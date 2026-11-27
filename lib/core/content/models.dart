/// Content-pack models. Schemas documented in docs/SCHEMAS.md.
library;

import 'localized.dart';

typedef Json = Map<String, dynamic>;

List<T> _list<T>(Object? v, T Function(Json) f) =>
    (v as List? ?? const []).map((e) => f((e as Map).cast<String, dynamic>())).toList();
List<String> _strings(Object? v) => (v as List? ?? const []).map((e) => e.toString()).toList();
List<LocalizedText> _texts(Object? v) =>
    (v as List? ?? const []).map(LocalizedText.fromJson).toList();

void _checkSchema(Json j, String expected) {
  final s = j['schema'] as String?;
  if (s == null || !s.startsWith('$expected/')) {
    throw FormatException('Expected schema $expected, got $s');
  }
  final major = int.tryParse(s.split('/').last) ?? 0;
  if (major != 1) throw FormatException('Unsupported $expected version $major');
}

/// Resolves to a bundled asset, a downloaded pack file, or a placeholder.
class MediaRef {
  const MediaRef(this.uri);
  final String uri;
  static const none = MediaRef('placeholder://none');

  bool get isPlaceholder => uri.startsWith('placeholder://');
  bool get isAsset => uri.startsWith('asset://');
  String get assetPath => uri.replaceFirst('asset://', 'assets/');
  @override
  String toString() => uri;
}

MediaRef _media(Object? v) => v == null ? MediaRef.none : MediaRef(v.toString());

// ---------------------------------------------------------------- Pooja

enum PoojaAction { tap, dragCircle, shake, blow, pour, shower, swipeDown, walkAround, archana, none }

PoojaAction _action(String? s) => switch (s) {
      'tap' => PoojaAction.tap,
      'drag_circle' => PoojaAction.dragCircle,
      'shake' => PoojaAction.shake,
      'blow' => PoojaAction.blow,
      'pour' => PoojaAction.pour,
      'shower' => PoojaAction.shower,
      'swipe_down' => PoojaAction.swipeDown,
      'walk_around' => PoojaAction.walkAround,
      'archana' => PoojaAction.archana,
      _ => PoojaAction.none,
    };

class PoojaStep {
  PoojaStep({
    required this.upachara,
    required this.title,
    required this.instruction,
    required this.mantra,
    required this.voice,
    required this.action,
    required this.target,
    required this.autoDurationSec,
    this.options = const [],
    this.names = const [],
  });
  final String upachara;
  final LocalizedText title, instruction, mantra;
  final MediaRef voice;
  final PoojaAction action;

  /// Repetitions needed to complete (3 aarti circles, 3 pradakshinas…).
  final int target;
  final int autoDurationSec;

  /// e.g. abhishekam liquids
  final List<String> options;

  /// Archana: one name per flower (Ashtottaram 108 / Shodasha 16).
  final List<TextLine> names;

  factory PoojaStep.fromJson(Json j) => PoojaStep(
        upachara: j['upachara'] as String,
        title: LocalizedText.fromJson(j['title']),
        instruction: LocalizedText.fromJson(j['instruction'] ?? j['title']),
        mantra: LocalizedText.fromJson(j['mantra'] ?? ''),
        voice: _media(j['voice']),
        action: _action(j['action'] as String?),
        target: (j['target'] as num?)?.toInt() ?? 1,
        autoDurationSec: (j['autoDurationSec'] as num?)?.toInt() ?? 8,
        options: _strings(j['options']),
        names: _list(j['names'], TextLine.fromJson),
      );

  /// Builds an archana step from a list of names (target = names.length).
  factory PoojaStep.archana({required LocalizedText title, required LocalizedText instruction, required List<TextLine> names}) =>
      PoojaStep(
        upachara: 'archana',
        title: title,
        instruction: instruction,
        mantra: const LocalizedText({'en': ''}),
        voice: MediaRef.none,
        action: PoojaAction.archana,
        target: names.length,
        autoDurationSec: (names.length * 2.5).round(),
        names: names,
      );
}

class PoojaVidhanam {
  PoojaVidhanam({required this.id, required this.name, required this.lengthMin, required this.steps});
  final String id;
  final LocalizedText name;
  final int lengthMin;
  final List<PoojaStep> steps;
  factory PoojaVidhanam.fromJson(Json j) => PoojaVidhanam(
        id: j['id'] as String,
        name: LocalizedText.fromJson(j['name']),
        lengthMin: (j['lengthMin'] as num).toInt(),
        steps: _list(j['steps'], PoojaStep.fromJson),
      );

  /// Copy with an archana inserted before the aarti (or before the closing).
  PoojaVidhanam withArchana(PoojaStep archana) {
    var at = steps.indexWhere((s) => s.upachara == 'aarti');
    if (at < 0) at = steps.indexWhere((s) => s.upachara == 'closing');
    if (at < 0) at = steps.length;
    return PoojaVidhanam(id: '$id+archana', name: name, lengthMin: lengthMin + (archana.autoDurationSec / 60).ceil(),
        steps: [...steps.take(at), archana, ...steps.skip(at)]);
  }
}

// ---------------------------------------------------------------- Deity

class Alankaram {
  Alankaram(this.id, this.name, this.season);
  final String id;
  final LocalizedText name;
  final String? season;
}

class PeakEvent {
  PeakEvent({required this.id, required this.name, required this.startsAt, required this.durationMin});
  final String id;
  final LocalizedText name;
  final DateTime startsAt;
  final int durationMin;
}

class DeityPack {
  DeityPack({
    required this.id,
    required this.version,
    required this.name,
    required this.epithet,
    required this.greeting,
    required this.weekdays,
    required this.primaryColor,
    required this.accentColor,
    required this.icon,
    required this.sceneId,
    required this.alankarams,
    required this.closingType,
    required this.closingAudio,
    required this.closingName,
    required this.abhishekamLiquids,
    required this.peakEvents,
    required this.poojas,
    required this.chantings,
    required this.stotras,
    required this.bhajans,
    required this.idolGlyph,
    this.rituals = const DeityRituals(),
    this.isLight = false,
  });

  final String id;
  final int version;
  final LocalizedText name, epithet, greeting, closingName;

  /// Nitya Archana data (DAILY RITUALS).
  final DeityRituals rituals;

  /// Light packs (Sai Baba, Surya) serve Day God mode only: no sanctum yet.
  final bool isLight;
  final List<int> weekdays;
  final int primaryColor, accentColor;
  final MediaRef icon;
  final String sceneId;
  final List<Alankaram> alankarams;
  final String closingType;
  final MediaRef closingAudio;
  final List<String> abhishekamLiquids;
  final List<PeakEvent> peakEvents;
  final List<PoojaVidhanam> poojas;
  final List<String> chantings, stotras, bhajans;

  /// Single glyph used by the placeholder sanctum until 3D idols land.
  final String idolGlyph;

  PoojaVidhanam? pooja(String id) {
    for (final p in poojas) {
      if (p.id == id) return p;
    }
    return null;
  }

  static int _hex(Object? v, int fallback) =>
      v == null ? fallback : int.parse((v as String).replaceFirst('#', 'FF'), radix: 16);

  factory DeityPack.fromJson(Json j) {
    _checkSchema(j, 'kalpam.deity');
    final s = (j['sanctum'] as Map?)?.cast<String, dynamic>() ?? {};
    final closing = (s['closing'] as Map?)?.cast<String, dynamic>() ?? {};
    final colors = (j['colors'] as Map?)?.cast<String, dynamic>() ?? {};
    return DeityPack(
      id: j['id'] as String,
      version: (j['version'] as num).toInt(),
      name: LocalizedText.fromJson(j['name']),
      epithet: LocalizedText.fromJson(j['epithet'] ?? j['name']),
      greeting: LocalizedText.fromJson(j['greeting'] ?? j['name']),
      weekdays: (j['weekdays'] as List? ?? []).map((e) => (e as num).toInt()).toList(),
      primaryColor: _hex(colors['primary'], 0xFF5E1224),
      accentColor: _hex(colors['accent'], 0xFFC9A227),
      icon: _media((j['art'] as Map?)?['icon']),
      sceneId: s['sceneId'] as String? ?? j['id'] as String,
      alankarams: _list(s['alankarams'], (a) => Alankaram(a['id'] as String,
          LocalizedText.fromJson(a['name']), a['season'] as String?)),
      closingType: closing['type'] as String? ?? 'aarti',
      closingAudio: _media(closing['audio']),
      closingName: LocalizedText.fromJson(closing['name'] ?? 'Mangala Aarti'),
      abhishekamLiquids: _strings(s['abhishekamLiquids']),
      peakEvents: _list(s['peakEvents'], (p) => PeakEvent(
          id: p['id'] as String,
          name: LocalizedText.fromJson(p['name']),
          startsAt: DateTime.parse(p['startsAt'] as String),
          durationMin: (p['durationMin'] as num?)?.toInt() ?? 30)),
      poojas: _list(j['poojas'], PoojaVidhanam.fromJson),
      chantings: _strings(j['chantings']),
      stotras: _strings(j['stotras']),
      bhajans: _strings(j['bhajans']),
      idolGlyph: j['idolGlyph'] as String? ?? 'ॐ',
      rituals: DeityRituals.fromJson((j['rituals'] as Map?)?.cast<String, dynamic>() ?? const {}),
      isLight: j['status'] == 'light',
    );
  }
}

/// Per-god daily ritual data. Everything is optional; missing pieces are
/// simply skipped by the ritual planner.
class DeityRituals {
  const DeityRituals({
    this.purpose,
    this.suprabhatam,
    this.morningChant,
    this.morningOffering,
    this.archana,
    this.shortCount = 16,
    this.eveningChant,
  });

  /// Spoken in the Sankalpam ("...for the grace of ...").
  final LocalizedText? purpose;
  final String? suprabhatam, morningChant, morningOffering, archana, eveningChant;

  /// Names in the short (Shodasha) archana; the full form uses every name.
  final int shortCount;

  factory DeityRituals.fromJson(Json j) => DeityRituals(
        purpose: j['purpose'] == null ? null : LocalizedText.fromJson(j['purpose']),
        suprabhatam: j['suprabhatam'] as String?,
        morningChant: j['morningChant'] as String?,
        morningOffering: j['morningOffering'] as String?,
        archana: j['archana'] as String?,
        shortCount: (j['shortCount'] as num?)?.toInt() ?? 16,
        eveningChant: j['eveningChant'] as String?,
      );
}

// ---------------------------------------------------------------- Vratam

enum VratamKind { singleDay, mala, recurring }

class ChecklistItem {
  ChecklistItem(this.id, this.text, {this.detail, this.optional = false});
  final String id;
  final LocalizedText text;
  final LocalizedText? detail;
  final bool optional;
  factory ChecklistItem.fromJson(Json j) => ChecklistItem(
        j['id'] as String,
        LocalizedText.fromJson(j['name'] ?? j['text']),
        detail: j['qty'] != null || j['detail'] != null
            ? LocalizedText.fromJson(j['qty'] ?? j['detail'])
            : null,
        optional: j['optional'] as bool? ?? false,
      );
}

class KathaChapter {
  KathaChapter({required this.chapter, required this.title, required this.text, required this.audio, this.day});
  final int chapter;
  final LocalizedText title, text;
  final MediaRef audio;
  final int? day;
}

class Recurrence {
  Recurrence({required this.rule, this.tithis = const {}, this.weekday});
  final String rule; // tithi | weekday | weekday_tithi | fixed
  final Set<int> tithis;
  final int? weekday;
}

class VratamPack {
  VratamPack({
    required this.id,
    required this.version,
    required this.deityId,
    required this.name,
    required this.summary,
    required this.kind,
    required this.defaultDays,
    required this.minDays,
    required this.maxDays,
    required this.morningChecklist,
    required this.eveningChecklist,
    required this.rules,
    required this.samagri,
    required this.fasting,
    required this.sankalpaPurpose,
    required this.vidhanamPoojaId,
    required this.katha,
    required this.udyapanam,
    required this.recurrence,
    required this.extras,
  });

  final String id;
  final int version;
  final String deityId;
  final LocalizedText name, summary, sankalpaPurpose;
  final VratamKind kind;
  final int defaultDays, minDays, maxDays;
  final List<ChecklistItem> morningChecklist, eveningChecklist, samagri;
  final List<LocalizedText> rules, fasting;
  final String vidhanamPoojaId;
  final List<KathaChapter> katha;
  final List<PoojaStep> udyapanam;
  final Recurrence? recurrence;
  final Json extras;

  /// Katha chapter for mala day [day] (1-based), cycling if fewer chapters.
  KathaChapter? kathaForDay(int day) {
    if (katha.isEmpty) return null;
    for (final k in katha) {
      if (k.day == day) return k;
    }
    return katha[(day - 1) % katha.length];
  }

  List<ChecklistItem> extraChecklist(String key) => _list(extras[key], ChecklistItem.fromJson);
  LocalizedText? extraText(String key) =>
      extras[key] == null ? null : LocalizedText.fromJson(extras[key]);

  factory VratamPack.fromJson(Json j) {
    _checkSchema(j, 'kalpam.vratam');
    final mala = (j['mala'] as Map?)?.cast<String, dynamic>() ?? {};
    final rec = (j['recurrence'] as Map?)?.cast<String, dynamic>();
    final udy = (j['udyapanam'] as Map?)?.cast<String, dynamic>() ?? {};
    return VratamPack(
      id: j['id'] as String,
      version: (j['version'] as num).toInt(),
      deityId: j['deityId'] as String,
      name: LocalizedText.fromJson(j['name']),
      summary: LocalizedText.fromJson(j['summary'] ?? ''),
      kind: switch (j['kind']) {
        'mala' => VratamKind.mala,
        'recurring' => VratamKind.recurring,
        _ => VratamKind.singleDay,
      },
      defaultDays: (mala['defaultDays'] as num?)?.toInt() ?? 1,
      minDays: (mala['minDays'] as num?)?.toInt() ?? 1,
      maxDays: (mala['maxDays'] as num?)?.toInt() ?? 1,
      morningChecklist: _list(mala['morningChecklist'], ChecklistItem.fromJson),
      eveningChecklist: _list(mala['eveningChecklist'], ChecklistItem.fromJson),
      rules: _texts(mala['rules']),
      samagri: _list(j['samagri'], ChecklistItem.fromJson),
      fasting: _texts(j['fasting']),
      sankalpaPurpose: LocalizedText.fromJson((j['sankalpam'] as Map?)?['purpose'] ?? ''),
      vidhanamPoojaId: j['vidhanamPoojaId'] as String? ?? 'shodasha',
      katha: _list(j['katha'], (k) => KathaChapter(
            chapter: (k['chapter'] as num).toInt(),
            title: LocalizedText.fromJson(k['title']),
            text: LocalizedText.fromJson(k['text']),
            audio: _media(k['audio']),
            day: (k['day'] as num?)?.toInt(),
          )),
      udyapanam: _list(udy['steps'], PoojaStep.fromJson),
      recurrence: rec == null
          ? null
          : Recurrence(
              rule: rec['rule'] as String,
              tithis: (rec['tithis'] as List? ?? []).map((e) => (e as num).toInt()).toSet(),
              weekday: (rec['weekday'] as num?)?.toInt(),
            ),
      extras: (j['extras'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }
}

// ---------------------------------------------------------------- Stotra / Bhajan

class TextLine {
  TextLine({required this.id, required this.script, required this.translit, required this.meaning, this.tSung, this.tLearn});
  final String id;

  /// Sanskrit/Telugu in Telugu script.
  final String script;
  final String translit;
  final LocalizedText meaning;
  final (int, int)? tSung, tLearn;

  static (int, int)? _cue(Object? v) {
    if (v is List && v.length == 2) return ((v[0] as num).toInt(), (v[1] as num).toInt());
    return null;
  }

  factory TextLine.fromJson(Json j) => TextLine(
        id: j['id']?.toString() ?? '',
        script: (j['te'] ?? j['sa_te'] ?? j['text'] ?? '') as String,
        translit: (j['translit'] ?? '') as String,
        meaning: LocalizedText.fromJson(j['meaning'] ?? ''),
        tSung: _cue(j['tSung'] ?? j['t']),
        tLearn: _cue(j['tLearn']),
      );
}

class StotraItem {
  StotraItem({
    required this.id,
    required this.version,
    required this.title,
    required this.deityIds,
    required this.category,
    required this.parayanamDays,
    required this.source,
    required this.sung,
    required this.learn,
    required this.lines,
    required this.complete,
  });
  final String id;
  final int version;
  final LocalizedText title;
  final List<String> deityIds;
  final String category;
  final List<int> parayanamDays;
  final String source;
  final MediaRef sung, learn;
  final List<TextLine> lines;

  /// false while only a verified sample is bundled (ASSETS_TODO.md).
  final bool complete;

  factory StotraItem.fromJson(Json j) {
    _checkSchema(j, 'kalpam.stotra');
    final audio = (j['audio'] as Map?)?.cast<String, dynamic>() ?? {};
    return StotraItem(
      id: j['id'] as String,
      version: (j['version'] as num).toInt(),
      title: LocalizedText.fromJson(j['title']),
      deityIds: _strings(j['deityIds']),
      category: j['category'] as String? ?? 'stotram',
      parayanamDays: (j['parayanamDays'] as List? ?? []).map((e) => (e as num).toInt()).toList(),
      source: j['source'] as String? ?? '',
      sung: _media(audio['sung']),
      learn: _media(audio['learn']),
      lines: _list(j['lines'], TextLine.fromJson),
      complete: j['complete'] as bool? ?? false,
    );
  }
}

class BhajanItem {
  BhajanItem({
    required this.id,
    required this.version,
    required this.title,
    required this.deityIds,
    required this.language,
    required this.audio,
    required this.durationSec,
    required this.lyrics,
    required this.seasons,
    required this.licenseHolder,
  });
  final String id;
  final int version;
  final LocalizedText title;
  final List<String> deityIds;
  final String language;
  final MediaRef audio;
  final int durationSec;
  final List<TextLine> lyrics;
  final List<String> seasons;
  final String? licenseHolder;

  factory BhajanItem.fromJson(Json j) {
    _checkSchema(j, 'kalpam.bhajan');
    final audio = _media(j['audio']);
    final lic = (j['license'] as Map?)?.cast<String, dynamic>();
    if (!audio.isPlaceholder && lic == null) {
      throw FormatException('Bhajan ${j['id']} has real audio but no license block');
    }
    return BhajanItem(
      id: j['id'] as String,
      version: (j['version'] as num).toInt(),
      title: LocalizedText.fromJson(j['title']),
      deityIds: _strings(j['deityIds']),
      language: j['language'] as String? ?? 'te',
      audio: audio,
      durationSec: (j['durationSec'] as num?)?.toInt() ?? 240,
      lyrics: _list(j['lyrics'], TextLine.fromJson),
      seasons: _strings(j['seasons']),
      licenseHolder: lic?['holder'] as String?,
    );
  }
}

// ---------------------------------------------------------------- Flagship

class FlagshipSeason {
  FlagshipSeason({
    required this.id,
    required this.deityId,
    required this.vratamId,
    required this.title,
    required this.subtitle,
    required this.format,
    required this.malaDays,
    required this.start,
    required this.end,
    required this.peakId,
    required this.peakAt,
    required this.peakTitle,
    required this.liveAarti,
    required this.teaserDays,
    required this.priority,
    required this.quiet,
    required this.bhajanSet,
    required this.chanting,
    required this.next,
    required this.milestones,
  });
  final String id, deityId;
  final String? vratamId;
  final LocalizedText title, subtitle, peakTitle;
  final String format;
  final int malaDays;
  final DateTime start, end; // civil dates (UTC midnight)
  final String peakId;
  final DateTime peakAt; // instant
  final bool liveAarti;
  final int teaserDays;

  /// "hero" or "secondary" (parallel season that never displaces the hero).
  final String priority;
  final bool quiet;
  final List<String> bhajanSet;
  final String? chanting;
  final String? next;
  final List<({DateTime date, LocalizedText name})> milestones;

  static DateTime _date(String s) {
    final d = DateTime.parse(s);
    return DateTime.utc(d.year, d.month, d.day);
  }

  factory FlagshipSeason.fromJson(Json j) {
    final peak = (j['peak'] as Map).cast<String, dynamic>();
    final daily = (j['daily'] as Map?)?.cast<String, dynamic>() ?? {};
    return FlagshipSeason(
      id: j['id'] as String,
      deityId: j['deityId'] as String,
      vratamId: j['vratamId'] as String?,
      title: LocalizedText.fromJson(j['title']),
      subtitle: LocalizedText.fromJson(j['subtitle'] ?? ''),
      format: j['format'] as String? ?? 'season',
      malaDays: (j['malaDays'] as num?)?.toInt() ?? 0,
      start: _date(j['start'] as String),
      end: _date(j['end'] as String),
      peakId: peak['id'] as String,
      peakAt: DateTime.parse(peak['at'] as String),
      peakTitle: LocalizedText.fromJson(peak['title']),
      liveAarti: peak['liveAarti'] as bool? ?? false,
      teaserDays: (j['teaserDays'] as num?)?.toInt() ?? 30,
      priority: j['priority'] as String? ?? 'hero',
      quiet: j['quiet'] as bool? ?? false,
      bhajanSet: _strings(daily['bhajanSet']),
      chanting: daily['chanting'] as String?,
      next: j['next'] as String?,
      milestones: _list(j['milestones'], (m) => (
            date: _date(m['date'] as String),
            name: LocalizedText.fromJson(m['name']),
          )),
    );
  }
}
