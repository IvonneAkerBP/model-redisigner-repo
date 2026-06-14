---
name: copilot-artifact-author
description: Use when creating or reviewing any GitHub Copilot / VS Code customization artifact — repository instructions, path-scoped instructions, prompt files, or custom agents. Ensures every artifact uses the current, correct file name, folder, and YAML frontmatter, so the team produces the same shape every time and any teammate can drop it into their own Copilot. Grounded in the official VS Code and GitHub Copilot docs (verified 2026-06-04 — re-verify on use; these change).
---

# Authoring Copilot customization artifacts

One consistent shape for every customization item, portable across teammates' Copilot licences.

## The item types (verified 2026-06-04)

| Want to… | Item | File + location | Key frontmatter | Invoke |
|---|---|---|---|---|
| Set always-on repo rules | Repository instructions | `.github/copilot-instructions.md` | none | auto-loaded |
| Scope rules to paths | Path instructions | `.github/instructions/<name>.instructions.md` | `applyTo: "<glob>"` | auto when a matching file is in context |
| Vendor-neutral agent contract | Agent file | `AGENTS.md` (root or nested) | none | auto-loaded by any AGENTS.md-aware agent |
| A repeatable task you run often | Prompt file | `.github/prompts/<name>.prompt.md` | `description`, `agent`, `model`, `tools`, `argument-hint` | type `/<name>` in chat |
| A reusable persona / mode | Custom agent | `.github/agents/<name>.agent.md` | `name`, `description`, `tools`, `model`, `handoffs` | pick from the agent dropdown |
| A multi-step capability | Agent Skill | `.github/skills/<name>/SKILL.md` | `name` (lowercase, matches folder), `description` | auto-loaded when relevant; `gh skill` to share, `/skills reload` to refresh |

Sources: VS Code `code.visualstudio.com/docs/agent-customization/*` (prompt-files, custom-agents, agent-skills) and GitHub `docs.github.com/copilot` (custom-instructions-support, about-agent-skills).

Ages fast — flag on sight: "chat modes" were renamed to **custom agents** (`.chatmode.md` → `.agent.md`). In bodies, reference tools with `#tool:<name>` and prompts with `#prompt:<name>`.

## Use the native scaffolder first

Let the tool generate the file — do not hand-write if you can scaffold:

- **Prompt file** — type `/create-prompt` in Copilot Chat and describe the task; Copilot writes the `.prompt.md` with frontmatter. Or Command Palette → **Chat: New Prompt File**, or the **Configure Chat** gear → **New Prompt**.
- **Custom agent** — the **Configure Chat** gear → **New Agent** (or Command Palette → **Chat: New Agent**).
- **Agent Skill** — create `.github/skills/<name>/SKILL.md`, then `/skills reload` in the CLI and `/skills info <name>` to confirm; share across repos with `gh skill`.

The recipe below is for writing or reviewing one by hand — and for judging whether what the scaffolder produced is correct.

## Recipe — create any item

1. Pick one type from the table. One job per artifact.
2. Name it kebab-case; put it in the exact folder above.
3. Add only the frontmatter fields that type supports — no invented fields.
4. Body: imperative, specific, one concern. For agents and prompts, name the tools you expect.
5. Keep it portable: no secrets, no GUIDs, no endpoint URLs, no org-internal repo names, no personnel.
6. Verify it loads: path instructions — the `applyTo` glob matches; prompt — appears under `/`; agent — appears in the dropdown.

## Capture-as-artifact (turn usage into reuse)

When an agent does something useful, ask "what shape makes this reusable?":

- A rule we keep repeating → **path instructions**.
- A task we re-run → **prompt file**.
- A persona we re-summon → **custom agent**.
- A multi-step capability with scripts → an **Agent Skill** in `.github/skills/` (a folder like this one).

Then write it once, here, so a teammate adopts it with their own Copilot licence.

## Confidentiality (non-negotiable — this is a shared repo)

No secrets, no real GUIDs / Key Vault names / endpoint URLs, no internal-only repo names, no non-public personnel. If a pattern came from an internal source, adopt the *generic* pattern and cite the public standard — never the internal artifact.
