/*
* Test Class for ServiceRequestTrgHandler
*/
@isTest
private class ServiceRequestTrgHandler_Test {
    @testSetup static void setupData() {
        try{
            list<string> rolenames = new List<string>{'PC','HOS','DOS'};
                Map<string,UserRole> mpRoles = InitializeSRDataTest.createRoles(rolenames);
            
            set<string> stProfileNames = new set<string>{'Property Consultant','Director of Sales','Head of Sales'};
                Map<string,profile> mpProfile = InitializeSRDataTest.getprofiles(stProfileNames);
            
            Map<id,integer> mpprofileidUsercount = new Map<Id,integer>();
            Map<Id,id> mpProfileIDRoleID = new Map<Id,Id>();
            for(profile p : mpprofile.values()){
                mpprofileidUsercount.put(p.id,2);
                if(p.name == 'Property Consultant')
                    mpProfileIDRoleID.put(p.id,mpRoles.get('PC').id);
                if(p.name == 'Director of Sales')
                    mpProfileIDRoleID.put(p.id,mpRoles.get('DOS').id);
                if(p.name == 'Head of Sales')
                    mpProfileIDRoleID.put(p.id,mpRoles.get('HOS').id);
            }
            List<user> lstUsers = InitializeSRDataTest.createInternalUser(mpprofileidUsercount);
            
            for(user u : lstUsers){
                system.debug('--Username>'+u.username);
                u.UserRoleId = mpProfileIDRoleID.get(u.profileid);
            }
            insert lstUsers;
        }
        catch(exception ex){
            system.debug('---> exception '+ex.getmessage());
        }
    }
    
    @isTest static void test_method_1() {
        Test.startTest();
        {
            
            Map<string,List<User>> mpUsers = new Map<string,List<User>>();
            for(user u : [select id,name,userrole.name,CompanyName from user]){
                if(mpUsers.containskey(u.userrole.name)){
                    List<User> lstu = mpUsers.get(u.userrole.name);
                    lstu.add(u);
                    mpUsers.put(u.userrole.name,lstu);
                }
                else{
                    List<User> lstu = new List<User>();
                    lstu.add(u);
                    mpUsers.put(u.userrole.name,lstu);
                }
            }
            system.debug('-->'+mpUsers);
                        
            NSIBPM__SR_Template__c srTemplate = InitializeSRDataTest.createSRTemplate('Agent Registration');
            insert srTemplate;
            
            NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Agent Registration',false,null);
            sr.ID_Type__c = null;
            sr.Agency_Type__c = 'Corporate';
            sr.NSIBPM__SR_Template__c = srTemplate.id;
            sr.Select_User_1__c = mpUsers.get('PC')[0].id;
            insert sr;
            
            List<Agent_Site__c> lstAgntSites = new List<Agent_Site__c>();
            lstAgntSites.add(new Agent_Site__c(Start_Date__c = system.today(),Active__c=true,Name='UAE',Agency__c = sr.NSIBPM__Customer__c));
            lstAgntSites.add(new Agent_Site__c(Start_Date__c = system.today(),Active__c=true,Name='UK',Agency__c = sr.NSIBPM__Customer__c));
            insert lstAgntSites;
            
            sr.Agency_Email_2__c = 'testsr@gmail.com';
            sr.Alternate_Agency_Email_2__c = 'testsr1@gmail.com';
            sr.Country_of_Sale__c = 'UAE';
            sr.Select_User_1__c = mpUsers.get('PC')[1].id;
            sr.DP_ok__c =true;
            Update sr;
            //Select_User_1__c
        }
        Test.stopTest();
    }
    
    @isTest static void test_method_2() {
        Test.startTest();
        {

        }
        Test.stopTest();
    }
    
    
}