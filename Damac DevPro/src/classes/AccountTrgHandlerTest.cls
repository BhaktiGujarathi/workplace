/*
* Name : Pavithra Gajendra
* Date : 02/08/2017
* Purpose : Test class for Account handler 
* Company : NSI Gulf
* 
*/
@isTest(seeAllData=true)
private class AccountTrgHandlerTest {
    
    public static Account acc ;
    public static Contact cont1 ; 
    
    @isTest static void blacklistAgency() {
        Test.startTest();
        acc = InitialiseTestData.getCorporateAccount('Test Agency11');
        insert acc ; 
        
        List<Agent_Site__c> lstagsites = new List<Agent_Site__c>();
        lstagsites.add(new Agent_Site__c(Start_Date__c=system.today(),End_Date__c = system.today(),Agency__c = acc.id));
        lstagsites.add(new Agent_Site__c(Start_Date__c=system.today(),IsAccountBlackListedTerminated__c = true,Agency__c = acc.id));
        insert lstagsites;  
        
        cont1 = InitialiseTestData.getAgentContact('Agency Con',acc.Id);
        insert cont1 ; 
        User contactUser1 = InitialiseTestData.getPortalUser('Agent11@mail.com',cont1.Id);
        insert contactUser1 ;
        acc.Blacklisted__c = true ;
        update acc ; 
        User blacklistedUser = [Select id,isActive FROM User Where Id=:contactUser1.Id];
        acc.Blacklisted__c = false ;
        update acc ; 
        System.debug('blacklistedUser '+blacklistedUser);
        Test.stopTest();
    }
    
    
    @isTest static void unTerminateAgency() {
        Test.startTest();
        acc = InitialiseTestData.getTerminatedAccount('Test Agency12');
        insert acc ; 
        cont1 = InitialiseTestData.getAgentContact('Agency Con',acc.Id);
        insert cont1 ;
        User contactUser2 = InitialiseTestData.getPortalUser('Agent12@mail.com',cont1.Id);
        insert contactUser2 ;
        acc.Terminated__c = false ;
        update acc ; 
        User unTerminatedUser = [Select id,isActive FROM User Where Id=:contactUser2.Id];
        System.assertEquals(unTerminatedUser.isActive, true);
        Test.stopTest();
    }
    
    @isTest static void encrypt(){
        Test.startTest();
        List<Account> lstAccount = new List<Account>();
        Id RecTypeIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        Id RecTypepersonal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        List<Account> lstaccounts = new List<account>();
        lstaccounts.add(new Account(Name = 'testLN',recordtypeid = RecTypeIndividual));
        lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal));
        lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal,
                                    Asst_Phone_Country_Code__c = 'India: 0091',Asst_Phone_Encrypt__c = ''));
        lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal,
                                    Asst_Phone_Encrypt__c = 'wdwsfddf'));
        
        lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal,
                                    Home_Phone_Country_Code__c = 'India: 0091',Home_Phone_Encrypt__c = ''));
        lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal,
                                    Home_Phone_Encrypt__c = 'wdwsfddf'));
        
        lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal,
                                    Mobile_Country_Code__c = 'India: 0091',Mobile_Encrypt__c = ''));
        lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal,
                                    Mobile_Encrypt__c = 'wdwsfddf'));
        
        lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal,
                                    Other_Phone_Country_Code__c = 'India: 0091',Other_Phone_Encrypt__c = ''));
        lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal,
                                    Other_Phone_Encrypt__c = 'wdwsfddf'));
        
        lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal,
                                    Phone_Country_Code__c = 'India: 0091',Phone_Encrypt__c = ''));
        lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal,
                                    Phone_Encrypt__c = 'wdwsfddf'));
        /*lstaccounts.add(new Account(FirstName = 'testLN',LastName ='teste',recordtypeid = RecTypepersonal,
                                    Asst_Phone_Country_Code__c = 'India: 0091',Asst_Phone_Encrypt__c = 'encryt',
                                    Home_Phone_Country_Code__c = 'India: 0091',Home_Phone_Encrypt__c = 'asda',
                                    Mobile_Country_Code__c = 'India: 0091',Mobile_Encrypt__c = 'asdasd',
                                    Other_Phone_Country_Code__c = 'India: 0091',Other_Phone_Encrypt__c = 'rwerwe',
                                    Phone_Country_Code__c = 'India: 0091',Phone_Encrypt__c= 'rwerwe'));*/

        try{        insert lstaccounts;}
        catch(exception ex){}
        //objinstance.encryptMobileNumbers(new list<account> {acc,pacc});
        Test.stopTest();
    }
}