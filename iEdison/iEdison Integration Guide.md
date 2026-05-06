# iEdison Integration Guide — MuleSoft / Anypoint Platform

**Audience:** SI developer / MuleSoft integration engineer  
**Package:** Technology Transfer Starter v3.x (`techstarter` / `TTS_`)  
**API spec:** `iEdison OpenAPI Spec.yaml` (same folder)  
**Prerequisite reading:** `iEdison Gap Remediation Guide.md` — the TTS data model changes in Phases 1–3 must be deployed before this integration can function.

---

## 1. Overview

iEdison is the NIST system through which US universities report federally funded inventions to comply with the Bayh-Dole Act. This integration pushes data from Salesforce (TTS) to iEdison across three domains:

| Flow | iEdison Endpoint | Trigger |
|---|---|---|
| Invention | `POST /v2/inventions/create` or `/update` | Technology record with Funding Agreements, no prior iEdison submission |
| Patent | `POST /v3/patents/create` or `/update` | Protection record (type = Patent) linked to a submitted Technology |
| Utilization | `POST /v3/utilizations/create` or `/update` | Annual Utilization Report record (TTS_Utilization_Report__c) |

The integration is **push-only** (Salesforce → iEdison). The one exception is the **iEdison Report Number writeback** — after a successful Invention create, the iEdison-generated `inventionReportNumber` must be written back to `TTS_Technology__c.techstarter__iEdison_Report_Number__c`. This field is the foreign key that links all subsequent patent and utilization submissions.

---

## 2. Prerequisites

### 2.1 TTS Data Model

Phases 1–3 of the Gap Remediation Guide must be deployed:

- `techstarter__iEdison_Report_Number__c` on Technology (Phase 1.1)
- `TTS_Funding_Agreement__c` object (Phase 1.2)
- Title Election Status fields on Technology (Phase 1.3)
- Federal inventor fields on TTS_Inventor__c (Phase 2.1)
- `techstarter__Confirmatory_License_Date__c` on Protection (Phase 3.1)

Without these, the integration cannot construct valid iEdison payloads.

### 2.2 iEdison Account

The institution must have an active iEdison account with:
- An assigned **Institution Code** (provided by NIST)
- mTLS certificates provisioned for UAT and Production (see Section 3)

### 2.3 MuleSoft Platform

- Anypoint Studio 7.x (for development)
- Anypoint Platform account with CloudHub or on-premises Mule Runtime 4.x
- Anypoint Secrets Manager access (for certificate storage)
- Salesforce Connector for Mule 4 (available on Anypoint Exchange)

---

## 3. Authentication — mTLS Setup

iEdison uses **Mutual TLS (mTLS)** — not OAuth, not API keys. This is the most distinctive aspect of the integration and requires specific setup steps in both MuleSoft and with NIST.

### 3.1 Certificate Provisioning (NIST side)

1. Generate a Certificate Signing Request (CSR) using OpenSSL with RSA 2048-bit encryption:
   ```
   openssl req -new -newkey rsa:2048 -nodes -keyout iedison-client.key -out iedison-client.csr
   ```
2. Submit the CSR along with a completed and signed **ISA (Interconnection Security Agreement)** to NIST. The ISA must be signed by an authorised representative of the institution.
3. NIST returns the signed client certificate. **Allow 2–4 weeks.** Request UAT and Production certificates separately — they are different.
4. Package the certificate and private key into a PKCS12 keystore:
   ```
   openssl pkcs12 -export -in iedison-client.crt -inkey iedison-client.key -out iedison-uat.p12
   ```

### 3.2 MuleSoft TLS Context Configuration

In Anypoint Studio, configure a **TLS Context** global element with the PKCS12 keystore. Apply it to the **HTTP Requester** global configuration — not to individual request operations.

```xml
<!-- Global TLS Context -->
<tls:context name="iEdison_TLS_Context">
  <tls:key-store
    type="pkcs12"
    path="${iedison.keystore.path}"
    password="${iedison.keystore.password}"
    keyPassword="${iedison.key.password}"
    alias="iedison-client" />
</tls:context>

<!-- HTTP Requester config using the TLS context -->
<http:request-config name="iEdison_HTTP_Config"
    basePath="/iedison/api"
    tlsContext="iEdison_TLS_Context">
  <http:request-connection
      host="${iedison.host}"
      port="443"
      protocol="HTTPS" />
</http:request-config>
```

### 3.3 Secrets Management

**Never** hardcode keystore paths, passwords, or Salesforce credentials in Mule XML or property files committed to source control.

Use **Anypoint Secrets Manager** (or Anypoint Runtime Manager secure properties) for:
- `iedison.keystore.path`
- `iedison.keystore.password`
- `iedison.key.password`
- `salesforce.username` / `salesforce.password` / `salesforce.token`
- `iedison.institution.code`

Use separate property files per environment (e.g. `config-uat.yaml`, `config-prod.yaml`) selected at deploy time via the `mule.env` system property.

---

## 4. Flow Architecture

### 4.1 Invention Flow

**Purpose:** Submit a new invention disclosure, or update an existing one, and write the iEdison Report Number back to Salesforce.

```
┌─────────────────────────────────────────────────────────────────┐
│ TRIGGER                                                         │
│  • Salesforce Connector: On Modified Object (TTS_Technology__c) │
│    Filter: iEdison_Report_Number__c IS NULL                     │
│    AND related TTS_Funding_Agreement__c records exist           │
│    AND Title_Election_Status__c != null                         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ QUERY (Salesforce Connector)                                    │
│  SOQL: SELECT Id, techstarter__IP_Title__c,                     │
│    techstarter__IP_Disclosure_Date__c,                          │
│    techstarter__IP_External_Reference__c,                       │
│    techstarter__IP_Public_Disclosure__c,                        │
│    techstarter__Title_Election_Status__c,                       │
│    techstarter__Title_Election_Date__c,                         │
│    techstarter__Not_Elect_Title_Reason__c,                      │
│    techstarter__IP_ParentIP__r.iEdison_Report_Number__c,        │
│    (SELECT techstarter__Federal_Agency__c,                      │
│            techstarter__Grant_Contract_Number__c,               │
│            techstarter__Award_Type__c,                          │
│            techstarter__Agreement_Type__c,                      │
│            techstarter__Primary__c                              │
│     FROM TTS_Funding_Agreements__r),                            │
│    (SELECT techstarter__IP_Original_Inventor_Name__r.FirstName, │
│            techstarter__IP_Original_Inventor_Name__r.LastName,  │
│            techstarter__IP_Original_Inventor_Name__r.MiddleName,│
│            techstarter__Federal_Employee__c,                    │
│            techstarter__Federal_Agency__c,                      │
│            techstarter__Primary_Reporting_Agency__c             │
│     FROM TTS_Inventors__r)                                      │
│  FROM techstarter__TTS_Technology__c WHERE Id = :id            │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ PRE-FLIGHT VALIDATION                                           │
│  • At least 1 Funding Agreement with agency + grantNumber       │
│  • At least 1 Inventor with firstName + lastName + primaryAgency│
│  • Title_Election_Status__c is populated                        │
│  If validation fails → emit error Platform Event → stop         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ TRANSFORM (DataWeave)                                           │
│  Map TTS fields → inventionRequest JSON                         │
│  (See Section 5.1 for DataWeave guidance)                       │
│  Serialise to multipart/form-data                               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ ROUTE: Create or Update?                                        │
│  Choice: iEdison_Report_Number__c IS NULL → /create             │
│          iEdison_Report_Number__c IS NOT NULL → /update         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ HTTP REQUEST (iEdison)                                          │
│  POST /v2/inventions/create  OR  /v2/inventions/update          │
│  Content-Type: multipart/form-data                              │
│  TLS Context: iEdison_TLS_Context                               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ WRITEBACK (Salesforce Connector — on create only)               │
│  Update TTS_Technology__c:                                      │
│    iEdison_Report_Number__c = response.inventionReportNumber    │
│    Title_Election_Date__c   = response.inventionStatus          │
│                                       .titleElectionDate        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│ NOTIFY                                                          │
│  Emit Platform Event: TTS_iEdison_Event__e                      │
│    Status: Success / Failure                                    │
│    RecordId, iEdison Report Number, Timestamp                   │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Patent Flow

**Purpose:** Submit a patent application record to iEdison, linked to an already-submitted invention.

**Trigger:** Protection record (Type = Patent) where parent Technology has `iEdison_Report_Number__c` populated and `techstarter__Confirmatory_License_Date__c` is set (if required by application type).

**Idempotency check:** Before calling create, search iEdison using `inventionReportNumber` + `patentDocketNumber`. If a result is returned → call update instead.

**Key DataWeave logic:** Select the correct application sub-object based on `Patent_Application_Type__c`:

```
- ORD, DIV, CON, CIP  →  nonProvisionalPatentApplication
- PROV                →  provisionalPatentApplication
- PCT                 →  pctPatentApplication
```

**Foreign filings:** Collect all Protection records in the same Protection Family as sibling records (excluding the primary). Each sibling becomes one entry in the `foreignFilings` array. On update, the full list must be sent — iEdison replaces rather than merges.

**Writeback:** Log the submission date on the Protection record. Consider a custom field `techstarter__iEdison_Last_Submitted__c` (Date).

### 4.3 Utilization Flow

**Purpose:** Submit the annual Bayh-Dole utilization report for a specific fiscal year.

**Trigger:** A `TTS_Utilization_Report__c` record where `techstarter__iEdison_Submitted__c = false` (manual or scheduled trigger — e.g. annually in October for the prior fiscal year).

**Derived fields computed at submission time (not stored):**

| iEdison Field | Derivation |
|---|---|
| `totalIncome` | `SELECT SUM(techstarter__IP_Actual_Amount__c) FROM TTS_Transaction__c WHERE techstarter__IP_Related_IP__c = :techId AND techstarter__Type__c IN ('Royalties','Licence Income') AND techstarter__Direction__c = 'Incoming' AND CALENDAR_YEAR(techstarter__IP_Transaction_Date_Time__c) = :year` |
| `exclusiveLicensesOptions` | `SELECT COUNT(Id) FROM TTS_Agreement__c WHERE techstarter__Technology__c = :techId AND techstarter__Agreement_Type__c = 'Exclusive License' AND techstarter__Status__c IN ('Active','Executed')` |
| `nonExclusiveLicensesOptions` | Same query with `Agreement_Type__c = 'Non-Exclusive License'` |
| `licensees[]` (v3) | Query distinct `Licensee_Account__r.Name` from active Agreements, with per-licensee exclusive/non-exclusive counts |

**Version branching:** The `licensees` array structure (v3) is used for `reportingYear >= 2024`; the flat `exclusiveLicensees` / `nonExclusiveLicensees` array strings (v2) for `reportingYear <= 2023`. Branch on the `reportingYear` field in DataWeave.

**Writeback:**
```
TTS_Utilization_Report__c.iEdison_Submitted__c       = true
TTS_Utilization_Report__c.iEdison_Submission_Date__c = today()
```

---

## 5. DataWeave Guidance

### 5.1 Date Formatting

iEdison requires all dates as `MM/DD/YYYY` strings. Salesforce returns ISO dates (`YYYY-MM-DD`). Always format at the DataWeave layer:

```dataweave
fun toIEdisonDate(d: Date | Null): String | Null =
  if (d == null) null
  else d as String {format: "MM/dd/yyyy"}
```

### 5.2 Invention Request Mapping (sketch)

```dataweave
%dw 2.0
output application/json
fun toIEdisonDate(d) = if (d == null) null else d as String {format: "MM/dd/yyyy"}
---
{
  institutionCode:    p('iedison.institution.code'),
  inventionTitle:     payload.techstarter__IP_Title__c,
  inventionReportDate: toIEdisonDate(payload.techstarter__IP_Disclosure_Date__c),
  inventionDocketNumber: payload.techstarter__IP_External_Reference__c,
  firstPublicationDate: toIEdisonDate(payload.techstarter__IP_Public_Disclosure__c),
  parentInventionNumber: payload.techstarter__IP_ParentIP__r.techstarter__iEdison_Report_Number__c default null,
  inventors: payload.TTS_Inventors__r.records map (inv) -> {
    firstName:       inv.techstarter__IP_Original_Inventor_Name__r.FirstName,
    lastName:        inv.techstarter__IP_Original_Inventor_Name__r.LastName,
    middleInitial:   inv.techstarter__IP_Original_Inventor_Name__r.MiddleName default null,
    fedEmployee:     inv.techstarter__Federal_Employee__c default false,
    fedAgency:       inv.techstarter__Federal_Agency__c default null,
    primaryAgency:   inv.techstarter__Primary_Reporting_Agency__c
  },
  fundingAgreements: payload.TTS_Funding_Agreements__r.records map (fa) -> {
    agency:          fa.techstarter__Federal_Agency__c,
    grantNumber:     fa.techstarter__Grant_Contract_Number__c,
    awardType:       fa.techstarter__Award_Type__c default null,
    agreementType:   fa.techstarter__Agreement_Type__c default null
  },
  inventionStatus: {
    titleElectionStatus:    payload.techstarter__Title_Election_Status__c,
    notElectTitleReason:    payload.techstarter__Not_Elect_Title_Reason__c default null,
    notElectTitleOtherReason: payload.techstarter__Not_Elect_Title_Other_Reason__c default null
  }
}
```

### 5.3 Patent Application Type Mapping

TTS picklist values do not exactly match iEdison codes. Apply this lookup at the DataWeave layer:

```dataweave
fun toIEdisonAppType(ttsValue: String): String = 
  {
    "Continuation":       "CON",
    "Divisional":         "DIV",
    "Provisional":        "PROV",
    "PCT":                "PCT",
    "Ordinary Utility":   "ORD",
    "Continuation-in-Part": "CIP",
    "Plant Variety Protection": "PVP",
    "National":           "ORD"   // closest equivalent
  }[ttsValue] default "ORD"
```

### 5.4 Patent Status Mapping

```dataweave
fun toIEdisonPatentStatus(ttsStatus: String): String =
  if (["Pending","Filed","Granted","In Force","Under Review"] contains ttsStatus) "Active"
  else if (["Expired","Lapsed"] contains ttsStatus) "Expired"
  else if (["Abandoned","Withdrawn","Cancelled","Invalidated"] contains ttsStatus) "Abandoned"
  else "Active"
```

### 5.5 Multipart Assembly

iEdison endpoints expect `multipart/form-data`. Assemble the multipart payload after the DataWeave transform:

```dataweave
%dw 2.0
output multipart/form-data
---
{
  parts: {
    inventionRequest: {
      headers: { "Content-Type": "application/json" },
      content: write(vars.inventionPayload, "application/json")
    }
    // Optionally add inventionDisclosure binary part here
  }
}
```

---

## 6. Error Handling and Retry Patterns

### 6.1 Error Classification

| HTTP Status | Cause | Action |
|---|---|---|
| `400 Bad Request` | iEdison field validation failure | Log full response body (contains field-level error messages). **Do not retry.** Emit error Platform Event. Fix source data and resubmit. |
| `401 / 403` | mTLS certificate rejected or institutionCode mismatch | **Alert operations immediately.** Do not retry automatically. Check certificate expiry and keystore config. |
| `404 Not Found` | `inventionReportNumber` not found on update | Data mismatch — the stored report number may be wrong. Route to manual review queue. |
| `429 Too Many Requests` | Rate limiting | Exponential backoff: wait 2s, retry. Then 4s, retry. Then 8s, retry. After 3 failures → dead-letter queue + alert. |
| `500 / 503` | Transient server error | Same exponential backoff as 429 (2s → 4s → 8s, 3 retries). Dead-letter on exhaustion. |

### 6.2 MuleSoft Error Handler Structure

```xml
<error-handler>
  <!-- Validation errors — do not retry -->
  <on-error-continue type="HTTP:BAD_REQUEST">
    <flow-ref name="iEdison-dead-letter-flow" />
    <flow-ref name="iEdison-emit-error-event-flow" />
  </on-error-continue>

  <!-- Auth errors — alert immediately -->
  <on-error-continue type="HTTP:UNAUTHORIZED, HTTP:FORBIDDEN">
    <flow-ref name="iEdison-ops-alert-flow" />
  </on-error-continue>

  <!-- Not found on update — manual review -->
  <on-error-continue type="HTTP:NOT_FOUND">
    <flow-ref name="iEdison-manual-review-queue-flow" />
    <flow-ref name="iEdison-emit-error-event-flow" />
  </on-error-continue>

  <!-- Transient errors — retry with backoff -->
  <on-error-propagate type="HTTP:SERVICE_UNAVAILABLE, HTTP:TOO_MANY_REQUESTS, MULE:CONNECTIVITY">
    <!-- Handled by Until Successful scope wrapping the HTTP call -->
  </on-error-propagate>
</error-handler>
```

Wrap the HTTP Requester in an **Until Successful** scope for transient errors:

```xml
<until-successful maxRetries="3" millisBetweenRetries="2000">
  <!-- HTTP Requester here -->
</until-successful>
```

Note: Until Successful uses a fixed interval. For true exponential backoff, implement a retry sub-flow with a counter variable and `set-variable` + `async` delay pattern.

### 6.3 Dead-Letter Queue

Failed submissions should be parked in a persistent store for investigation and manual resubmission. Options:
- **Anypoint MQ** dead-letter queue (preferred on CloudHub)
- **Salesforce custom object** (`TTS_iEdison_Submission_Log__c`) with fields: Record ID, Flow Type (Invention/Patent/Utilization), HTTP Status, Error Body, Submitted At, Resolved (checkbox)
- **VM Connector** with persistent VM queue (on-premises Mule)

### 6.4 Platform Events for Salesforce-Side Monitoring

Define a Platform Event `TTS_iEdison_Event__e` with fields:

| Field | Type | Notes |
|---|---|---|
| Record_Id__c | Text | Salesforce record that triggered the submission |
| Flow_Type__c | Text | Invention / Patent / Utilization |
| Status__c | Text | Success / Failure |
| iEdison_Report_Number__c | Text | Populated on success |
| HTTP_Status__c | Number | HTTP response code |
| Error_Message__c | Long Text Area | iEdison error body on failure |
| Submitted_At__c | DateTime | Submission timestamp |

Subscribe to this event in Salesforce with a Flow or Apex trigger to update record statuses and surface errors to TTO staff without requiring MuleSoft log access.

---

## 7. Idempotency

The integration must distinguish between first-time submissions (→ create) and subsequent updates (→ update). iEdison provides separate endpoints and there is no upsert.

### Invention
- **Decision field:** `TTS_Technology__c.techstarter__iEdison_Report_Number__c`
- If null → create. Store the returned `inventionReportNumber`.
- If populated → update. Include `inventionReportNumber` in the request body.

### Patent
- No equivalent stored identifier on Protection.
- **Approach:** Before each submission, call `POST /v3/patents/search` with `inventionReportNumber` + `patentDocketNumber`. If `totalRecords > 0` → update; else → create.
- Cache the search result within the flow execution — do not call search again after deciding.

### Utilization
- **Approach:** Search `POST /v3/utilizations/search` with `inventionReportNumber` + `fiscalYear`. If a result exists → update; else → create.
- Alternatively, trust the `iEdison_Submitted__c` checkbox on the Utilization Report record — if true, always call update.

---

## 8. Environment and Configuration

### Property file structure

```yaml
# config-uat.yaml
iedison:
  host: api-iedisonuat.nist.gov
  institution.code: "${secure::iedison.institution.code}"
  keystore.path: "${secure::iedison.keystore.path}"
  keystore.password: "${secure::iedison.keystore.password}"
  key.password: "${secure::iedison.key.password}"

salesforce:
  username: "${secure::sf.username}"
  password: "${secure::sf.password}"
  token: "${secure::sf.token}"
  url: https://login.salesforce.com/services/Soap/u/59.0
```

```yaml
# config-prod.yaml
iedison:
  host: api-iedison.nist.gov
  # ... same structure, different secrets references
```

Select at deploy time: `-Dmule.env=uat` or `-Dmule.env=prod`.

---

## 9. Testing

### 9.1 Unit Testing (MUnit)

Test DataWeave transforms in isolation before any API connectivity:
- Date format conversion (Salesforce Date → MM/DD/YYYY)
- Patent application type mapping (TTS picklist → iEdison code)
- Patent status mapping
- Conditional sub-object selection (nonProvisional vs provisional vs pct)
- Utilization version branching (reportingYear >= 2024 vs <= 2023)

### 9.2 UAT Environment Testing

- iEdison UAT base URL: `https://api-iedisonuat.nist.gov/iedison/api`
- UAT is a live environment — submissions create real records. Use clearly labelled test invention titles (e.g. "TEST — [Institution] — Do Not Process").
- Verify the full round-trip: submit an invention, confirm `inventionReportNumber` is written back to Salesforce, then submit a patent using that number.
- Test the idempotency path: submit the same invention twice and confirm the second call routes to `/update`.

### 9.3 Pre-Production Checklist

- [ ] All Phases 1–3 gap fields deployed to Salesforce
- [ ] Production mTLS certificate provisioned and loaded into Secrets Manager
- [ ] `institutionCode` in Production properties matches NIST registration exactly
- [ ] DataWeave date format tested for all three date fields
- [ ] Error handler paths verified: 400, 401, 404, 500
- [ ] Platform Event `TTS_iEdison_Event__e` defined and subscribed to in Salesforce
- [ ] Dead-letter queue configured and monitored
- [ ] First production submission tested with a non-critical invention record

---

## 10. Open Questions

These implementation decisions were unresolved at the time of writing and should be confirmed with the institution before build:

1. **Trigger mechanism:** Should submissions be triggered manually (button on TTS record), by a scheduled batch (e.g. nightly sweep), or by a Salesforce Flow/Process automation on record change? Each has different retry and volume implications.
2. **Disclosure document attachment:** The Invention create endpoint accepts an optional binary file part (`inventionDisclosure`, up to 50 MB). Should the integration attach the corresponding Salesforce File/ContentDocument automatically, or should document submission remain manual?
3. **Multiple funding agencies and `primaryAgency`:** When a Technology has multiple Funding Agreements, which agency becomes `primaryAgency` for each inventor? Confirm the business rule (likely: the Primary-flagged Funding Agreement's agency).
4. **Transaction date scope for `totalIncome`:** Does the institution report royalty income by transaction date, expected payment date, or fiscal year close date? This determines the SOQL date filter for the Utilization flow's income aggregation.
5. **Retroactive utilization reporting:** Does the institution need to submit Utilization Reports for prior fiscal years (e.g. if the integration is deployed mid-year)? If so, the Utilization flow needs a bulk-submission mode.
