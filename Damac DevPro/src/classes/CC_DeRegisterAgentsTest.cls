@isTest
private class CC_DeRegisterAgentsTest {
    
    @isTest static void ccAgentRegistered() {
        
        Account newAcc ;
       List<Account> accList = new List<Account>();
       for(Integer i=0;i<10;i++){
           
           newAcc = new Account();
           newAcc.name = 'TestCCDeReg' + i;
           accList.add(newAcc);
           
       }
       insert accList;
       Contact newCon;
       List<Contact> conList = new List<Contact>();
       List<Id> conIdList = new List<Id>();
       for(Integer i=0;i<accList.Size();i++){
           newCon = new Contact();
           newCon.FirstName = 'FirstName' + i;
           newCon.LastName = 'LastName' + i;
           newCon.Email = 'TestCCDeReg' + i + '@gmail.com';
           newCon.Accountid = accList[i].Id;
           conIdList.add(newCon.Id);
           conList.add(newCon);
       }
       insert conList;
       
        Account agency1 = InitialiseTestData.getCorporateAccount('Agency1256');
        insert agency1; 
       
       Contact newCont = new Contact();
        newCont.LastName = 'Agency1256';
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
           newAmd.Account__c = conList[0].AccountId;
           newAmd.Contact__c = conList[0].Id;
           if(i==0){
               newAmd.Owner__c = true;
               newAmd.Shareholding__c =100;
           }
           newAmd.Authorised_Signatory__c = true;
           newAmd.Agent_Representative__c =true;
           newAmd.Portal_Administrator__c = true;
           newAmd.Email__c ='TestCCDeReg'+i+'@test.com';
           newAmd.ID_Expiry_Date__c = System.Today().addDays(100);
           newAmd.ID_Type__c = 'Visa';
           newAmd.Service_Request__c = SRList[0].Id ;
           amdList.add(newAmd);
       }
       insert amdList;
       
        List<NSIBPM__Step__c> createStepList = InitialiseTestData.createTestStepRecords(
            new List<NSIBPM__Step__c>{
                new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[0].Id, NSIBPM__SR_Step__c = srStep.id),
                new NSIBPM__Step__c(NSIBPM__SR__c = SRList[0].id, NSIBPM__Status__c = createStatus[1].Id, NSIBPM__SR_Step__c = srStep.id)});
        
        User portalUser1  = InitialiseTestData.getPortalUser('portalCCDeUser@test.com',newCont.Id);
        insert portalUser1 ; 
        
        CC_DeRegisterAgents ccDeReg = new CC_DeRegisterAgents();
        ccDeReg.EvaluateCustomCode(SRList[0],createStepList[0]);
        ccDeReg.getAllAmendments(SRList[0].Id);
        //ccDeReg.deactivateContacts(conIdList);
        //CC_DeRegisterAgents.deactivateUsers(conIdList);
        //CC_DeRegisterAgents.getSRDetails(SRList[0].Id);
    
    }

}