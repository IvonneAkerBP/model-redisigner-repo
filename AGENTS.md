# AGENTS.md — dige-performance-pbi

## Project overview
This repository contains Power BI report and semantic model projects in PBIP format for the DIGE Performance team.

## Primary development model
- Use PBIP project format for all Power BI report/model work
- Semantic model files are expected in TMDL format
- Report files are expected in PBIR / PBIP-compatible structure
- Use Git branches and pull requests for all changes
- Review diffs before opening Power BI Desktop to validate changes

## Preferred workflow
1. Create a feature branch
2. Make changes in PBIP/TMDL/PBIR files
3. Review Git diff
4. Reopen the PBIP project in Power BI Desktop to validate
5. Commit and push
6. Open pull request

## MCP usage guidance
- Use local Power BI Modeling MCP Server for semantic model authoring and structural changes
- For thin reports connected to service models, prefer connecting directly to the semantic model in Fabric Workspace when supported
- For insight and query scenarios against service-hosted semantic models, prefer the remote Power BI MCP server when available

## Imported Power BI agent resources
This repo contains curated Power BI agent resources under:
`powerbi-agent-resources/plugins/`

Imported plugin families:
- fabric-cli
- pbi-desktop
- pbip
- reports
- semantic-models
- tabular-editor

These resources are reviewed and used as supporting guidance, not as an unbounded automation layer.

## Guardrails
- Do not rename or delete existing report/model files unless explicitly asked
- Do not change connection details or workspace bindings without confirmation
- Do not commit local machine settings, secrets, caches, or temporary files
- Always preserve PBIP/TMDL/PBIR structure integrity
``