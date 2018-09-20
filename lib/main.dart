import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(
    new ToImageBug()
);

/// https://github.com/flutter/flutter/issues/17687
class ToImageBug extends StatelessWidget {
  final GlobalKey repaintBoundary = new GlobalKey();

  void _saveToImage() async {
    RenderRepaintBoundary boundary = repaintBoundary.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    _showImage(pngBytes);
  }

  void _showImage(Uint8List imageBytes){
    showDialog(
        context: repaintBoundary.currentContext,
        barrierDismissible: true,
        builder: (BuildContext context2) =>
        new Center(
          child: new Image(image: new MemoryImage(imageBytes), fit: BoxFit.contain,),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text(".toImage() Bug Report Demo"),
        ),
        body: new RepaintBoundary(
          key: repaintBoundary,
          child: new Stack(
            children: <Widget>[
              new Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: new Text("This is behind of the image and gets rendered", textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, color: Colors.white),),
                  )
              ),
              new Positioned.fill(
                  child: new Image.asset("images/unsplash.jpg", fit: BoxFit.cover)
              ),
              new Positioned.fill(
                  child: new Container(decoration: new BoxDecoration(border: new Border.all(color: Colors.red, width: 5.0)),)
              ),
              new Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: new Text("This is in front of the image and gets rendered", textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, color: Colors.white),),
                )
              ),
            ],
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: _saveToImage,
          tooltip: 'Save as image',
          child: new Icon(Icons.camera),
        ),
      ),
    );
  }
}

