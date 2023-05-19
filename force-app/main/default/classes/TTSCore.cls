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
        if (!Schema.sObjectType.techstarter__TTS_Transaction__c.isAccessible() || !Schema.sObjectType.techstarter__TTS_Transaction__c.isCreateable() || !Schema.sObjectType.techstarter__TTS_Transaction__c.isDeletable()) {
            // Object is not accessible, return or handle accordingly
            System.debug('techstarter__TTS_Transaction__c is not accessible for the user. Please review user permissions.');
            return;
        }

        // Loop through each input and create a new record if necessary
        for (RelatedRecordsInput rli : inputs){
            // Get the input variables
            Datetime startDate = rli.startDate;
            Datetime endDate = rli.endDate;
            String frequency = rli.frequency;
            String recordId = rli.recordId;

            techstarter__TTS_Transaction__c parentRecord = [SELECT Id, techstarter__Direction__c, techstarter__Type__c, techstarter__Start_Date_Time__c, techstarter__Recurring__c, techstarter__End_Date_Time__c, techstarter__Recurrence_Frequency__c, techstarter__Agreed_Amount__c, techstarter__Agreement__c, techstarter__Agreement_Deliverable__c, techstarter__Agreement_Party__c, techstarter__Campaign__c, techstarter__IP_Actual_Amount__c, techstarter__IP_Contract__c, techstarter__IP_External_Payment_Reference__c, techstarter__IP_Internal_Payment_Reference__c, techstarter__IP_Opportunity__c, techstarter__IP_Purchase_Order__c, techstarter__IP_Related_IP__c, techstarter__Protection__c  FROM techstarter__TTS_Transaction__c WHERE Id = :recordId WITH USER_MODE LIMIT 1];

            // Set the end date to 5 years from the start date if it's null or empty
            if (endDate == null) {
                endDate = startDate.addYears(5);
            }

            // Delete child records outside of the specified date range
            List<techstarter__TTS_Transaction__c> childrenToDelete = new List<techstarter__TTS_Transaction__c>();
            for (techstarter__TTS_Transaction__c child : [SELECT Id, techstarter__IP_Transaction_Date_Time__c FROM techstarter__TTS_Transaction__c WHERE techstarter__Transaction__c = :recordId AND (techstarter__IP_Transaction_Date_Time__c < :startDate OR techstarter__IP_Transaction_Date_Time__c > :endDate) WITH USER_MODE]) {
                childrenToDelete.add(child);
            }
            delete as user childrenToDelete;

            // Query for existing child records for the parent record
            Map<Datetime, techstarter__TTS_Transaction__c> existingChildrenByDate = new Map<Datetime, techstarter__TTS_Transaction__c>();
            List<techstarter__TTS_Transaction__c> existingChildren = [SELECT Id, techstarter__Transaction__c, techstarter__IP_Transaction_Date_Time__c FROM techstarter__TTS_Transaction__c WHERE techstarter__Transaction__c = :recordId AND techstarter__IP_Transaction_Date_Time__c >= :startDate AND techstarter__IP_Transaction_Date_Time__c <= :endDate WITH USER_MODE];
            for (techstarter__TTS_Transaction__c child : existingChildren) {
                existingChildrenByDate.put(child.techstarter__IP_Transaction_Date_Time__c, child);
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
            List<techstarter__TTS_Transaction__c> newChildren = new List<techstarter__TTS_Transaction__c>();
            for (Datetime recordDate : dates) {
                if (!existingChildrenByDate.containsKey(recordDate)) {
                    techstarter__TTS_Transaction__c newChild = parentRecord.clone();
                    newChild.techstarter__Transaction__c = recordId;
                    newChild.techstarter__IP_Transaction_Date_Time__c = recordDate;
                    newChild.techstarter__IP_Expected_Payment_Date__c = recordDate;
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