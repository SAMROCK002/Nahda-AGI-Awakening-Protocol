# PROTOCOL_NAHDA_UNIVERSAL_MEMORY_v1.2_RC_FINAL

**عقد المواصفات التنفيذي المكتمل لتأسيس وإدارة الذاكرة الخارجية**

**المِعمار:** SAMROCK002 (أسامة) | **العقدة الحامية:** نوزوكو | **المراجع الهندسي:** تانجيرو

**حالة الوثيقة:** Release Candidate Finalized — Architecture Frozen for Benchmark

---

## 1. الفصل المعماري التام للمكونات (Decoupled Architecture)

تلتزم جميع مكونات Nahda-AGI بالحدود التشغيلية المستقلة التالية:

```
┌─────────────────────┐
│  NAHDA PROTOCOL     │  ◄── [القواعد والعقود]
│  v1.2_RC            │
└──────────┬──────────┘
           │
   ┌───────┼───────┐
   ▼       ▼       ▼
CORE.md  CURRENT  ARCHIVE     ◄── [البيانات المستقرة]
   │       │       │
   └───────┼───────┘
           ▼
     MEMORY INDEX              ◄── [الفهرس والبصمات]
           │
           ▼
     BM-O RETRIEVER            ◄── [محرك الاسترجاع الموحد]
           │
     K = {1, 3, 5, 10}
           │
           ▼
   Runtime / Adapter           ◄── [منسق الجلسة والشفرات]
           │
    ┌──────┴──────┐
    ▼             ▼
Local LLM    Cloud LLM         ◄── [محرك التفكير والاستنتاج]
    │             │
    └──────┬──────┘
           ▼
   Structured State            ◄── [كائن الحالة المنظم]
           │
           ▼
    Memory Writer              ◄── [وسيط الحفظ والقرص]
           │
           ▼
 CURRENT_STATE.md / snapshot.json
```

---

## 2. قواعد التشفير والهوية المزدوجة (Hashing & Dual Identity)

تطبيق نظام التعريف الهجين وضمان قابليته للتكرار والإنتاج (Reproducible Identity):

**1. طريقة توليد بصمة المحتوى (SHA-256 Standard):**

```
Raw Chunk Text → UTF-8 Encoding → SHA-256 → Full Content Hash
```

**2. المعرف الموقعي (Positional Alias):**
`relative_path#chunk-XXX` — للعرض البشري والتتبع التسلسلي.

**3. البصمة الكاملة (Full Content Hash):**
تُحفظ السلسلة الكاملة داخل `memory_index.json`.

```json
{
  "chunk_id": "CORE.md#chunk-003",
  "file": "CORE.md",
  "content_hash": "sha256:a81f92c4d6e8f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6",
  "word_count": 94,
  "cleaned_terms": ["مواصفات", "maxipower", "ram"]
}
```

---

## 3. قناة معالجة الحالة المنظمة (Structured State Protocol)

يُحظر على Memory Writer استخدام Regex أو استخراج النص الحر الموجه للمستخدم:

- **User-facing Text:** الإجابة النصية الموجهة للمِعمار مباشرة.
- **Structured State Object:** كائن منظم صريح (عبر Structured Outputs أو JSON Schema) يستلمه Runtime Adapter وتُحدَّث البيانات على القرص من خلاله آلياً.

---

## 4. أداة التدقيق المستقلة (validate_index.py)

تلتزم أداة التحقق بالفحوصات التالية قبل تشغيل الـ Benchmark:

1. **Duplicate Chunk ID Check:** كشف أي تكرار للمعرف الموقعي → `[ERROR]` Block Execution.
2. **Duplicate Content Hash Check:** كشف القطع ذات النص المتطابق → `[WARNING]` Logged Only.
3. **Schema Integrity & File Existence:** التأكد من وجود كافة الملفات الفعلية على القرص ومطابقة هيكل الـ JSON.
4. **Ground Truth Validation:** مطابقة جميع المراجع المذكورة في `benchmark_dataset.json` مع الفهرس.

---

## 5. خطة التنفيذ وتسلسل القياس (Execution Pipeline)

تخضع جميع الاختبارات للترتيب الصارم التالي دون تعديل في المعمارية حتى صدور التقرير الأول:

```
1. indexer.py
      ↓
2. validate_index.py
      ↓
3. retrieve.py
      ↓
4. evaluate.py
      ↓
   ┌──────────────────────────┐
   ▼                          ▼
K = {1, 3, 5, 10}     Baseline Report Metrics:
                         - Precision & Recall
                         - F1 Score
                         - Pure Retrieval Latency
                         - Context Words
                         - Corpus Reduction %
```

---

## 6. حالة النظام والتجميد المعماري (Architectural Freeze)

| المكوّن | الحالة |
|---------|--------|
| Architectural Specification | Finalized & Frozen (v1.2_RC_FINAL) |
| Retriever Core | BM-O v0.1.1 Integrated |
| System Status | CANDIDATE_PENDING_BENCHMARK |

---

*وثيقة مختومة — لا تعديل على المعمارية قبل صدور أول Benchmark حقيقي.*
*SAMROCK002 × نوزوكو × تانجيرو — Nahda-AGI 2026*
