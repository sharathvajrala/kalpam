# Kalpam Android release signing (Play internal testing)

Package: **com.kalpamapp.kalpam**. The upload keystore is created and kept by Sharath only. It is **never committed**: `.gitignore` blocks `*.jks`, `*.keystore`, `*.p12` and `android/key.properties`.

Kalpam uses **Play App Signing**: Google holds the app signing key; you sign each upload with your own *upload key*. If the upload key is ever lost, Play can reset it, so the app is never stranded.

## 1. Create the upload key (once, on your computer)

macOS / Linux (needs a JDK, e.g. from Android Studio):

```sh
keytool -genkeypair -v \
  -keystore ~/kalpam-upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias kalpam-upload \
  -dname "CN=Kalpam, O=Kalpam, C=IN"
```

Windows (PowerShell):

```powershell
keytool -genkeypair -v -keystore $env:USERPROFILE\kalpam-upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias kalpam-upload -dname "CN=Kalpam, O=Kalpam, C=IN"
```

It asks for a keystore password (and a key password; use the same one). Store the `.jks` file and the password in your password manager plus one offline backup. Do not email it, and do not put it in the repo or in project files.

## 2. Sign builds

**Option A — on your computer.** Create `android/key.properties` (ignored by git):

```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=kalpam-upload
storeFile=/Users/you/kalpam-upload-keystore.jks
```

Then build:

```sh
flutter build appbundle --release
# -> build/app/outputs/bundle/release/app-release.aab
```

**Option B — GitHub Actions (`.github/workflows/android.yml`).** In the repo: Settings → Secrets and variables → Actions → New repository secret, add:

| Secret | Value |
|---|---|
| `UPLOAD_KEYSTORE_BASE64` | output of `base64 -i ~/kalpam-upload-keystore.jks` (macOS) or `base64 -w0 ~/kalpam-upload-keystore.jks` (Linux) |
| `UPLOAD_KEYSTORE_PASSWORD` | the keystore password |
| `UPLOAD_KEY_ALIAS` | `kalpam-upload` |
| `UPLOAD_KEY_PASSWORD` | the key password |

Every push to `main` then runs analyze + tests and produces a signed `app-release.aab` and an installable `app-release.apk` under the run's **Artifacts**. Without the secrets the build is debug-signed and Play will refuse it (by design).

## 3. Play Console: first upload with Play App Signing

1. Play Console → **Create app**: name *Kalpam*, default language Telugu or English, App, Free. Accept the declarations.
2. **Testing → Internal testing → Create new release.**
3. When asked about app signing, choose **Use Google-generated key** (Play App Signing, the default). Your keystore from step 1 becomes the upload key automatically when you upload the first signed AAB.
4. Upload `app-release.aab`. The package name `com.kalpamapp.kalpam` is fixed from this moment.
5. Release name, e.g. `1.0.0 (Phase A internal)`; add notes; **Save → Review release → Start rollout to Internal testing**.
6. **Testers** tab: create an email list (up to 100 testers), save, and copy the opt-in link for them.
7. Complete the required **App content** items before wider testing: Privacy policy URL (kalpamapp.com), Data safety (everything on-device by default; no account needed; no ads), Content rating, Target audience, App access (no login needed).

## 4. First on-device run checklist (Phase A)

- Onboarding: language → Elder Mode choice → god → name/gotram/city → reminder times; the notification permission is asked once.
- Settings → Notifications: "Coming up" lists the next pushes; on Android tap "Allow exact timing" once.
- Leave the phone until the next sunrise: the Subhodayam push arrives; tap opens Today.
- Mark the morning ritual done: its reminder disappears from "Coming up".
- Join the Mandala Deeksha from the hero: days asked (41), check-in time; next morning brings "Day N of M".
- Start a pooja: no notification arrives during it.
- Elder Mode: mic button → say "పూజ" / "Bhajans".
- Watch Mode Ayyappa pooja start to finish; shake for the bell, blow for the shankh.
