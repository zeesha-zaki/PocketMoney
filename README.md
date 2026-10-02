# PocketVault
Offline-first pocket money tracker (Flutter, Hive). Currency: PKR.

Push to GitHub `main`/`master` → Actions builds the APK → download **PocketVault-APK** from the run's Artifacts.
The workflow runs `flutter create . --platforms=android` automatically if the `android/` folder is missing.

Local: `flutter create . --platforms=android && flutter pub get && flutter run`
