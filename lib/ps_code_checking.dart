import 'package:flutter/material.dart';
import 'dart:math';

/// This interface can be used to implement the code generator for
/// [PSCodeCheckingWidget]
abstract class CodeGenerator {
  String getCode();
}

/// This class is default code generator for [PSCodeCheckingWidget]
class SizedCodeGenerator implements CodeGenerator {
  final int _size;

  const SizedCodeGenerator({int size = 8}) : this._size = size;
  @override
  String getCode() {
    var code = "";
    for (var i = 0; i < _size; i++) {
      code = code + Random().nextInt(9).toString();
    }
    return code;
  }
}

/// This interface can be used to generate the color of different parts of
/// [PSCodeCheckingWidget].
///
/// You can implement this interface to a class and override the [ColorGenerator.getColor]
/// method to return the color for the component
abstract class ColorGenerator {
  Color getColor();
}

/// This class can be used to generate the single color
class SingleColorGenerator implements ColorGenerator {
  final Color color;

  SingleColorGenerator(this.color);
  @override
  Color getColor() {
    return color;
  }
}

/// This class is the default color generator for [PSCodeCheckingWidget]
class RandomColorGenerator implements ColorGenerator {
  final int r;
  final int g;
  final int b;

  /// Here r, g, b is the max value from rane 0-255. Color will be generated
  /// from Random().nextInt(value). Where value can be random value based on
  /// your input r, g, b values
  const RandomColorGenerator({this.r = 255, this.g = 255, this.b = 255});
  @override
  Color getColor() {
    final r = Random().nextInt(255);
    final g = Random().nextInt(225);
    final b = Random().nextInt(200);
    return Color.fromARGB(255, r, g, b);
  }
}

/// This controller class can be used to refresh or verify the code of [PSCodeCheckingWidget]
/// Please call the [CodeCheckController.dispose] method to clear all the refernces
class CodeCheckController extends ValueNotifier<void> {
  late bool Function(String)? _verify;
  CodeCheckController() : super(null);
  bool verify(String code) {
    return _verify!(code);
  }

  void refresh() {
    notifyListeners();
  }
}

/// This widget can be used to cross check the verification of the randomly
/// generated codes.
/// [dotMaxSize] should be greater than 5. Default 5 will be considered
class PSCodeCheckingWidget extends StatefulWidget {
  final int dotCount;
  final int? lineCount;
  final double height;
  final Color? backgroundColor;
  final CodeGenerator codeGenerator;
  final CodeCheckController controller;
  final ColorGenerator dotColorGenerator;
  final ColorGenerator lineColorGenerator;
  final ColorGenerator textColorGenerator;
  final double maxFontSize;
  final int dotMaxSize;
  final double lineWidth;

  int get _lineCode {
    return lineCount ?? (height * 0.45).toInt();
  }

  const PSCodeCheckingWidget({
    Key? key,
    required this.controller,
    this.dotColorGenerator = const RandomColorGenerator(),
    this.codeGenerator = const SizedCodeGenerator(),
    this.lineColorGenerator = const RandomColorGenerator(),
    this.textColorGenerator = const RandomColorGenerator(),
    this.backgroundColor,
    int? lineCount,
    this.dotCount = 50,
    this.height = 60,
    this.maxFontSize = 24,
    int dotMaxSize = 8,
    double lineWidth = 1,
  })  : assert(dotMaxSize > 5, "dotMax size should be greater than 5"),
        assert(lineWidth > -1, "line width can not be negative"),
        this.dotMaxSize = dotMaxSize,
        this.lineCount = lineCount,
        this.lineWidth = lineWidth,
        super(key: key);

  @override
  _PSCodeCheckingWidgetState createState() => _PSCodeCheckingWidgetState();
}

class _PSCodeCheckingWidgetState extends State<PSCodeCheckingWidget> {
  late String code;

  Map getRandomData(double width) {
    List list = code.split("");

    double x = 0.0;
    List mList = [];
    for (String item in list) {
      int fontWeight = 3 + Random().nextInt(5);
      TextSpan span = TextSpan(
          text: item,
          style: TextStyle(
              color: widget.textColorGenerator.getColor(),
              fontWeight: FontWeight.values[fontWeight],
              fontSize: widget.maxFontSize -
                  Random()
                      .nextInt(min(8, (widget.maxFontSize * 0.3).toInt()))));
      TextPainter painter =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      painter.layout();

      double y =
          Random().nextInt(widget.height.toInt()).toDouble() - painter.height;
      if (y < 0) {
        y = 0;
      }
      Map strMap = {"textPainter": painter, "x": x, "y": y};
      mList.add(strMap);
      x += painter.width + Random().nextInt(10);
    }
    double offsetX = (width - x) / 2;
    List dotData = [];

    for (var i = 0; i < widget.dotCount; i++) {
      double x = Random().nextInt(width.toInt()).toDouble();
      double y = Random().nextInt(widget.height.toInt()).toDouble();
      double dotWidth = Random().nextInt(widget.dotMaxSize).toDouble();
      Color color = widget.dotColorGenerator.getColor();
      Map dot = {"x": x, "y": y, "dotWidth": dotWidth, "color": color};
      dotData.add(dot);
    }
    List linedata = [];

    for (var i = 0; i < widget._lineCode; i++) {
      double x = Random().nextInt(width.toInt()).toDouble();
      double y = Random().nextInt(widget.height.toInt()).toDouble();
      if (y < 10) {
        y = 10;
      }
      if (x < 10) {
        x = 10;
      }
      Color color = widget.lineColorGenerator.getColor();
      Map dot = {"x": x, "y": y, "color": color};
      linedata.add(dot);
    }

    Map checkCodeDrawData = {
      "painterData": mList,
      "offsetX": offsetX,
      "dotData": dotData,
      "lineData": linedata
    };
    return checkCodeDrawData;
  }

  @override
  Widget build(BuildContext context) {
    double width = 0.0;

    width = getTextSize("0" * (code.length + 1),
            TextStyle(fontWeight: FontWeight.values[8], fontSize: 28))
        .width;

    Map drawData = getRandomData(width);
    return Container(
        color: widget.backgroundColor,
        width: width,
        height: widget.height,
        child: CustomPaint(
          painter: _HBCheckCodePainter(
              lineWidth: widget.lineWidth,
              drawData: drawData,
              width: width,
              height: widget.height),
        ));
  }

  Size getTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  void _refreshCode() {
    code = widget.codeGenerator.getCode();
    widget.controller._verify = (value) => code == value;

    setState(() {
      // here we are updating the widget
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refreshCode);
    _refreshCode();
  }

  @override
  void didUpdateWidget(covariant PSCodeCheckingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_refreshCode);
      widget.controller.addListener(_refreshCode);
    }
  }
}

class _HBCheckCodePainter extends CustomPainter {
  final Map drawData;
  final double width;
  final double height;
  final double lineWidth;
  _HBCheckCodePainter({
    required this.lineWidth,
    required this.drawData,
    required this.width,
    required this.height,
  });

  late Paint _paint = Paint()
    ..color = Colors.grey
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = lineWidth
    ..style = PaintingStyle.fill;
  @override
  void paint(Canvas canvas, Size size) {
    List mList = drawData["painterData"];
    canvas.clipRect(Rect.fromLTRB(0, 0, width, height));
    double offsetX = drawData["offsetX"];

    canvas.translate(offsetX, 0);

    for (var item in mList) {
      TextPainter painter = item["textPainter"];
      double x = item["x"];
      double y = item["y"];
      painter.paint(
        canvas,
        Offset(x, y),
      );
    }

    canvas.translate(-offsetX, 0);
    List dotData = drawData["dotData"];
    for (var item in dotData) {
      double x = item["x"];
      double y = item["y"];
      double dotWidth = item["dotWidth"];
      Color color = item["color"];
      _paint.color = color;
      canvas.drawOval(Rect.fromLTWH(x, y, dotWidth, dotWidth), _paint);
    }

    canvas.translate(0, 0);
    List lines = drawData["lineData"];
    for (var i = 0; i < lines.length - 1; i++) {
      final item = lines[i];
      final item1 = lines[i + 1];

      double x = item["x"];
      double y = item["y"];
      double x1 = item1["x"];
      double y1 = item1["y"];
      Color color = item["color"];
      _paint.color = color;

      canvas.drawLine(Offset(x, y), Offset(x1, y1), _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
