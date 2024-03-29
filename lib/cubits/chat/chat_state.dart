part of 'chat_cubit.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  ChatLoaded(this.messages, this.chatModel, this.audioText, this.isTyping);
  final List<Message> messages;
  final ChatModel chatModel;
  final String? audioText;
  final bool isTyping;
}

// class ChatAudioTextLoaded extends ChatState {
//   ChatAudioTextLoaded(this.audioText);
//   final String audioText;
// }

class ChatEmpty extends ChatState {}

class ChatError extends ChatState {
  ChatError(this.message);
  final String message;
}
