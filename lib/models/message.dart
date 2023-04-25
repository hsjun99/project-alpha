class Message {
  Message({
    required this.id,
    required this.roomId,
    this.profileId,
    this.modelId,
    required this.content,
    required this.createdAt,
    required this.isMine,
  });

  /// ID of the message
  final String id;

  /// ID of the user who posted the message
  final String? profileId;

  /// ID of the model used to generate the message
  final String? modelId;

  /// ID of the room the message belongs to
  final String roomId;

  /// Text content of the message
  final String content;

  /// Date and time when the message was created
  final DateTime createdAt;

  /// Whether the message is sent by the user or not.
  final bool isMine;

  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'room_id': roomId,
      'content': content,
    };
  }

  Message.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id = map['id'],
        roomId = map['room_id'],
        profileId = map['profile_id'],
        modelId = map['model_id'],
        content = map['content'],
        createdAt = DateTime.parse(map['created_at']),
        isMine = myUserId == map['profile_id'];

  Message copyWith({
    String? id,
    String? userId,
    String? modelId,
    String? roomId,
    String? text,
    DateTime? createdAt,
    bool? isMine,
  }) {
    return Message(
      id: id ?? this.id,
      profileId: userId ?? this.profileId,
      modelId: modelId ?? this.modelId,
      roomId: roomId ?? this.roomId,
      content: text ?? content,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
    );
  }
}
