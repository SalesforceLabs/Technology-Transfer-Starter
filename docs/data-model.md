---
layout: default
title: Data model
eyebrow: Introduction
summary: The core spine runs Disclosure → Technology → Protection → Agreement → Transaction, with parties, IP detail, space, mentoring and finance objects hanging off it.
---

The data model centres on a single commercialisation spine. An invention is
**disclosed**, promoted to a **technology**, **protected** as IP, **licensed**
through agreements, and settled through **transactions**. Supporting objects attach
parties, IP detail, facilities, mentoring and finance to that spine.

## The commercialisation spine

<div class="flow">
  <div class="flow-step"><span class="n">Intake</span><span class="t">Disclosure</span><span class="d">Invention disclosed and reviewed before formal evaluation.</span></div>
  <div class="flow-arrow" aria-hidden="true">→</div>
  <div class="flow-step"><span class="n">Evaluate</span><span class="t">Technology</span><span class="d">Technical, market, readiness and ownership detail.</span></div>
  <div class="flow-arrow" aria-hidden="true">→</div>
  <div class="flow-step"><span class="n">Protect</span><span class="t">Protection</span><span class="d">Patent, trademark, copyright or trade secret.</span></div>
  <div class="flow-arrow" aria-hidden="true">→</div>
  <div class="flow-step"><span class="n">License</span><span class="t">Agreement</span><span class="d">Licence and commercial terms with parties.</span></div>
  <div class="flow-arrow" aria-hidden="true">→</div>
  <div class="flow-step"><span class="n">Settle</span><span class="t">Transaction</span><span class="d">Incoming / outgoing payments and royalties.</span></div>
</div>

## What attaches to each stage

### Around Technology
<div class="rel-grid">
  <div class="rel"><h4>Inventor</h4><p>Inventors and contributors, roles and percentage shares — the basis for distribution.</p></div>
  <div class="rel"><h4>Success Plan → Milestone</h4><p>Reusable task templates that create date-based actions on a Technology.</p></div>
</div>

### Around Protection
<div class="rel-grid">
  <div class="rel"><h4>Protection Family</h4><p>Groups related filings for one technology across jurisdictions.</p></div>
  <div class="rel"><h4>Protection Claim</h4><p>Individual patent claims and their status.</p></div>
  <div class="rel"><h4>Protection Litigation</h4><p>Legal proceedings: parties, court references, damages, outcome.</p></div>
  <div class="rel"><h4>Applicant</h4><p>Organisations or individuals applying for / holding the protection.</p></div>
  <div class="rel"><h4>Trademark Class + Association</h4><p>NICE classification classes linked to trademark protections.</p></div>
  <div class="rel"><h4>Law Firm Matter</h4><p>Outside-counsel docket used to group legal costs and map invoices.</p></div>
</div>

### Around Agreement
<div class="rel-grid">
  <div class="rel"><h4>Agreement Party</h4><p>An organisation or individual participating in the agreement.</p></div>
  <div class="rel"><h4>Agreement Deliverable</h4><p>Specific deliverables committed to under the agreement.</p></div>
  <div class="rel"><h4>Royalty Term</h4><p>Structured royalty basis and rate (master-detail of Agreement).</p></div>
</div>

### Around Transaction
<div class="rel-grid">
  <div class="rel"><h4>Contributor</h4><p>A party contributing an amount to a multi-contributor transaction.</p></div>
  <div class="rel"><h4>Recipient</h4><p>A party receiving a distribution from a transaction.</p></div>
</div>

Transactions can link to a Technology, Agreement, Protection, Opportunity,
Contract, Space, Campaign, Agreement Party or Agreement Deliverable — the hub where
money meets the rest of the model.

## Supporting domains

<div class="rel-grid">
  <div class="rel"><h4>Space</h4><p>Offices, labs, incubators, desks and event space, plus the programme each supports.</p></div>
  <div class="rel"><h4>Space Tenant → Tenant Contact</h4><p>Occupants of a space and the individuals associated with them.</p></div>
  <div class="rel"><h4>Space Asset</h4><p>Physical equipment stored or used within a space.</p></div>
  <div class="rel"><h4>Mentoring Opportunity → Interest</h4><p>Mentoring engagements sought, and expressions of interest ranked for selection.</p></div>
</div>

## Extended standard objects

The package adds custom fields to standard objects rather than replacing them:

| Standard object | Purpose of the extension |
| --- | --- |
| **Contact** | Visa / immigration fields (nationality, visa dates, work authorisation, passport, US/UK references). |
| **Contract** | Links contracts into the technology-transfer commercial flow. |
| **Opportunity** | Connects commercial opportunities to technologies. |
| **Campaign** | Associates outreach campaigns with the model. |
| **Account** | A technology-transfer classification field. |

> For a per-object breakdown of purpose and relationships, see the
> **[Object reference]({{ '/objects-reference/' | relative_url }})**.
