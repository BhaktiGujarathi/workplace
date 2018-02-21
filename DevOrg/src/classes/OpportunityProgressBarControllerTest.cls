@isTest
private class OpportunityProgressBarControllerTest {
    
    static testMethod void progressBarTest() {                       
        // TO DO: implement unit test
        //Test.startTest();
            /*Opportunity objOppo = new Opportunity(Name='TestOpp', CloseDate = System.today(), 
                                              StageName='Prospecting', payment_Amount__c = 100, 
                                              Funding_Amount__c =50);
            insert objOppo;
            system.assertNotEquals(null, objOppo.Id);
            
            
            objOppo.StageName = 'Application Sent';
            update objOppo;
            system.assertNotEquals(null, objOppo.Id);
                
            objOppo.StageName = 'Application In';
            update objOppo;
                
            objOppo.StageName = 'Renewal Prospecting';
            update objOppo;*/
            
            
            //system.debug('$$$$$$$$$$$$$$$objOppo[0].Id '+objOppo.Id);
        //Test.stopTest();
       
        Opportunity objOppo = new Opportunity(Name='TestOpp', CloseDate = System.today(), 
                                              StageName='Prospecting', payment_Amount__c = 100, 
                                              Funding_Amount__c =50);
        insert objOppo;
        system.assertNotEquals(null, objOppo.Id);
        
        Apexpages.Pagereference P = Page.OpportunityProgressBar;
        P.getParameters().put('Id', objOppo.Id);
        test.setCurrentPage(P);
        
        ApexPages.currentPage().getParameters().put('Id', objOppo.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(objOppo);
        OpportunityProgressBarController controller = new OpportunityProgressBarController(sc);
        
        
        objOppo.StageName = 'Application Sent';
        update objOppo;
        
        objOppo.StageName = 'Application In';
        update objOppo;
            
        objOppo.StageName = 'Renewal Prospecting';
        update objOppo;
        
        objOppo.StageName = 'Underwriting';
        update objOppo;
        
        objOppo.StageName = 'Approved';
        update objOppo;
        
        List<OpportunityHistory> listOppHistory = new List<OpportunityHistory>();
        listOppHistory = [SELECT o.SystemModstamp, o.StageName, o.OpportunityId, o.CreatedDate
                              FROM OpportunityHistory o 
                              WHERE o.OpportunityId =: objOppo.Id 
                              ORDER BY o.CreatedDate];
        system.debug('---Opportunity History--->'+listOppHistory);
        controller.calculateTimeDifference(100);
        
        
        //Integer str = Integer.ValueOf('purple');
        //controller.addTimeDifference(string.ValueOf(str) , string.ValueOf(str) );
        //Integer val = controller.testmethods(10);
        //System.assertEquals(13,val);
    }
    
   
    
    
    
}