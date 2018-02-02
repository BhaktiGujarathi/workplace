global with sharing class ApproveNSendToTierTaskCreationService {
	public Static Opportunity sourceOpportunityRecord = new Opportunity();
    public Static Datetime currentDateTime = System.Now();

    webservice static string triggerTaskCreationForApproval(Id oppID){ 
        Id returnToId;
        if(oppID != null) {
            sourceOpportunityRecord = [SELECT id,
                                              StageName
                                         FROM Opportunity
                                        WHERE Id =:oppID];    
            if(sourceOpportunityRecord != null && sourceOpportunityRecord.StageName == 'Pending Appointment') {
                Task approvalTaskRecord = new Task(OwnerId = UserInfo.getUserId(),
                                                   Subject = 'Approval',
                                                   Subject_Description__c = 'Approving Patient',
                                                   Completed_Date__c = currentDateTime,
                                                   //Created Date / time  = currentDateTime,
                                                   Description = 'Patient screening information has been reviewed and is approved for admission.',
                                                   WhatId = oppID, 
                                                   Status = 'Completed');
                try {
                    insert approvalTaskRecord;
                    returnToId = approvalTaskRecord.Id;
                }
                catch(Exception exObj) {
                    system.debug('exObj = '+exObj);
                    returnToId = oppID;
                }
            }
        }
        
        return returnToId;
    }
}