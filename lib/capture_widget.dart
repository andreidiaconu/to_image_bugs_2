import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

class ToImageTestWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: ".toImage Test",
        home: SafeArea(
          child: Scaffold(
            body: Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(8.0),
                color: Colors.white,
                child: new RenderImageUsingToImage()
            ),
          ),
        )
    );
  }
}


/// Shows an image on the screen and then tries to "screenshot" it. Sometimes the image is missing from the "screenshot".
/// Displays FAIL or SUCCESS on the screen, which can then be picked up by FlutterDriver
class RenderImageUsingToImage extends StatefulWidget {
  @override
  _RenderImageUsingToImageState createState() {
    return new _RenderImageUsingToImageState();
  }
}

class _RenderImageUsingToImageState extends State<RenderImageUsingToImage> {
  final GlobalKey repaintBoundary = new GlobalKey();

  bool resultsWereSuccessful;
  Uint8List original, render;

  @override
  void initState() {
    _loadOriginalImage();
    super.initState();
  }

  /// I would normally just use an AssetImage but it turns out that
  /// Flutter Driver does not wait for that to load. I also tried waitUntilNoTransientCallbacks()
  /// but ended up waiting for the test button to show up and then wait another second.
  void _loadOriginalImage() async {
    Completer<ui.Image> imageCompleter = Completer();
    ImageStream stream = AssetImage("images/unsplash.jpg").resolve(ImageConfiguration());
    stream.addListener((image, done){
      imageCompleter.complete(image.image);
    });
    ui.Image image = await imageCompleter.future;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List read = byteData.buffer.asUint8List();
    setState(() {
      original = read;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (original == null) {
      return _getLoadingWidget(context);
    } else {
      return _getTestWidget(context);
    }
  }

  Widget _getLoadingWidget(BuildContext context){
    return Text("Loading original image");
  }

  Widget _getTestWidget(BuildContext context){
    List<Widget> testUI = new List();
    testUI.add(_getImageBeingConverted(context));
    testUI.add(_getStartTestWidget(context));
    if (resultsWereSuccessful!=null) {
      testUI.add(_getResultsWidget(context));
    }
    if (render!=null) {
      testUI.add(_getImageAfterRender(context));
    }
    return Wrap(
      direction: Axis.vertical,
      spacing: 20.0,
      children: testUI,
    );
  }

  Widget _getImageBeingConverted(BuildContext context) {
    return SizedBox(
      width: 200.0,
      height: 200.0,
      child: RepaintBoundary(
          key: repaintBoundary,
          child: Image(image: MemoryImage(original), fit: BoxFit.cover,)
      ),
    );
  }

  Widget _getImageAfterRender(BuildContext context) {
    return SizedBox(
      width: 200.0,
      height: 200.0,
      child: Image(image: MemoryImage(render), fit: BoxFit.cover,),
    );
  }

  Widget _getStartTestWidget(BuildContext context) {
    return RaisedButton(
      key: Key('startrender'),
      onPressed: _startTest,
      child: Text("Test rendering this image"),
    );
  }

  Widget _getResultsWidget(BuildContext context){
    if (resultsWereSuccessful == null){
      return Container();
    } else if (resultsWereSuccessful){
      return Text("OPAQUE", key: Key('results'));
    } else {
      return Text("TRANSPARENT", key: Key('results'));
    }
  }

  void _startTest() async {
    _removePreviousResults();
    bool rendersSuccessfully = await _renderAndGetIsOpaque();
    setState(() {
      resultsWereSuccessful = rendersSuccessfully;
    });
  }

  void _removePreviousResults() {
    setState(() {
      render = null;
      resultsWereSuccessful = null;
    });
  }

  Future<bool> _renderAndGetIsOpaque() async {
    ui.Image renderedImage = await _renderToImage();
    bool imageIsOpaque = await _isImageOpaque(renderedImage);
    _setupResultsPreview(renderedImage);
    return imageIsOpaque;
  }

  Future<ui.Image> _renderToImage() async {
    RenderRepaintBoundary boundary = repaintBoundary.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    return image;
  }

  Future<bool> _isImageOpaque(ui.Image image) async {
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    Uint32List pixels = byteData.buffer.asUint32List();
    bool hasTransparentPixels = pixels.any((pixel){
      final int alpha = (0xff000000 & pixel) >> 24;
      return alpha!=255;
    });
    return !hasTransparentPixels;
  }

  /// This has no role in the test, but helps humans see what's wrong
  void _setupResultsPreview(ui.Image image) async {
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pixels = byteData.buffer.asUint8List();
    setState(() {
      render = pixels;
    });
  }
}
