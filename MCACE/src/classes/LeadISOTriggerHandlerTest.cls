/*
     Created by:Srikanth Pinnamaneni
     ClassName: LeadISOTriggerHandlerTest
     
*/
@
isTest(seeAllData = false)

public class LeadISOTriggerHandlerTest{


    public static testmethod void validationtests(){
        
       List < RecordType > record = [select id, name, SobjectType from Recordtype where SobjectType = 'Account' AND (Name = 'ISO' OR Name = 'Vendor') ];
       
       List < Profile > profile = [select id, name from profile where name = : 'System Administrator'];
       List < User > user = [select id, name from User where isActive = true];
       List <Lead> leadsToInsert = new List<Lead>();
       List <Account> accountToInsert = new List<Account>();
             
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

        
        
        campaign camp = new campaign();
        camp.name = 'test Name';
        insert camp;

        
        
        
        Account VendorAccount = new Account(Name = 'testing Vendor Account',
                                              RecordTypeId = Vendorid
                                             );
        
        
       insert (VendorAccount);

        
        
        Account VendorAccount1 = new Account(Name = 'testing Vendor Account',
                                               RecordTypeId = Vendorid
                                              );
        
       
        insert (VendorAccount1);

        Account VendorAccount12 = new Account(Name = 'testing Vendor Account',
                                                RecordTypeId = Vendorid 
                                               );
        
       
        insert (VendorAccount12);

        Account ISOAccount = new Account(Name = 'ISO Account',
                                         McaApp__User__c = user[0].id,
                                         RecordTypeId = recordid,
                                         parentId = VendorAccount.id,
                                         type = 'Internal'
                                         );
        
         insert (ISOAccount);


        Account ISOAccount1 = new Account(Name = 'ISO Account',
                                          McaApp__User__c = user[1].id,
                                          RecordTypeId = recordid,
                                          parentId = VendorAccount1.id,
                                          type = 'Internal' 
                                          );
        
        
        insert (ISOAccount1);
       
        Account ISOAccount12 = new Account(Name = 'ISO Account',
                                           McaApp__User__c = user[2].id,
                                           RecordTypeId = recordid ,
                                           parentId = VendorAccount12.id,
                                           type = 'External'
                                           );
        
        
        insert (ISOAccount12);
        
        
        
        
        
        Lead leadError1 = new Lead(LastName = ' test Lead',
                          company = 'Test company',
                          ISO_1__c = ISOAccount.id,
                          Iso_2__c = VendorAccount1.id);
        
       
        leadsToInsert.add(leadError1);
        
       
        
        
        Lead lead1 = new Lead(LastName = ' test Lead',
                          company = 'Test company',
                          ISO_1__c = ISOAccount.id,
                          Iso_2__c = VendorAccount.id);
        
      
        leadsToInsert.add(lead1);
        
        
        
        Lead leadError2 = new Lead(LastName = ' test Lead',
                          company = 'Test company',
                          ISO_2__c = ISOAccount1.id,
                          Iso_4__c = VendorAccount.id);
      
        leadsToInsert.add(leadError2);
        
       
        
        Lead lead2 = new Lead(LastName = ' test Lead',
                           company = 'Test company',
                           Iso_2__c  = ISOAccount1.id,
                           ISO_4__c = VendorAccount1.id);
        
        
         leadsToInsert.add(lead2);
        
        
        Lead leadError3 = new Lead(LastName = ' test Lead',
                          company = 'Test company',
                          ISO_4__c = ISOAccount12.id,
                          Iso_3__c = VendorAccount.id
                          //original_Campaign__c = camp.id
                          );
        leadsToInsert.add(leadError3);
        Lead lead3 = new Lead(LastName = 'test Lead',
                            company = 'Test company',
                            Iso_4__c  = ISOAccount12.id,
                            ISO_3__c = VendorAccount12.id
                            //original_Campaign__c = camp.id
                            );        
     
        leadsToInsert.add(lead3);
       
      try{       
        database.insert(leadsToInsert,false); 
       
       }
      catch(Exception ex)
       {
       
       }
       
    }
    public static testmethod void onAfterLeadISOTriggerHandlerTest(){
    List < RecordType > record = [select id, name, SobjectType from Recordtype where SobjectType = 'Account' AND (Name = 'ISO') ];
    List<Lead> leadToInsert = new List<Lead>();
    id recordid;  
    for (recordType rc: record) 
    {
        if (rc.name == 'ISO')
        {
         recordid = rc.id;
        }

    }
         Account ISOAccount = new Account(Name = 'ISO Account',                                         
                                         RecordTypeId = recordid,                                         
                                         type = 'Internal'
                                         );
        
         insert (ISOAccount);
         Account ISOParentAccount = new Account(Name = 'ISO Parent Account',                                        
                                         RecordTypeId = recordid,
                                         parentId = ISOAccount.Id,                                    
                                         type = 'Internal'
                                         );
        
         insert (ISOParentAccount);
         
         Lead leadObj = new Lead(LastName = 'test Lead',
                            company = 'Test company',
                            Iso_4__c  = ISOAccount.id,
                            ISO_3__c = ISOParentAccount.id
                            //original_Campaign__c = camp.id
                            );        
     
        leadToInsert.add(leadObj);
        try
        {
            database.insert(leadToInsert,false);
        }
        catch(Exception e)
        {
            
        }
    }
}