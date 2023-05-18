public with sharing class TTSCore {



    // TRANSACTION METHODS - START
    // Written By: Stewart Anderson
    // Date: 13 MAR 2023


    public class RelatedRecordsInput {
        @InvocableVariable(label='Start Date')
        public Datetime startDate;
        @InvocableVariable(label='End Date')
        public Datetime endDate;
        @InvocableVariable(label='Frequency')
        public String frequency;
        @InvocableVariable(label='Record ID')
        public String recordId;
    }

    @InvocableMethod(label='Generate Recurring Transaction Records')
    public static void generateRecurringTransactionRecords(List<RelatedRecordsInput> inputs) {

        // Check object and field accessibility
        if (!Schema.sObjectType.TTS_Transaction__c.isAccessible() || !Schema.sObjectType.TTS_Transaction__c.isCreateable() || !Schema.sObjectType.TTS_Transaction__c.isDeletable()) {
            // Object is not accessible, return or handle accordingly
            System.debug('TTS_Transaction__c is not accessible for the user. Please review user permissions.');
            return;
        }

        // Loop through each input and create a new record if necessary
        for (RelatedRecordsInput rli : inputs){
            // Get the input variables
            Datetime startDate = rli.startDate;
            Datetime endDate = rli.endDate;
            String frequency = rli.frequency;
            String recordId = rli.recordId;

            TTS_Transaction__c parentRecord = [SELECT Id, Direction__c, Type__c, Start_Date_Time__c, Recurring__c, End_Date_Time__c, Recurrence_Frequency__c, Agreed_Amount__c, Agreement__c, Agreement_Deliverable__c, Agreement_Party__c, Campaign__c, IP_Actual_Amount__c, IP_Contract__c, IP_External_Payment_Reference__c, IP_Internal_Payment_Reference__c, IP_Opportunity__c, IP_Purchase_Order__c, IP_Related_IP__c, Protection__c  FROM TTS_Transaction__c WHERE Id = :recordId WITH USER_MODE LIMIT 1];

            // Set the end date to 5 years from the start date if it's null or empty
            if (endDate == null) {
                endDate = startDate.addYears(5);
            }

            // Delete child records outside of the specified date range
            List<TTS_Transaction__c> childrenToDelete = new List<TTS_Transaction__c>();
            for (TTS_Transaction__c child : [SELECT Id, IP_Transaction_Date_Time__c FROM TTS_Transaction__c WHERE Transaction__c = :recordId AND (IP_Transaction_Date_Time__c < :startDate OR IP_Transaction_Date_Time__c > :endDate) WITH USER_MODE]) {
                childrenToDelete.add(child);
            }
            delete as user childrenToDelete;

            // Query for existing child records for the parent record
            Map<Datetime, TTS_Transaction__c> existingChildrenByDate = new Map<Datetime, TTS_Transaction__c>();
            List<TTS_Transaction__c> existingChildren = [SELECT Id, Transaction__c, IP_Transaction_Date_Time__c FROM TTS_Transaction__c WHERE Transaction__c = :recordId AND IP_Transaction_Date_Time__c >= :startDate AND IP_Transaction_Date_Time__c <= :endDate WITH USER_MODE];
            for (TTS_Transaction__c child : existingChildren) {
                existingChildrenByDate.put(child.IP_Transaction_Date_Time__c, child);
            }

            // Calculate Recurring Payment Dates
            Datetime currentDate = startDate;
            List<Datetime> dates = new List<Datetime>();
            if (frequency == 'Daily') {
                while (currentDate >= startDate && currentDate < endDate) {
                    currentDate = currentDate.addDays(1);
                    dates.add(currentDate);
                }
            } else if (frequency == 'Weekly') {
                while (currentDate >= startDate && currentDate < endDate) {
                    currentDate = currentDate.addDays(7);
                    dates.add(currentDate);
                }
            } else if (frequency == 'Monthly') {
                while (currentDate >= startDate && currentDate < endDate) {
                    currentDate = currentDate.addMonths(1);
                    dates.add(currentDate);
                }
            } else if (frequency == 'Quarterly') {
                while (currentDate >= startDate && currentDate < endDate) {
                    currentDate = currentDate.addMonths(3);
                    dates.add(currentDate);
                }
            } else if (frequency == 'Annually') {
                while (currentDate >= startDate && currentDate < endDate) {
                    currentDate = currentDate.addYears(1);
                    dates.add(currentDate);
                }
            }

            // Create related records for each date if they don't already exist
            List<TTS_Transaction__c> newChildren = new List<TTS_Transaction__c>();
            for (Datetime recordDate : dates) {
                if (!existingChildrenByDate.containsKey(recordDate)) {
                    TTS_Transaction__c newChild = parentRecord.clone();
                    newChild.Transaction__c = recordId;
                    newChild.IP_Transaction_Date_Time__c = recordDate;
                    newChild.IP_Expected_Payment_Date__c = recordDate;
                    newChildren.add(newChild);
                }
            }            

            // Perform database actions after the loop has completed
            try {
                if (!newChildren.isEmpty()) {
                    insert as user newChildren;
                }
            } catch (Exception e) {
                // Add results to System Log
                System.debug('Recurring Transactions Generation FAILED: ' + e.getMessage());
            }
        }

        
        
    }

    
    // TRANSACTION METHODS - END
}