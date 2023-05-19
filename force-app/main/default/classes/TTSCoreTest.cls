@isTest
private class TTSCoreTest {
    
    @testSetup
    static void setup() {
        // Insert necessary records for the test
        Id spaceFeeRecordTypeId = Schema.SObjectType.techstarter__TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
        techstarter__TTS_Transaction__c parentRecord = new techstarter__TTS_Transaction__c(
            RecordTypeId = spaceFeeRecordTypeId,
            techstarter__Direction__c = 'Incoming',
            techstarter__Type__c = 'Rent',
            techstarter__Start_Date_Time__c = Datetime.now(),
            techstarter__Recurring__c = true,
            techstarter__End_Date_Time__c = Datetime.now().addYears(1),
            techstarter__Recurrence_Frequency__c = 'Monthly',
            techstarter__Agreed_Amount__c = 100.0,
            techstarter__Agreement__c = null,
            techstarter__Agreement_Deliverable__c = null,
            techstarter__Agreement_Party__c = null,
            techstarter__Campaign__c = null,
            techstarter__IP_Actual_Amount__c = null,
            techstarter__IP_Contract__c = null,
            techstarter__IP_External_Payment_Reference__c = null,
            techstarter__IP_Internal_Payment_Reference__c = null,
            techstarter__IP_Opportunity__c = null,
            techstarter__IP_Purchase_Order__c = null,
            techstarter__IP_Related_IP__c = null,
            techstarter__Protection__c = null
        );
        insert parentRecord;
        techstarter__TTS_Transaction__c childRecord = new techstarter__TTS_Transaction__c(
            RecordTypeId = spaceFeeRecordTypeId,
            techstarter__Transaction__c = parentRecord.Id,
            techstarter__IP_Transaction_Date_Time__c = Datetime.now().addDays(1),
            techstarter__IP_Expected_Payment_Date__c = Datetime.now().addDays(1),
            techstarter__Direction__c = parentRecord.techstarter__Direction__c,
            techstarter__Type__c = parentRecord.techstarter__Type__c,
            techstarter__Start_Date_Time__c = parentRecord.techstarter__Start_Date_Time__c,
            techstarter__Recurring__c = parentRecord.techstarter__Recurring__c,
            techstarter__End_Date_Time__c = parentRecord.techstarter__End_Date_Time__c,
            techstarter__Recurrence_Frequency__c = parentRecord.techstarter__Recurrence_Frequency__c,
            techstarter__Agreed_Amount__c = parentRecord.techstarter__Agreed_Amount__c,
            techstarter__Agreement__c = parentRecord.techstarter__Agreement__c,
            techstarter__Agreement_Deliverable__c = parentRecord.techstarter__Agreement_Deliverable__c,
            techstarter__Agreement_Party__c = parentRecord.techstarter__Agreement_Party__c,
            techstarter__Campaign__c = parentRecord.techstarter__Campaign__c,
            techstarter__IP_Actual_Amount__c = parentRecord.techstarter__IP_Actual_Amount__c,
            techstarter__IP_Contract__c = parentRecord.techstarter__IP_Contract__c,
            techstarter__IP_External_Payment_Reference__c = parentRecord.techstarter__IP_External_Payment_Reference__c,
            techstarter__IP_Internal_Payment_Reference__c = parentRecord.techstarter__IP_Internal_Payment_Reference__c,
            techstarter__IP_Opportunity__c = parentRecord.techstarter__IP_Opportunity__c,
            techstarter__IP_Purchase_Order__c = parentRecord.techstarter__IP_Purchase_Order__c,
            techstarter__IP_Related_IP__c = parentRecord.techstarter__IP_Related_IP__c,
            techstarter__Protection__c = parentRecord.techstarter__Protection__c
        );
        insert childRecord;
    }

    @isTest
    static void testGenerateRecurringTransactionRecords() {
        // Prepare the input data for the method
        List<TTSCore.RelatedRecordsInput> inputs = new List<TTSCore.RelatedRecordsInput>();

        TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
        input.startDate = Datetime.now();
        input.endDate = Datetime.now().addYears(2);
        input.frequency = 'Monthly';
        input.recordId = [SELECT Id FROM techstarter__TTS_Transaction__c LIMIT 1].Id;
        inputs.add(input);

        TTSCore.RelatedRecordsInput inputDaily = new TTSCore.RelatedRecordsInput();
        inputDaily.startDate = Datetime.now();
        inputDaily.endDate = Datetime.now().addYears(1);
        inputDaily.frequency = 'Daily';
        inputDaily.recordId = [SELECT Id FROM techstarter__TTS_Transaction__c LIMIT 1].Id;
        inputs.add(inputDaily);

        TTSCore.RelatedRecordsInput inputWeekly = new TTSCore.RelatedRecordsInput();
        inputWeekly.startDate = Datetime.now();
        inputWeekly.endDate = Datetime.now().addYears(2);
        inputWeekly.frequency = 'Weekly';
        inputWeekly.recordId = [SELECT Id FROM techstarter__TTS_Transaction__c LIMIT 1].Id;
        inputs.add(inputWeekly);

        TTSCore.RelatedRecordsInput inputQuarterly = new TTSCore.RelatedRecordsInput();
        inputQuarterly.startDate = Datetime.now();
        inputQuarterly.endDate = Datetime.now().addYears(2);
        inputQuarterly.frequency = 'Quarterly';
        inputQuarterly.recordId = [SELECT Id FROM techstarter__TTS_Transaction__c LIMIT 1].Id;
        inputs.add(inputQuarterly);

        TTSCore.RelatedRecordsInput inputAnnually = new TTSCore.RelatedRecordsInput();
        inputAnnually.startDate = Datetime.now();
        inputAnnually.endDate = Datetime.now().addYears(2);
        inputAnnually.frequency = 'Annually';
        inputAnnually.recordId = [SELECT Id FROM techstarter__TTS_Transaction__c LIMIT 1].Id;
        inputs.add(inputAnnually);

        // Call the method with the input data
        Test.startTest();
        TTSCore.generateRecurringTransactionRecords(inputs);
        Test.stopTest();

        // Verify that child records were created
        Integer expectedCount = 493;
        Integer actualCount = [SELECT COUNT() FROM techstarter__TTS_Transaction__c WHERE techstarter__Transaction__c = :input.recordId];
        System.assertEquals(expectedCount, actualCount, 'Unexpected number of child records');
    }

}