@isTest
private class NewRenewalTest {

    //test the methods explicitly
    static testMethod void testExplicitMethod() {
        
         PageReference pageRef = Page.ManageRenewDec;
         test.setCurrentPage(pageRef);
         MovingRenewal cntrllr = new MovingRenewal();
         test.startTest();
            cntrllr.getUserList();
            cntrllr.getbaseUrlOrg();
         test.stopTest();
    }
    
    // test init method for wrapper list
    static testMethod void testOpportunityWrapperListList() {
        
         PageReference pageRef = Page.ManageRenewDec;
         test.setCurrentPage(pageRef);
         MovingRenewal cntrllr = new MovingRenewal();
         
         List<Account> accountList = TestDataUtility.getAccountRecords(1);
         insert accountList;
         
         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }
         
         insert opportunityList;
          
         test.startTest();
             cntrllr.Init();
         test.stopTest();
         system.assertEquals(opportunityList.size(), cntrllr.renewalWrapperLst.size());
    }
    
    // test apply Filter method1
    static testMethod void testApplyFilterMethod() {

         RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

         List<Account> accountList = TestDataUtility.getAccountRecords(1);
         accountList[0].RecordTypeId = RecType.Id;
         insert accountList;

         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }

         insert opportunityList;

         PageReference pageRef = Page.ManageRenewDec;
         test.setCurrentPage(pageRef);
         MovingRenewal cntrllr = new MovingRenewal();
         cntrllr.Init();

         cntrllr.RenewalEligibilityPer = String.valueOf('1');
         cntrllr.renewalDateFunded = '1-3 Months Ago';
         cntrllr.oppFilter.Estimated_Renewal_Date__c = system.today();
         cntrllr.oppFilter.Bank_Name__c = accountList[0].Id;
         cntrllr.myDealsCheckbox = true;

         test.startTest();
             cntrllr.applyFilter();
         test.stopTest();
    }

    // test apply Filter method2
    static testMethod void testApplyFilterMethod2() {

         RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

         List<Account> accountList = TestDataUtility.getAccountRecords(1);
         accountList[0].RecordTypeId = RecType.Id;
         insert accountList;

         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }

         insert opportunityList;

         PageReference pageRef = Page.ManageRenewDec;
         test.setCurrentPage(pageRef);
         MovingRenewal cntrllr = new MovingRenewal();
         cntrllr.Init();

         cntrllr.RenewalEligibilityPer = String.valueOf('26');
         cntrllr.renewalDateFunded = '4-6 Months Ago';
         cntrllr.oppFilter.Estimated_Renewal_Date__c = system.today();
         cntrllr.oppFilter.Bank_Name__c = accountList[0].Id;
         cntrllr.myDealsCheckbox = true;
         cntrllr.isFirst = false;
         test.startTest();
             cntrllr.applyFilter();
         test.stopTest();
    }
    
    // test apply Filter method3
    static testMethod void testApplyFilterMethod3() {

         RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

         List<Account> accountList = TestDataUtility.getAccountRecords(1);
         accountList[0].RecordTypeId = RecType.Id;
         insert accountList;

         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }

         insert opportunityList;

         PageReference pageRef = Page.ManageRenewDec;
         test.setCurrentPage(pageRef);
         MovingRenewal cntrllr = new MovingRenewal();
         cntrllr.Init();

         cntrllr.RenewalEligibilityPer = String.valueOf('51');
         cntrllr.renewalDateFunded = '7-9 Months Ago';
         cntrllr.oppFilter.Estimated_Renewal_Date__c = system.today();
         cntrllr.oppFilter.Bank_Name__c = accountList[0].Id;
         cntrllr.myDealsCheckbox = true;
         cntrllr.isFirst = false;
         test.startTest();
             cntrllr.applyFilter();
         test.stopTest();
    }
    
    // test apply Filter method4
    static testMethod void testApplyFilterMethod4() {

         RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

         List<Account> accountList = TestDataUtility.getAccountRecords(1);
         accountList[0].RecordTypeId = RecType.Id;
         insert accountList;

         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }

         insert opportunityList;

         PageReference pageRef = Page.ManageRenewDec;
         test.setCurrentPage(pageRef);
         MovingRenewal cntrllr = new MovingRenewal();
         cntrllr.Init();

         cntrllr.RenewalEligibilityPer = String.valueOf('76');
         cntrllr.renewalDateFunded = '10-12 Months ago';
         cntrllr.oppFilter.Estimated_Renewal_Date__c = system.today();
         cntrllr.oppFilter.Bank_Name__c = accountList[0].Id;
         cntrllr.myDealsCheckbox = true;
         cntrllr.isFirst = false;
         test.startTest();
             cntrllr.applyFilter();
         test.stopTest();
    }

    // test apply Filter method4
    static testMethod void testApplyFilterMethod5() {

         RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

         List<Account> accountList = TestDataUtility.getAccountRecords(1);
         accountList[0].RecordTypeId = RecType.Id;
         insert accountList;

         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }

         insert opportunityList;

         PageReference pageRef = Page.ManageRenewDec;
         test.setCurrentPage(pageRef);
         MovingRenewal cntrllr = new MovingRenewal();
         cntrllr.Init();

         cntrllr.RenewalEligibilityPer = String.valueOf('1');
         cntrllr.renewalDateFunded = '12+ Months';
         cntrllr.oppFilter.Estimated_Renewal_Date__c = system.today();
         cntrllr.oppFilter.Bank_Name__c = accountList[0].Id;
         cntrllr.myDealsCheckbox = true;
         cntrllr.isFirst = false;
         test.startTest();
             cntrllr.applyFilter();
         test.stopTest();
    }
    
    // test generic search method
    static testMethod void testGenericSearchMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
        }

        insert opportunityList;

        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        cntrllr.Init();

        cntrllr.RenewalEligibilityPer = String.valueOf('26');
        cntrllr.renewalDateFunded = '4-6 Months Ago';
        cntrllr.oppFilter.Estimated_Renewal_Date__c = system.today();
        cntrllr.oppFilter.Bank_Name__c = accountList[0].Id;
        cntrllr.myDealsCheckbox = true;
        cntrllr.isFirst = false;
        for(Integer i = 0; i < 3; i++) {
            cntrllr.renewalWrapperLst[i].isSelected = true;
        }
        cntrllr.saveRemoveOpportunity();
        test.startTest();
            cntrllr.callOnSort();
            cntrllr.callOnFilter();
            cntrllr.clearFilter();
            cntrllr.genericSearch();
            cntrllr.CloseUserPopup();
            cntrllr.assignOwner();
            cntrllr.deselectOpportunity();
            cntrllr.pagingDetails();
            cntrllr.callNext();
            cntrllr.callFirst();
            cntrllr.limitQuery= 1;
            cntrllr.callLast();
            cntrllr.callPrevious();
            cntrllr.uploadFile();
        test.stopTest();
    }
    
    static testMethod void testDelayOpportunityMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
        }

        insert opportunityList;

        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        cntrllr.Init();
        for(Integer i = 0; i < 3; i++) {
            cntrllr.renewalWrapperLst[i].isSelected = true;
        }
        cntrllr.saveRemoveOpportunity();
        test.startTest();
            cntrllr.delayOpportunity();
            cntrllr.deselectOpportunity();
        test.stopTest();
    }
    
    static testMethod void testDelayDurationMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
        }

        insert opportunityList;

        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        cntrllr.Init();
        cntrllr.DelayTime = '1';
        for(Integer i = 0; i < 3; i++) {
            cntrllr.renewalWrapperLst[i].isSelected = true;
        }
        cntrllr.saveRemoveOpportunity();
        test.startTest();
            cntrllr.delayDuration();
        test.stopTest();
    }
    
    //test createOpportunity method
    static testMethod void testCreateOpportunityMethod() {
       /* Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'stdt12', Email='standarduser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileObj.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='12standarduser@testorg.com');*/
        
        system.debug('>>> testing create method : ');
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Contact> contactList = TestDataUtility.getContactRecords(2);
        contactList[0].Email = 'abc@gmail.com';
        insert contactList;
        
        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].Owner_1__c = contactList[0].Id;
            //opportunityList[i].OwnerId = userObj.Id;
        }

        insert opportunityList;
        
        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        cntrllr.Init();
        //cntrllr.selectedUser = userObj.Name;
       // system.runAs(userObj) {
        for(MovingRenewal.RenewalWrapper wrpperInsatnce : cntrllr.renewalWrapperLst /*Integer i = 0; i < 5; i++*/) {
            wrpperInsatnce.isSelected = true;
        }
        
        cntrllr.saveRemoveOpportunity();
         system.debug('>>> start test');
            test.startTest();
                cntrllr.createOpportunity();
            test.stopTest();
        //}
    }
    
    //test removeOpportunity method
    static testMethod void testRemoveOpportunityMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
        }

        insert opportunityList;

        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        cntrllr.Init();
        for(Integer i = 0; i < 3; i++) {
            cntrllr.renewalWrapperLst[i].isSelected = true;
        }
        cntrllr.saveRemoveOpportunity();
        test.startTest();
            cntrllr.removeOpportunity();
        test.stopTest();
    }
    
    //test createFollowupTask method
    static testMethod void testCreateFollowupTaskMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
        }

        insert opportunityList;

        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        cntrllr.Init();
        for(Integer i = 0; i < 3; i++) {
            cntrllr.renewalWrapperLst[i].isSelected = true;
        }
        cntrllr.saveRemoveOpportunity();
        test.startTest();
            cntrllr.assignOwnerTask();
            cntrllr.createFollowupTask();
        test.stopTest();
    }
    
    // test generic Test method
    static testMethod void testSendEmailRelatedMethods() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
        }

        insert opportunityList;

        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        cntrllr.Init();

        for(Integer i = 0; i < 3; i++) {
            cntrllr.renewalWrapperLst[i].isSelected = true;
        }
        cntrllr.saveRemoveOpportunity();
        
        test.startTest();
            cntrllr.getAttachments();
            cntrllr.cancelTemplate();
            cntrllr.removeAttachment();
            cntrllr.attachFile();
            cntrllr.displayMessageBodyContent();
            MovingRenewal.saveOpportBal(opportunityList[1].Id, '1000');
            MovingRenewal.saveOpportBalDate(opportunityList[1].Id, String.valueOf(system.today()+10));
        test.stopTest();
    }
    
    // test massMailvalidation method if condition
    static testMethod void testmassMailvalidationIfMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
        }

        insert opportunityList;

        Submission_Mails_Detail__c mailObj = new Submission_Mails_Detail__c();
        mailObj.Is_Active__c = true;
        mailObj.Message_Body__c = 'mailBody';
        mailObj.Subject__c = 'TestMail';
        mailObj.CC_Address__c = 'abcTest@gmail.com';
        mailObj.Bcc_Address__c = 'xyzTest@gmail.com';
        mailObj.Name = 'Renewal Email';
                                                                            
        insert mailObj;

        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'stdt12', Email='standarduser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileObj.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='12standarduser@testorg.com');
            
        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        cntrllr.Init();

        for(Integer i = 0; i < 3; i++) {
            cntrllr.renewalWrapperLst[i].isSelected = true;
        }
        cntrllr.saveRemoveOpportunity();
        
        System.runAs(userObj) {
            test.startTest();
                cntrllr.massMailvalidation();
            test.stopTest();
        }
    }
    
    // test massMailvalidation method else condition
    static testMethod void testmassMailvalidationElseMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
        }

        insert opportunityList;
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'stdt12', Email='standarduser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileObj.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='12standarduser@testorg.com');
            
        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        cntrllr.Init();
        System.runAs(userObj) {
            test.startTest();
                cntrllr.massMailvalidation();
            test.stopTest();
        }
    }
    
    //test sendAnEmail method
    static testMethod void testsendAnEmailMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Contact> contactList = TestDataUtility.getContactRecords(2);
        contactList[0].Email = 'abc@gmail.com';
        insert contactList;
        
        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
            //opportunityList[i].Owner_1__c = contactList[0].Id;
        }

        insert opportunityList;

        Submission_Mails_Detail__c mailObj = new Submission_Mails_Detail__c();
        mailObj.Is_Active__c = true;
        mailObj.Message_Body__c = 'mailBody';
        mailObj.Subject__c = 'TestMail';
        mailObj.CC_Address__c = 'abcTest@gmail.com';
        mailObj.Bcc_Address__c = 'xyzTest@gmail.com';
        mailObj.Name = 'Renewal Email';
                                                                            
        insert mailObj;
        
        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        cntrllr.Init();
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'stdt12', Email='standarduser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileObj.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='12standarduser@testorg.com');
       
        cntrllr.Init();
        cntrllr.fileBody = blob.valueOf('FileBody sample');
        cntrllr.fileName = 'testFileName';
        for(Integer i = 0; i < 3; i++) {
            cntrllr.renewalWrapperLst[i].isSelected = true;
        }
        cntrllr.saveRemoveOpportunity();
        cntrllr.uploadFile();
        //cntrllr.showThankyouPageTask = false;
        //cntrllr.displayMailPopUp = true;
        System.runAs(userObj) {
            test.startTest();
                cntrllr.strBcc = 'a@gmail.com, b@gmail.com';
                cntrllr.strSubject = '{Account Name}';
                cntrllr.sendAnEmail();
                cntrllr.showThankyouPageTask = false;
                cntrllr.displayMailPopUp = true;
                cntrllr.sendAnEmail();
                
            test.stopTest();
        }
    }
    
    // test messageBodyContent method in service class
    static testMethod void testMessageBodyContentMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Contact> contactList = TestDataUtility.getContactRecords(2);
        contactList[0].Email = 'abc@gmail.com';
        insert contactList;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
        }

        insert opportunityList;
        
        List<Document> documentList = TestDataUtility.getDocumentRecords(3);
        documentList[0].Name = 'Submission Email Logo';
        insert documentList;

        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'stdt12', Email='standarduser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileObj.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='12standarduser@testorg.com');
            
        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        MovingRenewalService serviceCls = new MovingRenewalService();
        
        serviceCls.emailBody = string.valueOf('Hello, This is fileBody sample. Thanks, Have a Good Day.');
        cntrllr.Init();
        system.runAs(userObj) {
            test.startTest();
                serviceCls.setBody(opportunityList[0], serviceCls.emailBody, userObj.Name, '');
                serviceCls.messageBodyContent(contactList[0].Name, serviceCls.emailBody, userObj.Name, '');
            test.stopTest();
        }
    }
    
    // test taskDescription method in service class
    static testMethod void testTaskDescriptionMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Contact> contactList = TestDataUtility.getContactRecords(2);
        contactList[0].Email = 'abc@gmail.com';
        insert contactList;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
            opportunityList[i].Owner_1__c = contactList[0].Id;
        }

        insert opportunityList;
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'stdt12', Email='standarduser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileObj.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='12standarduser@testorg.com');
            
        PageReference pageRef = Page.ManageRenewDec;
        test.setCurrentPage(pageRef);
        MovingRenewal cntrllr = new MovingRenewal();
        MovingRenewalService serviceCls = new MovingRenewalService();
        serviceCls.emailBody = string.valueOf('Hello, This is fileBody sample. Thanks, Have a Good Day.');
        cntrllr.Init();
        system.runAs(userObj) {
            test.startTest();
                serviceCls.taskDescription(opportunityList[0], serviceCls.emailBody, userObj.Name, '');
            test.stopTest();
        }
    }
}