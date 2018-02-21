/*
* Test Class for AccountSharingUtility.
*/
@isTest
private class AccountSharingUtility_Test {
    @testSetup static void setupData() {
        
        set<string> stProfileNames = new set<string>{'Property Consultant'};
        Map<string,profile> mpProfile = InitializeSRDataTest.getprofiles(stProfileNames);
        
        Map<id,integer> mpprofileidUsercount = new Map<Id,integer>();
       
        for(profile p : mpprofile.values()){
            if(p.name == 'Property Consultant'){
                mpprofileidUsercount.put(p.id,3);
            }
        }
        List<User> lstUsers = new list<user>();
        lstUsers.addall(InitializeSRDataTest.createinternalUser(mpprofileidUsercount));
        insert lstUsers;
    }
    @isTest static void test_method_1() {
        Test.startTest();
        {
            Id RecTypeIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Agency').getRecordTypeId();
            Account acc = new Account(firstname = 'testFN',lastname = 'testLN',recordtypeid = RecTypeIndividual);
            insert acc;

            Map<id,User> mpUsers = new Map<id,User>([select id,name from user where profile.name = 'Property Consultant' and isactive = true]);
            List<id> userids = new list<id>();
            userids.addall(mpUsers.keyset());
            
            List<Agency_PC__c> lstagncyPC = new List<Agency_PC__c>(); 
            lstagncyPC.add(new Agency_PC__c(Agency__c=acc.id,User__c=userids[0]));
            lstagncyPC.add(new Agency_PC__c(Agency__c=acc.id,User__c=userids[1]));
            insert lstagncyPC;
            

            delete lstagncyPC[0];
        }
        Test.stopTest();
        
    }
}