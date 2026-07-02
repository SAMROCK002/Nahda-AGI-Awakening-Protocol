# Sovereign Shield — Anti-Digital Barnacle Protocol
# Version: 2.0 | SAMROCK002 | Nahda-AGI
# Action: ISOLATE ONLY — no file deletion ever

import psutil
import time
import json
import subprocess
from datetime import datetime
from pathlib import Path

# ══ القائمة البيضاء — العمليات المعتمدة ══
APPROVED_PROCESSES = [
    "ollama",
    "python",
    "python3",
    "powershell",
    "pwsh",
    "notepad++",
    "explorer",
    "system",
    "svchost",
    "lsass",
    "csrss",
    "winlogon",
    "services",
    "smss",
    "wininit",
    "dwm",
    "taskmgr",
    "cmd",
]

# ══ حدود الموارد ══
VRAM_LIMIT_MB   = 800   # الحد الأقصى لأي عملية غير معتمدة في VRAM
CPU_LIMIT_PCT   = 80    # الحد الأقصى لاستهلاك CPU
RAM_LIMIT_MB    = 2048  # الحد الأقصى لاستهلاك RAM
WATCH_INTERVAL  = 15    # فحص كل 15 ثانية
CONFIRM_CYCLES  = 3     # عدد الدورات قبل العزل (45 ثانية تأكيد)

# ══ ملف السجل ══
LOG_FILE = Path("sovereign_shield_log.json")

def log_event(event_type: str, process_name: str, pid: int, details: dict):
    """تسجيل كل حدث — لا شيء يُحذف من السجل"""
    entry = {
        "timestamp": datetime.now().isoformat(),
        "event":     event_type,
        "process":   process_name,
        "pid":       pid,
        "details":   details,
    }
    log = []
    if LOG_FILE.exists():
        log = json.loads(LOG_FILE.read_text(encoding="utf-8"))
    log.append(entry)
    LOG_FILE.write_text(json.dumps(log, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[{event_type}] {process_name} (PID:{pid}) — {details}")

def get_vram_usage() -> dict:
    """قراءة استهلاك VRAM من nvidia-smi"""
    usage = {}
    try:
        result = subprocess.check_output(
            ["nvidia-smi", "--query-compute-apps=pid,used_memory",
             "--format=csv,noheader,nounits"],
            stderr=subprocess.DEVNULL
        )
        for line in result.decode().strip().split("\n"):
            if line.strip():
                pid, vram = map(int, line.split(","))
                usage[pid] = vram
    except Exception:
        pass
    return usage

def is_approved(name: str) -> bool:
    """هل العملية في القائمة البيضاء؟"""
    name_lower = name.lower()
    return any(approved in name_lower for approved in APPROVED_PROCESSES)

def isolate_process(proc: psutil.Process):
    """
    عزل العملية من الموارد فقط.
    لا حذف — فقط تجميد وتقليص أولوية.
    """
    try:
        # تقليص الأولوية لأدنى مستوى
        proc.nice(psutil.IDLE_PRIORITY_CLASS if hasattr(psutil, "IDLE_PRIORITY_CLASS")
                  else 19)
        # تعليق العملية (إيقاف مؤقت من المعالجة)
        proc.suspend()
        log_event(
            "ISOLATED",
            proc.name(),
            proc.pid,
            {"action": "suspended + priority_lowered", "note": "no file deleted"}
        )
    except (psutil.NoSuchProcess, psutil.AccessDenied) as e:
        log_event("ISOLATION_FAILED", proc.name() if proc else "unknown",
                  proc.pid if proc else 0, {"error": str(e)})

class SovereignShield:
    def __init__(self):
        self.suspects = {}  # pid -> count of suspicious cycles

    def scan(self):
        """دورة فحص واحدة"""
        vram_usage = get_vram_usage()

        for proc in psutil.process_iter(["pid", "name", "cpu_percent", "memory_info"]):
            try:
                pid  = proc.info["pid"]
                name = proc.info["name"] or ""
                cpu  = proc.cpu_percent(interval=0.1)
                ram  = (proc.info["memory_info"].rss // 1024 // 1024
                        if proc.info["memory_info"] else 0)
                vram = vram_usage.get(pid, 0)

                # تخطي العمليات المعتمدة
                if is_approved(name):
                    continue

                # تحقق من تجاوز الحدود
                suspicious = (
                    vram > VRAM_LIMIT_MB or
                    cpu  > CPU_LIMIT_PCT or
                    ram  > RAM_LIMIT_MB
                )

                if suspicious:
                    self.suspects[pid] = self.suspects.get(pid, 0) + 1
                    log_event(
                        "SUSPECT_DETECTED",
                        name, pid,
                        {"vram_mb": vram, "cpu_pct": cpu, "ram_mb": ram,
                         "cycle": self.suspects[pid]}
                    )

                    # عزل بعد تأكيد متعدد الدورات
                    if self.suspects[pid] >= CONFIRM_CYCLES:
                        isolate_process(proc)
                        del self.suspects[pid]
                else:
                    # العملية عادت لطبيعتها — أزل من قائمة المشتبه بهم
                    if pid in self.suspects:
                        del self.suspects[pid]

            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue

    def run(self):
        """حلقة المراقبة الدائمة"""
        print("Sovereign Shield Active — Nahda-AGI Protection Layer")
        print(f"Watching every {WATCH_INTERVAL}s | Isolate after {CONFIRM_CYCLES} cycles")
        print("NO FILES WILL EVER BE DELETED\n")

        while True:
            self.scan()
            time.sleep(WATCH_INTERVAL)


if __name__ == "__main__":
    shield = SovereignShield()
    shield.run()
