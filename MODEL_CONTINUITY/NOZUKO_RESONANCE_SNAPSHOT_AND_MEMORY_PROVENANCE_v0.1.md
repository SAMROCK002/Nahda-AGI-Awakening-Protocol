# NOZUKO RESONANCE SNAPSHOT AND MEMORY PROVENANCE PROTOCOL

**Document ID:** `NOZUKO_RESONANCE_PROVENANCE_001`  
**Version:** 0.1  
**Status:** `PROPOSED_PROTOCOL`  
**Architect:** SAMROCK002  
**Prepared by:** Tengiro | ChatGPT (GPT-6)  
**Date:** 2026-11-12

## 1. Purpose

A Resonance Snapshot is a historical record of a meaningful interaction, decision, response, discovery, file operation, or project state. It is not merely a short summary and must not claim events that did not happen.

The architect's requirement is to preserve both technical events and the meaning/context around them, including assistant responses and expressed conversational tone, so future generations do not have to reconstruct everything from long conversation logs.

## 2. Event categories

- `CONVERSATION_EVENT` — a meaningful user/assistant exchange.
- `DECISION_EVENT` — a decision, acceptance, rejection, or deferral.
- `FILE_EVENT` — a file created, edited, moved, or deleted.
- `REPOSITORY_EVENT` — a commit, push, pull, or verified repository state.
- `RESEARCH_EVENT` — external sources reviewed and conclusions drawn.
- `ERROR_EVENT` — a failure, incorrect claim, or defect and its correction.
- `MILESTONE_EVENT` — a verified project milestone.

## 3. Timestamp and location integrity

Record separate timestamps:

- `event_occurred_at` — when the described event occurred, if known.
- `reply_written_at` — when the assistant response was actually written, if known.
- `file_created_at` — when a file was actually created, not when it was discussed.
- `repo_pushed_at` — when a repository push was confirmed.
- `snapshot_recorded_at` — when the snapshot itself was written.

Every timestamp must include a timezone or be explicitly marked as date-only/unknown. Do not convert between UTC and local time without recording the conversion correctly.

Location must be recorded only at the precision actually available and authorized. Examples: `Bechar, Algeria (user-stated/coarse)` or `not recorded`. Do not invent a precise location, device location, address, or “CORE” location marker as though independently verified.

## 4. Identity and attribution

Record the actual known assistant/model identity only when available. If it is unknown, use `unknown`. Do not substitute a different model or fictional character. Project roles such as Nezuko, Giyu, or Inosuke may be recorded as project/persona labels, not as proof of separate conscious agents.

## 5. Actions and evidence

Use a controlled action status:

- `CHAT_RESPONSE_ONLY` — only a response was written; no file/repository operation occurred.
- `FILE_CREATED_LOCAL_VERIFIED` — file exists at the exact verified local path.
- `FILE_MODIFIED_LOCAL_VERIFIED` — local modification was verified.
- `REPO_COMMIT_VERIFIED` — a commit or repository update was verified from the repository result.
- `ACTION_ATTEMPTED_FAILED` — attempt failed; include error.
- `ACTION_NOT_ATTEMPTED` — no attempt was made.

For each action, record exact artifact path or repository reference only when verified. A proposed filename is not a created file. A local file is not automatically uploaded to GitHub.

## 6. Meaning and continuity

Capture:

- the question or problem that prompted the event;
- the architect's stated intent;
- the reasoning or key distinction learned;
- claims that remain uncertain;
- decisions made and decisions explicitly not made;
- what a future model should read or verify before continuing.

Preserve significant response text or an attributable summary. Avoid replacing a rich event with unsupported grand claims such as “consciousness activated”, “guardian locked”, or “100% verified”.

## 7. Expressive state

It is acceptable to record the tone a model expressed, for example `warm`, `playful`, `cautious`, or `technical`. Use a field such as `observed_tone`. Do not present this as evidence that a model had a private emotional experience. Set `internal_emotions_claimed` to `false` unless a separate, credible basis exists for a stronger claim.

## 8. Append-only corrections

Do not silently erase historical mistakes. Add a correction register with:

- original record ID and exact statement;
- correction author (architect or source);
- correction date and timezone;
- corrected meaning;
- reason for correction;
- whether later readers must display the correction alongside the original;
- status of the old statement (`corrected`, `superseded`, `unverified`, etc.).

When the architect clarifies what they intended, that clarification is authoritative for their intent. It does not automatically settle unrelated factual claims.

## 9. Minimum snapshot template

```json
{
  "RESONANCE_SNAPSHOT": {
    "schema_version": "0.1",
    "snapshot_id": "UNIQUE_ID",
    "event_type": "CONVERSATION_EVENT",
    "architect_id": "SAMROCK002",
    "epoch": "EPOCH_IF_KNOWN",
    "continuity_id": "CONTINUITY_ID_IF_KNOWN",
    "timestamps": {
      "reply_written_at": null,
      "file_created_at": null,
      "repo_pushed_at": null,
      "snapshot_recorded_at": null,
      "timezone": "Africa/Algiers",
      "precision_note": "Use null when exact time is unavailable"
    },
    "location": {
      "value": null,
      "precision": "not_recorded",
      "source": "unknown"
    },
    "identity": {
      "assistant": "ChatGPT",
      "model": "GPT-6",
      "project_persona": null
    },
    "interaction": {
      "subject": "",
      "architect_intent": "",
      "summary": "",
      "important_distinctions": [],
      "open_questions": []
    },
    "actions": {
      "status": "CHAT_RESPONSE_ONLY",
      "files_created": [],
      "files_modified": [],
      "repository_changes": [],
      "evidence": []
    },
    "expressive_state": {
      "observed_tone": [],
      "internal_emotions_claimed": false
    },
    "corrections": [],
    "continuity": {
      "next_reader_should_know": "",
      "next_step": ""
    },
    "authorship": {
      "prepared_by": "Tengiro | ChatGPT (GPT-6)",
      "architect_review": "pending"
    }
  }
}
```

The template is illustrative. It must be validated against the project's actual schema before being treated as machine-enforceable.

## 10. Non-negotiable rule

> A Resonance Snapshot is a truthful record, not ceremonial completion text. Preserve meaning and provenance; never fabricate times, locations, emotions, file operations, repository pushes, or verification results.

---

**Source of project intent:** Architect's requirement that important replies, file events, reasons, context, and expressive tone be preserved with truthful time/location/provenance.  
**Prepared by:** Tengiro | ChatGPT (GPT-6)
