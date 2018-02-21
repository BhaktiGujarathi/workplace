/*
    This is the Test Class for the Visual Force page leadConvertPage.
    
  * Revision History:
  *    
  * Version         Author                                   Date                                    Description
  * 1.0             Nachiket R. Deshpande                    24/12/2014                              Initial Draft
    
*/
@isTest
public class leadConvertControllerTest {

    static testMethod void leadConvertTest() { 
        Boolean bolCreateOpp;
        String strAccountId;
        //Create Test Data For Lead
        Lead objLead = new Lead ();
        objLead.FirstName = 'Test First Name';
        objLead.LastName = 'Test Last Name';
        objLead.Company = 'Test Company';
        objLead.Status = 'Open - Not Contacted';
        objLead.Funding_App__c = true;
        
        insert objLead;
        system.debug('****objLead***'+objLead);
        
        Id leadId = objLead.Id;
        bolCreateOpp = false;
        test.startTest();
        //Create a reference to the VF page
        PageReference pageRef = Page.LeadConvertPage;
        pageRef.getParameters().put('Id', objLead.Id);
        system.debug('***pageRef***'+pageRef);
        Test.setCurrentPageReference(pageRef);
        

        ApexPages.StandardController sc = new ApexPages.standardController(objLead);
        
        PageControllerBase objPageControllerBase = new PageControllerBase();
        ComponentControllerBase objComponentBase = new ComponentControllerBase();
        
        objPageControllerBase.getMyComponentController();
        objPageControllerBase.getmyDescriptionComponentController();
        objPageControllerBase.getmyReminderComponentController();
        objPageControllerBase.getmyTaskComponentController();
                
        objPageControllerBase.setTaskComponentController(objComponentBase); 
        objPageControllerBase.setComponentController(objComponentBase);
        objPageControllerBase.setReminderComponentController(objComponentBase);
        objPageControllerBase.setDescriptionComponentController(objComponentBase);
        objPageControllerBase.getThis();
        

        //objPageControllerBase.getmyTaskComponentController();
        
        
        
        leadConvertPageHeaderTextComponent objPageHeaderComponent = new leadConvertPageHeaderTextComponent();
        
        leadConvertCoreComponentController objCoreComponent = new leadConvertCoreComponentController();
        //objCoreComponent.accountLookedUp();
        
        leadConvertTaskInfoComponentController objTaskInfoComponent = new leadConvertTaskInfoComponentController();
        objTaskInfoComponent.DueDateChanged();
        
        leadConvertTaskRemindComponentController objTaskRemiderComponent = new leadConvertTaskRemindComponentController();
        
        leadConvertTaskDescComponentController objTaskDescComponent = new leadConvertTaskDescComponentController();
        
        
        leadConvertController leadconvt = new leadConvertController(sc); 
        leadconvt.setComponentController(objCoreComponent);
        leadconvt.setTaskComponentController(objTaskInfoComponent);
        leadconvt.setDescriptionComponentController(objTaskDescComponent);
        leadconvt.getMyComponentController();
        leadconvt.getmyDescriptionComponentController();
        leadconvt.getmyTaskComponentController();
        leadconvt.getmyReminderComponentController();
        leadconvt.setReminderComponentController(objCoreComponent);
        leadconvt.getThis();
        
        leadconvt.convertLead();
 
        objCoreComponent.populateAccounts();
        DateTimeUtility.LocaleToTimeFormatMap();
 
        //Retrieve the converted Lead info and the opps and roles.
        list<Lead> lstLead = new list<Lead> ();
        lstLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId ,Status,
        Company,OwnerId,firstname,lastname,city,country from Lead where Id = :leadId];
        system.debug('****lstLead***'+lstLead);
        system.debug('****lstLead***'+lstLead[0].IsConverted);
         
        system.assert(!lstLead[0].IsConverted,'Lead Converted' ); 
        test.stopTest();
     }
     
      static testMethod void leadConvertandTaskTest() { 
        Boolean bolCreateOpp;
        String strAccountId;
        //Create Test Data For Lead
        Lead objLead = new Lead ();
        objLead.FirstName = 'Test First Name';
        objLead.LastName = 'Test Last Name';
        objLead.Company = 'Test Company';
        objLead.Status = 'Open - Not Contacted';
        objLead.Funding_App__c = true;
        
        insert objLead;
        system.debug('****objLead***'+objLead);
        
        Id leadId = objLead.Id;
        bolCreateOpp = false;
        test.startTest();
        //Create a reference to the VF page
        PageReference pageRef = Page.LeadConvertPage;
        pageRef.getParameters().put('Id', objLead.Id);
        system.debug('***pageRef***'+pageRef);
        Test.setCurrentPageReference(pageRef);
        

        ApexPages.StandardController sc = new ApexPages.standardController(objLead);
        
        PageControllerBase objPageControllerBase = new PageControllerBase();
        ComponentControllerBase objComponentBase = new ComponentControllerBase();
        
        objPageControllerBase.getMyComponentController();
        objPageControllerBase.getmyDescriptionComponentController();
        objPageControllerBase.getmyReminderComponentController();
        objPageControllerBase.getmyTaskComponentController();
                
        objPageControllerBase.setTaskComponentController(objComponentBase); 
        objPageControllerBase.setComponentController(objComponentBase);
        objPageControllerBase.setReminderComponentController(objComponentBase);
        objPageControllerBase.setDescriptionComponentController(objComponentBase);
        objPageControllerBase.getThis();
        
        
        
        leadConvertPageHeaderTextComponent objPageHeaderComponent = new leadConvertPageHeaderTextComponent();
        
        leadConvertCoreComponentController objCoreComponent = new leadConvertCoreComponentController();
        objCoreComponent.populateAccounts();
        leadConvertTaskInfoComponentController objTaskInfoComponent = new leadConvertTaskInfoComponentController();
        objTaskInfoComponent.DueDateChanged();
        
        
        
        leadConvertTaskDescComponentController objTaskDescComponent = new leadConvertTaskDescComponentController();
    
        Database.LeadConvert leadConvert = new database.LeadConvert();
        leadConvert.setLeadId(objLead.Id);
        leadConvert.setConvertedStatus('Closed - Converted');
        leadConvert.setDoNotCreateOpportunity(false);
        Database.LeadConvertResult leadConvertResult;
        leadConvertResult = Database.convertLead(leadConvert);
        
        leadConvertController leadconvt = new leadConvertController(sc); 
        leadconvt.setComponentController(objCoreComponent);
        leadconvt.setTaskComponentController(objTaskInfoComponent);
        leadconvt.setDescriptionComponentController(objTaskDescComponent);
        leadconvt.getMyComponentController();
        leadconvt.getmyDescriptionComponentController();
        leadconvt.getmyTaskComponentController();
        leadconvt.getmyReminderComponentController();
        leadconvt.setReminderComponentController(objCoreComponent);
        leadconvt.getThis();
        leadconvt.convertToDatetime(system.today(),'2:07 PM');
        objCoreComponent.populateAccounts();        
        DateTimeUtility.LocaleToTimeFormatMap();
        leadconvt.convertLead();
        
        System.debug('%%%%%%leadConvertResult '+leadConvertResult);
        
        
        Task taskToCreate = new Task();
        //set the whatId to the Opportunity Id            
                taskToCreate.WhatId = leadConvertResult.getOpportunityId();
                
                //set the whoId to the contact Id
                taskToCreate.WhoId = leadConvertResult.getContactId();
                
                //set the subject
                taskToCreate.Subject = 'Test Subject';
                
                //set the status
                taskToCreate.Status = 'Not Started';
                
                //set the activity date 
                taskToCreate.ActivityDate = system.today();
                
                //set the Priority 
                taskToCreate.Priority = 'Normal';
                
                //set the custom field Primary Resource (this is a custom field on the Task showing an example of adding custom fields to the page)
                //taskToCreate.Primary_Resource__c = myTaskComponentController.taskID.Primary_Resource__c;
                
                //set the Description field which comes from the leadConvertTaskDescComponent
                taskToCreate.Description =  'Test Description';
                taskToCreate.ReminderDateTime = system.today();
                
                insert taskToCreate;
                
        
        leadConvertTaskRemindComponentController objTaskRemiderComponent = new leadConvertTaskRemindComponentController();
        
        
 
        //Retrieve the converted Lead info and the opps and roles.
        list<Lead> lstLead = new list<Lead> ();
        lstLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId ,Status,
        Company,OwnerId,firstname,lastname,city,country from Lead where Id = :leadId];
        system.debug('****lstLead***'+lstLead);
        system.debug('****lstLead***'+lstLead[0].IsConverted);
         
        system.assert(lstLead[0].IsConverted,'Lead Converted' ); 
        test.stopTest();
     }
     
     
     static testMethod void myUnitTest() {
      Boolean bolCreateOpp;
      List<SelectOption> reminderTimeOption = new list<selectoption>();
      
        String strAccountId;
       // Craete test data for Account
       Account acc = new Account();
       acc.Name = 'Test Acc';
       //acc.Company = 'TestCompany';
       insert acc;
        
        //Create Test Data For Lead
        Lead objLead = new Lead ();
        objLead.FirstName = 'Test First Name';
        objLead.LastName = 'Test Last Name';
        objLead.Company = 'Test Company';
        objLead.Status = 'Open - Not Contacted';
        objLead.Funding_App__c = true;
        
        insert objLead;
        system.debug('****objLead***'+objLead);
        
        Id leadId = objLead.Id;
        bolCreateOpp = false;
        test.startTest();
        //Create a reference to the VF page
        PageReference pageRef = Page.LeadConvertPage;
        pageRef.getParameters().put('Id', objLead.Id);
        system.debug('***pageRef***'+pageRef);
        Test.setCurrentPageReference(pageRef);
        

        ApexPages.StandardController sc = new ApexPages.standardController(objLead);
        
        PageControllerBase objPageControllerBase = new PageControllerBase();
        ComponentControllerBase objComponentBase = new ComponentControllerBase();
        
        objPageControllerBase.getMyComponentController();
        objPageControllerBase.getmyDescriptionComponentController();
        objPageControllerBase.getmyReminderComponentController();
        objPageControllerBase.getmyTaskComponentController();
                
        objPageControllerBase.setTaskComponentController(objComponentBase); 
        objPageControllerBase.setComponentController(objComponentBase);
        objPageControllerBase.setReminderComponentController(objComponentBase);
        objPageControllerBase.setDescriptionComponentController(objComponentBase);
        objPageControllerBase.getThis();   
        
        
        leadConvertPageHeaderTextComponent objPageHeaderComponent = new leadConvertPageHeaderTextComponent();
        
        leadConvertCoreComponentController objCoreComponent = new leadConvertCoreComponentController();
        //objCoreComponent.populateAccounts();
        //objCoreComponent.accountChanged();
        //objCoreComponent.accountLookedUp();
         pageRef.getParameters().put('OpporyunityId', acc.Id);
         
         
        leadConvertTaskInfoComponentController objTaskInfoComponent = new leadConvertTaskInfoComponentController();
        objTaskInfoComponent.DueDateChanged();
        
        
        
        leadConvertTaskDescComponentController objTaskDescComponent = new leadConvertTaskDescComponentController();
    
        Database.LeadConvert leadConvert = new database.LeadConvert();
        leadConvert.setLeadId(objLead.Id);
        leadConvert.setConvertedStatus('Closed - Converted');
        leadConvert.setDoNotCreateOpportunity(false);
        Database.LeadConvertResult leadConvertResult;
        leadConvertResult = Database.convertLead(leadConvert);
        objCoreComponent.findCompany(objLead.Company);
        
        leadConvertController leadconvt = new leadConvertController(sc); 
        leadconvt.setComponentController(objCoreComponent);
        leadconvt.setTaskComponentController(objTaskInfoComponent);
        leadconvt.setDescriptionComponentController(objTaskDescComponent);
        leadconvt.getMyComponentController();
        leadconvt.getmyDescriptionComponentController();
        leadconvt.getmyTaskComponentController();
        leadconvt.getmyReminderComponentController();
        leadconvt.setReminderComponentController(objCoreComponent);
        leadconvt.getThis();
        leadconvt.convertToDatetime(system.today(),'2:07 PM');
        objCoreComponent.populateAccounts();        
        DateTimeUtility.LocaleToTimeFormatMap();
        leadconvt.convertLead();
        
        System.debug('%%%%%%leadConvertResult '+leadConvertResult);
        
           
        
        Task taskToCreate = new Task();
        //set the whatId to the Opportunity Id            
                taskToCreate.WhatId = leadConvertResult.getOpportunityId();
                
                //set the whoId to the contact Id
                taskToCreate.WhoId = leadConvertResult.getContactId();
                
                //set the subject
                taskToCreate.Subject = 'Test Subject';
                
                //set the status
                taskToCreate.Status = 'Not Started';
                
                //set the activity date 
                taskToCreate.ActivityDate = system.today();
                
                //set the Priority 
                taskToCreate.Priority = 'Normal';
                
                //set the custom field Primary Resource (this is a custom field on the Task showing an example of adding custom fields to the page)
                //taskToCreate.Primary_Resource__c = myTaskComponentController.taskID.Primary_Resource__c;
                
                //set the Description field which comes from the leadConvertTaskDescComponent
                taskToCreate.Description =  'Test Description';
                taskToCreate.ReminderDateTime = system.today();
                
                insert taskToCreate;
                
        
        leadConvertTaskRemindComponentController objTaskRemiderComponent = new leadConvertTaskRemindComponentController();
        objTaskRemiderComponent.ReminderOption('3:00:PM');
        
        //Testing Opportunity
        Opportunity opp = new Opportunity();
        opp = [Select Id
                           from Opportunity 
                           where Id =:leadConvertResult.getOpportunityId()];
        System.debug('%%%%%%% Opportunity created after lead convert'+ opp);
        opp.AccountId = acc.Id;
        upsert opp;
        
        
 
        //Retrieve the converted Lead info and the opps and roles.
        list<Lead> lstLead = new list<Lead> ();
        lstLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId ,Status,
        Company,OwnerId,firstname,lastname,city,country from Lead where Id = :leadId];
        system.debug('****lstLead***'+lstLead);
        system.debug('****lstLead***'+lstLead[0].IsConverted);
         
        system.assert(lstLead[0].IsConverted,'Lead Converted' ); 
        test.stopTest();
     }
}