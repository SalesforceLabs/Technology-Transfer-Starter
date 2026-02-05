# Technology Transfer Starter

A foundation for Technology Transfer and IP Management on Salesforce

Technology Transfer Starter provides a set of Fields, Page Layouts, Objects, Record Types and Automation to help you get started with using Salesforce for your Technology Transfer, IP Management and Commercialization activities.

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
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tDm000000Da7ZIAS
```

**Sandbox:**
```
https://test.salesforce.com/packaging/installPackage.apexp?p0=04tDm000000Da7ZIAS
```

Replace `04t...` with the latest package version ID. Contact the maintainers for the current version ID.

## Post-Installation Setup

After installation, assign the appropriate permission sets to users:

- **Technology Transfer Starter Permission** - Base permissions for all users
- **Technology Transfer Starter Visa Management** - For visa and immigration management
- **Technology Transfer Starter Space Manager** - For space and resource management
- **Technology Transfer Starter Mentoring Manager** - For mentoring program management

### Assigning Permission Sets

1. Navigate to **Setup** > **Users** > **Permission Sets**
2. Select the appropriate permission set
3. Click **Manage Assignments**
4. Click **Add Assignments**
5. Select users and click **Assign**

## Features

Technology Transfer Starter includes:

- IP Management objects and fields
- Technology Transfer workflows
- Commercialization tracking
- Inventor and applicant management
- Trademark management
- Custom page layouts and record types
- Pre-configured automation

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
