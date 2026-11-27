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
