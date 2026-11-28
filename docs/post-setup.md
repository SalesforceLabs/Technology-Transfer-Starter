---
layout: default
title: Post-setup checklists
eyebrow: Install & set up
summary: What to check before you install, then what to configure once the package is in. Do the shared steps first, then follow the checklist for each role your office runs.
permalink: /post-setup/
---

Installing the package puts the objects, flows, permission sets and pages into your
org — but a managed package **cannot** assign permissions for you, place every field
on your layouts, or decide which optional automation you want on. This section is the
runbook for finishing the job.

Work top-down: check **before you install**, complete the **shared setup**, then open
the checklist for each role your office staffs.

## Before you install

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Check you can install</strong> — you need the Download AppExchange Packages permission (or System Administrator). Confirm your Salesforce edition on the <a href="https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000G0x6zUAB">AppExchange listing</a>.</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Install in a sandbox first</strong> — check fit with your other managed packages, custom code and data model before production.</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Decide on multi-currency</strong> — <em>recommended, not required</em>. The package works without it; when it is on, generated schedule rows inherit the parent Transaction's currency. Enabling multi-currency <strong>cannot be undone</strong>, so set the corporate currency and exchange rates before you load Transactions.</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Install for Admins Only</strong> — then grant access with permission sets (below). Install steps and the direct install links are in the <a href="https://github.com/SalesforceLabs/Technology-Transfer-Starter#installation">README</a>.</li>
</ul>

### Upgrading from a version before 3.0

Versions before 3.0 were an **unmanaged** package. The managed package (namespace
`techstarter`) can't upgrade it in place, and installing it alongside the old version
creates **duplicate objects**. Treat it as a migration:

1. Export your data and capture your customisations (Salesforce DX retrieve).
2. Map the data to the managed objects:

   | Before 3.0 (unmanaged) | Now (managed) |
   | --- | --- |
   | IP | Technology (`TTS_Technology__c`) |
   | Patent | Protection (`TTS_Protection__c`), Patent record type |
   | Licence agreement on the standard Contract | Agreement (`TTS_Agreement__c`) |

3. Choose a new org, or an in-place change: delete the old TTS data, reports and
   dashboards, uninstall the unmanaged package, then install the managed one. Rehearse
   in a full-copy sandbox first.
4. Re-import your data, then run user acceptance testing.

## Shared setup (do this first)

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Assign the base permission set</strong> — <code>Technology_Transfer_Starter_Permission</code> to every staff user. Nothing else works without it. See <a href="{{ '/permission-sets-and-roles/' | relative_url }}">Permission sets &amp; roles</a>.</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Assign functional add-ons</strong> — stack the role sets each user needs <em>on top of</em> base (each adds only what base doesn't grant).</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Confirm the scheduled flows are running</strong> — the tenancy- and visa-expiry reminders are schedule-triggered; verify the schedule and time suit your office.</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Decide on the optional draft flows</strong> — <code>Auto_Link_Contract_to_Opportunity</code> and <code>Success_Plan_Setup</code> ship as <strong>Draft</strong>. Activate them only if you want that automation.</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Add off-layout fields to your page layouts</strong> — several shipped fields are intentionally left off the default layouts (new additions, formula/rollup summaries, cross-area lookups). Each role checklist lists the fields relevant to it.</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Surface research funding (if you track it)</strong> — the <strong>Funding Award</strong> tab ships in the app, but Funding Award and Award Budget Period ship <strong>without page layouts</strong>, so create those (see the <a href="{{ '/roles/administrator/' | relative_url }}">Administrator checklist</a>). Add the off-layout <code>Funding_Award__c</code> lookup on Disclosure and Technology plus the Bayh-Dole / iEdison utilisation fields on Technology (government interest, title-election and first-commercial-sale dates, US-manufacture, utilisation stage). Funding Award and Award Budget Period are base objects available to all staff.</li>
</ul>

> **Why fields are off-layout.** Managed-package upgrades don't force-add new fields to
> your customised layouts, and some fields are cross-area lookups or roll-up summaries
> an office may not want surfaced. The lists below tell you exactly which to add.

## Choose your role

<div class="card-grid">
  <a class="card" href="{{ '/roles/administrator/' | relative_url }}"><h3>Administrator</h3><p>Package-wide setup, permissions and automation.</p></a>
  <a class="card" href="{{ '/roles/ip-legal/' | relative_url }}"><h3>IP &amp; Legal Protection</h3><p>Patents, trademarks, claims, litigation, counsel.</p></a>
  <a class="card" href="{{ '/roles/royalty-finance/' | relative_url }}"><h3>Royalty &amp; Finance</h3><p>Transactions, royalty terms, distributions.</p></a>
  <a class="card" href="{{ '/roles/space-manager/' | relative_url }}"><h3>Space Manager</h3><p>Spaces, tenants, assets and occupancy.</p></a>
  <a class="card" href="{{ '/roles/mentoring-manager/' | relative_url }}"><h3>Mentoring Manager</h3><p>Opportunities, interests and mentor selection.</p></a>
  <a class="card" href="{{ '/roles/visa-management/' | relative_url }}"><h3>Visa Management</h3><p>Immigration fields and expiry reminders.</p></a>
</div>

## Legend

Each role page follows the same shape:

- **Permission sets** — what to assign for this role.
- **Fields to add to layouts** — shipped fields not on a default layout that this role needs.
- **Automation** — flows to confirm or activate.
- **Configuration** — anything else to set up or review.

A ✅ marks a field/step recommended for most offices; roll-up and formula summaries are
marked as optional since they carry no data-entry need.

## Key terms

| Term | Meaning in this package |
| --- | --- |
| **TTO** | Technology transfer office — the team that manages a research organisation's IP and its commercialisation. |
| **Disclosure** | An inventor's first report of a new invention, submitted before evaluation (`TTS_Disclosure__c`). |
| **Technology** | The invention or asset the office manages once a disclosure is accepted (`TTS_Technology__c`). |
| **Inventor** | A person credited on a Technology, with role, primary flag and percentage share for distributions. |
| **Protection** | A patent, trademark, copyright or trade-secret filing for a Technology. |
| **Protection Family** | Related Protections, such as one invention filed in several jurisdictions. |
| **Priority filing** | The first filing for an invention; later filings in the family claim its priority date. |
| **NICE classification** | The international classes of goods and services a trademark is registered under. |
| **Agreement** | A licence or other commercial or research agreement (record types include Licence, Option, MTA, CRA, SRA, Confidentiality). |
| **MTA** | Material transfer agreement — governs sharing research materials with another organisation. |
| **Technology Coverage** | Links an Agreement to each Technology it covers, with an allocation percent. |
| **Royalty Term** | The structured royalty basis and rate behind an Agreement's payment obligations. |
| **Transaction** | Money in or out — royalties, patent expenses, fees — with an optional recurring schedule. |
| **Funding Award** | The grant or contract that funded the research, for Bayh-Dole/iEdison and AUTM reporting. |
| **Bayh-Dole / iEdison** | The U.S. law on federally funded inventions, and the federal system where they're reported. |
| **TRL** | Technology readiness level — how mature a technology is, from concept to proven product. |

## Who uses it

- **A TTO staff member** logs an incoming disclosure, approves it into a Technology,
  tracks its patent filings, and negotiates a licence. Once the licence is signed, they
  record the royalty terms and the payments as they arrive.
- **An inventor** submits a disclosure through a form (a portal, if your office sets
  one up), then follows its status as the office evaluates and protects it. They're
  credited on the Technology, and their share of any royalties is distributed from it.
