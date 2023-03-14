@isTest
private class TTSCore_test {

    static testMethod void testCreateRecurringTransactions() {
        // Define test data
        TTS_Transaction__c parentTransaction = new TTS_Transaction__c(Direction__c='Incoming', Type__c='Rent', Recurring__c=true);
        insert parentTransaction;
        
        Date startDate = Date.today();
        Date endDate = startDate.addDays(7);
        String frequency = 'Daily';
        
        // Call the createRelatedRecords method
        TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
        input.recordId = parentTransaction.Id;
        input.frequency = frequency;
        input.startDate = startDate;
        input.endDate = endDate;

        List<TTSCore.RelatedRecordsInput> inputs = new List<TTSCore.RelatedRecordsInput>();
        inputs.add(input);

        TTSCore.generateRecurringTransactionRecords(inputs);
        
        // Verify that related records were created
        List<TTS_Transaction__c> childRecords = [SELECT Id, Name, Transaction__c, IP_Transaction_Date_Time__c FROM TTS_Transaction__c WHERE Transaction__c = :parentTransaction.Id];
        System.assertEquals(7, childRecords.size(), 'Unexpected number of child records created');
        
        for (TTS_Transaction__c childRecord : childRecords) {
            System.assertEquals(parentTransaction.Id, childRecord.Transaction__c, 'Incorrect parent account ID');
            System.assertEquals(startDate, childRecord.IP_Transaction_Date_Time__c, 'Incorrect date field value');
        }
    }
}