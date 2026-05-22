# SPEC

## §G GOAL
Extract agent, skill, and command prompts from ai.nix to external markdown files and switch to Google Gemini models.

## §C CONSTRAINTS
- Existing markdown files in `resources/` are source of truth for body content.
- Headers (frontmatter) from `ai.nix` are source of truth for metadata.
- New files use content from `ai.nix`.
- All final markdown files must use `@@PLACEHOLDER@@` format for models and permissions.
- Final `ai.nix` must load all prompts from external files.
- Skill directory structure is `resources/skills/<name>/SKILL.md`.

## §I INTERFACES
- File: `modules/ai.nix` → updated to load prompts externally.
- File: `resources/skills/` → contains all skill markdown files.
- File: `resources/agents/` → contains all agent markdown files.
- File: `resources/commands/` → contains all command markdown files.

## §V INVARIANTS
V1: `ai.nix` ! contain inline prompts for agents, skills, or commands.
V2: All markdown prompts ! contain hardcoded model names; must use `@@PLACEHOLDER@@`.
V3: `nix flake check` ! fail after refactor.

## §T TASKS
|id|status|task|cites|
|---|---|---|---|
|T1|x|Create SPEC.md file|§G|
|T2|x|Create missing skill files|§C, §I|
|T3|x|Create missing command files|§C, §I|
|T4|x|Create missing agent files|§C, §I|
|T5|x|Update existing files with correct headers and placeholders|§C, §I, V2|
|T6|x|Refactor ai.nix to load external prompts|V1, V2|
|T7|~|Run `nix flake check` to validate|V3|
