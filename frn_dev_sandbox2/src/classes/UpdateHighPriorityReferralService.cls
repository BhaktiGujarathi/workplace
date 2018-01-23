public with sharing class UpdateHighPriorityReferralService {
	
    public static Lead updateLeadHighPriorityCheckBox(Lead pLeadObj) {
        if(pLeadObj.get('Referral_Instruction__c') != null && pLeadObj.get('Referral_Instruction__c') != '') {
            pLeadObj.put('High_Priority__c', true);
        }
        else {
            pLeadObj.put('High_Priority__c', false);
        }

        return pLeadObj;
    }

    public static Opportunity updateOpportunityHighPriorityCheckBox(Opportunity pOpportunityObj) {
        if(pOpportunityObj.get('Referral_Instruction__c') != null && pOpportunityObj.get('Referral_Instruction__c') != '') {
            pOpportunityObj.put('High_Priority__c', true);
        }
        else {
            pOpportunityObj.put('High_Priority__c', false);
        }

        return pOpportunityObj;
    }

    public static void getReferralDocsOnOpportunity(Id pParentReferralId, Id pParentOpportnityId) {
        List<Document__c> relatedDocList = new List<Document__c>();
        List<Document__c> opportunityDocumentList = new List<Document__c>();
        relatedDocList = [SELECT id,
                                 Account__c,
                                 Opportunity__c,
                                 Linked_Document__c,
                                 Category__c
                            FROM Document__c
                           WHERE Account__c =: pParentReferralId
                             AND Opportunity__c = NULL
                             AND Category__c = 'Referral Documents'];

        for(Document__c docObj : relatedDocList) {
            system.debug('>>> docObj : '+docObj);
            Document__c docInstance = docObj.clone(false, true, false, false);
            docInstance.Opportunity__c = pParentOpportnityId;
            docInstance.Linked_Document__c = docObj.Id;
            docInstance.Account__c = null;
            opportunityDocumentList.add(docInstance);
        }

        if(!opportunityDocumentList.isEmpty()) {
            upsert opportunityDocumentList;
        }
    }
}