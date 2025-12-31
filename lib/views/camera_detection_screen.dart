import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/yolo_view.dart';
import 'package:ultralytics_yolo/yolo.dart';
import '../viewmodels/camera_detection_viewmodel.dart';
import '../models/language_model.dart';

class CameraDetectionScreen extends StatefulWidget {
  const CameraDetectionScreen({super.key});

  @override
  State<CameraDetectionScreen> createState() => _CameraDetectionScreenState();
}

class _CameraDetectionScreenState extends State<CameraDetectionScreen> {
  late final CameraDetectionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CameraDetectionViewModel();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RepaintBoundary(
          child: Stack(
            children: [
              Positioned.fill(
                child: YOLOView(
                  modelPath: 'best_float32',
                  task: YOLOTask.detect,
                  controller: _viewModel.yoloController,
                  showOverlays: _viewModel.state.isDevMode,
                  onResult: _viewModel.onYOLOResult,
                  onPerformanceMetrics: _viewModel.onPerformanceMetrics,
                ),
              ),

              if (_viewModel.state.isDevMode) _buildPerformanceOverlay(),

              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: _buildControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceOverlay() {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'prt: ${_viewModel.state.processingTime.toStringAsFixed(2)}s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'fps: ${_viewModel.state.fps.toStringAsFixed(1)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'obj: ${_viewModel.state.results.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildControl(
          icon: Icons.build,
          onTap: _viewModel.toggleDevMode,
          isActive: _viewModel.state.isDevMode,
        ),
        Row(
          children: LanguageModel.availableLanguages.map((lang) {
            final isSelected = _viewModel.state.selectedLanguage == lang;
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _buildControl(
                label: lang.toUpperCase(),
                onTap: () => _viewModel.changeLanguage(lang),
                isActive: isSelected,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildControl({
    IconData? icon,
    String? label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: label != null ? 16 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 20)
            : Text(
                label!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
      ),
    );
  }
}
