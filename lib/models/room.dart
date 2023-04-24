import 'package:project_alpha/models/message.dart';

class Room {
  Room({
    required this.id,
    required this.createdAt,
    required this.modelId,
    this.lastMessage,
  });

  /// ID of the room
  final String id;

  /// Date and time when the room was created
  final DateTime createdAt;

  /// ID of the user who the user is talking to
  final String modelId;

  /// Latest message submitted in the room
  final Message? lastMessage;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a room object from room_participants table
  // Room.fromRoomParticipants(Map<String, dynamic> map)
  //     : id = map['room_id'],
  //       otherUserId = map['profile_id'],
  //       createdAt = DateTime.parse(map['created_at']),
  //       lastMessage = null;

  Room.fromModel(Map<String, dynamic> map)
      : id = map['id'],
        modelId = map['chat_model_id'],
        createdAt = DateTime.parse(map['created_at']),
        lastMessage = null;

  Room copyWith({
    String? id,
    DateTime? createdAt,
    String? modelId,
    Message? lastMessage,
  }) {
    return Room(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      modelId: modelId ?? this.modelId,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
