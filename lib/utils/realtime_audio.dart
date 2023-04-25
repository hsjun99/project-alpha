import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:mic_stream/mic_stream.dart';
import 'package:path_provider/path_provider.dart';

class RealtimeAudio {
  final int bufferSize = 44100; // 1 second of audio at 16 kHz
  Future<void> temp() async {
    // Initialize microphone stream
    Stream<Uint8List>? stream = await MicStream.microphone(sampleRate: 44100);

    // Create a temporary file
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/chunk.wav';
    final file = File(filePath);
    final sink = file.openWrite();

    List<int> buffer = [];
    StreamSubscription<Uint8List> listener;

    listener = stream!.listen((samples) {
      log("Received ${samples.length} samples");
      buffer.addAll(samples);

      if (buffer.length >= bufferSize) {
        // Write the chunk to the file
        sink.add(buffer);

        // Clear the buffer
        buffer = [];
      }
    });
    Future.delayed(Duration(seconds: 10), () async {
      await listener.cancel();
      await sink.close();
      print('Finished recording audio chunk to: $filePath');
    });
  }
}
