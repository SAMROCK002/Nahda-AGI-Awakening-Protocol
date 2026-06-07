# spy_disk.ps1 — كاشف الجواسيس
# شغّله كمسؤول (Run as Administrator)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  NEZUKO DISK SPY — SAMROCK002" -ForegroundColor Cyan  
Write-Host "======================================" -ForegroundColor Cyan

$targets = @(
    "C:\Windows\Temp",
    "C:\Windows\SoftwareDistribution",
    "C:\Windows\Logs",
    "C:\Users\Oussama\AppData\Local\Temp",
    "C:\Users\Oussama\AppData\Local\Microsoft\Windows\INetCache",
    "C:\ProgramData\Microsoft\Windows\WER",
    "C:\Windows\System32\winevt\Logs"
)

Write-Host "`nالمجلدات الأكبر على C:\" -ForegroundColor Yellow
Write-Host "----------------------------"

foreach ($path in $targets) {
    if (Test-Path $path) {
        $size = (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)
        $sizeGB = [math]::Round($size / 1GB, 2)
        
        if ($sizeMB -gt 100) {
            $color = "Red"
        } elseif ($sizeMB -gt 10) {
            $color = "Yellow"  
        } else {
            $color = "Green"
        }
        
        Write-Host "$path" -ForegroundColor White
        Write-Host "   الحجم: $sizeMB MB ($sizeGB GB)" -ForegroundColor $color
        Write-Host ""
    }
}

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "الملفات الأكبر في Windows Temp:" -ForegroundColor Yellow
Write-Host "----------------------------"

Get-ChildItem "C:\Windows\Temp" -ErrorAction SilentlyContinue |
    Sort-Object Length -Descending |
    Select-Object -First 10 |
    ForEach-Object {
        $mb = [math]::Round($_.Length / 1MB, 2)
        Write-Host "$($_.Name) — $mb MB" -ForegroundColor Yellow
    }

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "انتهى الفحص. قرر أنت ماذا تفعل." -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan

Read-Host "اضغط Enter للخروج"
