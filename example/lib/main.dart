import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:image_overlay/image_overlay.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String imagePath;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {

      var srcImg = await rootBundle.load("assets/src.png");
      var dstImg = await rootBundle.load("assets/dst.jpg");

      Directory dir = await getTemporaryDirectory();

      var srcImgPath = "${dir.path}/srcImg.png";
      var dstImgPath = "${dir.path}/dstImg.png";

      print(srcImgPath);
      print(dstImgPath);

      var srcFile = new File(srcImgPath);
      srcFile.writeAsBytesSync(srcImg.buffer.asUint8List());

      var dstFile = new File(dstImgPath);
      dstFile.writeAsBytesSync(dstImg.buffer.asUint8List());

      await ImageOverlay.overlayImages(srcFile.path, dstFile.path);

      imagePath = dstImgPath;
    } on PlatformException {
      imagePath = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _imagePath = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {

    print(_imagePath);
    var child;
    if (_imagePath == null || _imagePath.isEmpty)
      child = Image.asset("assets/dst.jpg");
    else
      child = Image.file(new File(_imagePath));

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: child
        ),
      ),
    );
  }
}
