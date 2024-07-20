import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part '../../generated/data_stall.g.dart';

@HiveType(typeId: 1)
class DataStall extends HiveObject {
  @HiveField(0)
  String? path;

  @HiveField(1)
  bool? isVideo;

  DataStall({required this.path, required this.isVideo});
 
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'isVideo': isVideo,
    };
  }

  factory DataStall.fromDocument(DocumentSnapshot doc) {
    return DataStall(
      path: doc['path'],
      isVideo: doc['isVideo'],
    );
  }
}
