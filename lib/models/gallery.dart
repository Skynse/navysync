class Gallery {
  final String id;
  final String name;
  final List<String> images;
  final String description;

  Gallery({
    required this.id,
    required this.name,
    required this.images,
    required this.description,
  });

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      id: json['id'] as String,
      name: json['name'] as String,
      images: List<String>.from(json['images'] as List),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': images,
      'description': description,
    };
  }
}
