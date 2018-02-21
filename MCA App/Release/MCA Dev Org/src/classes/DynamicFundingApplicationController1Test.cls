/* 
 *  
 *  Description -  Test Class for DynamicFundingApplicationController1
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Ripal Patel            13-July 2015           Initial Draft 

 */
@isTest
private class DynamicFundingApplicationController1Test {
	
	
 
      
    //this method will test the save and quick save functionality used on Funding Application Page.
    static testMethod void DynamicFundingApplicationSaveAndQuickSaveTesting() {
       //created a single record of account
       Account accRecord = DynamicFundingApplicationController1Test.createAccountRecords();
       insert accRecord; //account record inserted
       
       //created list of contract record
       List<Contact> conList = DynamicFundingApplicationController1Test.createContactRecords(2);
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
      
      Opportunity opportunity5 = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent'); 
        insert opportunity5;
       
       Test.startTest();
        PageReference pageRef = Page.DynamicFundingApplication1;
        pageRef.getParameters().put('oppId', opportunity.Id);
        pageRef.getParameters().put('id', accRecord.Id);
       
       //Set Funding Application as Current Page
       test.setCurrentPageReference(pageRef);
       ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);
        ApexPages.StandardController sc5 = new ApexPages.StandardController(opportunity);
        ApexPages.StandardController sc6 = new ApexPages.StandardController(opportunity5);
      
       //created instance of FundingApplicationController class
       DynamicFundingApplicationController1 dynamicfundingApplication = 
            new DynamicFundingApplicationController1(sc);
             dynamicfundingApplication.opportunity.Owner_1__c = conList[0].Id;
	   conList[0].Title = 'Testing Title';
	   update conlist[0];
	   dynamicfundingApplication.Owner1LastName = 'TestLast';
	   dynamicfundingApplication.Owner2LastName = 'TestLast2';
	   dynamicfundingApplication.QuickSave1();
	   
	   
	    
	   Contact con = [Select Id,Title from Contact where Id =: conList[0].Id];
	   system.assertEquals(con.Title, 'Testing Title');
	   dynamicfundingApplication.cancel();
	   dynamicfundingApplication.editPage();
	   dynamicfundingApplication.Save();
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
       DynamicFundingApplicationController1 dynamicfundingApplication1 = 
            new DynamicFundingApplicationController1(sc1);
             dynamicfundingApplication1.opportunity.Owner_1__c = conList[0].Id;
	   Contact objContact = new Contact(FirstName='Test1', LastName='Test1',AccountId = accRecord.Id);
	   insert objContact;
	   dynamicfundingApplication.Owner2LastName = 'Test1';
	   dynamicfundingApplication.conForOwner2.FirstName = 'Test1';
	   dynamicfundingApplication.oldContactOwner2.add(objContact);
	   dynamicfundingApplication.QuickSave1();
	   
	                                      
        
       
        DynamicFundingApplicationController1 dynamicfundingApplication2 = 
            new DynamicFundingApplicationController1(sc3);
       dynamicfundingApplication2.opportunity.Owner_1__c = null;     
	   Contact dupContact = new Contact();
	   dupContact.FirstName = 'Test Contact';
	   dupContact.LastName = 'Test Contact';
	   insert dupContact;
	   dynamicfundingApplication2.Owner1LastName = 'Test Contact';
	   dynamicfundingApplication2.conForOwner1.FirstName = 'Test Contact';
	   dynamicfundingApplication2.QuickSave1();
	   
	   DynamicFundingApplicationController1 dynamicfundingApplication3 = 
            new DynamicFundingApplicationController1(sc4);
       dynamicfundingApplication3.opportunity.Owner_2__c = null;     
	   Contact dupContact1 = new Contact();
	   dupContact1.FirstName = 'Test Contact11';
	   dupContact1.LastName = 'Test Contact11';
	   insert dupContact1;
	   dynamicfundingApplication3.Owner2LastName = 'Test Contact11';
	   dynamicfundingApplication3.conForOwner2.FirstName = 'Test Contact11';
	   dynamicfundingApplication3.QuickSave1();
	   
	   Contact freshContact = new Contact();
	   freshContact.FirstName = 'Test Contact1';
	   freshContact.LastName = 'Test Contact1';
	   insert freshContact;
	   dynamicfundingApplication2.Owner1LastName = 'Test Contact1';
	   dynamicfundingApplication2.conForOwner1.FirstName = 'Test Contact1';
	   dynamicfundingApplication2.QuickSave1();
	   
	   dynamicfundingApplication2.Owner2LastName = 'Test Contact123';
	   dynamicfundingApplication2.conForOwner2.FirstName = 'Test Contact123';
	   dynamicfundingApplication2.QuickSave1();
	   
	   dynamicfundingApplication();
	  // pageRef.getParameters().put('oppId', opportunity2.Id);
      // pageRef.getParameters().put('id', accRecord.Id);
      
     Test.stopTest();
     
     //Ripal
      //created instance of FundingApplicationController class
    
       DynamicFundingApplicationController1 dynamicfundingApplication5 = 
            new DynamicFundingApplicationController1(sc5);
       dynamicfundingApplication5.docuSign();
       dynamicfundingApplication5.cancel1();  
       dynamicfundingApplication5.SendCongaPDF1();
       dynamicfundingApplication5.submissionWizard1();
       //dynamicfundingApplication5.openConga1();
       dynamicfundingApplication5.docuSign1();
       dynamicfundingApplication5.getFieldsBusiInfo();
       dynamicfundingApplication5.getFieldsOwnerOfficerInfo();
       dynamicfundingApplication5.getFields2ndOwnerOfficerInfo();
       dynamicfundingApplication5.getFieldsBankTradeInfo();
       dynamicfundingApplication5.getFieldsPropertyInfo();
       dynamicfundingApplication5.getFieldsOtherInfo();
       dynamicfundingApplication5.init();       
       
       DynamicFundingApplicationController1 dynamicfundingApplication6 = 
            new DynamicFundingApplicationController1(sc6);
            
       pageRef.getParameters().put('oppId', opportunity4.Id);
       pageRef.getParameters().put('id', accRecord.Id);
	   
    }
    
    
    
    //Method will create dummy records of Account
    public static Account createAccountRecords(){
    	
        Account account = new Account(Name = 'Test Account2',
                                          Email__c='testacc@gmail.com',
                                          Phone = '9898989895');   
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
    
    public static void dynamicfundingApplication(){
    	// Test.startTest();
    	//created a single record of account
       Account accRecord = DynamicFundingApplicationController1Test.createAccountRecords();
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
        
       
    	PageReference pageRef = Page.DynamicFundingApplication1;
        pageRef.getParameters().put('oppId', opportunity.Id);
       	pageRef.getParameters().put('id', accRecord.Id);
       
       //Set Funding Application as Current Page
       test.setCurrentPageReference(pageRef);
       ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);
      
       //created instance of FundingApplicationController class
       DynamicFundingApplicationController1 dynamicfundingApplication = new DynamicFundingApplicationController1(sc);
       dynamicfundingApplication.opportunity.Owner_1__c = conRecord1.Id;
	   conRecord1.Title = 'Testing Title';
	   update conRecord1;
	   dynamicfundingApplication.Owner1LastName = 'TestLast1';
	   dynamicfundingApplication.Owner2LastName = 'TestLast2';
	   dynamicfundingApplication.QuickSave1();
	   
	   dynamicfundingApplication.Owner1LastName = 'TestLast3';
	   dynamicfundingApplication.Owner2LastName = 'TestLast4';
        dynamicfundingApplication.QuickSave1();
       // Test.stopTest();
        
    }
    
}