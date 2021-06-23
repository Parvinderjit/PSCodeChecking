import 'package:flutter/material.dart';
import 'package:ps_code_checking/ps_code_checking.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Checking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Code Checking Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = CodeCheckController();
  final textConroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            TextButton(
                onPressed: () {
                  controller.refresh();
                },
                child: Text("Refresh")),
            PSCodeCheckingWidget(
              lineWidth: 2,
              maxFontSize: 32,
              dotMaxSize: 10,
              backgroundColor: Colors.blue,
              lineColorGenerator:
                  SingleColorGenerator(Colors.white.withOpacity(0.8)),
              textColorGenerator: SingleColorGenerator(Colors.white),
              dotColorGenerator:
                  SingleColorGenerator(Colors.white.withOpacity(0.9)),
              controller: controller,
              dotCount: 100,
              codeGenerator: SizedCodeGenerator(size: 7),
            ),
            TextField(
              controller: textConroller,
            ),
            TextButton(
                onPressed: () {
                  print(controller.verify(textConroller.value.text));
                },
                child: Text("Verify")),
          ],
        ),
      ),
    );
  }
}
