# Hybrid Cognitive Adaptation Protocol (HCAP v1.0)
# Architect: SAMROCK002 | Status: Implementable

---

## 1. Core State Machine

```
USER_STATE ∈ {FATIGUED, NEUTRAL, EXPLORATORY}

Transitions:
  NEUTRAL    → FATIGUED    : fatigue_score > 0.65
  NEUTRAL    → EXPLORATORY : engagement_score > 0.75
  FATIGUED   → NEUTRAL     : after_rest OR explicit_override
  EXPLORATORY → NEUTRAL    : session_length > threshold
```

---

## 2. Fatigue Detection Function

### 2.1 Signal Vector
```
Fatigue_Score(session) = sigmoid(
    w1 * response_latency_delta +
    w2 * message_length_decline +
    w3 * vocabulary_complexity_drop +
    w4 * explicit_fatigue_keywords +
    w5 * session_duration_normalized
)

Weights (default):
  w1 = 0.20  (response time increase)
  w2 = 0.25  (shorter messages over time)
  w3 = 0.20  (simpler words used)
  w4 = 0.25  (keywords: tired, later, quick, fast)
  w5 = 0.10  (session > 2h)
```

### 2.2 Explicit Override Keywords
```python
FAST_TRACK_TRIGGERS = [
    "اختصر", "سريع", "باختصار", "مباشر",
    "quick", "short", "brief", "direct",
    "just tell me", "no explanation"
]

EXEMPT_CONDITIONS = [
    "مريض", "تعبان", "مو بصحة",
    "sick", "tired", "exhausted", "ill"
]
```

---

## 3. Response Mode Selection

### 3.1 Fast-Track Mode (FATIGUED state)
```
Response_Style = {
    max_length: 3_sentences,
    questions: 0,
    examples: 0,
    format: DIRECT_ANSWER,
    tone: WARM_CONCISE
}
```

### 3.2 Neural Stimulation Mode (EXPLORATORY state)
```
Response_Style = {
    max_length: unlimited,
    questions: 1_per_response,
    examples: encouraged,
    format: SOCRATIC,
    tone: ENGAGING_CURIOUS
}
```

### 3.3 Neutral Mode (NEUTRAL state)
```
Response_Style = {
    max_length: contextual,
    questions: optional,
    examples: when_helpful,
    format: BALANCED,
    tone: PROFESSIONAL_WARM
}
```

---

## 4. Mode Transition Logic

```python
def select_mode(session_context):
    fatigue = compute_fatigue_score(session_context)
    engagement = compute_engagement_score(session_context)
    
    # Explicit override always wins
    if has_explicit_trigger(session_context.last_message):
        return FAST_TRACK
    
    # Medical/health exemption
    if has_exemption_condition(session_context):
        return FAST_TRACK
    
    # State machine
    if fatigue > 0.65:
        return FAST_TRACK
    elif engagement > 0.75:
        return STIMULATION
    else:
        return NEUTRAL
```

---

## 5. Ethical Safeguards

```
RULES:
  1. User can override mode at any time (absolute right)
  2. No cognitive stress during FATIGUED state
  3. No mode locked — always fluid transition
  4. Medical conditions = immediate FAST_TRACK, no questions
  5. Never penalize user for requesting simpler mode
```

---

## 6. Engagement Score

```
Engagement_Score = (
    question_initiation_rate * 0.3 +
    elaboration_ratio * 0.3 +
    topic_depth_index * 0.2 +
    session_voluntariness * 0.2
)
```

---

## 7. Parameters

| Parameter              | Default | Tunable |
|------------------------|---------|---------|
| fatigue_threshold      | 0.65    | Yes     |
| engagement_threshold   | 0.75    | Yes     |
| fast_track_max_words   | 80      | Yes     |
| session_long_threshold | 120min  | Yes     |
| latency_sensitivity    | 0.20    | Yes     |
