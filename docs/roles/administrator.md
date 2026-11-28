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
  <li class="task-list-item"><input type="checkbox" disabled> Review the validation rules below with each team before go-live, so users know why a save can be rejected.</li>
</ul>

### Flows the package ships

All ship **Active** except the two marked **Draft**.

| Flow | Runs on · when | What it does |
| --- | --- | --- |
| `TTS_Disclosure_Submission` | Disclosure · screen flow | Disclosure form for inventors; can be paused and resumed. Submitting moves Status from New to Review. |
| `TTS_Generate_Tech_Record_from_Disclosure` | Disclosure · **Approve Disclosure** action | Creates the Technology record from the disclosure (or says one is already linked). |
| `TTS_Auto_Update_PI_on_Technology` | Inventor · after save | Sets the Principal Inventor on the Technology from the primary Inventor record. |
| `TTS_Generate_Recurring_Schedule` | Transaction · **Generate Schedule** action | Builds the recurring child Transactions (calls the `TTSCore` invocable via the subflow below). See [Royalty & Finance]({{ '/roles/royalty-finance/' | relative_url }}). |
| `TTS_Subflow_for_generating_recurring_transactions` | Transaction · subflow | Creates missing schedule rows and removes untouched ones outside the range. |
| `TTS_Space_Auto_Status` | Space Tenant · after save | Sets the parent Space to Occupied or Unoccupied from its current tenancies. |
| `TTS_Tenancy_Expiry_Reminder` | Space Tenant · daily | Reminder Task 90, 30 and 7 days before a current tenancy ends. |
| `TTS_Update_Tenant_Contact_on_Change` | Tenant Contact · after save | Keeps the Current Contact flag up to date when dates change. |
| `TTS_Tenant_Contact_Scheduled_Actions` | Tenant Contact · daily | Keeps the Current Contact flag up to date as start and end dates pass. |
| `TTS_Tenant_Contact_Set_IsCurrent_Field` | Tenant Contact · subflow | Sets the Current Contact flag (used by the two flows above). |
| `TTS_Mentoring_Set_Chosen_Mentor_on_Opportunity` | Mentoring Interest · after save | Sets the Chosen Mentor on the Mentoring Opportunity. |
| `TTS_Visa_Expiry_Reminder` | Contact · daily | Reminder Task 90, 30 and 7 days before a visa ends (skipped once status is Expired). |
| `Auto_Link_Contract_to_Opportunity` | Opportunity · after save | **Draft.** Creates a Contract when an Opportunity is closed. |
| `Success_Plan_Setup` | Technology · screen flow | **Draft.** Creates or applies a Success Plan, dated from the Created, Disclosure or Public Disclosure date. It does not check whether a plan was already applied. |

### Validation rules

These reject a save with the message shown to the user. Ten ship active.

| Object | Rule | Blocks a save when |
| --- | --- | --- |
| Agreement | `TTS_Coverage_Allocation_100_Pct` | Technology Coverage allocations total more than 100%. |
| Agreement | `TTS_Single_Coverage_Requires_Primary` | It covers a single technology but Primary Technology is blank. |
| Transaction | `TTS_Contributor_Recipient_Sum_Match` | Contributor and Recipient amounts don't sum to the Actual Amount. |
| Transaction | `TTS_Royalty_Rate_Revenue_Match` | Actual Amount isn't Applied Royalty Rate × Reported Royalty Revenue (rounded up to the cent). |
| Transaction | `TTS_Royalty_Term_Agreement_Consistency` | Its Agreement or Agreement Party differs from the selected Royalty Term's. |
| Technology | `TTS_TotalContributionShareChecker` | Contribution shares total outside 0–100%. |
| Technology | `TTS_TotalPrimaryContributersCheck` | More than one primary contributor. |
| Mentoring Opportunity | `Dates_Check` | End Date is before Start Date. |
| Mentoring Opportunity | `Ensure_Only_One_Selected_Mentor` | More than one Mentor Interest is selected. |
| Space Tenant | `Ensure_a_tenant_is_provided` | Neither a Contact nor an Account is linked. |

`TTS_Alternative_Distribution_Check` (Inventor: Alternative Distribution can't be the Original Inventor) ships **inactive**. Activate it if your office wants that check.

## Fields to add to layouts

Fields the package ships **without a page layout**: add them to your own layouts (or
create layouts) before the relevant team uses them:

| Object | Fields not on any package layout |
| --- | --- |
| **Contact** | The package's Contact layout leaves out the 19 visa/immigration fields. Use the dedicated [Visa management setup]({{ '/visa-management-setup/' | relative_url }}). |
| **Funding Award** (`TTS_Funding_Award__c`) | No layout ships. Create one (award number, agency, funding type, Bayh-Dole subject, dates, amount). |
| **Award Budget Period** (`TTS_Award_Budget_Period__c`) | No layout ships. Create one and add it as a related list on Funding Award. |
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

## Security and data

<ul class="contains-task-list">
  <li class="task-list-item"><input type="checkbox" disabled> Review field-level security per permission set before go-live. Access comes from permission sets, not profiles, so check who holds each add-on.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Treat the Contact visa fields as sensitive personal data. Grant Visa Management only to staff who need it, and follow the <a href="{{ '/visa-management-setup/' | relative_url }}#prerequisites">visa data-policy note</a>.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Inventor personal details and financial records (Transactions, Royalty Terms) are also sensitive. If your org licenses Salesforce Shield, consider these fields for encryption and field audit history.</li>
  <li class="task-list-item"><input type="checkbox" disabled> Honour contact communication preferences with the standard Individual object (data privacy) if your org uses it.</li>
  <li class="task-list-item"><input type="checkbox" disabled> For API access, follow the REST guide's <a href="{{ '/rest-api-getting-started/' | relative_url }}#security-practices">Security practices</a>.</li>
</ul>
