public with sharing class OpportunityScoreTestDataFactory {
	public OpportunityScoreTestDataFactory() {
		
	}

    public static Document createDocumentRecord(Document pDocumentObj,
                                                String pBodyStr,
                                                String pDeveloperName,
                                                String pName,
                                                String pContentType,
                                                Boolean pIsPublic,
                                                Id pFolderId) {
        pDocumentObj.Body = Blob.valueOf(pBodyStr);
        pDocumentObj.DeveloperName = pDeveloperName;
        pDocumentObj.Name = pName;
        pDocumentObj.IsPublic = pIsPublic;
        pDocumentObj.ContentType = pContentType;
        pDocumentObj.FolderId = pFolderId;

        return pDocumentObj;

    }

    public static Opportunity createOpportunityRecord(Opportunity pOpportunityObj,
                                               Id pRecordTypeId,
                                               String pLeadSource,
                                               String pOpportunityName) {
        
        pOpportunityObj.RecordtypeId = pRecordTypeId;
        pOpportunityObj.LeadSource = pLeadSource;
        pOpportunityObj.Name = pOpportunityName;
        pOpportunityObj.StageName = 'In Process';        
        pOpportunityObj.CloseDate = System.today().addMonths(5);
        pOpportunityObj.Readmit__c = 'Yes';
        pOpportunityObj.Relapse_Date__c = System.today().addDays(-10);

        return pOpportunityObj;
    }
}