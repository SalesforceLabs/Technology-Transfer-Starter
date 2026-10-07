@isTest
private class TTSCoreTest {

    // Fixed base instant so the recurring-schedule occurrence count is deterministic. Using
    // Datetime.now() made the generated count drift by +/-1 depending on the run date (leap
    // days, month lengths, week boundaries), which failed intermittently in the package build.
    private static final Datetime BASE = Datetime.newInstance(2025, 1, 1, 0, 0, 0);

    @testSetup
    static void setup() {
        // Insert necessary records for the test. See TTS_TestSetup: grant the running user
        // this package's field access, then create fixtures under runAs (preserves record-type
        // visibility and avoids a setup/non-setup mixed-DML error in the package build).
        TTS_TestSetup.grantPackagePermissionSet();
        System.runAs(new User(Id = UserInfo.getUserId())) {
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
            IP_Transaction_Date_Time__c = BASE.addDays(1),
            IP_Expected_Payment_Date__c = BASE.addDays(1),
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
    }

    @isTest
    static void testGenerateRecurringTransactionRecords() {
        User testUser = TTS_TestSetup.userWithPackagePermissionSet();
        System.runAs(testUser) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            TTS_Transaction__c freshParent = new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = BASE,
                Recurring__c = true,
                End_Date_Time__c = BASE.addYears(2),
                Recurrence_Frequency__c = 'Monthly',
                Agreed_Amount__c = 100.0
            );
            insert freshParent;

            List<TTSCore.RelatedRecordsInput> inputs = new List<TTSCore.RelatedRecordsInput>();

            TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
            input.startDate = BASE;
            input.endDate = BASE.addYears(2);
            input.frequency = 'Monthly';
            input.recordId = freshParent.Id;
            inputs.add(input);

            TTSCore.RelatedRecordsInput inputDaily = new TTSCore.RelatedRecordsInput();
            inputDaily.startDate = BASE;
            inputDaily.endDate = BASE.addYears(1);
            inputDaily.frequency = 'Daily';
            inputDaily.recordId = freshParent.Id;
            inputs.add(inputDaily);

            TTSCore.RelatedRecordsInput inputWeekly = new TTSCore.RelatedRecordsInput();
            inputWeekly.startDate = BASE;
            inputWeekly.endDate = BASE.addYears(2);
            inputWeekly.frequency = 'Weekly';
            inputWeekly.recordId = freshParent.Id;
            inputs.add(inputWeekly);

            TTSCore.RelatedRecordsInput inputQuarterly = new TTSCore.RelatedRecordsInput();
            inputQuarterly.startDate = BASE;
            inputQuarterly.endDate = BASE.addYears(2);
            inputQuarterly.frequency = 'Quarterly';
            inputQuarterly.recordId = freshParent.Id;
            inputs.add(inputQuarterly);

            TTSCore.RelatedRecordsInput inputAnnually = new TTSCore.RelatedRecordsInput();
            inputAnnually.startDate = BASE;
            inputAnnually.endDate = BASE.addYears(2);
            inputAnnually.frequency = 'Annually';
            inputAnnually.recordId = freshParent.Id;
            inputs.add(inputAnnually);

            Test.startTest();
            TTSCore.generateRecurringTransactionRecords(inputs);
            Test.stopTest();

            // With dedup, only the last input per parent is processed. Annual schedule over 2 years.
            // Expected count is the number of Annual occurrences: from BASE to BASE+2years is 2.
            Integer expectedCount = 2;
            Integer actualCount = [SELECT COUNT() FROM TTS_Transaction__c WHERE Transaction__c = :freshParent.Id];
            System.assertEquals(expectedCount, actualCount, 'Unexpected number of child records');
        }
    }

    @isTest
    static void shouldNotCreateOccurrenceAfterEndDateWhenEndFallsBetweenWeeklyOccurrences() {
        User testUser = TTS_TestSetup.userWithPackagePermissionSet();
        System.runAs(testUser) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            TTS_Transaction__c freshParent = new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = BASE,
                Recurring__c = true,
                End_Date_Time__c = BASE.addYears(1),
                Recurrence_Frequency__c = 'Weekly',
                Agreed_Amount__c = 100.0
            );
            insert freshParent;

            Datetime endDate = BASE.addDays(20);
            TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
            input.startDate = BASE;
            input.endDate = endDate;
            input.frequency = 'Weekly';
            input.recordId = freshParent.Id;

            Test.startTest();
            TTSCore.generateRecurringTransactionRecords(
                new List<TTSCore.RelatedRecordsInput>{ input }
            );
            Test.stopTest();

            Integer occurrencesAfterEndDate = [
                SELECT COUNT()
                FROM TTS_Transaction__c
                WHERE Transaction__c = :freshParent.Id
                AND IP_Transaction_Date_Time__c > :endDate
            ];
            Assert.areEqual(
                0,
                occurrencesAfterEndDate,
                'A recurring transaction must not be created after the schedule end date'
            );
        }
    }

    @isTest
    static void millisecondPrecisionDoesNotDuplicateOnRerun() {
        User testUser = TTS_TestSetup.userWithPackagePermissionSet();
        System.runAs(testUser) {
            // Create a fresh parent to avoid interference from the setup fixture
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            TTS_Transaction__c freshParent = new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = BASE,
                Recurring__c = true,
                End_Date_Time__c = BASE.addYears(1),
                Recurrence_Frequency__c = 'Monthly',
                Agreed_Amount__c = 100.0
            );
            insert freshParent;

            Long timeWithMs = BASE.getTime() + 255;
            Datetime startWithMs = Datetime.newInstance(timeWithMs);
            Datetime endDate = BASE.addMonths(3);

            TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
            input.startDate = startWithMs;
            input.endDate = endDate;
            input.frequency = 'Monthly';
            input.recordId = freshParent.Id;

            Test.startTest();
            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ input });
            Test.stopTest();

            Integer countAfterFirstRun = [SELECT COUNT() FROM TTS_Transaction__c WHERE Transaction__c = :freshParent.Id];

            // Re-run with same dates; count must not change
            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ input });
            Integer countAfterSecondRun = [SELECT COUNT() FROM TTS_Transaction__c WHERE Transaction__c = :freshParent.Id];

            Assert.areEqual(countAfterFirstRun, countAfterSecondRun, 'Milliseconds must not cause duplicates on re-run');
        }
    }

    @isTest
    static void frequencyChangeReconciles() {
        User testUser = TTS_TestSetup.userWithPackagePermissionSet();
        System.runAs(testUser) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            TTS_Transaction__c freshParent = new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = BASE,
                Recurring__c = true,
                End_Date_Time__c = BASE.addYears(1),
                Recurrence_Frequency__c = 'Monthly',
                Agreed_Amount__c = 100.0
            );
            insert freshParent;

            Datetime endDate = BASE.addDays(45);

            TTSCore.RelatedRecordsInput inputMonthly = new TTSCore.RelatedRecordsInput();
            inputMonthly.startDate = BASE;
            inputMonthly.endDate = endDate;
            inputMonthly.frequency = 'Monthly';
            inputMonthly.recordId = freshParent.Id;

            Test.startTest();
            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ inputMonthly });
            Test.stopTest();

            Integer countMonthly = [SELECT COUNT() FROM TTS_Transaction__c WHERE Transaction__c = :freshParent.Id];
            Assert.isTrue(countMonthly > 0, 'Monthly schedule should generate children');

            // Switch to Weekly with same date range; stale Monthly children must be deleted
            TTSCore.RelatedRecordsInput inputWeekly = new TTSCore.RelatedRecordsInput();
            inputWeekly.startDate = BASE;
            inputWeekly.endDate = endDate;
            inputWeekly.frequency = 'Weekly';
            inputWeekly.recordId = freshParent.Id;

            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ inputWeekly });

            // Weekly should have more occurrences than Monthly; old Monthly-only dates should be gone
            Integer countWeekly = [SELECT COUNT() FROM TTS_Transaction__c WHERE Transaction__c = :freshParent.Id];
            Assert.isTrue(countWeekly > countMonthly, 'Weekly should have more occurrences than Monthly over same range');
        }
    }

    @isTest
    static void childrenInheritRecordTypeAndRoyaltyFields() {
        User testUser = TTS_TestSetup.userWithPackagePermissionSet();
        System.runAs(testUser) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            TTS_Transaction__c freshParent = new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = BASE,
                Recurring__c = true,
                End_Date_Time__c = BASE.addYears(1),
                Recurrence_Frequency__c = 'Monthly',
                Agreed_Amount__c = 100.0
            );
            insert freshParent;

            TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
            input.startDate = BASE;
            input.endDate = BASE.addMonths(1);
            input.frequency = 'Monthly';
            input.recordId = freshParent.Id;

            Test.startTest();
            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ input });
            Test.stopTest();

            List<TTS_Transaction__c> children = [
                SELECT RecordTypeId, Applied_Royalty_Rate__c, Royalty_Term__c, Payment_Status__c
                FROM TTS_Transaction__c
                WHERE Transaction__c = :freshParent.Id
            ];
            Assert.isFalse(children.isEmpty(), 'Should generate children');
            for (TTS_Transaction__c child : children) {
                Assert.areEqual(spaceFeeRecordTypeId, child.RecordTypeId, 'Child must inherit parent RecordTypeId');
                Assert.areEqual('Scheduled', child.Payment_Status__c, 'Child Payment_Status__c must be Scheduled');
            }
        }
    }

    @isTest
    static void neverCopyFieldsAreBlankOnChildren() {
        User testUser = TTS_TestSetup.userWithPackagePermissionSet();
        System.runAs(testUser) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            // Parent carries per-period values (rate x revenue = actual, so the royalty match
            // rule passes). None of them may be copied onto future scheduled children.
            TTS_Transaction__c freshParent = new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = BASE,
                Recurring__c = true,
                End_Date_Time__c = BASE.addYears(1),
                Recurrence_Frequency__c = 'Monthly',
                Agreed_Amount__c = 100.0,
                Applied_Royalty_Rate__c = 10,
                Reported_Royalty_Revenue__c = 1000.0,
                IP_Actual_Amount__c = 100.0,
                IP_External_Payment_Reference__c = 'EXT-1',
                IP_Internal_Payment_Reference__c = 'INT-1',
                Royalty_Report_Start_Date__c = BASE.date(),
                Royalty_Report_End_Date__c = BASE.date().addMonths(1)
            );
            insert freshParent;

            TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
            input.startDate = BASE;
            input.endDate = BASE.addMonths(3);
            input.frequency = 'Monthly';
            input.recordId = freshParent.Id;

            Test.startTest();
            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ input });
            Test.stopTest();

            List<TTS_Transaction__c> children = [
                SELECT Agreed_Amount__c, Applied_Royalty_Rate__c, Reported_Royalty_Revenue__c,
                    IP_Actual_Amount__c, IP_External_Payment_Reference__c, IP_Internal_Payment_Reference__c,
                    Royalty_Report_Start_Date__c, Royalty_Report_End_Date__c
                FROM TTS_Transaction__c
                WHERE Transaction__c = :freshParent.Id
            ];
            Assert.areEqual(3, children.size(), 'Should generate one child per month');
            for (TTS_Transaction__c child : children) {
                Assert.areEqual(100.0, child.Agreed_Amount__c, 'Agreed amount must be copied');
                Assert.areEqual(10.0, child.Applied_Royalty_Rate__c, 'Applied royalty rate must be copied');
                // Not copied from the parent; the field's own default (0) may apply on insert.
                Assert.isTrue(child.IP_Actual_Amount__c == null || child.IP_Actual_Amount__c == 0,
                    'Actual amount must not be copied');
                Assert.isNull(child.Reported_Royalty_Revenue__c, 'Reported revenue must not be copied');
                Assert.isNull(child.IP_External_Payment_Reference__c, 'External payment reference must not be copied');
                Assert.isNull(child.IP_Internal_Payment_Reference__c, 'Internal payment reference must not be copied');
                Assert.isNull(child.Royalty_Report_Start_Date__c, 'Report start date must not be copied');
                Assert.isNull(child.Royalty_Report_End_Date__c, 'Report end date must not be copied');
            }
        }
    }

    @isTest
    static void shorteningScheduleDeletesUnprotectedChildren() {
        User testUser = TTS_TestSetup.userWithPackagePermissionSet();
        System.runAs(testUser) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            // Actual amount on the parent must not make every generated child "protected".
            TTS_Transaction__c freshParent = new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = BASE,
                Recurring__c = true,
                End_Date_Time__c = BASE.addYears(1),
                Recurrence_Frequency__c = 'Monthly',
                Agreed_Amount__c = 100.0,
                IP_Actual_Amount__c = 100.0
            );
            insert freshParent;

            TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
            input.startDate = BASE;
            input.endDate = BASE.addMonths(12);
            input.frequency = 'Monthly';
            input.recordId = freshParent.Id;
            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ input });
            Assert.areEqual(12, [SELECT COUNT() FROM TTS_Transaction__c WHERE Transaction__c = :freshParent.Id],
                'Should generate one child per month for a year');

            input.endDate = BASE.addMonths(3);

            Test.startTest();
            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ input });
            Test.stopTest();

            Assert.areEqual(3, [SELECT COUNT() FROM TTS_Transaction__c WHERE Transaction__c = :freshParent.Id],
                'Unpaid children outside the shortened schedule must be deleted');
        }
    }

    @isTest
    static void touchedChildrenSurviveRangeChange() {
        User testUser = TTS_TestSetup.userWithPackagePermissionSet();
        System.runAs(testUser) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            TTS_Transaction__c freshParent = new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = BASE,
                Recurring__c = true,
                End_Date_Time__c = BASE.addYears(1),
                Recurrence_Frequency__c = 'Monthly',
                Agreed_Amount__c = 100.0
            );
            insert freshParent;

            TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
            input.startDate = BASE;
            input.endDate = BASE.addMonths(6);
            input.frequency = 'Monthly';
            input.recordId = freshParent.Id;
            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ input });

            List<TTS_Transaction__c> children = [
                SELECT Id FROM TTS_Transaction__c
                WHERE Transaction__c = :freshParent.Id
                ORDER BY IP_Transaction_Date_Time__c
            ];
            Assert.areEqual(6, children.size(), 'Should generate one child per month');

            // Touch two children: one no longer Scheduled, one with a contributor row.
            TTS_Transaction__c overdueChild = children[0];
            overdueChild.Payment_Status__c = 'Overdue';
            update overdueChild;
            TTS_Transaction__c splitChild = children[1];
            insert new TTS_Contributor__c(IP_Related_Transaction__c = splitChild.Id);

            // Narrow the range so no occurrence remains in the schedule
            input.endDate = BASE.addDays(15);

            Test.startTest();
            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ input });
            Test.stopTest();

            Map<Id, TTS_Transaction__c> remaining = new Map<Id, TTS_Transaction__c>([
                SELECT Id FROM TTS_Transaction__c WHERE Transaction__c = :freshParent.Id
            ]);
            Assert.areEqual(2, remaining.size(), 'Only the untouched Scheduled children may be deleted');
            Assert.isTrue(remaining.containsKey(overdueChild.Id), 'A child that is no longer Scheduled must not be deleted');
            Assert.isTrue(remaining.containsKey(splitChild.Id), 'A child with contributor rows must not be deleted');
        }
    }

    @isTest
    static void paidChildSurvivesRangeChange() {
        User testUser = TTS_TestSetup.userWithPackagePermissionSet();
        System.runAs(testUser) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            TTS_Transaction__c freshParent = new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = BASE,
                Recurring__c = true,
                End_Date_Time__c = BASE.addYears(1),
                Recurrence_Frequency__c = 'Monthly',
                Agreed_Amount__c = 100.0
            );
            insert freshParent;

            // Create initial schedule
            TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
            input.startDate = BASE;
            input.endDate = BASE.addMonths(6);
            input.frequency = 'Monthly';
            input.recordId = freshParent.Id;

            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ input });

            // Mark a child as protected by recording an actual amount
            TTS_Transaction__c protectedChild = [
                SELECT Id FROM TTS_Transaction__c
                WHERE Transaction__c = :freshParent.Id
                ORDER BY IP_Transaction_Date_Time__c
                LIMIT 1
            ];
            protectedChild.IP_Actual_Amount__c = 50.0;
            update protectedChild;

            // Narrow the range to exclude that child
            input.endDate = BASE.addDays(15);

            Test.startTest();
            TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ input });
            Test.stopTest();

            TTS_Transaction__c stillExists = [SELECT Id, IP_Actual_Amount__c FROM TTS_Transaction__c WHERE Id = :protectedChild.Id];
            Assert.areEqual(50.0, stillExists.IP_Actual_Amount__c, 'Protected child must not be deleted');
        }
    }

    @isTest
    static void blankStartDateSkipsInput() {
        User testUser = TTS_TestSetup.userWithPackagePermissionSet();
        System.runAs(testUser) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            TTS_Transaction__c freshParent = new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = BASE,
                Recurring__c = true,
                End_Date_Time__c = BASE.addYears(1),
                Recurrence_Frequency__c = 'Monthly',
                Agreed_Amount__c = 100.0
            );
            insert freshParent;

            TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
            input.startDate = null; // No start date
            input.endDate = BASE.addMonths(1);
            input.frequency = 'Monthly';
            input.recordId = freshParent.Id;

            Test.startTest();
            try {
                TTSCore.generateRecurringTransactionRecords(new List<TTSCore.RelatedRecordsInput>{ input });
                Assert.isTrue(true, 'Null startDate should not throw');
            } catch (Exception e) {
                Assert.fail('Null startDate must be skipped gracefully, but threw: ' + e.getMessage());
            }
            Test.stopTest();

            Integer count = [SELECT COUNT() FROM TTS_Transaction__c WHERE Transaction__c = :freshParent.Id];
            Assert.areEqual(0, count, 'Null startDate input should generate no children');
        }
    }

    @isTest
    static void generatedChildrenInheritParentCurrency() {
        // CurrencyIsoCode only exists in multi-currency orgs; nothing to assert otherwise.
        if (!UserInfo.isMultiCurrencyOrganization()) {
            return;
        }
        // Prefer a non-corporate active currency so a broken clone (child defaulting to the
        // running user's currency) is actually distinguishable. In an org with only the
        // corporate currency activated this falls back to it and the assert still holds.
        // CurrencyType is absent at compile time in single-currency orgs, so query it
        // dynamically — this line only executes in a multi-currency org (guarded above).
        List<SObject> others = Database.query(
            'SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsCorporate = false LIMIT 1'
        );
        String targetCurrency = others.isEmpty()
            ? (String) Database.query(
                  'SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true LIMIT 1'
              )[0].get('IsoCode')
            : (String) others[0].get('IsoCode');

        User testUser = TTS_TestSetup.userWithPackagePermissionSet();
        System.runAs(testUser) {
            Id parentId = [
                SELECT Id FROM TTS_Transaction__c WHERE Transaction__c = null LIMIT 1
            ].Id;
            // CurrencyIsoCode is absent at compile time in single-currency orgs, so set it
            // dynamically rather than with a static field reference.
            SObject parent = Database.query(
                'SELECT Id FROM TTS_Transaction__c WHERE Id = :parentId'
            );
            parent.put('CurrencyIsoCode', targetCurrency);
            update parent;

            TTSCore.RelatedRecordsInput input = new TTSCore.RelatedRecordsInput();
            input.startDate = BASE;
            input.endDate = BASE.addMonths(3);
            input.frequency = 'Monthly';
            input.recordId = parentId;

            Test.startTest();
            TTSCore.generateRecurringTransactionRecords(
                new List<TTSCore.RelatedRecordsInput>{ input }
            );
            Test.stopTest();

            Datetime firstOccurrence = BASE.addMonths(1);
            List<SObject> generated = Database.query(
                'SELECT CurrencyIsoCode FROM TTS_Transaction__c ' +
                'WHERE Transaction__c = :parentId AND IP_Transaction_Date_Time__c = :firstOccurrence'
            );
            Assert.isFalse(generated.isEmpty(), 'Expected a generated recurring occurrence');
            Assert.areEqual(
                targetCurrency,
                (String) generated[0].get('CurrencyIsoCode'),
                'Generated recurring transaction must inherit the parent currency'
            );
        }
    }

}
