/**
 * Selector layer for the generic REST CRUD API: owns the allow-list of custom objects
 * this package exposes for dynamic access, and encapsulates every dynamic SOQL query so
 * no caller-controlled string reaches a query without being validated against Schema
 * describe first.
 *
 * Reference for this Selector/Service split: "Salesforce Apex Design Patterns"
 * (Chamil Madusanka) and "Salesforce Lightning Platform Enterprise Architecture", 3rd
 * ed. (Andy Fawcett). New CRUD-style Apex for this package's custom objects should
 * extend this class and TTS_SObjectService rather than adding ad-hoc SOQL/DML elsewhere.
 */
public with sharing class TTS_SObjectSelector {

    public static final Set<String> ALLOWED_OBJECTS = new Set<String>{
        'TTS_Agreement__c', 'TTS_Agreement_Deliverable__c', 'TTS_Agreement_Party__c',
        'TTS_Applicant__c', 'TTS_Contributor__c', 'TTS_Disclosure__c', 'TTS_Inventor__c',
        'TTS_Mentoring_Interest__c', 'TTS_Mentoring_Opportunity__c', 'TTS_Milestone__c',
        'TTS_Protection__c', 'TTS_Protection_Claim__c', 'TTS_Protection_Family__c',
        'TTS_Protection_Litigation__c', 'TTS_Recipient__c', 'TTS_Space__c',
        'TTS_Space_Asset__c', 'TTS_Space_Tenant__c', 'TTS_Space_Tenant_Contact__c',
        'TTS_Success_Plans__c', 'TTS_Technology__c', 'TTS_TrademarkIPAssociation__c',
        'TTS_Trademark_Classes__c', 'TTS_Transaction__c'
    };

    // In a namespaced org Schema.getGlobalDescribe() keys this package's objects by their
    // fully-qualified name (e.g. techstarter__TTS_Transaction__c), while callers and the
    // allow-list use the bare name. Derive the prefix from this class's own name rather
    // than hardcoding it, so the API works in the namespaced package context and in an
    // unmanaged/unnamespaced org alike.
    private static final String NAMESPACE_PREFIX = computeNamespacePrefix();

    private static String computeNamespacePrefix() {
        String className = TTS_SObjectSelector.class.getName();
        return className.contains('.') ? className.substringBefore('.') + '__' : '';
    }

    private static String stripNamespace(String objectApiName) {
        if (String.isNotBlank(NAMESPACE_PREFIX) && objectApiName != null
                && objectApiName.startsWithIgnoreCase(NAMESPACE_PREFIX)) {
            return objectApiName.substring(NAMESPACE_PREFIX.length());
        }
        return objectApiName;
    }

    // Resolves an object name (bare or namespaced) to its SObjectType, tolerating either
    // form of getGlobalDescribe() key. Returns null if the object does not exist.
    public static Schema.SObjectType resolveType(String objectApiName) {
        if (objectApiName == null) {
            return null;
        }
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        if (globalDescribe.containsKey(objectApiName)) {
            return globalDescribe.get(objectApiName);
        }
        if (String.isNotBlank(NAMESPACE_PREFIX)) {
            String qualified = NAMESPACE_PREFIX + stripNamespace(objectApiName);
            if (globalDescribe.containsKey(qualified)) {
                return globalDescribe.get(qualified);
            }
        }
        return null;
    }

    public static void assertAllowed(String objectApiName) {
        if (objectApiName == null || !ALLOWED_OBJECTS.contains(stripNamespace(objectApiName))) {
            throw new TTS_SObjectAccessException('Object is not available through this API: ' + objectApiName);
        }
    }

    // Guards against a caller-supplied record Id that resolves to a different sObject
    // type than the one requested in the path — Database.update/delete-by-Id operate on
    // whatever the Id actually points to, so this check has to run before either.
    public static void assertIdMatchesObject(String objectApiName, Id recordId) {
        Schema.DescribeSObjectResult expected = describeObject(objectApiName);
        if (recordId == null
                || recordId.getSObjectType().getDescribe().getName() != expected.getName()) {
            throw new TTS_SObjectAccessException('Record Id does not belong to object: ' + objectApiName);
        }
    }

    public static Schema.DescribeSObjectResult describeObject(String objectApiName) {
        assertAllowed(objectApiName);
        Schema.SObjectType sObjType = resolveType(objectApiName);
        if (sObjType == null) {
            throw new TTS_SObjectAccessException('Unknown object: ' + objectApiName);
        }
        return sObjType.getDescribe();
    }

    // Returns a blank record of the requested type, validated against the allow-list.
    public static SObject newSObject(String objectApiName) {
        return describeObject(objectApiName).getSObjectType().newSObject();
    }

    public static List<String> assertAccessibleFields(String objectApiName, List<String> fieldNames) {
        Map<String, Schema.SObjectField> fieldsByName = describeObject(objectApiName).fields.getMap();
        List<String> validated = new List<String>();
        for (String fieldName : fieldNames) {
            // Standard fields (Id, Name, ...) are keyed bare; this package's own custom
            // fields are keyed by their namespaced name in a managed context, so fall back
            // to the qualified form before rejecting the field.
            Schema.SObjectField field = fieldsByName.get(fieldName);
            if (field == null && String.isNotBlank(NAMESPACE_PREFIX)) {
                field = fieldsByName.get(NAMESPACE_PREFIX + stripNamespace(fieldName));
            }
            if (field == null) {
                throw new TTS_SObjectAccessException('Unknown field on ' + objectApiName + ': ' + fieldName);
            }
            validated.add(field.getDescribe().getName());
        }
        return validated;
    }

    public static SObject selectById(String objectApiName, Id recordId, List<String> fieldNames) {
        String objectName = describeObject(objectApiName).getName();
        List<String> fields = assertAccessibleFields(objectApiName, fieldNames);
        String soql = 'SELECT ' + String.join(fields, ', ') + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';
        List<SObject> results = Database.query(soql, AccessLevel.USER_MODE);
        return results.isEmpty() ? null : results[0];
    }

    public static List<SObject> selectAll(String objectApiName, List<String> fieldNames, Integer limitCount) {
        String objectName = describeObject(objectApiName).getName();
        List<String> fields = assertAccessibleFields(objectApiName, fieldNames);
        Integer safeLimit = (limitCount == null || limitCount <= 0 || limitCount > 200) ? 200 : limitCount;
        String soql = 'SELECT ' + String.join(fields, ', ') + ' FROM ' + objectName + ' LIMIT ' + safeLimit;
        return Database.query(soql, AccessLevel.USER_MODE);
    }
}
