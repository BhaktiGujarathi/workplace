/*
     Created by:Srikanth Pinnamaneni
     ClassName: OpportunityISOTriggerHandlerTest
     
*/
@
isTest

public class OpportunityISOTriggerHandlerTest{


    public static testmethod void validationtests(){
        
       List < RecordType > record = [select id, name, SobjectType from Recordtype where SobjectType = 'Account' AND (Name = 'ISO' OR Name = 'Vendor')];
       List <Opportunity> oppListToInsert = new List<Opportunity>();
       
        id recordid;
        id Vendorid;

        for (recordType rc: record) {
            if (rc.name == 'ISO'){
             recordid = rc.id;
             }
             
            if (rc.name == 'Vendor') {
                Vendorid = rc.id;
            }        

            System.debug(VendorId + '   ' + recordid);

        }

        List < Profile > profile = [select id, name from profile where name = : 'System Administrator'];

        List < User > user = [select id, name from User where isActive = true];
        
        Account VendorAccount = new Account();
        VendorAccount.Name = 'testing Vendor Account';
        VendorAccount.RecordTypeId = Vendorid;
        insert VendorAccount;
        
        Account VendorAccount1 = new Account();
        VendorAccount1.Name = 'testing Vendor Account';
        VendorAccount1.RecordTypeId = Vendorid;
        insert VendorAccount1;
        
        Account ISOAccount = new Account();
        ISOAccount.Name = 'ISO Account';
        ISOAccount.McaApp__User__c = user[0].id;
        ISOAccount.RecordTypeId = recordid;
        //IsoAccount.parentId = VendorAccount.id;
        ISOAccount.type='Internal';
        insert ISOAccount;
        
        Account ISOAccount1 = new Account();
        ISOAccount1.Name = 'ISO Account';
        ISOAccount1.McaApp__User__c = user[1].id;
        ISOAccount1.RecordTypeId = recordid;
        IsoAccount1.parentId = ISOAccount.id;
        ISOAccount1.type='Internal';
        insert ISOAccount1;
        
        Account ISOAccount12 = new Account();
        ISOAccount12.Name = 'ISO Account';
        ISOAccount12.McaApp__User__c = user[2].id;
        ISOAccount12.RecordTypeId = recordid;
        IsoAccount12.parentId = ISOAccount1.id;
        ISOAccount12.type='Internal';
        insert ISOAccount12;

        opportunity oppForISOCheckTest = new opportunity();
        oppForISOCheckTest .name = 'Test oppty';
        oppForISOCheckTest .accountId = Vendoraccount.id;
        oppForISOCheckTest .StageName = 'Funded';
        oppForISOCheckTest .McaApp__Funding_Amount__c = 30000;
        oppForISOCheckTest .McaApp__Total_Receivables__c = 10000;
        oppForISOCheckTest .CloseDate = system.today();
        oppForISOCheckTest .ISO_1_Lead_Source__c = ISOAccount.id;
        oppListToInsert.add(oppForISOCheckTest );
        
        opportunity oppForISOParentCheckTest = new opportunity();
        oppForISOParentCheckTest.name = 'Test oppty';
        //oppForISOParentCheckTest .accountId = Vendoraccount.id;
        oppForISOParentCheckTest.StageName = 'Funded';
        oppForISOParentCheckTest.McaApp__Funding_Amount__c = 30000;
        oppForISOParentCheckTest.McaApp__Total_Receivables__c = 10000;
        oppForISOParentCheckTest.CloseDate = system.today();
        oppForISOParentCheckTest.Iso_2__c  = ISOAccount1.id;
        oppForISOParentCheckTest.ISO_4__c = ISOAccount12.id;   
        oppListToInsert.add(oppForISOParentCheckTest );
        
        
        opportunity oppNonISOCheck= new opportunity();
        oppNonISOCheck.name = 'Test oppty';
        oppNonISOCheck.StageName = 'Funded';
        oppNonISOCheck.McaApp__Funding_Amount__c = 30000;
        oppNonISOCheck.McaApp__Total_Receivables__c = 10000;
        oppNonISOCheck.CloseDate = system.today();
        oppNonISOCheck.ISO_3__c = VendorAccount1.id;  
        oppListToInsert.add(oppNonISOCheck);
        
        opportunity oppForDuplicateCheckTest = new opportunity();
        oppForDuplicateCheckTest .name = 'Test oppty';
        oppForDuplicateCheckTest .StageName = 'Funded';
        oppForDuplicateCheckTest .McaApp__Funding_Amount__c = 30000;
        oppForDuplicateCheckTest .McaApp__Total_Receivables__c = 10000;
        oppForDuplicateCheckTest .CloseDate = system.today();
        oppForDuplicateCheckTest .Iso_3__c  = ISOAccount12.id;
        oppForDuplicateCheckTest .ISO_4__c = ISOAccount12.id;  
        oppListToInsert.add(oppForDuplicateCheckTest );
        
        
        try
        {
            insert oppListToInsert;
        }
        catch(Exception e)
        {
        
        }
    
    }
    

}