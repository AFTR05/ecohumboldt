class Reward {
  final String id;
  final String title;
  final String description;
  final int costPoints;
  final String imageUrl;
  final int stock;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.costPoints,
    required this.imageUrl,
    required this.stock,
  });

  factory Reward.fromMap(String id, Map<String, dynamic> data) {
    return Reward(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      costPoints: data['costPoints'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      stock: data['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'costPoints': costPoints,
      'imageUrl': imageUrl,
      'stock': stock,
    };
  }
}
