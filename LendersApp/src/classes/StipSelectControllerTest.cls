@isTest
private class StipSelectControllerTest {

    @isTest
    public static void ValidateStipSelect() {

        Account objAcc = new Account();
        objAcc.name = 'testAccountName';
        insert objAcc;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAcc.id;
        objOpportunity.name = 'testOppName';
        objOpportunity.StageName= 'Close';
        objOpportunity.CloseDate = system.today()+ 10;
        insert objOpportunity;
        
        List<McaApp__Stips__c> lstStip = new List<McaApp__Stips__c>();
        McaApp__Stips__c objStip = new McaApp__Stips__c();
        objStip.McaApp__Opportunity__c = objOpportunity.id;
        objStip.name = 'testStipName';
        objStip.Interview__c = true;
        lstStip.add(objStip);
        insert lstStip;
        
        StipMaster__c objSM = new StipMaster__c();
        objSM.name = 'testStipMasterName';
        objSM.Type__c = 'Type 1';
        objSM.stage__c = 'PreQualification';
        insert objSM;

        ApexPages.StandardsetController sc = new ApexPages.StandardsetController(lstStip);
        Test.setCurrentPageReference(new PageReference('Page.StipsSelect')); 
        System.currentPageReference().getParameters().put('id_lkid', objOpportunity.id);
        StipSelectController con = new StipSelectController(sc);
        con.dealId = objOpportunity.id;
        con.lstStipMaster[0].selected = true;
        con.SaveAndClose();
        con.done();
        con.newStip();

        //System.assertEquals(1, con.lstStipToInsert.size());
    }
}