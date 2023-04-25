import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:project_alpha/models/chat_model.dart';
import 'package:project_alpha/utils/constants.dart';

part 'chat_model_state.dart';

class ChatModelsCubit extends Cubit<ChatModelsState> {
  ChatModelsCubit() : super(ChatModelsInitial());

  /// Map of app users cache in memory with profile_id as the key
  late final Map<String, ChatModel> _models;

  Future<void> initializeChatModels(context) async {
    final data =
        await supabase.from('chat_models').select().order('created_at', ascending: false).limit(12);

    final rows = List<Map<String, dynamic>>.from(data);
    _models = {
      for (var row in rows) (ChatModel.fromMap(row)).id: ChatModel.fromMap(row),
    };

    emit(ChatModelsLoaded(models: _models));
  }

  String getPrompt(String modelId) {
    if (_models[modelId] == null) {
      return '';
    }

    return _models[modelId]?.prompt ?? '';
  }

  // Future<void> getModel(String modelId) async {
  //   if (_models[modelId] != null) {
  //     return;
  //   }

  // final data = await supabase.from('chat_models').select().match({'id': modelId}).single();

  // if (data == null) {
  //   return;
  // }
  // _models[modelId] = ChatModel.fromMap(data);

  // emit(ChatModelsLoaded(models: _models));
  // }
}
