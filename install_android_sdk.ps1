# Script PowerShell pour installer le SDK Android
Write-Host "Installation du SDK Android pour Flutter" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Vérifier si Android Studio est installé
$androidStudioPath = "C:\Program Files\Android\Android Studio\bin\studio64.exe"
if (Test-Path $androidStudioPath) {
    Write-Host "Android Studio trouve" -ForegroundColor Green
} else {
    Write-Host "Android Studio non trouve dans le chemin par defaut" -ForegroundColor Red
    Write-Host "Veuillez installer Android Studio depuis : https://developer.android.com/studio" -ForegroundColor Yellow
    exit 1
}

# Vérifier si le SDK est déjà installé
$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
if (Test-Path $sdkPath) {
    Write-Host "SDK Android trouve dans : $sdkPath" -ForegroundColor Green
} else {
    Write-Host "SDK Android non trouve" -ForegroundColor Red
    Write-Host "Creation du repertoire..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $sdkPath -Force
}

# Définir les variables d'environnement
Write-Host "Configuration des variables d'environnement..." -ForegroundColor Yellow

# ANDROID_HOME
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")

# Ajouter au PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$sdkPath\platform-tools*") {
    $newPath = "$currentPath;$sdkPath\platform-tools;$sdkPath\tools;$sdkPath\tools\bin"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "Variables d'environnement configurees" -ForegroundColor Green
} else {
    Write-Host "Variables d'environnement deja configurees" -ForegroundColor Green
}

Write-Host ""
Write-Host "Instructions pour finaliser l'installation :" -ForegroundColor Cyan
Write-Host "1. Ouvrez Android Studio" -ForegroundColor White
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
Write-Host "6. Redemarrez votre terminal" -ForegroundColor Yellow
Write-Host "7. Verifiez avec : flutter doctor" -ForegroundColor Yellow
Write-Host "8. Acceptez les licences : flutter doctor --android-licenses" -ForegroundColor Yellow

Write-Host ""
Write-Host "Apres l'installation, vous pourrez deployer votre app sur mobile !" -ForegroundColor Green
