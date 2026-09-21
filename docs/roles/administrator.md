---
layout: default
title: Administrator checklist
eyebrow: Post-setup · Role
summary: Package-wide setup for the Salesforce administrator — permissions, automation, and the fields other roles will need on their layouts.
permalink: /roles/administrator/
---

You own the package configuration. Complete this once for the org, then hand each
functional role its own checklist.

## Permission sets

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Assign <code>Technology_Transfer_Starter_Permission</code> (base) to <strong>all</strong> staff users.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Stack the functional add-ons per role — see the mapping in <a href="{{ '/permission-sets-and-roles/' | relative_url }}">Permission sets &amp; roles</a>.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Assign <code>Technology_Transfer_Starter_Administrator</code> to package admins <strong>instead of</strong> base.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Assign <code>TTS_Integration_User</code> to API service accounts only — never to staff.</li>
</ul>

## Automation

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Confirm the scheduled reminder flows run at a suitable time: <code>TTS_Tenancy_Expiry_Reminder</code>, <code>TTS_Visa_Expiry_Reminder</code>, <code>TTS_Tenant_Contact_Scheduled_Actions</code> (all ship Active).</li>
  <li class="task-list-item"><input type="checkbox" disabled> Decide on the two <strong>Draft</strong> flows and activate if wanted: <code>Auto_Link_Contract_to_Opportunity</code>, <code>Success_Plan_Setup</code>.</li>
</ul>

## Fields to add to layouts

Objects the package ships **without a page layout** — add these custom fields to your
own layouts (or create layouts) before the relevant team uses them:

| Object | Fields not on any package layout |
| --- | --- |
| **Contact** | 19 visa/immigration fields — use the dedicated [Visa management setup]({{ '/visa-management-setup/' | relative_url }}). |
| **Contributor** (`TTS_Contributor__c`) | All 7 fields — add a layout for multi-contributor transactions. |
| **Trademark Class** (`TTS_Trademark_Classes__c`) | Both fields (class number, heading). |
| **Account / Campaign / Contract / Opportunity** | The single TTS classification/link field added to each standard object. |

Fields off the *default* layout on objects that **do** have one are listed on each
role page: [IP & Legal]({{ '/roles/ip-legal/' | relative_url }}),
[Space Manager]({{ '/roles/space-manager/' | relative_url }}),
[Royalty & Finance]({{ '/roles/royalty-finance/' | relative_url }}),
[Mentoring]({{ '/roles/mentoring-manager/' | relative_url }}).

## Configuration

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Review the included reports and the <strong>Technology Disclosure Dashboard</strong>; adjust folders and sharing.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Set org defaults (record types, picklist values, currencies) to match your office's terminology.</li>
  <li class="task-list-item"><input type="checkbox" disabled> If integrating externally, configure the API user and read the <a href="{{ '/rest-api-getting-started/' | relative_url }}">REST API guide</a>.</li>
</ul>
