@isTest
private class MovingRenewalControllerTest {

    //test the methods explicitly
    static testMethod void testExplicitMethod() {
        
         PageReference pageRef = Page.ManageRenewal;
         test.setCurrentPage(pageRef);
         MovingRenewalController cntrllr = new MovingRenewalController();
         test.startTest();
            cntrllr.getUserList();
            cntrllr.getbaseUrlOrg();
         test.stopTest();
    }
    
    // test init method for wrapper list
    static testMethod void testOpportunityWrapperListList() {
        
         PageReference pageRef = Page.ManageRenewal;
         test.setCurrentPage(pageRef);
         MovingRenewalController cntrllr = new MovingRenewalController();
         
         List<Account> accountList = TestDataUtility.getAccountRecords(1);
         insert accountList;
         
         FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
         
         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }
         insert opportunityList;
          
         RenewalButtons__c objCustomSetting1 = new RenewalButtons__c(Name = 'Create Follow Up Task',
                                                                    Button_Accessibility__c=true);
         insert objCustomSetting1;
         RenewalButtons__c objCustomSetting2 = new RenewalButtons__c(Name = 'Create Renewal',
                                                                    Button_Accessibility__c=false);
         insert objCustomSetting2;
         RenewalButtons__c objCustomSetting3 = new RenewalButtons__c(Name = 'Delay Eligibility',
                                                                    Button_Accessibility__c=true);
         insert objCustomSetting3;
         RenewalButtons__c objCustomSetting4 = new RenewalButtons__c(Name = 'Mass Email',
                                                                    Button_Accessibility__c=true);
         insert objCustomSetting4;
         RenewalButtons__c objCustomSetting5 = new RenewalButtons__c(Name = 'Remove',
                                                                    Button_Accessibility__c=true);
         insert objCustomSetting5;
         
         test.startTest();
             cntrllr.Init();
         test.stopTest();
         system.assertEquals(opportunityList.size(), cntrllr.renewalWrapperLst.size());
    }
    
    // test apply Filter method1
    static testMethod void testApplyFilterMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' 
                                 and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;
        
        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
        insert cstmSetng;
        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
        for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }

         insert opportunityList;
         
         PageReference pageRef = Page.ManageRenewal;
         test.setCurrentPage(pageRef);
         MovingRenewalController cntrllr = new MovingRenewalController();
         cntrllr.Init();

         cntrllr.RenewalEligibilityPer = String.valueOf('1');
         cntrllr.renewalDateFunded = '1-3 Months Ago';
         cntrllr.renewalPaidPer = '1';
         cntrllr.oppFilter.Estimated_Renewal_Date__c = system.today();
         cntrllr.oppFilter.Bank_Name__c = accountList[0].Id;
         cntrllr.myDealsCheckbox = true;

         test.startTest();
             cntrllr.applyFilter();
         test.stopTest();
    }

    // test apply Filter method2
    static testMethod void testApplyFilterMethod2() {

         RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' 
                                  and DeveloperName ='Bank'];

         List<Account> accountList = TestDataUtility.getAccountRecords(1);
         accountList[0].RecordTypeId = RecType.Id;
         insert accountList;

         FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }

         insert opportunityList;
         
         PageReference pageRef = Page.ManageRenewal;
         test.setCurrentPage(pageRef);
         MovingRenewalController cntrllr = new MovingRenewalController();
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

         RecordType RecType = [Select Id From RecordType  
                                Where SobjectType = 'Account' and DeveloperName ='Bank'];

         List<Account> accountList = TestDataUtility.getAccountRecords(1);
         accountList[0].RecordTypeId = RecType.Id;
         insert accountList;
        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
        insert cstmSetng;

         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }

         insert opportunityList;
        
         PageReference pageRef = Page.ManageRenewal;
         test.setCurrentPage(pageRef);
         MovingRenewalController cntrllr = new MovingRenewalController();
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

        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }

         insert opportunityList;
         
         PageReference pageRef = Page.ManageRenewal;
         test.setCurrentPage(pageRef);
         MovingRenewalController cntrllr = new MovingRenewalController();
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

        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }

         insert opportunityList;
         
         PageReference pageRef = Page.ManageRenewal;
         test.setCurrentPage(pageRef);
         MovingRenewalController cntrllr = new MovingRenewalController();
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

        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
        }

        insert opportunityList;
        
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
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

        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
        }

        insert opportunityList;
        
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
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

        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
        }

        insert opportunityList;
        
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
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
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'stdt12', Email='standarduser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileObj.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='12standarduser@testorg.com');

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;
        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;

        Contact contact = new Contact(LastName = 'Test Contact', Email = 'Test@gmail.com');
        insert contact;
        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            //opportunityList[i].Owner_1__c = contact.Id;
            //opportunityList[i].OwnerId = userObj.Id;
        }

        insert opportunityList;
        OpportunityContactRole conRoleObj = TestDataUtility.getContactRoleRecord(contact.Id, opportunityList[0].Id);
        insert conRoleObj; 
               
      system.runAs(userObj) {
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
        cntrllr.Init();
        cntrllr.selectedUser = UserInfo.getUserId();
        
        for(MovingRenewalController.RenewalWrapper wrpperInsatnce : cntrllr.renewalWrapperLst /*Integer i = 0; i < 5; i++*/) {
            wrpperInsatnce.isSelected = true;
        }
        
        cntrllr.saveRemoveOpportunity();
            test.startTest();
                cntrllr.createOpportunity();
            test.stopTest();
      }
    }
    
    //test removeOpportunity method
    static testMethod void testRemoveOpportunityMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
        }

        insert opportunityList;
        
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
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

        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
        }

        insert opportunityList;
        
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
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

        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;

        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
        }

        insert opportunityList;
        
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
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
            MovingRenewalController.saveOpportBal(opportunityList[1].Id, '1000');
            MovingRenewalController.saveOpportBalDate(opportunityList[1].Id, String.valueOf(system.today()+10));
        test.stopTest();
    }
    
    // test massMailvalidation method if condition
    static testMethod void testmassMailvalidationIfMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        Contact contact = new Contact(LastName = 'Test Owner1' , Email = 'abc@gmail.com');
        insert contact;

        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
            //opportunityList[i].Owner_1__c= contact.Id;
        }
        insert opportunityList;
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'stdt12', Email='standarduser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileObj.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='12standarduser@testorg.com');
            
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
        cntrllr.Init();

        for(Integer i = 0; i < 3; i++) {
            cntrllr.renewalWrapperLst[i].isSelected = true;
        }
        //cntrllr.saveRemoveOpportunity();
        System.runAs(userObj) {
            test.startTest();
            cntrllr.massMailvalidation();
                //cntrllr.massEmailSend();
            test.stopTest();
        }
    }
    
    // test massMailvalidation method else condition
    static testMethod void testmassMailvalidationElseMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
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
            
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
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
        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
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
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
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
        System.runAs(userObj) {
            test.startTest();
                cntrllr.strBcc = 'a@gmail.com,b@gmail.com';
                cntrllr.strSubject = '{!Opportunity.Account}';
                cntrllr.strBody = '';
                cntrllr.showThankyouPageTask = false;
                cntrllr.displayMailPopUp = true;
            test.stopTest();
        }
    }
        
    // test taskDescription method in service class
    static testMethod void testTaskDescriptionMethod() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        Contact contact = new Contact(LastName = 'Test Owner1' , Email = 'abc@gmail.com');
        insert contact;
        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
            //opportunityList[i].Owner_1__c = contact.Id;
        }

        insert opportunityList; 
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'stdt12', Email='standarduser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileObj.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='12standarduser@testorg.com');
            
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
        MovingRenewalService serviceCls = new MovingRenewalService();
        serviceCls.emailBody = string.valueOf('Hello, This is fileBody sample. Thanks, Have a Good Day.');
        cntrllr.Init();
        system.runAs(userObj) {
            List<Document> docList = new List<Document>();
            docList = TestDataUtility.getDocumentRecords(1);
            docList[0].Name = 'Submission Email Logo';
            insert docList;
            test.startTest();
                //serviceCls.taskDescription(opportunityList[0], serviceCls.emailBody, userObj.Name, '');
            test.stopTest();
        }
    }
    // test taskDescription method in service class
    static testMethod void testOwnershipOfAccount() {

        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        Contact contact = new Contact(LastName = 'Test Owner1' , Email = 'abc@gmail.com');
        insert contact;
        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
        insert cstmSetng;
        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
            //opportunityList[i].Owner_1__c =contact.Id;
        }

        insert opportunityList; 
        PageReference pageRef = Page.ManageRenewal;
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
        
    }

    //method to test massMailvalidation method of controller class
    static testMethod void testMassMailvalidationMethod() {
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Contact> contactList = TestDataUtility.getContactRecords(2);
        contactList[0].Email = 'abc@gmail.com';
        insert contactList;
        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
        insert cstmSetng;
        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accountList[0].Id;
        }
        opportunityList[8].Owner_1__c = null;
        insert opportunityList; 
        
        List<Attachment> attachmentList = TestDataUtility.getattachmentRecords(3);
        for(Attachment attachmentObj : attachmentList){
            attachmentObj.parentId = opportunityList[0].Id;
        }
        insert attachmentList;
             
        MovingRenewalController controllerClass = new MovingRenewalController();
        controllerClass.init();
        for(MovingRenewalController.RenewalWrapper wrapprInstance : controllerClass.renewalWrapperLst)
        {
            wrapprInstance.isSelected = true;
        }
        
        Test.startTest();
            controllerClass.massMailvalidation();
            
        Test.stopTest();
    }

    // test renewal date updation
    static testMethod void testOpportunityUpdateRenewalDate() {
        
         PageReference pageRef = Page.ManageRenewal;
         test.setCurrentPage(pageRef);
         MovingRenewalController cntrllr = new MovingRenewalController();
         
         List<Account> accountList = TestDataUtility.getAccountRecords(1);
         insert accountList;
         FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
         List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(5);
         for(Integer i =0; i < opportunityList.size(); i++){
             opportunityList[i].StageName = 'Funded';
             opportunityList[i].Funded__c = true;
             opportunityList[i].Remove_from_Renewal_Management__c = false;
             opportunityList[i].Date_Funded__c = system.today()+ i;
         }
         
         insert opportunityList;
          
         RenewalButtons__c objCustomSetting1 = new RenewalButtons__c(Name = 'Create Follow Up Task',
                                                                    Button_Accessibility__c=true);
         insert objCustomSetting1;
         RenewalButtons__c objCustomSetting2 = new RenewalButtons__c(Name = 'Create Renewal',
                                                                    Button_Accessibility__c=false);
         insert objCustomSetting2;
         RenewalButtons__c objCustomSetting3 = new RenewalButtons__c(Name = 'Delay Eligibility',
                                                                    Button_Accessibility__c=true);
         insert objCustomSetting3;
         RenewalButtons__c objCustomSetting4 = new RenewalButtons__c(Name = 'Mass Email',
                                                                    Button_Accessibility__c=true);
         insert objCustomSetting4;
         RenewalButtons__c objCustomSetting5 = new RenewalButtons__c(Name = 'Remove',
                                                                    Button_Accessibility__c=true);
         insert objCustomSetting5;
         
         test.startTest();
             cntrllr.Init();
             for(Integer i =0; i < opportunityList.size(); i++){
                 cntrllr.holdSelectedMap.put(opportunityList[0].id,opportunityList[i]);
             }
             cntrllr.createOpportunity();
             MovingRenewalController.saveOpportRenewalDate(opportunityList[0].Id, null);
             MovingRenewalController.saveOpportRenewalDate(null, null);
             MovingRenewalController.saveOpportRenewalDate(opportunityList[0].Id, String.valueOf(System.today()+2));
         test.stopTest();
         system.assertEquals(opportunityList.size(), cntrllr.renewalWrapperLst.size());
    }
    
    static testMethod void testCreateTask() {
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accountList = TestDataUtility.getAccountRecords(1);
        accountList[0].RecordTypeId = RecType.Id;
        insert accountList;

        List<Contact> contactList = TestDataUtility.getContactRecords(2);
        contactList[0].Email = 'abc@gmail.com';
        insert contactList;
        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
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
        MovingRenewalController controllerClass = new MovingRenewalController();
        
        Test.startTest();
            controllerClass.createTaskAfterMailSent(opportunityList);
        Test.stopTest();
    }

    // test mass email functionality and popup with template preview
    static testMethod void testMassEmailAndPreview() {
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName ='Bank'];

        List<Account> accounts = TestDataUtility.getAccountRecords(1);
        accounts[0].RecordTypeId = RecType.Id;
        insert accounts;
        
        List<Contact> contactList = TestDataUtility.getContactRecords(1);
        contactList[0].AccountId = accounts[0].Id;
        contactList[0].Email = 'testEmail@email.com';
        insert contactList;
        FO_Renewal_Management__c  cstmSetng = createCustomSettingRecord();
         insert cstmSetng;
        List<Opportunity> opportunityList = TestDataUtility.getOpportunityRecords(10);
        for(Integer i =0; i < opportunityList.size(); i++){
            opportunityList[i].StageName = 'Funded';
            opportunityList[i].Funded__c = true;
            opportunityList[i].Remove_from_Renewal_Management__c = false;
            opportunityList[i].Date_Funded__c = system.today()+ i;
            opportunityList[i].AccountId = accounts[0].Id;
            //opportunityList[i].Owner_1__c= contactList[0].Id;
        }

        insert opportunityList;
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userObj = new User(Alias = 'stdt12', Email='standarduser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profileObj.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='12standarduser@testorg.com');
        PageReference pageRef = Page.ManageRenewal;
        List<EmailTemplate> eTemplate = [SELECT
                                            Id,
                                            Name,
                                            Subject,
                                            TemplateType,
                                            Body,
                                            HtmlValue
                                        FROM
                                            EmailTemplate
                                       WHERE
                                            isactive=true];
        test.setCurrentPage(pageRef);
        MovingRenewalController cntrllr = new MovingRenewalController();
        cntrllr.Init();

        for(Integer i = 0; i < 3; i++) {
            cntrllr.renewalWrapperLst[i].isSelected = true;
        }
        //cntrllr.saveRemoveOpportunity();
        System.runAs(userObj) {
            test.startTest();
            cntrllr.getselectedOppWithoutOwnerOREmail();
            MovingRenewalController.previewSelectedTemplate(eTemplate[0].Id, opportunityList[0].Id);
            cntrllr.massMailvalidation();
                //cntrllr.massEmailSend();
            for(EmailTemplate tmplate : eTemplate) {
                if(tmplate.TemplateType == 'Text') {
                    MovingRenewalController.previewSelectedTemplate(tmplate.Id, opportunityList[0].Id);
                    break;
                }
                if(tmplate.TemplateType == 'custom') {
                    MovingRenewalController.previewSelectedTemplate(tmplate.Id, opportunityList[0].Id);
                    break;
                }
            }
            cntrllr.massMailvalidation();
            test.stopTest();
        }
    }

    public static FO_Renewal_Management__c createCustomSettingRecord() {
        FO_Renewal_Management__c cstmSetting = new FO_Renewal_Management__c(
            Name = 'Renewal Management Display Opportunity',
            Field_Storing_Logic_to_Display_Opps__c = 'Display_on_Renewal_Management__c'
        );
        return cstmSetting;
    }
}