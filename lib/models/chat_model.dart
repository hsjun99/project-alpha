class ChatModel {
  ChatModel({
    required this.id,
    required this.name,
    required this.prompt,
    required this.createdAt,
  });

  /// User ID of the profile
  final String id;

  /// Username of the profile
  final String name;

  /// Prompt of the profile
  final String prompt;

  /// Date and time when the profile was created
  final DateTime createdAt;

  ChatModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        prompt = map['prompt'],
        createdAt = DateTime.parse(map['created_at']);
}
