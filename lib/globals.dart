/*
рус/укр/англ
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String glTTSlang = 'en-US';
double glTtsVolume = 0.5;
double glTtsRate = 0.5;
double glTtsPitch = 1.0;
bool glAutoDifficultIncrease = true;
int glMaxNum = 10;
bool glIsPatternIcon = true;
bool glIsCapital = true;
bool glIsPattern = true;

String glLangModel = 'en-US';

int glMode = 0, glMaxMode = 6; // 0 цифры, 1-буквы, 2-слоги, 3-слова,4,5.
double glLastFS = 200;
int glLastTextLength = 0;
Size glLastSize = const Size(0,0);
ButtonStyle bStyle = OutlinedButton.styleFrom(
  primary: Colors.white,
  backgroundColor: Colors.teal,
  shadowColor: Colors.red,
  elevation: 10,
);

String glTextToWrite = '', glLastTextToWrite = '';
int glLastMode = 0;

String glAllLetters = 'zxcvbnmasdfghjklqwertyuiop';

var rng = Random();
List<String> glCurModeTexts = [];
int glCurModePos = 0;

glDefineCurModeTexts(){
	glCurModeTexts = [];
	if (glMode == 0) {
		for (int i=0; i<glMaxNum+1; i++){
			glCurModeTexts.add(i.toString());
		}
	} else if (glMode == 1) {
		glCurModeTexts = glAllLetters.split('');
		for (int i=0; i<glCurModeTexts.length; i++) {
			if (glIsCapital) {
				glCurModeTexts[i] = glCurModeTexts[i].toUpperCase();
			} else {
				glCurModeTexts[i] = glCurModeTexts[i].toLowerCase();
			}
		}
	} else {
		for (var el in glAllWordsAndSyllables) {
			if (el.length == glMode) {
				glCurModeTexts.add(glIsCapital? el.toUpperCase() : el.toLowerCase());
			}
		}
	}
	glCurModeTexts.shuffle();
	glCurModePos=0;
}

glDefineTextToWrite(context){
	if (glLastMode != glMode) {
		String _text = '';
		if (glMode == 0) {
			_text = 'Digits';
		} else if (glMode == 1) {
			_text = 'Letters';
		} else if (glMode == 2) {
			_text = 'Syllables';
		} else {
			_text = 'Words - $glMode';
		}
		showMode(context, _text);
	}
	glTextToWrite = glCurModeTexts[glCurModePos];
	if (glIsCapital) {
		glTextToWrite = glTextToWrite.toUpperCase();
	} else {
		glTextToWrite = glTextToWrite.toLowerCase();
	}
	glLastMode = glMode;
	glCurModePos++;
	if (glCurModePos == glCurModeTexts.length) {
		glCurModePos = 0;
		if (glAutoDifficultIncrease) {
			if (glIsPattern) {
				glIsPattern = false;
			} else {
				glIsPattern = true;
				if (glMode==0) {
					glMode=1;
				} else {
					if(glIsCapital){
						glIsCapital = false;
					} else {
						glIsCapital = true;
						glMode++;
						if (glMode == glMaxMode+1) {
							glMode = 0;
						}
					}
				}
			}
		}
		glDefineCurModeTexts();
	}
	saveLastState();
}

showAlertPage(context, String msg, {int delay=0}) async {
	await showDialog(
			context: context,
			builder: (context) {
				if (delay>0) {
					Future.delayed(Duration(seconds: delay), (){
						Navigator.pop(context);
					});
				}
				return AlertDialog(
					content: Text(msg),
				);
			}
	);
}

List <String> glGoodAnswerMsgs = ['Super!', 'Ok!', 'Well done!', 'Right!', 'Cool!','You are the best!','Good job!'];
List <String> glBadAnswerMsgs = ['Alas, wrong', 'No, pay attention!','Try again!', "I didn't get it. \n Write it again!"];

String get glGoodAnswerMsg => glGoodAnswerMsgs[rng.nextInt(glGoodAnswerMsgs.length)];
String get glBadAnswerMsg => glBadAnswerMsgs[rng.nextInt(glBadAnswerMsgs.length)];

List<String> glAllWordsAndSyllables = [
"in",
"of",
"to",
"is",
"it",
"on",
"no",
"us",
"at",
"un",
"go",
"an",
"my",
"up",
"me",
"as",
"he",
"we",
"so",
"be",
"by",
"or",
"do",
"if",
"hi",
"bi",
"ex",
"ok",
"And", "Fix", "Own",
"Are", "Fly", "Odd",
"Ape", "Fry", "Our",
"Ace", "For", "Pet",
"Act", "Got", "Pat",
"Ask", "Get", "Peg",
"Arm", "God", "Paw",
"Age", "Gel", "Pup",
"Ago", "Gas", "Pit",
"Air", "Hat", "Put",
"Ate", "Hit", "Pot",
"All", "Has", "Pop",
"But", "Had", "Pin",
"Bye", "How", "Rat",
"Bad", "Her", "Rag",
"Big", "His", "Rub",
"Bed", "Hen", "Row",
"Bat", "Ink", "Rug",
"Boy", "Ice", "Run",
"Bus", "Ill", "Rap",
"Bag", "Jab", "Ram",
"Box", "Jug", "Sow",
"Bit", "Jet", "See",
"Bee", "Jam", "Saw",
"Buy", "Jar", "Set",
"Bun", "Job", "Sit",
"Cub", "Jog", "Sir",
"Cat", "Kit", "Sat",
"Car", "Key", "Sob",
"Cut", "Lot", "Tap",
"Cow", "Lit", "Tip",
"Cry", "Let", "Top",
"Cab", "Lay", "Tug",
"Can", "Mat", "Tow",
"Dad", "Man", "Toe",
"Dab", "Mad", "Tan",
"Dam", "Mug", "Ten",
"Did", "Mix", "Two",
"Dug", "Map", "Use",
"Den", "Mum", "Van",
"Dot", "Mud", "Vet",
"Dip", "Mom", "Was",
"Day", "May", "Wet",
"Ear", "Met", "Win",
"Eye", "Net", "Won",
"Eat", "New", "Wig",
"End", "Nap", "War",
"Elf", "Now", "Why",
"Egg", "Nod", "Who",
"Far", "Net", "Way",
"Fat", "Not", "Wow",
"Few", "Nut", "You",
"Fan", "Oar", "Yes",
"Fun", "One", "Yak",
"Fit", "Out", "Yet",
"Fin", "Owl", "Zip",
"Fox", "Old", "Zap",

"Bake", "Word", "List",
"Four", "Five", "Nine",
"Good", "Best", "Cute",
"Zero", "Huge", "Cool",
"Tree", "Race", "Rice",
"Keep", "Lace", "Beam",
"Game", "Mars", "Tide",
"Ride", "Hide", "Exit",
"Hope", "Cold", "From",
"Need", "Stay", "Come",

"Seven",
"About",
"Again",
"Heart",
"Pizza",
"Water",
"Happy",
"Green",
"Music",
"Three",
"Party",
"Woman",
"Dream",
"Apple",
"Tiger",
"River",
"Money",
"House",
"Alone",
"After",
"Women",
"Thing",
"Light",
"Story",
"India",
"Today",
"Candy",
"Puppy",
"Above",
"Queen",
"Plant",
"Black",
"Zebra",
"Train",
"Under",
"Eight",
"Panda",
"Truck",
"Never",
"Color",
"Mouse",
"Paper",
"Dress",
"Table",
"White",
"Great",
"Sweet",
"Beach",
"Plate",
"Right",

"Purple",
"Orange",
"Family",
"People",
"Animal",
"Father",
"Yellow",
"Circle",
"School",
"Spring",
"Monkey",
"Mother",
"Winter",
"Indian",
"Strong",
"Cookie",
"Turkey",
"Better",
"Number",
"Little",
"Health",
"Summer",
"Donkey",
"Things",
"Flower",
"Easter",
"Pretty",
"Island",
"Church",
"Before",
"Garden",
"Always",
"Please",
"Rocket",
"Golden",
"Rabbit",
"Kitten",
"Coming",
"Spider",
"Crayon",
"Answer",
"Making",
"Farmer",
"Indigo",
"Almost",
"Icicle",
"Sticky",
"Zipper",
"Freely"
];

bool glAnswerIsCorrect(String answer){
	print('a $answer mod $glMode / $glLastMode');
	if (glLastMode == 0) {
		if (answer == 'o' || answer == 'O') {
			answer = '0';
		} else if (answer == 'S' || answer == 's') {
			answer = '5';
		} else if (answer == 'l' || answer == 'L' || answer == '/') {
			answer = '1';
		} else if (answer == 'b' || answer == 'B') {
			answer = '6';
		}
	} else if (glLastMode == 1) {
		if (answer == '0') {
			answer = 'o';
		} else if (answer == '5' ) {
			answer = 's';
		} else if (answer == '1' || answer == '/') {
			answer = 'l';
		} else if (answer == '6' ) {
			answer = 'b';
		}
	}
	answer = answer.toLowerCase();
	if (glMode > 1) {
		if (answer.indexOf('0')>-1 || answer.indexOf('5')>-1
				|| answer.indexOf('1')>-1 || answer.indexOf('6')>-1
				|| answer.indexOf('/')>-1
		) {
			answer = answer.replaceAll('0', 'o')
					.replaceAll('5', 's')
					.replaceAll('1', 'l')
					.replaceAll('/', 'l')
					.replaceAll('6', 'b');
		}
	}
	String _pattern = glTextToWrite.toLowerCase().replaceAll('ё', 'е');
	print('compare $answer to $_pattern');
	return answer == _pattern;
}

String glFormTaskMsg() {
	if (glLastMode == 0) {
		return 'Write digit "$glTextToWrite"';
	} else if (glLastMode == 1) {
		String _text = glTextToWrite.toUpperCase();
		if (_text=='К' || _text=='к') {
			_text = 'КА';
		} else if (_text=='В' || _text=='в') {
			_text = 'ВЭ';
		} else if (_text=='ф' || _text=='Ф') {
			_text = 'ЭФ';
		} else if (_text=='С' || _text=='с') {
			_text = 'ЭС';
		} else if (_text=='Б' || _text=='б') {
			_text = 'БЭ';
		} else if (_text=='Ж' || _text=='ж') {
			_text = 'ЖЕ';
		}
		String s = 'Write letter "$_text"';
		return s;
	}
	return 'Write word "$glTextToWrite"';
}

showMode(context, text){
	ScaffoldMessenger.of(context).showSnackBar(SnackBar(
		content: Text(text),
	));
}

saveLastState() async {
	SharedPreferences prefs = await SharedPreferences.getInstance();
	prefs.setBool('glIsCapital', glIsCapital);
	prefs.setBool('glIsPattern', glIsPattern);
	prefs.setInt('glMode', glMode);
	prefs.setInt('glLastMode', glLastMode);
	prefs.setInt('glCurModePos', glCurModePos);
	print('saveCurState ok');
}

saveState() async {
	SharedPreferences prefs = await SharedPreferences.getInstance();
	prefs.setDouble('glTtsVolume', glTtsVolume);
	prefs.setDouble('glTtsRate', glTtsRate);
	prefs.setDouble('glTtsPitch', glTtsPitch);
	prefs.setDouble('glTtsVolume', glTtsVolume);
	prefs.setBool('glAutoDifficultIncrease', glAutoDifficultIncrease);
	prefs.setBool('glIsCapital', glIsCapital);
	prefs.setBool('glIsPattern', glIsPattern);
	prefs.setBool('glIsPatternIcon', glIsPatternIcon);
	prefs.setInt('glMaxNum', glMaxNum);
	prefs.setString('glLangModel', glLangModel);
	prefs.setInt('glMode', glMode);
	prefs.setInt('glLastMode', glLastMode);
	prefs.setInt('glCurModePos', glCurModePos);
}

restoreState() async {
	SharedPreferences prefs = await SharedPreferences.getInstance();
	glTtsVolume = prefs.getDouble('glTtsVolume') ?? glTtsVolume;
	glTtsRate = prefs.getDouble('glTtsRate') ?? glTtsRate;
	glTtsPitch = prefs.getDouble('glTtsPitch') ?? glTtsPitch;
	glTtsVolume = prefs.getDouble('glTtsVolume') ?? glTtsVolume;
	glAutoDifficultIncrease = prefs.getBool('glAutoDifficultIncrease') ?? glAutoDifficultIncrease;
	glIsCapital = prefs.getBool('glIsCapital') ?? glIsCapital;
	glIsPattern = prefs.getBool('glIsPattern') ?? glIsPattern;
	glIsPatternIcon = prefs.getBool('glIsPatternIcon') ?? glIsPatternIcon;
	glMaxNum = prefs.getInt('glMaxNum') ?? glMaxNum;
	glLangModel = prefs.getString('glLangModel') ?? glLangModel;
	glMode = prefs.getInt('glMode') ?? glMode;
	print('got glMode $glMode');
	glLastMode = prefs.getInt('glLastMode') ?? glLastMode;
	glCurModePos = prefs.getInt('glCurModePos') ?? glCurModePos;
	print('got glCurModePos $glCurModePos');
}
