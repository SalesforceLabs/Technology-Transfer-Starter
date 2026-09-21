// Deletes only records created by seed-demo-data.apex.
String marker = 'DEMO-TTS-AEROSENSE';

delete [SELECT Id FROM techstarter__TTS_Contributor__c WHERE techstarter__IP_Cont_Payment_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Recipient__c WHERE techstarter__IP_Recipient_Payment_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Transaction__c WHERE techstarter__IP_Internal_Payment_Reference__c LIKE :marker + '%'];

delete [SELECT Id FROM techstarter__TTS_Milestone__c WHERE techstarter__Subject__c LIKE 'DEMO | %'];
delete [SELECT Id FROM techstarter__TTS_Success_Plans__c WHERE techstarter__Title__c LIKE 'DEMO | %'];

// Overview__c is the DEMO marker but is a long-text field (not filterable in SOQL), so
// match on the demo mentee Contact instead — the same email marker cleaned up below.
delete [SELECT Id FROM techstarter__TTS_Mentoring_Interest__c WHERE techstarter__Mentoring_Opportunity__r.techstarter__Mentee__r.Email LIKE '%.demo@example.invalid'];
delete [SELECT Id FROM techstarter__TTS_Mentoring_Opportunity__c WHERE techstarter__Mentee__r.Email LIKE '%.demo@example.invalid'];

delete [SELECT Id FROM techstarter__TTS_Space_Asset__c WHERE techstarter__Internal_Asset_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Space_Tenant_Contact__c WHERE techstarter__Space_Tenant__r.techstarter__Space__r.techstarter__Space_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Space_Tenant__c WHERE techstarter__Space__r.techstarter__Space_Reference__c LIKE :marker + '%'];

// Agreement children (parties, deliverables, royalty terms) before the agreement itself.
delete [SELECT Id FROM techstarter__TTS_Royalty_Term__c WHERE techstarter__Agreement__r.techstarter__Title__c LIKE 'DEMO | %'];
delete [SELECT Id FROM techstarter__TTS_Agreement_Party__c WHERE techstarter__Agreement__r.techstarter__Title__c LIKE 'DEMO | %'];
delete [SELECT Id FROM techstarter__TTS_Agreement_Deliverable__c WHERE techstarter__Agreement__r.techstarter__Title__c LIKE 'DEMO | %'];
delete [SELECT Id FROM techstarter__TTS_Agreement__c WHERE techstarter__Title__c LIKE 'DEMO | %'];

// Protection is a restrict-delete lookup child of Protection Family, so its own children,
// junctions and applicants must go first, then the protections, then the family. Both demo
// protections hang off the demo Technology, so match on that marker (the trademark one has
// no family).
delete [SELECT Id FROM techstarter__TTS_Protection_Claim__c WHERE techstarter__Protection__r.techstarter__Technology__r.techstarter__IP_External_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Protection_Litigation__c WHERE techstarter__Protection__r.techstarter__Technology__r.techstarter__IP_External_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_TrademarkIPAssociation__c WHERE techstarter__Protection__r.techstarter__Technology__r.techstarter__IP_External_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Applicant__c WHERE techstarter__IP_External_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Protection__c WHERE techstarter__Technology__r.techstarter__IP_External_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Trademark_Classes__c WHERE Name LIKE 'DEMO | %'];
delete [SELECT Id FROM techstarter__TTS_Protection_Family__c WHERE techstarter__Name_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Disclosure__c WHERE techstarter__External_ID__c LIKE :marker + '%'];

List<techstarter__TTS_Space__c> childSpaces = [
    SELECT Id FROM techstarter__TTS_Space__c
    WHERE techstarter__Space_Reference__c LIKE :marker + '%'
    AND techstarter__Parent_Space__c != null
];
delete childSpaces;
delete [
    SELECT Id FROM techstarter__TTS_Space__c
    WHERE techstarter__Space_Reference__c LIKE :marker + '%'
];

// Inventors are lookup children of Technology — remove them before the technologies.
delete [SELECT Id FROM techstarter__TTS_Inventor__c WHERE techstarter__IP_Contribution__r.techstarter__IP_External_Reference__c LIKE :marker + '%'];

delete [
    SELECT Id FROM techstarter__TTS_Technology__c
    WHERE techstarter__IP_External_Reference__c LIKE :marker + '%'
    AND techstarter__IP_ParentIP__c != null
];
delete [
    SELECT Id FROM techstarter__TTS_Technology__c
    WHERE techstarter__IP_External_Reference__c LIKE :marker + '%'
];

delete [SELECT Id FROM techstarter__TTS_Law_Firm_Matter__c WHERE techstarter__Law_Firm_Matter_Key__c LIKE :marker + '%'];

// Budget periods are master-detail children of Funding Award (cascade on award delete),
// removed explicitly first so cleanup is order-independent if run standalone. The award
// itself is deleted after Technology and Disclosure, which reference it via lookup.
delete [SELECT Id FROM techstarter__TTS_Award_Budget_Period__c WHERE techstarter__Funding_Award__r.techstarter__Award_Number__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Funding_Award__c WHERE techstarter__Award_Number__c LIKE :marker + '%'];

delete [SELECT Id FROM Contract WHERE Account.Name LIKE 'DEMO | %'];
delete [SELECT Id FROM Opportunity WHERE Name = 'DEMO | AeroSense Exclusive Licence'];
delete [SELECT Id FROM Campaign WHERE Name = 'DEMO | AeroSense Industry Partner Outreach'];
delete [SELECT Id FROM Contact WHERE Email LIKE '%.demo@example.invalid'];
delete [SELECT Id FROM Account WHERE Name LIKE 'DEMO | %'];

System.debug(LoggingLevel.INFO, 'DEMO_DATASET_CLEANED: AeroSense demo records removed.');
