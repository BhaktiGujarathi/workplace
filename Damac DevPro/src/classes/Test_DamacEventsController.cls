/**************************************************************************************************
* Name               : Test_DamacEventsController                                              
* Description        : An apex page controller for DamacEventsController                                           
* Created Date       : NSI - Diana                                                                        
* Created By         : 02/21/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          02/21/2017                                                           
**************************************************************************************************/
@isTest
public class Test_DamacEventsController {

    public static Contact adminContact;
    public static User portalUser;
    public static Account adminAccount;
    public static User portalOnlyAgent;
    
    static void init(){

        adminAccount = InitialiseTestData.getAdminAccount(50000000,'Test agency');
        insert adminAccount;
        
        adminContact = InitialiseTestData.getAdminContact('Test Contact',adminAccount.Id);
        insert adminContact;
        
        Contact agentContact = InitialiseTestData.getAgentContact('Test Agent', adminAccount.Id);
        insert agentContact;
        
        portalUser = InitialiseTestData.getPortalUser('test@test.com', adminContact.Id, 'Admin');
        portalOnlyAgent = InitialiseTestData.getPortalUser('test1@test.com', agentContact.Id, 'Agent');
        
        System.runAs(portalUser){
          Assigned_Agent__c assignedAgents =  InitialiseTestData.assignCampaignsToAgents(System.now().Date().addDays(5),System.now().Date(),portalUser.Id);
          insert assignedAgents;
        }
        
    }
    
    @isTest static void showAllEvents(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            DamacEventsController eventsController = new DamacEventsController();
            
            system.assert(eventsController.allevents.size() >0);
        }
        
        Test.stopTest();
    }
        
    
    
}