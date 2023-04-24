import 'dart:async';
import 'dart:developer';

import 'package:dart_openai/openai.dart';

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
}
