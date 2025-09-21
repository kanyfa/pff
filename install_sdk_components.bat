@echo off
echo Installation des composants SDK Android...
echo ========================================

REM V??rifier si sdkmanager est disponible
if exist "C:\Users\hp\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" (
    echo SDK Manager trouve
    echo Installation des composants...
    
    REM Installer les platforms
    "C:\Users\hp\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" "platforms;android-34"
    "C:\Users\hp\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" "platforms;android-33"
    
    REM Installer les build-tools
    "C:\Users\hp\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" "build-tools;34.0.0"
    "C:\Users\hp\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" "build-tools;33.0.2"
    
    REM Installer les platform-tools
    "C:\Users\hp\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools"
    
    echo Installation terminee !
    pause
) else (
    echo SDK Manager non trouve
    echo Veuillez installer Android Studio et configurer le SDK
    pause
)
