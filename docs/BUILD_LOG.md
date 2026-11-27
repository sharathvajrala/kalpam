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

## 2026-11-27 — Grantham core ready for review
- Daily Rituals approved (fde097d). Phase A order: Grantham core → Bhajans core → Elder Mode polish.
- `lib/core/chant/chant_engine.dart`: pure-Dart chant-along engine. Line timing from the recording's cue points when present (TextLine.tSung / tLearn), else estimated from the text; Learn Mode slower with a pause to repeat; repeat-line ×1/11/21/108; JapaCounter (108 beads per mala, target 108 or 1,008); optional "count each repeat on the mala".
- Grantham tab: Parayanam today (weekday map), library by god (your god first; Phase A core set leads) or by category; every unverified text carries a "Sample" flag.
- Chant-along player: karaoke fill on the current line, auto-scroll, tap a line to jump, meaning toggle, Sung/Learn, repeat chips, japa card with 108-bead ring and meru, persisted per stotra (included in Export). With no licensed recording yet, the voice guide reads each line and the player says so.
- Ayyappa 108 Saranams parayanam day moved to Wednesday (founder map).
- ASSETS_TODO: Grantham text + audio slots listed; background/lock-screen playback and audio downloads wait for the first licensed recording.
- 63 tests pass, analyzer clean. Screenshot: docs/screenshots/grantham-core.png.

## 2026-11-27 — Bhajans core ready for review
- Grantham core approved (6c2d20b). Standing note recorded: lock-screen/background playback + downloads are a Phase A exit item, wired as soon as the first licensed recording lands.
- Content: 7 new traditional chants (Govinda Namalu, Hare Rama maha mantra, Om Namah Shivaya, Sri Rama Jaya Rama, Om Gam Ganapataye, Haro Hara, Om Sai Namo Namah) attached to their gods. Bhajan packs now carry `source` and `lyricsVerified`; unverified lyrics show a "Sample" flag.
- `lib/core/chant/playlist.dart`: BhajanPlaylist on top of the chant engine: karaoke lyrics, auto-advance, loop, next/previous wrap (advance is deferred outside the engine's notification so the finished engine can be disposed safely).
- Bhajans tab: season playlist on top with Play all (Ayyappa Mandala set this season), then your god, then every god with bhajans. Today's Bhajan on the hero opens the player with the season queue.
- Player: big karaoke lyrics, tap a line to jump, Up next queue, loop, voice guide reads lines until recordings land (stated on screen).
- 67 tests pass, analyzer clean. Screenshot: docs/screenshots/bhajans-core.png.

## 2026-11-27 — Notifications ready for review
- Spec eea9f63 (NOTIFICATIONS). All daily notifications are local and planned on-device.
- `lib/app/notifications/notification_planner.dart`: pure planner over 7 days. Subhodayam digest at sunrise (+0/15/30/60 min) with tithi, nakshatram, sunrise/sunset, today's festival and the day's god; morning ritual reminder and evening Sandhya push, both dropped once that ritual is done; festival T-1 evening, festival morning, flagship peak (with live aarti time), T-30 invitation and closing Udyapanam, capped at one extra per day; mala check-in "Day N of M" at the chosen time with halfway, final-day (opens Udyapanam) and gentle resume wording; evening nudge only while the checklist is incomplete; quiet hours.
- `notification_scheduler.dart`: flutter_local_notifications (UTC instants, no tz database), re-plans on open/resume (covers timezone change), any state change (city, ritual done, checklist, Settings) and when a pooja ends; cancels everything while NotificationGate is active. Taps route to Today, the ritual or the vratam.
- Join flow: "Join the Sankalpam" now asks the number of days (pack standard prefilled, 41 for Ayyappa, 1–90), start date and daily check-in time.
- Settings → Notifications: per-type switches, Subhodayam time, quiet hours, one-time Android exact-timing/battery note, "Coming up" preview, Allow notifications.
- Android manifest/gradle (desugaring, receivers, permissions) and iOS delegate configured.
- 81 tests pass, analyzer clean. Screenshots: docs/screenshots/notifications-*.png.

## 2026-11-27 — Elder Mode polish ready for review
- Bhajans (ba24f01) and Notifications (03bdf8e) approved; both notification assumptions confirmed. Next after review: Android AAB for Play internal testing (com.kalpamapp.kalpam).
- Automated Elder Mode audit (test/app/elder_audit_test.dart): every tab and Phase A screen on a 360 x 740 dp phone with Elder Mode, Telugu and English, plus tap-target and contrast guidelines; and a walk through every step of both guided rituals. Fixed: Today rituals row, Panchangam header, Bhajans season header, ritual step buttons (stacked full width in Elder Mode).
- Theme: 56 dp minimum for icon and text buttons, roomier chips and list tiles in Elder Mode.
- Elder Today card: one tap runs the day's pooja (Watch Mode in the sanctum, or the voice-guided ritual), and "Listen to today" speaks the greeting, Panchangam, sunrise/sunset, the day's god and what is still pending.
- Voice navigation: mic button on every tab (Elder Mode). Commands in English or Telugu: Pooja, Morning, Evening, Panchangam, Chanting, Bhajans, Sannidhanam, Groups, Today, Settings, Help, Stop.
- Guided rituals read each step aloud in Elder Mode. Elder Mode choice added to the first onboarding screen.
- Android RECORD_AUDIO + RecognitionService query, iOS microphone/speech usage strings.
- 92 tests pass, analyzer clean. Screenshots: docs/screenshots/elder-*.png.
