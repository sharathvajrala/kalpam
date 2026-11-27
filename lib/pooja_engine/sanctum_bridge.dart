/// Flutter <-> 3D-engine message protocol for the Sannidhanam.
///
/// The Unity module (Phase A.2, see ARCHITECTURE.md) and the Flutter
/// placeholder sanctum both implement this. Messages carry a session id and
/// sequence number so v1.1 live group pooja can relay them between phones.
library;

import 'dart:async';
import 'dart:convert';

import '../core/content/models.dart';

class SanctumCommand {
  const SanctumCommand(this.type, this.payload);
  final String type;
  final Map<String, Object?> payload;

  factory SanctumCommand.loadSanctum(String sceneId, {required String alankaram, String? season}) =>
      SanctumCommand('loadSanctum', {'sceneId': sceneId, 'alankaram': alankaram, 'season': season});
  factory SanctumCommand.beginStep(String upachara,
          {required PoojaAction action, int target = 1, String? option}) =>
      SanctumCommand('beginStep', {'upachara': upachara, 'action': action.name, 'target': target, 'option': option});
  factory SanctumCommand.autoPerform(String upachara, {String? option}) =>
      SanctumCommand('autoPerform', {'upachara': upachara, 'option': option});
  factory SanctumCommand.peakEvent(String id) => SanctumCommand('peakEvent', {'id': id});
  factory SanctumCommand.setQuality(int tier) => SanctumCommand('setQuality', {'tier': tier});

  String encode(String sessionId, int seq) =>
      jsonEncode({'v': 1, 'session': sessionId, 'seq': seq, 'type': type, ...payload});
}

enum SanctumEventType { ready, actionDone, progress, fps, error }

class SanctumEvent {
  const SanctumEvent(this.type, {this.upachara, this.value});
  final SanctumEventType type;
  final String? upachara;
  final double? value;

  static SanctumEvent decode(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return SanctumEvent(
      SanctumEventType.values.byName(j['type'] as String),
      upachara: j['upachara'] as String?,
      value: (j['value'] as num?)?.toDouble(),
    );
  }
}

/// Transport-agnostic bridge. The Unity implementation forwards [send] to
/// `UnityWidgetController.postMessage` and feeds [events] from
/// `onUnityMessage`; the placeholder renderer pushes events directly.
class SanctumBridge {
  SanctumBridge({this.sessionId = 'local'});

  final String sessionId;
  int _seq = 0;
  final _events = StreamController<SanctumEvent>.broadcast(sync: true);
  final _commands = StreamController<SanctumCommand>.broadcast(sync: true);
  final List<String> sentLog = [];

  Stream<SanctumEvent> get events => _events.stream;
  Stream<SanctumCommand> get commands => _commands.stream;

  void send(SanctumCommand c) {
    sentLog.add(c.encode(sessionId, _seq++));
    _commands.add(c);
  }

  /// Called by the renderer.
  void emit(SanctumEvent e) => _events.add(e);

  void dispose() {
    _events.close();
    _commands.close();
  }
}
