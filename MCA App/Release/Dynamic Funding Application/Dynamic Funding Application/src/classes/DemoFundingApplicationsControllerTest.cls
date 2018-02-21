/* 
*  Apex controller Test Class for Dynamic FundingApplication Page using Field sets.
*  Revision History: 
* 
*  Version           Author                 Date                  Description 
*  1.0               Yogesh Mahajan         19-Jan 2016           Initial Draft 

*/


@isTest

private class DemoFundingApplicationsControllerTest {

    static testMethod void fundingApplicationTest() {
        List<Account> listAccountToInsert = createAccountRecords(2);
        insert listAccountToInsert;
        System.assertNotEquals(null, listAccountToInsert);
        
        List<Contact> listContactToInsert = createContactRecords(4, listAccountToInsert[0].Id);
        insert listContactToInsert;
        System.assertNotEquals(null, listContactToInsert);
        
        Test.startTest();
            List<Opportunity> listOppToInsert = createOpportunitiesRecords(1, listAccountToInsert[0].Id);
            insert listOppToInsert;
            System.assertNotEquals(null, listOppToInsert);
        Test.stopTest();
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting1 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting1.Name  = 'Section 1';
        objCustomSetting1.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_BUSINESS_INFORMATION';
        objCustomSetting1.MCAExtension1__Header_Name__c = 'BUSINESS INFORMATION';
        objCustomSetting1.MCAExtension1__Number_of_Column__c = 4;
        objCustomSetting1.MCAExtension1__Object_Type__c = 'Account';
        insert objCustomSetting1;
        System.assertNotEquals(null, objCustomSetting1);
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting2 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting2.Name  = 'Section 2';
        objCustomSetting2.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_OWNER_OFFICER_INFORMATION';
        objCustomSetting2.MCAExtension1__Header_Name__c = 'OWNER/OFFICER INFORMATION';
        objCustomSetting2.MCAExtension1__Number_of_Column__c = 4;
        objCustomSetting2.MCAExtension1__Object_Type__c = 'Contact';
        objCustomSetting2.MCAExtension1__Oppotunity_Contact_API_Name__c = 'McaApp__Owner_1__c';
        insert objCustomSetting2;
        System.assertNotEquals(null, objCustomSetting2);
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting3 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting3.Name  = 'Section 3';
        objCustomSetting3.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_2nd_OWNER_OFFICER_INFORMATION';
        objCustomSetting3.MCAExtension1__Header_Name__c = '2nd OWNER/OFFICER INFORMATION';
        objCustomSetting3.MCAExtension1__Number_of_Column__c = 3;
        objCustomSetting3.MCAExtension1__Object_Type__c = 'Contact';
        objCustomSetting3.MCAExtension1__Oppotunity_Contact_API_Name__c = 'McaApp__Owner_2__c';
        insert objCustomSetting3;
        System.assertNotEquals(null, objCustomSetting3);
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting4 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting4.Name  = 'Section 4';
        objCustomSetting4.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_BANK_TRADE_INFORMATION';
        objCustomSetting4.MCAExtension1__Header_Name__c = 'BANK/TRADE INFORMATION';
        objCustomSetting4.MCAExtension1__Number_of_Column__c = 3;
        objCustomSetting4.MCAExtension1__Object_Type__c = 'Account';
        insert objCustomSetting4;
        System.assertNotEquals(null, objCustomSetting4);
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting5 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting5.Name  = 'Section 5';
        objCustomSetting5.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_PROPERTY_INFORMATION';
        objCustomSetting5.MCAExtension1__Header_Name__c = 'PROPERTY INFORMATION';
        objCustomSetting5.MCAExtension1__Number_of_Column__c = 4;
        objCustomSetting5.MCAExtension1__Object_Type__c = 'Account';
        insert objCustomSetting5;
        System.assertNotEquals(null, objCustomSetting5);
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting7 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting7.Name  = 'Section 7';
        objCustomSetting7.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_OTHER_INFORMATION';
        objCustomSetting7.MCAExtension1__Header_Name__c = 'OTHER INFORMATION';
        objCustomSetting7.MCAExtension1__Number_of_Column__c = 4;
        objCustomSetting7.MCAExtension1__Object_Type__c = 'Account';
        insert objCustomSetting7;
        System.assertNotEquals(null, objCustomSetting7);
        
        listOppToInsert[0].McaApp__Owner_1__c = listContactToInsert[0].Id;
        listOppToInsert[0].McaApp__Owner_2__c = listContactToInsert[1].Id;
        update listOppToInsert[0];
        System.assertNotEquals(null, listOppToInsert[0]);
        
        ApexPages.currentPage().getParameters().put('oppId', listOppToInsert[0].Id);
        ApexPages.currentPage().getParameters().put('id', listAccountToInsert[0].Id);
        ApexPages.currentPage().getParameters().put('newApplication' ,'false');
        DemoFundingApplicationController controller = new DemoFundingApplicationController();
        
        controller.paramValue = 1;
        controller.listofPageData[controller.paramValue].selectedContact = '-None-' ;
        controller.listofPageData[controller.paramValue].selectedContact = 'New' ;
        
        controller.getOppValue();
        System.assertEquals(ApexPages.currentPage().getParameters().get('oppId'), string.valueOf(listOppToInsert[0].Id));
        
        controller.getContactVal(string.ValueOf(listContactToInsert[0].Id));
        controller.relatedContact();
        System.assertEquals(ApexPages.currentPage().getParameters().get('id'), listContactToInsert[0].AccountId);
        
        controller.getConatactOptions();
        controller.getCustomSettingVal();
        controller.changeOwner();
        controller.quickSave();
        controller.saveRecordBeforeBtnAction();
        controller.Save();
        controller.cancel();
        
        
    }//end fundingApplicationTest
    
    static testMethod void fundingApplicationInvalidTest() {
        List<Account> listAccountToInsert = createAccountRecords(2);
        insert listAccountToInsert;
        System.assertNotEquals(null, listAccountToInsert);
        
        List<Contact> listContactToInsert = createContactRecords(4, listAccountToInsert[0].Id);
        insert listContactToInsert;
        System.assertNotEquals(null, listContactToInsert);
        
        Test.startTest();
            List<Opportunity> listOppToInsert = createOpportunitiesRecords(200, listAccountToInsert[0].Id);
            insert listOppToInsert;
            System.assertNotEquals(null, listOppToInsert);
            listOppToInsert[0].McaApp__Owner_1__c = listContactToInsert[0].Id;
            listOppToInsert[0].McaApp__Owner_2__c = listContactToInsert[1].Id;
            update listOppToInsert[0];
        Test.stopTest();
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting1 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting1.Name  = 'Section 1';
        objCustomSetting1.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_BUSINESS_INFORMATION';
        objCustomSetting1.MCAExtension1__Header_Name__c = 'BUSINESS INFORMATION';
        objCustomSetting1.MCAExtension1__Number_of_Column__c = 4;
        objCustomSetting1.MCAExtension1__Object_Type__c = 'Account';
        insert objCustomSetting1;
        System.assertNotEquals(null, objCustomSetting1);
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting2 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting2.Name  = 'Section 2';
        objCustomSetting2.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_OWNER_OFFICER_INFORMATION';
        objCustomSetting2.MCAExtension1__Header_Name__c = 'OWNER/OFFICER INFORMATION';
        objCustomSetting2.MCAExtension1__Number_of_Column__c = 4;
        objCustomSetting2.MCAExtension1__Object_Type__c = 'Contact';
        objCustomSetting2.MCAExtension1__Oppotunity_Contact_API_Name__c = 'McaApp__Owner_1__c';
        insert objCustomSetting2;
        System.assertNotEquals(null, objCustomSetting2);
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting3 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting3.Name  = 'Section 3';
        objCustomSetting3.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_2nd_OWNER_OFFICER_INFORMATION';
        objCustomSetting3.MCAExtension1__Header_Name__c = '2nd OWNER/OFFICER INFORMATION';
        objCustomSetting3.MCAExtension1__Number_of_Column__c = 3;
        objCustomSetting3.MCAExtension1__Object_Type__c = 'Contact';
        objCustomSetting3.MCAExtension1__Oppotunity_Contact_API_Name__c = 'McaApp__Owner_2__c';
        insert objCustomSetting3;
        System.assertNotEquals(null, objCustomSetting3);
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting4 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting4.Name  = 'Section 4';
        objCustomSetting4.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_BANK_TRADE_INFORMATION';
        objCustomSetting4.MCAExtension1__Header_Name__c = 'BANK/TRADE INFORMATION';
        objCustomSetting4.MCAExtension1__Number_of_Column__c = 3;
        objCustomSetting4.MCAExtension1__Object_Type__c = 'Account';
        insert objCustomSetting4;
        System.assertNotEquals(null, objCustomSetting4);
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting5 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting5.Name  = 'Section 5';
        objCustomSetting5.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_PROPERTY_INFORMATION';
        objCustomSetting5.MCAExtension1__Header_Name__c = 'PROPERTY INFORMATION';
        objCustomSetting5.MCAExtension1__Number_of_Column__c = 4;
        objCustomSetting5.MCAExtension1__Object_Type__c = 'Account';
        insert objCustomSetting5;
        System.assertNotEquals(null, objCustomSetting5);
        
        MCAExtension1__Dynamic_Sections__c objCustomSetting7 = new MCAExtension1__Dynamic_Sections__c();
        objCustomSetting7.Name  = 'Section 7';
        objCustomSetting7.MCAExtension1__Field_Set_API_Name__c = 'MCAExtension1__ADDITIONAL_OTHER_INFORMATION';
        objCustomSetting7.MCAExtension1__Header_Name__c = 'OTHER INFORMATION';
        objCustomSetting7.MCAExtension1__Number_of_Column__c = 4;
        objCustomSetting7.MCAExtension1__Object_Type__c = 'Account';
        insert objCustomSetting7;
        System.assertNotEquals(null, objCustomSetting7);
        
        ApexPages.currentPage().getParameters().put('newApplication' ,'true');
        DemoFundingApplicationController controller = new DemoFundingApplicationController();
        controller.getCustomSettingVal(); 
        controller.paramValue = 1;
        controller.listofPageData[controller.paramValue].selectedContact = '-None-' ;
        controller.listofPageData[controller.paramValue].selectedContact = 'New' ;
        
        controller.getOppValue();
        controller.getContactVal(string.ValueOf(listContactToInsert[0].Id));
        controller.relatedContact();
        controller.getConatactOptions();
        //controller.getCustomSettingVal(); 
        controller.changeOwner();
        controller.quickSave();
        controller.Save();
        controller.cancel();
        controller.Save();
    }
    
    //create test data for account records
    public static List<Account> createAccountRecords(integer pCount) {
        List<Account> listAccount = new List<Account>();
        
        for(integer count= 0; count < = pCount; count++) {
            Account accInstance = new Account(Name = 'Test'+count,
                                            Phone = '9632587410');
            listAccount.add(accInstance);
        }
        
        return listAccount;
    }//end createAccountRecords
    
    //create test data for contact records
    public static List<Contact> createContactRecords(integer pCount, Id accountId) {
        List<Contact> listContact = new List<Contact>();
        for(integer count= 0; count< = pCount; count++) {
            Contact contInstance = new Contact(LastName = 'Test'+count,
                                AccountId = accountId,
                                Email = 'test'+count+'@gmail.com',
                                McaApp__Of_Ownership__c = 10);
            listContact.add(contInstance);
        }
        return listContact;
    }//end createContactRecords
    
    //create test data for Opportunity records
    public static List<Opportunity> createOpportunitiesRecords(integer pCount, Id accountId) {
        List<Opportunity> listOpp = new List<Opportunity>();
        for(integer count = 0; count <=pCount ; count++) {
            Opportunity opp = new Opportunity(Name='Test Opportunity',
                                             AccountId = accountId, 
                                             stageName = 'Open',
                                             closeDate = system.Today());
            listOpp.add(opp);
        }
        return listOpp;
    }//end createOpportunitiesRecords
}