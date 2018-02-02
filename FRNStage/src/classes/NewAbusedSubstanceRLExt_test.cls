@isTest
public class NewAbusedSubstanceRLExt_test{
 testMethod static void test1(){
     contact con = new contact();
        con.LastName = 'Test';
        con.Birthdate = System.Today();
        con.FirstName = 'Test1';
        con.Social_Security_Number__c = 'Test';
        insert con;
        
        
        Id oppRTId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.CloseDate=system.today();
        opp.RecordTypeId = oppRTId2;
        opp.StageName='Prospecting';
        opp.Contact__c = con.Id;
        opp.Probability = 10;
        insert opp;
		
        Abused_Substance__c abs = new Abused_Substance__c();
        abs.Opportunity__c = opp.Id;       
        abs.Patient__c = con.Id;
     	insert abs;
		
        ApexPages.CurrentPage().getparameters().put('retURL',opp.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(abs);

        PageReference pageRef = Page.NewAbusedSubstanceRL;
        pageRef.getParameters().put('retURL',opp.id);
        Test.setCurrentPage(pageRef);
        NewAbusedSubstanceRLExt nas = new NewAbusedSubstanceRLExt(sc);
        nas.Save();
		nas.SaveandNew();
		nas.Cancel();
    }
}