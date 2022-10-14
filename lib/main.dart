/* Задачи
2 - ru ukr * other + base - eng
опред яз системы - ru / ukr
gl - msgs
+ автоперевод на язык...
tts

Настр:
choose lang to learn
основа паттерн / без
цифры / буквы / микс / слоги

 */

import 'package:flutter/material.dart';
import 'package:learning_digital_ink_recognition/learning_digital_ink_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';
import 'letters_trainer.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late FlutterTts flutterTts;
  bool isModelDownloaded = false;

  @override
  void initState() {
    super.initState();
    trySkipIntroPage();
  }

  trySkipIntroPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? mode = prefs.getInt('glMode');

    print('got mode $mode');

    if (mode != null) {
      setState(() {
        isModelDownloaded = true;
      });
      Navigator.push(context,
        MaterialPageRoute(builder: (context)=>const LettersTrainer())
      );
    } else {
      print('start at ${DateTime.now()}');
      _loadModel();
      flutterTts = FlutterTts();
      await flutterTts.setVolume(glTtsVolume);
      await flutterTts.setSpeechRate(glTtsRate);
      await flutterTts.setPitch(glTtsPitch);
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.setLanguage(glTTSlang);
      await flutterTts.speak('Hello!');
      await flutterTts.speak("I'm your teacher!");
      await flutterTts.speak("Let play!");
      await flutterTts.speak("I'll ask you for letters and digits, and you draw them and press OK.");
      await flutterTts.speak('To start, wait for the images to load and tap the button GO');
    }
  }

  _loadModel() async {
    bool isDownloaded = await DigitalInkModelManager.isDownloaded(glLangModel);
    print('model isDownloaded? $isDownloaded at ${DateTime.now()}');
    if (!isDownloaded) {
      await DigitalInkModelManager.download(glLangModel);
      print('model isDownloaded at ${DateTime.now()}');
    }
    setState(() {
      isModelDownloaded = true;
      print('set isModelDownloaded=true at ${DateTime.now()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Write teacher'),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text("""
Hey!
  
Let's play!
  
I will tell you letters and numbers. Try to draw them correctly and press "OK".

You can use < and > arrows to navigate between the elements of the current data set.
Use arrows << and >> to select the mode - numbers, letters or words.
In the settings menu, you can turn off the preview at the bottom of the screen, switch the mode to UPPER or lower letters, etc.
                  
Ready to start? Wait for the images to load and tap "GO!"
""", textAlign: TextAlign.justify,),

              isModelDownloaded?
              OutlinedButton(
                style: bStyle,
                child: Text('GO!'),
                onPressed: (){
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>const LettersTrainer())
                  );
                },
              )
                  :
              Container(
                color: Colors.cyanAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text('Loading...'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }

}