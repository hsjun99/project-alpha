import 'dart:developer';
import 'dart:io';

import 'package:elevenlabs/elevenlabs.dart';

class ElevenLabsAudio {
  Future<File> generateAudioFile(String text, {String voiceId = 'ErXwobaYiN019PkySvjV'}) async {
    final File file = await ElevenLabs.instance.create(
      text: text,
      voiceId: voiceId,
      fileName: "NewFile",
      stability: 1.0,
      similarityBoost: 1.0,
    );
    log("ElevenLabsAudio: ${file.path}");
    return file;
  }
}
