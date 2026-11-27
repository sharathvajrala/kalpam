# KALPAM — Fable Build Prompt (paste everything below the line into Claude Fable, and attach the 4 UI sample images)

Design reference images to attach with this prompt:
1. kalpam-ui-1-home — Home: flagship takeover + My God pinned
2. kalpam-ui-2-sannidhanam — 3D Sannidhanam pooja
3. kalpam-ui-3-vratam — Vratam detail page
4. kalpam-ui-4-chant — Chant-along player

---

You are the lead builder for a production mobile app. Build it completely, in phases, with production-quality code — no toy demos, no dead buttons, no placeholder screens. Where a media asset (3D model, licensed audio) is not yet available, build the full feature around a clearly-flagged placeholder asset and log it in ASSETS_TODO.md. Everything else must actually work.

## THE PRODUCT

**Kalpam** — a general Hindu devotional platform (iOS + Android).
Store title: "Kalpam: Sankalpam, Vratam & Daily Pooja"
Tagline: "Mee Sankalpam — prathi roju, prathi vratam" (Your sankalpam — every day, every vratam)

The user chooses their god and gets: that god's daily pooja in a 3D virtual sanctum, pooja vidhanams, background chantings and bhajans for that god, a full built-in library of stotras, and a complete Vratam library (Vratha Kalpam + Vidhanam + Katha + Samagri + Sankalpam + tracker). Every month/season, one vratam/mala/bhajan season becomes the FLAGSHIP and takes over the home screen. The flagship launch season is the Ayyappa Mandala Deeksha (41-day mala), live now, peaking at Makaravilakku on 14 Jan 2027.

## DESIGN LANGUAGE (match the attached UI samples exactly)

Warm ivory background (#FAF5EC family), deep temple maroon (#5E1224 family), temple gold (#C9A227 / #D4AF37), saffron accents. Elegant serif display headings, clean sans body. Every label bilingual: English + Telugu script. Cards with thin gold borders and soft corners, as in the samples. Bottom tab bar, 5 tabs: **Today, Sannidhanam, Grantham, Bhajans, Groups**.

## ARCHITECTURE RULES

1. **Content-pack engine, data-driven.** Gods, vratams, stotras, bhajans and the flagship calendar are versioned content packs (JSON + media manifests), NOT hard-coded screens. Adding a god or a vratam = adding a pack, zero new code. Define and document schemas for: DeityPack, VratamPack, StotraItem, BhajanItem, FlagshipSeason, PanchangDay.
2. **Stack:** Flutter single codebase for iOS + Android. The 3D Sannidhanam is an embedded real-time 3D module (Unity-as-a-library or an equivalent embedded 3D engine — choose one, justify briefly, and commit). Backend: Firebase or Supabase (your pick, justify briefly) for accounts, groups, sync and remote content-pack updates. Offline-first: pooja, chanting, trackers and downloaded content work fully offline.
3. **Performance non-negotiable:** the 3D sanctum must run smoothly on a low-end Android phone (~₹10,000 class, 3–4 GB RAM). Stylized low-poly idols, baked lighting, texture atlases, quality auto-scaling. No heavy realism.
4. **Panchangam:** compute tithi, nakshatram, sunrise/sunset, Rahu Kalam etc. for the user's city locally from an astronomy library — do not depend on a paid API.
5. **Audio:** all stotra/bhajan audio is delivered as licensed/commissioned recordings via content packs. NEVER scrape or embed YouTube or any third-party copyrighted audio. Build the full player/chant-along pipeline with licensed-audio slots flagged in ASSETS_TODO.md.
6. **Localization:** every user-visible string goes through the localization system from day one — no hard-coded strings anywhere. Telugu + English ship at launch; the string tables must be structured so Tamil, Malayalam, Kannada and Hindi drop in as new tables with zero code changes.
7. **Notifications:** user-set morning/evening pooja reminders, flagship season prompts (join at T-30, peak-day aarti), and vratam-day surfaces. A NotificationGate suppresses ALL notifications while a pooja session is active. No marketing notifications, ever.
8. **Privacy by architecture:** practice data lives on-device by default (see USER DATA MODEL below). Cloud sync exists only after the user creates an account and opts in (Phase B, for Groups). No analytics SDK that profiles religious practice; no ad SDKs anywhere in the app.

## ONBOARDING (frozen order — 5 steps, no account, under 2 minutes)

1. **Language** — Telugu / English at launch (more added as packs land).
2. **Choose your god** — the 8 launch deities; this becomes "My God", pinned on Today forever. Also offer **"Choose for me by day"**: the user may skip choosing, and the app runs in Day God mode (see DAILY RITUALS) — the weekday god fills the My God slot until the user picks their own god in Settings.
3. **City** — one-time GPS detection of the nearest listed city, or search and pick. Only the city id is stored, never coordinates. Hyderabad is ONLY a fallback when the city is unset, and Today shows a "Set your city" prompt until it is set. Panchangam and the Sankalpam use this city.
4. **Name + Gotram** — creates the first family profile; janma nakshatram (birth star) is optional here, never blocking.
5. **Reminder times** — morning + evening, prefilled 5:30 AM / 6:30 PM, editable.

No phone, no email, no password at onboarding. A user can finish onboarding and do a full pooja without ever creating an account.

## USER DATA MODEL (approved 27 Nov 2026 — do not expand)

| Field | When | Required | Where it lives |
|---|---|---|---|
| Language | Onboarding step 1 | yes | device |
| Chosen god | Onboarding step 2 | yes | device |
| City (name/id only) | Onboarding step 3 — GPS one-time or search | yes (Hyderabad only as unset fallback) | device |
| Name | Onboarding step 4 / family profile | yes | device |
| Gotram | Onboarding step 4 / family profile | yes | device |
| Janma nakshatram | Onboarding step 4 / family profile | optional, never blocking | device |
| Morning + evening reminder times | Onboarding step 5 | yes (prefilled 5:30 AM / 6:30 PM) | device |
| Phone / email | Only when joining a Group or opting in to sync (Phase B) | optional | Firebase Auth, after opt-in |

**Family profiles:** several name/gotram(/nakshatram) profiles per device. The active profile is the one spoken in every Sankalpam; switch with one tap from the Today header chips or Settings. One profile always remains (the last profile cannot be deleted).

**Never collected:** contacts, mandatory DOB, ID numbers, payment details (v1), location history or coordinates. GPS is used once to pick the nearest city; only that city id is stored.

**Practice data** (trackers, checklists, joined vratams) is on-device only. Cloud sync starts only after account opt-in (Phase B).

**Settings → Your data:** one-tap Export (JSON of everything stored, via the share sheet) and Delete all (wipes every key on the device and returns to onboarding). Tests must prove: export contains no coordinates/phone/email/DOB; delete-all leaves zero keys.

## SANKALPAM GENERATOR

Every pooja and vratam begins with a generated Sankalpam, spoken aloud (TTS or recorded voice slot) and shown as text, in the user's language:
- The **active family profile's** name + gotram (+ janma nakshatram if provided)
- The user's **city**
- **Today's** samvatsaram, ayanam, ritu, masam, paksham, tithi, nakshatram, weekday — computed by the on-device Panchangam for that city (Amanta month reckoning, Lahiri ayanamsa — the Telugu tradition)
- The **purpose**: the pooja/vratam being performed and its stated phalam in one line

The same generator powers: Sannidhanam pooja opening, VratamPack sankalpam step, and Family Circle joint sankalpams (each member's own profile spoken on their own device). If gotram was skipped it is simply omitted — never block a pooja on missing optional data.

## HOME (Today tab) — FROZEN LAYOUT

1. **Flagship Hero (takes over the top of home for everyone):** current flagship season — god, season art, user's day count (e.g. Day 23 of 41 ring), countdown to peak day, today's katha chapter / bhajan / pooja for the season, "Join the Sankalpam" if not joined, "Continue" if joined.
2. **My God — pinned directly under the hero, always:** the user's chosen deity with one-tap Daily Pooja (opens Sannidhanam) and Chanting (opens their god's chanting). The flagship never buries this.
3. **Today strip:** Panchangam for user's city (tithi, nakshatram, sunrise/sunset, Rahu Kalam), today's recurring vratam if any (one tap to join), today's weekday god.
4. Subhodayam greeting header with the day's tithi/nakshatram in Telugu + English (as in sample 1).

## FLAGSHIP SEASON SYSTEM (core feature)

Every season follows the same lifecycle, driven by FlagshipSeason config:
- **T-30 days:** home takeover begins, countdown, "Sankalpam chey" (join), samagri checklist published, group/family-circle creation prompts.
- **Season days:** daily tracker, katha chapter of the day, bhajan + chanting of the day, season pooja in that god's sanctum.
- **Peak day:** special 3D pooja + a global synchronized live aarti moment in the sanctum (the Makara Jyothi pattern, reusable per season).
- **Closing:** Udyapanam flow, completion certificate + shareable card, next flagship teased on the same screen.

**2027 flagship calendar (ship this data):**
- Nov 2026–14 Jan 2027: **Ayyappa Mandala Deeksha** (41-day mala) — peak Makaravilakku / Makara Jyothi Thu 14 Jan 2027 ~6:30 PM IST; Sankranti 15 Jan alongside
- Dec 2026 (parallel, Ayyappa stays hero): **Dhanurmasam** — Vaikuntha Ekadashi 20 Dec 2026, Hanumad Vratam 22 Dec 2026, early-morning Vishnu pooja
- Feb–6 Mar 2027: **Shiva** — 21-day Om Namah Shivaya mala → Maha Shivratri Sat 6 Mar 2027, 4-jaama night pooja peak
- Apr 2027: **Rama + Hanuman** — Ugadi 7 Apr, Chaitra Navratri (9 days), Rama Navami 15 Apr, Hanuman Jayanti 20 Apr; Ramayana parayanam season
- May 2027: **Hanuman (Telugu)** — Hanuman Jayanti 31 May 2027 (Telugu tradition), 11-day Chalisa mala
- Jun 2027: **Ekadashi + Japa season** — Nirjala Ekadashi as peak; 108-japa sankalpam challenges; builds to Guru Purnima 18 Jul
- Jul 2027: **Guru + Shravanam begins** — Devshayani Ekadashi 14 Jul, Guru Purnima 18 Jul
- Aug 2027: **Lakshmi** — Shravana Masam: Varalakshmi Vratam Fri 13 Aug 2027, Mangala Gauri Tuesdays; second peak Krishna Janmashtami 25 Aug 2027
- Sep 2027: **Ganapathy** — Ganesh Chaturthi Sat 4 Sep 2027, 11-day Ganesh mala to Visarjan 14 Sep; then Pitru Paksham (16–29 Sep) as a QUIET seva feature (tarpanam) — never marketed as a celebration
- Oct 2027: **Devi, then Lakshmi** — Navratri 30 Sep–9 Oct (Dussehra 9 Oct), then Diwali / Lakshmi Pooja 29 Oct 2027
- 30 Oct–Nov 2027: **Karthika Masam** — Shiva + Satyanarayana, Karthika Somavarams, 365-wicks deepam, Karthika Pournami 13 Nov 2027
- Mid-Nov 2027: Ayyappa season begins again.

**Always-on layers under the flagship:**
- Monthly recurring: Ekadashi (×2/month), Sankashti Chaturthi, Pradosham, Masa Shivratri, Pournami Satyanarayana — auto-surfaced on the day, one tap to join.
- Weekly god days (founder-frozen): Mon Shiva, Tue Hanuman, Wed Ayyappa, Thu Sai Baba (Guru/Datta alongside), Fri Lakshmi/Durga, Sat Venkateswara, Sun Surya — that god gets the morning chanting + pooja push, and drives Day God mode (see DAILY RITUALS).

**"Mala" is a reusable format:** 9-day (Devi), 11-day (Ganesh, Hanuman), 21-day (Shiva), 41-day (Ayyappa) — same tracker, checklist, group system, different pack data.

## DAILY RITUALS — NITYA ARCHANA (morning & evening, every day)

The daily habit loop, anchored to the user's city sunrise/sunset from the Panchangam engine:

- **Morning ritual (sunrise-anchored):** the god's Suprabhatam, deepam, and **Nitya Archana** — a daily archana for the god: the Sankalpam of the day, then the god's Ashtottaram (108 names) as a flower-offering archana (in the Sannidhanam each name offers one flower; in the chant player each name highlights karaoke-style), closing aarti. A short form (Suprabhatam + 16-name Shodasha archana) on busy days — the user picks full/short per day, the app remembers.
- **Evening ritual (sunset-anchored, sandhya time):** sunset deepam, the god's evening aarti + evening chant (Ayyappa: Harivarasanam; others per pack), and the day's closing. Reminder fires at the user's evening time OR at local sunset — user chooses the anchor in Settings.
- **Which god:** the user's chosen god. **If no god is chosen (Day God mode)**, the weekday god drives everything that day — My God slot, Suprabhatam, archana, chanting, and the Sankalpam's deity + purpose: **Mon Shiva, Tue Hanuman, Wed Ayyappa, Thu Sai Baba, Fri Lakshmi/Durga, Sat Venkateswara, Sun Surya** (Sunday: Aditya Hridayam + Surya arghyam/namaskaram as the morning ritual). Sai Baba and Surya get lightweight packs for this (aarti, signature chant, archana names) even though they are not among the 8 full deity packs at launch.
- **Sankalpam follows the god:** the generated Sankalpam names the day's god and that god's purpose line (per-pack data), whether the god came from the user's choice or the weekday.
- Today home surfaces both rituals as morning/evening cards with done-state for the day; streaks live here and in trackers — never inside the sanctum (per non-negotiables).

## DEITY PACKS (8 at launch)

Ayyappa, Ganapathy, Shiva, Venkateswara/Vishnu (incl. Krishna + Satyanarayana forms), Lakshmi, Durga/Devi, Hanuman, Subrahmanya. Each pack: 3D idol + sanctum theme, Suprabhatam, Ashtottaram, Sahasranamam where applicable, signature background chantings, bhajan set with lyrics, deity-specific offerings + aarti, festival alankaram variants. **Ayyappa pack is the deepest** (it carries the launch flagship); other packs ship complete for daily pooja + chanting at Phase B.

## SANNIDHANAM TAB — 3D VIRTUAL POOJA (the heart of the app)

- One sanctum per god; flagship season re-dresses it (Navratri: Devi alankaram changes all 9 days; Karthika: 365-wicks deepam lit wick by wick; Shivratri: 4-jaama night poojas).
- **TWO MODES, both v1 (frozen decision):**
  - **Hands-on:** the user performs every upachara — light the deepam, shower flowers (physics), pour abhishekam (water / milk / panchamrutam / ghee for Ayyappa), break the coconut, drag the aarti plate in circles (live flame), shake the phone to ring the bell, blow into the mic for the shankh (tap-hold fallback), offer naivedyam, pradakshina around the Swamy.
  - **Watch Mode (Elder Mode):** one tap and the full pooja auto-performs in the same 3D sanctum like a temple deeparadhana, with voice chanting — the user simply receives it.
- **Three guided lengths:** 5-min Nitya Pooja, 15-min, full Shodashopachara (16 upacharas). Voice guide in the user's language WAITS at each step until the action is done.
- Every pooja opens with the **spoken Sankalpam** generated for the user (name, gotra, city, today's tithi/nakshatram, the pooja's purpose) and closes with that god's closing (Ayyappa: nada/curtains close as Harivarasanam plays).
- **Peak moments:** Makara Jyothi appearing over the hill in the Ayyappa sanctum on 14 Jan 2027 ~6:30 PM IST with synchronized global aarti; 18-steps (Pathinettampadi) climb with Irumudi on the user's deeksha completion day.

## GRANTHAM TAB — BUILT-IN LIBRARY (everything in-app, no YouTube dependence)

- **Stotra canon, built in:** Vishnu Sahasranamam, Lalitha Sahasranamam, Shiva Sahasranamam, Hanuman Chalisa, Bajrang Baan, Sankatmochan, Aditya Hridayam, Kanakadhara Stotram, Lingashtakam, Bilvashtakam, Rama Raksha Stotram, Durga Saptashati (Navratri), Soundarya Lahari selections, every god's Ashtottaram + Suprabhatam, Ayyappa 108 Saranams + Harivarasanam, Govinda Namalu. Texts are public domain — include Telugu script + transliteration + simple English meaning for every item.
- **Chant-along player (sample 4):** current line highlights karaoke-style in sync with audio; sung version + slow Learn Mode; repeat-line ×11/21/108; japa/mala counter (108 / 1,008) with bead progress; background + lock-screen playback; offline downloads.
- **Parayanam habit loop:** Vishnu Sahasranamam Thu + Sat, Lalitha Sahasranamam Fri, Hanuman Chalisa Tue + Sat, Aditya Hridayam Sun — home push on the day + a live "devotees chanting today" counter.
- **Pooja Vidhanams:** step-by-step guided text+audio procedures per god and per vratam, same content the Sannidhanam animates.
- **Bhajans tab:** per-god bhajans/keertanalu with lyrics, background play, offline packs, season playlists (flagship bhajan set becomes the home playlist in its season).

## VRATAM ENGINE + LIBRARY

Every vratam is a VratamPack with ONE standard structure: Katha (audio chapters + text), Samagri checklist, Sankalpam generator, fasting rules, Vidhanam steps, day-by-day tracker (multi-day), Udyapanam closing, completion certificate + share card.
**Fully built at launch (6):** Ayyappa Mandala Deeksha 41-day, Satyanarayana Vratam, Ekadashi, Sankashti Chaturthi, Pradosham, Varalakshmi Vratam. Post-launch: one new vratam per week via content packs (Kedareswara, Mangala Gauri, Anagha Datta, Navratri, Karthika Somavara, Hanuman Vratam…).

**Ayyappa pack depth (launch flagship):** deeksha tracker (any start date, 1–90 days, default 41), morning + evening checklist, sunrise/sunset reminders, Maladharana mantram, Irumudi checklist, **Sabarimala Live** (nada open/closed, current pooja, crowd/queue note, official notices), **Annadanam near you** with live "serving now / finished today" status, Ayyappa temples + Padi Poojas near you, link OUT to sabarimalaonline.org for Virtual Queue booking. NEVER sell darshan or offer "VIP darshan" anything.

## GROUPS TAB

- **Family Circles** (all vratams): join a vratam/mala together, see each member's day count, gentle reminders, shared parayanam counts, completion celebrated together.
- **Guruswamy Groups** (Ayyappa): Guruswamy creates the group, WhatsApp invite link, per-member deeksha day count, announcements, yatra date poll, Virtual Queue member list (max-10 booking coordination), expense split for bus / annadanam / Padi Pooja.
- Live synced multi-phone 3D group pooja and AR Sannidhanam are v1.1 — architect for them, do not build in v1.

## NON-NEGOTIABLES

- Languages: **Telugu + English at launch**; Tamil + Malayalam (at minimum the full Ayyappa pack) before 14 Jan 2027; Kannada + Hindi fast-follow. UI strings fully localized from day one — no hard-coded strings.
- **Elder Mode:** big text, full voice navigation, Watch Mode — a first-class setting, not an afterthought.
- No account required for pooja, chanting, bhajans, trackers. Account only for groups/sync.
- **No ads inside pooja, ever.** No astrology. No reels/social feed. No paid darshan anything.
- Reverence: no gamification inside the sanctum (no points/streaks there — streaks live in trackers only), no notifications during an active pooja.

## BUILD ORDER & MILESTONES

- **Step 0 (first response):** output (a) architecture + stack choices with one-line justifications, (b) all content-pack schemas, (c) full screen inventory mapped to the 4 samples, (d) ASSETS_TODO.md (3D idols/sanctums, licensed audio, verified texts), (e) build plan per phase below. Then start Phase A without waiting.
- **Phase A — soft launch, Mandala Puja 27 Dec 2026:** app shell + design system from the samples, Today home (flagship hero + My God pinned + Today strip), Panchangam, Sankalpam generator, Ayyappa flagship complete (tracker, checklists, Irumudi, Sabarimala Live, Annadanam), Sannidhanam with Ayyappa sanctum in BOTH modes (5/15-min + Shodashopachara), Grantham core (Ayyappa set + Vishnu/Lalitha Sahasranamam + Hanuman Chalisa chant-along), Bhajans core, Elder Mode, Telugu + English.
- **Phase B — Makaravilakku, 14 Jan 2027:** all 8 deity packs (daily pooja + chanting), all 6 launch vratams fully built, Groups (Family Circles + Guruswamy), Tamil + Malayalam Ayyappa pack, Makara Jyothi live sanctum event, flagship engine running the full 2027 calendar above.
- **Phase C — post-Jan 2027:** weekly new vratam packs, Kannada + Hindi, v1.1 features (live group pooja, AR).

Write clean, tested, production code. Commit in small working increments per screen/feature, keep a BUILD_LOG.md of what is done, and flag every assumption you had to make in ASSUMPTIONS.md instead of silently choosing. Begin with Step 0 now.
