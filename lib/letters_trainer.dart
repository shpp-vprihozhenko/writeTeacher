import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learning_digital_ink_recognition/learning_digital_ink_recognition.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'about.dart';
import 'globals.dart';
import 'painter.dart';
import 'settings.dart';

//void main() {LettersTrainer(MyApp());}

enum TtsState { playing, stopped, paused, continued }

class LettersTrainer extends StatelessWidget {
  const LettersTrainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryTextTheme: const TextTheme(
          headline6: TextStyle(color: Colors.white),
        ),
      ),
      home: ChangeNotifierProvider(
        create: (_) => DigitalInkRecognitionState(),
        child: const DigitalInkRecognitionPage(),
      ),
    );
  }
}

class DigitalInkRecognitionPage extends StatefulWidget {
  const DigitalInkRecognitionPage({Key? key}) : super(key: key);

  @override
  _DigitalInkRecognitionPageState createState() =>
      _DigitalInkRecognitionPageState();
}

class _DigitalInkRecognitionPageState extends State<DigitalInkRecognitionPage> {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  bool isCurrentLanguageInstalled = false;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  DigitalInkRecognitionState get state => Provider.of(context, listen: false);
  final DigitalInkRecognition _recognition = DigitalInkRecognition(model: glLangModel);

  double get _width => MediaQuery.of(context).size.width;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    initMyWidget();
  }

  initMyWidget() async {
    flutterTts = FlutterTts();
    await _setAwaitOptions();
    await flutterTts.setLanguage(glTTSlang);
    if (isAndroid) {
      await _getDefaultEngine();
    }
    await restoreState();
    glDefineCurModeTexts();
    setState(() {
      glDefineTextToWrite(context);
    });
    _speakCurrentTask(speakHello: true);
  }

  _speakCurrentTask({bool speakHello=false}) async {
    if (speakHello) {
      //await _speak(glHelloText);
    }
    print('m $glMode l $glTextToWrite');
    String _taskMsg = glFormTaskMsg();
    await _speak(_taskMsg);
  }

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _speak(_text) async {
    await flutterTts.setVolume(glTtsVolume);
    await flutterTts.setSpeechRate(glTtsRate);
    await flutterTts.setPitch(glTtsPitch);
    if (_text != null) {
      if (_text!.isNotEmpty) {
        await flutterTts.speak(_text!);
      }
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  @override
  void dispose() {
    _recognition.dispose();
    super.dispose();
    flutterTts.stop();
  }

  // need to call start() at the first time before painting the ink
  Future<void> _init() async {
    //print('Writing Area: ($_width, $_height)');
    await _recognition.start(writingArea: Size(_width, _height));
    // always check the availability of model before being used for recognition
    await _checkModel();
  }

  Future<void> _checkModel() async {
    bool isDownloaded = await DigitalInkModelManager.isDownloaded(glLangModel);

    if (!isDownloaded) {
      await DigitalInkModelManager.download(glLangModel);
    }
  }

  Future<void> _actionDown(Offset point) async {
    state.startWriting(point);
    await _recognition.actionDown(point);
  }

  Future<void> _actionMove(Offset point) async {
    state.writePoint(point);
    await _recognition.actionMove(point);
  }

  Future<void> _actionUp() async {
    state.stopWriting();
    await _recognition.actionUp();
  }

  Future<void> _startRecognition() async {
    flutterTts.stop();
    if (state.isNotProcessing) {
      state.startProcessing();
      // always check the availability of model before being used for recognition
      await _checkModel();
      state.data = await _recognition.process();
      state.stopProcessing();

      String answer = '';
      try {
        answer = state.data.first.text;
      } catch(e) {}
      print('res $answer');
      String msg;
      if (glAnswerIsCorrect(answer)){
        msg = glGoodAnswerMsg;
        await _speak(msg);
        //await showAlertPage(context, msg, delay: 1);
        glDefineTextToWrite(context);
        _speakCurrentTask();
      } else {
        msg = glBadAnswerMsg;
        _speak(msg+'.\n'+glFormTaskMsg());
        //await showAlertPage(context, msg, delay: 1);
      }

      state.reset();
      setState(() {});
      await _recognition.start(writingArea: Size(_width, _height));
    }
  }

  _restartGame(){
    print('restart with $glMode');
    glDefineCurModeTexts();
    glDefineTextToWrite(context);
    _speakCurrentTask();
    state.reset();
    setState(() {});
    _recognition.start(writingArea: Size(_width, _height));
  }

  _settings() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const Settings())
    );
    setState(() {});
    saveState();
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    double _h = MediaQuery.of(context).size.height;
    _height = _h>_w? _h*0.75 : _h*0.75;
    bool showAppBar = _h > _w;
    return Scaffold(
      appBar: showAppBar? AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.help_outline_outlined, size: 32,
          ),
          onPressed: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const About())
            );
          },
        ),
        title: Row(
          children: [
            const Expanded(child: Text('Write teacher')),
            IconButton(
              icon: const Icon(
                Icons.settings_outlined, size: 32,
              ),
              onPressed: _settings,
            ),
          ],
        ),
      ):null,
      body: Stack(
        children: [
          showAppBar?
          Positioned(
            left: 0,
            top: 40,
            child: Container(
              width: _w,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('write', textAlign: TextAlign.center, textScaleFactor: 4,
                    style: TextStyle(fontFamily: 'Cav2', color: Colors.green),
                  )
                ],
              ),
            ),
          )
              :
          SizedBox(),
          Positioned(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Builder(
                          builder: (_) {
                            _init();
                            return GestureDetector(
                              onScaleStart: (details) async =>
                              await _actionDown(details.localFocalPoint),
                              onScaleUpdate: (details) async =>
                              await _actionMove(details.localFocalPoint),
                              onScaleEnd: (details) async =>
                              await _actionUp(),
                              child: Consumer<DigitalInkRecognitionState>(
                                builder: (_, state, __) => CustomPaint(
                                  painter: DigitalInkPainter(writings: state.writings),
                                  child: SizedBox(
                                    width: _width,
                                    height: _height,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text('OK'),
        onPressed: _startRecognition,
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          showAppBar?
          const SizedBox()
              :
          IconButton(
            icon: const Icon(
              Icons.help_outline_outlined, size: 32,
            ),
            onPressed: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const About())
              );
            },
          ),
          TextButton(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.1415926),
              child: const Icon(Icons.double_arrow, color: Colors.black,),
            ),
            onPressed: (){
              glIsPattern = true;
              glIsCapital = true;
              if (glMode>0){
                glMode--;
              }
              _restartGame();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
            ),
            onPressed: (){
              glCurModePos = glCurModePos < 2? 0 : (glCurModePos-2);
              glDefineTextToWrite(context);
              _speakCurrentTask();
              state.reset();
              setState(() {});
              _recognition.start(writingArea: Size(_width, _height));
            },
          ),
          IconButton(
            icon: Stack(
              children: const [
                Positioned(
                  top:-2, left:0,
                  child: Icon(
                    Icons.replay_outlined, size: 38,
                  ),
                ),
                Positioned(
                  top: 12, left: 10,
                  child: Icon(
                    Icons.volume_up_outlined, size: 16, color: Colors.blue,
                  ),
                ),
              ]
            ),
            onPressed: _speakCurrentTask,
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_outlined,
            ),
            onPressed: (){
              glDefineTextToWrite(context);
              _speakCurrentTask();
              state.reset();
              setState(() {});
              _recognition.start(writingArea: Size(_width, _height));
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.double_arrow_outlined,
            ),
            onPressed: (){
              glIsPattern = true;
              glIsCapital = true;
              if (glMode < glMaxMode){
                glMode++;
              }
              _restartGame();
            },
          ),
          glIsPatternIcon ?
          TextButton(
            child: Container(
              color: const Color.fromRGBO(214, 255, 251, 0.9),
              //Colors.teal[100],
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Text(glTextToWrite,
                  style: TextStyle(
                    color: glIsPattern? Colors.green : Colors.grey,
                    fontFamily: 'Cav2',
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            onPressed: (){
              setState(() {
                glIsPattern = !glIsPattern;
              });
            },
          )
            :
          const SizedBox(),
          showAppBar?
          const SizedBox()
            :
          IconButton(
            icon: const Icon(
              Icons.settings_outlined, size: 32,
            ),
            onPressed: _settings,
          ),
        ],
      ),
    );
  }
}

class DigitalInkRecognitionState extends ChangeNotifier {
  List<List<Offset>> _writings = [];
  List<RecognitionCandidate> _data = [];
  bool isProcessing = false;

  List<List<Offset>> get writings => _writings;
  List<RecognitionCandidate> get data => _data;
  bool get isNotProcessing => !isProcessing;
  bool get isEmpty => _data.isEmpty;
  bool get isNotEmpty => _data.isNotEmpty;

  List<Offset> _writing = [];

  void reset() {
    _writings = [];
    notifyListeners();
  }

  void startWriting(Offset point) {
    _writing = [point];
    _writings.add(_writing);
    notifyListeners();
  }

  void writePoint(Offset point) {
    if (_writings.isNotEmpty) {
      _writings[_writings.length - 1].add(point);
      notifyListeners();
    }
  }

  void stopWriting() {
    _writing = [];
    notifyListeners();
  }

  void startProcessing() {
    isProcessing = true;
    notifyListeners();
  }

  void stopProcessing() {
    isProcessing = false;
    notifyListeners();
  }

  set data(List<RecognitionCandidate> data) {
    _data = data;
    notifyListeners();
  }

  @override
  String toString() {
    return isNotEmpty ? _data.first.text : '';
  }

  String toCompleteString() {
    return _data.first.text.toLowerCase();
    //return isNotEmpty ? _data.map((c) => c.text).toList().join(', ') : '';
  }
}