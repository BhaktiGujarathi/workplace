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
public class Test_DamacCasesController {
	
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
            Case__c cases = InitialiseTestData.createCases();
            insert cases;
        }
        
        System.runAs(portalOnlyAgent){
            Case__c cases = InitialiseTestData.createCases();
            insert cases;
        } 
        
        ApexPages.currentPage().getParameters().put('sfdc.tabName','aX982364');
    }
    
    @isTest static void showCasesForAdmin(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            DamacCaseController caseController = new DamacCaseController();
            caseController.loadCasesList();
            system.assert(caseController.caseList.size()==2);
        }
        
        Test.stopTest();
    }
    
    @isTest static void showCasesForAgent(){
        Test.startTest();
        init();
        
        System.runAs(portalOnlyAgent){
            DamacCaseController caseController = new DamacCaseController();
            caseController.loadCasesList();
            system.assert(caseController.caseList.size()==1);
        }
        
        Test.stopTest();
    }
}