---
layout: default
title: Visa Management checklist
eyebrow: Post-setup · Role
summary: For international/immigration officers and scholar-services staff tracking visa, immigration and right-to-work detail on Contacts.
permalink: /roles/visa-management/
---

## Permission sets

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> <code>Technology_Transfer_Starter_Permission</code> (base).</li>
  <li class="task-list-item"><input type="checkbox" disabled> <strong>+ <code>Technology_Transfer_Starter_Visa_Management</code></strong> — Contact <strong>edit</strong> plus the visa / immigration fields.</li>
</ul>

## Fields to add to layouts

The package adds **19 visa / immigration fields to Contact** but, because the package
doesn't ship a Contact layout, **none are on a page layout by default** — you must add
the ones your region uses. The dedicated setup guide walks through the US, UK and
rest-of-world field groupings:

> **→ Follow [Visa management setup]({{ '/visa-management-setup/' | relative_url }})** for the region-by-region field list and layout guidance.

Core fields (all regions): `Nationality__c`, `Immigration_Status__c`, `Visa_Type__c`,
`Visa_Number__c`, `Visa_Start_Date__c`, `Visa_End_Date__c`, `Issuing_Authority__c`,
`Work_Authorization__c`, `Work_Hours_Limit__c`, `Right_to_Work_Check_Date__c`,
`Passport_Number__c`, `Passport_Expiry_Date__c`, and the formula
`Visa_Days_To_Expiry__c`. UK adds CAS/BRP/ATAS fields; US adds SEVIS/I-94/form-type
fields.

## Automation

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Confirm <code>TTS_Visa_Expiry_Reminder</code> (Scheduled, Active) runs — it raises reminder tasks 90, 30 and 7 days before a visa expiry.</li>
</ul>

## Configuration

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Set the <code>Nationality__c</code> values from the <code>TTS_Countries</code> global value set to match your intake.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Restrict who can see visa fields — this is sensitive personal data; confirm sharing and field-level security beyond the Visa Management set.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Confirm the reminder task owner/assignment routes to your immigration team.</li>
</ul>
