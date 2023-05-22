@isTest
private class TTSCoreTest {
    
    @testSetup
    static void setup() {
        // Insert necessary records for the test
        Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
        TTS_Transaction__c parentRecord = new TTS_Transaction__c(
            RecordTypeId = spaceFeeRecordTypeId,
            Direction__c = 'Incoming',
            Type__c = 'Rent',
            Start_Date_Time__c = Datetime.now(),
            Recurring__c = true,
            End_Date_Time__c = Datetime.now().addYears(1),
            Recurrence_Frequency__c = 'Monthly',
            Agreed_Amount__c = 100.0,
            Agreement__c = null,
            Agreement_Deliverable__c = null,
            Agreement_Party__c = null,
            Campaign__c = null,
            IP_Actual_Amount__c = null,
            IP_Contract__c = null,
            IP_External_Payment_Reference__c = null,
            IP_Internal_Payment_Reference__c = null,
            IP_Opportunity__c = null,
            IP_Purchase_Order__c = null,
            IP_Related_IP__c = null,
            Protection__c = null
        );
        insert parentRecord;
        TTS_Transaction__c childRecord = new TTS_Transaction__c(
            RecordTypeId = spaceFeeRecordTypeId,
            Transaction__c = parentRecord.Id,
            IP_Transaction_Date_Time__c = Datetime.now().addDays(1),
            IP_Expected_Payment_Date__c = Datetime.now().addDays(1),
            Direction__c = parentRecord.Direction__c,
            Type__c = parentRecord.Type__c,
            Start_Date_Time__c = parentRecord.Start_Date_Time__c,
            Recurring__c = parentRecord.Recurring__c,
            End_Date_Time__c = parentRecord.End_Date_Time__c,
            Recurrence_Frequency__c = parentRecord.Recurrence_Frequency__c,
            Agreed_Amount__c = parentRecord.Agreed_Amount__c,
            Agreement__c = parentRecord.Agreement__c,
            Agreement_Deliverable__c = parentRecord.Agreement_Deliverable__c,
            Agreement_Party__c = parentRecord.Agreement_Party__c,
            Campaign__c = parentRecord.Campaign__c,
            IP_Actual_Amount__c = parentRecord.IP_Actual_Amount__c,
            IP_Contract__c = parentRecord.IP_Contract__c,
            IP_External_Payment_Reference__c = parentRecord.IP_External_Payment_Reference__c,
            IP_Internal_Payment_Reference__c = parentRecord.IP_Internal_Payment_Reference__c,
            IP_Opportunity__c = parentRecord.IP_Opportunity__c,
            IP_Purchase_Order__c = parentRecord.IP_Purchase_Order__c,
            IP_Related_IP__c = parentRecord.IP_Related_IP__c,
            Protection__c = parentRecord.Protection__c
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
        input.recordId = [SELECT Id FROM TTS_Transaction__c LIMIT 1].Id;
        inputs.add(input);

        TTSCore.RelatedRecordsInput inputDaily = new TTSCore.RelatedRecordsInput();
        inputDaily.startDate = Datetime.now();
        inputDaily.endDate = Datetime.now().addYears(1);
        inputDaily.frequency = 'Daily';
        inputDaily.recordId = [SELECT Id FROM TTS_Transaction__c LIMIT 1].Id;
        inputs.add(inputDaily);

        TTSCore.RelatedRecordsInput inputWeekly = new TTSCore.RelatedRecordsInput();
        inputWeekly.startDate = Datetime.now();
        inputWeekly.endDate = Datetime.now().addYears(2);
        inputWeekly.frequency = 'Weekly';
        inputWeekly.recordId = [SELECT Id FROM TTS_Transaction__c LIMIT 1].Id;
        inputs.add(inputWeekly);

        TTSCore.RelatedRecordsInput inputQuarterly = new TTSCore.RelatedRecordsInput();
        inputQuarterly.startDate = Datetime.now();
        inputQuarterly.endDate = Datetime.now().addYears(2);
        inputQuarterly.frequency = 'Quarterly';
        inputQuarterly.recordId = [SELECT Id FROM TTS_Transaction__c LIMIT 1].Id;
        inputs.add(inputQuarterly);

        TTSCore.RelatedRecordsInput inputAnnually = new TTSCore.RelatedRecordsInput();
        inputAnnually.startDate = Datetime.now();
        inputAnnually.endDate = Datetime.now().addYears(2);
        inputAnnually.frequency = 'Annually';
        inputAnnually.recordId = [SELECT Id FROM TTS_Transaction__c LIMIT 1].Id;
        inputs.add(inputAnnually);

        // Call the method with the input data
        Test.startTest();
        TTSCore.generateRecurringTransactionRecords(inputs);
        Test.stopTest();

        // Verify that child records were created
        Integer expectedCount = 493;
        Integer actualCount = [SELECT COUNT() FROM TTS_Transaction__c WHERE Transaction__c = :input.recordId];
        System.assertEquals(expectedCount, actualCount, 'Unexpected number of child records');
    }

}