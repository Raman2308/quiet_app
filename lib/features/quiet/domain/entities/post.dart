class Post {
  final String id;
  final String content;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  /// Factory for creating a new post
  factory Post.create(String content) {
    return Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      createdAt: DateTime.now(),
    );
  }

  /// Convert Post -> Map (for Firestore/API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert Map -> Post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Copy method (useful for updates)
  Post copyWith({String? id, String? content, DateTime? createdAt}) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
