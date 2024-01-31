# Technology-Transfer-Starter

A foundation for Technology Transfer and IP Management on Salesforce

Technology Transfer Starter provides a set of Fields, Page Layouts, Objects, Record Types and Automation to help you get started with using Salesforce for your Technology Transfer, IP Management and Commercialization activities.

# Install Latest Release (AppExchange)

https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000G0x6zUAB

# Requirements

- Salesforce Cli
- Salesforce DX Extensions for VSCode
- CumulusCI

# Development

To work on this project in a scratch org:

You must have access to develop against the namespace for this project. Ensure DevHub is set to the default for the project. In my case the DevHub is connected to the project with alias TTSDevHub so update this command with yours sf config set target-dev-hub=TTSDevHub

1. Create a new Scratch Org using the Salesforce command "SFDX: Create a default scratch org..." - Set the alias to 'tts_dev' and accept the rest of the prompts.
2. Connect the org to CumulusCI using cci org import tts_dev tts_dev
3. You now have a connected org called tts_dev where you will work on the project.
4. Deploy the solution to the dev org by running cci flow run dev_org --org tts_dev

The process above provides you with an org, which has the current configuration in it. Once you have made the changes you want, move onto the next steps

5. Retrieve the changes using cci task run retrieve_changes --org tts_dev
6. Check the changes within the source
7. Create another org but call it tts_qa and then deploy the source to it to check that it works
8. Make any changes.

At this point your changes should be ok to commit to a Pull Request (PR). In GitHub desktop, create a PR for your branch, to main branch.
