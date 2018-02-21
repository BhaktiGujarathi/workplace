/**************************************************************************************************
* Name               : DamacSidebarController                                               
* Description        : An apex page controller for                                              
* Created Date       : NSI - Diana                                                                        
* Created By         : 29/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          29/Jan/2017                                                               
**************************************************************************************************/
@isTest
public class Test_DamacSidebarController {
	public static Contact adminContact;
    public static User portalUser;
    public static Account adminAccount;
    public static User portalOnlyAgent;
    public static Contact agentContact;
    
    static void init(){

        adminAccount = InitialiseTestData.getAdminAccount(50000000,'Test agency');
        insert adminAccount;
        
        adminContact = InitialiseTestData.getAdminContact('Test Contact',adminAccount.Id);
        insert adminContact;
        
        agentContact = InitialiseTestData.getAgentContact('Test Agent', adminAccount.Id);
        insert agentContact;
        
        portalUser = InitialiseTestData.getPortalUser('test@test.com', adminContact.Id, 'Admin');
        portalOnlyAgent = InitialiseTestData.getPortalUser('test1@test.com', agentContact.Id, 'Agent');
        
        Announcement__c futureannouncement = InitialiseTestData.createAnnouncement(System.now().Date(),System.now().Date().addDays(30),true,
                                                                  'SILVER','All');
        insert futureannouncement;
        
        System.runAs(portalUser){
          Assigned_Agent__c assignedAgents =  InitialiseTestData.assignCampaignsToAgents(System.now().Date().addDays(5),System.now().Date(),portalUser.Id);
          insert assignedAgents;
        }
       
    }
    
    @isTest static void showNotificationToAdmin(){
        Test.startTest();
        init();
        System.runAs(portalUser){
            Notification__c notification = InitialiseTestData.createNotification(adminAccount.Id,adminContact.Id);
            DamacSidebarController sidebar = new DamacSidebarController();
           
        }
        
        Test.stopTest();
    }
    
    @isTest static void showNotificationToAgent(){
        Test.startTest();
        init();
        
        System.runAs(portalOnlyAgent){
            Notification__c notification = InitialiseTestData.createNotification(adminAccount.Id,agentContact.Id);
       		DamacSidebarController sidebar = new DamacSidebarController();
        }
        
        Test.stopTest();
    }
}