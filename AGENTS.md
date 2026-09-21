# Agent Instructions

Read `.solution_context/project-state.md` when it exists before changing project artifacts.

**`CLAUDE.md` is the single source of truth for this repo.** Read it in full before working here — it covers project overview, commands, architecture, and conventions. This file intentionally does not duplicate that content; keep the two aligned by editing `CLAUDE.md` and leaving the pointers below in place.

## Always-on rules

- **CLI: default to `sf` (Salesforce CLI).** Use `sf` for org lifecycle, deploy/retrieve, tests, and 2GP packaging against scratch orgs. Never use the deprecated `sfdx` executable. CumulusCI (`cci`) is legacy — only for the flows/data tasks `CLAUDE.md` calls out (e.g. Snowfakery `load_dataset`).
- **Packaging model:** 2GP managed package, namespace `techstarter`, source API 67.0, single package dir `force-app/main/default/`.
- **Automation is Flow-first**; Apex is minimal (`TTSCore.cls`). Check existing Flows before adding triggers/classes.
- **Access control is via permission sets, not profiles.** Any new object/field needing end-user access gets FLS added to the relevant permission set(s).
- **Data seeding:** update both `datasets/seed-demo-data.apex` and `datasets/cleanup-demo-data.apex` when adding objects/fields.
- **Coverage:** 75% org code coverage is a package policy `sf` does not auto-enforce — check the test-run summary.

See `CLAUDE.md` for exact commands, the full data model, and naming conventions (`TTS_`/`IP_` prefixes, `WITH USER_MODE` DML, no hardcoded namespace).
