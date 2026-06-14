# Custom agents

Reusable personas, one per file: `<name>.agent.md`, picked from the Copilot agent dropdown.

Frontmatter: `name`, `description`, `tools`, `model`, `handoffs`. Reference tools in the body with
`#tool:<name>`. (Formerly "chat modes" — the `.chatmode.md` form is deprecated; use `.agent.md`.)

Full recipe: [`.github/skills/copilot-artifact-author`](../skills/copilot-artifact-author/SKILL.md).
