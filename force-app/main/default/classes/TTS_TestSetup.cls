/**
 * Shared test setup helpers. Exists so every test class provisions field-level security the
 * same way: the package version build runs Apex tests as a user that has this package's
 * objects and record types but not its permission-set-delivered field access, so fixture DML
 * on the namespaced custom fields must be preceded by a perm-set assignment for the running
 * user. Kept @isTest so it is excluded from the package's Apex coverage denominator.
 */
@isTest
public class TTS_TestSetup {

    // Grants the current user this package's permission set if not already assigned. Guarded
    // so it is idempotent in orgs where the running user already holds it (e.g. a configured
    // dev scratch org), which would otherwise fail on a duplicate PermissionSetAssignment.
    public static void grantPackagePermissionSet() {
        Integer alreadyAssigned = [
            SELECT COUNT()
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId()
            AND PermissionSet.Name = 'Technology_Transfer_Starter_Permission'
        ];
        if (alreadyAssigned == 0) {
            insert new PermissionSetAssignment(
                AssigneeId = UserInfo.getUserId(),
                PermissionSetId = [
                    SELECT Id FROM PermissionSet
                    WHERE Name = 'Technology_Transfer_Starter_Permission'
                    LIMIT 1
                ].Id
            );
        }
    }

    // Creates a standard-profile user holding only this package's permission set, for tests
    // that must exercise USER_MODE DML the way an integration/end user would. Assigning the
    // perm set to the currently-running user does not retroactively grant that user's own test
    // method field access, so those tests must run under runAs(this user) instead. The perm set
    // supplies field access and record-type visibility; TTS_Transaction__c is Public Read/Write
    // so @testSetup fixtures remain visible to this user.
    public static User userWithPackagePermissionSet() {
        Long salt = Datetime.now().getTime() + Math.roundToLong(Math.random() * 1000000);
        User u = new User(
            FirstName = 'TTS',
            LastName = 'TestRunner',
            Email = 'tts.testrunner@example.com',
            Username = 'tts.testrunner.' + salt + '@example.com',
            Alias = 'ttstr',
            CommunityNickname = 'ttstr' + salt,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        insert new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = [
                SELECT Id FROM PermissionSet
                WHERE Name = 'Technology_Transfer_Starter_Permission'
                LIMIT 1
            ].Id
        );
        return u;
    }
}
