/*
     Created by:Srikanth Pinnamaneni
     ClassName:CloneCommissionTest
     
*/
@
isTest

public class CloneCommissionTest {


   public static testmethod void CommissionTest() {

        List < RecordType > record = [select id, name, SobjectType from Recordtype where SobjectType = 'Account' AND (Name = 'ISO' OR Name = 'Merchant') ];
      
        List < Profile > profile = [select id, name from profile where name = : 'System Administrator'];
        List < User > user = [select id, name from User where isActive = true];

        
        id recordid;
        id merchantid;

        for (recordType rc: record) {
            if (rc.name == 'ISO'){
             recordid = rc.id;
             }
            if (rc.name == 'Merchant') {
                merchantid = rc.id;
            }

            System.debug(MerchantId + '   ' + recordid);

        }

       

        Account merchantAccount = new Account();
        merchantAccount.Name = 'testing Merchant Account';
        merchantAccount.RecordTypeId = merchantid;
        //merchantAccount.
        insert merchantAccount;



        Account ISOAccount = new Account();
        ISOAccount.Name = 'ISO Account';
        ISOAccount.McaApp__User__c = user[0].id;
        ISOAccount.RecordTypeId = recordid;
        ISOAccount.type = 'Internal';
        insert ISOAccount;

        opportunity o = new opportunity();
        o.name = 'Test oppty';
        o.accountId = Merchantaccount.id;
        o.StageName = 'Funded';
        o.McaApp__Funding_Amount__c = 30000;
        o.McaApp__Total_Receivables__c = 10000;
        o.CloseDate = system.today();
        insert o;

        opportunityTeamMember optymem = new opportunityTeamMember();
        optymem.userid = user[0].id;
        optymem.opportunityid = o.id;

        insert optymem;

        Commission_Structure__c cs = new Commission_Structure__c();
        cs.name = ' Test Commission Structure';
        cs.Type__c = 'Opener';
        insert cs;


        Commission_Agreement__c ca = new Commission_Agreement__c();
        ca.name = 'commission test';
        ca.structure__c = cs.id;
        ca.Active__c = true;
        ca.Account__c = ISOAccount.id;
        insert ca;

        Commission_Rule__c cr = new Commission_Rule__c();
        cr.name = 'Test Rule1';
        cr.Commission_Structure__c = cs.id;
        cr.Fixed_Amount__c = 200;
        cr.Commission_Type__c = 'Fixed';
        cr.Payable_Type__c = 'commission';
        insert cr;

        Commission_Rule_Entry__c cre = new Commission_Rule_Entry__c();

        cre.name = 'Test Entry';
        cre.Commission_Rule__c = cr.id;
        cre.Field_API__c = 'McaApp__Funding_Amount__c';
        cre.Object_API__c = 'Opportunity';
        cre.Operator__c = 'Greater or Equal';
        cre.Text__c = '200';

        insert cre;

        Commission_Rule_Entry__c cre1 = new Commission_Rule_Entry__c();

        cre1.name = 'Test Entry';
        cre1.Commission_Rule__c = cr.id;
        cre1.Field_API__c = 'StageName';
        cre1.Object_API__c = 'Opportunity';
        cre1.Operator__c = 'Equals';
        cre1.Text__c = 'Funded';

        insert cre1;

        ApexPages.StandardController controller = new ApexPages.StandardController(cs);
        ApexPages.StandardController control = new ApexPages.StandardController(cr);

       
        
        
        Test.StartTest();
        
        GenerateAgreementRecordsController cst = new GenerateAgreementRecordsController(controller);
        cst.init();

        GenerateChildRecordsController commrule = new GenerateChildRecordsController(control);
        commrule.init();
        
        Test.StopTest();


    }
  
}