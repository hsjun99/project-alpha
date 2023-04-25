import 'dart:typed_data';

import 'package:mic_stream/mic_stream.dart';
import 'package:path_provider/path_provider.dart';

class RealtimeAudio {
  final int bufferSize = 16000; // 1 second of audio at 16 kHz
  Future<void> temp() async {
    // Initialize microphone stream
    Stream<Uint8List>? stream = await MicStream.microphone(sampleRate: 16000);

    // Create a temporary file
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/chunk.wav';
    final file = File(filePath);
    final sink = file.openWrite();

    List<int> buffer = [];
    StreamSubscription<List<int>> listener;

    listener = stream.listen((samples) {
      buffer.addAll(samples);

      if (buffer.length >= bufferSize) {
        // Write the chunk to the file
        sink.add(buffer);

        // Clear the buffer
        buffer = [];
      }
    });
  }
}
