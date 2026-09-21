---
layout: default
title: Object reference
eyebrow: Introduction
summary: Every custom object in the package — its label, purpose and how it relates to the rest of the model. Field counts are custom fields shipped by the package.
---

All objects use the `TTS_` API prefix and the `techstarter` namespace inside the
managed package. Field counts below are the custom fields the package ships on each
object. For fields that exist but are **not** placed on a page layout — and so need
adding by an administrator — see the relevant **[post-setup checklist]({{ '/post-setup/' | relative_url }})**.

## Core lifecycle

| Object | Purpose | Fields |
| --- | --- | ---: |
| **Disclosure** (`TTS_Disclosure__c`) | Initial invention disclosure submitted before formal technology evaluation and protection processing. | 13 |
| **Technology** (`TTS_Technology__c`) | Shared technical, disclosure, readiness, ownership and commercial information about a technology or invention. | 30 |
| **Protection** (`TTS_Protection__c`) | Patents, trademarks, copyrights and trade secrets — ownership, jurisdiction, lifecycle and type-specific detail. | 34 |
| **Agreement** (`TTS_Agreement__c`) | Licensing and commercial agreements related to a technology. | 17 |
| **Transaction** (`TTS_Transaction__c`) | Incoming or outgoing monetary transactions related to a technology, agreement, protection, space and more. | 32 |

## Parties & contributors

| Object | Purpose | Fields |
| --- | --- | ---: |
| **Inventor** (`TTS_Inventor__c`) | An inventor or research contributor to a technology — role, primary status, contribution and percentage share for distributions. | 8 |
| **Applicant** (`TTS_Applicant__c`) | An organisation or individual applying for or holding an interest in a protection record. | 7 |
| **Contributor** (`TTS_Contributor__c`) | A party contributing an amount to a transaction involving multiple contributors. | 7 |
| **Recipient** (`TTS_Recipient__c`) | A party receiving a distribution from a financial transaction. | 7 |
| **Agreement Party** (`TTS_Agreement_Party__c`) | An organisation or individual participating in a specific agreement. | 4 |

## IP protection detail

| Object | Purpose | Fields |
| --- | --- | ---: |
| **Protection Family** (`TTS_Protection_Family__c`) | Groups related protection records, such as filings for one technology across multiple jurisdictions. | 4 |
| **Protection Claim** (`TTS_Protection_Claim__c`) | Individual patent claims under a protection record, with claim text and status. | 3 |
| **Protection Litigation** (`TTS_Protection_Litigation__c`) | Legal proceedings for a protection — parties, court references, dates, damages, settlement, outcome and appeal. | 16 |
| **Trademark Class** (`TTS_Trademark_Classes__c`) | NICE Classification class numbers and their official headings. | 2 |
| **Trademark Class Association** (`TTS_TrademarkIPAssociation__c`) | Links a trademark protection record to a NICE trademark class. | 2 |
| **Law Firm Matter** (`TTS_Law_Firm_Matter__c`) | Outside-counsel matter or docket used to group legal costs and map invoices to TTS records. | 7 |

## Agreements & finance

| Object | Purpose | Fields |
| --- | --- | ---: |
| **Agreement Deliverable** (`TTS_Agreement_Deliverable__c`) | Specific deliverables committed to under an agreement. | 8 |
| **Royalty Term** (`TTS_Royalty_Term__c`) | Structured royalty terms for agreement payment obligations (master-detail of Agreement). | 10 |

## Engagement tracking

| Object | Purpose | Fields |
| --- | --- | ---: |
| **Success Plan** (`TTS_Success_Plans__c`) | A reusable series of Milestone task templates for a specified object. | 2 |
| **Milestone** (`TTS_Milestone__c`) | A task template within a Success Plan — source date, timing offset, subject, amount and default contact. | 10 |

## Space & facilities

| Object | Purpose | Fields |
| --- | --- | ---: |
| **Space** (`TTS_Space__c`) | A physical space — office, lab, incubator, meeting room or workshop — managed by the TTO. | 11 |
| **Space Tenant** (`TTS_Space_Tenant__c`) | An organisation or individual occupying a managed space for a defined period. | 15 |
| **Tenant Contact** (`TTS_Space_Tenant_Contact__c`) | Associates an individual contact with a space tenant, tracking active/primary status. | 6 |
| **Space Asset** (`TTS_Space_Asset__c`) | Physical assets and equipment stored or used within a managed space. | 8 |

## Mentoring

| Object | Purpose | Fields |
| --- | --- | ---: |
| **Mentoring Opportunity** (`TTS_Mentoring_Opportunity__c`) | A mentoring engagement sought by a mentee — required expertise, candidate interest, mentor selection and dates. | 10 |
| **Mentoring Interest** (`TTS_Mentoring_Interest__c`) | A prospective mentor's interest in an opportunity, with selection status and preference ranking. | 5 |
