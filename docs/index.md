---
layout: default
title: null
---

<section class="hero">
  <p class="eyebrow">Salesforce Labs · Managed package</p>
  <h1>Technology Transfer Starter</h1>
  <p>A connected workspace for the records and activities a Technology Transfer Office manages every day — disclosures, technologies, IP protections, agreements, commercialisation and finance, on Salesforce.</p>
</section>

Technology Transfer Starter gives university and research-organisation Technology
Transfer Offices (TTOs) a single place to run the innovation-to-commercialisation
lifecycle. It brings **disclosures, technologies, inventors, intellectual-property
protections, agreements, commercial opportunities and financial transactions**
together in Salesforce — reducing the need to track each stage in separate
spreadsheets or systems.

The package ships a ready-made data model, guided processes, purpose-built record
pages, progress paths, reports and a dashboard. Offices use it as a foundation and
adapt it to their own policies, terminology and operating model.

## Start here

<div class="card-grid">
  <a class="card" href="{{ '/overview/' | relative_url }}">
    <h3>What it does</h3>
    <p>The capability areas, from disclosure intake to royalty distribution.</p>
  </a>
  <a class="card" href="{{ '/data-model/' | relative_url }}">
    <h3>Data model</h3>
    <p>How disclosures, technologies, protections, agreements and transactions relate.</p>
  </a>
  <a class="card" href="{{ '/objects-reference/' | relative_url }}">
    <h3>Object reference</h3>
    <p>Every custom object, its purpose and its key relationships.</p>
  </a>
  <a class="card" href="{{ '/post-setup/' | relative_url }}">
    <h3>Post-setup checklists</h3>
    <p>Role-by-role runbooks for what to configure after installing.</p>
  </a>
  <a class="card" href="{{ '/permission-sets-and-roles/' | relative_url }}">
    <h3>Permission sets &amp; roles</h3>
    <p>The layered access model and how it maps to TTO roles.</p>
  </a>
  <a class="card" href="{{ '/rest-api-getting-started/' | relative_url }}">
    <h3>REST API</h3>
    <p>Read, create and update package objects from external systems.</p>
  </a>
</div>

## Who it's for

- **Technology Transfer Offices** at universities and research institutions.
- **Salesforce administrators** installing and configuring the package for those offices.
- **TTO staff** — licensing associates, IP/patent managers, finance analysts, facilities and mentoring coordinators, and international/immigration officers — each with a tailored role checklist.

## The essentials

| | |
| --- | --- |
| **Type** | Second-generation (2GP) managed package |
| **Namespace** | `techstarter` |
| **Platform** | Salesforce (metadata & automation only — no custom UI components) |
| **Automation** | Flow-first, with minimal invocable Apex (`TTSCore`) |
| **Distribution** | [AppExchange listing](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000G0x6zUAB) |
| **Source** | [SalesforceLabs/Technology-Transfer-Starter](https://github.com/SalesforceLabs/Technology-Transfer-Starter) |

> New to the package? Read **[What it does]({{ '/overview/' | relative_url }})**, then follow the **[post-setup checklists]({{ '/post-setup/' | relative_url }})** for the roles your office needs.
