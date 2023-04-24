import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:project_alpha/models/chat_model.dart';
import 'package:project_alpha/utils/constants.dart';

part 'chat_model_state.dart';

class ChatModelsCubit extends Cubit<ChatModelsState> {
  ChatModelsCubit() : super(ChatModelsInitial());

  /// Map of app users cache in memory with profile_id as the key
  final Map<String, ChatModel?> _models = {};

  Future<void> getModel(String modelId) async {
    if (_models[modelId] != null) {
      return;
    }

    final data = await supabase.from('chat_models').select().match({'id': modelId}).single();

    if (data == null) {
      return;
    }
    _models[modelId] = ChatModel.fromMap(data);

    emit(ChatModelsLoaded(models: _models));
  }
}
