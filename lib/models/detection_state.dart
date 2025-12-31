import 'package:ultralytics_yolo/yolo.dart';

class DetectionState {
  final List<YOLOResult> results;
  final double fps;
  final double processingTime;
  final bool isDevMode;
  final String selectedLanguage;

  const DetectionState({
    this.results = const [],
    this.fps = 0.0,
    this.processingTime = 0.0,
    this.isDevMode = true,
    this.selectedLanguage = 'tr',
  });

  DetectionState copyWith({
    List<YOLOResult>? results,
    double? fps,
    double? processingTime,
    bool? isDevMode,
    String? selectedLanguage,
  }) {
    return DetectionState(
      results: results ?? this.results,
      fps: fps ?? this.fps,
      processingTime: processingTime ?? this.processingTime,
      isDevMode: isDevMode ?? this.isDevMode,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}
