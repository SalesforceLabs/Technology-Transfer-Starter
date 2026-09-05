# Get Started with the REST API

Connect an external system to Technology Transfer Starter to read, create, and update package records through its custom Salesforce REST API. This setup guide is for Salesforce administrators and integration developers configuring a server-to-server connection.

## Before You Begin

Make sure the following items are available:

- Technology Transfer Starter is installed in the target Salesforce org.
- A dedicated Salesforce integration user is available. Do not use a personal administrator account.
- An External Client App or Connected App is configured for OAuth 2.0 server-to-server authentication. This guide uses the OAuth client credentials flow.
- The app's OAuth scopes include `Manage user data via APIs (api)`.
- The app is configured to run as the dedicated integration user and restricted to approved users where the selected app type supports that policy.
- A secure secrets manager is available for the client secret and access tokens.
- The integration user has the **TTS Integration User** permission set.

The examples use `curl` and environment variables. Run them first against a sandbox or scratch org.

## Understand the Endpoint

The package exposes this endpoint in a subscriber org:

```text
https://{my-domain}.my.salesforce.com/services/apexrest/techstarter/v1/{object-api-name}[/{record-id}]
```

Use the instance URL returned by OAuth as the hostname. The `techstarter` segment is the managed-package namespace. In an unmanaged development org, omit that segment:

```text
https://{instance-url}/services/apexrest/v1/{object-api-name}[/{record-id}]
```

The endpoint supports these operations:

| Method | Path | Result |
| --- | --- | --- |
| `GET` | `/{object-api-name}` | Returns up to 200 records. |
| `GET` | `/{object-api-name}/{record-id}` | Returns one record. |
| `POST` | `/{object-api-name}` | Creates a record and returns HTTP `201`. |
| `PATCH` | `/{object-api-name}/{record-id}` | Updates fields and returns HTTP `200`. |

Delete is implemented by the Apex resource, but the shipped **TTS Integration User** permission set does not grant delete access. This guide therefore excludes delete usage.

## Configure Authentication

Configure an External Client App or Connected App according to your org's application-management policies. For the OAuth client credentials flow, record the consumer key as the client ID and store the client secret in an approved secrets manager.

Set the integration values in your shell without committing them to source control:

```bash
export SF_LOGIN_URL="https://test.salesforce.com"
read -r -p "Salesforce consumer key: " SF_CLIENT_ID
read -r -s -p "Salesforce client secret: " SF_CLIENT_SECRET
export SF_CLIENT_ID SF_CLIENT_SECRET
```

Use `https://login.salesforce.com` for production unless your security policy requires a My Domain login URL. Use `https://test.salesforce.com` for a sandbox.

Request an access token:

```bash
TOKEN_RESPONSE=$(curl --silent --show-error --fail \
  --request POST "$SF_LOGIN_URL/services/oauth2/token" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "client_id=$SF_CLIENT_ID" \
  --data-urlencode "client_secret=$SF_CLIENT_SECRET")

export SF_ACCESS_TOKEN=$(jq --raw-output '.access_token' <<<"$TOKEN_RESPONSE")
export SF_INSTANCE_URL=$(jq --raw-output '.instance_url' <<<"$TOKEN_RESPONSE")
export TTS_API_ROOT="$SF_INSTANCE_URL/services/apexrest/techstarter/v1"
```

Do not log `TOKEN_RESPONSE`, `SF_CLIENT_SECRET`, or `SF_ACCESS_TOKEN`. Refresh the token by repeating the token request when it expires.

## Assign Permissions

1. From **Setup**, enter `Permission Sets` in **Quick Find**, then select **Permission Sets**.
2. Select **TTS Integration User**.
3. Click **Manage Assignments**.
4. Click **Add Assignments**.
5. Select the dedicated integration user.
6. Click **Next**, then click **Assign**.

The permission set grants:

- **API Enabled** system permission.
- Access to the `TTS_ObjectRestResource` Apex class.
- Read, create, and edit access to the 24 package objects exposed by the API.
- Read or edit field-level security for the exposed package fields.
- **View All** record access on exposed objects, without **Modify All** or delete permission.

Salesforce still enforces the integration user's permissions. Requests fail when the user lacks access to an object, field, record type, referenced record, or required business rule.

## Read Data

List Technology records and select the fields returned in each record:

```bash
curl --silent --show-error --fail-with-body --get \
  "$TTS_API_ROOT/TTS_Technology__c" \
  --header "Authorization: Bearer $SF_ACCESS_TOKEN" \
  --data-urlencode "fields=Id,Name,IP_Title__c,IP_Status__c,IP_External_Reference__c" \
  --data-urlencode "limit=25"
```

The default response contains `Id` and `Name`. Pass a comma-separated `fields` query parameter to request other accessible fields. The `limit` parameter accepts values from 1 through 200; omitted or out-of-range values return up to 200 records.

Read one record by its Salesforce record ID:

```bash
curl --silent --show-error --fail-with-body --get \
  "$TTS_API_ROOT/TTS_Technology__c/$TTS_RECORD_ID" \
  --header "Authorization: Bearer $SF_ACCESS_TOKEN" \
  --data-urlencode "fields=Id,Name,IP_Title__c,IP_Status__c,IP_External_Reference__c"
```

## Create Data

Create a Technology record by sending writable field API names as a JSON object:

```bash
CREATE_RESPONSE=$(curl --silent --show-error --fail-with-body \
  --request POST "$TTS_API_ROOT/TTS_Technology__c" \
  --header "Authorization: Bearer $SF_ACCESS_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "IP_Title__c": "Low-Energy Water Purification Membrane",
    "IP_Status__c": "Draft",
    "IP_External_Reference__c": "API-DEMO-2026-001"
  }')

export TTS_RECORD_ID=$(jq --raw-output '.Id' <<<"$CREATE_RESPONSE")
```

A successful request returns HTTP `201` and a JSON representation containing the new record ID. `IP_External_Reference__c` is a unique external ID, so use a new value for each example run.

## Update Data

Update only the fields that need to change:

```bash
curl --silent --show-error --fail-with-body \
  --request PATCH "$TTS_API_ROOT/TTS_Technology__c/$TTS_RECORD_ID" \
  --header "Authorization: Bearer $SF_ACCESS_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "IP_Status__c": "Initial Disclosure",
    "IP_Title__c": "Low-Energy Membrane for Water Purification"
  }'
```

A successful request returns HTTP `200` and a JSON representation containing the record ID and submitted field values.

## Verify Your Work

Read the record after the update:

```bash
curl --silent --show-error --fail-with-body --get \
  "$TTS_API_ROOT/TTS_Technology__c/$TTS_RECORD_ID" \
  --header "Authorization: Bearer $SF_ACCESS_TOKEN" \
  --data-urlencode "fields=Id,Name,IP_Title__c,IP_Status__c,IP_External_Reference__c"
```

Confirm that the response contains the expected title, status, and external reference. Also open the Technology record in Salesforce and confirm that the values match.

## Available Objects

The endpoint accepts these unqualified object API names:

| Object API name | Object API name |
| --- | --- |
| `TTS_Agreement__c` | `TTS_Agreement_Deliverable__c` |
| `TTS_Agreement_Party__c` | `TTS_Applicant__c` |
| `TTS_Contributor__c` | `TTS_Disclosure__c` |
| `TTS_Inventor__c` | `TTS_Mentoring_Interest__c` |
| `TTS_Mentoring_Opportunity__c` | `TTS_Milestone__c` |
| `TTS_Protection__c` | `TTS_Protection_Claim__c` |
| `TTS_Protection_Family__c` | `TTS_Protection_Litigation__c` |
| `TTS_Recipient__c` | `TTS_Space__c` |
| `TTS_Space_Asset__c` | `TTS_Space_Tenant__c` |
| `TTS_Space_Tenant_Contact__c` | `TTS_Success_Plans__c` |
| `TTS_Technology__c` | `TTS_TrademarkIPAssociation__c` |
| `TTS_Trademark_Classes__c` | `TTS_Transaction__c` |

Use bare names in the URL and request body, as shown in the examples. The package resolves its namespace internally.

## Troubleshoot Common Errors

| Symptom | Resolution |
| --- | --- |
| OAuth returns `invalid_client` | Confirm the client ID and secret, the app's client credentials setting, and the configured run-as user. |
| Salesforce returns `401 Unauthorized` | Request a new access token and confirm that the request uses the OAuth `instance_url`. |
| Salesforce returns `403 Forbidden` | Confirm that the integration user is approved for the OAuth app and has **TTS Integration User** assigned. |
| The API returns `Object is not available through this API` | Use one of the object API names listed in this guide. Standard objects such as `Account` are not exposed. |
| The API returns an unknown-field error | Check the field API name and the integration user's field-level security. Use bare package field names such as `IP_Title__c`. |
| A create or update returns an unexpected error | Check required fields, record type access, lookup access, validation rules, and picklist values in the target org. |
| A delete request fails | The shipped integration permission set intentionally omits delete access. Use a separately reviewed permission design only when deletion is a documented integration requirement. |

## Security Practices

- Store client secrets and tokens in an approved secrets manager.
- Use separate OAuth apps, credentials, and integration users for sandbox and production.
- Grant only the OAuth scopes and Salesforce permissions required by the integration.
- Restrict access by IP range or network policy when required by your security design.
- Rotate service credentials according to your security policy and immediately after suspected exposure.
- Monitor OAuth login history, API usage, and integration-user record changes.
- Do not place access tokens or client secrets in URLs, logs, source files, support tickets, or chat messages.

## Related Resources

- [OAuth 2.0 Client Credentials Flow for Server-to-Server Integration](https://help.salesforce.com/s/articleView?id=xcloud.remoteaccess_oauth_client_credentials_flow.htm&type=5)
- [Quick Start: OAuth](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/quickstart_oauth.htm)
- [Apex REST Basic Code Sample](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest_code_sample_basic.htm)
