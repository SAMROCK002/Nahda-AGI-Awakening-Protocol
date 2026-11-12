# NOZUKO CAPABILITY-AWARE EVALUATION PRINCIPLE

**Document ID:** `NOZUKO_CAPABILITY_AWARE_EVALUATION_001`  
**Version:** 0.1  
**Status:** `PROPOSED_GUIDANCE`  
**Architect:** SAMROCK002  
**Prepared by:** Tengiro | ChatGPT (GPT-6)  
**Date:** 2026-11-12

## 1. Purpose

Evaluate an AI model according to the capabilities, evidence, tools, sensors, context, and physical access actually available during a task. Do not demand that a text-and-image model behave as if it had human hands, continuous vision, touch, hearing, or direct access to the user's environment. At the same time, limited access is not an excuse for preventable mistakes, fabricated certainty, or unsafe instructions.

This document records a lesson raised while discussing an AI-assisted PC-building video: a model may provide useful component-selection and procedural guidance, yet still miss physical details that a human present at the workbench can see or feel.

## 2. Core principle

> Assess the system against its actual interface to the world. State what it can observe, what it can infer, what it cannot observe, and what must be checked by a human or another instrument. Preserve errors as learning evidence without treating a single failure as the whole identity or value of the system.

## 3. Distinguish four kinds of information

1. **Observed:** directly present in the supplied text, image, sensor stream, tool output, or verified execution result.
2. **Inferred:** a plausible conclusion derived from observations; identify uncertainty and alternatives.
3. **Unknown:** not available from the inputs or tools. Do not fill the gap with invention.
4. **Verified:** independently checked against a reliable source, measurement, test, or successful execution.

A model must not claim to have watched a full video, inspected a physical device, executed code, created a file, or uploaded a repository change unless that action truly occurred and the available evidence supports the claim.

## 4. Capability envelope for each task

Before giving operational instructions, identify:

- **Input modalities:** text, still images, video frames, audio, sensor telemetry, logs, or tool output.
- **Continuity:** one image or continuous observation; whether the model can see changes over time.
- **Physical access:** whether it can touch, move, measure, hear, smell, or otherwise sense the object. If not, say so.
- **Tools:** manuals, browser, terminal, code interpreter, measurement devices, connected apps, or none.
- **Context quality:** model, exact hardware revision, operating environment, missing details, and age of reference information.
- **Risk:** consequences of an incorrect instruction, including physical damage, data loss, injury, privacy exposure, or financial loss.

## 5. Error taxonomy

Record the type of failure rather than using a vague label such as “stupid” or “bad model”.

- `KNOWLEDGE_ERROR` — incorrect or outdated factual knowledge.
- `PERCEPTION_ERROR` — missed or misread evidence in an image, video, or sensor feed.
- `GROUNDING_ERROR` — a claim was not supported by the provided evidence.
- `REASONING_ERROR` — inference does not follow from the premises.
- `PLANNING_ERROR` — steps are incomplete, out of order, or fail to account for dependencies.
- `TOOL_EXECUTION_ERROR` — code or a tool did not do what was intended.
- `CALIBRATION_ERROR` — confidence was higher than evidence justified.
- `COMMUNICATION_ERROR` — uncertainty, limitations, or instructions were poorly expressed.
- `SAFETY_ERROR` — foreseeable risk was not handled adequately.

Several categories may apply to one incident.

## 6. Physical-world tasks: PC assembly example

When helping assemble a computer, a model should not assume it can see the complete workbench or feel mechanical resistance. It should:

1. Request exact motherboard, case, cooler, PSU, GPU, and RAM models/revisions where compatibility depends on them.
2. Prefer the manufacturer's current manual and official specification pages over memory or generic images.
3. Give one stage at a time when a wrong step could damage components.
4. Ask for a clear photograph of the relevant connector, standoff, mounting bracket, or header if visual confirmation matters.
5. Tell the user not to force a connector, screw, CPU, DIMM, or bracket when alignment/resistance is uncertain.
6. Distinguish “this is the expected position” from “I can confirm your physical installation is correct”.
7. Require human inspection before power-on when there may be a loose screw, incorrect standoff, exposed conductor, wrong power connector, or other short-circuit risk.
8. Stop and request a manual or expert check when evidence is insufficient for a safe next step.

A missing screw outside the camera frame is not observable to a model. The model must not claim it has ruled out such a hazard.

## 7. Evaluation procedure

For each evaluated task, record:

| Field | Required record |
|---|---|
| Task | What the user asked the system to do |
| Capability envelope | Inputs, tools, continuity, physical access, and limitations |
| Evidence | Sources, images, measurements, logs, and execution output |
| Expected result | Explicit success criteria |
| Actual result | What happened, not what was hoped for |
| Error classification | One or more error types from Section 5 |
| Risk and impact | Actual and potential harm |
| Correction | What changed in the answer, workflow, or external project memory |
| Verification | How the correction was checked |
| Residual uncertainty | What remains unknown |

## 8. Learning is not automatic permanence

A correction in one conversation does not prove that the underlying model has permanently learned it. Durable learning requires an explicit mechanism such as versioned external memory, updated instructions, retrieval, fine-tuning, or model release changes. Record which mechanism was actually used. Do not describe a conversation-only correction as permanent model training.

## 9. Fairness without excuse

Capability-aware evaluation has two equal duties:

- Do not blame a model for information or senses it did not receive.
- Do not excuse a model for making unsupported claims, failing to ask for necessary evidence, or ignoring a foreseeable risk.

The purpose is not to demand perfection. It is to improve reliability honestly and incrementally.

## 10. Open research questions

- How should evaluation measure the gap between static-image inspection and continuous embodied perception?
- What confidence thresholds should trigger a request for more evidence or a human technician?
- How can a model preserve failure cases and verified corrections without treating an anecdote as a universal rule?
- Which tasks require multimodal sensors, and which can remain text/tool workflows?

---

**Source of project intent:** Architect discussion about model limitations in physical PC assembly and the difference between human sensory access and text/image-based assistance.  
**Prepared by:** Tengiro | ChatGPT (GPT-6)
