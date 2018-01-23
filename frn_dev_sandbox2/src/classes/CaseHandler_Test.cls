@isTest
private class CaseHandler_Test{
       static testMethod void test1 () {
           
           Contact con = new contact(Firstname='Test',  Birthdate = system.today(), Description = 'tttt',Lastname = 'Test');
           insert con;
           Account acc = new Account(Name = 'Acount 1');
           insert acc;
			//case ca = [select Id,Status,Origin,Temp_Age__c,Case_Age__c from Case];

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
           
           Opportunity opp = new Opportunity(
               Name = 'Test',
               StageName = 'Prospecting',
               Probability = 10.00,
               CloseDate = system.today(),
               Contact__c  = con.id
           );
           insert opp;

           Case cs = New Case(Status = 'Approved',
               Origin='Web',
               Temp_Age__c='10',
               Opportunity__c=opp.Id,
               Accountid = acc.Id
           );
           insert cs;
           Case cs1 = New Case(
               Status = 'New', 
               Origin='Web',
               Temp_Age__c='10',
               Opportunity__c=opp.Id,
               Accountid = acc.Id
           );
           insert cs1;
           update cs1;
          /*  CaseHandler ch = new CaseHandler();
           ch.bulkAfter();
           ch.beforeDelete(cs);
           ch.beforeUpdate(cs, cs1);
           ch.afterInsert(cs);
           ch.afterUpdate(cs, cs);
           ch.afterDelete(cs);
           ch.afterUndelete(cs);
          // ch.bulkBefore(cs);
		    */
		  
		   
       }       
}