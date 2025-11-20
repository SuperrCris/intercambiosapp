# CORS Fix Script for Firebase Storage
# Run this script to fix CORS issues

Write-Host "Firebase Storage CORS Fix" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""

$projectId = "intercambiosaplicacion"
$bucket = "$projectId.firebasestorage.app"

Write-Host "Project: $projectId" -ForegroundColor Yellow
Write-Host "Bucket: $bucket" -ForegroundColor Yellow
Write-Host ""

Write-Host "To fix CORS, you need to:" -ForegroundColor Cyan
Write-Host "1. Install Google Cloud SDK from: https://cloud.google.com/sdk/docs/install-sdk" -ForegroundColor White
Write-Host "   Direct download: https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe" -ForegroundColor White
Write-Host ""
Write-Host "2. After installation, run these commands:" -ForegroundColor White
Write-Host "   gcloud auth login" -ForegroundColor Green
Write-Host "   gcloud config set project $projectId" -ForegroundColor Green
Write-Host "   gsutil cors set cors.json gs://$bucket" -ForegroundColor Green
Write-Host ""
Write-Host "3. Verify CORS is set:" -ForegroundColor White
Write-Host "   gsutil cors get gs://$bucket" -ForegroundColor Green
Write-Host ""

$response = Read-Host "Do you want to open the Google Cloud SDK download page? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    Start-Process "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe"
    Write-Host "Download started! Install it and run the commands above." -ForegroundColor Green
}
