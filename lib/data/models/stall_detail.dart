
import 'package:hive/hive.dart';

part '../../generated/stall_detail.g.dart';

@HiveType(typeId: 0)
class StallDetail extends HiveObject {
  @HiveField(0)
  final String? imageUrl;

  @HiveField(1)
  final String? date;

  @HiveField(2)
  final String? title;

  @HiveField(3)
  final String? description;


  StallDetail({
    required this.date,
    required this.title,
    required this.description,

    required this.imageUrl,
  });
}
