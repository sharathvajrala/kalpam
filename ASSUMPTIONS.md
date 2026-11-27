# ASSUMPTIONS — choices made without explicit confirmation

Each item is a decision Sharath may want to overrule.

1. **Truncated spec.** About 9,500 characters of the spec (architecture rules 6+ and whatever sat between them and the HOME section) did not arrive. Everything below that point and above it was followed. Asked Sharath to resend.
2. **UI sample images** were not attached. The design system follows the written design language (ivory #FAF5EC, maroon #5E1224, gold #C9A227/#D4AF37, saffron) until they arrive.
3. **Ayyappa Mandala start date:** season config uses 16 Nov 2026 (Vrischikam 1, Mandala start), Mandala Puja 27 Dec 2026, Makaravilakku 14 Jan 2027 18:30 IST. A user's own deeksha can start any date (1–90 days, default 41).
4. **Unity as a library** for 3D (see ARCHITECTURE.md). Requires Unity licence (Personal is fine below USD 200k revenue).
5. **Firebase** over Supabase.
6. **Panchangam method:** amanta month naming (Telugu tradition), Lahiri ayanamsa, values "at sunrise" for the day's tithi/nakshatra (udaya tithi), sunrise = upper limb with standard refraction (−0.833°). Rahu Kalam = 8 equal parts of daytime using the standard weekday order.
7. **Default city** = Hyderabad until the user picks one; no location permission at first launch.
8. **Sankalpam** uses the Telugu (Shalivahana, 60-year samvatsara) template; samvatsara for 2026-27 = Parabhava (Ugadi 2026 → Ugadi 2027), Plavanga from Ugadi 7 Apr 2027.
9. **Weekly god days:** Sunday (not listed in the spec) = Surya / Aditya Hridayam, matching the parayanam habit loop.
10. **Text content in bundled packs is a sample** (opening portions) until verified full texts are supplied; the player handles full-length items already.
11. **Fonts:** Cormorant Garamond (English serif headings), Noto Serif Telugu (Telugu headings), Noto Sans Telugu (body). All OFL, bundled for offline use.
12. **State management:** plain ChangeNotifier + InheritedWidget instead of Riverpod/Bloc, to keep dependencies small.
13. **Phase A Groups tab** shows a working intro + sign-in gate; the full groups feature is Phase B as per the build order.
14. **No GitHub repo yet**: work is committed to a local git repo and mirrored to the project files folder.
