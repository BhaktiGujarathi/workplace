/*
* Test Class for ManageDealTeam.
*/
@isTest
private class ManageDealTeam_Test {
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
    
     //change agent
    @isTest static void test_method_0() {
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
            
            List<NSIBPM__Service_Request__c> lstSR = new List<NSIBPM__Service_Request__c>();
            lstSR.add(InitializeSRDataTest.getSerReq('Deal',true,null));
            lstSR.add(InitializeSRDataTest.getSerReq('Deal',true,null));
            lstSR.add(InitializeSRDataTest.getSerReq('Deal',true,null));
            
            lstSR[0].Agent_Name__c = mpUsers.get('PC')[0].id;
            lstSR[0].Agency_Type__c = 'Corporate';
            
            lstSR[1].Select_User_1__c = mpUsers.get('PC')[0].id;
            lstSR[1].Select_User_2__c = mpUsers.get('HOS')[1].id;
            lstSR[1].Change_Type__c = 'HOS';
            
            lstSR[2].Select_User_1__c = mpUsers.get('PC')[0].id;
            lstSR[2].Select_User_2__c = mpUsers.get('PC')[1].id;
            lstSR[2].Change_Type__c = 'Change';
            
            insert lstSR;
            
            Deal_Team__c dt = InitializeSRDataTest.createDealTeam(lstSR[2].NSIBPM__Parent_SR__c,mpUsers.get('DOS')[0].id,mpUsers.get('HOS')[0].id,mpUsers.get('PC')[0].id);
            insert dt;
            
            List<NSIBPM__Step__c> lststeps = new List<NSIBPM__Step__c>();
            lststeps.add(InitializeSRDataTest.createStep(lstSR[0].id,null,null));
            lststeps.add(InitializeSRDataTest.createStep(lstSR[1].id,null,null));
            lststeps.add(InitializeSRDataTest.createStep(lstSR[2].id,null,null));
            insert lststeps;
            
            ManageDealTeam objmdt = new ManageDealTeam();
            objmdt.EvaluateCustomCode(lstSR[0],lststeps[0]);
            objmdt.EvaluateCustomCode(lstSR[1],lststeps[1]);
            objmdt.EvaluateCustomCode(lstSR[2],lststeps[2]);
            objmdt.EvaluateCustomCode(null,null);
        }
        Test.stopTest();
    }
    
    //change agent
    @isTest static void test_method_1() {
        Test.startTest();
        {
            List<User> lstUsers = [select id,name from user];
            NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Deal',true,null);
            insert sr;
            ManageDealTeam.ChangeAgent(SR);
            
            SR.Agent_Name__c = lstUsers[0].id;
            SR.Agency_Type__c = 'Corporate';
            update sr;
            ManageDealTeam.ChangeAgent(SR);
        }
        Test.stopTest();
    }
    
    //Change mgr
    @isTest static void test_method_2() {
        Test.startTest();{
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
            
            NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Deal',true,null);
            sr.Select_User_1__c = mpUsers.get('PC')[0].id;
            sr.Select_User_2__c = mpUsers.get('HOS')[1].id;
            sr.Change_Type__c = 'HOS';
            insert sr;
            
            Deal_Team__c dt = InitializeSRDataTest.createDealTeam(sr.NSIBPM__Parent_SR__c,mpUsers.get('DOS')[0].id,mpUsers.get('HOS')[0].id,mpUsers.get('PC')[0].id);
            insert dt;
            
            ManageDealTeam.ChangeMgr(sr);
            sr.Select_User_2__c = mpUsers.get('DOS')[1].id;
            sr.Change_Type__c = 'DOS';
            update sr;
            ManageDealTeam.ChangeMgr(sr);
        }
        Test.stopTest();
    }
    
    //Change PC
    @isTest static void test_method_3() {
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
            
            user u = mpUsers.get('PC')[0];
            u.managerid = mpUsers.get('HOS')[0].id;
            update u;
            
            NSIBPM__Service_Request__c SR = InitializeSRDataTest.getSerReq('Deal',true,null);
            sr.Select_User_2__c = mpUsers.get('PC')[0].id;
            sr.Change_Type__c = 'Add';
            insert sr;
            ManageDealTeam.ChangePC(sr);
            delete [select id from Deal_Team__c];
            
            u = mpUsers.get('PC')[0];
            u.managerid = mpUsers.get('DOS')[0].id;
            update u;
            
            user u1 = mpUsers.get('DOS')[0];
            u1.managerid = mpUsers.get('HOS')[0].id;
            update u1;
            
            ManageDealTeam.ChangePC(sr);
            delete [select id from Deal_Team__c];
            
            Deal_Team__c dt = InitializeSRDataTest.createDealTeam(sr.NSIBPM__Parent_SR__c,mpUsers.get('DOS')[0].id,mpUsers.get('HOS')[0].id,mpUsers.get('PC')[0].id);
            insert dt;
            
            sr.Select_User_1__c = mpUsers.get('PC')[0].id;
            sr.Select_User_2__c = mpUsers.get('PC')[1].id;
            sr.Change_Type__c = 'Change';
            update sr;
            ManageDealTeam.ChangePC(sr);
            delete [select id from Deal_Team__c];
            
            Deal_Team__c dt1 = InitializeSRDataTest.createDealTeam(sr.NSIBPM__Parent_SR__c,mpUsers.get('DOS')[0].id,mpUsers.get('HOS')[0].id,mpUsers.get('PC')[0].id);
            insert dt1;
            sr.Select_User_1__c = mpUsers.get('PC')[0].id;
            sr.Select_User_2__c = null;
            sr.Change_Type__c = 'Remove';
            update sr;
            ManageDealTeam.ChangePC(sr);

        }
        Test.stopTest();
    }
    
}