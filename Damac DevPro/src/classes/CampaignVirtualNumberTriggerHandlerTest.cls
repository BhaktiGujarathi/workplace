@istest

public class CampaignVirtualNumberTriggerHandlerTest{



    static testmethod void CampaignVirtualNumberTriggerHandler_m1(){
        
        Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Digital').getRecordTypeId();
        
        Virtual_Number__c v = new Virtual_Number__c();
        v.Active__c = true;
        v.name = '123';
        v.End_Date__c = System.today().addDays(60);
        v.Start_Date__c = System.today().addDays(-60);
        insert v;
        
        Campaign__c camp = new Campaign__c();
        camp.RecordTypeId = RSRecordTypeId;
        camp.Campaign_Name__c='Test Campaign';
        camp.start_date__c = System.today();
        camp.end_date__c = System.Today().addDays(30);
        camp.Marketing_start_date__c = System.today();
        camp.Marketing_end_date__c = System.Today().addDays(30);
        camp.Language__c = 'English';
        insert camp;
        
        Campaign__c camp2 = new Campaign__c();
        camp2.RecordTypeId = RSRecordTypeId;
        camp2.Campaign_Name__c='Test Campaign';
        camp2.start_date__c = System.today();
        camp2.end_date__c = System.Today().addDays(30);
        camp2.Marketing_start_date__c = System.today();
        camp2.Marketing_end_date__c = System.Today().addDays(30);
        camp2.Language__c = 'English';
        insert camp2;
    
        JO_Campaign_Virtual_Number__c vn = new JO_Campaign_Virtual_Number__c();
        vn.Related_Campaign__c = camp.id;
        vn.Related_Virtual_Number__c = v.id;
        
        
        JO_Campaign_Virtual_Number__c vn1 = new JO_Campaign_Virtual_Number__c();
        vn1.Related_Campaign__c = camp2.id;
        vn1.Related_Virtual_Number__c = v.id;
        try{
            insert vn;
            insert vn1;
        
            update vn;
        }catch(exception e){}
        
        
    
    
    }
    
    static testmethod void CampaignVirtualNumberTriggerHandler_m2(){
        
        Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        
        Virtual_Number__c v = new Virtual_Number__c();
        v.Active__c = true;
        v.name = '123';
        v.End_Date__c = System.today().addDays(60);
        v.Start_Date__c = System.today().addDays(-60);
        insert v;
        
        Campaign__c camp = new Campaign__c();
        camp.RecordTypeId = RSRecordTypeId;
        camp.Campaign_Name__c='Test Campaign';
        camp.start_date__c = System.today();
        camp.end_date__c = System.Today().addDays(30);
        camp.Marketing_start_date__c = System.today();
        camp.Marketing_end_date__c = System.Today().addDays(30);
        camp.Language__c = 'English';
        insert camp;
        
        Campaign__c camp2 = new Campaign__c();
        camp2.RecordTypeId = RSRecordTypeId;
        camp2.Campaign_Name__c='Test Campaign';
        camp2.start_date__c = System.today();
        camp2.end_date__c = System.Today().addDays(30);
        camp2.Marketing_start_date__c = System.today();
        camp2.Marketing_end_date__c = System.Today().addDays(30);
        camp2.Language__c = 'English';
        insert camp2;
    
        JO_Campaign_Virtual_Number__c vn = new JO_Campaign_Virtual_Number__c();
        vn.Related_Campaign__c = camp.id;
        vn.Related_Virtual_Number__c = v.id;
        
        
        JO_Campaign_Virtual_Number__c vn1 = new JO_Campaign_Virtual_Number__c();
        vn1.Related_Campaign__c = camp2.id;
        vn1.Related_Virtual_Number__c = v.id;
        try{
            insert vn;
            insert vn1;
        
            update vn;
        }catch(exception e){}
        
        
    
    
    }





}