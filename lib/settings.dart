import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'globals.dart';

//void main() => runApp(const Settings());

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text('Volume'),
              Slider(
                value: glTtsVolume,
                max: 1,
                //divisions: 10,
                label: glTtsVolume.toString(),
                onChanged: (double value) {
                  setState(() {
                    glTtsVolume = value;
                  });
                },
              ),
              const Text('Speech rate'),
              Slider(
                value: glTtsRate,
                max: 1,
                //divisions: 10,
                label: glTtsRate.toString(),
                onChanged: (double value) {
                  setState(() {
                    glTtsRate = value;
                  });
                },
              ),
              Row(
                children: [
                  const Text('Autocomplexity: '),
                  CupertinoSwitch(
                    value: glAutoDifficultIncrease,
                    onChanged: (value) {
                      setState(() {
                        glAutoDifficultIncrease = value;
                      });
                    },
                  ),
                ],
              ),
              Text('Max number:  $glMaxNum'),
              Slider(
                value: glMaxNum.toDouble(),
                max: 100,
                //divisions: 10,
                label: glMaxNum.toString(),
                onChanged: (double value) {
                  setState(() {
                    glMaxNum = value.toInt();
                  });
                },
              ),
              Row(
                children: [
                  const Text('Mini-show: '),
                  CupertinoSwitch(
                    value: glIsPatternIcon,
                    onChanged: (value) {
                      setState(() {
                        glIsPatternIcon = value;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('UPPERCASE/lowercase: '),
                  CupertinoSwitch(
                    value: glIsCapital,
                    onChanged: (value) {
                      setState(() {
                        glIsCapital = value;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Pattern visible: '),
                  CupertinoSwitch(
                    value: glIsPattern,
                    onChanged: (value) {
                      setState(() {
                        glIsPattern = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
