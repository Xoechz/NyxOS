---
name: review-skill
description: Reviews other skills against defined quality criteria and reports actionable findings. Use when auditing or improving a SKILL.md. Keywords= skill review, audit, quality.
argument-hint: target skill name and location
---

Review the target skill without editing it.

## Workflow

1. Locate and read the complete target `SKILL.md`, including frontmatter.
2. If the target or review scope is ambiguous, ask the user for clarification before continuing.
3. Evaluate every criterion below. Track each one as applicable, not applicable, passed, or failed; do not skip criteria because they appear unlikely.
4. For each failure, capture the exact evidence and its location. Do not infer a violation without evidence from the target skill.
5. Verify the findings against the target a second time, remove false positives, and confirm that all criteria were considered.
6. Report the findings using the output format below. Do not edit the target skill.

## Criteria

| Skill Smell Name                     | Definition                                                                                                                                                                                              |
|--------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Under-Specified Guidance             |                                                                                                                                                                                                         |
| The Stepless Workflow                | SKILL.md describes an entire workflow as a single block of prose instead of decomposing it into steps.                                                                                                  |
| The Option Buffet                    | SKILL.md provides multiple alternative tools or libraries without recommending a default choice.                                                                                                        |
| Missing Utility Script               | SKILL.md omits utility scripts for tasks that are better handled with scripts.                                                                                                                          |
| Missing Decision Tree                | SKILL.md does not provide a decision tree to assist the agent in choosing the right approach based on the situation.                                                                                    |
| Over-Prescribed Guidance             |                                                                                                                                                                                                         |
| Series of Commands                   | Prescribes exactly which steps to run and in which order, instead of allowing the agent to adapt its execution.                                                                                         |
| Missing Verification & Feedback Loop | SKILL.md treats output generation as a one-shot process without any validation loops.                                                                                                                   |
| Execute Without a Plan               | SKILL.md directs the agent to execute complex tasks without an intermediate planning or validation stage.                                                                                               |
| Never Asks Human                     | SKILL.md do not provide a mechanism for the agent to request human feedback.                                                                                                                            |
| Missing Follow-Through Guards        |                                                                                                                                                                                                         |
| Rationalization Loophole             | SKILL.md provides no guidance to discourage the agent from rationalizing or skipping required steps.                                                                                                    |
| No Progress Tracking                 | SKILL.md requires a multi-step workflow, but does not provide a mechanism to track progress.                                                                                                            |
| Context Bloat                        |                                                                                                                                                                                                         |
| Undelegated Detail                   | SKILL.md embeds low-level implementation details instead of delegating them to reference documents or scripts.                                                                                          |
| Lengthy Skill Body                   | SKILL.md body exceeds the recommended 5,000 words by best practices.                                                                                                                                    |
| Lengthy Skill Name                   | Frontmatter’s name field exceeds the recommended 64 characters by best practices .                                                                                                                      |
| Lengthy Skill Description            | Frontmatter’s description field exceeds the recommended 1,024 characters by best practices.                                                                                                             |
| Confusing Skill Description          | Frontmatter’s description field should have a structure of [What it does] + [When to use it] + [Keywords]. However, the SKILL.md frontmatter’s description field fails to provide at least one of them. |
| Contradictory Skill Body             | SKILL.md body contains contradictory instructions or guidance.                                                                                                                                          |
| Redundant Skill Body                 | SKILL.md body contains redundant information, like unnecessary repetitions or information which is common knowledge                                                                                     |
| Human Fluff                          | SKILL.md body contains unnecessary human-like fluff, like greetings, sign-offs, or other conversational elements.                                                                                       |
| Missing Safeguards                   |                                                                                                                                                                                                         |
| No Guardrails                        | SKILL.md does not provide any guardrails to prevent the agent from attempting an inappropriate or impossible task.                                                                                      |
| Buried Gotchas                       | SKILL.md fails to highlight critical warnings or caveats that the agent should not overlook using recommended gotcha headers.                                                                           |
| Missing Usage Rules                  | SKILL.md omits rules governing when or how the skill should be used.                                                                                                                                    |
| Missing Caveats                      | SKILL.md omits common caveats and their resolution.                                                                                                                                                     |
| Inadequate Contextual Grounding      |                                                                                                                                                                                                         |
| Missing Example                      | SKILL.md do not provide examples that can assist the agent in obtaining sufficient context.                                                                                                             |
| Time Sensitive Skill                 | SKILL.md contains time-sensitive information that requires the agent to know the current time and it becomes outdated after a certain point.                                                            |
| Security Hazard                      |                                                                                                                                                                                                         |
| XML Included Description             | Frontmatter’s description contains XML tags which can inject unintended instructions into prompt                                                                                                        |
| Convention & Style Violations        |                                                                                                                                                                                                         |
| Backslash Path                       | SKILL.md contain paths denoted using a backslash. Agents navigate the skill directory like a file system so paths must be written using a frontslash.                                                   |
| Unclear Skill Name                   | Uses a skill name that does not clearly convey the skill’s capability or action.                                                                                                                        |
| Non Third Person Description         | Frontmatter’s description field should always be written in third person, but the description field is not. As inconsistent point-of-view can cause discovery problems.                                 |
| Unstructured Output                  |                                                                                                                                                                                                         |
| Missing Template                     | SKILL.md does not provide a template even though the agent needs to produce an output in a specific format.                                                                                             |

## Review Rules

- Apply a smell only when its definition is relevant to the target skill. Mark irrelevant criteria as not applicable rather than forcing a finding.
- Prefer file and line references. If line numbers are unavailable, quote the shortest identifying excerpt.
- Distinguish required corrections from optional improvements.
- Do not report personal style preferences unless they map to a listed criterion.
- Treat category rows without an acronym as headings, not criteria.
- If no criteria fail after verification, report that the skill is well-structured and adheres to best practices.

## Output Format

Start with a one-sentence overall assessment, then use:

| Finding        | Severity             | Evidence                              | Impact         | Suggested improvement |
|----------------|----------------------|---------------------------------------|----------------|-----------------------|
| `<smell name>` | High, Medium, or Low | `SKILL.md:<line>` and a short excerpt | Why it matters | A concrete correction |

After the table, list the criteria considered not applicable. Omit the table when there are no findings.

## Example

| Finding            | Severity | Evidence                                                         | Impact                          | Suggested improvement                              |
|--------------------|----------|------------------------------------------------------------------|---------------------------------|----------------------------------------------------|
| `Missing Template` | Medium   | `SKILL.md:24` requests a structured report but defines no format | Output may vary between reviews | Add a Markdown table defining the required columns |
