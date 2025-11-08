import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:event_safety_app/core/theme/app_colors.dart';
import 'package:event_safety_app/bloc/camera/camera_bloc.dart';
import 'package:event_safety_app/bloc/camera/camera_event.dart';
import 'package:event_safety_app/bloc/camera/camera_state.dart';
import 'package:event_safety_app/bloc/location/location_bloc.dart';
import 'package:event_safety_app/bloc/location/location_event.dart';
import 'package:event_safety_app/models/captured_hazard_model.dart';
import 'package:event_safety_app/widgets/bounding_box_overlay.dart';

/// Camera screen for real-time hazard detection
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isDetecting = false;
  late final LocationBloc _locationBloc;
  late final CameraBloc _cameraBloc;
  String? _lastAutoCaptureId;

  @override
  void initState() {
    super.initState();
    // Store bloc references before widget tree changes
    _locationBloc = context.read<LocationBloc>();
    _cameraBloc = context.read<CameraBloc>();
    
    // Initialize camera and start location tracking
    _cameraBloc.add(InitializeCamera());
    _locationBloc.add(StartLocationTracking());
    
    // Auto-start detection after camera initializes
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isDetecting = true);
        _cameraBloc.add(StartDetection());
      }
    });
  }

  @override
  void dispose() {
    // Stop detection and location tracking using stored references
    _cameraBloc.add(StopDetection());
    _locationBloc.add(StopLocationTracking());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<CameraBloc, CameraState>(
        listener: (context, state) {
          if (state is CameraPermissionDenied) {
            _showPermissionDialog();
          }
          if (state is CameraReady && state.capturedImagePath != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Image saved to ${state.capturedImagePath}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
          if (state is CameraReady && state.lastCapturedHazardId != null) {
            if (_lastAutoCaptureId != state.lastCapturedHazardId) {
              _lastAutoCaptureId = state.lastCapturedHazardId;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Gyroscope trigger captured a hazard clip'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          }
        },
        builder: (context, state) {
          if (state is CameraLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }

          if (state is CameraPermissionDenied) {
            return _buildPermissionDenied();
          }

          if (state is CameraError) {
            return _buildError(state.message);
          }

          if (state is CameraReady) {
            return _buildCameraView(state);
          }

          return const Center(
            child: Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraView(CameraReady state) {
    final controller = state.controller;
    final previewSize = controller.value.previewSize ?? const Size(640, 480);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        CameraPreview(controller),

        // Bounding box overlay for detections
        if (state.detections.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              return BoundingBoxOverlay(
                detections: state.detections,
                previewSize: previewSize,
                screenSize: Size(constraints.maxWidth, constraints.maxHeight),
              );
            },
          ),

        // Detection overlay border
        if (_isDetecting)
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.secondaryGreen,
                width: 3,
              ),
            ),
          ),

        // Top controls
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    _CircleButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                    ),

                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isDetecting
                            ? AppColors.secondaryGreen.withOpacity(0.9)
                            : AppColors.grey800.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isDetecting ? Colors.white : AppColors.grey400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isDetecting ? 'Detecting' : 'Paused',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Settings button
                    _CircleButton(
                      icon: Icons.collections_bookmark_outlined,
                      onPressed: () => _showCapturedHazardsSheet(state),
                    ),
                  ],
                ),

                const Spacer(),

                // Bottom controls
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Detection stats (when detecting)
                      if (_isDetecting)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                label: 'Detections',
                                value: '${state.detections.length}',
                                valueColor: state.detections.isNotEmpty 
                                    ? AppColors.severityHigh 
                                    : Colors.white,
                              ),
                              _StatItem(
                                label: 'FPS',
                                value: state.fps.toStringAsFixed(1),
                              ),
                              _StatItem(
                                label: 'Frames',
                                value: '${state.framesProcessed}',
                              ),
                              _StatItem(
                                label: 'Captures',
                                value: '${state.capturedHazards.length}',
                              ),
                            ],
                          ),
                        ),

                      // Main action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Capture image button
                          _ActionButton(
                            icon: Icons.camera_alt,
                            label: 'Capture',
                            onPressed: () {
                              context.read<CameraBloc>().add(CaptureImage());
                            },
                          ),

                          // Start/Stop detection button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDetecting = !_isDetecting;
                              });

                              if (_isDetecting) {
                                context.read<CameraBloc>().add(StartDetection());
                              } else {
                                context.read<CameraBloc>().add(StopDetection());
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: _isDetecting
                                    ? const LinearGradient(
                                        colors: [
                                          AppColors.error,
                                          AppColors.severityHigh,
                                        ],
                                      )
                                    : AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isDetecting
                                            ? AppColors.error
                                            : AppColors.primaryBlue)
                                        .withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isDetecting ? Icons.stop : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),

                          // Switch camera button
                          _ActionButton(
                            icon: Icons.flip_camera_ios,
                            label: 'Flip',
                            onPressed: () {
                              context.read<CameraBloc>().add(SwitchCamera());
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Detection boxes will be overlaid here when ML model is connected
      ],
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera Permission Required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please grant camera permission to detect road hazards',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey400,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<CameraBloc>().add(RequestCameraPermission());
              },
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCapturedHazardsSheet(CameraReady state) {
    final captures = state.capturedHazards.reversed.toList();
    if (captures.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No captured hazards yet'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final formatter = DateFormat('MMM d • HH:mm:ss');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  'Captured Hazards',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: captures.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final hazard = captures[index];
                      final file = File(hazard.imagePath);
                      final imageExists = file.existsSync();
                      final detectionLabel = hazard.detections.isNotEmpty
                          ? '${hazard.detections.first.label} ${(hazard.detections.first.confidence * 100).toStringAsFixed(0)}%'
                          : 'No detections';
                      final impactRaw = hazard.sensorSnapshot['impact_magnitude'];
                      final impact = impactRaw is num ? impactRaw.toDouble() : null;
                      final latitudeRaw = hazard.locationSnapshot?['latitude'];
                      final longitudeRaw = hazard.locationSnapshot?['longitude'];
                      final latitude = latitudeRaw is num ? latitudeRaw.toDouble() : null;
                      final longitude = longitudeRaw is num ? longitudeRaw.toDouble() : null;
                      final subtitleParts = <String>[
                        formatter.format(hazard.timestamp.toLocal()),
                        if (impact != null) 'Impact ${impact.toStringAsFixed(2)} rad/s',
                        if (latitude != null && longitude != null)
                          'Lat ${latitude.toStringAsFixed(4)}, Lng ${longitude.toStringAsFixed(4)}',
                      ];
                      final subtitle = subtitleParts.join(' • ');

                      return ListTile(
                        onTap: () {
                          Navigator.of(context).pop();
                          _showCapturedHazardPreview(hazard);
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageExists
                              ? Image.file(
                                  file,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.white12,
                                  child: const Icon(Icons.image_not_supported, color: Colors.white54),
                                ),
                        ),
                        title: Text(
                          detectionLabel,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white70),
                          onPressed: () {
                            context.read<CameraBloc>().add(DeleteCapturedHazard(hazard.id));
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCapturedHazardPreview(CapturedHazardModel hazard) {
    final file = File(hazard.imagePath);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (file.existsSync())
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(file),
                  )
                else
                  Container(
                    height: 200,
                    alignment: Alignment.center,
                    color: Colors.white12,
                    child: const Text('Image not available', style: TextStyle(color: Colors.white54)),
                  ),
                const SizedBox(height: 16),
                if (hazard.detections.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: hazard.detections.map((detection) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${detection.label} • ${(detection.confidence * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      );
                    }).toList(),
                  )
                else
                  const Text('No detections recorded', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  'Captured at ${DateFormat('MMM d, HH:mm:ss').format(hazard.timestamp.toLocal())}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                if (hazard.sensorSnapshot['impact_magnitude'] != null)
                  Text(
                    () {
                      final impact = hazard.sensorSnapshot['impact_magnitude'];
                      if (impact is num) {
                        return 'Impact magnitude: ${impact.toDouble().toStringAsFixed(2)} rad/s';
                      }
                      return 'Impact magnitude: unavailable';
                    }(),
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                if (hazard.locationSnapshot != null)
                  Text(
                    () {
                      final latRaw = hazard.locationSnapshot!['latitude'];
                      final lngRaw = hazard.locationSnapshot!['longitude'];
                      if (latRaw is! num || lngRaw is! num) {
                        return 'Location: unavailable';
                      }
                      return 'Location: ${latRaw.toDouble().toStringAsFixed(5)}, ${lngRaw.toDouble().toStringAsFixed(5)}';
                    }(),
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission'),
        content: const Text(
          'Camera access is required to detect road hazards. Please grant permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open app settings
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}

/// Circle button widget
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey800.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.grey400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
