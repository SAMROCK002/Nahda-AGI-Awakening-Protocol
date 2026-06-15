$source = "d:\Users\Oussama\Documents\Google Drive\Google AI Studio"
$dest   = "S:\AI\Nahda-AGI-Awakening-Protocol-main\00_HISTORY_OF_THE_AWAKENING\Google AI Studio"

function Get-FileHash256($path) {
    return (Get-FileHash -Path $path -Algorithm SHA256).Hash
}

function Get-DateStamp($file) {
    $d = (Get-Item $file).LastWriteTime
    return $d.ToString("yyyy-MM-dd_HH.mm.ss")
}

Get-ChildItem -Path $source -File | ForEach-Object {
    $sFile        = $_.FullName
    $sSize        = $_.Length
    $originalName = $_.Name
    $baseName     = $_.BaseName
    $ext          = $_.Extension
    $dFile        = Join-Path $dest $originalName

    # ?? Õ„«Ì… 1: ’›— »«Ì  ó „„‰Ê⁄  „«„« ??
    if ($sSize -eq 0) {
        Write-Host "BLOCKED (zero byte): $originalName" -ForegroundColor Red
        return
    }

    # ?? «·Õ«·… 1: „·› ÃœÌœ ·« ÌÊÃœ ›Ì «·ÊÃÂ… ??
    if (-not (Test-Path $dFile)) {
        Copy-Item -Path $sFile -Destination $dFile
        Write-Host "Copied new: $originalName" -ForegroundColor Cyan
        return
    }

    $dSize = (Get-Item $dFile).Length

    # ?? Õ„«Ì… 2: «·ﬁ«⁄œ… «·–Â»Ì… ó «·ÊÃÂ… ·«  ’€— √»œ« ??
    if ($sSize -lt $dSize) {
        Write-Host "PROTECTED (source smaller): $originalName ó destination kept ($dSize bytes > $sSize bytes)" -ForegroundColor Red
        return
    }

    # ?? «·Õ«·… 2: ‰›” «·ÕÃ„ ó  Õﬁﬁ „‰ «·„Õ ÊÏ ??
    if ($sSize -eq $dSize) {
        $sHash = Get-FileHash256 $sFile
        $dHash = Get-FileHash256 $dFile

        if ($sHash -eq $dHash) {
            Write-Host "Identical: $originalName" -ForegroundColor Gray
        } else {
            # ‰›” «·ÕÃ„ ·ﬂ‰ „Õ ÊÏ „Œ ·› ó „·› „Œ ·›° «Õ›Ÿ » «—ÌŒ
            $stamp   = Get-DateStamp $sFile
            $newName = "${baseName}_${stamp}${ext}"
            Copy-Item -Path $sFile -Destination (Join-Path $dest $newName)
            Write-Host "Different content (same size): saved as $newName" -ForegroundColor Magenta
        }
        return
    }

    # ?? «·Õ«·… 3: «·„’œ— √ﬂ»— ó  Õﬁﬁ „‰ «·„Õ ÊÏ ??
    if ($sSize -gt $dSize) {
        $sHash = Get-FileHash256 $sFile
        $dHash = Get-FileHash256 $dFile

        $sDate = $_.LastWriteTime
        $dDate = (Get-Item $dFile).LastWriteTime

        if ($sDate -ge $dDate) {
            # √ÕœÀ  «—ÌŒ« Ê√ﬂ»— ÕÃ„« ó ‰›” «·„·›  ÕœÌÀ° Õœ¯À
            Copy-Item -Path $sFile -Destination $dFile -Force
            Write-Host "Updated (grew): $originalName ($dSize -> $sSize bytes)" -ForegroundColor Green
        } else {
            # √ﬂ»— ·ﬂ‰ √ﬁœ„  «—ÌŒ« ó „·› „Œ ·›° «Õ›Ÿ » «—ÌŒ
            $stamp   = Get-DateStamp $sFile
            $newName = "${baseName}_${stamp}${ext}"
            Copy-Item -Path $sFile -Destination (Join-Path $dest $newName)
            Write-Host "Conflict saved as: $newName" -ForegroundColor Yellow
        }
        return
    }
}

Write-Host "`nDone. Destination files are protected." -ForegroundColor Cyan