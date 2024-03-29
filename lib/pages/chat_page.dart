import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_alpha/components/audio_recorder.dart';
import 'package:project_alpha/components/model_avatar.dart';
import 'package:project_alpha/components/user_avatar.dart';
import 'package:project_alpha/cubits/chat/chat_cubit.dart';
import 'package:project_alpha/cubits/chat_model/chat_model_cubit.dart';
import 'package:project_alpha/models/chat_model.dart';

import 'package:project_alpha/models/message.dart';
import 'package:project_alpha/utils/constants.dart';
import 'package:project_alpha/widgets/icons.dart';
import 'package:project_alpha/widgets/typing_indicator.dart';
import 'package:timeago/timeago.dart';

/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  static Route<void> route(String roomId) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ChatCubit>(
        create: (context) => ChatCubit()..setMessagesListener(roomId),
        child: const ChatPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    log("INIT CHAT");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: AudioRecorder()),
          ),
        ],
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            context.showErrorSnackBar(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is ChatInitial) {
            log("CHAT_NOT_LOADED!!!");
            return preloader;
          } else if (state is ChatLoaded) {
            log("CHAT_LOADED!!!");
            final messages = state.messages;
            log(messages.length.toString());
            log(state.isTyping.toString());
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _ChatBubble(message: message);
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: TypingIndicator(
                    showIndicator: state.isTyping,
                    bubbleColor: Theme.of(context).primaryColor,
                  ),
                ),
                const _MessageBar(),
              ],
            );
          } else if (state is ChatEmpty) {
            return const Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text('Start your conversation now :)'),
                  ),
                ),
                _MessageBar(),
              ],
            );
          } else if (state is ChatError) {
            return Center(child: Text(state.message));
          }
          throw UnimplementedError();
        },
      ),
    );
  }
}

/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  const _MessageBar({
    Key? key,
  }) : super(key: key);

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (state.audioText != null) _textController.text = state.audioText ?? '';
          });
        }
        return Material(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: EdgeInsets.only(
              top: 8,
              left: 8,
              right: 8,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    maxLines: null,
                    autofocus: true,
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _submitMessage(context),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage(context) async {
    final text = _textController.text;
    if (text.isEmpty) {
      return;
    }
    BlocProvider.of<ChatCubit>(context).sendMessage(text);
    _textController.clear();
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    ChatCubit chatCubit = BlocProvider.of<ChatCubit>(context);
    // log(chatCubit.state.toString());

    List<Widget> chatContents = [
      if (!message.isMine) ModelAvatar(modelId: message.profileId ?? ''),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: message.isMine ? Colors.grey[300] : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.createdAt, locale: 'en_short')),
      const SizedBox(width: 60),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}
