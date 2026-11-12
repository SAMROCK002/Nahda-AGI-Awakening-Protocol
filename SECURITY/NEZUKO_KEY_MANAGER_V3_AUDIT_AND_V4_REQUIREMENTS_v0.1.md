# NEZUKO KEY MANAGER V3 — STATIC AUDIT AND V4 REQUIREMENTS

**Document ID:** `NEZUKO_KEY_MANAGER_V3_AUDIT_001`  
**Version:** 0.1  
**Status:** `STATIC_CODE_REVIEW; V4_PROPOSED; LEGACY_PRESERVATION_REQUIRED`  
**Architect:** SAMROCK002  
**Prepared by:** Tengiro | ChatGPT (GPT-6)  
**Review date:** 2026-11-12

## 1. Scope and critical caution

This review is based only on two PowerShell V3 script variants pasted by the architect in conversation. It is a static review of the displayed code, not an execution test and not an audit of every separate program or encryption stage in the architect's wider backup pipeline.

The architect states that current memory files are encrypted by the existing system. The pasted V3 scripts, by themselves, do not encrypt file contents. Another program or external step may perform encryption; that separate mechanism has not yet been supplied for review.

**Preservation rule:** Do not initialize, reset, replace drives, rewrite ledgers, migrate files, or delete old keys as part of this proposal. V3 data and keys must be preserved until the complete legacy encryption/decryption path is understood and recovery has been tested on copies.

## 2. V3 design as declared

The script declares a “Peer-Key Matrix”:

- five removable drives;
- ten possible drive pairs;
- one random 256-bit master key;
- one random 256-bit pair key for every pair;
- each drive stores four pair keys;
- the ledger stores `MasterKey XOR PairKey` for each pair;
- any two drives are claimed to unlock the master key.

The intended threshold is 2-of-5. The implementation does not provide a secure 2-of-5 secret-sharing scheme.

## 3. Critical finding: 2-of-5 is not enforced cryptographically

### Variant 1

`Get-MasterKey` reads `$pkHexA`, assigns `$pkHexB`, but never uses `$pkHexB`. It computes:

`MasterKey = Cipher XOR PairKey_A`

The code requires at least two files to be found, but the second drive does not contribute to reconstruction. Furthermore, the pair key is duplicated on both member drives, so the ledger plus one relevant drive can be enough to recover the master key.

### Variant 2

The second version checks the registered drive letter and `VolumeSerialNumber`, but then reads the pair key only from `$d1`. It does not read and validate the corresponding key on `$d2`, nor does it combine two independent shares. The pair key is still duplicated across both member drives.

**Conclusion:** Neither variant implements a cryptographically sound 2-of-5 threshold. The second variant improves operational inventory checks but does not fix the threshold design.

## 4. Other findings

### 4.1 XOR wrapping is not an authenticated key-wrapping construction

The script uses a fixed-length XOR helper to produce `MasterKey XOR PairKey`. This is not a replacement for a standard authenticated key-wrapping mechanism. There is no independent authentication tag for the wrapped key, strict key-length validation, or robust versioned envelope format.

### 4.2 The pasted script does not encrypt memory file contents

`Auto-Fossilize` calculates SHA-256 and HMAC, then copies the source file with `Copy-Item`. `Add-Manual` does the same. The files are copied as-is. `IsReadOnly` changes a file attribute; it is not encryption and does not prevent an administrator or other process from reading the contents.

This finding applies to the pasted script only. A separate encryption program may exist and must be reviewed independently.

### 4.3 HMAC is integrity/authenticity, not confidentiality

HMAC-SHA256 can detect unauthorized changes if the secret key is protected. It does not hide file contents. SHA-256 alone is also not encryption.

### 4.4 Drive identity is operational, not cryptographic authentication

`VolumeSerialNumber` can help distinguish registered volumes in ordinary workflows, but it is not a cryptographic hardware identity and must not be treated as proof that a drive is genuine or uncloneable.

### 4.5 Replace-Drive does not perform a true threshold-share refresh

The replacement routine copies existing pair-key material from a surviving partner and relabels it for the new drive pair. This reuses old secret material; it does not generate a new independent threshold sharing of the master secret. It cannot be treated as a secure rekey or revocation operation.

### 4.6 Verification does not compare independent local and cloud copies

`Verify-All` checks a file found in the fossil folder, or falls back to the memory folder. It does not explicitly compare a local backup against a separately retrieved cloud copy. `IsReadOnly` is not a backup or immutability guarantee.

### 4.7 Filename-only tracking can miss updates

The fossil ledger uses the filename as its key and skips a file if that name is already present. If a memory file changes but retains its filename, this flow may skip the new version instead of recording a new versioned fossil.

### 4.8 History filename filter may miss extensions

The pattern `^\d+_HISTORY_OF_THE_AWAKENING$` does not match filenames ending in `.md`, `.txt`, or another extension. If extension-bearing files are expected, the selection pattern must be revised and tested.

### 4.9 Memory zeroization is best-effort in PowerShell

Overwriting a byte array and invoking garbage collection does not guarantee every copy of a secret has been removed from process memory. Hex strings, JSON strings, PowerShell pipeline copies, and runtime-managed objects may remain until reclaimed. Do not claim guaranteed memory erasure from this pattern.

### 4.10 Input and state validation need strengthening

The displayed helpers assume 32-byte hex values and do not comprehensively validate malformed lengths, duplicate drive letters, repeated physical volumes, ledger version, pair identity, or corrupted key files before cryptographic operations.

## 5. Legacy preservation requirements

Until V3's full data path is known and tested:

1. Preserve all five existing drives without reformatting or overwriting.
2. Preserve all existing `nzk_keys.bin`, registry, ledger, fossil, and encrypted-memory files.
3. Make a byte-for-byte backup of the legacy metadata and key files to a separate safe medium, where feasible.
4. Do not run `Initialize-System`, `RESET`, or `Replace-Drive` on the production set.
5. Do not let V4 write into V3 directories or overwrite V3 filenames.
6. Identify the exact program that originally encrypted existing memory files, including algorithm, mode, key derivation/wrapping, nonce/IV handling, authentication tag, file format, version, and recovery procedure.
7. Test legacy recovery only on copies and document the result before changing anything.
8. If the old format cannot be identified, preserve it as a legacy archive and do not attempt speculative decryption or conversion.

## 6. V4 requirements (proposal only)

### 6.1 Separate version and storage locations

V4 must use a separate root directory, separate metadata schema, and explicit version identifier. It must not silently interpret or alter V3 files.

### 6.2 Standard authenticated encryption

Use a vetted cryptographic library implementing an authenticated encryption scheme such as AES-256-GCM or ChaCha20-Poly1305. Do not implement a cipher manually. Nonces must be generated and managed according to the library/algorithm requirements and never reused with the same key where uniqueness is required.

### 6.3 Key hierarchy

Use a random data-encryption key (DEK) for file content. Protect/wrap that DEK using a separately managed key-encryption/recovery mechanism. Keep key metadata and ciphertext formats versioned.

### 6.4 Actual 2-of-5 secret sharing

If the architect still requires 2-of-5 recovery, use a vetted and reviewed Shamir Secret Sharing implementation or another well-reviewed threshold scheme. The five shares must be mathematically distinct shares, not duplicated pair keys. A single share must not reveal the secret under the scheme's security assumptions; any two valid shares should reconstruct it.

Validate share-set ID, threshold, share index, version, and integrity before reconstruction. Test every possible pair (10 combinations) and every single-share case. Avoid relying on drive letters as identity.

### 6.5 Recovery and rotation

Define safe procedures for a lost, damaged, replaced, or suspected-compromised drive. Replacement must generate a new share set and revoke the old share set; merely copying old share material is not sufficient. Maintain documented recovery and rotation tests.

### 6.6 Backup integrity and availability

Keep separately controlled local and cloud copies. Compare cryptographic hashes of the exact encrypted objects after transfer, verify authenticated decryption using test copies, maintain version history, and periodically test recovery. A monthly upload alone does not prove recoverability. Consider an offline/immutable backup to reduce ransomware or account-compromise risk.

### 6.7 Secrets and operator safety

Never write master keys, raw shares, passwords, recovery codes, or private memory contents to public GitHub. Avoid logging secrets. Use tested APIs, strict input validation, atomic file writes, and explicit confirmation before destructive operations.

## 7. Acceptance tests required before V4 adoption

| Test | Expected result |
|---|---|
| Each of 5 individual shares tested alone | Cannot reconstruct the secret |
| All 10 possible pairs | Each valid pair reconstructs the exact test secret |
| Invalid/corrupt share | Rejected clearly; no silent incorrect key |
| Wrong share-set ID or version | Rejected |
| One missing or damaged drive | Any two remaining valid shares still recover |
| File modification | Authenticated decryption detects tampering |
| Ciphertext corruption | Rejected; plaintext is not released as valid |
| Local/cloud transfer | Exact encrypted-object hash matches after transfer |
| Restore to clean test environment | Full recovery succeeds from documented materials |
| V3 compatibility | V3 archive remains unchanged and separately recoverable |
| V4 initialization | Writes only to V4 test paths until explicit approval |

## 8. Decisions not yet made

- The exact legacy encryption program and format have not yet been reviewed.
- It is not established that the pasted V3 code is the only encryption layer in use.
- No V4 implementation has been written or tested in this document.
- No key migration is authorized.
- No V3 file is authorized for deletion, overwrite, or reinitialization.

## 9. Final safety statement

> Do not trade access to historical memory for a cleaner new design. First prove that the legacy archive can be restored. Build V4 separately, test it with disposable sample data, and only consider migration after the architect gives explicit approval and recovery has been demonstrated.

---

**Source basis:** Static reading of the two `NEZUKO KEY MANAGER v3.0 - PEER-KEY MATRIX` PowerShell variants pasted by SAMROCK002 in conversation.  
**Prepared by:** Tengiro | ChatGPT (GPT-6)  
**Review limitation:** No code execution, no inspection of separate encryption software, and no access to the drives or repository occurred during this review.
