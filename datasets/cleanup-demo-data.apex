// Deletes only records created by seed-demo-data.apex.
String marker = 'DEMO-TTS-AEROSENSE';

delete [SELECT Id FROM techstarter__TTS_Contributor__c WHERE techstarter__IP_Cont_Payment_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Recipient__c WHERE techstarter__IP_Recipient_Payment_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Transaction__c WHERE techstarter__IP_Internal_Payment_Reference__c LIKE :marker + '%'];

delete [SELECT Id FROM techstarter__TTS_Milestone__c WHERE techstarter__Subject__c LIKE 'DEMO | %'];
delete [SELECT Id FROM techstarter__TTS_Success_Plans__c WHERE techstarter__Title__c LIKE 'DEMO | %'];

delete [SELECT Id FROM techstarter__TTS_Mentoring_Interest__c WHERE techstarter__Mentoring_Opportunity__r.techstarter__Overview__c LIKE 'DEMO | %'];
delete [SELECT Id FROM techstarter__TTS_Mentoring_Opportunity__c WHERE techstarter__Overview__c LIKE 'DEMO | %'];

delete [SELECT Id FROM techstarter__TTS_Space_Asset__c WHERE techstarter__Internal_Asset_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Space_Tenant_Contact__c WHERE techstarter__Space_Tenant__r.techstarter__Space__r.techstarter__Space_Reference__c LIKE :marker + '%'];
delete [SELECT Id FROM techstarter__TTS_Space_Tenant__c WHERE techstarter__Space__r.techstarter__Space_Reference__c LIKE :marker + '%'];

delete [SELECT Id FROM techstarter__TTS_Agreement__c WHERE techstarter__Title__c LIKE 'DEMO | %'];
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

delete [
    SELECT Id FROM techstarter__TTS_Technology__c
    WHERE techstarter__IP_External_Reference__c LIKE :marker + '%'
    AND techstarter__IP_ParentIP__c != null
];
delete [
    SELECT Id FROM techstarter__TTS_Technology__c
    WHERE techstarter__IP_External_Reference__c LIKE :marker + '%'
];

delete [SELECT Id FROM Contract WHERE Description = 'DEMO | AeroSense patent licence contract'];
delete [SELECT Id FROM Opportunity WHERE Name = 'DEMO | AeroSense Exclusive Licence'];
delete [SELECT Id FROM Campaign WHERE Name = 'DEMO | AeroSense Industry Partner Outreach'];
delete [SELECT Id FROM Contact WHERE Email LIKE '%.demo@example.invalid'];
delete [SELECT Id FROM Account WHERE Name LIKE 'DEMO | %'];

System.debug(LoggingLevel.INFO, 'DEMO_DATASET_CLEANED: AeroSense demo records removed.');
