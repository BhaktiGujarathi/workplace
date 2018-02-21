/* Track opportunity and lead and update the date field de
 * 
 * Revision History:
 *   
 * Version      Author                Date              Description
 * 1.0          Yogesh Mahajan        10/08/2016        Initial draft[]
 */
public with sharing class StatusFieldMapping {
    
    // Map for storing Opportunity Stage Name to it's respective DateTime field
    public static final Map<String, String> OPPORTUNITY_STAGE_DATE_FIELD_MAP
        = new Map<String, String> {
            'Application Sent' => 'Application_Sent_Date_Time__c',
            'Application In'  => 'Application_In_Date_Time__c',
            'Application Missing Info'  => 'Application_Missing_Info_Date_Time__c',
            'Underwriting'  => 'Underwriting_Date_Time__c',
            'Approved'  => 'Approved_Date_Time__c',
            'Declined'  => 'Declined_Date_Time__c',
            'Agreement Requested'  => 'Agreement_Requested_Date_Time__c',
            'Agreement Sent'  => 'Agreement_Sent_Date_Time__c',
            'Agreement Signed'  => 'Agreement_Signed_Date_Time__c',
            'Funded'  => 'Funded_Date_Time__c',
            'Closed Lost'  => 'Closed_Lost_Date_Time__c',
            'Renewal Prospecting'  => 'Renewal_Prospecting_Date_Time__c',
            'Renewal Requested'  => 'Renewal_Requested_Date_Time__c'
        };

    // Map for storing Opportunity Stage Name to it's respective boolean field
    public static final Map<String, String> OPPORTUNITY_IS_STAGE_FIELD_MAP
        = new Map<String, String> {
            'Application Sent' => 'Application_Sent__c',
            'Application In'  => 'Application_In__c',
            'Application Missing Info'  => 'Application_Missing_Info__c',
            'Underwriting'  => 'Underwriting__c',
            'Approved'  => 'ApprovedStage__c',
            'Declined'  => 'Declined__c',
            'Agreement Requested'  => 'Agreement_Requested__c',
            'Agreement Sent'  => 'Agreement_Sent__c',
            'Agreement Signed'  => 'Agreement_Signed__c',
            'Funded'  => 'FundedStage__c',
            'Closed Lost'  => 'Closed_Lost__c',
            'Renewal Prospecting'  => 'Renewal_Prospecting__c',
            'Renewal Requested'  => 'Renewal_Requested__c'
        };

    // Map for storing Lead Status to it's respective Date field
    public static final Map<String, String> LEAD_STATUS_DATE_FIELD_MAP
        = new Map<String, String> {
            'Open - Not Contacted' => 'Open_Not_Contacted_Date_Time__c',
            'Open - Attempting Contact' => 'Open_Attempting_Contact_Date_Time__c',
            'Working - Contacted' => 'Working_Contacted_Date_Time__c',
            'Closed - Lost' => 'Closed_Lost_Date_Time__c'
        };

    // Map for storing Lead Status to it's respective boolean field
    public static final Map<String, String> LEAD_IS_STATUS_FIELD_MAP
        = new Map<String, String> {
            'Open - Not Contacted' => 'Open_Not_Contacted__c',
            'Open - Attempting Contact' => 'Open_Attempting_Contact__c',
            'Working - Contacted' => 'Working_Contacted__c',
            'Closed - Lost' => 'Closed_Lost__c'
        };
}