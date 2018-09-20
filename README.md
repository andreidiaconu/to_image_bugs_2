# to_image_bugs_2

This repository reproduces the bug reported in https://github.com/flutter/flutter/issues/17687

The bug: **Scene.toImage(), RepaintBoundary.toImage() or OffsetLayer.toImage() never render images**.

It used to be that images _sometimes_ did not render, but now, with the latest dev branch they _never_ render.

Flutter doctor:
```$xslt
[✓] Flutter (Channel dev, v0.9.2, on Mac OS X 10.13.6 17G65, locale en-RO)
    • Flutter version 0.9.2 at /Users/andrei/Library/Android/flutter
    • Framework revision 85b4670b2a (11 hours ago), 2018-09-19 14:59:23 -0700
    • Engine revision 2e8e96fad1
    • Dart version 2.1.0-dev.4.0.flutter-4eb879133a

[✓] Android toolchain - develop for Android devices (Android SDK 27.0.3)
    • Android SDK at /Users/andrei/Library/Android/sdk
    • Android NDK location not configured (optional; useful for native profiling support)
    • Platform android-27, build-tools 27.0.3
    • ANDROID_HOME = /Users/andrei/Library/Android/sdk
    • Java binary at: /Applications/Android Studio.app/Contents/jre/jdk/Contents/Home/bin/java
    • Java version OpenJDK Runtime Environment (build 1.8.0_152-release-1024-b01)
    • All Android licenses accepted.

[✓] iOS toolchain - develop for iOS devices (Xcode 10.0)
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • Xcode 10.0, Build version 10A255
    • ios-deploy 1.9.2
    • CocoaPods version 1.5.3

[✓] Android Studio (version 3.1)
    • Android Studio at /Applications/Android Studio.app/Contents
    • Flutter plugin version 25.0.1
    • Dart plugin version 173.4700
    • Java version OpenJDK Runtime Environment (build 1.8.0_152-release-1024-b01)

[✓] IntelliJ IDEA Community Edition (version 2018.2.4)
    • IntelliJ at /Applications/IntelliJ IDEA CE.app
    • Flutter plugin version 28.0.4
    • Dart plugin version 182.4323.44

[✓] Connected devices (1 available)
    • Andrei’s iPhone • 58ec7127e64b74785a039897b271f7367f1950b7 • ios • iOS 11.4.1

• No issues found!

```