# radar_disk.ps1 — الرادار الشامل
# شغّله كمسؤول (Run as Administrator)
# سيأخذ وقتاً لأنه يمسح القرص C كاملاً

$outputFile = "C:\radar_results.txt"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  FULL DISK RADAR — SAMROCK002" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# 1. وقت التجميد = آخر إقلاع للنظام
$bootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
Write-Host "`n[1] وقت الإقلاع (نقطة الصفر): $bootTime" -ForegroundColor Yellow

# 2. مسح القرص C كاملاً
Write-Host "`n[2] جاري المسح الشامل لـ C:\ ... (قد يأخذ دقائق)" -ForegroundColor Yellow

$results = Get-ChildItem -Path "C:\" -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -gt $bootTime } |
    Sort-Object Length -Descending |
    Select-Object -First 100 |
    Select-Object FullName, 
                  @{N='Size_MB';E={[math]::Round($_.Length/1MB,2)}},
                  LastWriteTime

# 3. عرض النتائج
Write-Host "`n[3] أكبر الملفات التي تغيرت بعد الإقلاع:" -ForegroundColor Cyan
Write-Host "-------------------------------------------"

$results | ForEach-Object {
    $color = if ($_.Size_MB -gt 100) { "Red" } 
             elseif ($_.Size_MB -gt 10) { "Yellow" } 
             else { "Green" }
    Write-Host "$($_.Size_MB) MB | $($_.LastWriteTime) | $($_.FullName)" -ForegroundColor $color
}

# 4. حفظ النتائج في ملف
$results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
Write-Host "`n[✅] تم حفظ النتائج الكاملة في: $outputFile" -ForegroundColor Green
Write-Host "افتح الملف في Excel لتحليل أفضل." -ForegroundColor Cyan

Write-Host "`n======================================" -ForegroundColor Cyan
Read-Host "اضغط Enter للخروج"
