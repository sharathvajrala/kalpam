# BUILD_LOG

## 2026-11-27
- Step 0 docs (architecture, schemas, screens, phase plan, ASSETS_TODO, ASSUMPTIONS). **Approved by Sharath** with the city correction.
- Core engines, pure Dart, tested: Panchangam (Meeus + Lahiri, verified against known 2026–27 dates), content-pack models + repository, flagship engine (lifecycle phases, parallel/quiet seasons), Sankalpam generator (te/en), pooja session state machine (Hands-on waits for actions, Watch Mode auto-performs, NotificationGate), deeksha tracker.
- Content packs: 8 deities (3 guided lengths each), Ayyappa Mandala vratam, 6 stotras (samples, flagged), 3 bhajans (traditional chants, audio pending), full 2027 flagship calendar + weekly gods + recurring vratams.
- App shell (5 tabs), design system, en/te localization (144 strings), onboarding (language → god → city by GPS/search → name/gotra), Today home (Subhodayam header, Flagship Hero with day ring, My God pinned, Today strip), Panchangam detail, city picker, settings with Elder Mode.
- City correction applied: no Hyderabad default; GPS or search in onboarding; fallback prompt on Today.
- Compiles clean: `flutter analyze` no issues, 25 tests pass, release web build OK (Android/iOS builds need their SDKs; not installed in this workspace).

### Temporary screens (labelled "in review queue", replaced in later groups)
Sannidhanam tab + pooja setup (group 2), Vratam detail (group 3), Grantham tab + chant player (group 4), Bhajans tab + player (group 5), Groups tab (Phase B). The placeholder sanctum renderer is written but not yet wired (group 2).

### Waiting on
- Private GitHub repo `kalpam` (Sharath to create; this session cannot create repos).
- Full spec file and the 4 UI sample images (attachments did not arrive).

## 2026-11-27 (later)
- Pushed to GitHub `sharathvajrala/kalpam` (private).
- Group 1 fixes: bilingual bottom tab bar (primary + secondary script on every tab); city chip moved to a full-width row so long Telugu names never clip.
- Approved user data model implemented (docs/DATA_MODEL.md): onboarding is language → god → city → name/gotram (+ optional janma nakshatram) → reminder times, with no skipping of required steps; family profiles with one-tap Sankalpam switching; GPS stores city name only; Settings has Export + Delete all.
- Reminder times are stored; scheduling the actual notifications (with the no-notification-during-pooja gate) lands with the notifications work in Phase A week 3.
- 27 tests pass, analyzer clean.

## 2026-11-27 — Screen group 1 (shell + Today home) ready for review
- Spec of record: docs/Kalpam-Fable-Build-Prompt.md (d225e0c). Note: it still contains the "[truncated 9553 chars]" marker after rule 5.
- Checked against the spec's frozen Today layout (hero → My God pinned → Today strip; Subhodayam header with te + en tithi/nakshatram).
- Bilingual pass: hero tiles, hero CTA, My God buttons, Panchangam strip labels, today's vratam + Join, weekday god label all now show both scripts.
- Hero tiles equal height.
- Screenshots (20 Dec 2026, Vijayawada, two family profiles): docs/screenshots/today-group1-{te,en}.png.

## 2026-11-27 — Screen group 2 (Ayyappa pooja interaction engine) ready for review
- Engine is its own module, `lib/pooja_engine/` (pure Dart, renderer-agnostic):
  - `gestures.dart`: one recognizer per upachara. Aarti/dhoopam clockwise circles (centre jitter and counter-clockwise ignored), flower shower (upward swipe), abhishekam (drag down or tilt the phone ~35° for 3 s), coconut (firm downward swipe), bell (phone shake via accelerometer, debounced, tap fallback), shankh (mic blow sustained 0.6 s, or press-and-hold 0.8 s), pradakshina (sweeps = rounds), archana (tap/flick = one flower per name).
  - `choreography.dart`: Watch Mode timelines per upachara (cue vocabulary shared with the future Unity sanctum). Ayyappa closing plays Harivarasanam, then the curtains close.
  - `pooja_session.dart`: one state machine for both modes; Sankalpam is spoken first; voice guide waits in Hands-on; "Do this for me" performs one step; switch mode mid-pooja; pause/resume; NotificationGate stays closed while a pooja (even paused) is open. No points or streaks.
- Screens: Sannidhanam tab + pooja setup (mode, 5/15/Shodashopachara, archana none/short/full, Sankalpam preview for the active family profile) and the pooja screen (sanctum, bilingual step HUD, gesture hint, liquid choice for abhishekam, gentle completion).
- Only the Ayyappa sanctum opens; other gods show a note until this group is reviewed (addendum).
- Hidden tabs no longer animate (TickerMode), so the sanctum never runs off-screen.
- Debug-only dart-defines for demos: `KALPAM_TAB`, `KALPAM_DEMO_SPEED`.
- 49 tests pass (gestures 11, choreography 6, session 4, pooja flow widget test 1), analyzer clean.
- Screenshots: docs/screenshots/pooja-group2-watch-en.png, pooja-group2-setup-handson-te.png.

## 2026-11-27 — Daily Rituals (Nitya Archana) ready for review
- Group 2 approved by Sharath (6903786). Standing notes: archana count stays data-driven from the pack; the pooja engine stays god-agnostic.
- Content (tool/build_packs.py): Ashtottaram namavali for all 8 gods + Sai Baba (first 16 names each, flagged until the verified 108 lands), Surya Dwadasa Namavali (12, complete), Venkatesa Suprabhatam, Aditya Hridayam, Lingashtakam, Om Sai Ram namajapam (samples flagged). Per-god `rituals` block: Sankalpam purpose line, suprabhatam, archana namavali + short count, evening chant (Ayyappa: Harivarasanam). Founder weekday map in calendar.json. Light packs `sai_baba` and `surya` (status "light": no sanctum, Day God only).
- `lib/core/rituals/daily_rituals.dart`: planner for the morning (Sankalpam, Suprabhatam, Sunday Aditya Hridayam + Surya arghyam, deepam, archana, aarti) and evening (deepam, aarti, evening chant, closing) rituals; `toVidhanam` runs the same plan in the Sannidhanam (Ayyappa), with Harivarasanam played once at the curtain closing.
- Day God mode: "Choose for me by day" in onboarding step 2 and the My God switcher; the weekday god leads My God, Daily Pooja, rituals, chanting and the Sankalpam (god + purpose).
- Today: Daily rituals card under My God (sunrise / sunset times, done-state, Full/Short archana remembered per day, streak). Guided ritual screen for any god with one flower per name; "Perform in Sannidhanam" for Ayyappa.
- Settings: evening reminder anchored to my time or local sunset (`ritualReminderAt`). Actual notification scheduling lands with the notifications work.
- 58 tests pass, analyzer clean. Screenshot: docs/screenshots/rituals-group-dayGod-thursday.png (Thursday, Day God mode = Sai Baba).
