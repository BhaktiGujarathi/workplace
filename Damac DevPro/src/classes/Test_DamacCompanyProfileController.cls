/**************************************************************************************************
* Name               : Test_DamacCasesController                                               
* Description        : An apex page controller for DamacCasesController                                          
* Created Date       : NSI - Diana                                                                        
* Created By         : 02/21/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          02/21/2017                                                           
**************************************************************************************************/
@isTest
public class Test_DamacCompanyProfileController {
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
         
        InitialiseTestData.createPageFlow(LABEL.Agent_Portal_Registration_Update_Page_Flow_Name);

    }
    
    @isTest static void showCompanyProfileData(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            DamacCompanyProfileController companyProfile = new DamacCompanyProfileController();
            system.assert(companyProfile.accountDetail != null);
            companyProfile.isError = true;
            companyProfile.init();
        }
        
        Test.stopTest();
    }
    
    
}