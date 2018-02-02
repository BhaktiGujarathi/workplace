@isTest
public class FacilityApprovalcontroller_Test{
    static testMethod void Test1(){
       // RecordType rcCase = [select id from  RecordType where SobjectType='Case' AND Name='Facility Approval'];
       RecordType rc1 = [select id from  RecordType where SobjectType='Account' AND Name='FRN Facility'];
       Account acc = new Account();
       acc.Name = 'test';
       acc.RecordTypeid = rc1.id;
       insert acc;
       
       contact con = new contact();
        con.LastName = 'Test';
        con.Birthdate = System.Today();
        con.FirstName = 'Test';
        con.Social_Security_Number__c = 'Test';
        insert con;
       
       Red_Flag_Details_Setting__c rfd = new Red_Flag_Details_Setting__c();
       rfd.name='Abused Substances';
       rfd.Opportunity_Fields__c='Substance__c,Date_of_Last_Use__c,Age_of_First_Use__c,Average_Amount_of_Use__c,Duration_of_Current_Episode_of_Use__c,Frequency__c,Method_of_Use__c,Additional_Notes__c';
       insert rfd;
       
       Red_Flag_Details_Setting__c rfd1 = new Red_Flag_Details_Setting__c();
       rfd1.name='Legal Offenses';
       rfd1.Opportunity_Fields__c='Substance__c,Date_of_Last_Use__c,Age_of_First_Use__c,Average_Amount_of_Use__c,Duration_of_Current_Episode_of_Use__c,Frequency__c,Method_of_Use__c,Additional_Notes__c';
       insert rfd1; 
       
       Red_Flag_Details_Setting__c rfd2 = new Red_Flag_Details_Setting__c();
       rfd2.name='Medical Equipment';
       rfd2.Opportunity_Fields__c='Substance__c,Date_of_Last_Use__c,Age_of_First_Use__c,Average_Amount_of_Use__c,Duration_of_Current_Episode_of_Use__c,Frequency__c,Method_of_Use__c,Additional_Notes__c';
       insert rfd2; 
        
        RecordType rc = [select id from  RecordType where SobjectType='Opportunity' AND Name='Refer Out Only'];
        Opportunity opp = new Opportunity (Name = 'TestOpp',StageName = 'Prospecting', Probability = 10, CloseDate = System.today(),Travel_Restrictions__c='test', AccountId = acc.Id, Admission_Date__c= System.Today());
        insert opp;
        
        Case cs = new Case();
        cs.Opportunity__c = opp.Id;
        cs.AccountId = acc.Id;
        cs.Red_Flag_Information__c = 'Abused Substances;Legal Offenses;Medical Equipment;Medical Problems / Symptoms';
        cs.Status = 'New';
        cs.Origin = 'Email';
        cs.Red_Flag_Details__c = 'Safety Questions';
        insert cs;
        
        Abused_Substance__c CMR = new Abused_Substance__c(Opportunity__c = opp.Id, Patient__c = con.id);
        insert CMR;
        
        
        List<sObject> sObjetcLlist = new List<sObject>();
        sObjetcLlist.add((sObject)CMR);
        
        Map<String, Schema.SObjectField> allCMRFields = Schema.SObjectType.Abused_Substance__c.fields.getMap();
        
//public String createRTDataChild(Map<String, Schema.SObjectField> allFields,List<sObject> sObjectList,Red_Flag_Details_Setting__c f)
        //Map<String, Schema.SObjectField> allFields = new Map<String, Schema.SObjectField>();
        
        ApexPages.currentPage().getParameters().put('recType', 'Facility Approval');
        ApexPages.StandardController  sc = new ApexPages.StandardController(opp);
        FacilityApprovalcontroller FAC = new FacilityApprovalcontroller(sc);
        FAC.getRecorordtypes();
        //FAC.rowToRemove = 0; 
        //FAC.removeRowToAccList();
        //FAC.addNewAccObj();
        FAC.getFacilitylist();
        //FAC.addNewAccObj();
        FacilityApprovalcontroller.WrpFacility fwp = new FacilityApprovalcontroller.WrpFacility();
        fwp.Facilitylistinfow = 'test';
        fwp.acct = acc;
        system.debug('>>> cs.Acc : '+cs.AccountId);
        fwp.cs= cs;
        system.debug('>>> cs.Acc : '+fwp.cs.AccountId);
        system.debug('>>> fwp : '+fwp);
        FAC.WrapFacilitylist.add(fwp);
        system.debug('>>> FAC.WrapFacilitylist : '+FAC.WrapFacilitylist);
        FAC.WrapFacilitylist[0].cs = cs;
        FAC.WrapFacilitylist[0].acct = acc;
        FAC.WrapFacilitylist[0].Facilitylistinfow = 'test';
        FAC.save();
        FAC.RedFlagDetailsFormate('Abused Substances;Legal Offenses');
        FAC.rowToRemove = 1; 
        FAC.createRTDataChild(allCMRFields, sObjetcLlist, rfd);
        FAC.createRTData(allCMRFields, CMR, rfd);
        FAC.removeRowToAccList();
        FAC.Cancel();
    }  
    static testMethod void Test2(){
       // RecordType rcCase = [select id from  RecordType where SobjectType='Case' AND Name='Facility Approval'];
       RecordType rc1 = [select id from  RecordType where SobjectType='Account' AND Name='FRN Facility'];
       Account acc = new Account();
       acc.Name = 'test';
       acc.RecordTypeid = rc1.id;
       insert acc;
       
       Red_Flag_Details_Setting__c rfd = new Red_Flag_Details_Setting__c();
       rfd.name='Safety Questions';
       rfd.Opportunity_Fields__c='Travel_Restrictions__c,Admission_Date__c,Estimated_Date_of_Arrival__c';
       insert rfd;  
        
        RecordType rc = [select id from  RecordType where SobjectType='Opportunity' AND Name='Refer Out Only'];
        Opportunity opp = new Opportunity (Name = 'TestOpp',StageName = 'Prospecting', Probability = 10, CloseDate = System.today(),Travel_Restrictions__c='test', AccountId = acc.Id, Admission_Date__c= System.Today());
        insert opp;
        
        RecordType caseRecordType = [select id from  RecordType where SobjectType='Case' AND Name='Clinical / Medical Approval'];
        
        Case cs = new Case();
        cs.Opportunity__c = opp.Id;
        cs.AccountId = acc.Id;
        cs.Red_Flag_Information__c = 'Safety Questions;Eating Disorder Questions';
        cs.Status = 'New';
        cs.Origin = 'Email';
        cs.Red_Flag_Details__c = 'Safety Questions';
        insert cs;
        

        Clinical_Medical_Review_Note__c clm = new Clinical_Medical_Review_Note__c();
        clm.Assigned_To__c = Userinfo.getUserID();
        clm.Comments__c = 'Test';
        clm.Opportunity__c = opp.id;
        insert clm;

        
        ApexPages.currentPage().getParameters().put('recType', 'Facility Approval');
        ApexPages.StandardController  sc = new ApexPages.StandardController(opp);
        FacilityApprovalcontroller FAC = new FacilityApprovalcontroller(sc);
        FAC.getRecorordtypes();
        //FAC.cmrnList.add(clm);
        //FAC.rowToRemove = 0; 
        //FAC.removeRowToAccList();
        //FAC.addNewAccObj();
        FAC.getFacilitylist();
        //FAC.addNewAccObj();
        FacilityApprovalcontroller.WrpFacility fwp = new FacilityApprovalcontroller.WrpFacility();
        fwp.Facilitylistinfow = 'test';
        fwp.acct = acc;
        fwp.cs= cs;
        FAC.WrapFacilitylist.add(fwp);
        FAC.save();
        FAC.addNewAccObj();
        FAC.RedFlagDetailsFormate('Medical / Clinical Review Notes');
        FAC.rowToRemove = 1; 
        FAC.removeRowToAccList();
        FAC.redirectToCaseId(opp.Id, caseRecordType.Id);
        FAC.Cancel();
    }   
}