/**
* Class to perform communication with the Eternus LMA org
* Author: Saket Joshi
* Version History
*     #    Author        Comments        Date
*     1.0  Saket Joshi   Initial Draft   02/23/2017
*/
public with sharing class LmaCommunicationManager {
    
    // Wrapper to store the session information
    public class LoginInformation {
        public String access_token;
        public String instance_url;
        public String id;
        public String token_type;
        public String issued_at;
        public String signature;
    }

    // Wrapper to store license information
    public class LicenseInformation {
        public Boolean isValid;
        public String status;
        public String expiryDate;
        public String licenseId;
    }

    // Wrapper for license information check request
    public class LicenseCheckRequest {
        public String orgId;
        public Boolean isInstall;
        public Boolean isUpgrade;
        public Boolean isUninstall;
    }

    // Wrapper for license update request
    public class LicenseUpdateRequest {
        public String orgId;
        public String packageName;
        public String licenseId;
        public Boolean isUninstall;
    }

    // Wrapper for license update response
    public class LicenseUpdateResponse {
        public String isSuccess;
        public String licenseId;
        public String message;
    }

    // Method to get the session ID for the LMA org
    public static LoginInformation getLmaSessionId() {
        String response = '';

        // Get the LMA OAuth details
        final Endpoint_Settings__c lmaEndpointSetting = 
            Endpoint_Settings__c.getAll().get(LMSConstants.LMS_ENDPOINT_SETTING);
        
        // Form the HTTP POST request to login.salesforce.com
        String body = '' +
            LMSConstants.HEADER_GRANT_TYPE + '=' + LMSConstants.GRANT_TYPE_PASSWORD
            + '&' + LMSConstants.HEADER_CLIENT_ID + '=' + lmaEndpointSetting.LMA_Consumer_Key__c
            + '&' + LMSConstants.HEADER_CLIENT_SECRET + '=' + lmaEndpointSetting.LMA_Client_Secret__c
            + '&' + LMSConstants.HEADER_USERNAME + '=' + lmaEndpointSetting.LMA_Username__c
            + '&' + LMSConstants.HEADER_PASSWORD + '=' + lmaEndpointSetting.LMA_Password__c;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(lmaEndpointSetting.Endpoint_Url__c);
        req.setMethod('POST');
        req.setBody(body);
        req.setTimeout(12000);

        HttpResponse res = new Http().send(req);

        // Parse the response
        LoginInformation loginInfo = (LoginInformation)JSON.deserialize(res.getBody(), LoginInformation.class);

        // Get the session ID and the instance URL
        return loginInfo;
    }

    // Method to perform the license check in the LMA org
    public static LicenseInformation checkLicenseValidity(LoginInformation loginInfo, Boolean isInstall, Boolean isUpgrade) {
        String response = '';
        // Form the request for license validity check
        String endpoint = loginInfo.instance_url + LMSConstants.LMS_ENDPOINT;
        endpoint += '?' + LMSConstants.PARAM_SUBSCRIBER_ID + '=' + UserInfo.getOrganizationId()
        + '&' + LMSConstants.PARAM_IS_INSTALL + '=' + isInstall
        + '&' + LMSConstants.PARAM_IS_UPGRADE + '=' + isUpgrade
        + '&' + LMSConstants.PARAM_PACKAGE_NAME + '=' + EncodingUtil.urlEncode(LMSConstants.APPLICATION_NAME, 'UTF-8');
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader(LMSConstants.AUTHORIZATION_KEY_FOR_HEADER, LMSConstants.AUTHORIZATION_VALUE_FOR_HEADER + loginInfo.access_token);
        req.setHeader(LMSConstants.CONTENT_TYPE_KEY_FOR_HEADER, LMSConstants.CONTENT_TYPE_JSON);
        req.setTimeout(12000);

        HttpResponse res = new Http().send(req);
        response = res.getBody();

        // Parse the response and return
        return (LicenseInformation)JSON.deserialize(response, LicenseInformation.class);
    }

    // Method to update the license status in the LMA org
    public static LicenseUpdateResponse updateLicense(LoginInformation loginInfo, LicenseUpdateRequest updateRequest) {
        String response = '';
        
        // Form the request for license validity check
        String endpoint = loginInfo.instance_url + LMSConstants.LMS_ENDPOINT;
        String body = JSON.serialize(updateRequest);

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setBody(body);
        req.setHeader(LMSConstants.AUTHORIZATION_KEY_FOR_HEADER, LMSConstants.AUTHORIZATION_VALUE_FOR_HEADER + loginInfo.access_token);
        req.setHeader(LMSConstants.CONTENT_TYPE_KEY_FOR_HEADER, LMSConstants.CONTENT_TYPE_JSON);
        req.setTimeout(12000);

        HttpResponse res = new Http().send(req);
        response = res.getBody();

        // Parse the response and return
        return (LicenseUpdateResponse)JSON.deserialize(response, LicenseUpdateResponse.class);
    }
    
}