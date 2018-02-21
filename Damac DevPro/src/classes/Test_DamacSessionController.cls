/**************************************************************************************************
* Name               : DamacSessionController                                               
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
public class Test_DamacSessionController {
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
        
       
    }
    
    @isTest static void getSessionDetails(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            DamacSessionController sessionController = new DamacSessionController();
            
        }
        
        Test.stopTest();
    }
}