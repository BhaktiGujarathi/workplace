@isTest
private class MCANestedOffersTabControllerTest{
   static testMethod void MCANestedOffersTabController(){
    
        Opportunity OppRecord1 = new Opportunity(Name = 'Rocky1', CloseDate = system.today(), 
												 StageName = 'Application Sent', ForecastCategoryName = 'Pipeline',
												 Amount = 1000);
		insert OppRecord1;
		
		Submission__c submissionRecord1 = new Submission__c(Date_Submitted__c = system.today(),Opportunity__c = OppRecord1.Id);
		insert submissionRecord1;
	    
        Offer__c objOffer = new Offer__c();
        objOffer.Opportunity__c = OppRecord1.Id;
        objOffer.Submission__c = submissionRecord1.Id;
        insert objOffer;
        system.debug('****objOffer***'+objOffer);
        
        //Create a reference to the VF page
        PageReference pageRef = Page.MCATabPage;
        pageRef.getParameters().put('Id', objOffer.Id);
        system.debug('***pageRef***'+pageRef);
        Test.setCurrentPageReference(pageRef);
        

        ApexPages.StandardController sc = new ApexPages.standardController(objOffer);
        MCANestedOffersTabController obj = new MCANestedOffersTabController();
        
        obj.getOffers();
        obj.newOffer();
        obj.refresh();
        obj.saveAll();
        obj.editAll();
    }
 }