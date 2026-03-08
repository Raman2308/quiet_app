import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String content;
  final DateTime createdAt;
  final String userId;

  const Post({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userId,
  });

  /// Factory for creating a new post
  factory Post.create(String content) {
    return Post(
      id: '',
      content: content,
      createdAt: DateTime.now(),
      userId: '',
    );
  }

  /// Convert Post -> Map (for Firestore/API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  /// Convert Map -> Post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
    );
  }

  /// Copy method (useful for updates)
  Post copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    String? userId,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
