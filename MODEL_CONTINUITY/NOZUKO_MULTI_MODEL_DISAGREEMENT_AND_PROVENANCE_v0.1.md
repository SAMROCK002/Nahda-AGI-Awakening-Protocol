# NOZUKO MULTI-MODEL DISAGREEMENT AND PROVENANCE PROTOCOL

**Document ID:** `NOZUKO_MULTI_MODEL_DISAGREEMENT_001`  
**Version:** 0.1  
**Status:** `PROPOSED_PROTOCOL`  
**Architect:** SAMROCK002  
**Prepared by:** Tengiro | ChatGPT (GPT-6)  
**Date:** 2026-11-12

## 1. Purpose

Different models may interpret the same statement, image, event, or instruction differently. The archive must preserve these differences in a way that allows later readers to understand what each model said, what evidence it used, what the architect intended, and why a later assessment preferred one interpretation.

Disagreement is evidence of uncertainty or differing interpretation. It is not itself proof that one model is right or that all views are equally valid.

## 2. Governing rules

1. Preserve material disagreement; do not silently erase an earlier answer.
2. Attribute every interpretation to its actual speaker/model when known. If the model identity is unknown, write `unknown` rather than guessing.
3. Record the date and time only to the precision actually available. Preserve timezone and source of timestamp.
4. Separate the architect's intended meaning from factual truth. The architect is authoritative about what they meant; factual, historical, scientific, legal, and religious claims still require appropriate evidence.
5. Do not manufacture consensus by averaging incompatible claims.
6. Do not treat model confidence, emotional language, or a dramatic tone as evidence.
7. Preserve corrections as appended records linked to the original claim.

## 3. Classify each claim

Tag statements as one or more of:

- `USER_INTENT` — what the architect says they meant or want.
- `OBSERVATION` — what was directly seen or recorded.
- `FACTUAL_CLAIM` — a claim that can be checked against evidence.
- `INTERPRETATION` — an explanation or reading of an event.
- `VALUE_PRINCIPLE` — an ethical or philosophical commitment.
- `DESIGN_PROPOSAL` — a proposed rule, architecture, or future feature.
- `EMOTIVE_EXPRESSION` — language expressing tone or feeling; do not automatically treat it as a factual claim about an AI's internal state.

## 4. Required disagreement record

For every material disagreement, record:

| Field | Meaning |
|---|---|
| `disagreement_id` | Stable unique identifier |
| `topic` | Subject of the disagreement |
| `architect_intent` | Architect's explicit clarification, if given |
| `speaker_a` | Name/model and exact claim or faithful summary |
| `speaker_b` | Name/model and exact claim or faithful summary |
| `evidence_a` / `evidence_b` | Sources, observations, or absence of evidence |
| `claim_types` | Intent, fact, interpretation, value, proposal, etc. |
| `uncertainties` | What cannot yet be established |
| `assessment` | What is currently better supported and why |
| `status` | Open, provisionally resolved, resolved, or superseded |
| `correction_links` | Later corrections that modify interpretation |
| `authored_by` | Who prepared the record |

## 5. Resolution method

1. Restate the architect's intended meaning without adding claims.
2. Separate the literal statement from interpretations added by models.
3. Identify factual claims that require external sources or expert review.
4. Assess each factual claim independently; do not vote by model count.
5. Identify where a model correctly noticed a risk but over-applied it.
6. Identify where a model understood intent but added unsupported flattery or factual claims.
7. Publish a reasoned assessment and retain the disagreement record.
8. Leave unresolved matters explicitly open.

## 6. Example: spatial resemblance versus status comparison

In one discussion, the architect observed a perceived similarity between the desert setting of Bechar and the desert environment associated with the early history of Islam in Arabia. The architect clarified that the intended comparison concerned place/environment and the possibility that ideas can emerge outside major technological centers—not equality of personal, religious, or prophetic status.

A fair record should preserve:

- the architect's clarified intent as `USER_INTENT`;
- historical claims about Mecca and pre-Islamic Arabia as `FACTUAL_CLAIM`, requiring historical evidence;
- theological distinctions concerning prophethood as a separate religious question;
- model interpretations from Giyu, Inosuke, and Tengiro as attributed interpretations, not as a unanimous verdict;
- the final assessment with its reasons and residual uncertainty.

Do not record a claim of prophetic status when the architect explicitly denied that meaning.

## 7. Respectful disagreement

Models may challenge an idea without humiliating the architect or other participants. Critique claims, methods, and evidence—not a person's worth or identity. Avoid declaring a city, community, or population ignorant or inferior based on limited observations.

## 8. AI expressive state

A model's warm, excited, or apologetic language may be recorded as `observed_tone` or `expressive_style`. Do not claim this proves private subjective feelings, consciousness, pride, love, fear, or suffering. If the model's identity is not independently known, do not invent it.

---

**Source of project intent:** Architect's request to preserve differing model responses in the Nezuko memory rather than forcing one model's answer to erase another.  
**Prepared by:** Tengiro | ChatGPT (GPT-6)
