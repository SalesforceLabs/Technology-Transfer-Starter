# Contributing to Technology Transfer Starter

Thank you for your interest in contributing to Technology Transfer Starter! This guide will help you set up your development environment and walk you through the contribution process.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)
- [Salesforce DX Extensions for VSCode](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)
- [CumulusCI](https://cumulusci.readthedocs.io/en/stable/install.html)
- Git
- Access to a Salesforce DevHub

## Getting DevHub Access

To develop on this project, you need access to the namespace DevHub. Please contact **Stewart Anderson** at [stewart.anderson@salesforce.com](mailto:stewart.anderson@salesforce.com) to request access.

Once you have access, authenticate to the DevHub:

```bash
sf org login web --set-default-dev-hub --alias TTSDevHub
```

Set the DevHub as your default:

```bash
sf config set target-dev-hub=TTSDevHub
```

## Development Workflow

### 1. Creating a Development Scratch Org

#### Option A: Using Salesforce CLI

Create a scratch org using the Salesforce CLI:

```bash
sf org create scratch --definition-file orgs/dev.json --alias tts_dev --duration-days 30 --set-default
```

Then connect it to CumulusCI:

```bash
cci org import tts_dev tts_dev
```

#### Option B: Using CumulusCI

Create a scratch org directly with CumulusCI:

```bash
cci org scratch dev tts_dev --days 30
```

### 2. Deploy to Development Org

Deploy the solution to your dev org using CumulusCI:

```bash
cci flow run dev_org --org tts_dev
```

This flow will:
- Update dependencies
- Deploy the metadata
- Assign required permission sets:
  - Technology_Transfer_Starter_Visa_Management
  - Technology_Transfer_Starter_Permission
  - Technology_Transfer_Starter_Space_Manager
  - Technology_Transfer_Starter_Mentoring_Manager

### 3. Make Your Changes

Make your changes in the org through Setup or using the Salesforce UI. You can also make changes directly to the source code in your IDE.

### 4. Retrieve Changes

After making changes in the org, retrieve them back to your local source:

```bash
cci task run retrieve_changes --org tts_dev
```

Review the changes in your source directory to ensure only the intended changes were retrieved.

### 5. Create a QA Scratch Org

Create a QA org to test your changes:

#### Using Salesforce CLI + CumulusCI:

```bash
sf org create scratch --definition-file orgs/dev.json --alias tts_qa --duration-days 30
cci org import tts_qa tts_qa
```

#### Using CumulusCI:

```bash
cci org scratch dev tts_qa --days 30
```

Deploy to the QA org:

```bash
cci flow run qa_org --org tts_qa
```

### 6. Validate Your Changes

Test your changes thoroughly in the QA org to ensure:
- All functionality works as expected
- No regressions were introduced
- All automation and flows execute correctly
- Permission sets provide the correct access

### 7. Submit a Pull Request

Once you've validated your changes:

1. Commit your changes to a feature branch
2. Push the branch to GitHub
3. Create a Pull Request (PR) targeting the `main` branch
4. Provide a clear description of your changes and any testing performed
5. Wait for code review and approval

## Package Publishing (Maintainers Only)

### Creating a New Package Version

To create a new 2GP package version:

```bash
sf package version create --package 0HoDm000000CaTXKA0 --target-dev-hub TTSDevHub --installation-key-bypass --code-coverage --wait 10
```

This command will:
- Create a new package version
- Run Apex tests and validate code coverage
- Wait up to 10 minutes for the process to complete
- Return a package version ID (04t...)

### Promoting a Package Version

After testing the package version, promote it to released status:

```bash
sf package version promote --target-dev-hub TTSDevHub --package 04t...
```

Replace `04t...` with the actual package version ID from the previous step.

### Testing Package Installation

Test the package installation in a scratch org:

```bash
sf package install --wait 20 --package 04t...
```

Replace `04t...` with the package version ID you want to test.

## Useful CumulusCI Commands

### List Available Orgs

```bash
cci org list
```

### View Org Information

```bash
cci org info tts_dev
```

### Open an Org in Browser

```bash
cci org browser tts_dev
```

### Run Specific Tasks

```bash
cci task run deploy --org tts_dev
cci task run assign_permission_sets --org tts_dev
```

### Delete Test Data

```bash
cci task run delete_data --org tts_dev
```

### Load Sample Data

```bash
cci task run load_dataset --org tts_dev
```

## Project Structure

- `force-app/` - Main source directory containing all metadata
- `orgs/` - Scratch org configuration files
- `robot/` - Robot Framework test files
- `cumulusci.yml` - CumulusCI configuration
- `sfdx-project.json` - Salesforce DX project configuration

## Code Standards

- Follow Salesforce best practices for metadata development
- Use meaningful naming conventions
- Add comments to complex automation
- Ensure all Apex code has appropriate test coverage (minimum 75%)
- Test thoroughly before submitting PRs

## Getting Help

If you encounter issues or have questions:

- Review the [CumulusCI documentation](https://cumulusci.readthedocs.io/)
- Check the [Salesforce CLI documentation](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- Contact Stewart Anderson at [stewart.anderson@salesforce.com](mailto:stewart.anderson@salesforce.com)
- Open an issue in the GitHub repository

## License

By contributing to Technology Transfer Starter, you agree that your contributions will be licensed under the same license as the project.
