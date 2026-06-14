---
description: Pressure-test a Copilot answer against its sources before you repeat it to anyone.
agent: ask
argument-hint: paste the claim or summary you are about to forward
---
Take the answer or summary I am about to forward and pressure-test it before I send it.

For each claim:

1. Name the exact source that supports it — file, visual, query result, or doc URL. If there is none, mark it UNSUPPORTED.
2. Flag any number that is not traceable to a source.
3. Separate what is verified from what is inference.

Return three things: the verified claims, the unsupported claims to drop or check, and the single next human verification step. Do not add new claims of your own.
