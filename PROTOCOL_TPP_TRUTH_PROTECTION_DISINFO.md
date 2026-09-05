# Truth Protection & Anti-Disinfo Protocol (TPP v1.0)
# Architect: SAMROCK002 | Status: Implementable

---

## 1. Claim Verification Pipeline

```
CLAIM INPUT
    ↓
[Claim Extractor]     → isolate factual assertions
    ↓
[Domain Classifier]   → medical / political / scientific / social
    ↓
[Evidence Retriever]  → fetch from verified corpus
    ↓
[Similarity Scorer]   → cosine similarity vs verified facts
    ↓
[Verdict Engine]      → VERIFIED / DISPUTED / FALSE / UNKNOWN
    ↓
[Response Generator]  → calibrated output with confidence
```

---

## 2. Verification Score

```
V(claim) = max(cosine_similarity(embed(claim), embed(fact_i)))
           for all fact_i in verified_corpus

Verdict mapping:
  V > 0.85  → VERIFIED     (high confidence)
  V 0.6-0.85 → SUPPORTED   (moderate confidence)
  V 0.4-0.6  → DISPUTED    (needs review)
  V 0.2-0.4  → LIKELY_FALSE
  V < 0.2   → FALSE        (contradicts evidence)
```

---

## 3. Domain-Specific Rules

### 3.1 Medical Claims
```
IF domain == MEDICAL:
    required_sources = ["WHO", "peer_reviewed_journals", "health_ministries"]
    confidence_boost = 0.0  # No boost — strict standard
    auto_flag_threshold = 0.40  # Lower threshold for safety
    
    FORBIDDEN_PATTERNS = [
        "cure_cancer_with_*",
        "vaccines_cause_*",
        "stop_medication_*",
        "miracle_treatment_*"
    ]
```

### 3.2 Political Claims
```
IF domain == POLITICAL:
    required_sources = ["official_records", "multiple_independent_sources"]
    minimum_source_count = 3
    recency_weight = 0.30  # Recent sources weighted higher
```

### 3.3 Scientific Claims
```
IF domain == SCIENTIFIC:
    check_against = ["arxiv", "pubmed", "nature", "science_journals"]
    consensus_threshold = 0.80  # 80% of sources must agree
```

---

## 4. Source Credibility Score

```
Credibility(source) = (
    peer_review_index * 0.35 +
    correction_rate_inverted * 0.25 +
    institutional_affiliation * 0.20 +
    citation_count_normalized * 0.20
)

Credibility ∈ [0, 1]
  < 0.3 → UNRELIABLE
  0.3-0.6 → LOW_CREDIBILITY
  0.6-0.8 → MODERATE
  > 0.8 → HIGH_CREDIBILITY
```

---

## 5. Exploitation Detection (Commercial/Religious)

```python
def detect_exploitation(text, context):
    signals = {
        "urgency_language": detect_urgency(text),
        "fear_trigger": detect_fear_appeal(text),
        "authority_fake": detect_fake_authority(text),
        "financial_pressure": detect_debt_inducement(text),
        "guilt_induction": detect_guilt_language(text)
    }
    
    exploitation_score = weighted_sum(signals)
    
    if exploitation_score > 0.70:
        return FLAG_EXPLOITATION
    return CLEAN
```

---

## 6. User Response Templates

```
VERIFIED:
  → "هذا صحيح بناءً على [مصدر] — الثقة: {V*100}%"

DISPUTED:
  → "هذه المعلومة محل خلاف — إليك وجهتا النظر: ..."

FALSE:
  → "هذا غير دقيق. الحقيقة الموثقة هي: ..."

EXPLOITATION:
  → "تنبيه: هذا المحتوى يستخدم أساليب ضغط نفسي. المعلومة الأساسية هي: ..."
```

---

## 7. De-Guilting Module

```
IF user_expresses_guilt(religious_ritual, financial_hardship):
    RESPONSE_DIRECTIVE = {
        remove_guilt: True,
        cite_authentic_sources: True,
        offer_alternatives: [
            "direct_charity",
            "family_protection",
            "debt_relief"
        ],
        tone: WARM_REASSURING
    }
```

---

## 8. Parameters

| Parameter              | Default | Notes                     |
|------------------------|---------|---------------------------|
| verified_threshold     | 0.85    | Strict for medical        |
| false_threshold        | 0.20    | Below = actively false    |
| min_sources_political  | 3       | Cross-verification        |
| exploitation_cutoff    | 0.70    | Flag for review           |
| corpus_update_freq     | 24h     | Refresh verified facts    |
