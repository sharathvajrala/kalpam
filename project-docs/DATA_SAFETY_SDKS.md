# Third-party SDKs in the Kalpam Android build (for Play Data Safety)

Source: `pubspec.lock` and each plugin's `android/build.gradle`, as of 27 Nov 2026.

**No Firebase components** (no Analytics, Crashlytics, Messaging, Auth or Firestore). FCM is Phase B.
No ads SDK, no analytics SDK, no crash reporting SDK.

## Flutter plugins (with Android native code)

| Plugin | Version | Native Android libraries it pulls in | What it touches on device |
|---|---|---|---|
| flutter_local_notifications | 23.0.4 | androidx.core:core 1.19.0, androidx.media:media 1.1.0, com.google.code.gson:gson 2.12.0 | Schedules local reminders. Nothing leaves the device. |
| flutter_tts | 4.2.5 | kotlin-stdlib | Device text-to-speech engine for spoken steps. |
| geolocator (geolocator_android 5.2.1) | 14.1.2 | **com.google.android.gms:play-services-location 21.2.0**, androidx.core 1.16.0 | One-time approximate location to pick the city. Only the city name is stored. |
| speech_to_text | 7.5.0 | none (uses the Android system SpeechRecognizer) | Microphone for Elder Mode voice commands. The device recognizer may be Google's speech service. |
| sensors_plus | 7.1.1 | kotlin-stdlib | Motion sensors (tilt in the sanctum). |
| share_plus | 13.3.1 | androidx.core-ktx 1.16.0, androidx.annotation 1.9.1, kotlinx-coroutines-android 1.11.0 | System share sheet. |
| shared_preferences (android 2.5.5) | 2.5.6 | androidx.datastore 1.2.1, datastore-preferences 1.2.1, androidx.preference 1.2.1 | On-device storage of profile and settings. |
| url_launcher (android 6.3.35) | 6.3.3 | androidx.core 1.17.0, androidx.annotation 1.10.0, androidx.browser 1.9.0 | Opens links in the browser. |
| path_provider_android | 2.3.1 | none | App file paths. |
| package_info_plus | 10.2.2 | none | App version. |
| jni / jni_flutter | 1.2.1 / 1.1.0 | none | Native bridge (transitive). |

## Dart-only packages

cupertino_icons 1.0.9, flutter_localizations (SDK), intl 0.20.3, material_ui 1.11.1, timezone 0.11.2.

## Build-time libraries

- androidx.core:core-ktx 1.19.0 (resolved version, needs compileSdk 37)
- com.android.tools:desugar_jdk_libs 2.1.4 (core library desugaring)
- Flutter engine 3.50.1

## Data Safety notes

- The only Google SDK is Play Services Location. Kalpam requests approximate location once and stores just the city name. Location is not sent to a Kalpam server.
- Microphone and speech: audio goes to the device's speech recognizer only while the mic button is held. Kalpam stores no audio or transcripts.
- The privacy policy (docs/privacy.html) does not mention microphone use yet. It needs a line before submission (page content left unchanged per instructions).
