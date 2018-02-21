/**

 *  Description -  Test Class for FundingApplicationController
 *
 * Version     Author                      Date                 Description
 * 1.0         Neena Tiwari               04/18/2014            Initial Draft
 *                                                          
 */
    
@isTest
private class FundingApplicationControllerTest {
    
    //Method will create dummy records of Account
    public static Account createAccountRecords(){
        
        Account account = new Account(Name = 'Test Account2',
                                          Email__c='testacc@gmail.com',
                                          Phone = '9898989898');   
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
    
    
    //this method will test the save and quick save functionality used on Funding Application Page.
    static testMethod void FundingApplicationSaveAndQuickSaveTesting() {
       //created a single record of account
       Account accRecord = FundingApplicationControllerTest.createAccountRecords();
       insert accRecord; //account record inserted
       system.assertNotEquals(null, accRecord.Id);
       
       //created list of contract record
       List<Contact> conList = FundingApplicationControllerTest.createContactRecords(2);
       insert conList; //contract list inserted 
       system.assertNotEquals(null, conList);
       
       //created a single opportunity record 
        Opportunity opportunity = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent', 
                                          Owner_1__c = conList[0].Id,
                                          Owner_2__c = conList[1].Id); 
        insert opportunity;
        system.assertNotEquals(null, opportunity.Id);
        
        Opportunity opportunity1 = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Missing Info', 
                                          Owner_1__c = conList[0].Id ); 
        insert opportunity1; //opportunity list inserted
        system.assertNotEquals(null, opportunity1.Id);
        
        Opportunity opportunity2 = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent', 
                                          Owner_2__c = conList[0].Id ); 
        insert opportunity2;
        system.assertNotEquals(null, opportunity2.Id);
       
        Opportunity opportunity3 = new Opportunity(Name = 'Test Opp3', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent'
                                         ); 
        insert opportunity3; 
        system.assertNotEquals(null, opportunity3.Id);
      
        Opportunity opportunity4 = new Opportunity(Name = 'Test Opp3', 
                                          CloseDate = Date.today(),
                                          StageName = 'Application Sent'
                                         ); 
        insert opportunity4; 
        system.assertNotEquals(null, opportunity4.Id);
       
        Test.startTest();
        PageReference pageRef = Page.FundingApplication;
        pageRef.getParameters().put('oppId', opportunity.Id);
        pageRef.getParameters().put('id', accRecord.Id);
       
       //Set Funding Application as Current Page
       test.setCurrentPageReference(pageRef);
       ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);
      
       //created instance of FundingApplicationController class
        FundingApplicationController fundingApplication = new FundingApplicationController(sc);
        fundingApplication.flag = true;
        fundingApplication.isError = false;
        fundingApplication.opportunity.Owner_1__c = conList[0].Id;
        fundingApplication.opportunity.Owner_2__c = conList[1].Id;
        fundingApplication.opportunity.Application__c = true;
        conList[0].Title = 'Testing Title';
        conList[1].Title = 'Testing Title owner2';
        //update conlist;
        //system.assertNotEquals(null, conlist);
        fundingApplication.conForOwner1.LastName = 'TestLast';
        fundingApplication.conForOwner2.LastName = 'TestLast2';
        
        fundingApplication.changeOwner1();
        system.assertEquals('TestLast', fundingApplication.conForOwner1.LastName);
        
        fundingApplication.changeOwner2();
        system.assertEquals('TestLast2', fundingApplication.conForOwner2.LastName);
        
        fundingApplication.QuickSave1();
        fundingApplication.doSave();
        system.assertEquals(fundingApplication.conForOwner1.LastName, 'TestLast');
        
        
        /*
        Contact con = [Select Id,Title from Contact where Id =: conList[0].Id];
        system.assertEquals(con.Title, 'Testing Title');
        fundingApplication.doSave();
        system.assertEquals(con.Title, 'Testing Title');*/
        
        fundingApplication.cancel();
        fundingApplication.cancel1();
        fundingApplication.editPage();
        
        fundingApplication.SendCongaPDF1();
        fundingApplication.submissionWizard1();
        fundingApplication.openConga1();
        fundingApplication.relatedContact();
        fundingApplication.getConatactOptions();
        fundingApplication.docuSign();
        fundingApplication.docuSign1();
        fundingApplication.dateFieldValidation(system.Today(), '');
        fundingApplication.numberFieldValidation('' , '');
        system.debug('Opportunity1');
        pageRef.getParameters().put('oppId', opportunity1.Id);
        pageRef.getParameters().put('id', accRecord.Id);
        test.setCurrentPageReference(pageRef);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(opportunity1);
        
        system.debug('Opportunity2');
        pageRef.getParameters().put('oppId', opportunity2.Id);
        pageRef.getParameters().put('id', accRecord.Id);
        test.setCurrentPageReference(pageRef);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(opportunity2);
        
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
        FundingApplicationController fundingApplication1 = new FundingApplicationController(sc1);
        fundingApplication1.opportunity.Owner_1__c = conList[0].Id;
        fundingApplication1.opportunity.Owner_2__c = conList[1].Id;
        Contact objContact = new Contact(FirstName='Test1', LastName='Test1',AccountId = accRecord.Id);
        insert objContact;
        system.assertNotEquals(null, objContact.Id);
        
        fundingApplication.conForOwner2.LastName = 'Test1';
        fundingApplication.conForOwner2.FirstName = 'Test1';
        fundingApplication.oldContactOwner2.add(objContact);
        fundingApplication.QuickSave1();
        
        FundingApplicationController fundingApplication2 = new FundingApplicationController(sc3);
        fundingApplication2.opportunity.Owner_1__c = null;
        
        Contact dupContact = new Contact();
        dupContact.FirstName = 'Test Contact';
        dupContact.LastName = 'Test Contact';
        insert dupContact;
        fundingApplication2.conForOwner1.LastName = 'Test Contact';
        fundingApplication2.conForOwner1.FirstName = 'Test Contact';
        fundingApplication2.QuickSave1();
       
       FundingApplicationController fundingApplication3 = new FundingApplicationController(sc4);
       fundingApplication3.opportunity.Owner_2__c = null;
       Contact dupContact1 = new Contact();
       dupContact1.FirstName = 'Test Contact11';
       dupContact1.LastName = 'Test Contact11';
       insert dupContact1;
       fundingApplication3.conForOwner2.LastName = 'Test Contact11';
       fundingApplication3.conForOwner2.FirstName = 'Test Contact11';
       //fundingApplication3.QuickSave1();
       
       Contact freshContact = new Contact();
       freshContact.FirstName = 'Test Contact1';
       freshContact.LastName = 'Test Contact1';
       insert freshContact;
       fundingApplication2.conForOwner1.LastName = 'Test Contact1';
       fundingApplication2.conForOwner1.FirstName = 'Test Contact1';
       //fundingApplication2.QuickSave1();
       
       fundingApplication2.conForOwner2.LastName = 'Test Contact123';
       fundingApplication2.conForOwner2.FirstName = 'Test Contact123';
       //fundingApplication2.QuickSave1();
       
       fundingApplication();
      // pageRef.getParameters().put('oppId', opportunity2.Id);
      // pageRef.getParameters().put('id', accRecord.Id);
       Test.stopTest();
       
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
                                          StageName = 'Renewal Requested',
                                          Owner_1__c = conRecord1.Id,
                                          Owner_2__c = conRecord2.Id,
                                          AccountId = accRecord.Id); 
        insert opportunity;
        system.assertNotEquals(null, opportunity.Id);
       
        PageReference pageRef = Page.FundingApplication;
        pageRef.getParameters().put('oppId', opportunity.Id);
        pageRef.getParameters().put('id', accRecord.Id);
       
        //Set Funding Application as Current Page
        test.setCurrentPageReference(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);
      
        //created instance of FundingApplicationController class
        FundingApplicationController fundingApplication = new FundingApplicationController(sc);
        fundingApplication.opportunity.Owner_1__c = conRecord1.Id;
        fundingApplication.opportunity.Owner_2__c = conRecord2.Id;
        conRecord1.Title = 'Testing Title';
        update conRecord1;
        system.assertNotEquals(null, conRecord1.Id);
        update conRecord2;
        system.assertNotEquals(null, conRecord2.Id);
       
        fundingApplication.conForOwner1.LastName = 'TestLast1';
        fundingApplication.conForOwner2.LastName = 'TestLast2';
        fundingApplication.QuickSave1();
       
        fundingApplication.conForOwner1.LastName = 'TestLast3';
        fundingApplication.conForOwner2.LastName = 'TestLast4';
        fundingApplication.cancel();
        fundingApplication.cancel1();
        fundingApplication.editPage();
        fundingApplication.changeOwner1();
        fundingApplication.changeOwner2();
        fundingApplication.SendCongaPDF1();
        fundingApplication.submissionWizard1();
        fundingApplication.openConga1();
        fundingApplication.relatedContact();
        fundingApplication.getConatactOptions();
        fundingApplication.docuSign();
        fundingApplication.docuSign1();
        
    }
    
    public static void fundingApplicationNegativeTest() {
        Account accRecord = FundingApplicationControllerTest.createAccountRecords();
        insert accRecord; 
        system.assertNotEquals(null, accRecord.Id);
        
        Contact conRecord1 = new Contact(FirstName='TestFirst1', LastName='TestLast1', AccountId= accRecord.Id );
        insert conRecord1;
        system.assertNotEquals(null, conRecord1.Id);
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'TestOppo';
        opportunity.CloseDate = Date.today();
        opportunity.StageName = 'Renewal Requested';
        opportunity.AccountId = accRecord.Id;
        insert opportunity;
        system.assertNotEquals(null, opportunity.Id);
        
        Test.startTest();
            PageReference pageRef = Page.FundingApplication;
            pageRef.getParameters().put('oppId', opportunity.Id);
            pageRef.getParameters().put('id', accRecord.Id);
            test.setCurrentPageReference(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);
            
            FundingApplicationController fundingApplication = new FundingApplicationController(sc);
            fundingApplication.opportunity.Name = 'TestOpp';
            fundingApplication.opportunity.CloseDate = Date.today();
            fundingApplication.opportunity.StageName = 'Renewal Requested';
            fundingApplication.opportunity.AccountId = accRecord.Id;
            insert fundingApplication.opportunity;
            system.assertNotEquals(null, fundingApplication.opportunity.Id);
            
            try {
                fundingApplication.opportunity.Owner_1__c = conRecord1.Id;
                Contact cont = new Contact(FirstName='testContact', LastName = 'Test LastName');
                insert cont;
                fundingApplication.opportunity.Owner_2__c = cont.Id ;
                fundingApplication.opportunity.StageName = 'Declined';
                fundingApplication.FedralTaxId = 'accRecord.Id';
                fundingApplication.flag = true;
                fundingApplication.isError = false;
                fundingApplication.QuickSave1();
                fundingApplication.doSave();
                update fundingApplication.opportunity;
                system.assertEquals(conRecord1.Id, fundingApplication.opportunity.Owner_1__c);
                system.assertEquals(cont.Id, fundingApplication.opportunity.Owner_2__c);
            } catch(DMLException e) {
                system.assertEquals(e.getMessage(), e.getMessage());
            }
            
            
        Test.stopTest();
    }
}