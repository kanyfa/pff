#!/bin/bash

echo "🚀 Déploiement de l'application Soclose sur mobile Android"
echo "=================================================="

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Ce script doit être exécuté depuis la racine du projet Flutter"
    exit 1
fi

echo "✅ Vérification de l'environnement Flutter..."
flutter doctor

echo ""
echo "📱 Vérification des appareils connectés..."
flutter devices

echo ""
echo "🔧 Nettoyage du projet..."
flutter clean

echo ""
echo "📦 Récupération des dépendances..."
flutter pub get

echo ""
echo "🔍 Analyse du code..."
flutter analyze

echo ""
echo "🏗️  Compilation pour Android..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Compilation réussie !"
    echo ""
    echo "📱 Pour installer sur votre téléphone :"
    echo "1. Activez le mode développeur sur votre téléphone"
    echo "2. Activez le débogage USB"
    echo "3. Connectez votre téléphone à l'ordinateur"
    echo "4. Exécutez : flutter install"
    echo ""
    echo "🎯 Ou lancez directement avec : flutter run"
    echo ""
    echo "📁 APK généré dans : build/app/outputs/flutter-apk/app-release.apk"
else
    echo ""
    echo "❌ Erreur lors de la compilation"
    exit 1
fi
