part of 'chat_model_cubit.dart';

@immutable
abstract class ChatModelsState {}

class ChatModelsInitial extends ChatModelsState {}

class ChatModelsLoaded extends ChatModelsState {
  ChatModelsLoaded({
    required this.models,
  });

  final Map<String, ChatModel> models;
}
