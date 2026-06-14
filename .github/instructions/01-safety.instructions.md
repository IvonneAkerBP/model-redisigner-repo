---
applyTo: "**"
---
# Confidentiality and safety — always apply

## What NOT to paste into Copilot chat

GitHub Copilot sends your prompt to a cloud service. Treat it like email — only send what
you would be comfortable with others seeing.

**Never include:**
- Workspace GUIDs or connection strings
- API keys, passwords, or tokens of any kind
- Personal data (names, emails, employee IDs)
- Data samples from tables with confidential or restricted classification
- Internal system URLs or environment-specific endpoints

**Safe to include:**
- Table and column names (without data values)
- Measure formulas (DAX, M)
- Model relationship descriptions
- Error messages (after removing any embedded connection strings)
- Generic schema descriptions

## Default Approvals

VS Code Agent mode runs in **Default Approvals** by default:
- Read-only operations happen without asking
- Write operations require your explicit OK
- The **Stop** button is always available — use it if the agent does something unexpected

Do not enable Bypass Approvals or Autopilot for Power BI / Fabric work.

## Workspace scope

AI-assisted changes go to a DEV workspace first. No direct PROD writes. Confirm row counts
and visual output in DEV before publishing.
