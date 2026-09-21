// Seeds the Technology Transfer Starter demo dataset (part 2 of 2: transactions).
// Prerequisite: run datasets/seed-demo-data.apex first. This re-queries the base records by marker.

String marker = 'DEMO-TTS-AEROSENSE';
Date today = Date.today();
Datetime now = Datetime.now();

techstarter__TTS_Technology__c technology = [SELECT Id FROM techstarter__TTS_Technology__c WHERE techstarter__IP_External_Reference__c = :marker + '-TECH-001' LIMIT 1];
techstarter__TTS_Protection__c patent = [SELECT Id FROM techstarter__TTS_Protection__c WHERE techstarter__Patent_number__c = :marker + '-PAT-001' LIMIT 1];
techstarter__TTS_Agreement__c licenceAgreement = [SELECT Id FROM techstarter__TTS_Agreement__c WHERE techstarter__Title__c = 'DEMO | AeroSense Exclusive Patent Licence' LIMIT 1];
techstarter__TTS_Agreement_Party__c recipientParty = [SELECT Id FROM techstarter__TTS_Agreement_Party__c WHERE techstarter__Agreement__c = :licenceAgreement.Id AND techstarter__Type__c = 'Recipient' LIMIT 1];
techstarter__TTS_Agreement_Deliverable__c transferDeliverable = [SELECT Id FROM techstarter__TTS_Agreement_Deliverable__c WHERE techstarter__Agreement__c = :licenceAgreement.Id AND techstarter__Name__c = 'DEMO | Technical Transfer Package' LIMIT 1];
techstarter__TTS_Royalty_Term__c incomingRoyalty = [SELECT Id FROM techstarter__TTS_Royalty_Term__c WHERE techstarter__Agreement__c = :licenceAgreement.Id AND techstarter__Direction__c = 'Incoming' LIMIT 1];
techstarter__TTS_Law_Firm_Matter__c patentMatter = [SELECT Id FROM techstarter__TTS_Law_Firm_Matter__c WHERE techstarter__Law_Firm_Matter_Key__c = :marker + '-LFM-001' LIMIT 1];
techstarter__TTS_Space__c aeroSenseLab = [SELECT Id FROM techstarter__TTS_Space__c WHERE techstarter__Space_Reference__c = :marker + '-SPACE-002' LIMIT 1];
techstarter__TTS_Space_Tenant__c aeroSenseTenant = [SELECT Id FROM techstarter__TTS_Space_Tenant__c WHERE techstarter__Space__c = :aeroSenseLab.Id LIMIT 1];
Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'DEMO | AeroSense Exclusive Licence' LIMIT 1];
Account aeroSenseAcctForContract = [SELECT Id FROM Account WHERE Name = 'DEMO | AeroSense Labs Ltd' LIMIT 1];
Contract contractRecord = [SELECT Id FROM Contract WHERE AccountId = :aeroSenseAcctForContract.Id ORDER BY CreatedDate DESC LIMIT 1];
Campaign campaign = [SELECT Id FROM Campaign WHERE Name = 'DEMO | AeroSense Industry Partner Outreach' LIMIT 1];
Account northbridge = [SELECT Id FROM Account WHERE Name = 'DEMO | Northbridge University' LIMIT 1];
Account aeroSenseAcct = [SELECT Id FROM Account WHERE Name = 'DEMO | AeroSense Labs Ltd' LIMIT 1];
Account vector = [SELECT Id FROM Account WHERE Name = 'DEMO | Vector Dynamics Inc' LIMIT 1];
Contact principalInventor = [SELECT Id FROM Contact WHERE Email = 'maya.chen.demo@example.invalid' LIMIT 1];
techstarter__TTS_Funding_Award__c fundingAward = [SELECT Id FROM techstarter__TTS_Funding_Award__c WHERE techstarter__Award_Number__c = :marker + '-AWD-001' LIMIT 1];

insert new List<techstarter__TTS_Award_Budget_Period__c>{
    new techstarter__TTS_Award_Budget_Period__c(techstarter__Funding_Award__c = fundingAward.Id, techstarter__Period_Number__c = 1, techstarter__Period_Start__c = today.addYears(-2), techstarter__Period_End__c = today.addYears(-1), techstarter__Budgeted_Amount__c = 500000, techstarter__Actual_Spend__c = 480000),
    new techstarter__TTS_Award_Budget_Period__c(techstarter__Funding_Award__c = fundingAward.Id, techstarter__Period_Number__c = 2, techstarter__Period_Start__c = today.addYears(-1), techstarter__Period_End__c = today, techstarter__Budgeted_Amount__c = 500000, techstarter__Actual_Spend__c = 510000)
};

Map<String, Id> transactionRecordTypes = new Map<String, Id>();
for (RecordType recordType : [
    SELECT Id, DeveloperName FROM RecordType
    WHERE SobjectType = 'techstarter__TTS_Transaction__c'
    AND DeveloperName IN ('Patent_Expense', 'Space_Fee')
]) {
    transactionRecordTypes.put(recordType.DeveloperName, recordType.Id);
}
System.assertEquals(2, transactionRecordTypes.size(), 'Patent and space transaction record types must be installed.');

List<techstarter__TTS_Transaction__c> transactions = new List<techstarter__TTS_Transaction__c>{
    new techstarter__TTS_Transaction__c(
        RecordTypeId = transactionRecordTypes.get('Patent_Expense'),
        techstarter__Direction__c = 'Outgoing',
        techstarter__Type__c = 'Patent - Filing',
        techstarter__IP_Related_IP__c = technology.Id,
        techstarter__Protection__c = patent.Id,
        techstarter__Agreement__c = licenceAgreement.Id,
        techstarter__Law_Firm_Matter__c = patentMatter.Id,
        techstarter__Payment_Status__c = 'Paid',
        techstarter__IP_Opportunity__c = opportunity.Id,
        techstarter__Agreed_Amount__c = 9000,
        techstarter__IP_Actual_Amount__c = 8750,
        techstarter__IP_Transaction_Date_Time__c = now.addMonths(-18),
        techstarter__IP_Expected_Payment_Date__c = now.addMonths(-18),
        techstarter__IP_Internal_Payment_Reference__c = marker + '-TXN-001',
        techstarter__IP_External_Payment_Reference__c = marker + '-LAW-001',
        techstarter__IP_Purchase_Order__c = marker + '-PO-001'
    ),
    new techstarter__TTS_Transaction__c(
        RecordTypeId = transactionRecordTypes.get('Patent_Expense'),
        techstarter__Direction__c = 'Incoming',
        techstarter__Type__c = 'Licence Income',
        techstarter__IP_Related_IP__c = technology.Id,
        techstarter__Protection__c = patent.Id,
        techstarter__Agreement__c = licenceAgreement.Id,
        techstarter__Agreement_Party__c = recipientParty.Id,
        techstarter__Agreement_Deliverable__c = transferDeliverable.Id,
        techstarter__Payment_Status__c = 'Received',
        techstarter__IP_Opportunity__c = opportunity.Id,
        techstarter__IP_Contract__c = contractRecord.Id,
        techstarter__Campaign__c = campaign.Id,
        techstarter__Agreed_Amount__c = 50000,
        techstarter__IP_Actual_Amount__c = 50000,
        techstarter__IP_Transaction_Date_Time__c = now.addDays(-20),
        techstarter__IP_Expected_Payment_Date__c = now.addDays(-30),
        techstarter__IP_Internal_Payment_Reference__c = marker + '-TXN-002',
        techstarter__IP_External_Payment_Reference__c = marker + '-BANK-001'
    ),
    new techstarter__TTS_Transaction__c(
        RecordTypeId = transactionRecordTypes.get('Space_Fee'),
        techstarter__Direction__c = 'Incoming',
        techstarter__Type__c = 'Rent',
        techstarter__Space__c = aeroSenseLab.Id,
        techstarter__Space_Tenant__c = aeroSenseTenant.Id,
        techstarter__Agreed_Amount__c = 1800,
        techstarter__IP_Actual_Amount__c = 1800,
        techstarter__Recurring__c = true,
        techstarter__Recurrence_Frequency__c = 'Monthly',
        techstarter__Start_Date_Time__c = now.addMonths(-6),
        techstarter__End_Date_Time__c = now.addMonths(18),
        techstarter__IP_Transaction_Date_Time__c = now.addDays(-5),
        techstarter__IP_Internal_Payment_Reference__c = marker + '-TXN-003'
    ),
    new techstarter__TTS_Transaction__c(
        RecordTypeId = transactionRecordTypes.get('Patent_Expense'),
        techstarter__Direction__c = 'Incoming',
        techstarter__Type__c = 'Royalties',
        techstarter__IP_Related_IP__c = technology.Id,
        techstarter__Protection__c = patent.Id,
        techstarter__Agreement__c = licenceAgreement.Id,
        techstarter__Agreement_Party__c = recipientParty.Id,
        techstarter__Royalty_Term__c = incomingRoyalty.Id,
        techstarter__Payment_Status__c = 'Received',
        techstarter__Applied_Royalty_Rate__c = 5.0,
        techstarter__Reported_Royalty_Revenue__c = 120000,
        techstarter__Royalty_Report_Start_Date__c = today.addMonths(-6),
        techstarter__Royalty_Report_End_Date__c = today.addMonths(-3),
        techstarter__Agreed_Amount__c = 6000,
        techstarter__IP_Actual_Amount__c = 6000,
        techstarter__IP_Transaction_Date_Time__c = now.addDays(-15),
        techstarter__IP_Internal_Payment_Reference__c = marker + '-TXN-004',
        techstarter__IP_External_Payment_Reference__c = marker + '-BANK-002'
    )
};
insert transactions;

insert new List<techstarter__TTS_Contributor__c>{
    new techstarter__TTS_Contributor__c(
        techstarter__IP_Related_Transaction__c = transactions[1].Id,
        techstarter__Account__c = aeroSenseAcct.Id,
        techstarter__Amount__c = 40000,
        techstarter__IP_Date_Time__c = now.addDays(-20),
        techstarter__IP_Cont_Payment_Reference__c = marker + '-CONT-001',
        techstarter__Comments__c = 'Initial licence fee from AeroSense Labs.'
    ),
    new techstarter__TTS_Contributor__c(
        techstarter__IP_Related_Transaction__c = transactions[1].Id,
        techstarter__Account__c = vector.Id,
        techstarter__Amount__c = 10000,
        techstarter__IP_Date_Time__c = now.addDays(-20),
        techstarter__IP_Cont_Payment_Reference__c = marker + '-CONT-002',
        techstarter__Comments__c = 'Industrial validation contribution from Vector Dynamics.'
    )
};

insert new List<techstarter__TTS_Recipient__c>{
    new techstarter__TTS_Recipient__c(
        techstarter__IP_Transaction__c = transactions[1].Id,
        techstarter__IP_Recipient_Contact__c = principalInventor.Id,
        techstarter__Amount__c = 30000,
        techstarter__IP_Recipient_Payment_Date_Time__c = now.addDays(-10),
        techstarter__IP_Recipient_Payment_Reference__c = marker + '-RECIP-001',
        techstarter__IP_Recipient_Comments__c = 'Synthetic 60 percent inventor distribution.'
    ),
    new techstarter__TTS_Recipient__c(
        techstarter__IP_Transaction__c = transactions[1].Id,
        techstarter__IP_Recipient_Account__c = northbridge.Id,
        techstarter__Amount__c = 20000,
        techstarter__IP_Recipient_Payment_Date_Time__c = now.addDays(-10),
        techstarter__IP_Recipient_Payment_Reference__c = marker + '-RECIP-002',
        techstarter__IP_Recipient_Comments__c = 'Synthetic institutional share retained for research and technology transfer.'
    )
};


System.assertEquals(4, [SELECT COUNT() FROM techstarter__TTS_Transaction__c WHERE techstarter__IP_Internal_Payment_Reference__c LIKE :marker + '%']);
System.assertEquals(2, [SELECT COUNT() FROM techstarter__TTS_Award_Budget_Period__c WHERE techstarter__Funding_Award__c = :fundingAward.Id]);

System.debug(LoggingLevel.INFO, 'DEMO_DATASET_SEEDED_PART_2: transactions, contributors and recipients created.');
