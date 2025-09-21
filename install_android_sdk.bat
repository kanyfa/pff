@echo off
chcp 65001 >nul
echo 🚀 Installation du SDK Android pour Flutter
echo =============================================

REM Vérifier si Android Studio est installé
if exist "C:\Program Files\Android\Android Studio\bin\studio64.exe" (
    echo ✅ Android Studio trouvé
) else (
    echo ❌ Android Studio non trouvé dans le chemin par défaut
    echo Veuillez installer Android Studio depuis : https://developer.android.com/studio
    pause
    exit /b 1
)

REM Vérifier si le SDK est déjà installé
set "SDK_PATH=%LOCALAPPDATA%\Android\Sdk"
if exist "%SDK_PATH%" (
    echo ✅ SDK Android trouvé dans : %SDK_PATH%
) else (
    echo ❌ SDK Android non trouvé
    echo Création du répertoire...
    mkdir "%SDK_PATH%" 2>nul
)

REM Définir les variables d'environnement
echo 🔧 Configuration des variables d'environnement...

REM ANDROID_HOME
setx ANDROID_HOME "%SDK_PATH%"

REM Ajouter au PATH
setx PATH "%PATH%;%SDK_PATH%\platform-tools;%SDK_PATH%\tools;%SDK_PATH%\tools\bin"

echo ✅ Variables d'environnement configurées

echo.
echo 📋 Instructions pour finaliser l'installation :
echo 1. Ouvrez Android Studio
echo 2. Allez dans Tools ^> SDK Manager
echo 3. Dans 'SDK Platforms', cochez :
echo    - Android 14.0 (API 34)
echo    - Android 13.0 (API 33)
echo 4. Dans 'SDK Tools', cochez :
echo    - Android SDK Build-Tools
echo    - Android SDK Command-line Tools
echo    - Android SDK Platform-Tools
echo 5. Cliquez sur 'Apply' et attendez l'installation
echo.
echo 6. Redémarrez votre terminal
echo 7. Vérifiez avec : flutter doctor
echo 8. Acceptez les licences : flutter doctor --android-licenses

echo.
echo 🎯 Après l'installation, vous pourrez déployer votre app sur mobile !
pause

