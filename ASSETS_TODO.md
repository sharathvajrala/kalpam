# ASSETS_TODO — media the app is built around but does not yet have

Every item below has a working placeholder in the app (`placeholder://…` MediaRef). The UI shows a small
"recording coming soon" chip where audio is missing; features never break.

## 3D (Unity, URP, low-poly, baked lighting, ≤25k tris/scene, 1×2048² atlas)
| id | item | needed by | notes |
|---|---|---|---|
| 3d.ayyappa.idol | Ayyappa idol (Yogasana with Chinmudra, patta-bandha) + 3 alankarams (daily, Mandala, Makaravilakku Thiruvabharanam) | Phase A | Stylized, devotional, not photoreal. Needs priest/elder review. |
| 3d.ayyappa.sanctum | Sabarimala-inspired sreekovil, golden roof, 18 steps (Pathinettampadi), Ponnambalamedu hill backdrop for Makara Jyothi | A / B (steps, jyothi) | Do not replicate trademarked TDB imagery. |
| 3d.props | Deepam (oil lamp, live flame shader), aarti plate, bell, shankh, coconut (break anim), abhishekam vessels (water/milk/panchamrutam/ghee), flower particles, naivedyam plates, curtains | A | Shared across all sanctums. |
| 3d.{ganapathy,shiva,venkateswara,lakshmi,durga,hanuman,subrahmanya} | 7 idols + sanctum themes + festival alankarams (Navratri 9-day Devi, Karthika 365-wick deepam, Shivratri 4-jaama) | B | |

## Licensed / commissioned audio (NEVER scraped; each needs a license block in the pack)
| id | item | needed by |
|---|---|---|
| audio.voiceguide.{te,en} | Voice guide prompts for every upachara (≈40 lines × 2 langs), Sankalpam TTS voice or recorded segments | A |
| audio.ayyappa.harivarasanam | Harivarasanam (closing) — commissioned recording, not the K.J. Yesudas version | A |
| audio.ayyappa.saranam108 | Ayyappa 108 Saranams (sung + slow learn) | A |
| audio.ayyappa.bhajans | 8–12 Ayyappa bhajans with lyrics and cue points | A |
| audio.stotra.vishnu_sahasranamam | sung + learn, cue points per line | A |
| audio.stotra.lalitha_sahasranamam | sung + learn | A |
| audio.stotra.hanuman_chalisa | sung + learn | A |
| audio.sfx | bell, shankh, coconut crack, curtain, temple ambience loops (can be CC0 / recorded) | A |
| audio.{deity}.suprabhatam / ashtottaram / signature chanting | for 7 other gods | B |
| audio.stotra.* | Remaining canon (Shiva Sahasranamam, Aditya Hridayam, Kanakadhara, Lingashtakam, Bilvashtakam, Rama Raksha, Bajrang Baan, Sankatmochan, Durga Saptashati, Soundarya Lahari selections, Govinda Namalu) | B |

## Texts (public domain, but need verification by a pandit before launch)
| id | item | status |
|---|---|---|
| text.ayyappa.saranam108 | Telugu + translit + meaning | **Partial sample in pack; full verified text needed** |
| text.harivarasanam | full 8 verses | **Sample in pack; verify** |
| text.vishnu_sahasranamam / lalitha_sahasranamam | full 1000 names + dhyanam + phalasruti | **Opening lines only in pack; full verified text needed** |
| text.hanuman_chalisa | Telugu script of Awadhi original + translit + meaning | **Sample; verify** |
| text.ayyappa.katha | Ayyappa katha chapters mapped to 41 days | Needed (we have chapter structure + 3 sample chapters) |
| text.sankalpam.template | Telugu Sankalpam template (samvatsara/ayana/ritu/masa/paksha/tithi/vasara) | Built; needs pandit review |

## Images / art
| id | item | needed by |
|---|---|---|
| art.{deity}.icon/card/hero | Deity art for cards (S1 style) | A (Ayyappa), B (others) |
| art.app_icon, store screenshots, feature graphic | | A |
| art.certificate | Udyapanam certificate template | A |

## Data feeds
| id | item | notes |
|---|---|---|
| feed.sabarimala_live | Nada open/closed, current pooja, notices | Needs a source: official TDB notices are manually curated by Kalpam ops into Firestore. No scraping. |
| feed.annadanam | Annadanam locations + live serving status | Crowd/organiser submitted, moderated |
| data.temples | Ayyappa temples + Padi Pooja schedule | Curated |
