/*
*/
import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text('This program was invented and developed by a programmer', textAlign: TextAlign.center,),
              const Text('Prykhozhenko Volodymyr', textAlign: TextAlign.center),
              Image.asset('assets/v1.jpg', height: 309,),
              const Text("""
              
  The program is designed to develop the skill of writing letters and numbers for children.
  This simulator allows children to work out difficult letters in a playful way, to cultivate perseverance in achieving goals.
  By default, the program gradually increases the complexity of tasks.
  Its algorithm works as follows: numbers - numbers without a hint - uppercase letters - uppercase letters without a hint - lowercase letters - lowercase letters without a hint - words, etc.
  You can use < and > arrows to navigate between the elements of the current data set.
  With arrows << and >> you can manually select the mode - numbers / letters / words.
  In the settings menu, you can turn off the preview at the bottom of the screen.
                  
  Good luck!                  
""", textAlign: TextAlign.justify,),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Please, email comments and suggestions to', textAlign: TextAlign.center),
              ),
              Container(
                color: Colors.yellow[100],
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SelectableText('vprihogenko@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, ),),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text("Health to you and your children!", textScaleFactor: 1.5, style: TextStyle(color: Colors.blue), textAlign: TextAlign.center,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
