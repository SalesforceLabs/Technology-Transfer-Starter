public with sharing class TTSCore {

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

        // Deduplicate inputs by recordId, keeping the last input for each parent. This avoids
        // stacking multiple schedules on the same parent in one call and makes the in-memory
        // lookup O(1) instead of O(n²).
        Map<Id, RelatedRecordsInput> deduped = new Map<Id, RelatedRecordsInput>();
        for (RelatedRecordsInput rli : inputs) {
            if (rli.recordId != null) {
                deduped.put(Id.valueOf(rli.recordId), rli);
            }
        }

        // Strip milliseconds from start dates once, at the top. The Datetime field rounds
        // to whole seconds on round-trip, so containsKey() would always miss millisecond
        // precision and create duplicates on re-run.
        for (RelatedRecordsInput rli : deduped.values()) {
            if (rli.startDate != null) {
                Long timeMs = rli.startDate.getTime();
                Long timeNoMs = (timeMs / 1000) * 1000;
                rli.startDate = Datetime.newInstance(timeNoMs);
            }
        }

        // Build the field-list SELECT from schema to include all copyable fields: RecordTypeId,
        // all standard fields, and custom fields except per-period state (Payment_Status__c,
        // etc.). This picks up fields added later without source changes. Currency is handled
        // dynamically below.
        Set<String> fieldNames = new Set<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.TTS_Transaction__c.fields.getMap();
        // Compared as lower-case local names: fieldMap keys are lower-case and, in the packaged
        // org, carry the namespace prefix, so a raw key never matches a mixed-case API name.
        Set<String> neverCopy = new Set<String>{ 'id', 'transaction__c', 'ip_transaction_date_time__c',
            'ip_expected_payment_date__c', 'payment_status__c', 'reported_royalty_revenue__c',
            'royalty_report_start_date__c', 'royalty_report_end_date__c', 'ip_actual_amount__c',
            'ip_external_payment_reference__c', 'ip_internal_payment_reference__c' };
        for (String fname : fieldMap.keySet()) {
            Schema.DescribeFieldResult field = fieldMap.get(fname).getDescribe();
            if (field.isCreateable() && !neverCopy.contains(field.getLocalName().toLowerCase())) {
                fieldNames.add(fname);
            }
        }

        String parentQuery = 'SELECT ' + String.join(new List<String>(fieldNames), ', ');
        if (UserInfo.isMultiCurrencyOrganization()) {
            parentQuery += ', CurrencyIsoCode';
        }
        Set<Id> parentIds = deduped.keySet();
        parentQuery += ' FROM TTS_Transaction__c WHERE Id IN :parentIds WITH USER_MODE';
        Map<Id, TTS_Transaction__c> parentsById = new Map<Id, TTS_Transaction__c>(
            (List<TTS_Transaction__c>) Database.query(parentQuery)
        );

        // Existing children for every parent, keyed by date. We fetch Payment_Status__c,
        // IP_Actual_Amount__c and any contributor/recipient rows to decide whether a child
        // outside the new range should be protected (see isProtected).
        Map<Id, Map<Datetime, TTS_Transaction__c>> childrenByParentId = new Map<Id, Map<Datetime, TTS_Transaction__c>>();
        for (TTS_Transaction__c child : [
            SELECT Id, Transaction__c, IP_Transaction_Date_Time__c, Payment_Status__c, IP_Actual_Amount__c,
                (SELECT Id FROM Contributions__r LIMIT 1), (SELECT Id FROM Recipients__r LIMIT 1)
            FROM TTS_Transaction__c
            WHERE Transaction__c IN :deduped.keySet()
            WITH USER_MODE
        ]) {
            if (!childrenByParentId.containsKey(child.Transaction__c)) {
                childrenByParentId.put(child.Transaction__c, new Map<Datetime, TTS_Transaction__c>());
            }
            childrenByParentId.get(child.Transaction__c).put(child.IP_Transaction_Date_Time__c, child);
        }

        List<TTS_Transaction__c> allChildrenToDelete = new List<TTS_Transaction__c>();
        List<TTS_Transaction__c> allNewChildren = new List<TTS_Transaction__c>();

        for (Id parentId : deduped.keySet()) {
            RelatedRecordsInput rli = deduped.get(parentId);
            Datetime startDate = rli.startDate;
            Datetime endDate = rli.endDate;
            String frequency = rli.frequency;

            // Skip if start date is null or frequency is invalid
            if (startDate == null || frequency == null) {
                continue;
            }

            TTS_Transaction__c parentRecord = parentsById.get(parentId);
            if (parentRecord == null) {
                continue;
            }

            // Validate frequency; nextOccurrence is the single source of truth
            Datetime testNext = nextOccurrence(startDate, frequency);
            if (testNext.getTime() == startDate.getTime()) {
                // nextOccurrence returned unchanged, so frequency is invalid
                continue;
            }

            // Set the end date to 5 years from the start date if it's null
            if (endDate == null) {
                endDate = startDate.addYears(5);
            }

            Map<Datetime, TTS_Transaction__c> existingChildrenByDate = childrenByParentId.get(parentId);
            if (existingChildrenByDate == null) {
                existingChildrenByDate = new Map<Datetime, TTS_Transaction__c>();
                childrenByParentId.put(parentId, existingChildrenByDate);
            }

            // Calculate the new schedule
            Set<Datetime> newSchedule = new Set<Datetime>();
            Datetime currentDate = startDate;
            while (currentDate < endDate) {
                Datetime nextDate = nextOccurrence(currentDate, frequency);
                if (nextDate > endDate || nextDate.getTime() == currentDate.getTime()) {
                    break;
                }
                newSchedule.add(nextDate);
                currentDate = nextDate;
            }

            // Reconcile: delete existing children not in the new schedule, unless they are
            // protected (see isProtected).
            List<Datetime> datesOutOfSchedule = new List<Datetime>();
            for (Datetime childDate : existingChildrenByDate.keySet()) {
                if (!newSchedule.contains(childDate)) {
                    datesOutOfSchedule.add(childDate);
                }
            }
            for (Datetime childDate : datesOutOfSchedule) {
                TTS_Transaction__c child = existingChildrenByDate.remove(childDate);
                if (child.Id != null) {
                    if (!isProtected(child)) {
                        allChildrenToDelete.add(child);
                    }
                } else {
                    // Pending insert, not yet saved; remove from pending batch
                    Integer pendingIndex = allNewChildren.indexOf(child);
                    if (pendingIndex >= 0) {
                        allNewChildren.remove(pendingIndex);
                    }
                }
            }

            // Create new children for dates not already present
            for (Datetime recordDate : newSchedule) {
                if (!existingChildrenByDate.containsKey(recordDate)) {
                    TTS_Transaction__c newChild = parentRecord.clone(false, false);
                    newChild.Transaction__c = parentId;
                    newChild.IP_Transaction_Date_Time__c = recordDate;
                    newChild.IP_Expected_Payment_Date__c = recordDate;
                    newChild.Payment_Status__c = 'Scheduled';
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

    // A saved child may only be deleted while it is untouched: still Scheduled, no actual
    // amount recorded (IP_Actual_Amount__c defaults to 0, so 0 means "not yet recorded"),
    // and no contributor or recipient rows. Expects the child queried with both subqueries.
    private static Boolean isProtected(TTS_Transaction__c child) {
        return child.Payment_Status__c != 'Scheduled'
            || (child.IP_Actual_Amount__c != null && child.IP_Actual_Amount__c != 0)
            || !child.Contributions__r.isEmpty()
            || !child.Recipients__r.isEmpty();
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
                // Invalid frequency. Return a Datetime far in the future so the loop detects
                // it and skips this input. Do not return current unchanged; that would loop.
                return current.addYears(1000);
            }
        }
    }

    // TRANSACTION METHODS - END
}
