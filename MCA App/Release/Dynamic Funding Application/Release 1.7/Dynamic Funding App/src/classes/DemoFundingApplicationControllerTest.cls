/* 
 *  
 *  Description -  Test Class for DynamicDemoFundingApplicationController1
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Yogesh Mahajan         04-Jan-2016          Initial Draft 

 */
@isTest
private class DemoFundingApplicationControllerTest  {
    
    
 
      
    //this method will test the save and quick save functionality used on Funding Application Page.
    static testMethod void DynamicFundingApplicationSaveAndQuickSaveTesting() {
       
       //created a single record of account
       Account accRecord = DemoFundingApplicationControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       System.assertNotEquals(null, accRecord);
       
       
       //created list of contract record
       List<Contact> conList = DemoFundingApplicationControllerTest.createContactRecords(2);
       insert conList; //contract list inserted 
       System.assertNotEquals(null, conList);
       
       //created a single opportunity record 
       Opportunity opportunity = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent', 
                                          McaApp__Owner_1__c = conList[0].Id,
                                          McaApp__Owner_2__c = conList[1].Id); 
       insert opportunity;
                                          
       Opportunity opportunity1 = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent', 
                                          McaApp__Owner_1__c = conList[0].Id ); 
       insert opportunity1; //opportunity list inserted
       
       Opportunity opportunity2 = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent', 
                                          McaApp__Owner_2__c = conList[0].Id ); 
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
            PageReference pageRef = Page.FundingApplication;
            pageRef.getParameters().put('oppId', opportunity.Id);
            pageRef.getParameters().put('id', accRecord.Id);
           
            //Set Funding Application as Current Page
            test.setCurrentPageReference(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);
            ApexPages.StandardController sc5 = new ApexPages.StandardController(opportunity);
            ApexPages.StandardController sc6 = new ApexPages.StandardController(opportunity5);
      
            //created instance of DemoFundingApplicationController class
            DemoFundingApplicationController fundingApplication = new DemoFundingApplicationController(sc);
            fundingApplication.opportunity.McaApp__Owner_1__c = conList[0].Id;
            
            fundingApplication.flag = true;
            fundingApplication.isError = false;
            fundingApplication.opportunity.McaApp__Owner_1__c = conList[0].Id;
            fundingApplication.opportunity.McaApp__Owner_2__c = conList[1].Id;
            
            
            conList[0].Title = 'Testing Title';
            update conlist[0];
            System.assertNotEquals(null, conlist[0].Id);
          
            fundingApplication.Owner1LastName = 'TestLast';
            fundingApplication.Owner2LastName = 'TestLast2';
          
            fundingApplication.Owner1FirstName = 'Testfrst1';
            fundingApplication.Owner2FirstName = 'Testfrst2';
            
          fundingApplication.getConatactOptions();
          fundingApplication.relatedContact();
          fundingApplication.objAccount = accRecord;
          fundingApplication.selectedContactOwner1 = conList[0].Id;
          fundingApplication.selectedContactOwner2 = conList[1].Id;
          fundingApplication.oppListToUpdate2ndOwnerOfficerInfo = opportunity;
          fundingApplication.oppListToUpdateOwnerOfficerInfo = opportunity1;
          fundingApplication.oppListToUpdateBankTradeInfo = opportunity2;
          fundingApplication.oppListToUpdatePropertyInfo = opportunity3;
          fundingApplication.oppListToUpdateOtherInfo = opportunity4;
          fundingApplication.oppListToUpdateBusiInfo = opportunity5;
          fundingApplication.Contacta = conList[0];
          fundingApplication.conForOwner1 = conList[0];
          fundingApplication.changeOwner1();
          fundingApplication.conForOwner2 = conList[1];
          fundingApplication.changeOwner2();
          
          fundingApplication.QuickSave1();
          fundingApplication.conForOwner2.McaApp__Drivers_License__c = 'sa!@';
          fundingApplication.conForOwner1.McaApp__Drivers_License__c = 'sa!@';
          fundingApplication.objAccount.McaApp__Federal_Tax_ID_No__c = '12@1';
          fundingApplication.objAccount.Website = 'asdf';
          fundingApplication.objAccount.Fax='12345678901';
          fundingApplication.objAccount.McaApp__Date_Business_Established__c = Date.Today().addDays(1);
          fundingApplication.conForOwner2.McaApp__Social_Security_Number1__c = '1234';
          fundingApplication.conForOwner2.McaApp__Of_Ownership__c = 111;
          fundingApplication.QuickSave1();
          
          
          fundingApplication.Save();    
       
        
       Contact con = [Select Id,Title from Contact where Id =: conList[0].Id];
       //system.assertEquals(con.Title, 'Testing Title');
       //fundingApplication.getConatactOptions();
       //fundingApplication.relatedContact();
       fundingApplication.openConga1();
       fundingApplication.cancel();
       fundingApplication.editPage();
       
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
       
       //created instance of DemoFundingApplicationController class
       DemoFundingApplicationController fundingApplication1= new DemoFundingApplicationController(sc1);
       fundingApplication.opportunity.McaApp__Owner_1__c = conList[0].Id;
       fundingApplication.opportunity.McaApp__Owner_2__c = conList[1].Id;
       
       Contact objContact = new Contact(FirstName='Test1', LastName='Test1',AccountId = accRecord.Id);
       insert objContact;
       fundingApplication.Owner2LastName = 'Test1';
       fundingApplication.conForOwner2.FirstName = 'Test1';
       fundingApplication.oldContactOwner2.add(objContact);
       //fundingApplication.QuickSave1();
       
       DemoFundingApplicationController fundingApplication2= new DemoFundingApplicationController(sc3);
       fundingApplication2.opportunity.McaApp__Owner_1__c = null;     
       Contact dupContact = new Contact();
       dupContact.FirstName = 'Test Contact';
       dupContact.LastName = 'Test Contact';
       insert dupContact;
       fundingApplication2.Owner1LastName = 'Test Contact';
       fundingApplication2.conForOwner1.FirstName = 'Test Contact';
       //fundingApplication2.QuickSave1();
       
       DemoFundingApplicationController fundingApplication3= new DemoFundingApplicationController(sc4);
       fundingApplication3.opportunity.McaApp__Owner_2__c = null;     
       Contact dupContact1 = new Contact();
       dupContact1.FirstName = 'Test Contact11';
       dupContact1.LastName = 'Test Contact11';
       insert dupContact1;
       fundingApplication3.Owner2LastName = 'Test Contact11';
       fundingApplication3.conForOwner2.FirstName = 'Test Contact11';
       //fundingApplication3.QuickSave1();
       
       Contact freshContact = new Contact();
       freshContact.FirstName = 'Test Contact1';
       freshContact.LastName = 'Test Contact1';
       insert freshContact;
       fundingApplication2.Owner1LastName = 'Test Contact1';
       fundingApplication2.conForOwner1.FirstName = 'Test Contact1';
      //fundingApplication2.QuickSave1();
       
       fundingApplication2.Owner2LastName = 'Test Contact123';
       fundingApplication2.conForOwner2.FirstName = 'Test Contact123';
       //fundingApplication2.QuickSave1();
       
       dynamicfundingApplication();
      // pageRef.getParameters().put('oppId', opportunity2.Id);
      // pageRef.getParameters().put('id', accRecord.Id);
      
     Test.stopTest();
     
     //Ripal
      //created instance of DemoFundingApplicationController class
    
       DemoFundingApplicationController fundingApplication5= new DemoFundingApplicationController(sc5);
       fundingApplication5.docuSign();
       fundingApplication5.cancel1();  
       fundingApplication5.SendCongaPDF1();
       fundingApplication5.submissionWizard1();
       //dynamicfundingApplication5.openConga1();
       fundingApplication5.docuSign1();
       fundingApplication5.getFieldsBusiInfo();
       fundingApplication5.getFieldsOwnerOfficerInfo();
       fundingApplication5.getFields2ndOwnerOfficerInfo();
       fundingApplication5.getFieldsBankTradeInfo();
       fundingApplication5.getFieldsPropertyInfo();
       fundingApplication5.getFieldsOtherInfo();
       fundingApplication5.init();       
       
       DemoFundingApplicationController fundingApplication6= 
            new DemoFundingApplicationController(sc6);
            
       pageRef.getParameters().put('oppId', opportunity4.Id);
       pageRef.getParameters().put('id', accRecord.Id);
       
    }
    
    
    
    //Method will create dummy records of Account
    public static Account createAccountRecords(){
        
        Account account = new Account(Name = 'Test Account2',
                                          McaApp__Email__c='testacc@gmail.com',
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
       Account accRecord = DemoFundingApplicationControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       
       Contact conRecord1 = new Contact(FirstName='TestFirst1', LastName='TestLast1', AccountId=accRecord.Id );
       insert conRecord1;
       
       Contact conRecord2 = new Contact(FirstName='TestFirst2', LastName='TestLast2', AccountId=accRecord.Id);
       insert conRecord2;
       
        Opportunity opportunity = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent', 
                                          McaApp__Owner_1__c = conRecord1.Id,
                                          McaApp__Owner_2__c = conRecord2.Id,
                                          AccountId = accRecord.Id); 
        insert opportunity;
        
       
        PageReference pageRef = Page.FundingApplication;
        pageRef.getParameters().put('oppId', opportunity.Id);
        pageRef.getParameters().put('id', accRecord.Id);
       
       //Set Funding Application as Current Page
       test.setCurrentPageReference(pageRef);
       ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);
      
       //created instance of DemoFundingApplicationController class
       DemoFundingApplicationController fundingApplication = new DemoFundingApplicationController(sc);
       fundingApplication.opportunity.McaApp__Owner_1__c = conRecord1.Id;
       conRecord1.Title = 'Testing Title';
       update conRecord1;
       fundingApplication.Owner1LastName = 'TestLast1';
       fundingApplication.Owner2LastName = 'TestLast2';
       //fundingApplication.QuickSave1();
       
       fundingApplication.Owner1LastName = 'TestLast3';
       fundingApplication.Owner2LastName = 'TestLast4';
       // fundingApplication.QuickSave1();
       // Test.stopTest();
        
    }
    
     public static void dynamicfundingAppNegativeTest(){
          //created a single record of account
       Account accRecord = DemoFundingApplicationControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       System.assertNotEquals(null, accRecord);
       
       accRecord.Website = 'http://www.google.com';
       update accRecord;
       System.assertNotEquals(null, accRecord.Id);
       
       //created list of contract record
       List<Contact> conList = DemoFundingApplicationControllerTest.createContactRecords(2);
       insert conList; //contract list inserted 
       System.assertNotEquals(null, conList);
       
       //created a single opportunity record 
       Opportunity opportunity = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent', 
                                          McaApp__Owner_1__c = conList[0].Id,
                                          McaApp__Owner_2__c = conList[1].Id,
                                          AccountId = accRecord.Id); 
       insert opportunity;
       System.assertNotEquals(null, opportunity.Id);                                   
       
       Test.startTest();
            PageReference pageRef = Page.FundingApplication;
            pageRef.getParameters().put('oppId', opportunity.Id);
            pageRef.getParameters().put('id', accRecord.Id);
           
            //Set Funding Application as Current Page
            test.setCurrentPageReference(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);
           
      
            //created instance of DemoFundingApplicationController class
            DemoFundingApplicationController fundingApplication = new DemoFundingApplicationController(sc);
            fundingApplication.flag = false;
            fundingApplication.isError = true;
            //accRecord.McaApp__Federal_Tax_ID_No__c = '12@1';
            accRecord.Website = 'asdf';
            //conList[0].McaApp__Social_Security_Number1__c = '1234';
            conList[0].McaApp__Drivers_License__c = 'sa!@';
            //fundingApplication.isError = true;
            fundingApplication.QuickSave1();
          fundingApplication.Save();    
       
     }
    
}