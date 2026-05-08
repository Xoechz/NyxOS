# SPEC

## §G GOAL
Refactor NyxOS AI workflow: merge opencode-dotnet & opencode-java into single opencode HM module, harden agent permissions (allow safe reads, deny destructive ops), add manager agent, add ## Skills section to all agents, update host imports & README.

## §C CONSTRAINTS
- Nix only — no non-nix source files changed
- `flake.nix` ! never edited directly
- All changes via `modules/ai.nix`, host files, `README.md`, `AGENTS.md`
- Module names kebab-case, files camelCase
- Every agent ! loads caveman skill at session start
- `programs.opencode` merge-safe — HM merges attrsets, no conflicts on combine

## §I INTERFACES
- file: `modules/ai.nix` → single `flake.modules.homeManager.opencode` exporting all formatters/skills/agents/commands
- file: `modules/hosts/eliasPC.nix` → HM imports list without opencode-dotnet & opencode-java
- file: `modules/hosts/eliasLaptop.nix` → same
- file: `README.md` → opencode entry updated, opencode-dotnet & opencode-java entries removed
- file: `AGENTS.md` → "Default Agent" section removed
- cmd: `nix flake check` → 0 errors after changes

## §V INVARIANTS
V1: `flake.modules.homeManager.opencode-dotnet` & `opencode-java` ! removed from ai.nix — DONE
V2: ∀ agent permission blocks → include safe-read allows: ls*, cat*, find*, which*, env, echo*, ps*, df*, du*, rg*, jq*, file*, stat*, wc*, head*, tail*, sort* — DONE
V3: ∀ agent permission blocks → include deny entries: rm -rf*, dd *, mkfs*, fdisk*, shred*, passwd*, useradd*, userdel*, usermod*, sudo rm*, git push --force*, git push -f* — DONE
V4: review agents (nix-review, dotnet-review, java-review) & manager ! keep `edit: deny`
V5: dotnet-format formatter (sdk_10_0) & google-java-format formatter present in merged opencode module — DONE
V6: java-dev & dotnet-dev skills present in merged opencode module — DONE
V7: /dotnet-build /dotnet-test /dotnet-format /java-build /java-test /java-format commands present in merged module — DONE
V8: eliasPC.nix & eliasLaptop.nix HM imports ! contain only `opencode` — DONE
V9: README.md opencode description mentions dotnet & java included; opencode-dotnet & opencode-java rows removed — DONE
V10: `nix flake check` passes after all changes
V11: `commonPerms` ! contains `"nix flake check*": allow` — belongs only in nix agents
V12: ∀ nix agents (nix-lite, nix-medium, nix-heavy, nix-max, nix-review) → explicit `"nix flake check*": allow` in permission block
V13: ∀ 16 agents → first section is `## Skills` listing caveman + domain skill(s)
V14: manager agent exists with `edit: deny`, `${commonPerms}`, model = maxModel
V15: manager agent body → loads delegate + cavekit skills; never commits unless explicitly asked
V16: 11 remaining literal permission blocks replaced with `${commonPerms}`
V17: AGENTS.md "Default Agent" section removed

## §T TASKS
id|status|task|cites
T1|x|merge opencode-dotnet & opencode-java content into opencode module in ai.nix|V1,V5,V6,V7
T2|x|add safe-read allow entries to all 15 agents|V2
T3|x|add deny entries to all 15 agents|V3
T4|x|remove TODO comment line 1465 ai.nix|-
T5|x|update eliasPC.nix HM imports — remove opencode-dotnet & opencode-java|V8
T6|x|update eliasLaptop.nix HM imports — same|V8
T7|x|update README.md — merge opencode entry, remove opencode-dotnet & opencode-java|V9
T8|x|run nix flake check, confirm clean|V10
T9|x|remove "nix flake check*" from commonPerms; add explicitly to 5 nix agents|V11,V12
T10|x|replace 11 remaining literal permission blocks with ${commonPerms}|V16
T11|x|add ## Skills section to all 16 agents (15 domain + manager)|V13
T12|x|add manager agent to ai.nix|V4,V14,V15
T13|x|remove "Default Agent" section from AGENTS.md|V17
T14|x|run nix flake check, confirm clean|V10

## §B BUGS
id|date|cause|fix
