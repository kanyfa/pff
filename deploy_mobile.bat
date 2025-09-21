@echo off
echo ========================================
echo    DEPLOIEMENT MOBILE - SOCLOSE
echo ========================================
echo.

echo [1/6] Verification de Flutter...
flutter doctor
if %errorlevel% neq 0 (
    echo ERREUR: Flutter n'est pas correctement configure
    pause
    exit /b 1
)

echo.
echo [2/6] Nettoyage du projet...
flutter clean

echo.
echo [3/6] Installation des dependances...
flutter pub get

echo.
echo [4/6] Construction de l'APK de release...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ERREUR: Echec de la construction de l'APK
    pause
    exit /b 1
)

echo.
echo [5/6] APK construit avec succes!
echo L'APK se trouve dans: build\app\outputs\flutter-apk\app-release.apk

echo.
echo [6/6] Installation sur l'appareil connecte...
flutter install --release
if %errorlevel% neq 0 (
    echo ATTENTION: Impossible d'installer automatiquement
    echo Installez manuellement l'APK depuis: build\app\outputs\flutter-apk\app-release.apk
)

echo.
echo ========================================
echo    DEPLOIEMENT TERMINE AVEC SUCCES!
echo ========================================
echo.
echo L'application Soclose est maintenant installee sur votre appareil.
echo.
pause


