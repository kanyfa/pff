# 🚀 Guide Rapide : Installation du SDK Android

## 📱 Pourquoi installer le SDK Android ?

Pour déployer votre application Flutter sur un téléphone Android, vous devez avoir le SDK Android installé sur votre ordinateur.

## 🛠️ Méthodes d'installation

### Option 1 : Scripts automatiques (Recommandé)
- **PowerShell** : `install_android_sdk.ps1`
- **Batch** : `install_android_sdk.bat`

Double-cliquez sur l'un de ces fichiers pour lancer l'installation automatique.

### Option 2 : Installation manuelle

#### 1. Télécharger Android Studio
- Allez sur : https://developer.android.com/studio
- Téléchargez et installez Android Studio

#### 2. Configurer le SDK
- Ouvrez Android Studio
- Allez dans **Tools > SDK Manager**
- Dans **SDK Platforms**, cochez :
  - ✅ Android 14.0 (API 34)
  - ✅ Android 13.0 (API 33)
- Dans **SDK Tools**, cochez :
  - ✅ Android SDK Build-Tools
  - ✅ Android SDK Command-line Tools
  - ✅ Android SDK Platform-Tools
- Cliquez sur **Apply** et attendez l'installation

#### 3. Variables d'environnement
- Ouvrez les **Variables d'environnement système**
- Ajoutez `ANDROID_HOME` = `%LOCALAPPDATA%\Android\Sdk`
- Ajoutez au PATH : `%ANDROID_HOME%\platform-tools`

## ✅ Vérification

Après l'installation, redémarrez votre terminal et tapez :

```bash
flutter doctor
```

Vous devriez voir :
```
[✓] Android toolchain - develop for Android devices
    • Android SDK at C:\Users\[USER]\AppData\Local\Android\Sdk
    • Platform android-34, build-tools 34.0.0
    • Java version OpenJDK Runtime Environment
```

## 📱 Déploiement sur mobile

Une fois le SDK installé :

1. **Connectez votre téléphone** en mode développeur
2. **Vérifiez la détection** : `flutter devices`
3. **Lancez l'app** : `flutter run`
4. **Construisez l'APK** : `flutter build apk --release`

## 🆘 En cas de problème

- Vérifiez que Android Studio est bien installé
- Redémarrez votre terminal après l'installation
- Exécutez `flutter doctor --android-licenses` pour accepter les licences
- Vérifiez que les variables d'environnement sont correctes

## 🎯 Prochaines étapes

Après l'installation du SDK, vous pourrez :
- Tester votre app sur votre téléphone
- Construire des APK pour distribution
- Déployer sur le Google Play Store

