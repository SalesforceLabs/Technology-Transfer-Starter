# Technology Transfer Starter

A practical starting point for managing technology transfer and intellectual property on Salesforce.

Technology Transfer Starter gives university and research organisation Technology Transfer Offices a connected workspace for the records and activities they manage every day. It brings disclosures, technologies, inventors, intellectual property protections, agreements, commercial opportunities and financial transactions together in Salesforce, reducing the need to track each stage in separate spreadsheets or systems.

The solution provides a ready-made data model, guided processes, purpose-built record pages, progress paths, reports and a dashboard. Offices can use it as a foundation and adapt it to their policies, terminology and operating model.

## Features

- **Disclosure intake and review** - Collect invention details, funding information, commercial applications and supporting documents through a guided disclosure form. Approved disclosures can be turned into Technology records without re-entering the information.
- **Technology portfolio management** - Keep technical, market and prior-art information together, assess Technology Readiness Levels and follow each Technology from initial disclosure through protection and commercialization.
- **Inventor and contributor records** - Link inventors and other contributors to a Technology, record their roles and contribution shares, and identify the principal inventor.
- **IP protection management** - Manage patents, trademarks, copyrights and trade secrets, including ownership, jurisdictions, key dates, applicants, claims, related filings, litigation details and the law-firm matters handling them.
- **Agreement management** - Record licence, confidentiality, material transfer, sponsored research and other agreements, together with their parties, terms, dates, deliverables and related Technologies.
- **Commercial and financial tracking** - Connect Technologies to Opportunities, Contracts, Campaigns and Agreements. Record incoming and outgoing payments, define royalty terms on agreements, create recurring payment schedules and allocate amounts to contributors or other recipients.
- **Reports and dashboard** - View Technology counts by status and readiness level, disclosure trends and agreement revenue using the included reports and Technology Disclosure Dashboard.
- **Technology Transfer workspace** - Use a ready-made Salesforce app with dedicated pages, progress paths, tabs and views for the records your office works with most often.
- **Mentoring management** - Advertise mentoring opportunities, record expressions of interest, rank potential mentors and track the selected mentoring relationship.
- **Space and tenant management** - Track offices, labs, incubators, accelerators, hot desks, co-working and event space, along with the programme each space supports. Manage tenants and their contacts with venture category (student startup, spinout, external and more), venture stage, membership tier, occupancy type and departure reason, categorise equipment as assets, and attribute space fees to the paying tenant. A daily flow raises tenancy-expiry reminder tasks at 90, 30 and 7 days before an end date, and space status follows occupancy automatically.
- **Visa and immigration management** - Track nationality, immigration status, visa type and dates, work authorization, passports and US / UK-specific references on Contact records, with a formula-driven days-to-expiry field and a daily flow that raises reminder tasks at 90, 30 and 7 days before expiry. See [Set Up Visa Management](docs/visa-management-setup.md).
- **REST API integration** - Read, create and update the package's custom objects from external systems through a namespaced Apex REST endpoint. The exposed object list is derived from the package schema at run time, so every shipped object is available automatically. See [Get Started with the REST API](docs/rest-api-getting-started.md).

## Installation

### Option 1: Install from AppExchange (Recommended)

The easiest way to install Technology Transfer Starter is through the Salesforce AppExchange:

[Install from AppExchange](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000G0x6zUAB)

1. Click the link above or visit the AppExchange listing
2. Click "Get It Now"
3. Choose whether to install in production or sandbox
4. Log in to your Salesforce org
5. Follow the installation wizard
6. Select the appropriate installation option:
   - **Install for Admins Only** - Recommended for initial setup
   - **Install for All Users** - After configuring permissions
   - **Install for Specific Profiles** - For controlled rollout

### Option 2: Direct Installation Link

You can also install the latest package version directly using the package installation URL:

**Production:**
```
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tg7000000N5lNAAS
```

**Sandbox:**
```
https://test.salesforce.com/packaging/installPackage.apexp?p0=04tg7000000N5lNAAS
```

Replace `04t...` with the latest package version ID. Contact the maintainers for the current version ID.

## Post-Installation Setup

Access is controlled through a **layered permission-set model**. Assign the base set to every staff user, then stack the functional add-ons each user needs on top of it.

**Base (assign to all staff):**

- **Technology Transfer Starter Permission** - The shared foundation: Account/Contact read, read/write on all core TTS objects, tabs, app and Apex. Required for the add-ons below to work — always assign it alongside them.

**Functional add-ons (co-assign with base, per role):**

- **Technology Transfer Starter Visa Management** - Contact edit plus the visa / immigration fields.
- **Technology Transfer Starter Space Manager** - Space, tenant and asset management, with its own app.
- **Technology Transfer Starter Mentoring Manager** - Mentoring opportunities and interests, with its own app.
- **Technology Transfer Starter IP & Legal Protection Manager** - Protection families, claims, litigation, applicants and law-firm matters.
- **Technology Transfer Starter Royalty & Finance Manager** - Royalty terms and related financial records.

Each add-on is a pure delta — it grants only what base does not, so it must be assigned *with* base, not on its own.

**Standalone sets (assign instead of base):**

- **Technology Transfer Starter Administrator** - Full CRUD plus View All / Modify All on every TTS object, for package admins.
- **TTS Integration User** - Object and field access for the REST API integration user only; not for standard staff.

You can assign several sets at once from the CLI:

```bash
sf org assign permset \
  --name Technology_Transfer_Starter_Permission \
  --name Technology_Transfer_Starter_Visa_Management \
  --name Technology_Transfer_Starter_Space_Manager \
  --target-org <your-org>
```

### Assigning Permission Sets from Setup

1. Navigate to **Setup** > **Users** > **Permission Sets**
2. Select the appropriate permission set
3. Click **Manage Assignments**
4. Click **Add Assignments**
5. Select users and click **Assign**

## Contributing

Interested in contributing to Technology Transfer Starter? Check out our [Contributing Guide](CONTRIBUTING.md) for information on:

- Setting up your development environment
- Creating scratch orgs
- Making and testing changes
- Submitting pull requests

## Support

For issues, questions, or feature requests:

- Open an issue in the [GitHub repository](https://github.com/SalesforceLabs/Technology-Transfer-Starter)
- Contact Stewart Anderson at [stewart.anderson@salesforce.com](mailto:stewart.anderson@salesforce.com)

## License

[View License Information]

---

Built with ❤️ by Salesforce Labs
