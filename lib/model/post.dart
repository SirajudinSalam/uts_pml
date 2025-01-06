class PostModel {
  final String id;
  final String? user;
  final String title;
  final String body;
  final String? image;
  final String? imageId;
  PostModel({
    this.user,
    required this.id,
    required this.title,
    required this.body,
    this.image,
    this.imageId,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['\$id'] as String,
      user: map['user'] != null ? map['user'] as String : null,
      title: map['title'] as String,
      body: map['body'] as String,
      image: map['image'] != null ? map['image'] as String : null,
      imageId: map['imageId'] != null ? map['imageId'] as String : null,
    );
  }
}
