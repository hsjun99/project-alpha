import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_alpha/cubits/chat_model/chat_model_cubit.dart';
import 'package:project_alpha/models/chat_model.dart';
import 'package:project_alpha/models/message.dart';
import 'package:project_alpha/utils/constants.dart';
import 'package:project_alpha/utils/elevenlabs_audio.dart';
import 'package:project_alpha/utils/gpt.dart';
import 'package:project_alpha/utils/speechplayer.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  // final ChatModelsCubit chatModelsCubit;

  StreamSubscription<List<Message>>? _messagesSubscription;
  List<Message> _messages = [];

  late final String _roomId;
  late final String _myUserId;
  late final ChatModel _chatModel;

  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String _filePath = '';
  bool _isRecording = false;

  // String getModelName() => _modelName;

  void setMessagesListener(String roomId) async {
    _roomId = roomId;

    _myUserId = supabase.auth.currentUser!.id;

    final data = (await supabase.from('rooms').select('''
          chat_models ( id, name, prompt, created_at )
        ''').eq('id', roomId).single())['chat_models'];

    _chatModel = ChatModel(
        id: data['id'],
        name: data['name'],
        prompt: data['prompt'],
        createdAt: DateTime.parse(data['created_at']));

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
            emit(ChatLoaded(_messages, _chatModel, null));
          }
        });
  }

  Future<void> sendGPT(Message message) async {
    final response = (await GPT().getChatResponse(_chatModel.prompt + '\n' + message.content))
        .choices[0]
        .message
        .content;

    final gptMessage = Message(
      id: 'new',
      roomId: _roomId,
      modelId: _chatModel.id,
      content: response,
      createdAt: DateTime.now(),
      isMine: false,
    );

    _messages.insert(0, gptMessage);

    try {
      await Future.wait([
        SpeechPlayer().play(await ElevenLabsAudio().generateAudioFile(gptMessage.content)),
        supabase.from('messages').insert(gptMessage.toMap()),
      ]);

      emit(ChatLoaded(_messages, _chatModel, null));

      log("FINISHED!!!!!");
    } catch (e) {
      log(e.toString());
    }
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
    emit(ChatLoaded(_messages, _chatModel, null));

    try {
      await supabase.from('messages').insert(message.toMap());
      await sendGPT(message);
    } catch (_) {
      emit(ChatError('Error submitting message.'));
      _messages.removeWhere((message) => message.id == 'new');
      emit(ChatLoaded(_messages, _chatModel, null));
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> startRecording() async {
    _requestPermissions();
    _initializeRecorder();

    log("Start recording!!!");

    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/audio_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.pcm16WAV,
      numChannels: 1,
      sampleRate: 16000,
    );

    _isRecording = true;
  }

  Future<void> stopRecording() async {
    log("Stop Recording!!!");
    await _recorder.stopRecorder();

    _isRecording = false;

    print('Audio saved to: $_filePath');

    _recorder.closeRecorder();
    _recorder.stopRecorder();

    OpenAIAudioModel transcription = await GPT().getTranscript(_filePath);
    // log(transcription.text);
    emit(ChatLoaded(_messages, _chatModel, transcription.text));
    if (transcription.text.isNotEmpty) sendMessage(transcription.text);
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
