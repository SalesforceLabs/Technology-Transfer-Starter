// Seeds the Technology Transfer Starter demo dataset (part 1 of 2: base records).
// Run datasets/seed-demo-data-2.apex afterwards to add transactions, contributors and recipients.
// Split across two anonymous-Apex blocks to stay under the executeAnonymous size limit.

String marker = 'DEMO-TTS-AEROSENSE';
System.assertEquals(
    0,
    [SELECT COUNT() FROM techstarter__TTS_Technology__c
     WHERE techstarter__IP_External_Reference__c LIKE :marker + '%'],
    'Remove the existing AeroSense demo dataset before running this script.'
);

Date today = Date.today();
Datetime now = Datetime.now();

List<Account> accounts = new List<Account>{
    new Account(Name = 'DEMO | Northbridge University', Type = 'Customer'),
    new Account(Name = 'DEMO | AeroSense Labs Ltd', Type = 'Customer'),
    new Account(Name = 'DEMO | Vector Dynamics Inc', Type = 'Partner'),
    new Account(Name = 'DEMO | Harbor IP Counsel LLP', Type = 'Partner')
};
insert accounts;

List<Contact> contacts = new List<Contact>{
    new Contact(FirstName = 'Maya', LastName = 'Chen', Title = 'Associate Professor of Environmental Engineering', Email = 'maya.chen.demo@example.invalid', AccountId = accounts[0].Id,
        techstarter__Nationality__c = 'India', techstarter__Immigration_Status__c = 'Valid',
        techstarter__Visa_Type__c = 'Exchange Visitor Visa', techstarter__Visa_Number__c = 'DEMO-J1-0001',
        techstarter__Visa_Start_Date__c = Date.today().addMonths(-11), techstarter__Visa_End_Date__c = Date.today().addDays(30),
        techstarter__Passport_Number__c = 'DEMOPP12345', techstarter__Passport_Expiry_Date__c = Date.today().addYears(3),
        techstarter__US_Form_Type__c = 'DS-2019 (J-1 Exchange Visitor)', techstarter__US_SEVIS_ID__c = 'N0012345678', techstarter__US_I94_Number__c = '12345678901',
        techstarter__Work_Authorization__c = true, techstarter__Work_Hours_Limit__c = 20, techstarter__Right_to_Work_Check_Date__c = Date.today().addMonths(-11)),
    new Contact(FirstName = 'Elias', LastName = 'Ward', Title = 'Professor of Embedded Systems', Email = 'elias.ward.demo@example.invalid', AccountId = accounts[0].Id,
        techstarter__Nationality__c = 'Nigeria', techstarter__Immigration_Status__c = 'Valid',
        techstarter__Visa_Type__c = 'Student Visa', techstarter__Visa_Number__c = 'DEMO-UKV-0002',
        techstarter__Visa_Start_Date__c = Date.today().addMonths(-6), techstarter__Visa_End_Date__c = Date.today().addDays(90),
        techstarter__Passport_Number__c = 'DEMOPP67890', techstarter__Passport_Expiry_Date__c = Date.today().addYears(4),
        techstarter__UK_CAS_Number__c = 'E4X8Y2Z1DEMO', techstarter__UK_BRP_Number__c = 'ZR1234567', techstarter__UK_ATAS_Certificate__c = 'ATAS-DEMO-001',
        techstarter__Work_Authorization__c = true, techstarter__Work_Hours_Limit__c = 20, techstarter__Right_to_Work_Check_Date__c = Date.today().addMonths(-6)),
    new Contact(FirstName = 'Rina', LastName = 'Patel', Title = 'Technology Transfer Manager', Email = 'rina.patel.demo@example.invalid', AccountId = accounts[0].Id),
    new Contact(FirstName = 'Jordan', LastName = 'Bell', Title = 'Chief Executive Officer', Email = 'jordan.bell.demo@example.invalid', AccountId = accounts[1].Id),
    new Contact(FirstName = 'Avery', LastName = 'Morgan', Title = 'Commercialisation Mentor', Email = 'avery.morgan.demo@example.invalid', AccountId = accounts[2].Id)
};
insert contacts;

Campaign campaign = new Campaign(
    Name = 'DEMO | AeroSense Industry Partner Outreach',
    IsActive = true,
    StartDate = today.addDays(-90),
    EndDate = today.addDays(90),
    Description = 'Synthetic campaign for testing university technology marketing and partner engagement.'
);
insert campaign;

Opportunity opportunity = new Opportunity(
    Name = 'DEMO | AeroSense Exclusive Licence',
    AccountId = accounts[1].Id,
    StageName = 'Closed Won',
    CloseDate = today.addDays(-30),
    Amount = 125000,
    CampaignId = campaign.Id,
    Description = 'Synthetic exclusive licence opportunity for the AeroSense university spinout.'
);
insert opportunity;

Contract contractRecord = new Contract(
    AccountId = accounts[1].Id,
    Status = 'Draft',
    StartDate = today.addDays(-30),
    ContractTerm = 60,
    Description = 'DEMO | AeroSense patent licence contract'
);
insert contractRecord;

techstarter__TTS_Funding_Award__c fundingAward = new techstarter__TTS_Funding_Award__c(
    Name = 'DEMO | NIH Sustainable Campus Sensing Award',
    techstarter__Award_Number__c = marker + '-AWD-001',
    techstarter__Sponsor__c = accounts[0].Id,
    techstarter__Awarding_Agency__c = 'NIH',
    techstarter__Funding_Type__c = 'Federal Grant',
    techstarter__Bayh_Dole_Subject__c = true,
    techstarter__Principal_Investigator__c = contacts[0].Id,
    techstarter__Award_Start_Date__c = today.addYears(-2),
    techstarter__Award_End_Date__c = today.addYears(3),
    techstarter__Total_Awarded_Amount__c = 1500000,
    techstarter__Status__c = 'Active',
    techstarter__Description__c = 'Synthetic federal award funding the AeroSense sensing research programme.'
);
insert fundingAward;

techstarter__TTS_Technology__c technology = new techstarter__TTS_Technology__c(
    techstarter__IP_Title__c = 'AeroSense Low-Power Laboratory Air Quality Platform',
    techstarter__IP_External_Reference__c = marker + '-TECH-001',
    techstarter__IP_Category__c = 'Device',
    techstarter__Funding_Award__c = fundingAward.Id,
    techstarter__Utilisation_Stage__c = 'Product on Market',
    techstarter__Products_On_Market__c = true,
    techstarter__Product_Names__c = 'AeroSense Monitor One',
    techstarter__First_Commercial_Sale_Date__c = today.addMonths(-3),
    techstarter__US_Manufactured__c = true,
    techstarter__Government_Interest__c = true,
    techstarter__Title_Election_Date__c = today.addYears(-1),
    techstarter__Confirmatory_Licence_Granted__c = true,
    techstarter__IP_Status__c = 'Commercialisation',
    techstarter__TRL__c = 'TRL 6',
    techstarter__IP_Disclosure_Date__c = today.addYears(-2),
    techstarter__IP_Public_Disclosure__c = today.addMonths(-18),
    techstarter__IP_Principal_Inventor_PI__c = contacts[0].Id,
    techstarter__IP_Experimental_Verification__c = true,
    techstarter__IP_Experimental_Verification_Detail__c = 'Validated in three university laboratories over a six-month pilot.',
    techstarter__IP_Prior_Art__c = true,
    techstarter__IP_Prior_Art_detail__c = 'Existing monitors require mains power or frequent calibration; AeroSense combines low-power sensing with adaptive calibration.',
    techstarter__IP_Sponsored_Program__c = true,
    techstarter__IP_Sponsored_Program_Detail__c = 'Developed under the fictional Northbridge Sustainable Campus Research Fund.',
    techstarter__IP_Technical_Description__c = 'A network of low-power environmental sensors with edge processing and adaptive calibration for continuous laboratory monitoring.',
    techstarter__IP_Novelty__c = 'The platform reduces calibration drift while operating for extended periods on battery power.',
    techstarter__IP_Utility__c = 'Supports laboratory safety, facilities management and research-environment assurance.',
    techstarter__IP_Commercial_Market__c = 'Universities, research institutes, life-science laboratories and specialist facilities operators.',
    techstarter__IP_Known_Limitations__c = 'The current prototype requires validation for highly corrosive environments.',
    techstarter__IP_Known_Risks__c = 'Certification timelines and component supply may affect market launch.',
    techstarter__Non_Confidential_Description__c = 'A university-developed sensor platform for continuous, energy-efficient monitoring of laboratory air quality.'
);
insert technology;

techstarter__TTS_Technology__c childTechnology = new techstarter__TTS_Technology__c(
    techstarter__IP_Title__c = 'AeroSense Adaptive Calibration Algorithm',
    techstarter__IP_External_Reference__c = marker + '-TECH-002',
    techstarter__IP_Category__c = 'Software',
    techstarter__IP_Status__c = 'Commercialisation',
    techstarter__TRL__c = 'TRL 5',
    techstarter__IP_ParentIP__c = technology.Id,
    techstarter__IP_Principal_Inventor_PI__c = contacts[1].Id,
    techstarter__IP_Technical_Description__c = 'Software that adjusts sensor baselines using controlled environmental reference data.',
    techstarter__Non_Confidential_Description__c = 'Adaptive software that improves environmental sensor accuracy between scheduled calibrations.'
);
insert childTechnology;

techstarter__TTS_Disclosure__c disclosure = new techstarter__TTS_Disclosure__c(
    techstarter__Status__c = 'Approved',
    techstarter__Disclosure_Title__c = 'AeroSense Low-Power Laboratory Air Quality Sensor',
    techstarter__Disclosure_Description__c = '<p>A low-power sensor platform created by Northbridge University researchers for continuous laboratory air-quality monitoring.</p>',
    techstarter__Disclosure_date__c = today.addYears(-2),
    techstarter__Contact__c = contacts[0].Id,
    techstarter__Technology__c = technology.Id,
    techstarter__Funding_Award__c = fundingAward.Id,
    techstarter__Commercial_Applications__c = 'Laboratory safety, clean rooms, research facilities and university estates.',
    techstarter__Funding_Source__c = 'Grant',
    techstarter__Funding_Details__c = 'Fictional Northbridge Sustainable Campus Research Fund award NB-2024-017.',
    techstarter__Current_Protections__c = 'Patent pending;Trademarked',
    techstarter__Current_Protection_Details__c = 'A provisional patent application and trademark application have been filed.',
    techstarter__Partnership_Collaboration_Details__c = 'Pilot completed with fictional industry collaborator Vector Dynamics Inc.',
    techstarter__External_ID__c = marker + '-DISC-001'
);
insert disclosure;

insert new techstarter__TTS_Inventor__c(
    techstarter__IP_Contribution__c = technology.Id,
    techstarter__IP_Original_Inventor_Name__c = contacts[1].Id,
    techstarter__IP_Contribution_Role__c = 'Researcher',
    techstarter__IP_Is_Primary__c = false,
    techstarter__Percentage_Share__c = 40,
    techstarter__IP_Contribution_Description__c = 'Developed embedded firmware and the adaptive calibration method.'
);
insert new techstarter__TTS_Inventor__c(
    techstarter__IP_Contribution__c = technology.Id,
    techstarter__IP_Original_Inventor_Name__c = contacts[0].Id,
    techstarter__IP_Contribution_Role__c = 'Inventor',
    techstarter__IP_Is_Primary__c = true,
    techstarter__Percentage_Share__c = 60,
    techstarter__IP_Contribution_Description__c = 'Led the sensor architecture, laboratory validation and research programme.'
);

techstarter__TTS_Protection_Family__c protectionFamily = new techstarter__TTS_Protection_Family__c(
    techstarter__Technology__c = technology.Id,
    techstarter__Name_Reference__c = marker + '-FAMILY-001',
    techstarter__Earliest_Priority_Date__c = today.addMonths(-20),
    techstarter__Additional_notes__c = 'Synthetic family covering the AeroSense sensor architecture in the US and through an international filing.'
);
insert protectionFamily;

List<techstarter__TTS_Law_Firm_Matter__c> lawFirmMatters = new List<techstarter__TTS_Law_Firm_Matter__c>{
    new techstarter__TTS_Law_Firm_Matter__c(
        techstarter__Law_Firm__c = accounts[3].Id,
        techstarter__Law_Firm_Matter_Key__c = marker + '-LFM-001',
        techstarter__Matter_Docket_Number__c = 'HIP-2025-AERO-001',
        techstarter__Status__c = 'Active',
        techstarter__Opened_Date__c = today.addMonths(-18),
        techstarter__Description__c = 'DEMO | Harbor IP Counsel engagement for the AeroSense patent family filing and prosecution.'
    ),
    new techstarter__TTS_Law_Firm_Matter__c(
        techstarter__Law_Firm__c = accounts[3].Id,
        techstarter__Law_Firm_Matter_Key__c = marker + '-LFM-002',
        techstarter__Matter_Docket_Number__c = 'HIP-2025-AERO-LIT-002',
        techstarter__Status__c = 'Closed',
        techstarter__Opened_Date__c = today.addMonths(-8),
        techstarter__Closed_Date__c = today.addMonths(-2),
        techstarter__Description__c = 'DEMO | Harbor IP Counsel engagement for the AeroSense infringement settlement.'
    )
};
insert lawFirmMatters;

Map<String, Id> protectionRecordTypes = new Map<String, Id>();
for (RecordType recordType : [
    SELECT Id, DeveloperName FROM RecordType
    WHERE SobjectType = 'techstarter__TTS_Protection__c'
    AND DeveloperName IN ('Patent', 'Trademark')
]) {
    protectionRecordTypes.put(recordType.DeveloperName, recordType.Id);
}
System.assertEquals(2, protectionRecordTypes.size(), 'Patent and Trademark record types must be installed.');

List<techstarter__TTS_Protection__c> protections = new List<techstarter__TTS_Protection__c>{
    new techstarter__TTS_Protection__c(
        RecordTypeId = protectionRecordTypes.get('Patent'),
        techstarter__Title__c = 'Distributed Low-Power Environmental Sensor Network',
        techstarter__Description__c = 'Synthetic patent record for AeroSense sensing, communications and adaptive-calibration methods.',
        techstarter__Stage__c = 'Examination',
        techstarter__Protection_Status__c = 'Pending',
        techstarter__Technology__c = technology.Id,
        techstarter__Protection_Family__c = protectionFamily.Id,
        techstarter__Account__c = accounts[0].Id,
        techstarter__Attorney__c = contacts[2].Id,
        techstarter__Law_Firm_Matter__c = lawFirmMatters[0].Id,
        techstarter__Type__c = 'Utility',
        techstarter__Patent_Application_Type__c = 'PCT',
        techstarter__Patent_Application_Number__c = 'DEMO-PCT-2025-001',
        techstarter__Patent_number__c = marker + '-PAT-001',
        techstarter__Jurisdiction__c = 'World Intellectual Property Organization (WIPO) (WO)',
        techstarter__Priority_Date__c = today.addMonths(-20),
        techstarter__Filing_Date__c = today.addMonths(-18),
        techstarter__Publication_Date__c = today.addMonths(-6)
    ),
    new techstarter__TTS_Protection__c(
        RecordTypeId = protectionRecordTypes.get('Trademark'),
        techstarter__Title__c = 'AEROSENSE',
        techstarter__Description__c = 'Synthetic trademark for the AeroSense laboratory-monitoring platform.',
        techstarter__Stage__c = 'Registration',
        techstarter__Protection_Status__c = 'Registered',
        techstarter__Technology__c = technology.Id,
        techstarter__Account__c = accounts[0].Id,
        techstarter__Trademark_registration_number__c = marker + '-TM-001',
        techstarter__Jurisdiction__c = 'United States of America (USA) (US)',
        techstarter__Registered__c = true,
        techstarter__Registration_date__c = today.addMonths(-4),
        techstarter__Renewal_date__c = today.addYears(9)
    )
};
insert protections;

List<techstarter__TTS_Applicant__c> applicants = new List<techstarter__TTS_Applicant__c>{
    new techstarter__TTS_Applicant__c(
        techstarter__Protection__c = protections[0].Id,
        techstarter__Account__c = accounts[0].Id,
        techstarter__Type__c = 'Educational Institution',
        techstarter__Lead_Applicant__c = true,
        techstarter__IP_External_Reference__c = marker + '-APPL-001'
    ),
    new techstarter__TTS_Applicant__c(
        techstarter__Protection__c = protections[0].Id,
        techstarter__Individual_Contact__c = contacts[0].Id,
        techstarter__Type__c = 'Individual Inventor',
        techstarter__Lead_Applicant__c = false,
        techstarter__IP_External_Reference__c = marker + '-APPL-002'
    )
};
insert applicants;

insert new List<techstarter__TTS_Protection_Claim__c>{
    new techstarter__TTS_Protection_Claim__c(
        techstarter__Protection__c = protections[0].Id,
        techstarter__Claim__c = 'A synthetic independent claim covering a distributed low-power sensing architecture with local environmental processing.',
        techstarter__Status__c = 'Pending'
    ),
    new techstarter__TTS_Protection_Claim__c(
        techstarter__Protection__c = protections[0].Id,
        techstarter__Claim__c = 'A synthetic dependent claim covering adaptive calibration using controlled reference observations.',
        techstarter__Status__c = 'Pending'
    )
};

insert new techstarter__TTS_Protection_Litigation__c(
    techstarter__Protection__c = protections[0].Id,
    techstarter__Applicant__c = applicants[0].Id,
    techstarter__Law_Firm_Matter__c = lawFirmMatters[1].Id,
    techstarter__Type__c = 'Patent infringement',
    techstarter__Status__c = 'Settlement',
    techstarter__Case_Outcome__c = 'Settlement',
    techstarter__Case_Number_Reference__c = marker + '-CASE-001',
    techstarter__Court__c = 'Fictional Federal Technology Court',
    techstarter__Plaintiff__c = 'Northbridge University',
    techstarter__Defendant__c = 'Synthetic Sensors LLC',
    techstarter__Filing_Date__c = today.addMonths(-8),
    techstarter__Settlement_Date__c = today.addMonths(-2),
    techstarter__Damages_Sought__c = 250000,
    techstarter__Settlement_Amount__c = 75000
);

List<techstarter__TTS_Trademark_Classes__c> trademarkClasses = new List<techstarter__TTS_Trademark_Classes__c>{
    new techstarter__TTS_Trademark_Classes__c(Name = 'DEMO | NICE Class 9', techstarter__Class_Number__c = '9', techstarter__Class_Heading__c = 'Scientific, measuring and monitoring apparatus and software.'),
    new techstarter__TTS_Trademark_Classes__c(Name = 'DEMO | NICE Class 42', techstarter__Class_Number__c = '42', techstarter__Class_Heading__c = 'Scientific and technological services, research and software services.')
};
insert trademarkClasses;

insert new List<techstarter__TTS_TrademarkIPAssociation__c>{
    new techstarter__TTS_TrademarkIPAssociation__c(techstarter__Trademark_Classes__c = trademarkClasses[0].Id, techstarter__Protection__c = protections[1].Id),
    new techstarter__TTS_TrademarkIPAssociation__c(techstarter__Trademark_Classes__c = trademarkClasses[1].Id, techstarter__Protection__c = protections[1].Id)
};

Map<String, Id> agreementRecordTypes = new Map<String, Id>();
for (RecordType recordType : [
    SELECT Id, DeveloperName FROM RecordType
    WHERE SobjectType = 'techstarter__TTS_Agreement__c'
    AND DeveloperName IN ('Licence_Agreement', 'Sponsored_Research_Agreement_SRA')
]) {
    agreementRecordTypes.put(recordType.DeveloperName, recordType.Id);
}
System.assertEquals(2, agreementRecordTypes.size(), 'Licence and sponsored research record types must be installed.');

List<techstarter__TTS_Agreement__c> agreements = new List<techstarter__TTS_Agreement__c>{
    new techstarter__TTS_Agreement__c(
        RecordTypeId = agreementRecordTypes.get('Licence_Agreement'),
        techstarter__Title__c = 'DEMO | AeroSense Exclusive Patent Licence',
        techstarter__Description__c = 'Synthetic exclusive licence from Northbridge University to its AeroSense spinout.',
        techstarter__Agreement_Type__c = 'Patent License Agreement',
        techstarter__Status__c = 'Executed',
        techstarter__Technology__c = technology.Id,
        techstarter__Opportunity__c = opportunity.Id,
        techstarter__Licensee_Account__c = accounts[1].Id,
        techstarter__Licensee__c = contacts[3].Id,
        techstarter__Effective_Date__c = now.addDays(-30),
        techstarter__Expiration_Date__c = now.addYears(5),
        techstarter__Renewal_Date__c = now.addYears(4),
        techstarter__Budget__c = 125000,
        techstarter__Payment_terms__c = 'An initial licence fee followed by annual minimum payments and sales royalties.',
        techstarter__Usage_Restrictions__c = 'Use is limited to laboratory and research-facility environmental monitoring.',
        techstarter__Governing_Law__c = 'Fictional State of Northbridge'
    ),
    new techstarter__TTS_Agreement__c(
        RecordTypeId = agreementRecordTypes.get('Sponsored_Research_Agreement_SRA'),
        techstarter__Title__c = 'DEMO | AeroSense Industrial Validation Study',
        techstarter__Description__c = 'Synthetic sponsored research project with Vector Dynamics to validate AeroSense in specialist facilities.',
        techstarter__Agreement_Type__c = 'Collaborative SRA',
        techstarter__Status__c = 'Active',
        techstarter__Technology__c = technology.Id,
        techstarter__Licensee_Account__c = accounts[2].Id,
        techstarter__Effective_Date__c = now.addDays(-60),
        techstarter__Expiration_Date__c = now.addYears(1),
        techstarter__Budget__c = 80000,
        techstarter__Payment_terms__c = 'Two staged research payments linked to validation reports.'
    )
};
insert agreements;

List<techstarter__TTS_Agreement_Party__c> agreementParties = new List<techstarter__TTS_Agreement_Party__c>{
    new techstarter__TTS_Agreement_Party__c(techstarter__Agreement__c = agreements[0].Id, techstarter__Account__c = accounts[0].Id, techstarter__Type__c = 'Provider'),
    new techstarter__TTS_Agreement_Party__c(techstarter__Agreement__c = agreements[0].Id, techstarter__Account__c = accounts[1].Id, techstarter__Type__c = 'Recipient'),
    new techstarter__TTS_Agreement_Party__c(techstarter__Agreement__c = agreements[0].Id, techstarter__Contact__c = contacts[0].Id, techstarter__Type__c = 'Principal Investigator (PI)')
};
insert agreementParties;

List<techstarter__TTS_Royalty_Term__c> royaltyTerms = new List<techstarter__TTS_Royalty_Term__c>{
    new techstarter__TTS_Royalty_Term__c(
        techstarter__Agreement__c = agreements[0].Id,
        techstarter__Agreement_Party__c = agreementParties[1].Id,
        techstarter__Direction__c = 'Incoming',
        techstarter__Royalty_Obligation_Type__c = 'Licensee royalty',
        techstarter__Royalty_Basis__c = 'Net sales',
        techstarter__Royalty_Rate__c = 5.0,
        techstarter__Effective_Start_Date__c = today.addDays(-30),
        techstarter__Effective_End_Date__c = today.addYears(5),
        techstarter__Description__c = 'DEMO | 5% net-sales royalty payable by AeroSense Labs on licensed products.'
    ),
    new techstarter__TTS_Royalty_Term__c(
        techstarter__Agreement__c = agreements[0].Id,
        techstarter__Direction__c = 'Outgoing',
        techstarter__Royalty_Obligation_Type__c = 'Inventor revenue share',
        techstarter__Royalty_Basis__c = 'Net sales',
        techstarter__Royalty_Rate__c = 40.0,
        techstarter__Effective_Start_Date__c = today.addDays(-30),
        techstarter__Description__c = 'DEMO | 40% inventor revenue share of net royalty income distributed to the principal inventor.'
    )
};
insert royaltyTerms;

List<techstarter__TTS_Agreement_Deliverable__c> deliverables = new List<techstarter__TTS_Agreement_Deliverable__c>{
    new techstarter__TTS_Agreement_Deliverable__c(
        techstarter__Agreement__c = agreements[0].Id,
        techstarter__Name__c = 'DEMO | Technical Transfer Package',
        techstarter__Type__c = 'Technical Documentation',
        techstarter__Status__c = 'Complete',
        techstarter__Deadline__c = now.addDays(-10),
        techstarter__Description__c = 'Design files, calibration procedures and prototype test results.',
        techstarter__Expected_Outcome__c = 'AeroSense Labs can reproduce and test the university prototype.'
    ),
    new techstarter__TTS_Agreement_Deliverable__c(
        techstarter__Agreement__c = agreements[0].Id,
        techstarter__Name__c = 'DEMO | Quarterly Commercialisation Report',
        techstarter__Type__c = 'Reports',
        techstarter__Status__c = 'In Progress',
        techstarter__Deadline__c = now.addDays(45),
        techstarter__Description__c = 'Commercial progress, product development and royalty-bearing sales report.'
    )
};
insert deliverables;

techstarter__TTS_Space__c innovationHub = new techstarter__TTS_Space__c(
    techstarter__Space_Reference__c = marker + '-SPACE-001',
    techstarter__Type__c = 'Incubator',
    techstarter__Programme__c = 'Incubator',
    techstarter__Status__c = 'Occupied',
    techstarter__Total_Capacity__c = 20,
    techstarter__Address__c = 'Innovation Way, Northbridge University, Example City',
    techstarter__Space_Description__c = 'University incubator for research-led ventures and translational projects.'
);
insert innovationHub;

techstarter__TTS_Space__c aeroSenseLab = new techstarter__TTS_Space__c(
    techstarter__Space_Reference__c = marker + '-SPACE-002',
    techstarter__Parent_Space__c = innovationHub.Id,
    techstarter__Type__c = 'Lab / Makerspace',
    techstarter__Programme__c = 'Incubator',
    techstarter__Status__c = 'Occupied',
    techstarter__Total_Capacity__c = 5,
    techstarter__Address__c = 'Lab 2B, Innovation Way, Northbridge University, Example City',
    techstarter__Space_Description__c = 'Prototype assembly and calibration space occupied by AeroSense Labs.'
);
insert aeroSenseLab;

insert new List<techstarter__TTS_Space_Asset__c>{
    new techstarter__TTS_Space_Asset__c(
        techstarter__Space__c = aeroSenseLab.Id,
        techstarter__Name__c = 'Environmental Calibration Chamber',
        techstarter__Description__c = 'Controlled chamber used to validate environmental sensor accuracy.',
        techstarter__Asset_Category__c = 'Lab / Makerspace',
        techstarter__Internal_Asset_Reference__c = marker + '-ASSET-001',
        techstarter__Purchase_Date__c = today.addYears(-1),
        techstarter__Estimated_Value__c = 28000,
        techstarter__Status__c = 'In Use'
    ),
    new techstarter__TTS_Space_Asset__c(
        techstarter__Space__c = aeroSenseLab.Id,
        techstarter__Name__c = 'Sensor Prototyping Workstation',
        techstarter__Description__c = 'Electronics workstation for building and testing AeroSense prototypes.',
        techstarter__Asset_Category__c = 'IT / Equipment',
        techstarter__Internal_Asset_Reference__c = marker + '-ASSET-002',
        techstarter__Purchase_Date__c = today.addMonths(-10),
        techstarter__Estimated_Value__c = 12000,
        techstarter__Status__c = 'In Use'
    )
};

techstarter__TTS_Space_Tenant__c tenant = new techstarter__TTS_Space_Tenant__c(
    techstarter__Space__c = aeroSenseLab.Id,
    techstarter__Account__c = accounts[1].Id,
    techstarter__Type__c = 'Company',
    techstarter__Venture_Category__c = 'Spinout',
    techstarter__Venture_Stage__c = 'Scaling',
    techstarter__Membership_Tier__c = 'Subsidised',
    techstarter__Occupancy_Type__c = 'Private Office',
    techstarter__Start_Date__c = today.addMonths(-6),
    techstarter__End_Date__c = today.addMonths(18)
);
insert tenant;

insert new List<techstarter__TTS_Space_Tenant_Contact__c>{
    new techstarter__TTS_Space_Tenant_Contact__c(
        techstarter__Space_Tenant__c = tenant.Id,
        techstarter__Contact__c = contacts[3].Id,
        techstarter__Start_Date__c = today.addMonths(-6),
        techstarter__End_Date__c = today.addMonths(18),
        techstarter__Is_Primary_Contact__c = true
    ),
    new techstarter__TTS_Space_Tenant_Contact__c(
        techstarter__Space_Tenant__c = tenant.Id,
        techstarter__Contact__c = contacts[0].Id,
        techstarter__Start_Date__c = today.addMonths(-6),
        techstarter__End_Date__c = today.addMonths(12),
        techstarter__Is_Primary_Contact__c = false
    )
};

techstarter__TTS_Mentoring_Opportunity__c mentoringOpportunity = new techstarter__TTS_Mentoring_Opportunity__c(
    techstarter__Stage__c = 'Open',
    techstarter__Mentee__c = contacts[0].Id,
    techstarter__Expiry_Date__c = today.addDays(30),
    techstarter__Mentoring_Start_Date__c = today.addDays(45),
    techstarter__Mentoring_End_Date__c = today.addMonths(6),
    techstarter__Overview__c = 'DEMO | Commercialisation mentoring for the AeroSense university spinout team.',
    techstarter__Applicable_Industries__c = 'Higher Education/Academia;Laboratory Instruments/Research Tools',
    techstarter__Requested_Skills__c = 'Business;Funding;Marketing;Presentations'
);
insert mentoringOpportunity;

insert new techstarter__TTS_Mentoring_Interest__c(
    techstarter__Mentoring_Opportunity__c = mentoringOpportunity.Id,
    techstarter__Contact__c = contacts[2].Id,
    techstarter__Status__c = 'Interested',
    techstarter__Selected_Mentor__c = false,
    techstarter__Ranking__c = '2'
);
insert new techstarter__TTS_Mentoring_Interest__c(
    techstarter__Mentoring_Opportunity__c = mentoringOpportunity.Id,
    techstarter__Contact__c = contacts[4].Id,
    techstarter__Status__c = 'Selected',
    techstarter__Selected_Mentor__c = true,
    techstarter__Ranking__c = '1'
);

techstarter__TTS_Success_Plans__c successPlan = new techstarter__TTS_Success_Plans__c(
    techstarter__Title__c = 'DEMO | AeroSense Commercialisation Readiness Plan',
    techstarter__Object__c = 'TTS_Technology__c'
);
insert successPlan;

insert new List<techstarter__TTS_Milestone__c>{
    new techstarter__TTS_Milestone__c(
        techstarter__Success_Plans__c = successPlan.Id,
        techstarter__Who__c = contacts[2].Id,
        techstarter__Subject__c = 'DEMO | Complete invention assessment',
        techstarter__IP_Milestone_Description__c = 'Review technical merit, ownership, prior art and commercial potential.',
        techstarter__Date__c = 'Disclosure Date',
        techstarter__When__c = 'After',
        techstarter__Number_of_Days__c = 14,
        techstarter__Unit__c = 'Days'
    ),
    new techstarter__TTS_Milestone__c(
        techstarter__Success_Plans__c = successPlan.Id,
        techstarter__Who__c = contacts[2].Id,
        techstarter__Subject__c = 'DEMO | Prepare patent filing',
        techstarter__IP_Milestone_Description__c = 'Complete drafting and inventor review before the planned public disclosure.',
        techstarter__Date__c = 'Public Disclosure Date',
        techstarter__When__c = 'Before',
        techstarter__Number_of_Days__c = 30,
        techstarter__Unit__c = 'Days'
    ),
    new techstarter__TTS_Milestone__c(
        techstarter__Success_Plans__c = successPlan.Id,
        techstarter__Who__c = contacts[2].Id,
        techstarter__Subject__c = 'DEMO | Review licence performance',
        techstarter__IP_Milestone_Description__c = 'Review development progress, reporting and payment obligations.',
        techstarter__Date__c = 'Created Date',
        techstarter__When__c = 'After',
        techstarter__Number_of_Days__c = 3,
        techstarter__Unit__c = 'Months'
    )
};

System.assertEquals(2, [SELECT COUNT() FROM techstarter__TTS_Technology__c WHERE techstarter__IP_External_Reference__c LIKE :marker + '%']);
System.assertEquals(1, [SELECT COUNT() FROM techstarter__TTS_Disclosure__c WHERE techstarter__External_ID__c = :marker + '-DISC-001']);
System.assertEquals(1, [SELECT COUNT() FROM techstarter__TTS_Funding_Award__c WHERE techstarter__Award_Number__c = :marker + '-AWD-001']);
System.assertEquals(2, [SELECT COUNT() FROM techstarter__TTS_Protection__c WHERE techstarter__Technology__c = :technology.Id]);
System.assertEquals(2, [SELECT COUNT() FROM techstarter__TTS_Agreement__c WHERE techstarter__Technology__c = :technology.Id]);
System.assertEquals(2, [SELECT COUNT() FROM techstarter__TTS_Law_Firm_Matter__c WHERE techstarter__Law_Firm_Matter_Key__c LIKE :marker + '%']);
System.assertEquals(2, [SELECT COUNT() FROM techstarter__TTS_Royalty_Term__c WHERE techstarter__Agreement__c = :agreements[0].Id]);
System.assertEquals(1, [SELECT COUNT() FROM techstarter__TTS_Mentoring_Interest__c WHERE techstarter__Mentoring_Opportunity__c = :mentoringOpportunity.Id AND techstarter__Selected_Mentor__c = true]);
System.assertEquals(contacts[0].Id, [SELECT techstarter__IP_Principal_Inventor_PI__c FROM techstarter__TTS_Technology__c WHERE Id = :technology.Id].techstarter__IP_Principal_Inventor_PI__c);

System.debug(LoggingLevel.INFO, 'DEMO_DATASET_SEEDED_PART_1: base records created. Run datasets/seed-demo-data-2.apex next to add transactions.');
