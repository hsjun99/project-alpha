import 'dart:developer';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

class SpeechPlayer {
  final player = AudioPlayer();

  Future<void> play(File audioFile) async {
    log("play!");

    final audioSource = AudioSource.uri(
      Uri.file(audioFile.path),
    );

    await player.setAudioSource(audioSource);
    // await player.setFilePath(audioFile.path);
    await player.play();
  }
}
