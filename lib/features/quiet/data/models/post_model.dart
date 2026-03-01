import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post.dart';

class PostModel extends Post {
  PostModel({
    required super.id,
    required super.content,
    required super.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json, String id) {
    final createdAtField = json['createdAt'];

    DateTime parsedDate;

    if (createdAtField is Timestamp) {
      parsedDate = createdAtField.toDate();
    } else if (createdAtField is String) {
      parsedDate = DateTime.parse(createdAtField);
    } else {
      throw FormatException('Invalid createdAt format');
    }

    return PostModel(
      id: id,
      content: json['content'] ?? '',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}