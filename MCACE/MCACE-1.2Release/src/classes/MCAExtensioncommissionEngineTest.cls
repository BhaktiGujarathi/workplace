/*
     Created by:Srikanth Pinnamaneni
     
*/    

@isTest(seeAllData =  false)

public class MCAExtensioncommissionEngineTest{


    public static testmethod void CommissionTest()
    {
   
        
   PublicGroupInfoTestData.publicGroupInfoTestDataInsert(UserInfo.getUserID());       
      
   List<recordType> record = [select id , name , SobjectType from Recordtype where SobjectType = 'Account' AND (Name = 'ISO' OR Name = 'Merchant')];
   List<Profile> Profile = [select id, name from Profile where name =: 'System Administrator'];
   List<User> User = [select id, name from User where isActive = true];
    
    
    
    id recordid;
    id merchantid;
    
    for(recordType rc : record){
        if(rc.name == 'ISO') {
            recordid = rc.id;
        }
        if(rc.name == 'Merchant') {
            merchantid = rc.id;
        }
       
    
    }
    Test.StartTest();
     
    system.runAs([select id from User where id = :userInfo.getUserID() limit 1][0])
    {
         
    
    
    Account merchantAccount = new Account();
    merchantAccount.Name = 'testing Merchant Account';
    merchantAccount.RecordTypeId = merchantid;
    
    insert merchantAccount;
    
    
    
    Account ISOAccount = new Account();
    ISOAccount.Name='ISO Account' ;
     ISOAccount.McaApp__User__c = User[0].id;
     ISOAccount.RecordTypeId  = recordid;
     ISOAccount.type = 'Internal';
     insert ISOAccount;
     
     
     opportunity o = new opportunity();
     o.name = 'Test oppty';
     o.accountId = Merchantaccount.id;
     o.StageName = 'Funded';
     o.McaApp__Funding_Amount__c = 30000;
     o.McaApp__Total_Receivables__c = 10000;
     o.McaApp__Date_Funded__c = System.TODAY().addDays(10);
     o.CloseDate = system.today();
     insert o;
      
      opportunityTeamMember optymem = new opportunityTeamMember();
      optymem.Userid = User[0].id;
      optymem.opportunityid = o.id;
      
      insert optymem;
      
      Commission_Structure__c cs = new Commission_Structure__c();
      cs.name = ' Test Commission Structure';
      cs.Type__c = 'Opener';
      insert cs;
      
      
      
      Commission_Agreement__c caOld = new Commission_Agreement__c();
      caOld .name = 'commission test';
      caOld.structure__c = cs.id;
      caOld.MCACE__First_Payroll_Cycle_End_Date__c = System.TODAY().addDays(1);
      caOld.MCACE__First_Payroll_Pay_Date__c = System.TODAY().addMonths(3);
      caOld.MCACE__Pay_Period_Frequency__c = 7;
      caOld.Active__c = true;
      caOld.Account__c = ISOAccount.id;
      insert caOld;
      
      
      Commission_Agreement__c ca = new Commission_Agreement__c();
      ca.name = 'commission test';
      ca.structure__c = cs.id;
      ca.Active__c = true;
      ca.Account__c = ISOAccount.id;
      insert ca;
      
      // rule for PickList field
      Commission_Rule__c crPickList = new Commission_Rule__c();
      crPickList.name = 'Test Rule PickList';
      crPickList.Commission_Structure__c = cs.id;
      //cr.Fixed_Amount__c = 100;
      crPickList.Commission_Type__c = 'Percent';
      crPickList.Payable_Type__c = 'Commission';
      crPickList.Commission_Percentage__c = 20;
      crPickList.Percentage_Of__c = 'All Revenue';           
      insert crPickList;
      
      Commission_Rule_Entry__c crePickList = new Commission_Rule_Entry__c();
      
      crePickList.name = 'Test Entry';
      crePickList.Commission_Rule__c = crPickList.id;
      crePickList.Field_API__c = 'StageName';
      crePickList.Object_API__c = 'Opportunity';
      crePickList.Operator__c = 'not equal to';
      crePickList.Text__c= 'Funded';
      
      insert crePickList;
      
      // rule for currency field
      Commission_Rule__c crCurrency = new Commission_Rule__c();
      crCurrency.name = 'Test Rule Currency';
      crCurrency.Commission_Structure__c = cs.id;
      //cr.Fixed_Amount__c = 100;
      crCurrency.Commission_Type__c = 'Fixed';
      crCurrency.Payable_Type__c = 'Commission';
      crCurrency.MCACE__Fixed_Amount__c = 100;           
      insert crCurrency;
      
      Commission_Rule_Entry__c creCurrency = new Commission_Rule_Entry__c();
      
      creCurrency.name = 'Test Entry';
      creCurrency.Commission_Rule__c = crCurrency.id;
      creCurrency.Field_API__c = 'McaApp__Funding_Amount__c';
      creCurrency.Object_API__c = 'Opportunity';
      creCurrency.Operator__c = 'Greater or Equal';
      creCurrency.Text__c= '200';
      insert creCurrency;

      // rule for String Field
      Commission_Rule__c crString = new Commission_Rule__c();
      crString.name = 'Test Rule String';
      crString.Commission_Structure__c = cs.id;
      //cr.Fixed_Amount__c = 100;
      crString.Commission_Type__c = 'Fixed';
      crString.Payable_Type__c = 'Commission';
      crString.MCACE__Fixed_Amount__c = 200;           
      insert crString;
      
      Commission_Rule_Entry__c creString = new Commission_Rule_Entry__c();
      
      creString.name = 'Test Entry';
      creString.Commission_Rule__c = crString.id;
      creString.Field_API__c = 'McaApp__Collector__c';
      creString.Object_API__c = 'Opportunity';
      creString.Operator__c = 'equals';
      creString.Text__c= 'TestCollector';
      insert creString;
      
      // rule for Decimal field
      Commission_Rule__c crDecimal = new Commission_Rule__c();
      crDecimal.name = 'Test Rule Decimal';
      crDecimal.Commission_Structure__c = cs.id;
      //cr.Fixed_Amount__c = 100;
      crDecimal.Commission_Type__c = 'Fixed';
      crDecimal.Payable_Type__c = 'Commission';
      crDecimal.MCACE__Fixed_Amount__c = 300;           
      insert crDecimal;
      
      Commission_Rule_Entry__c creDecimal = new Commission_Rule_Entry__c();
      
      creDecimal.name = 'Test Entry';
      creDecimal.Commission_Rule__c = crDecimal.id;
      creDecimal.Field_API__c = 'McaApp__No_Bank_Statements__c';
      creDecimal.Object_API__c = 'Opportunity';
      creDecimal.Operator__c = 'equals';
      creDecimal.Text__c= '3';
      insert creDecimal;
      
      // rule for Date
      Commission_Rule__c crDate = new Commission_Rule__c();
      crDate.name = 'Test Rule Date';
      crDate.Commission_Structure__c = cs.id;
      //cr.Fixed_Amount__c = 100;
      crDate.Commission_Type__c = 'Fixed';
      crDate.Payable_Type__c = 'Commission';
      crDate.MCACE__Fixed_Amount__c = 400;           
      insert crDate;
      
      Commission_Rule_Entry__c creDate = new Commission_Rule_Entry__c();
      
      creDate.name = 'Test Entry';
      creDate.Commission_Rule__c = crDate.id;
      creDate.Field_API__c = 'CloseDate';
      creDate.Object_API__c = 'Opportunity';
      creDate.Operator__c = 'equals';
      creDate.Text__c= '12/10/2015';
      
      insert creDate;
      
      // rule for URL
      Commission_Rule__c crURL = new Commission_Rule__c();
      crURL.name = 'Test Rule URL';
      crURL.Commission_Structure__c = cs.id;
      //cr.Fixed_Amount__c = 100;
      crURL.Commission_Type__c = 'Fixed';
      crURL.Payable_Type__c = 'Commission';
      crURL.MCACE__Fixed_Amount__c = 500;           
      insert crURL;
      
      Commission_Rule_Entry__c creURL = new Commission_Rule_Entry__c();
      
      creURL.name = 'Test Entry URL';
      creURL.Commission_Rule__c = crURL.id;
      creURL.Field_API__c = 'MCACE__Test_URL__c';
      creURL.Object_API__c = 'Opportunity';
      creURL.Operator__c = 'equals';
      creURL.Text__c= 'abc';
      insert creURL;
      
      // rule for Date Time
      Commission_Rule__c crDateTime = new Commission_Rule__c();
      crDateTime.name = 'Test Rule DateTime';
      crDateTime.Commission_Structure__c = cs.id;
      //cr.Fixed_Amount__c = 100;
      crDateTime.Commission_Type__c = 'Fixed';
      crDateTime.Payable_Type__c = 'Commission';
      crDateTime.MCACE__Fixed_Amount__c = 600;           
      insert crDateTime;
      
      Commission_Rule_Entry__c creDateTime = new Commission_Rule_Entry__c();
      
      creDateTime.name = 'Test Entry';
      creDateTime.Commission_Rule__c = crDateTime.id;
      creDateTime.Field_API__c = 'McaApp__Date_Submitted__c';
      creDateTime.Object_API__c = 'McaApp__Submission__c';
      creDateTime.Operator__c = 'equals';
      creDateTime.Text__c= '12/10/2015';
      
      insert creDateTime;
      
      List<Group> listGroup = [Select id,type from Group where name = 'CEPayableCreation' AND type='Queue' limit 1];
       MCACE__CEPayableCreation__c tempCEcreate = new MCACE__CEPayableCreation__c(name='CEPayableCreation',
                                   ownerID = listGroup[0].id);
       insert tempCEcreate; 
      
            MCAExtensionCommissionEngine.commissioncal(o.id);
      }
          
          
     
     
      
      Test.StopTest();
      
      

    
    }
   
    
    
    
}