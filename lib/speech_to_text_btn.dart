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

class speechToTextBtn extends StatefulWidget {
  speechToTextBtn(
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
  State<speechToTextBtn> createState() => _speechToTextBtnState();
}

class _speechToTextBtnState extends State<speechToTextBtn> {
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
          print("object");
        }
      }
    }
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

  void startStopdRecordNotSuportedGoogle() async {
    if (recognitionStarted) {
      await speechService?.stop();

      subscription?.cancel();
    } else {
      await speechService!.start();
      setState(() {
        fullText = "";
        subscription = speechService?.onResult().listen(
              (Value) => widget.theText(ResultNotSuportedGoogle(Value)),
            );
      });
    }
  }

  void startStopRecordSuportedGoogle() async {
    if (recognitionStarted) {
      // Stop the speech recognition
      await speechToText.stop();
      // Update the recognition state
      setState(() {});
    } else {
      await initializeSpeech();

      // Check if speech is enabled before starting
      if (speechEnabled) {
        startListening();
      }
    }
  }

  void startListening() async {
    // Start listening with continuous operation settings
    await speechToText.listen(
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
      ),
      onResult: (result) {
        // Process the result and update the text
        widget.theText(ResultSuportedGoogle(result));
        fullText += result.recognizedWords; // Append to the full text
      },
      listenFor: Duration(hours: 5), // Set a very long duration for listening
      pauseFor: Duration(
          milliseconds: 500), // Minimal pause time to keep active listening
      localeId: widget.isEnglish ? "en-US" : "ar-SA",
    );

    setState(() {});
  }

  Future<void> initializeSpeech() async {
    // Initialize speech-to-text with status and error handlers
    speechEnabled = await speechToText.initialize(
      finalTimeout: Duration(hours: 5), // Long timeout for stability
      onStatus: (status) {
        print('onStatus: $status');
        // Only log status updates, do not restart or stop listening
      },
      onError: (errorNotification) {
        print('onError: $errorNotification');
        // Handle errors gracefully without restarting initialization
      },
    );

    if (!speechEnabled) {
      print('Speech recognition not available on this device');
      // Provide user feedback if initialization fails
    }

    setState(() {});
  }

  String ResultNotSuportedGoogle(
    String Result,
  ) {
    var str = (jsonDecode(Result));

    var newStr = str.text ?? "";
    if (newStr.isNotEmpty) {
      setState(() {
        fullText += " " + newStr;
      });
    }
    return fullText;
  }

  String ResultSuportedGoogle(SpeechRecognitionResult Result) {
    setState(() {
      fullText = Result.recognizedWords;
    });
    return fullText;
  }
}

Future<bool> isAndroidGoogleNotSupported() async {
  // Check if the platform is Android
  if (!Platform.isAndroid) return false;

  try {
    await PackageInfo.fromPlatform();

    bool googleServicesSupported = true;

    return !googleServicesSupported;
  } on PlatformException {
    return true;
  }
}
