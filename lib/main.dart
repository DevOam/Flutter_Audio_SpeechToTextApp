import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(MyApp3());
}
class MyApp3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyWidget());
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late Record audioRecord;
  late AudioPlayer audioplayer;
  bool isRecording = false;
  String audioPath = '';
  String text = "hh";

  SpeechToText speechToText = SpeechToText();

  @override
  void initState() {
    audioRecord = Record();
    audioplayer = AudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    audioRecord.dispose();
    audioplayer.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    if (await audioRecord.hasPermission()) {
      await audioRecord.start();
      setState(() {
        isRecording = true;
      });
    }
  }

  Future<void> stopRecording() async {
    String? path = await audioRecord.stop();
    setState(() {
      isRecording = false;
      audioPath = path!;
    });
  }

  Future<void> playRecording() async {
    if (audioPath.isNotEmpty) {
      Source urlSource = UrlSource(audioPath);
      await audioplayer.play(urlSource);
    }

    var availabl = await speechToText.initialize();
    if (availabl == true) {
      setState(() {
        text = "hh";
        speechToText.listen(onResult: (result) {
          setState(() {
            text = result.recognizedWords;
          });
        });
      });
    }
  }

  Future<void> convert() async {
    var availabl = await speechToText.initialize();
    if (availabl) {
      setState(() {
        speechToText.listen(onResult: (result) {
          text = result.recognizedWords;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Audio/'),
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (isRecording) Text('Recording.....'),
                ElevatedButton(
                  onPressed: isRecording ? stopRecording : startRecording,
                  child: isRecording
                      ? Text('Stop recording')
                      : Text('Start recording'),
                ),
                SizedBox(height: 25),
                if (!isRecording && audioPath.isNotEmpty)
                  ElevatedButton(
                    onPressed: playRecording,
                    child: Text("Play record"),
                  ),
                SizedBox(height: 25),
                if (!isRecording && audioPath.isNotEmpty)
              ElevatedButton(
                onPressed: convert,
                child: Text("Transcribe audio"),
              ),
                SizedBox(height: 25),
                Text(
                  "Transcription: $text",
                  style: TextStyle(fontSize: 6),
                ),
              ],
            ),
            ),
        );
    }
}
