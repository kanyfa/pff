# Script pour installer les composants SDK Android manquants
Write-Host "Installation des composants SDK Android manquants..." -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$cmdlineToolsPath = "$sdkPath\cmdline-tools\latest\bin"

Write-Host "SDK Path: $sdkPath" -ForegroundColor Yellow

# Créer la structure des répertoires cmdline-tools
$latestPath = "$sdkPath\cmdline-tools\latest"
if (-not (Test-Path $latestPath)) {
    Write-Host "Creation de la structure cmdline-tools..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $latestPath -Force
    New-Item -ItemType Directory -Path "$latestPath\bin" -Force
}

# Télécharger et installer les composants SDK
Write-Host "Telechargement des composants SDK..." -ForegroundColor Yellow

# Créer un script batch pour l'installation
$batchContent = @"
@echo off
echo Installation des composants SDK Android...
echo ========================================

REM Vérifier si sdkmanager est disponible
if exist "$cmdlineToolsPath\sdkmanager.bat" (
    echo SDK Manager trouve
    echo Installation des composants...
    
    REM Installer les platforms
    "$cmdlineToolsPath\sdkmanager.bat" "platforms;android-34"
    "$cmdlineToolsPath\sdkmanager.bat" "platforms;android-33"
    
    REM Installer les build-tools
    "$cmdlineToolsPath\sdkmanager.bat" "build-tools;34.0.0"
    "$cmdlineToolsPath\sdkmanager.bat" "build-tools;33.0.2"
    
    REM Installer les platform-tools
    "$cmdlineToolsPath\sdkmanager.bat" "platform-tools"
    
    echo Installation terminee !
    pause
) else (
    echo SDK Manager non trouve
    echo Veuillez installer Android Studio et configurer le SDK
    pause
)
"@

$batchPath = "install_sdk_components.bat"
$batchContent | Out-File -FilePath $batchPath -Encoding ASCII

Write-Host "Script batch cree : $batchPath" -ForegroundColor Green
Write-Host ""
Write-Host "Instructions :" -ForegroundColor Cyan
Write-Host "1. Android Studio devrait etre ouvert" -ForegroundColor White
Write-Host "2. Allez dans Tools > SDK Manager" -ForegroundColor White
Write-Host "3. Dans 'SDK Platforms', cochez :" -ForegroundColor White
Write-Host "   - Android 14.0 (API 34)" -ForegroundColor White
Write-Host "   - Android 13.0 (API 33)" -ForegroundColor White
Write-Host "4. Dans 'SDK Tools', cochez :" -ForegroundColor White
Write-Host "   - Android SDK Build-Tools" -ForegroundColor White
Write-Host "   - Android SDK Command-line Tools" -ForegroundColor White
Write-Host "   - Android SDK Platform-Tools" -ForegroundColor White
Write-Host "5. Cliquez sur 'Apply' et attendez l'installation" -ForegroundColor White
Write-Host ""
Write-Host "Ou utilisez le script batch : $batchPath" -ForegroundColor Yellow

