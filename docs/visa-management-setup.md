---
layout: default
permalink: /visa-management-setup/
---

# Set Up Visa Management

Technology Transfer Starter ships a set of visa / immigration fields on the standard **Contact** object, plus a daily reminder flow. Use them to track the immigration status, work authorization, and visa expiry of the people you work with (visiting researchers, sponsored students, incubator tenants, staff on work visas).

This guide is for the Salesforce administrator setting the feature up after installing the package.

## What the Package Provides — and What You Add

The package provides the **fields**, the **country picklist**, the **field-level security** (on the *Visa Management* permission set), and the **expiry-reminder flow**. It does **not** touch your Contact page layouts.

Because almost every org has its own Contact layouts (often several, by record type or profile), the package cannot safely edit them. **You add the fields you need to your own Contact layout(s)** — this guide's three sections tell you which fields to add for a US, UK, or rest-of-world setup.

## Prerequisites

1. Technology Transfer Starter is installed in the org.
2. Assign the base permission set **plus** the visa add-on to every user who maintains visa data:
   ```bash
   sf org assign permset \
     --name Technology_Transfer_Starter_Permission \
     --name Technology_Transfer_Starter_Visa_Management \
     --target-org <your-org>
   ```
   The visa add-on is a delta on top of base — assign it *with* base, not standalone. It grants Contact edit plus field-level security on all visa fields below.

> **Data policy.** These fields hold passport numbers, national IDs, and immigration status — sensitive personal data. Every field's help text repeats *"handle this information according to data policy."* Restrict access with the permission set, and follow your organization's data-protection obligations (GDPR, FERPA, etc.) for retention and disclosure.

## The Fields

All fields are on **Contact**. None are required, so you can adopt only what you need.

### Generic fields (all setups)

| Field | API name | Type | Notes |
| --- | --- | --- | --- |
| Nationality | `Nationality__c` | Picklist | Country of citizenship. Backed by the **TTS_Countries** global value set (198 countries) — not free text. |
| Immigration Status | `Immigration_Status__c` | Picklist | Valid · Renewal in Progress · Pending · Expired · Not Required · Unknown |
| Visa Type | `Visa_Type__c` | Picklist | Exchange Visitor Visa · Schengen Visa · Student Visa · Work and Study Visa |
| Visa Number | `Visa_Number__c` | Text(100) | Visa identifier as issued. |
| Issuing Authority | `Issuing_Authority__c` | Lookup → Account | The organization that issued the visa. |
| Visa Start Date | `Visa_Start_Date__c` | Date | Date the visa becomes valid. |
| Visa End Date | `Visa_End_Date__c` | Date | Date the visa expires. Drives the reminder flow. |
| Visa Days To Expiry | `Visa_Days_To_Expiry__c` | Number (formula) | `Visa_End_Date − TODAY`. Read-only; do not make it editable on the layout. |
| Passport Number | `Passport_Number__c` | Text(50) | |
| Passport Expiry Date | `Passport_Expiry_Date__c` | Date | |
| Work Authorization | `Work_Authorization__c` | Checkbox | Permitted to work under current status. |
| Work Hours Limit | `Work_Hours_Limit__c` | Number | Weekly work-hours cap imposed by the visa. |
| Right to Work Check Date | `Right_to_Work_Check_Date__c` | Date | Date the right-to-work check was completed. |

### US fields

| Field | API name | Type | Notes |
| --- | --- | --- | --- |
| US Form Type | `US_Form_Type__c` | Picklist | I-20 (F-1 Student) · DS-2019 (J-1 Exchange Visitor) · Other |
| US SEVIS ID | `US_SEVIS_ID__c` | Text(20) | |
| US I-94 Number | `US_I94_Number__c` | Text(20) | Admission number. |

### UK fields

| Field | API name | Type | Notes |
| --- | --- | --- | --- |
| UK CAS Number | `UK_CAS_Number__c` | Text(50) | Confirmation of Acceptance for Studies, for sponsored students. |
| UK BRP Number | `UK_BRP_Number__c` | Text(50) | Biometric Residence Permit. |
| UK ATAS Certificate | `UK_ATAS_Certificate__c` | Text(50) | Academic Technology Approval Scheme reference, where the research field requires it. |

## Add the Fields to Your Contact Layout

1. From **Setup**, open **Object Manager → Contact → Page Layouts**.
2. Edit the layout(s) your visa-maintaining users see.
3. Add a section (e.g. *Visa & Immigration*) and drag in the fields for your setup — see the three profiles below.
4. Leave **Visa Days To Expiry** as read-only (it is a formula; the layout shows it automatically as read-only).
5. Save. Repeat for each relevant layout / record type.

Only users with the *Visa Management* permission set (plus base) will see the fields; without it the fields stay hidden by field-level security even if they are on the layout.

### US-based organization

Add the **generic fields** plus the **US fields**. Typical section:

- Nationality, Immigration Status, Work Authorization, Work Hours Limit
- Visa Type, Visa Number, Issuing Authority, Visa Start Date, Visa End Date, Visa Days To Expiry
- **US Form Type, US SEVIS ID, US I-94 Number**
- Passport Number, Passport Expiry Date

Skip the UK fields.

### UK-based organization

Add the **generic fields** plus the **UK fields**. Typical section:

- Nationality, Immigration Status, Work Authorization, Work Hours Limit, Right to Work Check Date
- Visa Type, Visa Number, Issuing Authority, Visa Start Date, Visa End Date, Visa Days To Expiry
- **UK CAS Number, UK BRP Number, UK ATAS Certificate**
- Passport Number, Passport Expiry Date

Skip the US fields.

### Rest-of-world / generic

Add only the **generic fields** — no country-specific block:

- Nationality, Immigration Status, Work Authorization, Work Hours Limit
- Visa Type, Visa Number, Issuing Authority, Visa Start Date, Visa End Date, Visa Days To Expiry
- Passport Number, Passport Expiry Date, Right to Work Check Date

The US and UK fields stay available on the object — add them later to individual layouts if you take on people under those regimes.

## Expiry Reminders

The package installs a scheduled flow, **TTS - Visa Expiry Reminder**, active on install. It runs **daily** and creates a **High-priority Task** against the Contact when a visa reaches a reminder milestone:

- **90 days** to expiry
- **30 days** to expiry
- **7 days** to expiry
- when **Immigration Status = Expired**

Milestones fire on the exact day `Visa Days To Expiry` equals the threshold, so keep **Visa End Date** populated and accurate — the reminders derive entirely from it.

No configuration is required. To change the milestones or the task, edit the flow in **Setup → Flows**; to stop reminders, deactivate it.

## Verify

1. Assign yourself base + *Visa Management*.
2. Open a Contact, confirm the visa fields appear and **Nationality** is a country picklist.
3. Set **Visa End Date** to 7 days out and confirm **Visa Days To Expiry** shows `7`.
4. Optionally run the flow from **Setup → Flows → TTS - Visa Expiry Reminder → Debug** (or wait for the daily run) and confirm a Task is created on the Contact.
