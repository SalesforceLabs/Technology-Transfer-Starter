public with sharing class tts_core {

    public class RelatedRecordsInput {
        @InvocableVariable(label='Start Date')
        public Date startDate;
        @InvocableVariable(label='End Date')
        public Date endDate;
        @InvocableVariable(label='Frequency')
        public String frequency;
        @InvocableVariable(label='Record ID')
        public String recordId;
        @InvocableVariable(label='Direction')
        public String direction;
        @InvocableVariable(label='Type')
        public String type;
    }

    public class RelatedRecordsOutput {
        @InvocableVariable(label='Status')
        public String status;
    }

    @InvocableMethod(label='Create Recurring Transaction Records')
    public static void createRelatedTransactionRecords(List<RelatedRecordsInput> inputs) {

        List<RelatedRecordsOutput> outputs = new List<RelatedRecordsOutput>();
        for (RelatedRecordsInput input : inputs) {
            // Get the input variables
            Date startDate = input.startDate;
            Date endDate = input.endDate;
            String frequency = input.frequency;
            String recordId = input.recordId;
            String direction = input.direction;
            String type = input.type;

            // Perform the logic to create related records
            // Calculate the recurring dates for the current parent record
            Date currentDate = startDate;
            List<Date> dates = new List<Date>();
            if (frequency == 'Daily') {
                while (currentDate <= endDate) {
                    dates.add(currentDate);
                    currentDate = currentDate.addDays(1);
                }
            } else if (frequency == 'Weekly') {
                while (currentDate <= endDate) {
                    dates.add(currentDate);
                    currentDate = currentDate.addDays(7);
                }
            } else if (frequency == 'Monthly') {
                while (currentDate <= endDate) {
                    dates.add(currentDate);
                    currentDate = currentDate.addMonths(1);
                }
            } else if (frequency == 'Quarterly') {
                while (currentDate <= endDate) {
                    dates.add(currentDate);
                    currentDate = currentDate.addMonths(3);
                }
            } else if (frequency == 'Annually') {
                while (currentDate <= endDate) {
                    dates.add(currentDate);
                    currentDate = currentDate.addYears(1);
                }
            }

            // Create related records for each date if they don't already exist
            List<TTS_Transaction__c> newChildren = new List<TTS_Transaction__c>();
            for (Date RecordDate : dates) {
                List<TTS_Transaction__c> existingChildren = [SELECT Id FROM TTS_Transaction__c WHERE IsDeleted = False AND Transaction__c = :recordId AND IP_Transaction_Date_Time__c = :RecordDate];
                if (existingChildren.isEmpty()) {
                    TTS_Transaction__c newChild = new TTS_Transaction__c();
                    newChild.Transaction__c = recordId;
                    newChild.IP_Transaction_Date_Time__c = RecordDate;
                    newChild.IP_Expected_Payment_Date__c = RecordDate;
                    newChild.Direction__c = direction;
                    newChild.Type__c = type;
                    // Set any additional fields or relationships for the new related record
                    newChildren.add(newChild);
                }
            }

            // Perform database actions after the loop has completed
            try {
                if (!newChildren.isEmpty()) {
                    insert newChildren;
                }
                // Add the output variables (if any)
                RelatedRecordsOutput output = new RelatedRecordsOutput();
                output.status = 'success'; // Or 'error' if something went wrong
                outputs.add(output);
            } catch (Exception e) {
                // Add the output variables (if any)
                RelatedRecordsOutput output = new RelatedRecordsOutput();
                output.status = 'error - ' + e.getMessage(); // Or 'error' if something went wrong
                outputs.add(output);
            }

            System.debug('Outputs: ' + outputs);
        }
        
    }

    
    
}