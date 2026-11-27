# Kalpam — Architecture (Step 0a)

Store title: **Kalpam: Sankalpam, Vratam & Daily Pooja**
Tagline: *Mee Sankalpam — prathi roju, prathi vratam* / మీ సంకల్పం — ప్రతి రోజు, ప్రతి వ్రతం

## Stack decisions (committed)

| Layer | Choice | One-line justification |
|---|---|---|
| App | **Flutter 3.50 / Dart 3.14**, single codebase iOS + Android | One UI codebase, strong i18n (ARB/gen-l10n), mature background-audio plugins. |
| 3D Sannidhanam | **Unity 6 LTS as a library** (URP, embedded via `flutter_embed_unity`) | Only embeddable engine with production-grade baked lightmaps, texture atlasing, LOD, GPU-instanced particles, Rigidbody physics (flower shower) and per-device quality tiers proven on ₹10k Android phones; Flutter-native 3D (flutter_scene / Filament) is still too immature for physics + particles. |
| Backend | **Firebase** (Auth, Firestore, Cloud Storage, Remote Config, FCM, Functions) | Firestore's offline persistence gives offline-first groups/sync for free, phone-OTP auth is the norm for the Indian audience, Storage + Remote Config deliver content packs, FCM handles weekday/parayanam pushes. |
| Local storage | `shared_preferences` (settings), JSON files in app docs dir (downloaded packs), SQLite via `sqflite` (tracker history, Phase A.2) | Everything a pooja needs lives on-device. |
| Audio | `just_audio` + `audio_service` (Phase A.2) | Gapless, background + lock-screen controls on both OSes. |
| State | Plain `ChangeNotifier` services exposed through an `AppScope` InheritedWidget | Zero-magic, easy to test, no codegen; can migrate to Riverpod later if needed. |
| Panchangam | **On-device pure-Dart astronomy** (`lib/core/panchangam/`) implementing Meeus *Astronomical Algorithms* (solar + lunar ephemeris, Lahiri ayanamsa, NOAA sunrise) | No paid API, works offline, deterministic and unit-testable. Accuracy target: tithi/nakshatra end-times within ±5 min, sunrise within ±1 min. |

## Layered structure

```
lib/
  main.dart                 app entry, AppScope wiring
  app/                      KalpamApp, shell (5 tabs), theme, localization delegate
  core/
    content/                content-pack models (DeityPack, VratamPack, StotraItem,
                            BhajanItem, FlagshipSeason, PanchangDay) + PackRepository
    panchangam/             astronomy + Panchangam calculator (pure Dart, no Flutter)
    sankalpam/              Sankalpam text generator (pure Dart)
    flagship/               FlagshipEngine: picks hero season, lifecycle phase, day counts
    pooja/                  PoojaSession state machine (steps, wait-for-action, watch mode)
                            + SanctumBridge (Flutter <-> 3D engine protocol)
    tracker/                Deeksha / mala / vratam trackers (streaks live here only)
    settings/               user profile (name, gotra, city, deity, language, elder mode)
  features/
    today/  sannidhanam/  grantham/  bhajans/  groups/  ayyappa/  onboarding/
  l10n/                     ARB files (en, te; ta, ml for Ayyappa pack in Phase B)
assets/
  packs/                    bundled base content packs (JSON) — remote updates override
  fonts/                    bundled OFL fonts (offline-first)
unity/ (Phase A.2)          Unity project: one scene per sanctum, AssetBundles per deity
```

## Content-pack engine

* Every god, vratam, stotra, bhajan set and the flagship calendar is a **versioned JSON pack** plus a media manifest. Schemas: `docs/SCHEMAS.md`.
* `PackRepository` loads, in priority order: (1) downloaded packs in app storage (newer `version`) → (2) bundled packs in `assets/packs/`. Screens render whatever packs exist — adding a god or a vratam is adding a pack, no new code.
* Remote updates: `packs/index.json` in Firebase Storage lists `{id, version, sha256, url, minAppVersion}`. The app diffs against local, downloads in background on Wi-Fi, verifies sha256, swaps atomically.
* Media (`MediaRef`) is resolved lazily: `asset://` (bundled), `pack://` (downloaded), `placeholder://` (flagged in ASSETS_TODO.md — the UI shows a "recording coming soon" chip and the feature still works with silent/tone fallback and timed lyrics).

## 3D Sannidhanam

* Flutter owns all UI, voice guide, Sankalpam and the step state machine (`PoojaSession`). Unity only renders and reports gestures. They talk over a small JSON message protocol (`SanctumBridge`, see `lib/core/pooja/sanctum_bridge.dart`):
  * Flutter → 3D: `loadSanctum{deityId, alankaram, season}`, `beginStep{upachara}`, `autoPerform{upachara}` (Watch Mode), `peakEvent{id}`, `setQuality{tier}`, `closeSanctum`.
  * 3D → Flutter: `ready`, `actionDone{upachara}`, `progress{upachara, 0..1}`, `fps{avg}`.
* Performance budget for low-end Android (Helio G85 / SD 680, 3–4 GB): ≤ 25k tris per scene, 1 × 2048² atlas per sanctum, fully baked lightmaps + 1 realtime flame light, ≤ 300 flower particles, target 30 fps; auto-scaler drops to tier 0 (no bloom, half-res particles) if avg fps < 26 for 3 s.
* Until the Unity module and idols land, `PlaceholderSanctumView` (a Flutter CustomPainter sanctum) implements the same bridge so every upachara, both modes and all three lengths work end-to-end today. It is flagged in ASSETS_TODO.md.
* v1.1-ready: `SanctumBridge` messages carry a `sessionId` + `seq` so a future live group pooja can relay them through Firestore/RTDB; AR is a separate Unity scene using the same assets.

## Offline-first

| Works fully offline | Needs network |
|---|---|
| Panchangam, Sankalpam, all poojas, chanting of downloaded items, bhajans downloaded, trackers, checklists, Elder Mode | Groups, sync, Sabarimala Live, Annadanam live status, pack downloads, live "devotees chanting today" counter |

## Reverence rules enforced in code

* `PoojaSession.active` suppresses all local notifications while a pooja runs (NotificationGate).
* No points/streak widgets are allowed inside `features/sannidhanam/` (lint test checks imports of `tracker/streak`).
* No ad SDK in the dependency tree. No astrology module.
* Sabarimala: only link out to sabarimalaonline.org for Virtual Queue. Nothing about darshan is sold.

## Accounts

No account for pooja / chanting / bhajans / trackers. Firebase Auth (phone OTP or Google/Apple) is requested only when the user opens Groups or turns on sync.
