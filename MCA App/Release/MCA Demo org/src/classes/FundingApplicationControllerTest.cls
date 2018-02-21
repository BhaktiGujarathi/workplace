/**

 *  Description -  Test Class for FundingApplicationController
 *
 * Version     Author                      Date                 Description
 * 1.0         Neena Tiwari		          04/18/2014            Initial Draft
 *                                                          
 */
 	
@isTest
private class FundingApplicationControllerTest {

    //this method will test the save and quick save functionality used on Funding Application Page.
    static testMethod void FundingApplicationSaveAndQuickSaveTesting() {
       //created a single record of account
       Account accRecord = FundingApplicationControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       
       //created list of contract record
       List<Contact> conList = FundingApplicationControllerTest.createContactRecords(2);
       insert conList; //contract list inserted 
       
       //created a single opportunity record 
       Opportunity opportunity = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent', 
                                          Owner_1__c = conList[0].Id,
                                          Owner_2__c = conList[1].Id); 
        insert opportunity;
                                          
       Opportunity opportunity1 = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent', 
                                          Owner_1__c = conList[0].Id ); 
       insert opportunity1; //opportunity list inserted
       
        Opportunity opportunity2 = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent', 
                                          Owner_2__c = conList[0].Id ); 
       insert opportunity2;
       
       Opportunity opportunity3 = new Opportunity(Name = 'Test Opp3', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent'
                                         ); 
      insert opportunity3; 
      
      Opportunity opportunity4 = new Opportunity(Name = 'Test Opp3', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent'
                                         ); 
      insert opportunity4; 
       
       Test.startTest();
    PageReference pageRef = Page.FundingApplication;
        pageRef.getParameters().put('oppId', opportunity.Id);
       pageRef.getParameters().put('id', accRecord.Id);
       
       //Set Funding Application as Current Page
       test.setCurrentPageReference(pageRef);
       ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);
      
       //created instance of FundingApplicationController class
       FundingApplicationController fundingApplication = 
            new FundingApplicationController(sc);
             fundingApplication.opportunity.Owner_1__c = conList[0].Id;
	   conList[0].Title = 'Testing Title';
	   update conlist[0];
	   fundingApplication.Owner1LastName = 'TestLast';
	   fundingApplication.Owner2LastName = 'TestLast2';
	   fundingApplication.QuickSave1();
	   
	   
	    
	   Contact con = [Select Id,Title from Contact where Id =: conList[0].Id];
	   system.assertEquals(con.Title, 'Testing Title');
	   fundingApplication.cancel();
	   fundingApplication.editPage();
	   fundingApplication.Save();
	   //          
	  system.debug('Opportunity2');
	   pageRef.getParameters().put('oppId', opportunity1.Id);
       pageRef.getParameters().put('id', accRecord.Id);
	   test.setCurrentPageReference(pageRef);
	   ApexPages.StandardController sc1 = new ApexPages.StandardController(opportunity1);
      
       system.debug('Opportunity3');
	   pageRef.getParameters().put('oppId', opportunity3.Id);
       pageRef.getParameters().put('id', accRecord.Id);
	   test.setCurrentPageReference(pageRef);
	   ApexPages.StandardController sc3 = new ApexPages.StandardController(opportunity3);
	   
	   system.debug('Opportunity4');
	   pageRef.getParameters().put('oppId', opportunity4.Id);
       pageRef.getParameters().put('id', accRecord.Id);
	   test.setCurrentPageReference(pageRef);
	   ApexPages.StandardController sc4 = new ApexPages.StandardController(opportunity4);
	   
	   
	   
       //created instance of FundingApplicationController class
       FundingApplicationController fundingApplication1 = 
            new FundingApplicationController(sc1);
             fundingApplication1.opportunity.Owner_1__c = conList[0].Id;
	   Contact objContact = new Contact(FirstName='Test1', LastName='Test1',AccountId = accRecord.Id);
	   insert objContact;
	   fundingApplication.Owner2LastName = 'Test1';
	   fundingApplication.conForOwner2.FirstName = 'Test1';
	   fundingApplication.oldContactOwner2.add(objContact);
	   fundingApplication.QuickSave1();
	   
	                                      
        
       
        FundingApplicationController fundingApplication2 = 
            new FundingApplicationController(sc3);
       fundingApplication2.opportunity.Owner_1__c = null;     
	   Contact dupContact = new Contact();
	   dupContact.FirstName = 'Test Contact';
	   dupContact.LastName = 'Test Contact';
	   insert dupContact;
	   fundingApplication2.Owner1LastName = 'Test Contact';
	   fundingApplication2.conForOwner1.FirstName = 'Test Contact';
	   fundingApplication2.QuickSave1();
	   
	   FundingApplicationController fundingApplication3 = 
            new FundingApplicationController(sc4);
       fundingApplication3.opportunity.Owner_2__c = null;     
	   Contact dupContact1 = new Contact();
	   dupContact1.FirstName = 'Test Contact11';
	   dupContact1.LastName = 'Test Contact11';
	   insert dupContact1;
	   fundingApplication3.Owner2LastName = 'Test Contact11';
	   fundingApplication3.conForOwner2.FirstName = 'Test Contact11';
	   fundingApplication3.QuickSave1();
	   
	   Contact freshContact = new Contact();
	   freshContact.FirstName = 'Test Contact1';
	   freshContact.LastName = 'Test Contact1';
	   insert freshContact;
	   fundingApplication2.Owner1LastName = 'Test Contact1';
	   fundingApplication2.conForOwner1.FirstName = 'Test Contact1';
	   fundingApplication2.QuickSave1();
	   
	   fundingApplication2.Owner2LastName = 'Test Contact123';
	   fundingApplication2.conForOwner2.FirstName = 'Test Contact123';
	   fundingApplication2.QuickSave1();
	   
	   fundingApplication();
	  // pageRef.getParameters().put('oppId', opportunity2.Id);
      // pageRef.getParameters().put('id', accRecord.Id);
	   Test.stopTest();
	   
    }
    
    //Method will create dummy records of Account
    public static Account createAccountRecords(){
    	
        Account account = new Account(Name = 'Test Account2',
                                          Email__c='testacc@gmail.com',
                                          Phone = '02234557');   
        return account;
    }
    
    //Method will create dummy records of Contacts
    public static list<Contact> createContactRecords(Integer pCountOfContact){
    	
       List<Contact> conList = new List<Contact>();
       for(Integer intIndex = 0; intIndex < pCountOfContact; intIndex ++){
            
            Contact objCon = new Contact();
            objCon.FirstName = 'testOpp' + intIndex;
            objCon.LastName = 'testOppLast' + intIndex;
          
            conList.add(objCon);                       
        }//End for
        return conList; 
    }
    
    public static void fundingApplication(){
    	// Test.startTest();
    	//created a single record of account
       Account accRecord = FundingApplicationControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       
       Contact conRecord1 = new Contact(FirstName='TestFirst1', LastName='TestLast1', AccountId=accRecord.Id );
       insert conRecord1;
       
       Contact conRecord2 = new Contact(FirstName='TestFirst2', LastName='TestLast2', AccountId=accRecord.Id);
       insert conRecord2;
       
    	Opportunity opportunity = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent', 
                                          Owner_1__c = conRecord1.Id,
                                          Owner_2__c = conRecord2.Id,
                                          AccountId = accRecord.Id); 
        insert opportunity;
        
       
    	PageReference pageRef = Page.FundingApplication;
        pageRef.getParameters().put('oppId', opportunity.Id);
       	pageRef.getParameters().put('id', accRecord.Id);
       
       //Set Funding Application as Current Page
       test.setCurrentPageReference(pageRef);
       ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);
      
       //created instance of FundingApplicationController class
       FundingApplicationController fundingApplication = new FundingApplicationController(sc);
       fundingApplication.opportunity.Owner_1__c = conRecord1.Id;
	   conRecord1.Title = 'Testing Title';
	   update conRecord1;
	   fundingApplication.Owner1LastName = 'TestLast1';
	   fundingApplication.Owner2LastName = 'TestLast2';
	   fundingApplication.QuickSave1();
	   
	   fundingApplication.Owner1LastName = 'TestLast3';
	   fundingApplication.Owner2LastName = 'TestLast4';
        fundingApplication.QuickSave1();
       // Test.stopTest();
        
    }
}