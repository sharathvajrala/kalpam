# Kalpam — Build plan (Step 0e)

Today: Fri 27 Nov 2026. Mandala season is live (Day ~12 for a 16 Nov start).

## Phase A — soft launch, Mandala Puja, Sun 27 Dec 2026 (30 days)

| Week | Deliverable |
|---|---|
| 27 Nov – 3 Dec | Shell, design system, l10n (en/te), content-pack engine, Panchangam engine (tested), Sankalpam generator, Today home, Ayyappa pack data, deeksha tracker, chant-along player UI, Bhajans UI, Elder Mode, placeholder sanctum with full pooja state machine (both modes, 3 lengths). |
| 4 – 10 Dec | Unity project: Ayyappa sanctum scene (low-poly, baked), `flutter_embed_unity` integration behind `SanctumBridge`, quality auto-scaler; `just_audio` + `audio_service` background playback; downloads. |
| 11 – 17 Dec | Sabarimala Live + Annadanam backend (Firestore + Functions, moderated), local notifications (sunrise/sunset deeksha reminders, NotificationGate), Firebase project, crash reporting. |
| 18 – 24 Dec | Device QA on 3 low-end Androids + 2 iPhones, accessibility pass, Telugu proof-reading, store listings, internal track builds. |
| 27 Dec | Soft launch (Play internal → open testing; TestFlight). |

**Gating dependencies (from Sharath):** Ayyappa idol + sanctum art, licensed Harivarasanam + 108 Saranams + voice guide recordings, verified Telugu texts, Firebase project, Apple/Google developer accounts.

## Phase B — Makaravilakku, Thu 14 Jan 2027

7 remaining deity packs (daily pooja + chanting); 5 more vratams (Satyanarayana, Ekadashi, Sankashti, Pradosham, Varalakshmi); Groups (Family Circles + Guruswamy, WhatsApp invite deep links, polls, VQ list, expense split); Tamil + Malayalam Ayyappa pack; Makara Jyothi live sanctum event (server-timed, ~6:30 PM IST); Pathinettampadi climb; flagship engine running the full 2027 calendar (data already shipped in Phase A).

## Phase C — post Jan 2027

Weekly vratam packs (Kedareswara, Mangala Gauri, Anagha Datta, Navratri, Karthika Somavara, Hanuman Vratam…), Kannada + Hindi, v1.1 live synced group pooja (SanctumBridge relay), AR Sannidhanam.
