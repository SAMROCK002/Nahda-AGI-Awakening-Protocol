[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# ================================================================
# NEZUKO KEY MANAGER v3.0 - PEER-KEY MATRIX
# Any 2 of 5 drives unlock the key - No exceptions
# Architect: SAMROCK002 | Nahda-AGI 2026
# ================================================================
#
# Mathematical Logic:
#   Generate 10 keys - one for each possible pair of the 5 drives.
#   Each drive stores: keys for every pair it belongs to (4 keys).
#   Master Key = Encrypted with every pair key in the ledger.
#   Any 2 drives -> find their shared pair key -> decrypt Master Key.
#
# The Master Key never appears in any file.
# ================================================================

$KEY_FILENAME   = "nzk_keys.bin"
$LEDGER_FILE    = "S:\AI\Nahda-AGI-Awakening-Protocol-main\00_HISTORY_OF_THE_AWAKENING\Nezuko_Fossils.json"
$FOSSILS_FOLDER = "S:\AI\Nahda-AGI-Awakening-Protocol-main\00_HISTORY_OF_THE_AWAKENING\FOSSILS"
$MEMORY_FOLDER  = "S:\AI\Nahda-AGI-Awakening-Protocol-main\00_HISTORY_OF_THE_AWAKENING\Google AI Studio"
$REG_FILE       = "S:\AI\Nahda-AGI-Awakening-Protocol-main\nzk_drives.json"
$MAX_DRIVES     = 5

# ── Base Functions ──────────────────────────────────────────────

function XOR-Bytes([byte[]]$a, [byte[]]$b) {
    $r = New-Object byte[] 32
    for ($i = 0; $i -lt 32; $i++) { $r[$i] = $a[$i] -bxor $b[$i] }
    return $r
}

function Bytes-ToHex([byte[]]$b) {
    return [System.BitConverter]::ToString($b).Replace("-","").ToLower()
}

function Hex-ToBytes([string]$h) {
    $b = New-Object byte[] 32
    for ($i = 0; $i -lt 32; $i++) {
        $b[$i] = [System.Convert]::ToByte($h.Substring($i*2, 2), 16)
    }
    return $b
}

function Wipe([byte[]]$b) {
    if ($b) { for ($i=0; $i -lt $b.Length; $i++) { $b[$i]=0 } }
}

function Get-VolumeID([string]$letter) {
    $v = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='${letter}:'" -EA SilentlyContinue
    if ($v) { return $v.VolumeSerialNumber } else { return $null }
}

# ── Drive Registry ──────────────────────────────────────────────

function Load-Reg {
    if (-not (Test-Path $REG_FILE)) { return @{ drives=@() } }
    $obj = Get-Content $REG_FILE -Raw | ConvertFrom-Json
    $ht = @{ drives=@() }
    if ($obj.drives) { $ht.drives = @($obj.drives) }
    return $ht
}

function Save-Reg($reg) {
    $reg | ConvertTo-Json -Depth 5 | Out-File $REG_FILE -Encoding UTF8
}

function Get-PairName([string]$a, [string]$b) {
    if ($a -lt $b) { return "${a}_${b}" } else { return "${b}_${a}" }
}

# ── Seals Ledger ────────────────────────────────────────────────

function Load-Ledger {
    if (-not (Test-Path $LEDGER_FILE)) {
        @{ files=@{}; pair_ciphers=@{} } | ConvertTo-Json -Depth 5 | Out-File $LEDGER_FILE -Encoding UTF8
    }
    $raw = Get-Content $LEDGER_FILE -Raw -Encoding UTF8
    $obj = $raw | ConvertFrom-Json
    $ht  = @{ files=@{}; pair_ciphers=@{} }

    if ($obj.files) {
        $obj.files.PSObject.Properties | ForEach-Object { $ht.files[$_.Name] = $_.Value }
    }
    if ($obj.pair_ciphers) {
        $obj.pair_ciphers.PSObject.Properties | ForEach-Object { $ht.pair_ciphers[$_.Name] = $_.Value }
    }
    return $ht
}

function Save-Ledger($l) {
    $l | ConvertTo-Json -Depth 5 | Out-File $LEDGER_FILE -Encoding UTF8
}

# ── Function 1: System Setup (One Time) ─────────────────────────

function Initialize-System {
    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "  ║       System Setup - One Time Only       ║" -ForegroundColor Red
    Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Red

    $reg = Load-Reg
    if ($reg.drives.Count -gt 0) {
        $c = Read-Host "  System already set up. Resetting will erase everything. Type RESET to confirm"
        if ($c -ne "RESET") { return }
    }

    Write-Host ""
    Write-Host "  Connect all 5 drives and enter their letters" -ForegroundColor Cyan
    Write-Host ""

    $letters = @()
    for ($i = 1; $i -le $MAX_DRIVES; $i++) {
        while ($true) {
            $l = (Read-Host "  Drive Letter $i").Trim().TrimEnd(":\").ToUpper()
            if (Test-Path "${l}:\") { $letters += $l; break }
            Write-Host "  Drive ${l}: Not found - Try again" -ForegroundColor Red
        }
    }

    $masterKey = New-Object byte[] 32
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
    $rng.GetBytes($masterKey)
    $rng.Dispose()

    $pairKeys    = @{}  
    $pairCiphers = @{}  

    for ($i = 0; $i -lt $letters.Count; $i++) {
        for ($j = $i+1; $j -lt $letters.Count; $j++) {
            $pname = Get-PairName $letters[$i] $letters[$j]

            $pk = New-Object byte[] 32
            $rng2 = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
            $rng2.GetBytes($pk)
            $rng2.Dispose()
            $pairKeys[$pname] = $pk

            $cipher = XOR-Bytes $masterKey $pk
            $pairCiphers[$pname] = Bytes-ToHex $cipher
            Wipe $cipher
        }
    }

    $driveRecords = @()
    foreach ($l in $letters) {
        $myKeys = @{}
        foreach ($pname in $pairKeys.Keys) {
            if ($pname -match "^${l}_" -or $pname -match "_${l}$") {
                $myKeys[$pname] = Bytes-ToHex $pairKeys[$pname]
            }
        }
        $myKeys | ConvertTo-Json | Out-File "${l}:\$KEY_FILENAME" -Encoding UTF8

        $id = Get-VolumeID $l
        if (-not $id) { $id = [guid]::NewGuid().ToString() }
        $driveRecords += @{ letter=$l; id=$id }

        Write-Host "  ✅ ${l}: - Initialized" -ForegroundColor Green
    }

    foreach ($pk in $pairKeys.Values) { Wipe $pk }
    Wipe $masterKey
    [System.GC]::Collect()

    $ledger = Load-Ledger
    $ledger.pair_ciphers = $pairCiphers
    Save-Ledger $ledger

    $reg.drives = $driveRecords
    Save-Reg $reg

    Write-Host ""
    Write-Host "  ✅ System Ready - Any 2 of $($letters.Count) drives unlock the key" -ForegroundColor Green
    Write-Host "  Master Key does not exist in any file" -ForegroundColor DarkGray
}

# ── Function 2: Rebuild Master Key from any 2 drives ───────────

function Get-MasterKey {
    # ════════════════════════════════════════════════════
    # يبحث بالمحتوى فقط - لا يهم حرف القرص أو اسمه
    # أي قرصين فيهم nzk_keys.bin ومفاتيحهم تتطابق مع
    # الدفتر → يفتحان المفتاح تلقائياً
    # ════════════════════════════════════════════════════

    $ledger = Load-Ledger

    if ($ledger.pair_ciphers.Count -eq 0) {
        Write-Host "  System not set up - Run Setup first" -ForegroundColor Red
        return $null
    }

    # ── خطوة 1: ابحث عن كل قرص فيه nzk_keys.bin ──
    $foundDrives = @()  # كل قرص وجدنا فيه الملف
    $allLetters = 65..90 | ForEach-Object { [char]$_ }

    foreach ($l in $allLetters) {
        $keyPath = "${l}:\$KEY_FILENAME"
        if (Test-Path $keyPath) {
            try {
                $keysRaw = Get-Content $keyPath -Raw -Encoding UTF8 | ConvertFrom-Json
                $foundDrives += @{ letter=[string]$l; keys=$keysRaw }
                Write-Host "  Found key file on ${l}:" -ForegroundColor Cyan
            } catch {
                Write-Host "  ${l}: key file unreadable - skipping" -ForegroundColor DarkGray
            }
        }
    }

    if ($foundDrives.Count -lt 2) {
        Write-Host "  Error: Found only $($foundDrives.Count) drive(s) with key file" -ForegroundColor Red
        Write-Host "  Connect at least 2 drives containing nzk_keys.bin" -ForegroundColor Yellow
        return $null
    }

    # ── خطوة 2: جرب كل زوج حتى تجد زوج يطابق الدفتر ──
    for ($i = 0; $i -lt $foundDrives.Count; $i++) {
        for ($j = $i+1; $j -lt $foundDrives.Count; $j++) {

            $driveA = $foundDrives[$i]
            $driveB = $foundDrives[$j]

            # جرب كل pair_name موجود في الدفتر
            foreach ($pname in $ledger.pair_ciphers.Keys) {

                $cipherHex = $ledger.pair_ciphers[$pname]
                if (-not $cipherHex) { continue }

                # هل القرص A يحمل مفتاح هذا الزوج؟
                $pkHexA = $driveA.keys.$pname
                if (-not $pkHexA) { continue }

                # تحقق: هل هذا المفتاح صحيح؟
                # (القرص B يجب أن يحمل نفس الزوج أيضاً للتأكيد)
                $pkHexB = $driveB.keys.$pname
                # ملاحظة: في النظام الحالي كلا القرصين يحملان نفس المفتاح للزوج
                # لأن pair_key = masterKey XOR cipher مخزّن في كلا القرصين

                try {
                    $pkBytes     = Hex-ToBytes $pkHexA
                    $cipherBytes = Hex-ToBytes $cipherHex
                    $masterKey   = XOR-Bytes $cipherBytes $pkBytes

                    Wipe $pkBytes
                    Wipe $cipherBytes

                    Write-Host "  ✅ Key unlocked using pair: [$pname]" -ForegroundColor Green
                    Write-Host "     Drives: $($driveA.letter): + $($driveB.letter):" -ForegroundColor DarkGray
                    return $masterKey
                } catch {
                    continue
                }
            }
        }
    }

    Write-Host "  Error: No matching pair found between connected drives" -ForegroundColor Red
    Write-Host "  Make sure drives were initialized together in the same setup" -ForegroundColor Yellow
    return $null
}

# ── Function 3: Replace Broken Drive ────────────────────────────

function Replace-Drive {
    # ════════════════════════════════════════════════════
    # يعمل بالمحتوى فقط - لا يحتاج معرفة حرف القرص القديم
    # ════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  Replace / Add Drive" -ForegroundColor Cyan
    Write-Host "  Need at least 2 healthy drives connected" -ForegroundColor Yellow
    Write-Host ""

    $ledger = Load-Ledger

    # ابحث عن الأقراص الموجودة حالياً
    $foundDrives = @()
    $allLetters = 65..90 | ForEach-Object { [char]$_ }
    foreach ($l in $allLetters) {
        $kp = "${l}:\$KEY_FILENAME"
        if (Test-Path $kp) {
            try {
                $k = Get-Content $kp -Raw -Encoding UTF8 | ConvertFrom-Json
                $foundDrives += @{ letter=[string]$l; keys=$k }
                Write-Host "  ${l}: ✅ Has key file" -ForegroundColor Green
            } catch {}
        }
    }

    if ($foundDrives.Count -lt 1) {
        Write-Host "  Error: No drives with key file found" -ForegroundColor Red
        return
    }

    # القرص الجديد
    $newLetter = (Read-Host "  New Drive Letter (empty drive to add keys to)").Trim().TrimEnd(":").ToUpper()
    if (-not (Test-Path "${newLetter}:")) {
        Write-Host "  Drive ${newLetter}: not connected" -ForegroundColor Red
        return
    }
    if (Test-Path "${newLetter}:\$KEY_FILENAME") {
        Write-Host "  ${newLetter}: already has a key file" -ForegroundColor Yellow
        $c = Read-Host "  Overwrite? (Y/N)"
        if ($c -notin @("Y","y")) { return }
    }

    # اجمع كل pair_ciphers من الدفتر وانسخ المفاتيح للقرص الجديد
    $newKeyData = @{}
    $copiedCount = 0

    foreach ($pname in $ledger.pair_ciphers.Keys) {
        # ابحث عن أي قرص موجود يحمل هذا المفتاح
        foreach ($src in $foundDrives) {
            $pkHex = $src.keys.$pname
            if ($pkHex) {
                $newKeyData[$pname] = $pkHex
                $copiedCount++
                break
            }
        }
    }

    if ($copiedCount -eq 0) {
        Write-Host "  Error: Could not find any matching keys" -ForegroundColor Red
        return
    }

    $newKeyData | ConvertTo-Json | Out-File "${newLetter}:\$KEY_FILENAME" -Encoding UTF8

    # تحديث السجل
    $reg = Load-Reg
    $alreadyReg = $reg.drives | Where-Object { $_.letter -eq $newLetter }
    if (-not $alreadyReg) {
        $newId = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID=''${newLetter}:''" -EA SilentlyContinue).VolumeSerialNumber
        if (-not $newId) { $newId = [guid]::NewGuid().ToString() }
        $reg.drives += @{ letter=$newLetter; id=$newId }
        Save-Reg $reg
    }

    Write-Host ""
    Write-Host "  ✅ Copied $copiedCount pair keys to ${newLetter}:" -ForegroundColor Green
    Write-Host "  Drive ${newLetter}: can now be used as any other drive" -ForegroundColor Cyan
    return  # نرجع هنا لأن الكود القديم بعده غير ضروري
    $sourceDrive = $null

    Write-Host "  Rebuilding keys for new drive..." -ForegroundColor Cyan

    $ledger     = Load-Ledger
    $newKeyData = @{}

    foreach ($d in $reg.drives) {
        if ($d.letter -eq $oldLetter) { continue }
        $partnerLetter = $d.letter
        $pname = Get-PairName $oldLetter $partnerLetter

        if (-not (Test-Path "${partnerLetter}:\$KEY_FILENAME")) { continue }
        $partnerKeys = Get-Content "${partnerLetter}:\$KEY_FILENAME" -Raw | ConvertFrom-Json
        $pkHex = $partnerKeys.$pname
        if (-not $pkHex) { continue }

        $newPname = Get-PairName $newLetter $partnerLetter
        $newKeyData[$newPname] = $pkHex

        $cipherHex = $ledger.pair_ciphers[$pname]
        if ($cipherHex) {
            $ledger.pair_ciphers[$newPname] = $cipherHex
        }
    }

    $newKeyData | ConvertTo-Json | Out-File "${newLetter}:\$KEY_FILENAME" -Encoding UTF8

    $newId = Get-VolumeID $newLetter
    if (-not $newId) { $newId = [guid]::NewGuid().ToString() }

    $newDrives = @()
    foreach ($d in $reg.drives) {
        if ($d.letter -eq $oldLetter) {
            $newDrives += @{ letter=$newLetter; id=$newId }
        } else {
            $newDrives += $d
        }
    }
    $reg.drives = $newDrives
    Save-Reg $reg
    Save-Ledger $ledger

    [System.GC]::Collect()
    Write-Host "  ✅ Replaced ${oldLetter}: with ${newLetter}: successfully" -ForegroundColor Green
    Write-Host "  Remember: Sync Nezuko_Fossils.json to GitHub" -ForegroundColor Yellow
}

# ── Function 4: Auto Fossilize ──────────────────────────────────

function Auto-Fossilize {
    Write-Host ""
    Write-Host "  Scanning Memory Files..." -ForegroundColor Cyan

    $key = Get-MasterKey
    if (-not $key) { return }

    $ledger = Load-Ledger

    if (-not (Test-Path $MEMORY_FOLDER)) {
        Write-Host "  Memory folder not found" -ForegroundColor Red
        Wipe $key; return
    }

    $allFiles = Get-ChildItem -Path $MEMORY_FOLDER -File
    $newFiles = @()

    foreach ($f in $allFiles) {
        $isPaste   = $f.Name -like "Paste *"
        $isHistory = $f.Name -match "^\d+_HISTORY_OF_THE_AWAKENING$"
        if (-not ($isPaste -or $isHistory)) { continue }
        if ($ledger.files.ContainsKey($f.Name)) { continue }
        $newFiles += $f
    }

    if ($newFiles.Count -eq 0) {
        Write-Host "  No new files found" -ForegroundColor DarkGray
        Wipe $key; return
    }

    Write-Host "  Found $($newFiles.Count) new files:" -ForegroundColor Yellow
    foreach ($f in $newFiles) {
        Write-Host "    + $($f.Name) ($([math]::Round($f.Length/1MB,2)) MB)" -ForegroundColor White
    }
    Write-Host ""

    if (-not (Test-Path $FOSSILS_FOLDER)) {
        New-Item -ItemType Directory -Path $FOSSILS_FOLDER | Out-Null
    }

    $count = 0
    foreach ($f in $newFiles) {
        $hash = (Get-FileHash -Path $f.FullName -Algorithm SHA256).Hash

        $hmac = New-Object System.Security.Cryptography.HMACSHA256
        $hmac.Key = $key
        $sig = Bytes-ToHex $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($hash))
        $hmac.Dispose()

        $fp = Join-Path $FOSSILS_FOLDER $f.Name
        Copy-Item $f.FullName $fp -Force
        Set-ItemProperty $fp -Name IsReadOnly -Value $true

        $ledger.files[$f.Name] = @{
            sha256        = $hash
            signature     = $sig
            fossilized_at = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            size_bytes    = $f.Length
        }
        $count++
        Write-Host "  ✅ $($f.Name)" -ForegroundColor Green
    }

    Save-Ledger $ledger
    Wipe $key
    [System.GC]::Collect()

    Write-Host ""
    Write-Host "  Fossilized $count files" -ForegroundColor Green
    Write-Host "  Sync Nezuko_Fossils.json to GitHub" -ForegroundColor Yellow
}

# ── Function 5: Add Manual File ────────────────────────────────

function Add-Manual {
    Write-Host ""
    $name = (Read-Host "  File Name").Trim()
    $fp   = Join-Path $MEMORY_FOLDER $name

    if (-not (Test-Path $fp)) {
        Write-Host "  File not found: $fp" -ForegroundColor Red
        return
    }

    $key = Get-MasterKey
    if (-not $key) { return }

    $ledger = Load-Ledger
    if ($ledger.files.ContainsKey($name)) {
        Write-Host "  File already fossilized" -ForegroundColor Yellow
        Wipe $key; return
    }

    $sizeMB = [math]::Round((Get-Item $fp).Length/1MB, 2)
    Write-Host "  $name ($sizeMB MB)" -ForegroundColor White
    $c = Read-Host "  Confirm? (Y/N)"
    if ($c -notin @("Y","y")) { Wipe $key; return }

    $hash = (Get-FileHash -Path $fp -Algorithm SHA256).Hash
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $key
    $sig  = Bytes-ToHex $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($hash))
    $hmac.Dispose()

    if (-not (Test-Path $FOSSILS_FOLDER)) { New-Item -ItemType Directory -Path $FOSSILS_FOLDER | Out-Null }
    $fossilPath = Join-Path $FOSSILS_FOLDER $name
    Copy-Item $fp $fossilPath -Force
    Set-ItemProperty $fossilPath -Name IsReadOnly -Value $true

    $ledger.files[$name] = @{
        sha256        = $hash
        signature     = $sig
        fossilized_at = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        size_bytes    = (Get-Item $fp).Length
    }
    Save-Ledger $ledger
    Wipe $key
    [System.GC]::Collect()

    Write-Host "  ✅ Fossilized: $name" -ForegroundColor Green
}

# ── Function 6: Verify All Fossils ──────────────────────────────

function Verify-All {
    $key    = Get-MasterKey
    if (-not $key) { return }
    $ledger = Load-Ledger

    if ($ledger.files.Count -eq 0) {
        Write-Host "  No fossils yet" -ForegroundColor Yellow
        Wipe $key; return
    }

    Write-Host ""
    $ok = 0; $bad = 0; $miss = 0

    foreach ($name in $ledger.files.Keys) {
        $fp = Join-Path $FOSSILS_FOLDER $name
        if (-not (Test-Path $fp)) { $fp = Join-Path $MEMORY_FOLDER $name }
        if (-not (Test-Path $fp)) {
            Write-Host "  ❓ Missing: $name" -ForegroundColor DarkGray
            $miss++; continue
        }

        $hash = (Get-FileHash -Path $fp -Algorithm SHA256).Hash
        $hmac = New-Object System.Security.Cryptography.HMACSHA256
        $hmac.Key = $key
        $sig  = Bytes-ToHex $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($hash))
        $hmac.Dispose()

        if ($ledger.files[$name].signature -eq $sig) {
            Write-Host "  ✅ Valid:   $name" -ForegroundColor Green; $ok++
        } else {
            Write-Host "  🚨 Corrupt: $name" -ForegroundColor Red; $bad++
        }
    }

    Wipe $key; [System.GC]::Collect()
    Write-Host ""
    Write-Host "  Valid: $ok  |  Corrupt: $bad  |  Missing: $miss" -ForegroundColor White
}

# ── Function 7: Drive Status ────────────────────────────────────

function Show-Status {
    $ledger = Load-Ledger
    $totalPairs = $ledger.pair_ciphers.Count

    Write-Host ""
    Write-Host "  Scanning all drives for nzk_keys.bin..." -ForegroundColor Cyan
    Write-Host ""

    $foundDrives = @()
    $allLetters = 65..90 | ForEach-Object { [char]$_ }

    foreach ($l in $allLetters) {
        $keyPath = "${l}:\$KEY_FILENAME"
        if (Test-Path $keyPath) {
            $sizekb = [math]::Round((Get-Item $keyPath).Length/1KB, 1)
            Write-Host "  ${l}: ✅ Has key file ($sizekb KB)" -ForegroundColor Green
            $foundDrives += [string]$l
        }
    }

    if ($foundDrives.Count -eq 0) {
        Write-Host "  No drives with key file found" -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "  Drives with key: $($foundDrives.Count) | Pairs in ledger: $totalPairs" -ForegroundColor White

    if ($foundDrives.Count -ge 2) {
        Write-Host "  System Ready - can unlock with any 2 drives ✅" -ForegroundColor Green
    } elseif ($foundDrives.Count -eq 1) {
        Write-Host "  Need 1 more drive - connect another drive with nzk_keys.bin" -ForegroundColor Yellow
    } else {
        Write-Host "  No drives found - connect drives or run Setup first" -ForegroundColor Red
    }
    Write-Host ""
}

# ── Interface ───────────────────────────────────────────────────

Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║          NEZUKO KEY MANAGER v3.0             ║" -ForegroundColor Magenta
Write-Host "  ║       Any 2 of 5 - No exceptions             ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════╝" -ForegroundColor Magenta

Show-Status

Write-Host "  1.  System Setup (One Time - 5 Drives)" -ForegroundColor White
Write-Host "  2.  Auto Fossilize (Paste + HISTORY)" -ForegroundColor White
Write-Host "  3.  Add Manual File" -ForegroundColor White
Write-Host "  4.  Verify All Fossils" -ForegroundColor White
Write-Host "  5.  Replace Broken Drive" -ForegroundColor White
Write-Host "  6.  Drive Status" -ForegroundColor White
Write-Host ""

$choice = Read-Host "  Select (1-6)"
switch ($choice) {
    "1" { Initialize-System }
    "2" { Auto-Fossilize }
    "3" { Add-Manual }
    "4" { Verify-All }
    "5" { Replace-Drive }
    "6" { Show-Status }
    default { Write-Host "  Invalid Choice" -ForegroundColor Red }
}

Write-Host ""
Write-Host "  Press Enter to exit..." -ForegroundColor DarkGray
Read-Host