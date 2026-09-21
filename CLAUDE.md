# CLAUDE.md

Read `.solution_context/project-state.md` when it exists before changing project artifacts.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Technology Transfer Starter is a Salesforce managed package (namespace `techstarter`) built as an SFDX project (2GP), driven with the `sf` CLI against scratch orgs. A CumulusCI (`cci`) config is retained for legacy flows. It provides objects, automation, and permission sets for Technology Transfer / IP Management / Commercialization workflows (disclosures, patents/trademarks ("Protection"), licensing agreements, transactions, space/tenant management, mentoring). It is distributed on the AppExchange as a 2GP managed package.

## Commands

**Default to `sf` (Salesforce CLI) for this project** — org lifecycle, deploy/retrieve, tests, and 2GP packaging against scratch orgs. Never use the deprecated `sfdx` executable. The CumulusCI (`cci`) config in `cumulusci.yml` is retained for legacy flows and Snowfakery data seeding (below), but is no longer the default for day-to-day work.

### Org setup
```bash
sf org create scratch --definition-file config/dev-scratch-def.json --alias tts_dev --duration-days 30 --set-default
sf project deploy start --source-dir force-app --target-org tts_dev
```
After deploy, assign permission sets. `Technology_Transfer_Starter_Permission` is the **base** — assign it to every staff user; it grants the shared commons (Account/Contact read, all core TTS objects R/W, tabs, app, apex). The functional-area sets are **pure add-on deltas** designed to be co-assigned on top of base — they no longer re-declare base-provided access, so assign them *with* base, not standalone. Assign base + whichever areas a user needs:
```bash
sf org assign permset \
  --name Technology_Transfer_Starter_Permission \
  --name Technology_Transfer_Starter_Visa_Management \
  --name Technology_Transfer_Starter_Space_Manager \
  --name Technology_Transfer_Starter_Mentoring_Manager \
  --name Technology_Transfer_Starter_IP_Protection_Manager \
  --name Technology_Transfer_Starter_Royalty_Manager \
  --target-org tts_dev
```
`Technology_Transfer_Starter_Administrator` is a standalone package-scoped admin set (full CRUD + View All/Modify All on every TTS object) — assign it *instead of* base to package admins, not on top. (`TTS_Integration_User` is a separate integration-only permission set — assign it only to integration users, not standard staff.)

### Deploy / retrieve
```bash
sf project deploy start --source-dir force-app --target-org tts_dev      # deploy source
sf project retrieve start --source-dir force-app --target-org tts_dev    # pull org changes back to source
```

### Tests
```bash
sf apex run test --target-org tts_dev --code-coverage --result-format human --wait 10
```
Package policy still requires **75% org code coverage** before a version can be cut — `sf` does not enforce this automatically, so check the coverage summary in the test output. There is no separate lint command in this repo.

### Data
Demo/test data is seeded by anonymous Apex scripts in `datasets/`, run with `sf`. Assign the permission sets (above) to the running user first — the seed runs in user mode and needs FLS on the managed-package fields. Seeding is split across two ordered scripts because a single dataset exceeds the `executeAnonymous` size limit:
```bash
sf apex run --file datasets/seed-demo-data.apex   --target-org tts_dev  # part 1: base records (DEMO | ... records)
sf apex run --file datasets/seed-demo-data-2.apex --target-org tts_dev  # part 2: transactions/contributors/recipients (re-queries part 1 by marker)
sf apex run --file datasets/cleanup-demo-data.apex --target-org tts_dev # remove everything (any order-independent, deletes by marker)
```
The scripts insert records in dependency order and use the explicit `techstarter__` namespace prefix. When adding a new object or field to the model, update the seed scripts (insert new records / populate new fields, in dependency order — part 1 for base records, part 2 for transaction-side records) **and** `cleanup-demo-data.apex` (delete the new objects). If part 1 grows past the size limit again, move the next tail section into part 2's re-query pattern. The older Snowfakery dataset (`mapping.yml` + `sample.sql`, loaded via `cci task run load_dataset`) is legacy.

### Package versioning (2GP, maintainers only)
```bash
sf package version create --package 0HoDm000000CaTXKA0 --target-dev-hub TTSDevHub --installation-key-bypass --code-coverage --wait 10
sf package version promote --target-dev-hub TTSDevHub --package 04t...
```
When cutting a new version, update `packageAliases` and `ancestorId`/`versionNumber` in `sfdx-project.json` — the ancestor must point at the latest released version ID.

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
- **Permission sets** (`force-app/main/default/permissionsets/`) are the access-control unit, layered: `Technology_Transfer_Starter_Permission` is the **broad base** (assigned to all staff — shared Account/Contact reads + all core TTS objects R/W + tabs/app/apex). The functional-area sets — Visa Management, Space Manager, Mentoring Manager, IP & Legal Protection Manager, Royalty & Finance Manager — are **pure deltas** stacked on base: each declares only what base does NOT provide (Space/Mentoring add their own app + their own objects; Visa adds Contact edit + 5 visa fields; IP/Royalty own their specialist objects R/W). Royalty must keep `TTS_Agreement__c` read because `TTS_Royalty_Term__c` is a master-detail child (platform-enforced FLS dependency, not removable). `Technology_Transfer_Starter_Administrator` is a standalone full-access set (not a delta). When adding a new object/field for end users, put FLS in **base** if it's a shared common, otherwise in the relevant functional set — and never re-declare base-provided reads in a delta set. Caveat: because the deltas no longer carry Account/Contact, an add-on assigned *without* base grants less than before — always co-assign base. Any new object/field needs FLS on the relevant permission set(s), not profiles.
- **iEdison/**: integration mapping docs and an OpenAPI spec for the U.S. federal iEdison reporting system (invention/patent/utilization reporting). These are reference docs (CSV field mappings + `iEdison OpenAPI Spec.yaml`), not implemented integration code — consult them before building any iEdison-related feature.
- **datasets/**: demo/test data. Primary path is the anonymous-Apex scripts `seed-demo-data.apex` + `seed-demo-data-2.apex` (run in order) and `cleanup-demo-data.apex`, via `sf apex run --file` (see Data commands above). Seeding is split into two scripts to stay under the `executeAnonymous` size limit; part 2 re-queries part 1's records by marker. The Snowfakery dataset (`mapping.yml` + `sample.sql`, `cci task run load_dataset`) is legacy. New objects/fields must be reflected in the seed scripts and `cleanup-demo-data.apex`.
- **`.qbrix/`**: generated deployment-backup snapshot of metadata (mirrors `force-app/`); not hand-edited source, ignore when tracing feature logic.

## Conventions

- Custom objects/fields for this package's own model use the `TTS_` prefix (e.g. `TTS_Transaction__c`); some legacy/inherited fields on `TTS_Transaction__c` use an `IP_` prefix — check field-level naming on the specific object before assuming `TTS_`.
- Apex uses `WITH USER_MODE` / `as user` DML (user-mode security) rather than manual CRUD/FLS checks — follow this pattern for new Apex.
- Namespace is `techstarter`; when writing SOQL/Apex or metadata that will run inside the managed package context, don't hardcode the namespace prefix.
