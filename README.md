# speechToTextBtn

`speechToTextBtn` is a Flutter widget that provides speech-to-text functionality for both English and Arabic languages. It supports devices without Google Play Services by integrating with Vosk, and it uses Google Speech APIs when available.

## Features

- Supports English and Arabic speech recognition.
- Compatible with devices without Google Play Services using Vosk.
- Easy-to-use UI with customizable start and stop recording widgets.
- Outputs recognized text through a callback.

## Getting Started

### Installation

Add `speechToTextBtn` to your `pubspec.yaml`:

```yaml
dependencies:
  speechToTextBtn: ^0.0.1
```

Then, run:

```sh
flutter pub get
```

### Dependencies

Ensure you have the following dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  speech_to_text: ^5.4.0
  vosk_flutter: ^0.1.0
  package_info_plus: ^3.0.5
```

### Usage

Here’s how to use the `speechToTextBtn` widget in your Flutter application:

```dart
import 'package:flutter/material.dart';
import 'package:speechToTextBtn/speechToTextBtn.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpeechToTextExample(),
    );
  }
}

class SpeechToTextExample extends StatefulWidget {
  @override
  _SpeechToTextExampleState createState() => _SpeechToTextExampleState();
}

class _SpeechToTextExampleState extends State<SpeechToTextExample> {
  String recognizedText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech To Text Button Demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Recognized Text:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              recognizedText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: speechToTextBtn(
              isEnglish: true, // Set to false for Arabic
              startedRecordChild: Icon(Icons.mic, color: Colors.red, size: 50),
              stopedRecordChild:
                  Icon(Icons.mic_none, color: Colors.green, size: 50),
              theText: (text) {
                setState(() {
                  recognizedText = text;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Parameters

- `isEnglish`: A boolean value to set the language. `true` for English, `false` for Arabic.
- `startedRecordChild`: A widget to display when recording has started (e.g., a microphone icon).
- `stopedRecordChild`: A widget to display when recording is stopped.
- `theText`: A callback function that receives the recognized text as a string.

### Methods

- `startStopdRecord()`: Toggles the speech recognition process on or off.

## Permissions

Applications using this plugin require specific user permissions. Below are the necessary steps for configuring permissions on iOS, macOS, and Android platforms.

### iOS & macOS

Add the following keys to your `Info.plist` file, located in `<project root>/ios/Runner/Info.plist`:

- **NSSpeechRecognitionUsageDescription**: Describe why your app uses speech recognition. This key is called "Privacy - Speech Recognition Usage Description" in the visual editor.
- **NSMicrophoneUsageDescription**: Describe why your app needs access to the microphone. This key is called "Privacy - Microphone Usage Description" in the visual editor.

#### Additional Warning for macOS

When running the macOS app through VSCode, the app may crash when requesting permissions due to a known issue with Flutter. More details can be found in the [Flutter GitHub issue](https://github.com/flutter/flutter/issues/70374).

To request permissions correctly on macOS, run the app directly from Xcode.

If you are upgrading an existing macOS app to use this plugin, make sure to update your dependencies and the pods by running the following commands:

```bash
flutter clean
flutter pub get
cd macos
pod install
```

### Android

Add the required permissions to your `AndroidManifest.xml` file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

- **android.permission.RECORD_AUDIO**: Required for microphone access.
- **android.permission.INTERNET**: Required because speech recognition may use remote services.
- **android.permission.BLUETOOTH**: Required for using Bluetooth headsets when connected.
- **android.permission.BLUETOOTH_ADMIN**: Required for managing Bluetooth connections.
- **android.permission.BLUETOOTH_CONNECT**: Required for connecting Bluetooth devices (necessary for SDK 30 or later).

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
```

#### Android SDK 30 or Later

If targeting Android SDK 30 or later, add the following to your `AndroidManifest.xml` right after the permissions section to allow the app to query speech recognition services:

```xml
<queries>
    <intent>
        <action android:name="android.speech.RecognitionService" />
    </intent>
</queries>
```

### Adding Sounds for iOS (Optional)

Android automatically plays system sounds when speech listening starts or stops, but iOS does not. This plugin supports playing sounds to indicate listening status on iOS if sound files are available as assets in the application. 

To enable sounds in an application using this plugin, add the sound files to the project and reference them in the assets section of the application `pubspec.yaml`. The location and filenames of the sound files must match exactly as shown below:

```yaml
assets:
  - assets/sounds/speech_to_text_listening.m4r
  - assets/sounds/speech_to_text_cancel.m4r
  - assets/sounds/speech_to_text_stop.m4r
```

- **speech_to_text_listening.m4r**: Played when the listen method is called.
- **speech_to_text_cancel.m4r**: Played when the cancel method is called.
- **speech_to_text_stop.m4r**: Played when the stop method is called.

Ensure these sound files are very short as they delay the start/end of the speech recognizer until the sound playback is complete.

## Device Compatibility

This package is designed to work on both devices that support Google Play Services and those that do not:

- **Devices with Google Play Services**: Uses Google Speech APIs for speech recognition.
- **Devices without Google Play Services**: Uses Vosk, a lightweight, offline-capable speech recognition engine.

## Troubleshooting

- **Model Loading Error**: Ensure the internet access permissions are correctly set and that the model paths are accurate.
- **Speech Recognition Fails**: Make sure microphone permissions are granted and your device supports speech recognition.

## Contributions

Contributions are welcome! Feel free to open issues or submit pull requests.

## License




Copyright (c) 2024 [yousef mohammed]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#   s p e e c h _ t o _ t e x t _ b t n  
 