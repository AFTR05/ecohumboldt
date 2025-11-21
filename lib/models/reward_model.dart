class Reward {
  final String id;
  final String title;
  final String description;
  final int costPoints;
  final int stock;
  final String imageUrl;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.costPoints,
    required this.stock,
    required this.imageUrl,
  });

  factory Reward.fromMap(String id, Map<String, dynamic> data) {
    return Reward(
      id: id,
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      costPoints: data["costPoints"] ?? 0,
      stock: data["stock"] ?? 0,
      imageUrl: data["imageUrl"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "costPoints": costPoints,
      "stock": stock,
      "imageUrl": imageUrl,
    };
  }
}
