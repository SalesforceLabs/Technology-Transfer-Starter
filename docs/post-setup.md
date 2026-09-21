---
layout: default
title: Post-setup checklists
eyebrow: After you install
summary: What to configure once the package is installed. Do the shared steps first, then follow the checklist for each role your office runs.
permalink: /post-setup/
---

Installing the package puts the objects, flows, permission sets and pages into your
org — but a managed package **cannot** assign permissions for you, place every field
on your layouts, or decide which optional automation you want on. This section is the
runbook for finishing the job.

Work top-down: complete the **shared setup** below, then open the checklist for each
role your office staffs.

## Shared setup (do this first)

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Assign the base permission set</strong> — <code>Technology_Transfer_Starter_Permission</code> to every staff user. Nothing else works without it. See <a href="{{ '/permission-sets-and-roles/' | relative_url }}">Permission sets &amp; roles</a>.</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Assign functional add-ons</strong> — stack the role sets each user needs <em>on top of</em> base (they are pure deltas).</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Confirm the scheduled flows are running</strong> — the tenancy- and visa-expiry reminders are schedule-triggered; verify the schedule and time suit your office.</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Decide on the optional draft flows</strong> — <code>Auto_Link_Contract_to_Opportunity</code> and <code>Success_Plan_Setup</code> ship as <strong>Draft</strong>. Activate them only if you want that automation.</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>Add off-layout fields to your page layouts</strong> — several shipped fields are intentionally left off the default layouts (new additions, formula/rollup summaries, cross-area lookups). Each role checklist lists the fields relevant to it.</li>
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
