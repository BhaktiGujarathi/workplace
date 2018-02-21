@istest
public class DealTeamTrgHandlerTest{

    @testSetup static void setupData() {
        try{
            list<string> rolenames = new List<string>{'PC','HOS','DOS','HOD'};
                Map<string,UserRole> mpRoles = InitializeSRDataTest.createRoles(rolenames);
            
            set<string> stProfileNames = new set<string>{'Property Consultant','Director of Sales','Head of Sales','Head of Department'};
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
                if(p.name == 'Head of Department')
                    mpProfileIDRoleID.put(p.id,mpRoles.get('HOD').id);
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
            
        Account a = new Account();
        a.Name = 'Test Account';        
        insert a;
        
        Id PerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a1 = new Account();
        a1.FirstName = 'Test Account';
        a1.LastName = 'Acc';
        a1.Phone_Key__c = 'ABC';
        a1.Email_Key__c = 'TEST@TEST.COM';
        a1.recordtypeid = PerRecordTypeId;
        insert a1;
        
        NSIBPM__SR_Template__c SRTemplate = new NSIBPM__SR_Template__c();
        srtemplate.NSIBPM__SR_RecordType_API_Name__c = 'Deal';
        insert SRTemplate;
        
        Id RecType1 = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
        sr.NSIBPM__Customer__c = a.id;
        sr.RecordTypeId = RecType1;
        sr.Agency__c = a.id;
        sr.NSIBPM__SR_Template__c = SRTemplate.id;
        sr.Agency_Type__c = 'Corporate';        
        sr.Registration_Date__c = system.today();
        sr.doc_ok__c = true;
        sr.DP_ok__c = true;
        insert sr;
        
        user u = mpUsers.get('PC')[0];
        u.managerid = mpUsers.get('DOS')[0].id;
        update u;
        
        
        deal_team__c dt = new deal_team__c();
        dt.Associated_PC__c = u.id;
        dt.Associated_Deal__c  = sr.id;
        insert dt;
        
        u.managerid = mpUsers.get('HOS')[0].id;
        update u;
        
        
        deal_team__c dt1 = new deal_team__c();
        dt1.Associated_PC__c = u.id;
        dt1.Associated_Deal__c  = sr.id;
        
        insert dt1;
        
        u.managerid = mpUsers.get('HOS')[0].id;
        update u;
        
        
        deal_team__c dt2 = new deal_team__c();
        dt2.Associated_PC__c = u.id;
        dt2.Associated_Deal__c  = sr.id;
        insert dt2;
        
        //u.managerid = mpUsers.get('HOD')[0].id;
        //update u;
        
        
        deal_team__c dt3 = new deal_team__c();
        dt3.Associated_PC__c = u.id;
        dt3.Associated_Deal__c  = sr.id;
        dt3.status__c = 'Inactive';
        insert dt3;
        update dt3;
            
        }
        Test.stopTest();
    }
    
   
    
  
    
    
}