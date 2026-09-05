public with sharing class TTSCore {

    private static final Set<String> VALID_FREQUENCIES = new Set<String>{
        'Daily', 'Weekly', 'Monthly', 'Quarterly', 'Annually'
    };


    // TRANSACTION METHODS - START
    // Written By: Stewart Anderson
    // Date: 13 MAR 2023

    public class TTS_TransactionException extends Exception {}

    public class RelatedRecordsInput {
        @InvocableVariable(label='Start Date')
        public Datetime startDate;
        @InvocableVariable(label='End Date')
        public Datetime endDate;
        @InvocableVariable(label='Frequency')
        public String frequency;
        @InvocableVariable(label='Record ID')
        public String recordId;

        // API 67.0 requires invocable-action parameter classes to expose an explicit
        // no-argument constructor.
        public RelatedRecordsInput() {}
    }

    @InvocableMethod(label='Generate Recurring Transaction Records')
    public static void generateRecurringTransactionRecords(List<RelatedRecordsInput> inputs) {

        // Check object and field accessibility
        if (!Schema.sObjectType.TTS_Transaction__c.isAccessible() || !Schema.sObjectType.TTS_Transaction__c.isCreateable() || !Schema.sObjectType.TTS_Transaction__c.isDeletable()) {
            // Object is not accessible, return or handle accordingly
            System.debug('TTS_Transaction__c is not accessible for the user. Please review user permissions.');
            return;
        }

        // Collect every parent record referenced across all inputs so parents and their
        // children can be queried once in bulk, instead of once per input inside the loop.
        Set<Id> recordIds = new Set<Id>();
        for (RelatedRecordsInput rli : inputs) {
            if (rli.recordId != null) {
                recordIds.add(rli.recordId);
            }
        }

        Map<Id, TTS_Transaction__c> parentsById = new Map<Id, TTS_Transaction__c>([
            SELECT Id, Type__c, Direction__c, Start_Date_Time__c, Recurring__c, End_Date_Time__c, Recurrence_Frequency__c, Agreed_Amount__c, Agreement__c, Agreement_Deliverable__c, Agreement_Party__c, Campaign__c, IP_Actual_Amount__c, IP_Contract__c, IP_External_Payment_Reference__c, IP_Internal_Payment_Reference__c, IP_Opportunity__c, IP_Purchase_Order__c, IP_Related_IP__c, Protection__c
            FROM TTS_Transaction__c
            WHERE Id IN :recordIds
            WITH USER_MODE
        ]);

        // Existing children for every parent, keyed by date, so each input can be evaluated
        // in-memory against the current state (including changes made by earlier inputs in
        // this same call) without re-querying the database on every iteration.
        Map<Id, Map<Datetime, TTS_Transaction__c>> childrenByParentId = new Map<Id, Map<Datetime, TTS_Transaction__c>>();
        for (TTS_Transaction__c child : [
            SELECT Id, Transaction__c, IP_Transaction_Date_Time__c
            FROM TTS_Transaction__c
            WHERE Transaction__c IN :recordIds
            WITH USER_MODE
        ]) {
            if (!childrenByParentId.containsKey(child.Transaction__c)) {
                childrenByParentId.put(child.Transaction__c, new Map<Datetime, TTS_Transaction__c>());
            }
            childrenByParentId.get(child.Transaction__c).put(child.IP_Transaction_Date_Time__c, child);
        }

        List<TTS_Transaction__c> allChildrenToDelete = new List<TTS_Transaction__c>();
        List<TTS_Transaction__c> allNewChildren = new List<TTS_Transaction__c>();

        for (RelatedRecordsInput rli : inputs) {
            // Get the input variables
            Datetime startDate = rli.startDate;
            Datetime endDate = rli.endDate;
            String frequency = rli.frequency;
            String recordId = rli.recordId;

            TTS_Transaction__c parentRecord = recordId == null ? null : parentsById.get(recordId);
            if (parentRecord == null || !VALID_FREQUENCIES.contains(frequency)) {
                continue;
            }

            // Set the end date to 5 years from the start date if it's null or empty
            if (endDate == null) {
                endDate = startDate.addYears(5);
            }

            Map<Datetime, TTS_Transaction__c> existingChildrenByDate = childrenByParentId.get(recordId);
            if (existingChildrenByDate == null) {
                existingChildrenByDate = new Map<Datetime, TTS_Transaction__c>();
                childrenByParentId.put(recordId, existingChildrenByDate);
            }

            // Move child records outside the specified date range out of the "existing" view.
            // A record already in the database is queued for deletion; a record only just
            // created by an earlier input in this same call (no Id yet) is simply dropped
            // from the pending insert batch instead, since it was never persisted.
            List<Datetime> datesOutOfRange = new List<Datetime>();
            for (Datetime childDate : existingChildrenByDate.keySet()) {
                if (childDate < startDate || childDate > endDate) {
                    datesOutOfRange.add(childDate);
                }
            }
            for (Datetime childDate : datesOutOfRange) {
                TTS_Transaction__c child = existingChildrenByDate.remove(childDate);
                if (child.Id != null) {
                    allChildrenToDelete.add(child);
                } else {
                    Integer pendingIndex = allNewChildren.indexOf(child);
                    if (pendingIndex >= 0) {
                        allNewChildren.remove(pendingIndex);
                    }
                }
            }

            // Calculate Recurring Payment Dates
            Datetime currentDate = startDate;
            List<Datetime> dates = new List<Datetime>();
            while (currentDate < endDate) {
                Datetime nextDate = nextOccurrence(currentDate, frequency);
                if (nextDate > endDate) {
                    break;
                }
                dates.add(nextDate);
                currentDate = nextDate;
            }

            // Create related records for each date if they don't already exist
            for (Datetime recordDate : dates) {
                if (!existingChildrenByDate.containsKey(recordDate)) {
                    TTS_Transaction__c newChild = parentRecord.clone();
                    newChild.Transaction__c = recordId;
                    newChild.IP_Transaction_Date_Time__c = recordDate;
                    newChild.IP_Expected_Payment_Date__c = recordDate;
                    allNewChildren.add(newChild);
                    existingChildrenByDate.put(recordDate, newChild);
                }
            }
        }

        // Perform database actions once, after every input has been evaluated.
        if (!allChildrenToDelete.isEmpty()) {
            delete as user allChildrenToDelete;
        }

        if (!allNewChildren.isEmpty()) {
            try {
                insert as user allNewChildren;
            } catch (DmlException e) {
                throw new TTS_TransactionException('Recurring Transaction Generation failed: ' + e.getMessage(), e);
            }
        }
    }

    private static Datetime nextOccurrence(Datetime current, String frequency) {
        switch on frequency {
            when 'Daily' {
                return current.addDays(1);
            }
            when 'Weekly' {
                return current.addDays(7);
            }
            when 'Monthly' {
                return current.addMonths(1);
            }
            when 'Quarterly' {
                return current.addMonths(3);
            }
            when 'Annually' {
                return current.addYears(1);
            }
            when else {
                return current;
            }
        }
    }

    // TRANSACTION METHODS - END
}
