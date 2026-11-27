import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kalpam/core/chant/playlist.dart';
import 'package:kalpam/core/content/pack_repository.dart';

void main() {
  late PackRepository repo;
  setUpAll(() async => repo = await PackRepository.load((p) => File(p).readAsString()));

  test('every god with a full pack has bhajans; unverified lyrics are marked', () {
    for (final id in ['ayyappa', 'venkateswara', 'shiva', 'hanuman', 'ganapathy', 'subrahmanya', 'sai_baba']) {
      expect(repo.deities[id]!.bhajans.where(repo.bhajans.containsKey), isNotEmpty, reason: id);
    }
    expect(repo.bhajans['govinda_namalu']!.lyricsVerified, isFalse);
    expect(repo.bhajans.values.every((b) => b.audio.isPlaceholder), isTrue, reason: 'no unlicensed audio');
  });

  test('playlist auto-advances through the season set and stops at the end', () {
    final season = repo.seasons.firstWhere((s) => s.id == 'ayyappa_mandala_2026');
    final items = season.bhajanSet.map((id) => repo.bhajans[id]!).toList();
    final p = BhajanPlaylist(items);
    p.play();
    var guard = 0;
    final seen = <String>{p.current.id};
    while (!p.finished && guard++ < 10000) {
      p.advance(0.5);
      seen.add(p.current.id);
    }
    expect(seen, items.map((b) => b.id).toSet());
    expect(p.finished, isTrue);
    expect(p.playing, isFalse);
  });

  test('loop returns to the first bhajan; next and previous wrap', () {
    final items = ['govinda_namalu', 'hare_rama_maha_mantra'].map((id) => repo.bhajans[id]!).toList();
    final p = BhajanPlaylist(items, loop: true)..play();
    var guard = 0;
    while (p.index == 0 && guard++ < 10000) {
      p.advance(0.5);
    }
    while (p.index == 1 && guard++ < 10000) {
      p.advance(0.5);
    }
    expect(p.index, 0);
    expect(p.playing, isTrue);
    p.previous();
    expect(p.index, 1);
    p.next();
    expect(p.index, 0);
    p.dispose();
  });
}
