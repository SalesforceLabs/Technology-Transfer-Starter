@isTest
private class TTS_SObjectServiceTest {

    @testSetup
    static void setup() {
        // See TTS_TestSetup: the package build's test user lacks perm-set-delivered field
        // access, so grant it and create fixtures under runAs before touching the namespaced
        // custom fields.
        TTS_TestSetup.grantPackagePermissionSet();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            insert new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = Datetime.now(),
                Recurring__c = false,
                Agreed_Amount__c = 250.0
            );
        }
    }

    @isTest
    static void testCreateGetUpdateDeleteRoundTrip() {
        // Runs as a perm-set-only user so the full USER_MODE CRUD round-trip is exercised with
        // end-user field access rather than the running user's profile permissions.
        System.runAs(TTS_TestSetup.userWithPackagePermissionSet()) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();

            Test.startTest();
            SObject created = TTS_SObjectService.createRecord('TTS_Transaction__c', new Map<String, Object>{
                'RecordTypeId' => spaceFeeRecordTypeId,
                'Direction__c' => 'Outgoing',
                'Type__c' => 'Rent',
                'Agreed_Amount__c' => 500.0
            });
            Id createdId = created.Id;
            System.assertNotEquals(null, createdId, 'Record should have been created');

            SObject fetched = TTS_SObjectService.getRecord('TTS_Transaction__c', createdId, new List<String>{ 'Id', 'Agreed_Amount__c' });
            System.assertEquals(500.0, fetched.get('Agreed_Amount__c'), 'Fetched amount should match created value');

            TTS_SObjectService.updateRecord('TTS_Transaction__c', createdId, new Map<String, Object>{ 'Agreed_Amount__c' => 750.0 });
            SObject updated = TTS_SObjectService.getRecord('TTS_Transaction__c', createdId, new List<String>{ 'Agreed_Amount__c' });
            System.assertEquals(750.0, updated.get('Agreed_Amount__c'), 'Amount should reflect the update');

            TTS_SObjectService.deleteRecord('TTS_Transaction__c', createdId);
            Test.stopTest();

            System.assertEquals(0, [SELECT COUNT() FROM TTS_Transaction__c WHERE Id = :createdId], 'Record should have been deleted');
        }
    }

    @isTest
    static void testGetRecordsListsExistingRecords() {
        Test.startTest();
        List<SObject> records = TTS_SObjectService.getRecords('TTS_Transaction__c', new List<String>{ 'Id', 'Name' }, null);
        Test.stopTest();

        System.assert(!records.isEmpty(), 'Expected the fixture record inserted in @testSetup to be returned');
    }

    @isTest
    static void testDisallowedObjectIsRejected() {
        try {
            TTS_SObjectSelector.assertAllowed('Account');
            System.assert(false, 'Expected TTS_SObjectAccessException for a disallowed object');
        } catch (TTS_SObjectAccessException e) {
            System.assert(e.getMessage().contains('Account'), 'Exception should name the rejected object');
        }
    }

    @isTest
    static void testIdFromDifferentObjectIsRejected() {
        Id transactionId = [SELECT Id FROM TTS_Transaction__c LIMIT 1].Id;
        try {
            // TTS_Recipient__c is allow-listed, but the Id belongs to TTS_Transaction__c.
            TTS_SObjectService.deleteRecord('TTS_Recipient__c', transactionId);
            System.assert(false, 'Expected TTS_SObjectAccessException for a mismatched record Id');
        } catch (TTS_SObjectAccessException e) {
            System.assert(e.getMessage().contains('TTS_Recipient__c'), 'Exception should name the requested object');
        }
    }

    @isTest
    static void testUserWithoutPermissionSetCannotCreate() {
        String uniqueUsername = 'tts.norights.' + Datetime.now().getTime() + '@example.com';
        User restrictedUser = new User(
            FirstName = 'No',
            LastName = 'Rights',
            Email = 'tts.norights@example.com',
            Username = uniqueUsername,
            Alias = 'nrghts',
            CommunityNickname = 'norights',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert restrictedUser;

        Test.startTest();
        System.runAs(restrictedUser) {
            Boolean accessDenied = false;
            try {
                TTS_SObjectService.createRecord('TTS_Transaction__c', new Map<String, Object>{ 'Direction__c' => 'Incoming' });
            } catch (Exception e) {
                accessDenied = true;
            }
            System.assert(accessDenied, 'Expected record creation to be denied for a user with no permission set assigned');
        }
        Test.stopTest();
    }
}
