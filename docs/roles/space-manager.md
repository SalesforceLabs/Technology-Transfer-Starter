---
layout: default
title: Space Manager checklist
eyebrow: Post-setup · Role
summary: For facilities and incubator managers running spaces, tenants, assets and occupancy.
permalink: /roles/space-manager/
---

## Permission sets

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> <code>Technology_Transfer_Starter_Permission</code> (base).</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>+ <code>Technology_Transfer_Starter_Space_Manager</code></strong> — the Space Management app plus Space, Space Asset, Space Tenant and Tenant Contact objects.</li>
</ul>

## Fields to add to layouts

Several space fields ship off the default layouts — add the recommended ones:

| Object | Field | Add? |
| --- | --- | --- |
| Space | `Programme__c` | ✅ Recommended |
| Space | `Total_Tenants__c` | Optional (roll-up summary) |
| Space Tenant | `Venture_Category__c` | ✅ Recommended |
| Space Tenant | `Venture_Stage__c` | ✅ Recommended |
| Space Tenant | `Membership_Tier__c` | ✅ Recommended |
| Space Tenant | `Occupancy_Type__c` | ✅ Recommended |
| Space Tenant | `Departure_Reason__c` | ✅ Recommended |
| Space Asset | `Asset_Category__c` | ✅ Recommended |
| Transaction | `Space__c`, `Space_Tenant__c` | ✅ If you attribute space fees to the paying tenant |

## Automation

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Confirm <code>TTS_Tenancy_Expiry_Reminder</code> (Scheduled, Active) runs — it raises reminder tasks 90, 30 and 7 days before a tenancy end date.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Confirm <code>TTS_Tenant_Contact_Scheduled_Actions</code> and the tenant-contact currency flows are Active — space status follows occupancy automatically.</li>
</ul>

## Configuration

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Review the Space <strong>Type</strong> and <strong>Status</strong> picklists (office, lab, incubator, accelerator, hot desk, co-working, event, etc.).</li>
  <li class="task-list-item"><input type="checkbox" disabled> Set up the <strong>programmes</strong> your spaces support and the membership tiers you offer.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Decide how tenancy-fee transactions are recorded (via the Space / Space Tenant lookups on Transaction).</li>
</ul>
