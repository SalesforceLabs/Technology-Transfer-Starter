# Permission Sets and Technology Transfer Office Roles

This guide explains how Technology Transfer Starter's permission sets are structured and which
Technology Transfer Office (TTO) roles each one is intended for. It is written for Salesforce
administrators assigning access after the package is installed.

## How the Permission Sets Are Layered

Access is built from a **broad base plus thin add-ons**, not one set per person:

- **`Technology_Transfer_Starter_Permission`** ("Technology Transfer Starter - TTO") is the **base**.
  Assign it to *every* staff user. It grants the shared commons the whole office needs: read on
  Account and Contact, full create/read/edit/delete on all core Technology Transfer objects
  (disclosures, technologies, protections, agreements, transactions, parties, milestones, success
  plans), the TTS app, its tabs, and Apex access.
- The **functional-area sets** are **pure add-on deltas**. Each one declares *only* what the base
  does not already provide, so it must be **co-assigned on top of the base** — never on its own.
  Assigning an add-on without the base leaves the user without Account/Contact and other shared
  access.
- **`Technology_Transfer_Starter_Administrator`** is a **standalone** full-access set. Assign it
  *instead of* the base to package administrators, not on top.
- **`TTS_Integration_User`** is a **standalone integration-only** set for server-to-server API
  users. Never assign it to staff. See [rest-api-getting-started.md](rest-api-getting-started.md).

> Permission sets are additive in Salesforce: a user's effective access is the union of every set
> assigned to them. "Layering" here is a design convention, not an enforced inheritance — the base
> only takes effect because you assign it alongside the add-ons.

## The Permission Sets

| Permission set | Assign with base? | Grants (delta over base) |
| --- | --- | --- |
| Technology Transfer Starter - TTO (`Permission`) | This *is* the base | Shared commons: Account/Contact read, all core TTS objects R/W, TTS app, tabs, Apex |
| Administrator | No — assign *instead of* base | Full CRUD + View All + Modify All on every TTS object, all fields, tabs, and Apex |
| Visa Management | Yes | Contact **edit** plus the five visa fields (Visa Type/Number/Start/End, Issuing Authority) |
| Space Manager | Yes | Space Management app + Space, Space Asset, Space Tenant, Space Tenant Contact objects |
| Mentoring Manager | Yes | Mentoring Manager app + Mentoring Opportunity, Mentoring Interest objects |
| IP & Legal Protection Manager | Yes | Protections, protection families, claims, litigation, trademark classes/associations, applicants, outside-counsel matters |
| Royalty & Finance Manager | Yes | Transactions, royalty terms, contributors, recipients (plus Agreement read, required by a master-detail dependency) |

## Alignment to Standard TTO Roles

TTO staffing varies, but most offices map onto the same functional roles. Assign the base to
everyone, then add the sets that match each person's responsibilities.

| TTO role | Also known as | Assign |
| --- | --- | --- |
| Technology transfer generalist | Licensing associate, TTO officer, case manager | Base only |
| Licensing / commercialisation manager | Licensing manager, business development | Base only (add Royalty & Finance if they also handle revenue reporting) |
| IP / patent manager | IP counsel, patent administrator, paralegal, docketing specialist | Base + **IP & Legal Protection Manager** |
| Legal / outside-counsel liaison | Contracts specialist, legal operations | Base + **IP & Legal Protection Manager** |
| Finance / royalty analyst | Royalty accountant, revenue distribution officer | Base + **Royalty & Finance Manager** |
| Facilities / incubator manager | Space manager, lab operations, property coordinator | Base + **Space Manager** |
| Mentoring / programs coordinator | Entrepreneur-in-residence coordinator, programs manager | Base + **Mentoring Manager** |
| International / immigration officer | Visa coordinator, scholar services | Base + **Visa Management** |
| TTO system administrator | Salesforce admin, package owner | **Administrator** (instead of base) |
| External system / integration | API service account | **`TTS_Integration_User`** (instead of base) |

Many people wear several hats — a common licensing associate who also tracks patent costs would get
**Base + IP & Legal Protection Manager + Royalty & Finance Manager**. Stack as many add-ons as the
person's duties require.

## Assigning the Sets

Assign the base plus whichever add-ons a user needs in one command. Example — a full generalist with
every functional area:

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

A patent administrator would instead get just base + IP:

```bash
sf org assign permset \
  --name Technology_Transfer_Starter_Permission \
  --name Technology_Transfer_Starter_IP_Protection_Manager \
  --target-org tts_dev
```

Package administrators get the standalone Administrator set on its own:

```bash
sf org assign permset --name Technology_Transfer_Starter_Administrator --target-org tts_dev
```

## Notes for Administrators

- **Always co-assign the base with any functional add-on.** The add-ons no longer carry
  Account/Contact or other shared access; without the base the user cannot see the records those
  add-ons operate against.
- **Standard-object fields stay read-only** in the base and the functional add-ons (except the five
  Contact visa fields granted by Visa Management, and Contact edit itself). Broadening standard-object
  field access is intentionally left to the org's own permission sets.
- **Adding a new object or field:** put its field-level security on the **base** if it belongs to the
  shared commons, otherwise on the relevant functional set. Do not re-declare base-provided access in
  an add-on.
