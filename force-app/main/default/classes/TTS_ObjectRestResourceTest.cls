@isTest
private class TTS_ObjectRestResourceTest {

    @testSetup
    static void setup() {
        // The package version build runs these tests as a user without this package's
        // permission set, so field-level security on the namespaced custom fields has to be
        // granted before any DML. Assigning the perm set to the running user (guarded to stay
        // idempotent) and creating fixtures under runAs preserves field access and record-type
        // visibility while sidestepping a setup/non-setup mixed-DML error.
        TTS_TestSetup.grantPackagePermissionSet();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            insert new TTS_Transaction__c(
                RecordTypeId = spaceFeeRecordTypeId,
                Direction__c = 'Incoming',
                Type__c = 'Rent',
                Start_Date_Time__c = Datetime.now(),
                Recurring__c = false,
                Agreed_Amount__c = 100.0
            );
        }
    }

    private static RestRequest buildRequest(String method, String path, String body) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/v1/' + path;
        req.httpMethod = method;
        if (body != null) {
            req.requestBody = Blob.valueOf(body);
        }
        RestContext.request = req;
        RestContext.response = new RestResponse();
        return req;
    }

    @isTest
    static void testGetList() {
        buildRequest('GET', 'TTS_Transaction__c', null);
        Test.startTest();
        TTS_ObjectRestResource.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode, 'List GET should succeed');
    }

    @isTest
    static void testGetById() {
        Id recordId = [SELECT Id FROM TTS_Transaction__c LIMIT 1].Id;
        buildRequest('GET', 'TTS_Transaction__c/' + recordId, null);
        Test.startTest();
        TTS_ObjectRestResource.doGet();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode, 'Get-by-Id should succeed');
    }

    @isTest
    static void testPostCreate() {
        // Runs as a perm-set-only user so the create path exercises USER_MODE DML the way an
        // end user would (the package build's own test user lacks profile-level field access).
        System.runAs(TTS_TestSetup.userWithPackagePermissionSet()) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            String body = JSON.serialize(new Map<String, Object>{
                'RecordTypeId' => spaceFeeRecordTypeId,
                'Direction__c' => 'Outgoing',
                'Type__c' => 'Rent',
                'Agreed_Amount__c' => 200.0
            });
            buildRequest('POST', 'TTS_Transaction__c', body);
            Test.startTest();
            TTS_ObjectRestResource.doPost();
            Test.stopTest();
            System.assertEquals(201, RestContext.response.statusCode, 'Create should return 201');
        }
    }

    @isTest
    static void testPatchUpdate() {
        // Runs as a perm-set-only user, and creates its own record rather than sharing the
        // @testSetup fixture, so a concurrent testDelete can't lock-contend with this update
        // under parallel test execution (which surfaced as an intermittent HTTP 500).
        System.runAs(TTS_TestSetup.userWithPackagePermissionSet()) {
            Id spaceFeeRecordTypeId = Schema.SObjectType.TTS_Transaction__c.getRecordTypeInfosByDeveloperName().get('Space_Fee').getRecordTypeId();
            SObject own = TTS_SObjectService.createRecord('TTS_Transaction__c', new Map<String, Object>{
                'RecordTypeId' => spaceFeeRecordTypeId,
                'Direction__c' => 'Incoming',
                'Type__c' => 'Rent',
                'Agreed_Amount__c' => 100.0
            });
            String body = JSON.serialize(new Map<String, Object>{ 'Agreed_Amount__c' => 999.0 });
            buildRequest('PATCH', 'TTS_Transaction__c/' + own.Id, body);
            Test.startTest();
            TTS_ObjectRestResource.doPatch();
            Test.stopTest();
            System.assertEquals(200, RestContext.response.statusCode, 'Update should return 200');
        }
    }

    @isTest
    static void testDelete() {
        Id recordId = [SELECT Id FROM TTS_Transaction__c LIMIT 1].Id;
        buildRequest('DELETE', 'TTS_Transaction__c/' + recordId, null);
        Test.startTest();
        TTS_ObjectRestResource.doDelete();
        Test.stopTest();
        System.assertEquals(204, RestContext.response.statusCode, 'Delete should return 204');
    }

    @isTest
    static void testDisallowedObjectReturns400() {
        buildRequest('GET', 'Account', null);
        Test.startTest();
        TTS_ObjectRestResource.doGet();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode, 'Disallowed object should return 400, not an unhandled exception');
    }
}
