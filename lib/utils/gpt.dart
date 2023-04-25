import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';

class GPT {
  Future<void> test() async {
    List<OpenAIModelModel> models = await OpenAI.instance.model.list();
    OpenAIModelModel firstModel = models.first;
  }

  Future<void> testChat() async {
    Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat.createStream(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: "hello",
          role: OpenAIChatMessageRole.user,
        )
      ],
    );

    chatStream.listen((chatStreamEvent) {
      log(chatStreamEvent.choices[0].delta.content ?? ''); // ...
    });
  }

  Future<Stream<OpenAIStreamChatCompletionModel>> getChatStream(String query) async {
    Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat.createStream(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: query,
          role: OpenAIChatMessageRole.user,
        )
      ],
    );

    return chatStream;
  }

  Future<OpenAIChatCompletionModel> getChatResponse(String query) async {
    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: query,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );

    return chatCompletion;
  }

  Future<OpenAIAudioModel> getTranscript(File audioFile) async {
    OpenAIAudioModel transcription = await OpenAI.instance.audio.createTranscription(
      file: audioFile /* THE AUDIO FILE HERE */,
      model: "whisper-1",
      responseFormat: OpenAIAudioResponseFormat.json,
    );
    return transcription;
  }
}
