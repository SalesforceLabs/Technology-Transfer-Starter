/**
 * Service layer for the generic REST CRUD API — the single entry point for create/read/
 * update/delete against the allow-listed custom objects owned by TTS_SObjectSelector.
 * Callers (currently TTS_ObjectRestResource) never touch SOQL/DML directly.
 *
 * Object-name resolution (bare vs. namespaced) is delegated to TTS_SObjectSelector, which
 * tolerates either form against Schema.getGlobalDescribe().
 *
 * Reference: "Salesforce Apex Design Patterns" (Chamil Madusanka) and "Salesforce
 * Lightning Platform Enterprise Architecture", 3rd ed. (Andy Fawcett).
 */
public with sharing class TTS_SObjectService {

    public static SObject getRecord(String objectApiName, Id recordId, List<String> fieldNames) {
        SObject record = TTS_SObjectSelector.selectById(objectApiName, recordId, fieldNames);
        if (record == null) {
            throw new TTS_SObjectAccessException('Record not found: ' + recordId);
        }
        return record;
    }

    public static List<SObject> getRecords(String objectApiName, List<String> fieldNames, Integer limitCount) {
        return TTS_SObjectSelector.selectAll(objectApiName, fieldNames, limitCount);
    }

    public static SObject createRecord(String objectApiName, Map<String, Object> fieldValues) {
        SObject record = newSObject(objectApiName, fieldValues);
        Database.insert(record, AccessLevel.USER_MODE);
        return record;
    }

    public static SObject updateRecord(String objectApiName, Id recordId, Map<String, Object> fieldValues) {
        TTS_SObjectSelector.assertIdMatchesObject(objectApiName, recordId);
        SObject record = newSObject(objectApiName, fieldValues);
        record.Id = recordId;
        Database.update(record, AccessLevel.USER_MODE);
        return record;
    }

    public static void deleteRecord(String objectApiName, Id recordId) {
        TTS_SObjectSelector.assertIdMatchesObject(objectApiName, recordId);
        Database.delete(recordId, AccessLevel.USER_MODE);
    }

    private static SObject newSObject(String objectApiName, Map<String, Object> fieldValues) {
        List<String> fieldNames = new List<String>(fieldValues.keySet());
        TTS_SObjectSelector.assertAccessibleFields(objectApiName, fieldNames);
        SObject record = TTS_SObjectSelector.newSObject(objectApiName);
        for (String fieldName : fieldNames) {
            record.put(fieldName, fieldValues.get(fieldName));
        }
        return record;
    }
}
