import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_alpha/widgets/icons.dart';

class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  late String _filePath;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initializeRecorder();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    // await _recorder.openAudioSession();
  }

  Future<void> _startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/audio_recording.wav';

    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.pcm16WAV,
      numChannels: 1,
      sampleRate: 16000,
    );

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    print('Audio saved to: $_filePath');
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _recorder.stopRecorder();
    // _recorder.closeAudioSession();
    // _recorder = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [ClickableMicIcon()]);
  }
}
