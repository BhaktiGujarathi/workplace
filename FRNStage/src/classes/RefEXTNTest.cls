@isTest
private class RefEXTNTest 
{
 
    Static testMethod void RefEXTN_Test()
    {
        
        Id Accid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = Accid;
        acc.name='test';
        acc.phone= '(123) 456-7890';
        acc.type='Prospect';
        acc.Master_Referral_Type__c='Business and Industry';
        insert acc;
        
        
        Id Refid = Schema.SObjectType.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId();
        
        Referral__c ref =new Referral__c();
        ref.Account__c = acc.id;
        ref.RecordTypeId = Refid;
        
        Referral__c ref1 =new Referral__c();
        ref1.Account__c = acc.id;
        ref1.RecordTypeId = Refid;
        
        String retURL = 'url';
        apexpages.currentPage().getParameters().put('retURL',retURL);
        ApexPages.StandardController asd = new ApexPages.StandardController(ref);
        RefEXTN lcu = new RefEXTN(asd);
        
        lcu.Cancel();
        
        lcu.ReferralObj = ref;
        lcu.save();
        lcu.ReferralObj = ref1;
        lcu.saveandnew();
        
    }   
}