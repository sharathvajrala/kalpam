# Kalpam — Content-pack schemas (Step 0b)

All packs are UTF-8 JSON. Dart models: `lib/core/content/models.dart` (parsing is strict: unknown
`schema` versions are rejected, missing optional fields default). Bundled examples: `assets/packs/`.

## Shared types

```jsonc
// LocalizedText — every user-facing string. "en" is required; others optional, fall back to en.
{ "en": "Daily Pooja", "te": "నిత్య పూజ", "ta": "…", "ml": "…", "kn": "…", "hi": "…" }

// MediaRef — URI scheme decides resolution
"asset://packs/ayyappa/art/hero.webp"   // bundled in app
"pack://ayyappa/audio/harivarasanam.opus" // downloaded with the pack
"placeholder://audio/harivarasanam"       // not yet licensed/recorded → ASSETS_TODO.md

// PackHeader — top of every pack file
{ "schema": "kalpam.deity/1", "id": "ayyappa", "version": 3, "updatedAt": "2026-11-27",
  "minAppVersion": "1.0.0", "languages": ["en","te","ta","ml"] }
```

## DeityPack (`kalpam.deity/1`)

| field | type | notes |
|---|---|---|
| header… | PackHeader | |
| name, epithet | LocalizedText | "Swamy Ayyappa", "Hariharasutha" |
| weekdays | int[] | ISO weekday 1=Mon…7=Sun this god is honoured on |
| colors | {primary, accent} hex | sanctum + card tint |
| art | {icon, hero, card} MediaRef | |
| sanctum | {sceneId, defaultAlankaram, alankarams: [{id, name, season?}], closing: {type: "curtains"/"aarti"/"bell", audio: MediaRef}, abhishekamLiquids: ["water","milk","panchamrutam","ghee"], peakEvents: [{id, name, startsAt ISO, durationMin}]} | `sceneId` names the Unity AssetBundle |
| offerings | [{id, name, kind: flower/naivedyam/fruit/leaf, upacharaId}] | |
| poojas | [PoojaVidhanam] | at least `nitya5`, `nitya15`, `shodasha` |
| chantings | string[] | StotraItem ids for "Chanting" button (first = signature) |
| stotras | string[] | StotraItem ids in Grantham under this god |
| bhajans | string[] | BhajanItem ids |
| greeting | LocalizedText | "Swamiye Saranam Ayyappa" |

**PoojaVidhanam**: `{id, name, lengthMin, steps:[PoojaStep]}`
**PoojaStep**: `{upachara, title: LocalizedText, instruction: LocalizedText, mantra: LocalizedText, voice: MediaRef, action: "tap"|"drag_circle"|"shake"|"blow"|"pour"|"shower"|"swipe_down"|"walk_around"|"none", target: int (repetitions, e.g. 3 circles), autoDurationSec}`
`upachara` ∈ `sankalpam, dhyanam, avahanam, asanam, padyam, arghyam, achamaniyam, snanam/abhishekam, vastram, yagnopavitam, gandham, pushpam, dhoopam, deepam, naivedyam, tambulam, nirajanam/aarti, mantrapushpam, pradakshina, namaskaram, coconut, bell, shankh, closing`.

## VratamPack (`kalpam.vratam/1`)

| field | type | notes |
|---|---|---|
| header…, name, summary | | |
| deityId | string | sanctum used for Vidhanam |
| kind | "single_day" \| "mala" \| "recurring" | |
| mala | {defaultDays, minDays, maxDays, morningChecklist[], eveningChecklist[], rules[]} | Ayyappa: 41 / 1 / 90 |
| recurrence | {rule: "tithi", tithi: 11, paksha: "both"} \| {rule: "weekday", weekday: 5} \| {rule: "fixed", dates: [...]} | auto-surfacing on Today |
| samagri | [{id, name: LocalizedText, qty: LocalizedText, optional}] | checklist |
| fasting | [LocalizedText] | |
| sankalpam | {purpose: LocalizedText, template?: string} | fed to Sankalpam generator |
| vidhanamPoojaId | string | refers to deity pack pooja or an inline `pooja` |
| katha | [{chapter, title, text: LocalizedText, audio: MediaRef, day?}] | `day` maps chapter to mala day |
| udyapanam | [PoojaStep] + {certificateTemplate: MediaRef} | |
| extras | object | pack-specific (Ayyappa: irumudi checklist, maladharana mantram, sabarimala feed URL) |

## StotraItem (`kalpam.stotra/1`)

```jsonc
{ "schema":"kalpam.stotra/1", "id":"vishnu_sahasranamam", "version":1,
  "title": LocalizedText, "deityIds":["vishnu"], "category":"sahasranamam",
  "parayanamDays":[4,6],            // Thu+Sat habit loop
  "source": "Mahabharata, Anushasana Parva 149 (public domain)", "verifiedBy": null,
  "audio": { "sung": MediaRef, "learn": MediaRef },
  "lines": [ { "id":"l1", "sa_te":"శుక్లాంబరధరం విష్ణుం…", "translit":"śuklāmbaradharaṁ viṣṇuṁ…",
               "meaning": LocalizedText, "tSung":[0, 5200], "tLearn":[0, 9800] } ] }
```
`tSung` / `tLearn` are `[startMs, endMs]` cue points for karaoke highlighting (null = derived from line length until recordings arrive).

## BhajanItem (`kalpam.bhajan/1`)

`{id, version, title, deityIds[], language, artist: "commissioned"|name, license: {holder, ref, expires}, audio: MediaRef, durationSec, lyrics: [{text, translit, t:[start,end]}], seasons: [seasonId]}`
A bhajan **must** carry a `license` block before its `audio` may point to anything other than `placeholder://`. The pack validator enforces it.

## FlagshipSeason (`kalpam.flagship/1`) — one file holds the calendar

```jsonc
{ "id":"ayyappa_mandala_2026", "deityId":"ayyappa", "vratamId":"ayyappa_mandala",
  "title": LocalizedText, "format":"mala", "malaDays":41,
  "start":"2026-11-16", "end":"2027-01-15",
  "peak": { "id":"makara_jyothi", "at":"2027-01-14T18:30:00+05:30", "title": LocalizedText, "liveAarti": true },
  "teaserDays":30, "parallel":[ {"id":"dhanurmasam_2026", "priority":"secondary"} ],
  "daily": { "kathaFromVratam": true, "bhajanSet":["…"], "chanting":"ayyappa_saranam_108" },
  "sanctumDressing": { "alankaram":"mandala", "byDay": { "41":"padi_pooja" } },
  "quiet": false,          // Pitru Paksham = true → never shown as hero celebration
  "next": "dhanurmasam_2026" }
```
Lifecycle phase is derived, never stored: `teaser` (start−teaserDays … start), `season`, `peak` (peak day), `closing` (peak+1 … end+7).

## PanchangDay (computed on-device, cached per city/day)

```jsonc
{ "date":"2026-12-20", "city":{"name":"Hyderabad","lat":17.385,"lon":78.4867,"tz":"Asia/Kolkata","utcOffsetMin":330},
  "sunrise":"06:36", "sunset":"17:43", "weekday":7,
  "tithi": {"index":11, "paksha":"shukla", "name":LocalizedText, "endsAt":ISO},
  "nakshatra": {"index":2, "name":LocalizedText, "endsAt":ISO},
  "yoga": {...}, "karana": {...},
  "masa": LocalizedText (amanta), "rahuKalam":["10:15","11:39"], "yamagandam":[…], "gulikaKalam":[…],
  "festivals":["vaikuntha_ekadashi"] }
```
