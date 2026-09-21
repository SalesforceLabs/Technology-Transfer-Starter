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
</ul>

## Configuration

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Define <strong>Royalty Term</strong> records on active agreements — royalty basis and rate.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Confirm inventor / contributor <strong>percentage shares</strong> are populated so distributions calculate correctly.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Check currency and transaction type/direction picklists match your finance process.</li>
</ul>
