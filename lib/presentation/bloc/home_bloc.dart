import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:gatherly/data/models/data_stall.dart';
import 'package:gatherly/data/models/stall_detail.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc {
  final _stallsSubject = BehaviorSubject<List<StallDetail>>();
  final BehaviorSubject<bool> _showSearchBarSubject =
      BehaviorSubject<bool>.seeded(true);
  Box<StallDetail>? _box;
  bool _useFirestore = false;
  final _firestoreSubject = BehaviorSubject<bool>();
  final Reference firebaseStorageRef = FirebaseStorage.instance.ref();

  HomeBloc() {
    _initialize();
  }

  void _initialize() async {
    _box = Hive.box<StallDetail>('stalls');
    fetchData();
  }

  Stream<List<StallDetail>> get stallsStream => _stallsSubject.stream;
  Stream<bool> get showSearchBarStream => _showSearchBarSubject.stream;
  bool get showSearchBar => _showSearchBarSubject.value;
  Stream<bool> get firestoreStream => _firestoreSubject.stream;
  bool get useFirestore => _useFirestore;

  Future<String> _getDownloadURL(String imagePath) async {
    try {
      final ref = firebaseStorageRef.child(imagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint("Error getting download URL: $e");
      return "";
    }
  }

  Future<int> getFileCount(int stallIndex) async {
    if (_useFirestore) {
      final snapshot = await FirebaseFirestore.instance
          .collection('stalls')
          .doc(stallIndex.toString())
          .collection('media')
          .get();
      return snapshot.docs.length;
    } else {
      final box = await Hive.openBox<DataStall>('mediaBox_$stallIndex');
      return box.length;
    }
  }

  void addStall(StallDetail stall) async {
    if (_useFirestore) {
      final downloadURL = await _getDownloadURL(stall.imageUrl ?? "");
      await FirebaseFirestore.instance.collection('stalls').add({
        'date': stall.date,
        'title': stall.title,
        'description': stall.description,
        'imageUrl': downloadURL,
      });
    } else {
      await _box?.add(stall);
    }
    fetchData();
  }

  void fetchData() async {
    if (_useFirestore) {
      final snapshot =
          await FirebaseFirestore.instance.collection('stalls').get();
      final stalls = snapshot.docs
          .map((doc) => StallDetail(
                date: doc['date'],
                title: doc['title'],
                description: doc['description'],
                imageUrl: doc['imageUrl'],
              ))
          .toList();
      _stallsSubject.add(stalls);
    } else {
      _stallsSubject.add(_box!.values.toList());
    }
  }

  void setShowSearchBar(bool value) {
    if (_showSearchBarSubject.value != value) {
      _showSearchBarSubject.add(value);
    }
  }

  void switchToFirestore(bool useFirestore) {
    _useFirestore = useFirestore;
    _firestoreSubject.add(_useFirestore);
    fetchData();
  }

  void dispose() {
    _stallsSubject.close();
    _showSearchBarSubject.close();
  }
}

final homeBloc = HomeBloc();
