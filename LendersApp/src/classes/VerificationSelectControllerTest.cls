@isTest
private class VerificationSelectControllerTest {
    
    @isTest
    public static void validateVerificationSelect() {
    
        Account objAcc = new Account();
        objAcc.Name = 'testAccountName';
        insert objAcc;
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        Opportunity objDeal = new Opportunity();
        objDeal.AccountId = objAcc.id;
        objDeal.Name = 'testDealName';
        objDeal.StageName = 'Prospecting';
        objDeal.CloseDate = date.today().addDays(5);
        lstOpp.add(objDeal);
        insert lstOpp;
        
        UWVerification__c objUWV = new UWVerification__c();
        objUWV.Opportunity__c = objDeal.id;
        objUWV.Name = 'testUWVerificationName';
        objUWV.interview__c = true;
        insert objUWV;
        
        VerificationMaster__c objVM = new VerificationMaster__c ();
        objVM.Name = 'testName';
        insert objVM;
        
        ApexPAges.StandardsetController sc = new ApexPages.StandardsetController(lstOpp);
        VerificationSelectController con = new VerificationSelectController (sc);
        con.dealId = objDeal.id;
        con.SaveAndClose();
        con.done();
        con.newVerification();
    }
}