import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'globals.dart';

class DigitalInkPainter extends CustomPainter {
  final List<List<Offset>> writings;
  final double strokeWidth;
  final Color strokeColor;

  DigitalInkPainter({
    this.writings = const [],
    this.strokeWidth = 4.0,
    this.strokeColor = Colors.black87,
  });

  TextPainter prepareText(String _text, fs, size) {
    TextPainter textPainter;
    TextStyle textStyle;
    TextSpan textSpan;

    textStyle = TextStyle(
      color: Colors.green,
      //fontFamily: 'KleeOne', //'BadScript',
      fontFamily: 'Cav2', //glMode==0? 'Cav1' : 'Caveat',
      fontSize: fs,
      //fontWeight: FontWeight.w100,
    );

    textSpan = TextSpan(
      text: _text,
      style: textStyle,
    );

    textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width,);

    return textPainter;
  }

  double calcFS(_text, size){
    double fs = 200;
    double maxW = size.width*0.8;
    double maxH = size.height*0.8;
    print('fs $fs maxW $maxW maxH $maxH');
    bool vertMode = !(maxW > maxH);
    if (!vertMode) {
      maxH *= 1.5;
    }
    print('vertMode $vertMode');
    TextPainter textPainter;

    do {
      textPainter = prepareText(_text, fs, size);

      double w = textPainter.width;
      double h = textPainter.height;

      //print('got w $w h $h for fs $fs');
      if (w < maxW && h < maxH) {
        fs *= 1.1;
      } else {
        if (w > maxW*1.1 || h > maxH*1.1) {
          fs *= 0.9;
        } else {
          break;
        }
      }
    } while (true);
    print('exit on fs $fs');
    return fs;
  }

  paintText(String _text, canvas, Size size) {
    _text = _text.replaceAll('g', 'д').replaceAll('y', 'у');
    double fs = glLastFS;
    TextPainter textPainter = prepareText(_text, fs, size);
    if (_text.length != glLastTextLength
        || size != glLastSize
        || textPainter.width*1.1 > size.width
    ) {
      print('recalc');
      fs = calcFS(_text, size);
      if (_text.length == 2) {
        //fs *= 0.9;
      }
      glLastFS = fs;
      glLastSize = size;
      glLastTextLength = _text.length;
      textPainter = prepareText(_text, fs, size);
    }

    final xCenter = (size.width - textPainter.width) / 2 - 30;
    double yCenter = (size.height - textPainter.height) / 2;
    if (textPainter.height > size.height) {
      print('yC $yCenter');
      if (!glIsCapital) {
        yCenter -= 15;
      }
      print('change yC to $yCenter');
    }
    final offset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, offset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    canvas.drawColor(Colors.teal[100]!, BlendMode.multiply);
    if (glIsPattern) {
      paintText(glTextToWrite, canvas, size);
    }
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = BlendMode.srcOver;

    for (List<Offset> points in writings) {
      _paintLine(points, canvas, paint);
    }
  }

  void _paintLine(List<Offset> points, Canvas canvas, Paint paint) {
    final start = points.first;
    final path = Path()..fillType = PathFillType.evenOdd;

    path.moveTo(start.dx, start.dy);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DigitalInkPainter oldPainter) => true;
}