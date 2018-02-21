@istest
public class TaskTriggerHandlerTest{


    static testmethod void TaskTriggerHandler_Methods(){
        
        
    	Test.startTest();
         // Insert Inquiry        
        Inquiry__c i = new Inquiry__c();
        i.First_Name__c = 'Lead';
        i.Last_Name__c = 'Lead';
        i.Email__c = 'lead@lead.com';
        i.Inquiry_Source__c = 'Web';
        i.Organisation_Name__c = 'abc';
        insert i;
        
        // Insert Inquiry related tasks
        task tsk = new task();
        tsk.whatid = i.id;
        tsk.subject = 'Testing';
        insert tsk;
        tsk.subject = 'Updated';
        update tsk;
        Test.stopTest();
    
    }
    static testmethod void TaskTriggerHandler_Methods1(){
        
        
    	Test.startTest();
        
         // Insert Inquiry        
        Inquiry__c i = new Inquiry__c();
        i.First_Name__c = 'Lead';
        i.Last_Name__c = 'Lead';
        i.Email__c = 'lead@lead.com';
        i.Inquiry_Source__c = 'Digital';
        i.Organisation_Name__c = 'abc';
        insert i;
        
        // Insert Inquiry related tasks
        task tsk = new task();
        tsk.whatid = i.id;
        tsk.subject = 'Call';
        insert tsk;
        tsk.subject = 'Updated';
        update tsk;
        

         // Insert Inquiry related tasks
        task tsk1 = new task();
        tsk1.whatid = i.id;
        tsk1.subject = 'Call';
        tsk1.User_Ext_No__c = '432';
        upsert tsk1;
        
        delete tsk;
        Test.stopTest();
        
        }
	
        static testmethod void TaskTriggerHandler_Methods2(){
        
        Profile standardProfile = [SELECT Id FROM profile WHERE Name = 'System Administrator'];
        UserRole groupHsseRole = [SELECT Id FROM UserRole WHERE Name = 'PC1'];
        User userObject = new User();
        userObject.alias = 'standtest';
        userObject.alias = userObject.alias.subString(0, 8);
        userObject.email = 'standtest@damac.ae';
        userObject.emailencodingkey = 'UTF-8';
        userObject.lastname = 'standtest CTI';
        userObject.languagelocalekey = 'en_US';
        userObject.localesidkey = 'en_US';
        userObject.profileId = standardProfile.Id;
        userObject.timezonesidkey = 'America/Los_Angeles';
        userObject.username = 'standtest@damac.ae';
        userObject.UserRoleId = groupHsseRole.Id;
        userObject.Extension = '123';
        userObject.Break_Time__c = system.now();
            
            system.runAs(userObject){
                
                Inquiry__c i = new Inquiry__c();
        i.First_Name__c = 'Lead';
        i.Last_Name__c = 'Lead';
        i.Email__c = 'lead@lead.com';
        i.Inquiry_Source__c = 'Digital';
        i.Organisation_Name__c = 'abc';
        insert i;
        
        // Insert Inquiry related tasks
        task tsk = new task();
        tsk.whatid = i.id;
        tsk.subject = 'Call';
        tsk.OwnerId = userObject.Id;
        tsk.User_Ext_No__c = '123';
        insert tsk;
        tsk.subject = 'Updated';
        update tsk;
        

         // Insert Inquiry related tasks
        task tsk1 = new task();
        tsk1.whatid = i.id;
        tsk1.subject = 'Call';
        tsk1.OwnerId = userObject.Id;
        tsk1.User_Ext_No__c = '432';
        upsert tsk1;
        
        delete tsk;
                
            }

    }
    	

}