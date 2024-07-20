import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gatherly/data/models/data_stall.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StallBloc {
  final BehaviorSubject<List<DataStall>> _mediaPathsSubject =
      BehaviorSubject<List<DataStall>>();
  final BehaviorSubject<int> _fileCountSubject = BehaviorSubject<int>();
  Box<DataStall>? _mediaBox;
  final String boxName;
  final bool useFirestore;

  StallBloc(this.boxName, {this.useFirestore = false}) {
    _initialize();
  }

  Future<void> _initialize() async {
    _mediaBox = await Hive.openBox<DataStall>(boxName);
    _fetchData();
  }

  Stream<List<DataStall>> get mediaPathsStream => _mediaPathsSubject.stream;
  Stream<int> get fileCountStream => _fileCountSubject.stream;

  Future<void> addMedia(DataStall media) async {
    if (useFirestore) {
      try {
        final fileRef = FirebaseStorage.instance
            .ref()
            .child('stalls/${media.path!.split('/').last}');
        await fileRef.putFile(File(media.path!));
        final downloadUrl = await fileRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('stalls/$boxName/media')
            .add({
          'path': downloadUrl,
          'isVideo': media.isVideo,
        });
      } catch (e) {
        debugPrint('Error uploading to Firebase: $e');
      }
    } else {
      await _mediaBox?.add(media);
    }
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (useFirestore) {
      final snapshot = await FirebaseFirestore.instance
          .collection('stalls/$boxName/media')
          .get();
      final mediaList = snapshot.docs
          .map((doc) => DataStall(
                path: doc['path'],
                isVideo: doc['isVideo'],
              ))
          .toList();
      _mediaPathsSubject.add(mediaList);
      _fileCountSubject.add(mediaList.length);
    } else {
      final mediaList = _mediaBox!.values.toList();
      _mediaPathsSubject.add(mediaList);
      _fileCountSubject.add(mediaList.length);
    }
  }

  void dispose() {
    _mediaPathsSubject.close();
    _fileCountSubject.close();
    _mediaBox?.close();
  }
}
