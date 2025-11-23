class DailyTask {
  final String id;
  final String title;
  final String description;
  final int points;
  final double grams;
  final String expectedObject; 
  // 👆 Objeto que la IA debe detectar: “botella”, “bicicleta”, “bolsa de tela”, etc.

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.grams,
    required this.expectedObject,
  });

  factory DailyTask.fromMap(String id, Map<String, dynamic> data) {
    return DailyTask(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      points: data['points'] ?? 0,
      grams: (data['grams'] ?? 0).toDouble(),
      expectedObject: data['expectedObject'] ?? '', 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'points': points,
      'grams': grams,
      'expectedObject': expectedObject,
    };
  }
}
