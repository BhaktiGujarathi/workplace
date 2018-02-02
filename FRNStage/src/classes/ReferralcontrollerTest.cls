@isTest
private class ReferralcontrollerTest 
{
 
    Static testMethod void Referralcontroller_Test()
    {
        
        Id Accid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = Accid;
        acc.name='test';
        acc.phone= '(123) 456-7890';
        acc.type='Prospect';
        acc.Master_Referral_Type__c='Business and Industry';
        insert acc;
        
        contact con = new contact();
        con.LastName = 'Test';
        insert con;
        
          String accRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();
            Opportunity opp = new Opportunity ();
            opp.Name = 'TestOpp';
            opp.Probability = 10;
            opp.CloseDate = System.today();
            opp.Contact__c = con.Id;
            opp.StageName = 'Prospecting';
            opp.RecordTypeId = accRT;
            insert opp;
        
        Id Refid = Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId();
        
        Referral__c ref =new Referral__c();
        ref.Account__c = acc.id;
        ref.RecordTypeId = Refid;
        ref.Patient_Name__c = 'test test1';
        //ref.Brief_PPH__c = 'test_TEXTAREA';
        
        
        Referral__c ref1 =new Referral__c();
        ref1.Account__c = acc.id;
        ref1.RecordTypeId = Refid;
        //ref1.Brief_PPH__c = 'test_TEXTAREA';
        
      
        
        
        apexpages.currentPage().getParameters().put('id',opp.Id);
        apexpages.currentPage().getParameters().put('rectName', 'test');
        apexpages.currentPage().getParameters().put('rectId',Refid);
        /*apexpages.currentPage().getParameters().put('retURL',retURL);
        ApexPages.StandardController asd = new ApexPages.StandardController(ref);
        Referralcontroller lcu = new Referralcontroller(asd);*/
        Referralcontroller lcu = new Referralcontroller();
        
        lcu.Cancel();
        
        lcu.ReferralObj = ref;
        lcu.save();
        lcu.ReferralObj = ref1;
        lcu.saveandnew();
        
    }   
}