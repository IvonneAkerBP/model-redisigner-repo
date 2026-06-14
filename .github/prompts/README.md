# Prompt files

Repeatable tasks, one per file: `<name>.prompt.md`, run with `/<name>` in Copilot Chat.

Frontmatter fields: `description`, `agent` (`ask` / `agent` / `plan` / a custom agent), `model`,
`tools`, `argument-hint`. Reference tools in the body with `#tool:<name>`.

Full recipe: [`.github/skills/copilot-artifact-author`](../skills/copilot-artifact-author/SKILL.md).
