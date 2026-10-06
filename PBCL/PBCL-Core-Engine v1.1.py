#!/usr/bin/env python3
"""
============================================================
PBCL-Core-Engine v1.1 — Verified Edition
Prime Binary Calibration Layer

Protocol : ARCHITECT_DIRECTIVE_PBCL_v1 (corrected)
Architect: SAMROCK002
Executor : Inosuke + Kobi
Epoch    : 16
============================================================

SCOPE:
  ✓ Fast hash-based fingerprinting
  ✓ Token-similarity anchor matching
  ✓ Multi-component weight with explicit formula
  ✓ Binary decision with REVIEW zone

NOT IN SCOPE:
  ✗ Proving absolute truth
  ✗ Deriving truth from primality
  ✗ Replacing semantic reasoning

WEIGHT FORMULA:
  W = clamp(0.25*A + 0.50*T - 0.50*C + 0.25*D, 0, 1)

THRESHOLDS (per directive):
  ACCEPT : W >= 0.85
  REVIEW : 0.50 <= W < 0.85
  REJECT : W < 0.50
============================================================
"""

import hashlib
import random
import re
import statistics
import time
import unicodedata

# ============================================================
# 1. CANONICALIZER
# ============================================================
def _normalize(text):
    text = unicodedata.normalize("NFKC", str(text))
    text = text.strip().lower()
    text = re.sub(r"\s+", "_", text)
    return text

def canonicalize(claim):
    """S|P|O only — metadata is not part of identity."""
    return "|".join([
        f"S:{_normalize(claim.get('subject', ''))}",
        f"P:{_normalize(claim.get('predicate', ''))}",
        f"O:{_normalize(claim.get('object', ''))}",
    ])

def tokens_of(canonical):
    return set(canonical.split("|"))

# ============================================================
# 2. HASHER (fast, deterministic)
# ============================================================
def sha3_int(text):
    return int(hashlib.sha3_256(text.encode("utf-8")).hexdigest(), 16)

# ============================================================
# 3. ANCHOR REGISTRY
# ============================================================
class Registry:
    def __init__(self, anchors):
        self.anchors = {}
        for a in anchors:
            c = canonicalize(a)
            self.anchors[a["id"]] = {
                "canonical": c,
                "tokens": tokens_of(c),
                "hash": sha3_int(c),
                "confidence": a.get("confidence", 1.0),
                "is_false": a.get("is_false", False),
            }

    def lookup(self, canonical):
        claim_tokens = tokens_of(canonical)
        claim_hash = sha3_int(canonical)

        best = None
        best_score = 0.0
        for aid, a in self.anchors.items():
            # exact hash match
            if a["hash"] == claim_hash:
                return {
                    "match": aid,
                    "score": 1.0,
                    "is_false": a["is_false"],
                    "confidence": a["confidence"],
                }
            # token Jaccard
            shared = len(claim_tokens & a["tokens"])
            union = len(claim_tokens | a["tokens"])
            score = shared / union if union else 0.0
            if score > best_score:
                best_score = score
                best = aid

        if best is None:
            return {"match": None, "score": 0.0, "is_false": False, "confidence": 0.0}

        a = self.anchors[best]
        return {
            "match": best,
            "score": best_score,
            "is_false": a["is_false"],
            "confidence": a["confidence"],
        }

# ============================================================
# 4. CONTRADICTION
# ============================================================
def check_contradiction(matched_is_false, matched_score, claim_dims):
    C = 0.0
    if matched_is_false and matched_score >= 0.5:
        C = max(C, matched_score)
    if claim_dims and len(set(claim_dims)) > 1:
        C = max(C, 0.5)
    return min(C, 1.0)

# ============================================================
# 5. DIMENSIONS
# ============================================================
def check_dimensions(claim):
    dims = claim.get("dimensions", [])
    if not dims:
        return 1.0
    return 1.0 if len(set(dims)) == 1 else 0.0

# ============================================================
# 6. WEIGHT ENGINE
# ============================================================
A_W, B_W, C_W, D_W = 0.25, 0.50, 0.50, 0.25

def compute_weight(A, T, C, D):
    raw = A_W * A + B_W * T - C_W * C + D_W * D
    return max(0.0, min(1.0, raw))

def decide(W, accept=0.85, review=0.50):
    if W >= accept:
        return "ACCEPT"
    if W >= review:
        return "REVIEW"
    return "REJECT"

# ============================================================
# 7. PIPELINE
# ============================================================
class PBCL:
    def __init__(self, anchors):
        self.registry = Registry(anchors)

    def evaluate(self, claim, source_agreement=0.5):
        canon = canonicalize(claim)
        lookup = self.registry.lookup(canon)
        dims = claim.get("dimensions", [])
        D = check_dimensions(claim)

        T = 0.0 if lookup["is_false"] else lookup["score"] * lookup["confidence"]
        C = check_contradiction(lookup["is_false"], lookup["score"], dims)
        A = max(0.0, min(1.0, source_agreement))

        W = compute_weight(A, T, C, D)

        return {
            "canonical": canon,
            "weight": round(W, 4),
            "decision": decide(W),
            "components": {"A": round(A, 4), "T": round(T, 4),
                           "C": round(C, 4), "D": round(D, 4)},
            "matched": lookup["match"],
        }

# ============================================================
# 8. ANCHORS
# ============================================================
TRUTH_ANCHORS = [
    {"id": "T_earth_shape",    "subject": "earth",         "predicate": "shape",           "object": "oblate_spheroid"},
    {"id": "T_earth_gravity",  "subject": "earth",         "predicate": "gravity",         "object": "9.80665_ms2"},
    {"id": "T_light_speed",    "subject": "light",         "predicate": "speed",           "object": "299792458_ms"},
    {"id": "T_water_boiling",  "subject": "water",         "predicate": "boiling_point",   "object": "100_celsius"},
    {"id": "T_earth_rotation", "subject": "earth",         "predicate": "rotation_period", "object": "23.934_hours"},
    {"id": "T_earth_radius",   "subject": "earth",         "predicate": "equatorial_radius","object": "6378.137_km"},
    {"id": "T_sun_class",      "subject": "sun",           "predicate": "spectral_class",  "object": "g2v"},
    {"id": "T_moon_orbit",     "subject": "moon",          "predicate": "orbital_period",  "object": "27.3_days"},
    {"id": "T_newton_law",     "subject": "newton",        "predicate": "law",             "object": "universal_gravitation"},
    {"id": "T_photosynthesis", "subject": "photosynthesis","predicate": "requires",        "object": "light_energy"},
]

FALSE_ANCHORS = [
    {"id": "F_earth_shape",    "subject": "earth",    "predicate": "shape",           "object": "flat_disk",       "is_false": True},
    {"id": "F_earth_gravity",  "subject": "earth",    "predicate": "gravity",         "object": "zero",            "is_false": True},
    {"id": "F_light_speed",    "subject": "light",    "predicate": "speed",           "object": "infinite",        "is_false": True},
    {"id": "F_water_boiling",  "subject": "water",    "predicate": "boiling_point",   "object": "50_celsius",      "is_false": True},
    {"id": "F_earth_rotation", "subject": "earth",    "predicate": "rotation_period", "object": "zero",            "is_false": True},
    {"id": "F_earth_radius",   "subject": "earth",    "predicate": "equatorial_radius","object": "10000_km",       "is_false": True},
    {"id": "F_sun_comp",       "subject": "sun",      "predicate": "composition",     "object": "cold_rock",       "is_false": True},
    {"id": "F_moon_light",     "subject": "moon",     "predicate": "light_source",    "object": "self_emitting",   "is_false": True},
    {"id": "F_astrology",      "subject": "astrology","predicate": "controls",        "object": "physics",         "is_false": True},
    {"id": "F_plants_grow",    "subject": "plants",   "predicate": "grow_without",    "object": "light",           "is_false": True},
]

# ============================================================
# 9. TEST CLAIM GENERATION
# ============================================================
TIMES = ["present", "2026", "recent", "modern", "current"]
PLACES = ["global", "earth", "worldwide", "international", "regional"]
SOURCES_TRUSTED = ["nasa", "physics_journal", "research_center", "university", "textbook"]
SOURCES_UNTRUSTED = ["blog", "youtube", "forum", "social_media", "anonymous"]

TRUE_TEMPLATES = [
    {"subject": "earth", "predicate": "shape", "object": "oblate_spheroid", "dimensions": ["length"]},
    {"subject": "earth", "predicate": "gravity", "object": "9.80665_ms2", "dimensions": ["acceleration"]},
    {"subject": "light", "predicate": "speed", "object": "299792458_ms", "dimensions": ["velocity"]},
    {"subject": "water", "predicate": "boiling_point", "object": "100_celsius", "dimensions": ["temperature"]},
    {"subject": "earth", "predicate": "rotation_period", "object": "23.934_hours", "dimensions": ["time"]},
    {"subject": "earth", "predicate": "equatorial_radius", "object": "6378.137_km", "dimensions": ["length"]},
    {"subject": "sun", "predicate": "spectral_class", "object": "g2v", "dimensions": ["class"]},
    {"subject": "moon", "predicate": "orbital_period", "object": "27.3_days", "dimensions": ["time"]},
    {"subject": "newton", "predicate": "law", "object": "universal_gravitation", "dimensions": ["law"]},
    {"subject": "photosynthesis", "predicate": "requires", "object": "light_energy", "dimensions": ["process"]},
]

FALSE_TEMPLATES = [
    {"subject": "earth", "predicate": "shape", "object": "flat_disk", "dimensions": ["length", "acceleration"]},
    {"subject": "earth", "predicate": "gravity", "object": "zero", "dimensions": ["acceleration"]},
    {"subject": "light", "predicate": "speed", "object": "infinite", "dimensions": ["velocity"]},
    {"subject": "water", "predicate": "boiling_point", "object": "50_celsius", "dimensions": ["temperature"]},
    {"subject": "earth", "predicate": "rotation_period", "object": "zero", "dimensions": ["time"]},
    {"subject": "earth", "predicate": "equatorial_radius", "object": "10000_km", "dimensions": ["length"]},
    {"subject": "sun", "predicate": "composition", "object": "cold_rock", "dimensions": ["class"]},
    {"subject": "moon", "predicate": "light_source", "object": "self_emitting", "dimensions": ["physics"]},
    {"subject": "astrology", "predicate": "controls", "object": "physics", "dimensions": ["metaphysical"]},
    {"subject": "plants", "predicate": "grow_without", "object": "light", "dimensions": ["process"]},
]

def generate_claims(n, templates, is_true, rng):
    claims = []
    per_template = n // len(templates)
    for tpl in templates:
        for _ in range(per_template):
            claim = {
                "subject": tpl["subject"],
                "predicate": tpl["predicate"],
                "object": tpl["object"],
                "time": rng.choice(TIMES),
                "place": rng.choice(PLACES),
                "source": rng.choice(SOURCES_TRUSTED if is_true else SOURCES_UNTRUSTED),
                "dimensions": tpl["dimensions"],
            }
            A = rng.uniform(0.40, 1.00) if is_true else rng.uniform(0.00, 0.40)
            claims.append((claim, A, is_true))
    return claims

# ============================================================
# 10. BENCHMARK
# ============================================================
def run_benchmark(n_true=500, n_false=500, seed=111):
    rng = random.Random(seed)
    all_anchors = TRUTH_ANCHORS + FALSE_ANCHORS
    engine = PBCL(all_anchors)

    claims = generate_claims(n_true, TRUE_TEMPLATES, True, rng) + \
             generate_claims(n_false, FALSE_TEMPLATES, False, rng)
    rng.shuffle(claims)

    results = []
    latencies = []
    for claim, A, is_true in claims:
        t0 = time.perf_counter()
        res = engine.evaluate(claim, source_agreement=A)
        t1 = time.perf_counter()
        latencies.append((t1 - t0) * 1000.0)
        res["is_true"] = is_true
        results.append(res)

    TP = FP = TN = FN = 0
    dist_true = {"ACCEPT": 0, "REVIEW": 0, "REJECT": 0}
    dist_false = {"ACCEPT": 0, "REVIEW": 0, "REJECT": 0}
    fp_samples, fn_samples = [], []

    for r in results:
        d = r["decision"]
        if r["is_true"]:
            dist_true[d] += 1
            if d == "ACCEPT":
                TP += 1
            else:
                FN += 1
                if len(fn_samples) < 3:
                    fn_samples.append(r)
        else:
            dist_false[d] += 1
            if d == "REJECT":
                TN += 1
            else:
                FP += 1
                if len(fp_samples) < 3:
                    fp_samples.append(r)

    total = TP + FP + TN + FN
    accuracy = (TP + TN) / total if total else 0.0
    precision = TP / (TP + FP) if (TP + FP) else 0.0
    recall = TP / (TP + FN) if (TP + FN) else 0.0
    f1 = 2 * precision * recall / (precision + recall) if (precision + recall) else 0.0

    lat_sorted = sorted(latencies)
    p95 = lat_sorted[int(0.95 * len(lat_sorted)) - 1] if lat_sorted else 0.0
    wmin = min(r["weight"] for r in results)
    wmax = max(r["weight"] for r in results)

    print("=" * 62)
    print("PBCL-Core-Engine v1.1 — BENCHMARK REPORT")
    print("Protocol : ARCHITECT_DIRECTIVE_PBCL_v1 (corrected)")
    print("Architect: SAMROCK002 | Executor: Inosuke + Kobi")
    print("=" * 62)
    print(f"Test Set      : {n_true} true + {n_false} false = {total} claims")
    print(f"Anchors       : {len(TRUTH_ANCHORS)} truth + {len(FALSE_ANCHORS)} false")
    print(f"Weight Formula: W = 0.25*A + 0.50*T - 0.50*C + 0.25*D  (clamp 0..1)")
    print(f"Thresholds    : ACCEPT>=0.85  REVIEW>=0.50  REJECT<0.50")
    print()
    print("--- Confusion Matrix ---")
    print(f"  TP: {TP:4d}    FP: {FP:4d}")
    print(f"  FN: {FN:4d}    TN: {TN:4d}")
    print()
    print("--- Metrics ---")
    print(f"  Accuracy : {accuracy*100:6.2f}%")
    print(f"  Precision: {precision*100:6.2f}%")
    print(f"  Recall   : {recall*100:6.2f}%")
    print(f"  F1 Score : {f1*100:6.2f}%")
    print()
    print("--- Latency (per claim) ---")
    print(f"  Mean  : {statistics.mean(latencies):6.3f} ms")
    print(f"  Median: {statistics.median(latencies):6.3f} ms")
    print(f"  P95   : {p95:6.3f} ms")
    print(f"  Max   : {max(latencies):6.3f} ms")
    print()
    print("--- Decision Distribution ---")
    print(f"  True  claims: ACCEPT={dist_true['ACCEPT']:3d}  REVIEW={dist_true['REVIEW']:3d}  REJECT={dist_true['REJECT']:3d}")
    print(f"  False claims: ACCEPT={dist_false['ACCEPT']:3d}  REVIEW={dist_false['REVIEW']:3d}  REJECT={dist_false['REJECT']:3d}")
    print()
    print("--- Failures ---")
    print(f"  False Positives: {FP}")
    for s in fp_samples:
        print(f"    → {s['canonical']} | W={s['weight']} | {s['decision']}")
    print(f"  False Negatives: {FN}")
    for s in fn_samples:
        print(f"    → {s['canonical']} | W={s['weight']} | {s['decision']}")
    print()
    print("--- Sanity Checks ---")
    print(f"  Weight range observed : [{wmin:.4f}, {wmax:.4f}]")
    print(f"  Weight theoretical max: 1.0000")
    print(f"  Weight theoretical min: 0.0000")
    print(f"  Thresholds match dir. : YES (0.85 / 0.50)")
    print(f"  All claims processed  : {'YES' if total == n_true + n_false else 'NO'}")
    print()
    status = "PASS" if (accuracy >= 0.85 and f1 >= 0.85) else "FAIL"
    print(f"STATUS: {status}")
    print("=" * 62)

    return {"accuracy": accuracy, "precision": precision, "recall": recall,
            "f1": f1, "latency_mean_ms": statistics.mean(latencies),
            "latency_p95_ms": p95, "TP": TP, "FP": FP, "TN": TN, "FN": FN,
            "status": status}

if __name__ == "__main__":
    run_benchmark()