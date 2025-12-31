import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/widgets/yolo_controller.dart';
import 'package:ultralytics_yolo/yolo.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/detection_state.dart';

class CameraDetectionViewModel extends ChangeNotifier {
  final YOLOViewController yoloController;
  final AudioPlayer audioPlayer;

  DetectionState _state = const DetectionState();
  DetectionState get state => _state;

  DateTime? _lastAudioTime;
  String? _lastSpokenClass;
  static const Duration _audioDebounceTime = Duration(seconds: 3);

  CameraDetectionViewModel({
    YOLOViewController? yoloController,
    AudioPlayer? audioPlayer,
  }) : yoloController = yoloController ?? YOLOViewController(),
       audioPlayer = audioPlayer ?? AudioPlayer();

  void onYOLOResult(List<YOLOResult> results) {
    _state = _state.copyWith(results: results);
    notifyListeners();

    if (results.isNotEmpty) {
      final topResult = results.reduce(
        (curr, next) => (curr.confidence) > (next.confidence) ? curr : next,
      );

      final className = topResult.className;
      if (className.isNotEmpty) {
        _playAudio(className);
      }
    }
  }

  void onPerformanceMetrics(dynamic metrics) {
    _state = _state.copyWith(
      fps: metrics.fps,
      processingTime: metrics.processingTimeMs / 1000,
    );
    notifyListeners();
  }

  void toggleDevMode() {
    _state = _state.copyWith(isDevMode: !_state.isDevMode);
    yoloController.setShowOverlays(_state.isDevMode);
    notifyListeners();
  }

  void changeLanguage(String newLanguage) {
    if (newLanguage != _state.selectedLanguage) {
      _state = _state.copyWith(selectedLanguage: newLanguage);
      _lastSpokenClass = null;
      _lastAudioTime = null;
      notifyListeners();
    }
  }

  Future<void> _playAudio(String className) async {
    final now = DateTime.now();
    if (_lastAudioTime != null &&
        now.difference(_lastAudioTime!) < _audioDebounceTime &&
        _lastSpokenClass == className) {
      return;
    }

    final normalizedName = className.toLowerCase().replaceAll(' ', '_');
    final source = AssetSource(
      'audio/${_state.selectedLanguage}/$normalizedName.mp3',
    );
    await audioPlayer.stop();
    await audioPlayer.play(source);
    _lastAudioTime = now;
    _lastSpokenClass = className;
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
