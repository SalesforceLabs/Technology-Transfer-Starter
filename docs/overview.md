---
layout: default
title: What it does
eyebrow: Introduction
summary: The capability areas Technology Transfer Starter covers, from invention disclosure through IP protection, licensing and revenue distribution to space, mentoring and immigration management.
---

Technology Transfer Starter is organised around the lifecycle a TTO runs: an idea
is **disclosed**, evaluated as a **technology**, **protected** as intellectual
property, **licensed** through agreements, and generates **transactions** and
royalties — supported by space, mentoring and immigration management for the
people and ventures involved.

## Core lifecycle

### Disclosure intake and review
Collect invention details, funding information, commercial applications and
supporting documents through a guided disclosure form. Approved disclosures can be
turned into Technology records without re-entering the information.

### Technology portfolio management
Keep technical, market and prior-art information together, assess Technology
Readiness Levels, and follow each Technology from initial disclosure through
protection and commercialisation.

### Inventor and contributor records
Link inventors and other contributors to a Technology, record their roles and
contribution shares, and identify the principal inventor — the basis for later
revenue distribution.

### IP protection management
Manage patents, trademarks, copyrights and trade secrets: ownership, jurisdictions,
key dates, applicants, claims, related filings (families), litigation, and the
law-firm matters handling them.

### Agreement management
Record licence, confidentiality, material-transfer, sponsored-research and other
agreements — with their parties, terms, dates, deliverables and related
technologies.

### Commercial and financial tracking
Connect technologies to Opportunities, Contracts, Campaigns and Agreements. Record
incoming and outgoing payments, define royalty terms on agreements, create
recurring payment schedules, and allocate amounts to contributors or other
recipients.

## Supporting areas

### Space and tenant management
Track offices, labs, incubators, accelerators, hot desks, co-working and event
space, plus the programme each space supports. Manage tenants and their contacts
with venture category, venture stage, membership tier, occupancy type and departure
reason; categorise equipment as assets; and attribute space fees to the paying
tenant. A daily flow raises tenancy-expiry reminders at 90, 30 and 7 days before an
end date, and space status follows occupancy automatically.

### Mentoring management
Advertise mentoring opportunities, record expressions of interest, rank potential
mentors and track the selected mentoring relationship.

### Visa and immigration management
Track nationality, immigration status, visa type and dates, work authorisation,
passports and US / UK-specific references on Contact records, with a formula-driven
days-to-expiry field and a daily flow that raises reminder tasks at 90, 30 and 7
days before expiry. See **[Visa management setup]({{ '/visa-management-setup/' | relative_url }})**.

## Platform capabilities

- **Reports and dashboard** — technology counts by status and readiness, disclosure trends and agreement revenue, via the included reports and the Technology Disclosure Dashboard.
- **Technology Transfer workspace** — a ready-made Salesforce app with dedicated pages, progress paths, tabs and views.
- **REST API integration** — read, create and update the package's custom objects from external systems through a namespaced Apex REST endpoint; the exposed object list is derived from the package schema at run time. See **[REST API]({{ '/rest-api-getting-started/' | relative_url }})**.

## How it's built

Technology Transfer Starter is a managed package, so most of what you see is
configuration you can extend rather than code you maintain:

- **Automation is Flow-first** — disclosure-to-technology generation, contract and opportunity linking, tenant-contact lifecycle and recurring schedules are Flows, not triggers.
- **Apex is minimal** — a single `TTSCore` class exposes invocable methods (currently, generating recurring transaction schedules) for use from Flow.
- **Access is permission-set based** — a broad base set plus thin functional add-ons, mapped to TTO roles. See **[Permission sets & roles]({{ '/permission-sets-and-roles/' | relative_url }})**.
