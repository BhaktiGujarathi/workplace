/* Track opportunity and lead and update the date field de
 * 
 * Revision History:
 *   
 * Version      Author                Date              Description
 * 1.0          Yogesh Mahajan        08/09/2016        Initial draft[]
 */

public with sharing class OpportunityLeadService {
    //String applicationSentDate = Schema.sObjectType.Opportunity.fields.Application_Sent_Date_Time__c.getName();
    private static final Map<String, String> OPPORTUNITY_STAGE_FIELD_MAP
        = new Map<String, String> {
            'Application Sent' => 'Application_Sent_Date_Time__c',
            'Application In'  => 'Application_In_Date_Time__c',
            'Application Missing Info'  => 'Application_Missing_Info_Date_Time__c',
            'Underwriting'  => 'Underwriting_Date_Time__c',
            'Approved'  => 'Approved_Date__c',
            'Declined'  => 'Declined_Date_Time__c',
            'Agreement Requested'  => 'Agreement_Requested_Date_Time__c',
            'Agreement Sent'  => 'Agreement_Sent_Date_Time__c',
            'Agreement Signed'  => 'Agreement_Signed_Date_Time__c',
            'Funded'  => 'Funded_Date_Time__c',
            'Closed Lost'  => 'Closed_Lost_Date_Time__c',
            'Renewal Prospecting'  => 'Renewal_Prospecting_Date_Time__c',
            'Renewal Requested'  => 'Renewal_Requested_Date_Time__c'
        };
    Map<String, String> LEAD_STATUS_FIELD_MAP = new Map<String, String>();

    public void opportunityStageTrack() {
        
    }

    public static void opportunityStageTrack(List<Opportunity> opportunities) {
        for(Opportunity opportunity :opportunities) {
            if(OPPORTUNITY_STAGE_FIELD_MAP.containsKey(opportunity.StageName)) {
                opportunity.put(OPPORTUNITY_STAGE_FIELD_MAP.get(opportunity.StageName), system.now());
            }
        }
    }

}