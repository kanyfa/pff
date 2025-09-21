# 🚀 Guide de Déploiement Mobile - Soclose

## 📱 Déploiement sur Android

### Prérequis
- Flutter SDK installé
- Android Studio installé
- Un appareil Android ou émulateur

### Étapes de déploiement

1. **Vérifier la configuration**
```bash
flutter doctor
```

2. **Construire l'APK de release**
```bash
flutter build apk --release
```

3. **Installer sur l'appareil**
```bash
flutter install --release
```

4. **Créer un bundle pour Google Play Store**
```bash
flutter build appbundle --release
```

## 🍎 Déploiement sur iOS

### Prérequis
- Mac avec Xcode installé
- Compte développeur Apple
- iPhone ou iPad

### Étapes de déploiement

1. **Construire pour iOS**
```bash
flutter build ios --release
```

2. **Ouvrir dans Xcode**
```bash
open ios/Runner.xcworkspace
```

3. **Configurer le signing dans Xcode**
   - Sélectionner votre équipe de développement
   - Configurer le Bundle Identifier

4. **Archiver et distribuer**
   - Product > Archive
   - Distribuer via App Store Connect

## 🔧 Configuration Firebase

### Android
1. Télécharger `google-services.json` depuis Firebase Console
2. Placer dans `android/app/`
3. Vérifier que le fichier est dans `.gitignore`

### iOS
1. Télécharger `GoogleService-Info.plist` depuis Firebase Console
2. Placer dans `ios/Runner/`
3. Ajouter au projet Xcode

## 📋 Checklist de déploiement

### ✅ Avant le déploiement
- [ ] Tous les tests passent
- [ ] Configuration Firebase correcte
- [ ] Icônes et splash screen configurés
- [ ] Permissions configurées
- [ ] Version mise à jour

### ✅ Android spécifique
- [ ] `android/app/build.gradle` configuré
- [ ] `google-services.json` présent
- [ ] Permissions dans `AndroidManifest.xml`

### ✅ iOS spécifique
- [ ] `Info.plist` configuré
- [ ] `GoogleService-Info.plist` présent
- [ ] Signing configuré dans Xcode

## 🚨 Résolution des problèmes

### Erreur de build Android
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Erreur de build iOS
```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ios --release
```

## 📞 Support

Pour toute question sur le déploiement, consultez la documentation Flutter officielle ou contactez l'équipe de développement.


