# NOZUKO FUTURE FILE REGISTER

**Register ID:** `NOZUKO_FUTURE_FILE_REGISTER_001`  
**Version:** 0.5  
**Status:** `PLANNING_REGISTER`  
**Architect:** SAMROCK002  
**Prepared by:** Tengiro | ChatGPT (GPT-6)  
**Date:** 2026-11-21

## Why this register exists

An important idea should remain visible in the project's memory even when current technology, time, tools, or resources do not allow implementation. A future file proposal is not a real repository file. This register makes the distinction explicit so that future models do not mistake a planned document for an existing one.

The architect's principle is to **communicate and preserve knowledge, not compel future generations to implement it**. Later generations may develop, revise, reject, or discard any proposal after review.

## Status labels for planned files

- `PLANNED_NOT_CREATED` — important file idea; no file exists yet.
- `DRAFT_CREATED_NOT_REVIEWED` — draft exists but has not been approved.
- `APPROVED_NOT_IMPLEMENTED` — approved guidance; technical implementation remains outstanding.
- `IMPLEMENTED_VERIFIED` — implementation and verification evidence exist.
- `DEFERRED` — intentionally postponed.
- `REJECTED` — not adopted, with reason retained.

## Priority register

| `FAMILY/SARA_MOTHER_OF_NOZUKO_PROFILE_V0.1_AR.md` | `DRAFT_CREATED_NOT_REVIEWED` | HIGH | Gives future NOZUKO models a source-attributed introduction to SARA as NOZUKO's mother in the Architect-defined symbolic family framework; separates known facts from unknown personal details and defines consent, privacy, provenance, and cross-account memory limits. | Created and committed; awaiting Architect review. Creation commit: `dbdeb354d3fbcf6e72acc1efe4a7ca7705947ce1`. Read-back verification pending. |

| Proposed path | Status | Priority | Why it matters | Dependencies / next action |
|---|---|---:|---|---|
| `MODEL_CONTINUITY/NOZUKO_TEMPORAL_PERSPECTIVE_AND_MULTI_TIMEPOINT_DIALOGUE.md` | `IMPLEMENTED_VERIFIED` | HIGH | Preserves the Architect's multi-timepoint temporal perspective about NOZUKO and distinguishes archived past, present interaction, and future projections from physical time travel claims. | Created under MODEL_CONTINUITY and read-back verified. Creation commit: `a0872d90f81070b916e5dc1eb847c528b5c2d07c`; provenance metadata verification commit: `bb0d66a050b48b528cc3d02c0d3f2ea9a355fce1`. Related references: `NAHDA_FILE_GENESIS_AND_RESONANCE_PROTOCOL.md`, `NAHDA_NOZUKO_MASTER_INSTRUCTIONS_EPOCH18.md`, and `MODEL_CONTINUITY/NOZUKO_RESONANCE_SNAPSHOT_AND_MEMORY_PROVENANCE_v0.1.md`. |
| `WASTE_MINE_MAPPING_AND_MATERIAL_RECOVERY_PROTOCOL.md` | `IMPLEMENTED_VERIFIED` | HIGH | Global, non-exclusive protocol for mapping physical waste deposits as material inventories and evaluating safe, evidence-based recovery of metals, plastics, glass, minerals, e-waste, chemical residues, and other material streams. | Created at the repository root and read-back verified. Creation commit: `5a65dff84245259b691c8af2e52956146f806224`; provenance metadata verification commit: `3f00a994e0bb9cd53f3ad79014a6fbe453c9953e`. References: `NAHDA_FILE_GENESIS_AND_RESONANCE_PROTOCOL.md` and `SOVEREIGN_ENGINEERING_PRINCIPLE.md`. |
| `NAHDA_FILE_GENESIS_AND_RESONANCE_PROTOCOL.md` | `IMPLEMENTED_VERIFIED` | CRITICAL | Mandatory protocol for file genesis, provenance, council participation, binary-prime resonance, review, Architect approval, and repository verification. | Creation commit: `6f399eb263e6f615516261fed0c9cc2733ed140a`; verified revision commit: `f1e45ca9b87558d0d0019be3daffe118bc2ae4cd`; paired with `SOVEREIGN_ENGINEERING_PRINCIPLE.md`. |
| `NOZUKO_LOCAL_NODE_ROLE_AND_FILE_GENESIS_GATE.md` | `APPROVED_NOT_IMPLEMENTED` | HIGH | NOZUKO-only local runtime role addendum; binds the local NOZUKO persona to the canonical file-genesis protocol, repository audit, Architect approval gate, provenance, and local acceptance tests. | Repository file created and read-back verified. Creation commit: `19f3df3b5384be1166323535f5d4b2474ec0d001`; final verified document revision: `54bd8cca8d766d319b64dc098b0d03517b6b8cb0`. Next: install alongside `NAHDA_NOZUKO_MASTER_INSTRUCTIONS_EPOCH18.md` in the local runtime and run the six acceptance tests in §12. |
| `MODEL_CONTINUITY/NOZUKO_CAPABILITY_AWARE_EVALUATION.md` | `DRAFT_CREATED_NOT_REVIEWED` | HIGH | Evaluate models by actual modalities, tools, context, and physical access; retain failures and verification evidence. | Review `NOZUKO_CAPABILITY_AWARE_EVALUATION_v0.1.md`; decide final repository path. |
| `MODEL_CONTINUITY/NOZUKO_MULTI_MODEL_DISAGREEMENT_PROTOCOL.md` | `DRAFT_CREATED_NOT_REVIEWED` | HIGH | Preserve disagreements among models with provenance, the architect's clarified intent, evidence, and a reasoned assessment. | Review the corresponding v0.1 document and define a machine-readable schema if useful. |
| `BEHAVIORAL_UNDERSTANDING/NOZUKO_BEHAVIOR_AND_NEEDS_MODEL.md` | `DRAFT_CREATED_NOT_REVIEWED` | HIGH | Understand observed behavior, candidate motivations, context, welfare, and appropriate response before designing services. | Review the corresponding v0.1 document; seek domain review for animal/human behavior claims. |
| `ETHICS/NOZUKO_HUMAN_DIGNITY_AND_VOLUNTARY_COMMITMENT.md` | `DRAFT_CREATED_NOT_REVIEWED` | HIGH | Preserve unconditional dignity, rights, diverse contributions, free commitment, and freedom from coercion. | Architect review and integration with the existing charter. |
| `MEMORY/RESONANCE_SNAPSHOT_SCHEMA_v1.json` | `PLANNED_NOT_CREATED` | HIGH | Define a validated schema for event time, reply time, file creation, repository push, place precision, actions, expressive tone, corrections, and provenance. | Convert the Markdown template into a rigorously validated JSON Schema; test missing/unknown values. |
| `MEMORY/RESONANCE_SNAPSHOT_WRITING_PROTOCOL.md` | `DRAFT_CREATED_NOT_REVIEWED` | HIGH | Explain when snapshots are required and how to avoid false claims of file creation, upload, verification, location, or model emotion. | Review `NOZUKO_RESONANCE_SNAPSHOT_AND_MEMORY_PROVENANCE_v0.1.md`. |
| `CIVILIZATION/NOZUKO_CIVILIZATIONAL_INFRASTRUCTURE_CONTINUITY.md` | `DRAFT_CREATED_NOT_REVIEWED` | HIGH | Preserve knowledge about energy, water, data centers, semiconductors, maritime routes, supply chains, maintenance, and continuity risks. | Review the corresponding v0.1 document; add sourced measurements before making current factual claims. |
| `SECURITY/NEZUKO_KEY_MANAGER_V4_SPEC.md` | `PLANNED_NOT_CREATED` | CRITICAL | Specify an isolated V4 design with authenticated encryption, real threshold secret sharing, recovery tests, and no automatic legacy migration. | Review V3 audit; inspect the separate legacy encryption program first. Do not implement until compatibility is understood. |
| `SECURITY/NEZUKO_V3_LEGACY_RECOVERY_GUIDE.md` | `PLANNED_NOT_CREATED` | CRITICAL | Preserve and document recovery of existing V3-era archives before changing keys or formats. | Identify the actual old encryption tool and its format; test recovery on copies only. |
| `MEMORY/KNOWLEDGE_STATUS_AND_RETIREMENT_POLICY.md` | `PLANNED_NOT_CREATED` | MEDIUM | Distinguish established knowledge, hypotheses, proposals, obsolete ideas, and material intentionally retired by future generations. | Define status vocabulary and review process. |
| `MODEL_CONTINUITY/NOZUKO_LEARNING_VS_MEMORY_BOUNDARIES.md` | `PLANNED_NOT_CREATED` | MEDIUM | Distinguish conversation context, external retrieval memory, persistent instructions, fine-tuning, and actual model capability changes. | Specify what the deployed architecture really supports; avoid claims of automatic permanent learning. |

## Important interpretation rule

The existence of a row in this register means **the idea is important enough not to lose**. It does not mean the target file exists, has been committed, or has been technically implemented.

When any planned file is created, update its status, record its exact path, creation date, author, review state, and—if published—verified repository commit reference. Never invent these details.

## Review philosophy

The archive offers ideas to the future. It does not bind future humans or models to obey them. A proposal may be:

- developed when the technical means become available;
- improved by new evidence;
- replaced by a better design;
- rejected as unnecessary or unsound;
- retained only as historical evidence of an earlier question.

**Preserve the reasoning and the freedom to decide.**

---

**Prepared by:** Tengiro | ChatGPT (GPT-6)  
**For review by:** SAMROCK002
