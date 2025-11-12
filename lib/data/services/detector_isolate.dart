import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:event_safety_app/core/constants/model_config.dart';
import 'package:event_safety_app/data/services/tflite_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Result emitted by the detector isolate for a processed frame.
class DetectionPacket {
  final int sequenceId;
  final DateTime timestamp;
  final int inferenceTimeMs;
  final List<Detection> detections;

  const DetectionPacket({
    required this.sequenceId,
    required this.timestamp,
    required this.inferenceTimeMs,
    required this.detections,
  });
}

/// Dedicated isolate that keeps the TensorFlow Lite interpreter off the UI thread.
class DetectorIsolate {
  DetectorIsolate._(
    this._isolate,
    this._commandPort, {
    required int maxInflight,
  })  : _maxInflight = maxInflight,
        _resultPort = ReceivePort() {
    _resultPort.listen(_handleResultMessage);
  }

  final Isolate _isolate;
  final SendPort _commandPort;
  final int _maxInflight;
  final ReceivePort _resultPort;
  final StreamController<DetectionPacket> _resultController = StreamController.broadcast();

  bool _disposed = false;
  int _sequence = 0;
  int _inflight = 0;

  Stream<DetectionPacket> get results => _resultController.stream;
  bool get hasCapacity => !_disposed && _inflight < _maxInflight;

  /// Spawn the isolate and load the model before returning.
  static Future<DetectorIsolate> spawn({int? maxInflight}) async {
    final initPort = ReceivePort();
    final rootToken = ui.RootIsolateToken.instance;
    final modelData = await rootBundle.load(ModelConfig.MODEL_PATH);
    final modelBytes = Uint8List.fromList(modelData.buffer.asUint8List());
    final isolate = await Isolate.spawn<_DetectorIsolateBootstrap>(
      _detectorIsolateEntry,
      _DetectorIsolateBootstrap(
        initPort.sendPort,
        rootToken,
        modelBytes,
      ),
      debugName: 'hazardnet-detector',
    );

    SendPort? commandPort;
    var readyReceived = false;
    await for (final message in initPort) {
      if (message is SendPort) {
        commandPort = message;
        if (readyReceived) {
          initPort.close();
          break;
        }
      } else if (message is _BootstrapError) {
        initPort.close();
        throw Exception('Detector isolate failed to initialize: ${message.message}');
      } else if (message == _DetectorIsolateBootstrap.readySignal) {
        readyReceived = true;
        if (commandPort != null) {
          initPort.close();
          break;
        }
      }
    }

    if (commandPort == null) {
      throw StateError('Detector isolate did not provide a command port.');
    }

    return DetectorIsolate._(
      isolate,
      commandPort,
      maxInflight: maxInflight ?? ModelConfig.MAX_INFLIGHT_DETECTIONS,
    );
  }

  /// Enqueue a frame for background detection. Returns `true` if accepted.
  bool enqueueFrame(
    Uint8List jpegBytes, {
    DateTime? timestamp,
  }) {
    if (_disposed) return false;
    if (_inflight >= _maxInflight) return false;

    final seq = _sequence++;
    _inflight++;
    _commandPort.send(_RunInferenceMessage(
      bytes: jpegBytes,
      sequenceId: seq,
      timestampMillis: (timestamp ?? DateTime.now()).millisecondsSinceEpoch,
      replyPort: _resultPort.sendPort,
    ).toMap());
    return true;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final responsePort = ReceivePort();
    _commandPort.send(_DisposeMessage(responsePort.sendPort).toMap());
    await responsePort.first;
    responsePort.close();
    _resultPort.close();
    await _resultController.close();
    _isolate.kill(priority: Isolate.immediate);
  }

  void _handleResultMessage(dynamic message) {
    if (_disposed) {
      return;
    }
    if (message is! Map<String, dynamic>) {
      return;
    }

    final detections = _decodeDetections(message);
    final packet = DetectionPacket(
      sequenceId: message['sequenceId'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(message['timestamp'] as int),
      inferenceTimeMs: message['inferenceTime'] as int,
      detections: detections,
    );

    _inflight = _inflight - 1;
    if (_inflight < 0) {
      _inflight = 0;
    }
    _resultController.add(packet);
  }

  static List<Detection> _decodeDetections(Map<String, dynamic> payload) {
    final raw = payload['detections'] as List<dynamic>? ?? const [];
    return raw.map((entry) {
      final map = entry as Map<String, dynamic>;
      final box = map['box'] as List<dynamic>;
      return Detection(
        label: map['label'] as String,
        confidence: (map['confidence'] as num).toDouble(),
        classIndex: map['classIndex'] as int,
        boundingBox: ui.Rect.fromLTRB(
          (box[0] as num).toDouble(),
          (box[1] as num).toDouble(),
          (box[2] as num).toDouble(),
          (box[3] as num).toDouble(),
        ),
      );
    }).toList(growable: false);
  }
}

class _DetectorIsolateBootstrap {
  const _DetectorIsolateBootstrap(this.replyPort, this.rootIsolateToken, this.modelBytes);

  final SendPort replyPort;
  final ui.RootIsolateToken? rootIsolateToken;
  final Uint8List modelBytes;

  static const readySignal = 'ready';
}

class _BootstrapError {
  final String message;
  const _BootstrapError(this.message);
}

/// Entry point for the isolate.
Future<void> _detectorIsolateEntry(_DetectorIsolateBootstrap bootstrap) async {
  try {
    if (bootstrap.rootIsolateToken != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(
        bootstrap.rootIsolateToken!,
      );
    }

    final commandPort = ReceivePort();
    bootstrap.replyPort.send(commandPort.sendPort);

    final service = TFLiteService(preloadedModelBytes: bootstrap.modelBytes);
    await service.loadModel();
    bootstrap.replyPort.send(_DetectorIsolateBootstrap.readySignal);

    await for (final message in commandPort) {
      if (message is Map<String, dynamic>) {
        final type = message['type'];
        if (type == _RunInferenceMessage.type) {
          final request = _RunInferenceMessage.fromMap(message);
          final stopwatch = Stopwatch()..start();
          final detections = await service.detectObjectsFromJpeg(
            request.bytes,
            verbose: false,
          );
          stopwatch.stop();
          request.replyPort.send({
            'sequenceId': request.sequenceId,
            'timestamp': request.timestampMillis,
            'inferenceTime': stopwatch.elapsedMilliseconds,
            'detections': detections
                .map((d) => {
                      'label': d.label,
                      'confidence': d.confidence,
                      'classIndex': d.classIndex,
                      'box': [
                        d.boundingBox.left,
                        d.boundingBox.top,
                        d.boundingBox.right,
                        d.boundingBox.bottom,
                      ],
                    })
                .toList(growable: false),
          });
        } else if (type == _DisposeMessage.type) {
          service.dispose();
          final dispose = _DisposeMessage.fromMap(message);
          dispose.replyPort.send(null);
          commandPort.close();
          break;
        }
      }
    }
  } catch (e) {
    bootstrap.replyPort.send(_BootstrapError(e.toString()));
  }
}

class _RunInferenceMessage {
  const _RunInferenceMessage({
    required this.bytes,
    required this.sequenceId,
    required this.timestampMillis,
    required this.replyPort,
  });

  final Uint8List bytes;
  final int sequenceId;
  final int timestampMillis;
  final SendPort replyPort;

  static const String type = 'run';

  Map<String, dynamic> toMap() => {
        'type': type,
        'bytes': bytes,
        'sequenceId': sequenceId,
        'timestamp': timestampMillis,
        'replyPort': replyPort,
      };

  static _RunInferenceMessage fromMap(Map<String, dynamic> map) {
    return _RunInferenceMessage(
      bytes: map['bytes'] as Uint8List,
      sequenceId: map['sequenceId'] as int,
      timestampMillis: map['timestamp'] as int,
      replyPort: map['replyPort'] as SendPort,
    );
  }
}

class _DisposeMessage {
  const _DisposeMessage(this.replyPort);

  final SendPort replyPort;

  static const String type = 'dispose';

  Map<String, dynamic> toMap() => {
        'type': type,
        'replyPort': replyPort,
      };

  static _DisposeMessage fromMap(Map<String, dynamic> map) {
    return _DisposeMessage(map['replyPort'] as SendPort);
  }
}
