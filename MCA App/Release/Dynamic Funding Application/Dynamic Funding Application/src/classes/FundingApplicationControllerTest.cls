/* 
 *  
 *  Description -  Test Class for DynamicFundingApplicationController1
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Ripal Patel            13-July 2015           Initial Draft 

 */
@isTest
private class FundingApplicationControllerTest  {

    //this method will test the save and quick save functionality used on Funding Application Page.
    static testMethod void newDynamicFundingApplicationValidTesting() {
       
        //created a single record of account
        Account accRecord = FundingApplicationControllerTest.createAccountRecords();
        insert accRecord; //account record inserted
        System.assertNotEquals(null, accRecord);

        //created list of contract record
        List<Contact> conListToInsert = createContactRecords(2, accRecord.Id);
        insert conListToInsert; //contract list inserted 
        System.assertNotEquals(null, conListToInsert);
       
       //created a single opportunity record 
        Opportunity opportunity = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          AccountId = accRecord.Id,
                                          StageName = 'Application Sent', 
                                          McaApp__Owner_1__c = conListToInsert[0].Id,
                                          McaApp__Owner_2__c = conListToInsert[1].Id); 
        insert opportunity;
        system.assertNotEquals(null, opportunity.Id);

        List<MCAExtension1__Dynamic_Sections__c> lstDyanamicSetting = 
        new List<MCAExtension1__Dynamic_Sections__c>();
        lstDyanamicSetting.add(FundingApplicationControllerTest.createDynamicSettingRecord('Section 1','Account',
        'BUSINESS INFORMATION','MCAExtension1__ADDITIONAL_BUSINESS_INFORMATION', 4, 1,''));
         
         lstDyanamicSetting.add(FundingApplicationControllerTest.createDynamicSettingRecord('Section 2','Contact',
        'OWNER/OFFICER INFORMATION','MCAExtension1__ADDITIONAL_OWNER_OFFICER_INFORMATION',4, 2, 'McaApp__Owner_1__c'));

        insert lstDyanamicSetting;
        
        ApexPages.currentPage().getParameters().put('newApplication', 'true');
        //ApexPages.currentPage().getParameters().put('accountName', 'TestAccount');
        ApexPages.currentPage().getParameters().put('rURL','https%3A%2F%2Fmcaextension1.ap2.visual.'
                     + 'force.com%2Fapex%2FFundingApplicationAddedIntoScrollBar%3FautoMapValues%3D1');
        FundingApplicationController controllerInstance = new FundingApplicationController();
        
        controllerInstance.saveRecordBeforeBtnAction();
        controllerInstance.save();
        
    }//end newDynamicFundingApplicationValidTesting

    //this method will test the save and quick save functionality used on Funding Application Page.
    static testMethod void oldDynamicFundingApplicationValidTesting() {
       
        //created a single record of account
        Account accRecord = FundingApplicationControllerTest.createAccountRecords();
        insert accRecord; //account record inserted
        System.assertNotEquals(null, accRecord);

        //created list of contract record
        List<Contact> conList = FundingApplicationControllerTest.createContactRecords(2, accRecord.Id);
        insert conList; //contract list inserted 
        System.assertNotEquals(null, conList);
       
       //created a single opportunity record 
        Opportunity opportunity = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          AccountId = accRecord.Id,
                                          StageName = 'Application Sent', 
                                          McaApp__Owner_1__c = conList[0].Id,
                                          McaApp__Owner_2__c = conList[1].Id); 
        insert opportunity;
        system.assertNotEquals(null, opportunity.Id);

        List<MCAExtension1__Dynamic_Sections__c> lstDyanamicSetting = 
        new List<MCAExtension1__Dynamic_Sections__c>();
        lstDyanamicSetting.add(FundingApplicationControllerTest.createDynamicSettingRecord('Section 1','Account',
        'BUSINESS INFORMATION','MCAExtension1__ADDITIONAL_BUSINESS_INFORMATION', 4, 1,''));
         
         lstDyanamicSetting.add(FundingApplicationControllerTest.createDynamicSettingRecord('Section 2','Contact',
        'OWNER/OFFICER INFORMATION','MCAExtension1__ADDITIONAL_OWNER_OFFICER_INFORMATION',4, 2, 'McaApp__Owner_1__c'));

        insert lstDyanamicSetting;
        //System.assertNotEquals(null, objCustomSetting.Id);
        ApexPages.currentPage().getParameters().put('id' , opportunity.Id);
        ApexPages.currentPage().getParameters().put('accId' , accRecord.Id);
        ApexPages.currentPage().getParameters().put('accountName' , accRecord.Name);
        ApexPages.currentPage().getParameters().put('newApplication', 'false');
        //ApexPages.currentPage().getParameters().put('rURL','https%3A%2F%2Fmcaextension1.ap2.visual.'
        //             + 'force.com%2Fapex%2FFundingApplicationAddedIntoScrollBar%3FautoMapValues%3D1');
        FundingApplicationController controllerInstance = new FundingApplicationController();
        controllerInstance.checkNull(accRecord.Name);
        controllerInstance.getConatactOptions();
        controllerInstance.getOppValue();
        controllerInstance.getContactVal(String.valueOf(conList[0].Id));
        controllerInstance.relatedContact();
        controllerInstance.listofPageData[0].selectedContact = conList[0].Id;
        controllerInstance.saveRecordBeforeBtnAction();
        controllerInstance.save();
        controllerInstance.paramValue = 1;
        controllerInstance.changeOwner();
        controllerInstance.listofPageData[0].selectedContact = 'New';
        controllerInstance.changeOwner();
        
        controllerInstance.cancel();
    }//end oldDynamicFundingApplicationValidTesting
    
     static testMethod void dynamicFundingApplicationInValidTesting() {
         //created a single record of account
        Account accRecord = FundingApplicationControllerTest.createAccountRecords();
        insert accRecord; //account record inserted
        System.assertNotEquals(null, accRecord);

        //created list of contract record
        /*List<Contact> conList = FundingApplicationControllerTest.createContactRecords(2, accRecord.Id);
        insert conList; //contract list inserted 
        System.assertNotEquals(null, conList);*/
       
       //created a single opportunity record 
        Opportunity opportunity = new Opportunity(Name = 'Test Opp1', 
                                          CloseDate = Date.today(),
                                          AccountId = accRecord.Id,
                                          StageName = 'Application Sent' );
                                          //McaApp__Owner_1__c = conList[0].Id,
                                          //McaApp__Owner_2__c = conList[1].Id); 
        insert opportunity;
        system.assertNotEquals(null, opportunity.Id);
        
        ApexPages.currentPage().getParameters().put('id' , opportunity.Id);
        ApexPages.currentPage().getParameters().put('accId' , accRecord.Id);
        //ApexPages.currentPage().getParameters().put('accountName' , accRecord.Name);
        ApexPages.currentPage().getParameters().put('newApplication', 'false');
        //ApexPages.currentPage().getParameters().put('rURL','https%3A%2F%2Fmcaextension1.ap2.visual.'
        //             + 'force.com%2Fapex%2FFundingApplicationAddedIntoScrollBar%3FautoMapValues%3D1');
        FundingApplicationController controllerInstance = new FundingApplicationController();
        controllerInstance.getCustomSettingVal();
        controllerInstance.saveRecordBeforeBtnAction();
        controllerInstance.save();
     }
    
    //Method will create dummy records of Account
    public static Account createAccountRecords(){
        
        Account account = new Account(Name = 'Test Account2',
                                      McaApp__Email__c='testacc@gmail.com',
                                      Phone = '9898989895');   
        return account;
    }//end createAccountRecords

    //Method will create dummy records of Contacts
    public static list<Contact> createContactRecords(Integer pCountOfContact, Id AccId) {
        
       List<Contact> conList = new List<Contact>();
       for(Integer intIndex = 0; intIndex < pCountOfContact; intIndex ++){
            
            Contact objCon = new Contact();
            objCon.AccountId = AccId;
            objCon.FirstName = 'testCon' + intIndex;
            objCon.LastName = 'testonLast' + intIndex;

            conList.add(objCon);
        }//End for
        return conList; 
    }//end createContactRecords

    //Method will create dummy records of Contacts
    public static MCAExtension1__Dynamic_Sections__c createDynamicSettingRecord(String section,
     string objectName, String header, String fieldSetName, Integer numbColumn, Integer sortValue,
     string contactAPI){
        MCAExtension1__Dynamic_Sections__c objCustomSetting = new Dynamic_Sections__c();
        objCustomSetting.Name = section;
        objCustomSetting.Object_Type__c = objectName;
        objCustomSetting.Header_Name__c = header;
        objCustomSetting.Field_Set_API_Name__c = fieldSetName;
        objCustomSetting.Number_of_Column__c = numbColumn;
        objCustomSetting.Sort__c = sortValue;
        if(contactAPI <> '')
            objCustomSetting.Oppotunity_Contact_API_Name__c = contactAPI;
        return objCustomSetting;
    }//end createDynamicSettingRecord
}