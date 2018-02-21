@istest
public class CampaignInventoryTriggerHandlerTest{

    static testmethod void TestMethods(){
        
        Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        
        Campaign__c camp = new Campaign__c();
        camp.RecordTypeId = RSRecordTypeId;
        camp.Campaign_Name__c='Test Campaign';
        camp.start_date__c = System.today();
        camp.end_date__c = System.Today().addDays(30);
        camp.Marketing_start_date__c = System.today();
        camp.Marketing_end_date__c = System.Today().addDays(30);
        camp.Language__c = 'English';
        insert camp;
        
        inventory__c inv = new inventory__c();        
        insert inv;
        
         Assigned_Agent__c aa = new Assigned_Agent__c();
        aa.Campaign__c = camp.id;
        insert aa;
        
        Campaign_Inventory__c ci = new Campaign_Inventory__c();
        ci.campaign__c = camp.id;
        ci.inventory__c = inv.id;
        insert ci;
        
        delete ci;
    }
    
    

}