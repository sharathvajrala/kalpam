# ASSUMPTIONS — choices made without explicit confirmation

Each item is a decision Sharath may want to overrule.

1. ~~**Truncated spec.**~~ Sharath is re-sending the full spec as a file (27 Nov); not yet received. About 9,500 characters of the spec (architecture rules 6+ and whatever sat between them and the HOME section) did not arrive. Everything below that point and above it was followed. Asked Sharath to resend.
2. **UI sample images** were not attached. The design system follows the written design language (ivory #FAF5EC, maroon #5E1224, gold #C9A227/#D4AF37, saffron) until they arrive.
3. **Ayyappa Mandala start date:** season config uses 16 Nov 2026 (Vrischikam 1, Mandala start), Mandala Puja 27 Dec 2026, Makaravilakku 14 Jan 2027 18:30 IST. A user's own deeksha can start any date (1–90 days, default 41).
4. **Unity as a library** for 3D (see ARCHITECTURE.md). Requires Unity licence (Personal is fine below USD 200k revenue).
5. **Firebase** over Supabase.
6. **Panchangam method:** amanta month naming (Telugu tradition), Lahiri ayanamsa, values "at sunrise" for the day's tithi/nakshatra (udaya tithi), sunrise = upper limb with standard refraction (−0.833°). Rahu Kalam = 8 equal parts of daytime using the standard weekday order.
7. **City (corrected by Sharath, 27 Nov):** onboarding asks for the city by GPS (one-time detection of the nearest listed city; only the city is stored) or search. Hyderabad is only the fallback when no city is set, and Today then shows a "Set your city" prompt. Amanta months and Lahiri ayanamsa approved.
8. **Sankalpam** uses the Telugu (Shalivahana, 60-year samvatsara) template; samvatsara for 2026-27 = Parabhava (Ugadi 2026 → Ugadi 2027), Plavanga from Ugadi 7 Apr 2027.
9. **Weekly god days:** Sunday (not listed in the spec) = Surya / Aditya Hridayam, matching the parayanam habit loop.
10. **Text content in bundled packs is a sample** (opening portions) until verified full texts are supplied; the player handles full-length items already.
11. **Fonts:** Cormorant Garamond (English serif headings), Noto Serif Telugu (Telugu headings), Noto Sans Telugu (body). All OFL, bundled for offline use.
12. **State management:** plain ChangeNotifier + InheritedWidget instead of Riverpod/Bloc, to keep dependencies small.
13. **Phase A Groups tab** shows a working intro + sign-in gate; the full groups feature is Phase B as per the build order.
14. **No GitHub repo yet**: work is committed to a local git repo and mirrored to the project files folder.
15. **Diaspora cities with DST** (US/UK/AU) are not in the city list yet; they arrive with a timezone database in Phase B.
16. **Material/Cupertino:** Flutter 3.50 moved Material to `package:material_ui`; the app uses it throughout.
17. **Reminder defaults** prefilled at 5:30 AM and 6:30 PM; the user can change them before finishing onboarding.
18. **Profile removal:** the last remaining family profile cannot be removed (Delete all is the way to wipe it).
19. **Archana names:** the archana uses the Ayyappa Saranam pack, which has 12 verified sample names today. "Full" becomes 108 and "Short" 16 once the full text is verified; nothing else changes.
20. **Shankh by mic:** the recognizer already accepts mic levels; wiring the microphone plugin (with its permission prompt) is deferred to the device build. Press-and-hold works now, per the spec's fallback.
21. **Archana sample size:** every god's Ashtottaram ships its first 16 names until the verified 108 lands, so Full and Short both show 16 today. The counts come from the pack only.
22. **Suprabhatam:** only Venkatesa Suprabhatam (15th c., public domain) is bundled. Other gods' Suprabhatams are pending verification and licence checks; the morning ritual skips the step until a pack provides one.
23. **Sai Baba Ashtottaram:** in common temple use but of uncertain authorship; flagged for a licence check before launch.
24. **Fri Lakshmi/Durga:** Day God mode uses Lakshmi on Fridays; Durga stays listed as the alternate.
25. **Mala check-ins are part of the daily set, not the "extra":** the cap of one extra per day applies to festival and flagship pushes. A joined mala's morning "Day N of M" and its evening nudge are the user's own commitment; milestone, final-day and resume wording replace the check-in text on those days rather than adding a push. When the check-in falls at the same minute as the morning ritual reminder, the two merge into one push.
26. **Extra priority when two festival pushes compete on a day:** flagship peak, then closing Udyapanam, then the T-30 join invitation, then the festival-morning invitation, then the T-1 evening notice.
27. **Notification times:** festival-morning invitations come 1 hour after the Subhodayam digest; the T-1 notice comes at 7 PM or 45 minutes after sunset, whichever is later; the evening mala nudge comes 90 minutes after the evening ritual time. Quiet hours default to 10 PM–5 AM; a push inside them moves to the end of the window that night, or is dropped if that would be the next day.
28. **Recurring vratams use the tithi at sunrise (udaya tithi)** for notifications, so a tithi that spans two civil days is announced once. Today's card still lists every tithi touching the day.
29. **Schedule window is 7 days**, re-planned on every app open/resume and on any change. A missed day is only known on the day the app re-plans; if the app is not opened, the next mornings carry the ordinary check-in wording.
30. **Notifications are in the primary language only** (no second line in the other script), to keep them short on the lock screen.
31. **Battery optimisation:** no plugin opens the exemption screen; Settings explains once how to set battery use to Unrestricted. Exact alarms use SCHEDULE_EXACT_ALARM with a button; without it reminders are inexact. Android/iOS scheduling is configured but not yet run on a device in this environment.
32. **Live synchronized moments (Makara Jyothi aarti) need FCM**, which is not wired yet; the local peak-day invitation names the live aarti time.
