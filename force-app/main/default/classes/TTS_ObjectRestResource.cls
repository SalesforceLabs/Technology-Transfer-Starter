/**
 * Generic REST CRUD endpoint over the custom objects exposed by TTS_SObjectSelector's
 * allow-list. Ships inside this managed package (namespace `techstarter`), so the
 * exposed subscriber-org path is /services/apexrest/techstarter/v1/{ObjectApiName}[/{Id}]
 * — the namespace is prepended automatically to the mapping below; do not hardcode it.
 *
 * This class only parses the request and formats the response — all query/DML logic
 * lives in TTS_SObjectService / TTS_SObjectSelector. New CRUD-style Apex should extend
 * those two classes rather than adding logic here or growing TTSCore.cls.
 */
@RestResource(urlMapping='/v1/*')
global with sharing class TTS_ObjectRestResource {

    @HttpGet
    global static void doGet() {
        try {
            RestRequest req = RestContext.request;
            List<String> pathParts = parsePath(req);
            String objectApiName = pathParts[0];
            List<String> fields = parseFields(req);

            if (pathParts.size() > 1) {
                SObject record = TTS_SObjectService.getRecord(objectApiName, pathParts[1], fields);
                writeResponse(200, JSON.serialize(record));
            } else {
                List<SObject> records = TTS_SObjectService.getRecords(objectApiName, fields, parseLimit(req));
                writeResponse(200, JSON.serialize(records));
            }
        } catch (TTS_SObjectAccessException e) {
            writeError(400, e.getMessage());
        } catch (Exception e) {
            writeError(500, 'Unexpected error: ' + e.getMessage());
        }
    }

    @HttpPost
    global static void doPost() {
        try {
            RestRequest req = RestContext.request;
            String objectApiName = parsePath(req)[0];
            Map<String, Object> fieldValues = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            SObject record = TTS_SObjectService.createRecord(objectApiName, fieldValues);
            writeResponse(201, JSON.serialize(record));
        } catch (TTS_SObjectAccessException e) {
            writeError(400, e.getMessage());
        } catch (Exception e) {
            writeError(500, 'Unexpected error: ' + e.getMessage());
        }
    }

    @HttpPatch
    global static void doPatch() {
        try {
            RestRequest req = RestContext.request;
            List<String> pathParts = parsePath(req);
            if (pathParts.size() < 2) {
                writeError(400, 'A record Id is required in the path for updates.');
                return;
            }
            Map<String, Object> fieldValues = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            SObject record = TTS_SObjectService.updateRecord(pathParts[0], pathParts[1], fieldValues);
            writeResponse(200, JSON.serialize(record));
        } catch (TTS_SObjectAccessException e) {
            writeError(400, e.getMessage());
        } catch (Exception e) {
            writeError(500, 'Unexpected error: ' + e.getMessage());
        }
    }

    @HttpDelete
    global static void doDelete() {
        try {
            RestRequest req = RestContext.request;
            List<String> pathParts = parsePath(req);
            if (pathParts.size() < 2) {
                writeError(400, 'A record Id is required in the path for deletes.');
                return;
            }
            TTS_SObjectService.deleteRecord(pathParts[0], pathParts[1]);
            writeResponse(204, null);
        } catch (TTS_SObjectAccessException e) {
            writeError(400, e.getMessage());
        } catch (Exception e) {
            writeError(500, 'Unexpected error: ' + e.getMessage());
        }
    }

    private static List<String> parsePath(RestRequest req) {
        String uri = req.requestURI;
        Integer markerIndex = uri.indexOf('/v1/');
        String remainder = markerIndex >= 0 ? uri.substring(markerIndex + '/v1/'.length()) : '';
        List<String> parts = new List<String>();
        for (String part : remainder.split('/')) {
            if (String.isNotBlank(part)) {
                parts.add(part);
            }
        }
        if (parts.isEmpty()) {
            throw new TTS_SObjectAccessException('An object API name is required in the path.');
        }
        return parts;
    }

    private static List<String> parseFields(RestRequest req) {
        String fieldsParam = req.params.get('fields');
        if (String.isBlank(fieldsParam)) {
            return new List<String>{ 'Id', 'Name' };
        }
        return fieldsParam.split(',');
    }

    private static Integer parseLimit(RestRequest req) {
        String limitParam = req.params.get('limit');
        return String.isBlank(limitParam) ? null : Integer.valueOf(limitParam);
    }

    private static void writeResponse(Integer statusCode, String body) {
        RestContext.response.statusCode = statusCode;
        if (body != null) {
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(body);
        }
    }

    private static void writeError(Integer statusCode, String message) {
        writeResponse(statusCode, JSON.serialize(new Map<String, String>{ 'error' => message }));
    }
}
