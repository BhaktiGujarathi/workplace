/**
* Class for getting the config for LMS
* Author: Saket Joshi
* Version History
*     #    Author        Comments        Date
*     1.0  Saket Joshi   Initial Draft   02/23/2017
*/
public with sharing class LMSConfigManager {

    public class InvalidLicenseException extends Exception {}

    // Store the current environment here
    // @TODO - Change the value to PKG before creating the MANAGED RELEASE package
    public Enum ENV { DEV, PKG }
    public static final ENV CURRENT_ENV = ENV.DEV;

    // Method to get the status of installation for add-ons
    public static Boolean getIfLicenseValid () {
        String featureName = LMSConstants.FEATURE_FHT;
        Feature_Installation_Master__c feature = getFeatureDetails(featureName);
        return feature != null && 
            (feature.Is_Active__c == true && 
                (feature.License_Days_Remaining__c != null || feature.Never_Expires__c == true));
    }

    // Method to get the feature installation instance
    public static Feature_Installation_Master__c getFeatureDetails (String featureName) {
        return Feature_Installation_Master__c.getAll().get(featureName);
    }

    // Future method for license validation
    @future(callout=true)
    public static void validateLicenseFuture() {
        validateLicense();
    }
    
    // Method to validate license on installation
    public static void validateLicense() {
        LmaCommunicationManager.LoginInformation loginInfo = LmaCommunicationManager.getLmaSessionId();
        LmaCommunicationManager.LicenseInformation licenseInfo = LmaCommunicationManager.checkLicenseValidity(loginInfo, true, false);

        if (licenseInfo.isValid) {
            Feature_Installation_Master__c feature = new Feature_Installation_Master__c(
                    Name = LMSConstants.FEATURE_FHT,
                    Feature_Installed_By__c = UserInfo.getUserId(),
                    Installation_Date_Time__c = System.Datetime.now(),
                    Is_Active__c = true
            );

            insert feature;

            Feature_Installation_Master__c toUpdate = LicenseCheckScheduler.calculateFeatureValues(LMSConstants.FEATURE_FHT, licenseInfo);
            update toUpdate;
        } else {
            throw new InvalidLicenseException(LMSConstants.MSG_INVALID_LICENSE);
        }
    }
    
    // Method to be run from the post uninstall script
    public static void onUninstall() {
        LmaCommunicationManager.LoginInformation loginInfo = LmaCommunicationManager.getLmaSessionId();
        
        Feature_Installation_Master__c feature = getFeatureDetails(LMSConstants.FEATURE_FHT);
        
        LmaCommunicationManager.LicenseUpdateRequest updateRequest = new LmaCommunicationManager.LicenseUpdateRequest();
        updateRequest.orgId = UserInfo.getOrganizationId();
        updateRequest.packageName = LMSConstants.FEATURE_FHT;
        updateRequest.licenseId = feature.License_Record_ID__c;
        updateRequest.isUninstall = true;
        
        try {
            LmaCommunicationManager.updateLicense(loginInfo, updateRequest);
        } catch (Exception ex) {
            System.debug(System.LoggingLevel.ERROR, ex.getTypeName() + ': ' + ex.getStackTraceString());
        }
        
        delete feature;
    }
    
    // Method to kickoff the scheduler for LMS
    public static void kickoffLmsScheduler() {
        System.schedule('UFHTLicenseChesck' + UserInfo.getOrganizationId(), '0 0 0 * * ?', new LicenseCheckScheduler());
    }
    
    // Method to create the endpoint settings on package installation
    public static void createEndpoint() {
        Endpoint_Settings__c endpoint = new Endpoint_Settings__c(
            Name = LMSConstants.LMS_ENDPOINT_SETTING,
            Is_Active__c = true
        );
        
        if (CURRENT_ENV == ENV.DEV) {
            endpoint.Endpoint_Url__c = 'https://test.salesforce.com/services/oauth2/token';
            endpoint.LMA_Client_Secret__c = '2001897871368769936';
            endpoint.LMA_Consumer_Key__c = '3MVG9e2mBbZnmM6ls4waaovJqek2orJKEy.F8WGkv1npF4HiISeEH9EHIPn.eoFFAr6YrIREMsmCaToQCswhW';
            endpoint.LMA_Username__c = 'gauravsengupta@eternussolutions.com.devp';
            endpoint.LMA_Password__c = '$enzx1234';
        } else if (CURRENT_ENV == ENV.PKG) {
            endpoint.Endpoint_Url__c = 'https://login.salesforce.com/services/oauth2/token';
            endpoint.LMA_Client_Secret__c = '';
            endpoint.LMA_Consumer_Key__c = '';
            endpoint.LMA_Username__c = 'gauravsengupta@eternussolutions.com';
            endpoint.LMA_Password__c = 'sfdc@espl123';
        }
        
        insert endpoint;
    }

}