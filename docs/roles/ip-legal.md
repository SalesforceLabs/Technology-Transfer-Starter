---
layout: default
title: IP & Legal Protection checklist
eyebrow: Post-setup · Role
summary: For IP/patent managers, paralegals, docketing specialists and outside-counsel liaisons managing protections, claims, litigation and legal matters.
permalink: /roles/ip-legal/
---

## Permission sets

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> <code>Technology_Transfer_Starter_Permission</code> (base).</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>+ <code>Technology_Transfer_Starter_IP_Protection_Manager</code></strong> — protections, families, claims, litigation, trademark classes/associations, applicants and law-firm matters.</li>
</ul>

## Fields to add to layouts

These shipped fields are **not** on the default layouts — add the recommended ones to
the relevant page:

| Object | Field | Add? |
| --- | --- | --- |
| Protection | `Attorney_Reference_ID__c` | ✅ Recommended |
| Protection | `Registered__c` | ✅ Recommended |
| Protection | `Total_Active_Litigations__c` | Optional (roll-up summary) |
| Protection Litigation | `Applicant__c` | ✅ Recommended |
| Technology | `IP_Status__c` | ✅ Recommended |
| Technology | `Trademark_Classes__c` | ✅ Recommended |
| Technology | `IP_Compact_Title__c` | Optional (formula display helper) |
| Technology | `IP_Total_Percentage_Share__c` | Optional (roll-up summary) |
| Technology | `IP_Total_Primary_Contributions__c` | Optional (roll-up summary) |

The **Trademark Class** object ships without a package layout — add one if you record
NICE classifications for trademarks.

## Automation

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> No IP-specific flow activation is required. <code>TTS_Auto_Update_PI_on_Technology</code> runs automatically.</li>
</ul>

## Configuration

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Review Protection <strong>type</strong> and <strong>status</strong> picklists against your jurisdictions and lifecycle stages.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Set up <strong>Law Firm Matter</strong> records for the outside counsel you work with, so legal costs and invoices map to protections.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Confirm access to <strong>Agreement</strong> (read) if you cross-reference licences from protections.</li>
</ul>
