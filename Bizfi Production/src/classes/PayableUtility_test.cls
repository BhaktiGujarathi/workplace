@isTest

public class PayableUtility_test{
    

    public static testmethod void m1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser49@testorg.com');
        insert u;    
        User u1;
        System.runAs(u) {
            USerRole uRole1 = new USerRole(Name ='GM1',developerName='GM1');
            insert uRole1;
            USerRole uRole2 = new USerRole(Name='GM2',developerName='GM2',parentRoleId=uRole1.Id);
            insert uRole2;
            USerRole uRole3 = new USerRole(Name='GM3',developerName='GM3',parentRoleId=uRole2.Id);
            insert uRole3;
            USerRole uRole4 = new USerRole(Name='GM4',developerName='GM4',parentRoleId=uRole3.Id);
            insert uRole4;
            
            Profile p1 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id, UserRoleId=uRole4.id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser48@testorg.com');
            insert u1;
        }
        
        
        
         
        Account acc = new Account(name='test',McaApp__User__c=u1.Id);
        insert acc;
        
        McaApp__Payable__c pay = new McaApp__Payable__c();
        pay.McaApp__Account__c=acc.id;
        insert pay;
        
    
    
    
    }



}