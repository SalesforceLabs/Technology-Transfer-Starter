# CLAUDE.md

Read `.solution_context/project-state.md` when it exists before changing project artifacts.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Technology Transfer Starter is a Salesforce managed package (namespace `techstarter`) built as a CumulusCI-driven SFDX project. It provides objects, automation, and permission sets for Technology Transfer / IP Management / Commercialization workflows (disclosures, patents/trademarks ("Protection"), licensing agreements, transactions, space/tenant management, mentoring). It is distributed on the AppExchange as a 2GP managed package.

## Commands

This project uses **CumulusCI (`cci`)**, not raw `sf`/`sfdx`, for org lifecycle and deployment. Config lives in `cumulusci.yml`.

### Org setup
```bash
cci org scratch dev tts_dev --days 30       # create a scratch org
cci flow run dev_org --org tts_dev          # deploy + assign perm sets (dev config)
cci flow run qa_org --org tts_dev           # deploy + assign perm sets (qa config)
```
`dev_org`/`qa_org` flows run the custom `assign_perms` flow (task `assign_permission_sets`), which assigns all four permission sets listed below.

### Deploy / retrieve
```bash
cci task run deploy --org tts_dev                  # deploys force-app/ (path set in cumulusci.yml)
cci task run retrieve_changes --org tts_dev         # pull org changes back to source
```

### Tests
```bash
cci task run run_tests --org tts_dev
```
`run_tests` enforces `required_org_code_coverage_percent: 75` (set in `cumulusci.yml`). There is no separate lint command in this repo.

### Data
```bash
cci task run load_dataset --org tts_dev             # load datasets/ (Snowfakery mapping + sample.sql)
cci task run delete_data --org tts_dev              # deletes seeded data; object list is in cumulusci.yml (delete_data task)
```

### Package versioning (maintainers only)
```bash
sf package version create --package 0HoDm000000CaTXKA0 --target-dev-hub TTSDevHub --installation-key-bypass --code-coverage --wait 10
sf package version promote --target-dev-hub TTSDevHub --package 04t...
```
When cutting a new version, update `packageAliases` and `ancestorId`/`versionNumber` in `sfdx-project.json` — the ancestor must point at the latest released version ID, and `update_dependencies` in `cumulusci.yml` must reference the latest `version_id`.

## Architecture

- **Single package directory**: all metadata lives under `force-app/main/default/` (SFDX source format, API version 67.0). There is no `force-app/main/default/lwc` or Aura — this package is metadata/automation only (no custom UI components).
- **Apex is minimal**: only `TTSCore.cls` (+ test class). It exposes `@InvocableMethod`s for use from Flow (currently: generating recurring `TTS_Transaction__c` child records on a schedule). New server-side logic should generally be added as invocable Apex here rather than a new class unless it's unrelated to transaction/schedule generation.
- **Automation is Flow-first**: business logic (disclosure → technology record generation, contract/opportunity linking, tenant contact lifecycle, recurring schedules) is implemented as Flows in `force-app/main/default/flows/`, not triggers. Check existing flows before adding Apex triggers.
- **Data model** (`force-app/main/default/objects/`) centers on a Technology Transfer domain, plus standard objects (`Account`, `Contact`, `Contract`, `Campaign`, `Opportunity`) extended with custom fields:
  - Disclosure → Technology → Protection (patent/trademark family, claims, litigation) → Agreement (party, deliverable) → Transaction (recurring payments)
  - Inventor / Contributor / Applicant / Recipient — parties associated with IP
  - Space / Space Asset / Space Tenant / Tenant Contact — facilities/incubator management
  - Mentoring Opportunity / Mentoring Interest — mentoring program
  - Success Plans, Milestone — engagement tracking
- **Permission sets** (`force-app/main/default/permissionsets/`) are the access-control unit, one per functional area — Permission (base), Visa Management, Space Manager, Mentoring Manager. Any new object/field intended for end users needs FLS added to the relevant permission set(s), not profiles.
- **iEdison/**: integration mapping docs and an OpenAPI spec for the U.S. federal iEdison reporting system (invention/patent/utilization reporting). These are reference docs (CSV field mappings + `iEdison OpenAPI Spec.yaml`), not implemented integration code — consult them before building any iEdison-related feature.
- **datasets/**: Snowfakery-based sample data (`mapping.yml` + `sample.sql`) loaded via `cci task run load_dataset`.
- **`.qbrix/`**: generated deployment-backup snapshot of metadata (mirrors `force-app/`); not hand-edited source, ignore when tracing feature logic.

## Conventions

- Custom objects/fields for this package's own model use the `TTS_` prefix (e.g. `TTS_Transaction__c`); some legacy/inherited fields on `TTS_Transaction__c` use an `IP_` prefix — check field-level naming on the specific object before assuming `TTS_`.
- Apex uses `WITH USER_MODE` / `as user` DML (user-mode security) rather than manual CRUD/FLS checks — follow this pattern for new Apex.
- Namespace is `techstarter`; when writing SOQL/Apex or metadata that will run inside the managed package context, don't hardcode the namespace prefix.
