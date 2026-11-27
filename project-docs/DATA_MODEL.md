# Kalpam — User data model (approved by Sharath, 27 Nov 2026 — do not expand)

| Field | When | Required | Where it lives |
|---|---|---|---|
| Language | Onboarding step 1 | yes | device |
| Chosen god | Onboarding step 2 | yes | device |
| City (name only) | Onboarding step 3 — GPS one-time detection of nearest listed city, or search | yes (Hyderabad is only a fallback when unset) | device |
| Name | Onboarding step 4 / family profile | yes | device |
| Gotram | Onboarding step 4 / family profile | yes | device |
| Janma nakshatram | Onboarding step 4 / family profile | optional, never blocking | device |
| Morning + evening reminder times | Onboarding step 5 | yes (prefilled 5:30 AM / 6:30 PM) | device |
| Phone / email | Only when joining a Group or opting in to sync (Phase B) | optional | Firebase Auth, after opt-in |

**Family profiles:** several name/gotram(/nakshatram) profiles per device. The active profile is the one spoken in every Sankalpam; switch with one tap from the Today header chips or Settings. One profile always remains.

**Never collected:** contacts, mandatory DOB, ID numbers, payment details (v1), location history or coordinates. GPS is used once to pick the nearest city; only that city id is stored. Old coordinate keys from pre-approval builds are deleted on launch.

**Practice data** (trackers, checklists, joined vratams) is on-device only. Cloud sync starts only after account opt-in (Phase B).

**Settings → Your data:** one-tap **Export** (JSON of everything stored, via the share sheet) and **Delete all** (wipes every key on the device and returns to onboarding).

Code: `lib/core/profile/family_profile.dart`, `lib/app/app_state.dart`, `lib/features/settings/settings_screen.dart`. Tests: `test/app/app_smoke_test.dart` (export has no coordinates/phone/email/DOB; delete-all leaves zero keys).
