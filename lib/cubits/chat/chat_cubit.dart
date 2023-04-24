import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:project_alpha/models/message.dart';
import 'package:project_alpha/utils/constants.dart';
import 'package:project_alpha/utils/gpt.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  StreamSubscription<List<Message>>? _messagesSubscription;
  List<Message> _messages = [];

  late final String _roomId;
  late final String _myUserId;
  late final String _prompt;

  void setMessagesListener(String roomId) async {
    _roomId = roomId;

    _myUserId = supabase.auth.currentUser!.id;

    _prompt = (await supabase.from('rooms').select('''
          chat_models ( prompt )
        ''').eq('id', roomId).single())['chat_models']['prompt'];

    _messagesSubscription = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map<List<Message>>(
          (data) =>
              data.map<Message>((row) => Message.fromMap(map: row, myUserId: _myUserId)).toList(),
        )
        .listen((messages) {
          _messages = messages;
          if (_messages.isEmpty) {
            emit(ChatEmpty());
          } else {
            emit(ChatLoaded(_messages));
          }
        });
  }

  Future<void> sendMessage(String text) async {
    /// Add message to present to the user right away
    final message = Message(
      id: 'new',
      roomId: _roomId,
      profileId: _myUserId,
      content: text,
      createdAt: DateTime.now(),
      isMine: true,
    );
    _messages.insert(0, message);
    emit(ChatLoaded(_messages));

    try {
      await supabase.from('messages').insert(message.toMap());
      final response = (await GPT().getChatResponse(_prompt + '\n' + message.content))
          .choices[0]
          .message
          .content;
      log(response);
      final gptMessage = Message(
        id: 'new',
        roomId: _roomId,
        content: response,
        createdAt: DateTime.now(),
        isMine: false,
      );
      _messages.insert(0, gptMessage);
      await supabase.from('messages').insert(gptMessage.toMap());
    } catch (_) {
      emit(ChatError('Error submitting message.'));
      _messages.removeWhere((message) => message.id == 'new');
      emit(ChatLoaded(_messages));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
