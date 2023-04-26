import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_alpha/cubits/chat/chat_cubit.dart';
import 'package:project_alpha/utils/realtime_audio.dart';

class CustomIcons {
  static const IconData mic_rounded = IconData(0xf8bd, fontFamily: 'MaterialIcons');
}

class ClickableMicIcon extends StatefulWidget {
  @override
  _ClickableMicIconState createState() => _ClickableMicIconState();
}

class _ClickableMicIconState extends State<ClickableMicIcon> {
  Color _iconColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    ChatCubit chatCubit = context.read<ChatCubit>();
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_iconColor == Colors.blue) {
            chatCubit.startRecording();
          } else {
            chatCubit.stopRecording();
          }
          _iconColor = _iconColor == Colors.blue ? Colors.red : Colors.blue;
        });
      },
      child: Icon(
        CustomIcons.mic_rounded,
        size: 35,
        color: _iconColor,
      ),
    );
  }
}
