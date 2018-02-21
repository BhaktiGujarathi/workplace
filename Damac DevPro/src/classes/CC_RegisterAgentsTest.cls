@isTest
private class CC_RegisterAgentsTest {
    
    @isTest static void ccAgentRegistered() {
    
    
    List<Account_SR_Field_Mapping__c> lstAccSRFldMapping = new List<Account_SR_Field_Mapping__c>();
    lstAccSRFldMapping.add(new Account_SR_Field_Mapping__c(name = '1',Account_Field__c = 'Firstname',SR_Field__c='First_Name__c',Is_Person_Account__c = true));
    lstAccSRFldMapping.add(new Account_SR_Field_Mapping__c(name = '2',Account_Field__c = 'lastname',SR_Field__c='Last_Name__c',Is_Person_Account__c = true));
    lstAccSRFldMapping.add(new Account_SR_Field_Mapping__c(name = '3',Account_Field__c = 'name',SR_Field__c='Last_Name__c',Is_Person_Account__c = false));
       insert lstAccSRFldMapping;
       
       Account newAcc ;
       List<Account> accList = new List<Account>();
       for(Integer i=0;i<10;i++){
           
           newAcc = new Account();
           newAcc.name = 'TestCCReg' + i;
           accList.add(newAcc);
           
       }
       insert accList;
       Contact newCon;
       List<Contact>conList = new List<Contact>();
       for(Integer i=0;i<accList.Size();i++){
           newCon = new Contact();
           newCon.FirstName = 'FirstName' + i;
           newCon.LastName = 'LastName' + i;
           newCon.Email = 'TestCCReg' + i + '@gmail.com';
           newCon.Accountid = accList[i].Id;
           conList.add(newCon);
       }
       insert conList;
       Map<id,contact> mpContact = new Map<id,contact>();
        for(contact cnct : conlist){
            mpContact.put(cnct.id,cnct);
        }
        Id accRecordTypeId   = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account agency1 = InitialiseTestData.getCorporateAccount('Agency125');
        
        insert agency1; 
        
        Account acc = new Account();
        acc.lastname = 'ltest';
        acc.RecordTypeId = accRecordTypeId ;
        acc.Blacklisted__c = true ;
        acc.Reason_for_Blacklisting__c = 'Agency Blacklisting unit test';
        insert acc ;
        
        Contact newCont = new Contact();
        newCon.FirstName = 'Test';
        newCont.LastName = 'Agency125';
        newCont.AccountId = agency1.Id ;
        insert newCont ; 
        
       
        NSIBPM__SR_Steps__c srStep= new NSIBPM__SR_Steps__c();
        insert srStep;
        
        List<NSIBPM__Status__c> createStatus = new List<NSIBPM__Status__c>();
        createStatus = InitialiseTestData.createStatusRecords(
                new List<NSIBPM__Status__c>{
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_ADDITIONAL_INFO', Name = 'AWAITING_ADDITIONAL_INFO'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'MORE_INFO_UPDATED', Name = 'MORE_INFO_UPDATED'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'AWAITING_FFA_AA', Name = 'AWAITING_FFA_AA'),
                    new NSIBPM__Status__c(NSIBPM__Code__c = 'FFA_AA_UPLOADED', Name = 'FFA_AA_UPLOADED')});
        
        List<NSIBPM__SR_Template__c> SRTemplateList =  InitialiseTestData.createTestTemplateRecords(new List<NSIBPM__SR_Template__c>{new NSIBPM__SR_Template__c()});
        List<NSIBPM__Service_Request__c> SRList = InitialiseTestData.createTestServiceRequestRecords(new List<NSIBPM__Service_Request__c>{
                    new NSIBPM__Service_Request__c(recordTypeId = InitialiseTestData.getRecordTypeId('NSIBPM__Service_Request__c', 'Agent Registration'),
                                                    NSIBPM__SR_Template__c = SRTemplateList[0].Id)});
                                                    
                                                    
       NSIBPM__Service_Request__c serviceRequestObject = SRList[0] ; 
       serviceRequestObject.NSIBPM__Customer__c = agency1.Id ;
       serviceRequestObject.Last_Name__c = 'test User' ;
       update serviceRequestObject ; 
                                                    
        Amendment__c newAmd;
       List<Amendment__c> amdList = new List<Amendment__c>();
       for(integer i=0;i<conList.Size();i++){
           newAmd =  new Amendment__c();
           newAmd.First_Name__c = 'testfn'+i;
           newAmd.Last_Name__c = 'testfn'+i;
           newAmd.Account__c = conList[i].AccountId;
           newAmd.Contact__c = conList[i].Id;
           if(i==0){
               newAmd.Owner__c = true;
               newAmd.Shareholding__c =100;
           }
           newAmd.Authorised_Signatory__c = true;
           newAmd.Agent_Representative__c =true;
           newAmd.Portal_Administrator__c = true;
           newAmd.Email__c ='TestCCReg'+i+'@test.com';
           newAmd.ID_Expiry_Date__c = System.Today().addDays(100);
           newAmd.ID_Type__c = 'Visa';
           newAmd.Service_Request__c = SRList[0].Id ;
           amdList.add(newAmd);
       }
       insert amdList;
        Map<String, Contact> testconMap = new Map<String, Contact>();
        Map<String, Amendment__c> testamdMap = new Map<String, Amendment__c>();
        
        for (Amendment__c amd :  amdList) {
            testconMap.put(amd.id, mpContact.get(amd.Contact__c));
            testamdMap.put(amd.id,amd);
        }
        
        
        
        List<NSIBPM__Step__c> createStepList = InitialiseTestData.createTestStepRecords(
            new List<NSIBPM__Step__c>{
                new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[0].Id, NSIBPM__SR_Step__c = srStep.id),
                new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[1].Id, NSIBPM__SR_Step__c = srStep.id)});
        
        User portalUser1  = InitialiseTestData.getPortalUser('portalCCUser@test.com',newCont.Id);
        insert portalUser1 ; 
                                                
        CC_RegisterAgents ccRegisterAgents = new CC_RegisterAgents();
        ccRegisterAgents.EvaluateCustomCode(SRList[0],createStepList[0]);
        
        CC_RegisterAgents.conMap = testconMap;
            
        ccRegisterAgents.updateAmendmentLookups(agency1);
        ccRegisterAgents.createAccount(SRList[0]);
        ccRegisterAgents.createPersonAccount(SRList[0]);
        ccRegisterAgents.checkForDuplicatePersonAccounts('Test',acc.id);
        ccRegisterAgents.retPrefix();
        
        CC_RegisterAgents.amdMap= testamdMap ;
        ccRegisterAgents.createContacts(SRList[0],agency1);
        CC_RegisterAgents.randomWithLimit(100000);
        CC_RegisterAgents.getUserName(newCont);
        CC_RegisterAgents.getUserProfile(amdList[0]);
        CC_RegisterAgents.getAllAmendments(SRList[0].Id);
        CC_RegisterAgents.getSRDetails(SRList[0].Id);
        CC_RegisterAgents.getUserContactMap(agency1.Id);
        CC_RegisterAgents.createPortalUser(SRList[0].Id);
       
   }

}