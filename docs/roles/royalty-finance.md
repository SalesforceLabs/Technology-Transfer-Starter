---
layout: default
title: Royalty & Finance checklist
eyebrow: Post-setup · Role
summary: For royalty accountants and revenue-distribution officers managing transactions, royalty terms, contributors and recipients.
permalink: /roles/royalty-finance/
---

## Permission sets

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> <code>Technology_Transfer_Starter_Permission</code> (base).</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>+ <code>Technology_Transfer_Starter_Royalty_Manager</code></strong> — transactions, royalty terms, contributors and recipients.</li>
</ul>

> The Royalty set also grants **read** on Agreement — required because Royalty Term is a
> master-detail child of Agreement. This is platform-enforced and not optional.

## Fields to add to layouts

| Object | Field | Add? |
| --- | --- | --- |
| Contributor | All 7 fields | ✅ Add a layout — the object ships without one; needed for multi-contributor transactions. |
| Transaction | `Space__c` | Optional — only if you attribute space fees to transactions ([Space Manager]({{ '/roles/space-manager/' | relative_url }})). |
| Transaction | `Space_Tenant__c` | Optional — as above. |

## Automation

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Confirm <code>TTS_Generate_Recurring_Schedule</code> (and its subflow) is Active — it generates recurring transaction schedules via invocable Apex.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Review the recurring-schedule frequency options against how your office bills.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Note that generated recurring transactions carry the agreement's royalty details (term and rate) forward and start as unpaid, scheduled payments — amounts, reported revenue, payment references and report dates are left blank. Record those on each one as it is actually paid.</li>
</ul>

## Configuration

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Define <strong>Royalty Term</strong> records on active agreements — royalty basis and rate.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Confirm inventor / contributor <strong>percentage shares</strong> are populated so distributions calculate correctly.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Where an agreement covers more than one technology, set the <strong>Technology Coverage</strong> allocations so they total 100%. You can add coverage records one at a time — the package allows a running total below 100% but never above it — and the agreement's <strong>Allocation Complete</strong> flag stays unchecked until the split reaches 100%. To change an existing split, lower one allocation before raising another. Filter on Allocation Complete to find agreements whose split is still in progress.</li>
  <li class="task-list-item"><input type="checkbox" disabled> When reporting by technology, use the agreement's <strong>Technology Count</strong>: with 0 or 1 Technology Coverage records, report on <strong>Primary Technology</strong>; with 2 or more, report on the Technology Coverage records. An agreement with a single coverage record must have Primary Technology set, and that record should match it. On a multi-technology agreement, Primary Technology is the lead or reference technology you choose; it does not have to be the one with the largest allocation, so report allocation shares from the coverage records rather than from Primary Technology. Agreements created before Technology Coverage existed keep working on Primary Technology alone — add a matching 100% coverage record only if you want them on the coverage model.</li>
  <li class="task-list-item"><input type="checkbox" disabled> When you split a transaction across contributors or recipients, make sure those amounts reconcile with the transaction total — the package expects the parts to balance to the whole.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Keep each transaction's royalty rate and reported revenue consistent with the amount recorded, so royalty figures reconcile.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Check currency and transaction type/direction picklists match your finance process.</li>
</ul>
