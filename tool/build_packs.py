#!/usr/bin/env python3
"""Generates the bundled base content packs in assets/packs/.

Source of truth for Phase A pack data. Re-run after editing:
    python3 tool/build_packs.py
Texts are public-domain stotras; sample portions only where marked
complete=false (see ASSETS_TODO.md).
"""
import json, os, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent / "assets" / "packs"
DATE = "2026-11-27"

def L(en, te, **more):
    d = {"en": en, "te": te}; d.update(more); return d

def write(rel, obj):
    p = ROOT / rel
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(obj, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

# --------------------------------------------------------------- upacharas
# id: (title, instruction, mantra-suffix, action, target, autoSec)
U = {
 "sankalpam": (L("Sankalpam", "సంకల్పం"), L("Hold akshatas in your right palm and listen to your Sankalpam.", "కుడి అరచేతిలో అక్షతలు పట్టుకుని మీ సంకల్పం వినండి."), None, "tap", 1, 25),
 "dhyanam":   (L("Dhyanam", "ధ్యానం"), L("Fold your hands and meditate on the form of the Lord.", "చేతులు జోడించి స్వామి రూపాన్ని ధ్యానించండి."), L("dhyayami", "ధ్యాయామి"), "tap", 1, 15),
 "avahanam":  (L("Avahanam", "ఆవాహనం"), L("Invite the Lord into the sanctum. Tap the idol.", "స్వామిని ఆహ్వానించండి. విగ్రహాన్ని తాకండి."), L("avahayami", "ఆవాహయామి"), "tap", 1, 8),
 "asanam":    (L("Asanam", "ఆసనం"), L("Offer a seat. Tap the peetham.", "ఆసనం సమర్పించండి. పీఠాన్ని తాకండి."), L("asanam samarpayami", "ఆసనం సమర్పయామి"), "tap", 1, 6),
 "padyam":    (L("Padyam", "పాద్యం"), L("Offer water to wash the Lord's feet.", "పాదాలకు జలం సమర్పించండి."), L("padyam samarpayami", "పాద్యం సమర్పయామి"), "tap", 1, 6),
 "arghyam":   (L("Arghyam", "అర్ఘ్యం"), L("Offer water to the hands.", "హస్తాలకు జలం సమర్పించండి."), L("arghyam samarpayami", "అర్ఘ్యం సమర్పయామి"), "tap", 1, 6),
 "achamaniyam": (L("Achamaniyam", "ఆచమనీయం"), L("Offer water for achamanam.", "ఆచమనానికి జలం సమర్పించండి."), L("achamaniyam samarpayami", "ఆచమనీయం సమర్పయామి"), "tap", 1, 6),
 "abhishekam": (L("Abhishekam", "అభిషేకం"), L("Choose the offering and tilt the vessel to pour it over the Lord.", "ద్రవ్యాన్ని ఎంచుకుని పాత్రను వంచి అభిషేకం చేయండి."), L("snapayami", "స్నపయామి"), "pour", 1, 20),
 "vastram":   (L("Vastram", "వస్త్రం"), L("Offer the new cloth. Tap to drape it.", "నూతన వస్త్రం సమర్పించండి."), L("vastram samarpayami", "వస్త్రం సమర్పయామి"), "tap", 1, 6),
 "yagnopavitam": (L("Yagnopavitam", "యజ్ఞోపవీతం"), L("Offer the sacred thread.", "యజ్ఞోపవీతం సమర్పించండి."), L("yagnopavitam samarpayami", "యజ్ఞోపవీతం సమర్పయామి"), "tap", 1, 6),
 "gandham":   (L("Gandham", "గంధం"), L("Apply sandal paste and kumkum. Tap the forehead of the idol.", "గంధం, కుంకుమ అలంకరించండి."), L("gandham samarpayami", "గంధం సమర్పయామి"), "tap", 1, 6),
 "pushpam":   (L("Pushpam", "పుష్పం"), L("Shower flowers: swipe up three times.", "పుష్పాలు సమర్పించండి: మూడుసార్లు పైకి స్వైప్ చేయండి."), L("pushpaih pujayami", "పుష్పైః పూజయామి"), "shower", 3, 12),
 "dhoopam":   (L("Dhoopam", "ధూపం"), L("Wave the incense: draw three circles.", "ధూపం: మూడు వలయాలు గీయండి."), L("dhoopam aaghrapayami", "ధూపం ఆఘ్రాపయామి"), "drag_circle", 3, 10),
 "deepam":    (L("Deepam", "దీపం"), L("Light the deepam. Tap the wick.", "దీపం వెలిగించండి. వత్తిని తాకండి."), L("deepam darshayami", "దీపం దర్శయామి"), "tap", 1, 8),
 "naivedyam": (L("Naivedyam", "నైవేద్యం"), L("Place the naivedyam before the Lord.", "నైవేద్యం సమర్పించండి."), L("naivedyam samarpayami", "నైవేద్యం సమర్పయామి"), "tap", 1, 10),
 "tambulam":  (L("Tambulam", "తాంబూలం"), L("Offer betel leaves and nuts.", "తాంబూలం సమర్పించండి."), L("tambulam samarpayami", "తాంబూలం సమర్పయామి"), "tap", 1, 6),
 "coconut":   (L("Coconut", "కొబ్బరికాయ"), L("Break the coconut: swipe down firmly.", "కొబ్బరికాయ కొట్టండి: గట్టిగా కిందికి స్వైప్ చేయండి."), L("narikelam samarpayami", "నారికేళం సమర్పయామి"), "swipe_down", 1, 6),
 "bell":      (L("Ghanta", "ఘంటానాదం"), L("Ring the bell: shake your phone (or tap the bell).", "గంట మోగించండి: ఫోన్ ఊపండి (లేదా గంటను తాకండి)."), None, "shake", 3, 5),
 "shankh":    (L("Shankha Nadam", "శంఖనాదం"), L("Blow into the microphone, or press and hold the shankh.", "మైక్‌లోకి ఊదండి లేదా శంఖాన్ని నొక్కి పట్టుకోండి."), None, "blow", 1, 6),
 "aarti":     (L("Nirajanam", "నీరాజనం"), L("Wave the aarti plate in three clockwise circles.", "హారతి పళ్ళెంతో మూడు సవ్య వలయాలు తిప్పండి."), L("nirajanam samarpayami", "నీరాజనం సమర్పయామి"), "drag_circle", 3, 20),
 "mantrapushpam": (L("Mantrapushpam", "మంత్రపుష్పం"), L("Offer flowers with folded hands.", "చేతులు జోడించి మంత్రపుష్పం సమర్పించండి."), L("mantrapushpam samarpayami", "మంత్రపుష్పం సమర్పయామి"), "shower", 1, 15),
 "pradakshina": (L("Pradakshina", "ప్రదక్షిణ"), L("Walk around the Lord three times: swipe around the sanctum.", "మూడు ప్రదక్షిణలు: గర్భగుడి చుట్టూ స్వైప్ చేయండి."), L("pradakshina namaskaran samarpayami", "ప్రదక్షిణ నమస్కారాన్ సమర్పయామి"), "walk_around", 3, 15),
 "namaskaram": (L("Namaskaram", "నమస్కారం"), L("Bow down and offer your prayer.", "సాష్టాంగ నమస్కారం చేసి ప్రార్థించండి."), L("namaskaromi", "నమస్కరోమి"), "tap", 1, 10),
 "closing":   (L("Closing", "ముగింపు"), L("Receive the Lord's blessings.", "స్వామి ఆశీస్సులు స్వీకరించండి."), None, "none", 1, 30),
}

LENGTHS = {
 "nitya5":  (L("5-min Nitya Pooja", "5 నిమిషాల నిత్య పూజ"), 5,
             ["sankalpam", "bell", "deepam", "pushpam", "naivedyam", "aarti", "namaskaram", "closing"]),
 "nitya15": (L("15-min Pooja", "15 నిమిషాల పూజ"), 15,
             ["sankalpam", "dhyanam", "bell", "abhishekam", "gandham", "pushpam", "dhoopam", "deepam",
              "naivedyam", "coconut", "aarti", "shankh", "pradakshina", "namaskaram", "closing"]),
 "shodasha": (L("Shodashopachara Pooja", "షోడశోపచార పూజ"), 35,
             ["sankalpam", "dhyanam", "bell", "avahanam", "asanam", "padyam", "arghyam", "achamaniyam",
              "abhishekam", "vastram", "yagnopavitam", "gandham", "pushpam", "dhoopam", "deepam",
              "naivedyam", "tambulam", "coconut", "aarti", "shankh", "mantrapushpam", "pradakshina",
              "namaskaram", "closing"]),
}

def pooja(deity, pid):
    name, mins, ids = LENGTHS[pid]
    steps = []
    for u in ids:
        title, instr, suffix, action, target, auto = U[u]
        mantra = {"en": "", "te": ""}
        if u == "dhyanam":
            mantra = deity["dhyana"]
        elif suffix:
            mantra = {"en": f'{deity["mantra"]["en"]} — {suffix["en"]}', "te": f'{deity["mantra"]["te"]} {suffix["te"]}'}
        st = {"upachara": u, "title": title, "instruction": instr, "mantra": mantra,
              "voice": f"placeholder://audio/voiceguide/{u}", "action": action, "target": target,
              "autoDurationSec": auto}
        if u == "abhishekam":
            st["options"] = deity["liquids"]
        steps.append(st)
    return {"id": pid, "name": name, "lengthMin": mins, "steps": steps}

DEITIES = [
 dict(id="ayyappa", name=L("Swamy Ayyappa", "స్వామి అయ్యప్ప", ta="சுவாமி ஐயப்பன்", ml="സ്വാമി അയ്യപ്പൻ"),
      epithet=L("Hariharasutha, Dharma Sastha", "హరిహరసుతుడు, ధర్మశాస్త"),
      greeting=L("Swamiye Saranam Ayyappa", "స్వామియే శరణం అయ్యప్ప", ta="சுவாமியே சரணம் ஐயப்பா", ml="സ്വാമിയേ ശരണം അയ്യപ്പാ"),
      weekdays=[6], colors={"primary": "#1B1A3A", "accent": "#D4AF37"}, glyph="అ",
      mantra=L("Om Sri Dharma Sasthre Namaha", "ఓం శ్రీ ధర్మశాస్త్రే నమః"),
      dhyana=L("Bhutanatha sadananda sarvabhuta dayapara, raksha raksha mahabaho shastre tubhyam namo namah",
               "భూతనాథ సదానంద సర్వభూత దయాపర । రక్ష రక్ష మహాబాహో శాస్త్రే తుభ్యం నమో నమః ॥"),
      liquids=["water", "milk", "panchamrutam", "ghee"],
      closing={"type": "curtains", "audio": "placeholder://audio/ayyappa/harivarasanam",
               "name": L("Harivarasanam — Nada closes", "హరివరాసనం — నడ మూసివేత")},
      alankarams=[{"id": "daily", "name": L("Daily", "నిత్య")}, {"id": "mandala", "name": L("Mandala Kalam", "మండల కాలం"), "season": "ayyappa_mandala_2026"},
                  {"id": "thiruvabharanam", "name": L("Thiruvabharanam (Makaravilakku)", "తిరువాభరణం (మకరవిళక్కు)"), "season": "ayyappa_mandala_2026"}],
      peaks=[{"id": "makara_jyothi_2027", "name": L("Makara Jyothi", "మకర జ్యోతి"), "startsAt": "2027-01-14T18:30:00+05:30", "durationMin": 45}],
      chantings=["ayyappa_saranam_108", "harivarasanam"], stotras=["ayyappa_saranam_108", "harivarasanam", "maladharana_mantram"],
      bhajans=["ayyappa_saranaghosham", "ayyappa_padi_ghosham", "ayyappa_swamy_namavali"]),
 dict(id="ganapathy", name=L("Sri Ganapathy", "శ్రీ గణపతి"), epithet=L("Vighneswara", "విఘ్నేశ్వరుడు"),
      greeting=L("Om Gam Ganapataye Namaha", "ఓం గం గణపతయే నమః"), weekdays=[3], colors={"primary": "#7A2E0E", "accent": "#E39B2D"}, glyph="గ",
      mantra=L("Om Sri Mahaganadhipataye Namaha", "ఓం శ్రీ మహాగణాధిపతయే నమః"),
      dhyana=L("Shuklambaradharam vishnum shashivarnam chaturbhujam, prasanna vadanam dhyayet sarva vighnopashantaye",
               "శుక్లాంబరధరం విష్ణుం శశివర్ణం చతుర్భుజమ్ । ప్రసన్నవదనం ధ్యాయేత్ సర్వవిఘ్నోపశాంతయే ॥"),
      liquids=["water", "milk", "panchamrutam"], closing={"type": "aarti", "audio": "placeholder://audio/ganapathy/mangala_aarti", "name": L("Mangala Aarti", "మంగళ హారతి")},
      alankarams=[{"id": "daily", "name": L("Daily", "నిత్య")}], peaks=[], chantings=["vishnu_sahasranamam"], stotras=[], bhajans=[]),
 dict(id="shiva", name=L("Lord Shiva", "శ్రీ శివుడు"), epithet=L("Parameswara", "పరమేశ్వరుడు"),
      greeting=L("Om Namah Shivaya", "ఓం నమః శివాయ"), weekdays=[1], colors={"primary": "#22313F", "accent": "#C9A227"}, glyph="శి",
      mantra=L("Om Namah Shivaya", "ఓం నమః శివాయ"),
      dhyana=L("Dhyayen nityam mahesham rajatagiri nibham charu chandravatamsam",
               "ధ్యాయేన్నిత్యం మహేశం రజతగిరినిభం చారుచంద్రావతంసం"),
      liquids=["water", "milk", "panchamrutam", "bilva_water"], closing={"type": "aarti", "audio": "placeholder://audio/shiva/aarti", "name": L("Mangala Aarti", "మంగళ హారతి")},
      alankarams=[{"id": "daily", "name": L("Daily", "నిత్య")}], peaks=[], chantings=[], stotras=[], bhajans=[]),
 dict(id="venkateswara", name=L("Sri Venkateswara", "శ్రీ వేంకటేశ్వరుడు"), epithet=L("Srinivasa, Govinda", "శ్రీనివాసుడు, గోవిందుడు"),
      greeting=L("Om Namo Venkatesaya", "ఓం నమో వేంకటేశాయ"), weekdays=[3, 6], colors={"primary": "#3B1E54", "accent": "#D4AF37"}, glyph="వేం",
      mantra=L("Om Namo Venkatesaya", "ఓం నమో వేంకటేశాయ"),
      dhyana=L("Shantakaram bhujagashayanam padmanabham suresham", "శాంతాకారం భుజగశయనం పద్మనాభం సురేశం"),
      liquids=["water", "milk", "panchamrutam"], closing={"type": "aarti", "audio": "placeholder://audio/venkateswara/aarti", "name": L("Mangala Aarti", "మంగళ హారతి")},
      alankarams=[{"id": "daily", "name": L("Daily", "నిత్య")}, {"id": "rama", "name": L("Sri Rama", "శ్రీ రామ")}, {"id": "krishna", "name": L("Sri Krishna", "శ్రీ కృష్ణ")}, {"id": "satyanarayana", "name": L("Satyanarayana", "సత్యనారాయణ")}],
      peaks=[], chantings=["vishnu_sahasranamam"], stotras=["vishnu_sahasranamam"], bhajans=[]),
 dict(id="lakshmi", name=L("Sri Mahalakshmi", "శ్రీ మహాలక్ష్మి"), epithet=L("Sri Devi", "శ్రీదేవి"),
      greeting=L("Om Sri Mahalakshmyai Namaha", "ఓం శ్రీ మహాలక్ష్మ్యై నమః"), weekdays=[5], colors={"primary": "#7B1A3A", "accent": "#E8B84A"}, glyph="ల",
      mantra=L("Om Sri Mahalakshmyai Namaha", "ఓం శ్రీ మహాలక్ష్మ్యై నమః"),
      dhyana=L("Padmasana padmakare sarva lokaika pujite", "పద్మాసనే పద్మకరే సర్వలోకైక పూజితే"),
      liquids=["water", "milk", "panchamrutam"], closing={"type": "aarti", "audio": "placeholder://audio/lakshmi/aarti", "name": L("Mangala Aarti", "మంగళ హారతి")},
      alankarams=[{"id": "daily", "name": L("Daily", "నిత్య")}], peaks=[], chantings=["lalitha_sahasranamam"], stotras=[], bhajans=[]),
 dict(id="durga", name=L("Sri Durga Devi", "శ్రీ దుర్గాదేవి"), epithet=L("Kanaka Durga, Lalitha", "కనకదుర్గ, లలిత"),
      greeting=L("Om Sri Durgayai Namaha", "ఓం శ్రీ దుర్గాయై నమః"), weekdays=[5], colors={"primary": "#8B1E1E", "accent": "#E0A526"}, glyph="దు",
      mantra=L("Om Sri Durgayai Namaha", "ఓం శ్రీ దుర్గాయై నమః"),
      dhyana=L("Sarva mangala mangalye shive sarvartha sadhike", "సర్వమంగళ మాంగల్యే శివే సర్వార్థ సాధికే"),
      liquids=["water", "milk", "panchamrutam", "turmeric_water"], closing={"type": "aarti", "audio": "placeholder://audio/durga/aarti", "name": L("Mangala Aarti", "మంగళ హారతి")},
      alankarams=[{"id": "daily", "name": L("Daily", "నిత్య")}], peaks=[], chantings=["lalitha_sahasranamam"], stotras=["lalitha_sahasranamam"], bhajans=[]),
 dict(id="hanuman", name=L("Sri Hanuman", "శ్రీ ఆంజనేయస్వామి"), epithet=L("Anjaneya, Maruti", "ఆంజనేయుడు, మారుతి"),
      greeting=L("Jai Sri Ram, Jai Hanuman", "జై శ్రీరామ్, జై హనుమాన్"), weekdays=[2, 6], colors={"primary": "#8A2D0A", "accent": "#F08A24"}, glyph="హ",
      mantra=L("Om Sri Anjaneyaya Namaha", "ఓం శ్రీ ఆంజనేయాయ నమః"),
      dhyana=L("Manojavam maruta tulya vegam jitendriyam buddhimatam varishtam", "మనోజవం మారుత తుల్యవేగం జితేంద్రియం బుద్ధిమతాం వరిష్ఠమ్"),
      liquids=["water", "milk", "sindoor_oil"], closing={"type": "aarti", "audio": "placeholder://audio/hanuman/aarti", "name": L("Mangala Aarti", "మంగళ హారతి")},
      alankarams=[{"id": "daily", "name": L("Daily", "నిత్య")}], peaks=[], chantings=["hanuman_chalisa"], stotras=["hanuman_chalisa"], bhajans=[]),
 dict(id="subrahmanya", name=L("Sri Subrahmanya", "శ్రీ సుబ్రహ్మణ్యస్వామి"), epithet=L("Kartikeya, Murugan", "కార్తికేయుడు, షణ్ముఖుడు"),
      greeting=L("Om Saravanabhava", "ఓం శరవణభవ"), weekdays=[2], colors={"primary": "#5A1A0E", "accent": "#D98E04"}, glyph="సు",
      mantra=L("Om Sri Subrahmanyaya Namaha", "ఓం శ్రీ సుబ్రహ్మణ్యాయ నమః"),
      dhyana=L("Shadananam kumkuma raktavarnam mahamatim divya mayura vahanam", "షడాననం కుంకుమ రక్తవర్ణం మహామతిం దివ్య మయూర వాహనమ్"),
      liquids=["water", "milk", "panchamrutam"], closing={"type": "aarti", "audio": "placeholder://audio/subrahmanya/aarti", "name": L("Mangala Aarti", "మంగళ హారతి")},
      alankarams=[{"id": "daily", "name": L("Daily", "నిత్య")}], peaks=[], chantings=[], stotras=[], bhajans=[]),
]

for d in DEITIES:
    write(f"deities/{d['id']}.json", {
        "schema": "kalpam.deity/1", "id": d["id"], "version": 1, "updatedAt": DATE, "minAppVersion": "1.0.0",
        "name": d["name"], "epithet": d["epithet"], "greeting": d["greeting"], "weekdays": d["weekdays"],
        "colors": d["colors"], "idolGlyph": d["glyph"],
        "art": {"icon": f"placeholder://art/{d['id']}/icon", "hero": f"placeholder://art/{d['id']}/hero"},
        "sanctum": {"sceneId": f"sanctum_{d['id']}", "defaultAlankaram": "daily", "alankarams": d["alankarams"],
                    "closing": d["closing"], "abhishekamLiquids": d["liquids"], "peakEvents": d["peaks"]},
        "poojas": [pooja(d, p) for p in LENGTHS],
        "chantings": d["chantings"], "stotras": d["stotras"], "bhajans": d["bhajans"],
        "status": "complete" if d["id"] == "ayyappa" else "phase_a_minimum",
    })

# --------------------------------------------------------------- stotras
def stotra(sid, title, deities, cat, days, source, lines, complete=False):
    write(f"stotras/{sid}.json", {"schema": "kalpam.stotra/1", "id": sid, "version": 1, "title": title,
        "deityIds": deities, "category": cat, "parayanamDays": days, "source": source, "verifiedBy": None,
        "complete": complete,
        "audio": {"sung": f"placeholder://audio/stotra/{sid}/sung", "learn": f"placeholder://audio/stotra/{sid}/learn"},
        "lines": [{"id": f"l{i+1}", "te": te, "translit": tr, "meaning": m} for i, (te, tr, m) in enumerate(lines)]})

SAR = [
 ("స్వామియే శరణం అయ్యప్ప", "Swamiye saranam Ayyappa", L("Lord, you are my refuge, Ayyappa", "స్వామీ, నీవే నాకు శరణు")),
 ("హరిహర సుతనే శరణం అయ్యప్ప", "Harihara sutane saranam Ayyappa", L("Son of Hari and Hara, my refuge", "హరిహరుల పుత్రుడా, శరణు")),
 ("అన్నదాన ప్రభువే శరణం అయ్యప్ప", "Annadana prabhuve saranam Ayyappa", L("Lord of food-giving, my refuge", "అన్నదాన ప్రభువా, శరణు")),
 ("ఆరియంగావు అయ్యావే శరణం అయ్యప్ప", "Ariyangavu ayyave saranam Ayyappa", L("Lord of Ariyankavu, my refuge", "ఆరియంగావు స్వామీ, శరణు")),
 ("అచ్చన్‌కోవిల్ అరసే శరణం అయ్యప్ప", "Achankovil arase saranam Ayyappa", L("King of Achankovil, my refuge", "అచ్చన్‌కోవిల్ రాజా, శరణు")),
 ("కుళత్తుపుళ బాలకనే శరణం అయ్యప్ప", "Kulathupuzha balakane saranam Ayyappa", L("Child-Lord of Kulathupuzha, my refuge", "కుళత్తుపుళ బాలకా, శరణు")),
 ("ఎరుమేలి శాస్తావే శరణం అయ్యప్ప", "Erumeli sasthave saranam Ayyappa", L("Sastha of Erumeli, my refuge", "ఎరుమేలి శాస్తా, శరణు")),
 ("వావర్ స్వామియే శరణం అయ్యప్ప", "Vavar swamiye saranam Ayyappa", L("Vavar Swamy, my refuge", "వావర్ స్వామీ, శరణు")),
 ("కన్నిమూల గణపతి భగవానే శరణం అయ్యప్ప", "Kannimoola Ganapathi bhagavane saranam Ayyappa", L("Lord Ganapathi of Kannimoola, my refuge", "కన్నిమూల గణపతీ, శరణు")),
 ("మాళికప్పురత్తు మంజమ్మ దేవియే శరణం అయ్యప్ప", "Malikappurathu Manjamma deviye saranam Ayyappa", L("Devi Manjamma of Malikappuram, my refuge", "మాళికప్పురం మంజమ్మ దేవీ, శరణు")),
 ("పదునెట్టాంపడియే శరణం అయ్యప్ప", "Pathinettampadiye saranam Ayyappa", L("The holy eighteen steps, my refuge", "పవిత్ర పదునెట్టాంపడీ, శరణు")),
 ("మకరజ్యోతియే శరణం అయ్యప్ప", "Makarajyothiye saranam Ayyappa", L("The Makara Jyothi, my refuge", "మకరజ్యోతీ, శరణు")),
]
stotra("ayyappa_saranam_108", L("Ayyappa 108 Saranams", "అయ్యప్ప 108 శరణాలు", ta="ஐயப்பன் 108 சரணம்", ml="അയ്യപ്പ 108 ശരണം"), ["ayyappa"], "saranam", [6],
       "Traditional Sabarimala saranaghosham (public domain). Sample of 12; full 108 pending verification.", SAR)
stotra("harivarasanam", L("Harivarasanam", "హరివరాసనం"), ["ayyappa"], "keertana", [],
       "Kumbakudi Kulathur Iyer (1920s, public domain lyric). Recording must be commissioned.", [
 ("హరివరాసనం విశ్వమోహనం", "Harivarasanam vishwamohanam", L("Seated on the lion throne, enchanter of the universe", "సింహాసనాసీనుడు, విశ్వమోహనుడు")),
 ("హరిదధీశ్వరం ఆరాధ్యపాదుకం", "Haridadhiswaram aaradhyapadhukam", L("Lord of all directions, whose sandals are worshipped", "దిక్కులకు అధిపతి, పూజనీయ పాదుకలవాడు")),
 ("అరివిమర్దనం నిత్యనర్తనం", "Arivimardhanam nithyanarthanam", L("Destroyer of enemies, ever dancing", "శత్రు సంహారకుడు, నిత్య నర్తకుడు")),
 ("హరిహరాత్మజం దేవమాశ్రయే", "Hariharathmajam devamashraye", L("I take refuge in the son of Hari and Hara", "హరిహరాత్మజుని ఆశ్రయిస్తున్నాను")),
 ("శరణం అయ్యప్ప స్వామి శరణం అయ్యప్ప", "Saranam Ayyappa swami saranam Ayyappa", L("Refuge, Ayyappa", "శరణం అయ్యప్ప")),
])
stotra("maladharana_mantram", L("Maladharana Mantram", "మాలధారణ మంత్రం"), ["ayyappa"], "mantram", [],
       "Traditional (public domain). Pending pandit verification.", [
 ("జ్ఞానముద్రాం శాస్త్రముద్రాం గురుముద్రాం నమామ్యహం", "Jnanamudram shastramudram gurumudram namamyaham", L("I bow to the mala of wisdom, scripture and the Guru", "జ్ఞాన, శాస్త్ర, గురు ముద్రకు నమస్కారం")),
 ("వనముద్రాం శుద్ధముద్రాం రుద్రముద్రాం నమామ్యహం", "Vanamudram shuddhamudram rudramudram namamyaham", L("To the mala of the forest, of purity, of Rudra", "వన, శుద్ధ, రుద్ర ముద్రకు నమస్కారం")),
 ("శాంతముద్రాం సత్యముద్రాం వ్రతముద్రాం నమామ్యహం", "Shantamudram satyamudram vratamudram namamyaham", L("To the mala of peace, truth and the vow", "శాంతి, సత్య, వ్రత ముద్రకు నమస్కారం")),
 ("శబర్యాశ్రమ సత్యేన ముద్రాం పాతు సదాపి మే", "Shabaryashrama satyena mudram patu sadapi me", L("By the truth of Sabari's abode, may this mala protect me always", "శబరి ఆశ్రమ సత్యంతో ఈ ముద్ర నన్ను కాపాడుగాక")),
 ("గురుదక్షిణయా పూర్వం తస్యానుగ్రహ కారిణే", "Gurudakshinaya purvam tasyanugraha karine", L("Having first offered dakshina to the Guru, for his grace", "గురుదక్షిణ సమర్పించి, ఆయన అనుగ్రహం కొరకు")),
 ("శరణాగత ముద్రాఖ్యం త్వన్ముద్రాం ధారయామ్యహం", "Sharanagata mudrakhyam tvanmudram dharayamyaham", L("I wear your mala, the sign of surrender", "శరణాగత ముద్ర అయిన నీ మాలను ధరిస్తున్నాను")),
])
stotra("vishnu_sahasranamam", L("Vishnu Sahasranamam", "విష్ణు సహస్రనామం"), ["venkateswara"], "sahasranamam", [4, 6],
       "Mahabharata, Anushasana Parva (public domain). Opening portion; full text pending verification.", [
 ("శుక్లాంబరధరం విష్ణుం శశివర్ణం చతుర్భుజమ్", "Shuklambaradharam vishnum shashivarnam chaturbhujam", L("Clad in white, all-pervading, moon-hued, four-armed", "శ్వేత వస్త్రధారి, సర్వవ్యాపి, చంద్రవర్ణుడు, చతుర్భుజుడు")),
 ("ప్రసన్నవదనం ధ్యాయేత్ సర్వవిఘ్నోపశాంతయే", "Prasannavadanam dhyayet sarvavighnopashantaye", L("Meditate on that serene face to remove all obstacles", "ప్రసన్న వదనుని ధ్యానిస్తే విఘ్నాలు తొలగుతాయి")),
 ("ఓం విశ్వం విష్ణుర్వషట్కారో భూతభవ్యభవత్ప్రభుః", "Om vishvam vishnur vashatkaro bhuta bhavya bhavat prabhuh", L("He is the universe, all-pervading, lord of past, future and present", "విశ్వమే ఆయన, సర్వవ్యాపి, త్రికాల ప్రభువు")),
 ("భూతకృద్భూతభృద్భావో భూతాత్మా భూతభావనః", "Bhutakrid bhutabhrid bhavo bhutatma bhutabhavanah", L("Creator and sustainer of beings, their very Self", "జీవుల సృష్టికర్త, పోషకుడు, ఆత్మ")),
 ("పూతాత్మా పరమాత్మా చ ముక్తానాం పరమా గతిః", "Putatma paramatma cha muktanam parama gatih", L("The pure Self, the Supreme Self, final goal of the liberated", "పవిత్రాత్మ, పరమాత్మ, ముక్తుల పరమగతి")),
 ("అవ్యయః పురుషః సాక్షీ క్షేత్రజ్ఞోఽక్షర ఏవ చ", "Avyayah purushah sakshi kshetrajno akshara eva cha", L("Imperishable, the Person, the witness, knower of the field, eternal", "అవ్యయుడు, పురుషుడు, సాక్షి, క్షేత్రజ్ఞుడు, అక్షరుడు")),
])
stotra("lalitha_sahasranamam", L("Lalitha Sahasranamam", "లలితా సహస్రనామం"), ["durga", "lakshmi"], "sahasranamam", [5],
       "Brahmanda Purana (public domain). Opening portion; full text pending verification.", [
 ("ఓం శ్రీమాతా శ్రీమహారాజ్ఞీ శ్రీమత్సింహాసనేశ్వరీ", "Om shrimata shrimaharajni shrimat simhasaneshvari", L("The Divine Mother, the great Empress, Queen of the lion throne", "శ్రీమాత, మహారాజ్ఞి, సింహాసనేశ్వరి")),
 ("చిదగ్నికుండసంభూతా దేవకార్యసముద్యతా", "Chidagnikunda sambhuta devakarya samudyata", L("Born of the fire of consciousness, intent on the gods' purpose", "చిదగ్నికుండం నుండి ఉద్భవించి దేవకార్యానికి ఉద్యుక్తురాలు")),
 ("ఉద్యద్భానుసహస్రాభా చతుర్బాహుసమన్వితా", "Udyadbhanu sahasrabha chaturbahu samanvita", L("Radiant as a thousand rising suns, four-armed", "వేయి ఉదయసూర్యుల కాంతి, చతుర్భుజి")),
 ("రాగస్వరూపపాశాఢ్యా క్రోధాకారాంకుశోజ్జ్వలా", "Ragasvarupa pashadhya krodhakarankushojjvala", L("Holding the noose of love and the shining goad of wrath", "రాగ పాశం, క్రోధ అంకుశం ధరించినది")),
])
stotra("hanuman_chalisa", L("Hanuman Chalisa", "హనుమాన్ చాలీసా"), ["hanuman"], "chalisa", [2, 6],
       "Goswami Tulsidas (16th c., public domain), Awadhi in Telugu script. Opening portion; full 40 chaupais pending verification.", [
 ("శ్రీగురు చరన సరోజ రజ నిజ మను ముకుర సుధారి", "Shri guru charana saroja raja nija manu mukura sudhari", L("With the dust of the Guru's lotus feet I cleanse the mirror of my mind", "గురు పాదధూళితో నా మనస్సు అద్దాన్ని శుభ్రం చేసుకుని")),
 ("బరనఉఁ రఘుబర బిమల జసు జో దాయకు ఫల చారి", "Baranau raghubara bimala jasu jo dayaku phala chari", L("I sing the pure glory of Rama, giver of the four fruits", "నాలుగు ఫలాలనిచ్చే శ్రీరాముని కీర్తిని గానం చేస్తాను")),
 ("బుద్ధిహీన తను జానికే సుమిరౌఁ పవన కుమార", "Buddhihina tanu janike sumirau pavana kumara", L("Knowing myself unwise, I remember the Son of the Wind", "బుద్ధిహీనుడనని తెలిసి పవనకుమారుని స్మరిస్తాను")),
 ("బల బుధి బిద్యా దేహు మోహి హరహు కలేస బికార", "Bala budhi bidya dehu mohi harahu kalesa bikara", L("Grant me strength, wisdom and learning; remove my sorrows and flaws", "బలం, బుద్ధి, విద్య ఇచ్చి నా కష్టాలు తొలగించు")),
 ("జయ హనుమాన జ్ఞాన గుణ సాగర", "Jaya hanumana jnana guna sagara", L("Victory to Hanuman, ocean of wisdom and virtue", "జ్ఞాన గుణ సాగరుడైన హనుమకు జయం")),
 ("జయ కపీస తిహుఁ లోక ఉజాగర", "Jaya kapisa tihun loka ujagara", L("Victory to the Lord of monkeys, who illumines the three worlds", "ముల్లోకాలను ప్రకాశింపజేసే కపీశునికి జయం")),
 ("రామదూత అతులిత బల ధామా", "Ramaduta atulita bala dhama", L("Messenger of Rama, abode of matchless strength", "రామదూత, అసమాన బలధాముడు")),
 ("అంజనిపుత్ర పవనసుత నామా", "Anjaniputra pavanasuta nama", L("Known as Anjani's son and the Son of the Wind", "అంజనీపుత్రుడు, పవనసుతుడు")),
])

# --------------------------------------------------------------- bhajans (traditional chants; audio to be commissioned)
def bhajan(bid, title, deities, lines, seasons, dur):
    write(f"bhajans/{bid}.json", {"schema": "kalpam.bhajan/1", "id": bid, "version": 1, "title": title, "deityIds": deities,
        "language": "te", "artist": "commissioned", "audio": f"placeholder://audio/bhajan/{bid}", "license": None,
        "durationSec": dur, "seasons": seasons,
        "lyrics": [{"te": te, "translit": tr} for te, tr in lines]})

bhajan("ayyappa_saranaghosham", L("Saranaghosham (call and response)", "శరణఘోష"), ["ayyappa"], [
 ("స్వామియే — శరణం అయ్యప్ప", "Swamiye — Saranam Ayyappa"),
 ("హరిహర సుతనే — శరణం అయ్యప్ప", "Harihara sutane — Saranam Ayyappa"),
 ("కలియుగ వరదనే — శరణం అయ్యప్ప", "Kaliyuga varadane — Saranam Ayyappa"),
 ("పంబా వాసనే — శరణం అయ్యప్ప", "Pamba vasane — Saranam Ayyappa"),
 ("శబరిగిరీశనే — శరణం అయ్యప్ప", "Sabarigirisane — Saranam Ayyappa"),
], ["ayyappa_mandala_2026"], 300)
bhajan("ayyappa_padi_ghosham", L("Padi Ghosham — the 18 steps", "పడి ఘోష — పదునెట్టాంపడి"), ["ayyappa"], [
 ("ఒన్నాం తిరుప్పడి శరణం పొన్నయ్యప్పా", "Onnam thiruppadi saranam ponnayyappa"),
 ("రండాం తిరుప్పడి శరణం పొన్నయ్యప్పా", "Randam thiruppadi saranam ponnayyappa"),
 ("మూన్నాం తిరుప్పడి శరణం పొన్నయ్యప్పా", "Moonnam thiruppadi saranam ponnayyappa"),
 ("నాలాం తిరుప్పడి శరణం పొన్నయ్యప్పా", "Nalam thiruppadi saranam ponnayyappa"),
 ("అంజాం తిరుప్పడి శరణం పొన్నయ్యప్పా", "Anjam thiruppadi saranam ponnayyappa"),
], ["ayyappa_mandala_2026"], 360)
bhajan("ayyappa_swamy_namavali", L("Swamy Namavali", "స్వామి నామావళి"), ["ayyappa"], [
 ("ఓం శ్రీ ధర్మశాస్త్రే నమః", "Om Sri Dharma Sasthre Namaha"),
 ("ఓం హరిహర పుత్రాయ నమః", "Om Harihara Putraya Namaha"),
 ("ఓం మణికంఠాయ నమః", "Om Manikanthaya Namaha"),
 ("ఓం భూతనాథాయ నమః", "Om Bhutanathaya Namaha"),
 ("ఓం శబరిగిరీశాయ నమః", "Om Sabarigirishaya Namaha"),
], ["ayyappa_mandala_2026"], 240)

# --------------------------------------------------------------- vratam: Ayyappa Mandala Deeksha
CK = lambda i, en, te: {"id": i, "text": L(en, te)}
write("vratams/ayyappa_mandala.json", {
 "schema": "kalpam.vratam/1", "id": "ayyappa_mandala", "version": 1, "updatedAt": DATE, "deityId": "ayyappa", "kind": "mala",
 "name": L("Ayyappa Mandala Deeksha", "అయ్యప్ప మండల దీక్ష", ta="ஐயப்ப மண்டல விரதம்", ml="അയ്യപ്പ മണ്ഡല വ്രതം"),
 "summary": L("The 41-day mala vratam of discipline, devotion and surrender, culminating in the Sabarimala yatra.",
              "క్రమశిక్షణ, భక్తి, శరణాగతితో కూడిన 41 రోజుల మాల వ్రతం — శబరిమల యాత్రతో పూర్తి."),
 "mala": {"defaultDays": 41, "minDays": 1, "maxDays": 90,
   "morningChecklist": [CK("wake", "Wake before sunrise", "సూర్యోదయానికి ముందే మేల్కొనడం"), CK("bath", "Cold-water bath", "చన్నీటి స్నానం"),
     CK("vibhuti", "Vibhuti / chandanam on forehead", "నుదుట విభూది / చందనం"), CK("pooja", "Morning pooja and Saranaghosham", "ఉదయ పూజ, శరణఘోష"),
     CK("mala", "Mala worn, black or blue clothes", "మాల ధారణ, నలుపు/నీలం వస్త్రాలు")],
   "eveningChecklist": [CK("bath", "Evening bath", "సాయంత్ర స్నానం"), CK("deepam", "Light the deepam", "దీపారాధన"),
     CK("bhajan", "Bhajan or 108 Saranams", "భజన లేదా 108 శరణాలు"), CK("harivarasanam", "Harivarasanam before sleep", "నిద్రకు ముందు హరివరాసనం"),
     CK("food", "Single sattvic meal kept today", "నేడు సాత్విక ఏకభుక్తం")],
   "rules": [L("Observe brahmacharya", "బ్రహ్మచర్యం పాటించాలి"), L("No meat, alcohol, tobacco", "మాంసం, మద్యం, పొగాకు నిషిద్ధం"),
     L("Address every devotee as Swamy", "ప్రతి భక్తుని స్వామీ అని పిలవాలి"), L("Sleep on the floor, walk barefoot where possible", "నేలపై నిద్ర, వీలైనంత చెప్పులు లేకుండా"),
     L("No haircut or shaving during deeksha", "దీక్షలో క్షౌరం చేయరాదు"), L("Avoid anger and harsh words", "కోపం, కఠిన మాటలు వదలాలి")]},
 "samagri": [
   {"id": "mala", "name": L("Tulasi or rudraksha mala", "తులసి / రుద్రాక్ష మాల"), "qty": L("1 (108 beads)", "1 (108 పూసలు)")},
   {"id": "clothes", "name": L("Black / blue / saffron clothes", "నలుపు / నీలం / కాషాయ వస్త్రాలు"), "qty": L("2–3 sets", "2–3 జతలు")},
   {"id": "vibhuti", "name": L("Vibhuti, chandanam, kumkum", "విభూది, చందనం, కుంకుమ")},
   {"id": "camphor", "name": L("Camphor and agarbatti", "కర్పూరం, అగరుబత్తి")},
   {"id": "ghee_lamp", "name": L("Ghee lamp and wicks", "నెయ్యి దీపం, వత్తులు")},
   {"id": "flowers", "name": L("Flowers and tulasi", "పూలు, తులసి")},
   {"id": "coconut", "name": L("Coconuts", "కొబ్బరికాయలు"), "qty": L("2", "2")},
   {"id": "fruits", "name": L("Bananas and fruits", "అరటిపండ్లు, పండ్లు")},
   {"id": "photo", "name": L("Swamy photo or idol", "స్వామి పటం / విగ్రహం"), "optional": True}],
 "fasting": [L("One sattvic meal a day (ekabhuktam); light fruit or milk in the evening.", "రోజుకు ఒకసారి సాత్విక భోజనం; సాయంత్రం పండ్లు లేదా పాలు."),
             L("Food without onion and garlic.", "ఉల్లి, వెల్లుల్లి లేని ఆహారం.")],
 "sankalpam": {"purpose": L("to observe the Mandala Deeksha of Swamy Ayyappa with purity and devotion, and to receive his darshan at Sabarimala",
                           "శ్రీ అయ్యప్ప స్వామి మండల దీక్షను నిష్ఠతో ఆచరించి శబరిమలలో స్వామి దర్శనం పొందుటకు")},
 "vidhanamPoojaId": "shodasha",
 "katha": [
   {"chapter": 1, "title": L("The child of Pampa", "పంబా తీర బాలుడు"), "audio": "placeholder://audio/ayyappa/katha/1",
    "text": L("King Rajasekhara of Pandalam, childless and praying for an heir, was hunting by the river Pampa when he heard a baby crying. He found a radiant child with a golden bell around his neck. A sage told him to raise the boy as his own, and the King named him Manikandan, the one with the bell at his neck.",
              "సంతానం లేని పందళ రాజు రాజశేఖరుడు పంబా నది తీరాన వేటకు వెళ్ళినప్పుడు ఒక శిశువు ఏడుపు విన్నాడు. మెడలో బంగారు గంటతో వెలిగిపోతున్న బాలుని చూశాడు. ఒక ముని సూచనతో ఆ బాలుని తన కుమారునిగా పెంచి మణికంఠుడు అని పేరు పెట్టాడు.")},
   {"chapter": 2, "title": L("The tigress milk", "పులిపాల కథ"), "audio": "placeholder://audio/ayyappa/katha/2",
    "text": L("When the Queen feigned an illness that only tigress milk could cure, young Manikandan went alone into the forest. There he defeated the demoness Mahishi and returned riding a tigress, with the gods following as tigers. The King then understood that his son was divine.",
              "పులిపాలు మాత్రమే నయం చేస్తాయని రాణి అస్వస్థత నటించగా బాల మణికంఠుడు ఒంటరిగా అడవికి వెళ్ళాడు. అక్కడ మహిషిని సంహరించి, పులిపై స్వారీ చేస్తూ, దేవతలు పులులుగా వెంటరాగా తిరిగి వచ్చాడు. తన కుమారుడు దైవస్వరూపుడని రాజు గ్రహించాడు.")},
   {"chapter": 3, "title": L("The temple on Sabarimala", "శబరిమల ఆలయం"), "audio": "placeholder://audio/ayyappa/katha/3",
    "text": L("Manikandan told the King he would dwell on the hill of Sabari, and asked that a temple be built where his arrow fell. He promised to bless every devotee who came after the 41-day vratam, climbing the eighteen holy steps with the irumudi on their head.",
              "తాను శబరి కొండపై నివసిస్తానని, తన బాణం పడిన చోట ఆలయం నిర్మించమని మణికంఠుడు రాజుతో చెప్పాడు. 41 రోజుల వ్రతం చేసి, ఇరుముడి తలపై పెట్టుకుని పదునెట్టాంపడి ఎక్కి వచ్చే ప్రతి భక్తుని అనుగ్రహిస్తానని వాగ్దానం చేశాడు.")}],
 "udyapanam": {"steps": [
   {"upachara": "sankalpam", "title": L("Udyapana Sankalpam", "ఉద్యాపన సంకల్పం"), "instruction": L("Listen to the closing Sankalpam of your deeksha.", "దీక్ష ముగింపు సంకల్పం వినండి."), "action": "tap", "autoDurationSec": 20},
   {"upachara": "aarti", "title": L("Final Nirajanam", "చివరి నీరాజనం"), "instruction": L("Wave the aarti three times.", "మూడుసార్లు హారతి ఇవ్వండి."), "action": "drag_circle", "target": 3, "autoDurationSec": 20},
   {"upachara": "namaskaram", "title": L("Remove the mala", "మాల విసర్జన"), "instruction": L("With your Guruswamy's blessing, remove the mala and offer it to the Lord.", "గురుస్వామి ఆశీస్సులతో మాల తీసి స్వామికి సమర్పించండి."), "action": "tap", "autoDurationSec": 15}],
   "certificateTemplate": "placeholder://art/certificate/ayyappa"},
 "extras": {
   "irumudiFront": [CK("neyy_thenga", "Ghee-filled coconut (Neyy Thenga)", "నెయ్యి కొబ్బరికాయ"), CK("rice", "Raw rice", "బియ్యం"),
     CK("coconuts", "Coconuts", "కొబ్బరికాయలు"), CK("betel", "Betel leaves and nuts", "తమలపాకులు, వక్కలు"), CK("camphor", "Camphor", "కర్పూరం"),
     CK("turmeric", "Turmeric, kumkum, vibhuti", "పసుపు, కుంకుమ, విభూది"), CK("honey", "Honey and jaggery", "తేనె, బెల్లం"),
     CK("kalkandam", "Kalkandam, dry grapes, dates", "కలకండ, కిస్మిస్, ఖర్జూరం"), CK("rose_water", "Rose water", "పన్నీరు"), CK("agarbatti", "Agarbatti", "అగరుబత్తి")],
   "irumudiBack": [CK("food_rice", "Rice for the journey", "ప్రయాణానికి బియ్యం"), CK("padi_coconut", "Coconut to break at the 18 steps", "పదునెట్టాంపడి వద్ద కొట్టే కొబ్బరికాయ"),
     CK("erumeli", "Items for Erumeli Petta Thullal", "ఎరుమేలి పేట తుళ్ళల్ సామగ్రి"), CK("towel", "Towel and spare clothes", "తువాలు, అదనపు బట్టలు")],
   "maladharanaStotra": "maladharana_mantram",
   "virtualQueueUrl": "https://sabarimalaonline.org",
   "sabarimalaFeed": "firestore://sabarimala_live/current",
   "annadanamFeed": "firestore://annadanam"}
})

# --------------------------------------------------------------- flagship calendar
def S(sid, deity, title, subtitle, start, end, peak_id, peak_at, peak_title, fmt="season", days=0, vratam=None,
      prio="hero", quiet=False, live=False, milestones=(), nxt=None, chanting=None, bhajans=()):
    return {"id": sid, "deityId": deity, "vratamId": vratam, "title": title, "subtitle": subtitle, "format": fmt, "malaDays": days,
            "start": start, "end": end, "teaserDays": 30, "priority": prio, "quiet": quiet,
            "peak": {"id": peak_id, "at": peak_at, "title": peak_title, "liveAarti": live},
            "daily": {"kathaFromVratam": vratam is not None, "bhajanSet": list(bhajans), "chanting": chanting},
            "milestones": [{"date": d, "name": n} for d, n in milestones], "next": nxt}

CAL = [
 S("ayyappa_mandala_2026", "ayyappa", L("Ayyappa Mandala Deeksha", "అయ్యప్ప మండల దీక్ష", ta="ஐயப்ப மண்டல விரதம்", ml="അയ്യപ്പ മണ്ഡല വ്രതം"),
   L("41-day mala · Makaravilakku 14 Jan", "41 రోజుల మాల · మకరవిళక్కు జనవరి 14"), "2026-11-16", "2027-01-20",
   "makara_jyothi_2027", "2027-01-14T18:30:00+05:30", L("Makara Jyothi", "మకర జ్యోతి"), "mala", 41, "ayyappa_mandala", live=True,
   milestones=[("2026-12-27", L("Mandala Pooja", "మండల పూజ")), ("2027-01-14", L("Makaravilakku", "మకరవిళక్కు")), ("2027-01-15", L("Makara Sankranti", "మకర సంక్రాంతి"))],
   nxt="shiva_shivratri_2027", chanting="ayyappa_saranam_108", bhajans=["ayyappa_saranaghosham", "ayyappa_padi_ghosham", "ayyappa_swamy_namavali"]),
 S("dhanurmasam_2026", "venkateswara", L("Dhanurmasam", "ధనుర్మాసం"), L("Early-morning Vishnu pooja", "బ్రాహ్మీ ముహూర్త విష్ణు పూజ"),
   "2026-12-16", "2027-01-14", "vaikuntha_ekadashi_2026", "2026-12-20T05:00:00+05:30", L("Vaikuntha Ekadashi", "వైకుంఠ ఏకాదశి"), prio="secondary",
   milestones=[("2026-12-20", L("Vaikuntha Ekadashi", "వైకుంఠ ఏకాదశి")), ("2026-12-22", L("Hanumad Vratam", "హనుమద్వ్రతం"))], chanting="vishnu_sahasranamam"),
 S("shiva_shivratri_2027", "shiva", L("Om Namah Shivaya Mala", "ఓం నమః శివాయ మాల"), L("21-day mala · Maha Shivratri 6 Mar", "21 రోజుల మాల · మహాశివరాత్రి మార్చి 6"),
   "2027-02-14", "2027-03-07", "maha_shivratri_2027", "2027-03-06T18:30:00+05:30", L("Maha Shivratri — 4-jaama pooja", "మహాశివరాత్రి — చతుర్యామ పూజ"), "mala", 21, live=True,
   nxt="rama_hanuman_2027"),
 S("rama_hanuman_2027", "venkateswara", L("Sri Rama Navami Season", "శ్రీరామ నవమి ఉత్సవాలు"), L("Ugadi · Chaitra Navratri · Ramayana parayanam", "ఉగాది · చైత్ర నవరాత్రి · రామాయణ పారాయణం"),
   "2027-04-07", "2027-04-21", "rama_navami_2027", "2027-04-15T12:00:00+05:30", L("Sri Rama Navami", "శ్రీరామ నవమి"),
   milestones=[("2027-04-07", L("Ugadi", "ఉగాది")), ("2027-04-15", L("Sri Rama Navami", "శ్రీరామ నవమి")), ("2027-04-20", L("Hanuman Jayanti", "హనుమాన్ జయంతి"))], nxt="hanuman_telugu_2027"),
 S("hanuman_telugu_2027", "hanuman", L("Hanuman Chalisa Mala", "హనుమాన్ చాలీసా మాల"), L("11-day mala · Hanuman Jayanti 31 May", "11 రోజుల మాల · హనుమాన్ జయంతి మే 31"),
   "2027-05-21", "2027-06-01", "hanuman_jayanti_te_2027", "2027-05-31T07:00:00+05:30", L("Hanuman Jayanti", "హనుమాన్ జయంతి"), "mala", 11, chanting="hanuman_chalisa", nxt="ekadashi_japa_2027"),
 S("ekadashi_japa_2027", "venkateswara", L("Ekadashi & Japa Season", "ఏకాదశి — జప మాసం"), L("108-japa sankalpam · Nirjala Ekadashi", "108 జప సంకల్పం · నిర్జల ఏకాదశి"),
   "2027-06-02", "2027-07-13", "nirjala_ekadashi_2027", "2027-06-14T06:00:00+05:30", L("Nirjala Ekadashi", "నిర్జల ఏకాదశి"), nxt="guru_shravanam_2027"),
 S("guru_shravanam_2027", "venkateswara", L("Guru Purnima", "గురు పౌర్ణమి"), L("Devshayani Ekadashi · Guru Purnima", "తొలి ఏకాదశి · గురు పౌర్ణమి"),
   "2027-07-14", "2027-08-02", "guru_purnima_2027", "2027-07-18T07:00:00+05:30", L("Guru Purnima", "గురు పౌర్ణమి"),
   milestones=[("2027-07-14", L("Tholi Ekadashi", "తొలి ఏకాదశి"))], nxt="lakshmi_shravana_2027"),
 S("lakshmi_shravana_2027", "lakshmi", L("Shravana Masam", "శ్రావణ మాసం"), L("Varalakshmi Vratam · Mangala Gauri", "వరలక్ష్మీ వ్రతం · మంగళగౌరీ"),
   "2027-08-03", "2027-08-31", "varalakshmi_2027", "2027-08-13T09:00:00+05:30", L("Varalakshmi Vratam", "వరలక్ష్మీ వ్రతం"),
   milestones=[("2027-08-25", L("Krishna Janmashtami", "శ్రీకృష్ణ జన్మాష్టమి"))], nxt="ganapathy_2027"),
 S("ganapathy_2027", "ganapathy", L("Ganesh Mala", "గణేశ మాల"), L("Vinayaka Chavithi · 11 days to Nimajjanam", "వినాయక చవితి · 11 రోజుల నిమజ్జనం వరకు"),
   "2027-09-04", "2027-09-14", "ganesh_chaturthi_2027", "2027-09-04T10:00:00+05:30", L("Vinayaka Chavithi", "వినాయక చవితి"), "mala", 11, nxt="devi_navratri_2027",
   milestones=[("2027-09-14", L("Nimajjanam", "నిమజ్జనం"))]),
 S("pitru_paksham_2027", "venkateswara", L("Pitru Paksham — Tarpanam", "పితృ పక్షం — తర్పణం"), L("A quiet seva for our ancestors", "పితృదేవతలకు నిశ్శబ్ద సేవ"),
   "2027-09-16", "2027-09-29", "mahalaya_2027", "2027-09-29T12:00:00+05:30", L("Mahalaya Amavasya", "మహాలయ అమావాస్య"), prio="secondary", quiet=True),
 S("devi_navratri_2027", "durga", L("Devi Navaratrulu", "దేవీ నవరాత్రులు"), L("9-day mala · 9 alankarams · Dasara", "9 రోజుల మాల · 9 అలంకారాలు · దసరా"),
   "2027-09-30", "2027-10-09", "vijayadashami_2027", "2027-10-09T10:00:00+05:30", L("Vijayadashami", "విజయదశమి"), "mala", 9, chanting="lalitha_sahasranamam", nxt="lakshmi_diwali_2027"),
 S("lakshmi_diwali_2027", "lakshmi", L("Deepavali Lakshmi Pooja", "దీపావళి లక్ష్మీ పూజ"), L("Lakshmi Pooja 29 Oct", "లక్ష్మీ పూజ అక్టోబర్ 29"),
   "2027-10-10", "2027-10-29", "diwali_2027", "2027-10-29T18:30:00+05:30", L("Deepavali", "దీపావళి"), live=True, nxt="karthika_2027"),
 S("karthika_2027", "shiva", L("Karthika Masam", "కార్తీక మాసం"), L("Somavarams · 365 wicks · Karthika Pournami", "సోమవారాలు · 365 వత్తులు · కార్తీక పౌర్ణమి"),
   "2027-10-30", "2027-11-16", "karthika_pournami_2027", "2027-11-13T18:00:00+05:30", L("Karthika Pournami", "కార్తీక పౌర్ణమి"), live=True, nxt="ayyappa_mandala_2027"),
 S("ayyappa_mandala_2027", "ayyappa", L("Ayyappa Mandala Deeksha", "అయ్యప్ప మండల దీక్ష"), L("41-day mala · Makaravilakku", "41 రోజుల మాల · మకరవిళక్కు"),
   "2027-11-17", "2028-01-20", "makara_jyothi_2028", "2028-01-15T18:30:00+05:30", L("Makara Jyothi", "మకర జ్యోతి"), "mala", 41, "ayyappa_mandala", live=True,
   chanting="ayyappa_saranam_108", bhajans=["ayyappa_saranaghosham"]),
]
write("flagship/calendar.json", {"schema": "kalpam.flagship/1", "id": "calendar", "version": 1, "updatedAt": DATE, "seasons": CAL,
  "weeklyGods": {"1": ["shiva"], "2": ["hanuman", "subrahmanya"], "3": ["venkateswara"], "4": ["venkateswara"], "5": ["lakshmi", "durga"], "6": ["venkateswara", "hanuman"], "7": ["venkateswara"]},
  "parayanam": {"vishnu_sahasranamam": [4, 6], "lalitha_sahasranamam": [5], "hanuman_chalisa": [2, 6]},
  "recurring": [
    {"id": "ekadashi", "name": L("Ekadashi", "ఏకాదశి"), "tithis": [11, 26], "deityId": "venkateswara"},
    {"id": "sankashti", "name": L("Sankashti Chaturthi", "సంకష్టహర చతుర్థి"), "tithis": [19], "deityId": "ganapathy"},
    {"id": "pradosham", "name": L("Pradosham", "ప్రదోషం"), "tithis": [13, 28], "deityId": "shiva"},
    {"id": "masa_shivratri", "name": L("Masa Shivaratri", "మాస శివరాత్రి"), "tithis": [29], "deityId": "shiva"},
    {"id": "pournami_satyanarayana", "name": L("Pournami Satyanarayana Vratam", "పౌర్ణమి సత్యనారాయణ వ్రతం"), "tithis": [15], "deityId": "venkateswara"}]})

# index
idx = []
for p in sorted(ROOT.rglob("*.json")):
    if p.name == "index.json": continue
    j = json.loads(p.read_text(encoding="utf-8"))
    idx.append({"path": str(p.relative_to(ROOT)), "id": j["id"], "version": j["version"], "schema": j["schema"]})
write("index.json", {"schema": "kalpam.index/1", "id": "index", "version": 1, "packs": idx})
print(f"wrote {len(idx)} packs")
