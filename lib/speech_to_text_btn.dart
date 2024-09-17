library speechToTextBtn;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SpeechToTextBtn extends StatefulWidget {
  const SpeechToTextBtn(
      {required this.startedRecordChild,
      required this.stopedRecordChild,
      required this.theText,
      required this.isEnglish,
      super.key});

  ///The Language Arabic Or English If it's Arabic [isEnglish]=false else if it's English [isEnglish]=true
  final bool isEnglish;

  /// You Need String In ValueChanged Function YourString=Valu in [theText] ValueChanged
  final ValueChanged<String> theText;

  /// That Is The Wedgit In The Mic Stop Record
  final Widget startedRecordChild;

  /// That Is The Wedgit In The Mic Start Record
  final Widget stopedRecordChild;

  @override
  State<SpeechToTextBtn> createState() => _SpeechToTextBtnState();
}

class _SpeechToTextBtnState extends State<SpeechToTextBtn> {
  final SpeechToText speechToText = SpeechToText();
  final vosk = VoskFlutterPlugin.instance();
  final modelLoader = ModelLoader();
  final sampleRate = 16000;
  Model? model;

  /// If Do You Want The Btn For Mobils Not Suported By Google That Is Availabale
  Future<bool> isAndroidGoogleNotSupportedBool = isAndroidGoogleNotSupported();
  bool speechEnabled = false;

  Recognizer? recognizer;
  SpeechService? speechService;
  bool recognitionStarted = false;

  StreamSubscription? subscription;
  var loadData = true;
  String fullText = "";
  @override
  void initState() {
    recognizer?.dispose();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: startStopdRecord,
        child: recognitionStarted
            ? widget.startedRecordChild
            : widget.stopedRecordChild);
  }
/// Its for android not supported by google using vosk package 
  void loadModel() async {
    if (await modelLoader.isModelAlreadyLoaded(widget.isEnglish
        ? "vosk-model-small-en-us-0.15"
        : "vosk-model-ar-mgb2-0.4")) {
      try {
        setState(() async {
          var modelCreate = vosk.createModel(await modelLoader.modelPath(
              widget.isEnglish
                  ? "vosk-model-small-en-us-0.15"
                  : "vosk-model-ar-mgb2-0.4"));

          model = await modelCreate;

          var createRecognizer = vosk.createRecognizer(
            model: model!,
            sampleRate: sampleRate,
          );

          recognizer = await createRecognizer;
        });

        initspeechService();
      } catch (e) {
        print(e);
      }
    } else {
      setState(() async {
        loadData = true;

        var loadModel = modelLoader
            .loadModelsList()
            .then((modelsList) => modelsList.firstWhere((model) =>
                model.name ==
                (widget.isEnglish
                    ? "vosk-model-small-en-us-0.15"
                    : "vosk-model-ar-mgb2-0.4")))
            .then((modelDescription) =>
                modelLoader.loadFromNetwork(modelDescription.url));

        var modelCreate = vosk.createModel(await loadModel);

        model = await modelCreate;

        loadData = false;

        var createRecognizer =
            vosk.createRecognizer(model: model!, sampleRate: sampleRate);

        recognizer = await createRecognizer;
      });

      initspeechService();
    }
  }

  void initspeechService() async {
    if (speechService == null) {
      try {
        speechService = await vosk.initSpeechService(recognizer!);
      } catch (e) {
        if (e.toString() ==
            "PlatformException(INITIALIZE_FAIL, SpeechService instance already exist., null, null)") {
          setState(() {
            speechService = vosk.getSpeechService();
          });
        } else {
          print(e);

        }
      }
    }
  }
 void startStopdRecordNotSuportedGoogle() async {
    if (recognitionStarted) {
      await speechService?.stop();

      subscription?.cancel();
    } else {
      await speechService!.start();
      setState(() {
        fullText = "";
        subscription = speechService?.onResult().listen(
              (value) => widget.theText(resultNotSuportedGoogle(value)),
            );
      });
    }
  }
    String resultNotSuportedGoogle(
    String result,
  ) {
    var str = (jsonDecode(result));

    var newStr = str.text ?? "";
    if (newStr.isNotEmpty) {
      setState(() {
        fullText +=" " + newStr ;
      });
    }
    return fullText;
  }

  void startStopdRecord() async {
    await isAndroidGoogleNotSupportedBool ? loadModel() : null;
    await isAndroidGoogleNotSupportedBool
        ? startStopdRecordNotSuportedGoogle()
        : startStopRecordSuportedGoogle();
    setState(() {
      recognitionStarted = !recognitionStarted;
    });
  }

 /// Its for android supported by google using speech_to_text package

  void startStopRecordSuportedGoogle() async {
    if (recognitionStarted) {
      await speechToText.stop();
      recognitionStarted = false;
      setState(() {});
    } else {
      await initializeSpeech();

      if (speechEnabled) {
        await speechToText.listen(
          onResult: (result) {
            widget.theText(ResultSuportedGoogle(result));
            fullText += result.recognizedWords; // Update the full text
          },
          listenOptions:
              SpeechListenOptions(cancelOnError: false, partialResults: true),
          localeId: widget.isEnglish ? "en-US" : "ar-SA",
        );

        recognitionStarted = true;
        setState(() {});
      }
    }
  }

  Future<void> initializeSpeech() async {
    speechEnabled = await speechToText.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          // Automatically restart if not listening
          if (recognitionStarted) startStopRecordSuportedGoogle();
        }
      },
      onError: (errorNotification) {
        // Restart on non-permanent errors
        if (!errorNotification.permanent && recognitionStarted) {
          startStopRecordSuportedGoogle();
        }
      },
    );

    if (!speechEnabled) {
      print('Speech recognition not available on this device');
      // Consider providing feedback to the user here
    }

    setState(() {});
  }


  String ResultSuportedGoogle(SpeechRecognitionResult Result) {
    setState(() {
      fullText = Result.recognizedWords;
    });
    return fullText;
  }
}
  // Check if the platform is Android
Future<bool> isAndroidGoogleNotSupported() async {

  if (!Platform.isAndroid) return false;

  try {
    await PackageInfo.fromPlatform();

    bool googleServicesSupported = true;

    return !googleServicesSupported;
  } on PlatformException {
    return true;
  }
}
