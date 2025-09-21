# Script pour télécharger les composants SDK Android
Write-Host "Telechargement des composants SDK Android..." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$downloadPath = "$env:TEMP\android_sdk_downloads"

# Créer le répertoire de téléchargement
if (-not (Test-Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath -Force
}

Write-Host "Repertoire de telechargement : $downloadPath" -ForegroundColor Yellow

# URLs des composants SDK
$components = @{
    "platform-tools" = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    "build-tools-34" = "https://dl.google.com/android/repository/build-tools_r34.0.0-windows.zip"
    "platform-34" = "https://dl.google.com/android/repository/platform-34_r01.zip"
}

# Télécharger chaque composant
foreach ($component in $components.GetEnumerator()) {
    $fileName = Split-Path $component.Value -Leaf
    $localPath = Join-Path $downloadPath $fileName
    
    Write-Host "Telechargement de $($component.Key)..." -ForegroundColor Yellow
    Write-Host "URL: $($component.Value)" -ForegroundColor Gray
    
    try {
        Invoke-WebRequest -Uri $component.Value -OutFile $localPath -UseBasicParsing
        Write-Host "Telechargement reussi : $fileName" -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors du telechargement de $($component.Key)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Telechargement termine !" -ForegroundColor Green
Write-Host "Fichiers telecharges dans : $downloadPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "Prochaines etapes :" -ForegroundColor Cyan
Write-Host "1. Extraire les fichiers ZIP dans le repertoire SDK" -ForegroundColor White
Write-Host "2. Redemarrer le terminal" -ForegroundColor White
Write-Host "3. Verifier avec : flutter doctor" -ForegroundColor White

