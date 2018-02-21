/**************************************************************************************************
* Name               : Test_DamacProjectController                                               
* Description        : An apex page controller for DamacProjectController                                         
* Created Date       : NSI - Diana                                                                        
* Created By         : 02/21/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          02/21/2017                                                           
**************************************************************************************************/
@isTest
public class Test_DamacProjectController {
    
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
           Property__c property = InitialiseTestData.insertProperties();
            InitialiseTestData.createInventoryUser(property);
        }
    }
    
    @isTest static void showProjects(){
        Test.startTest();
        init();
        System.runAs(portalUser){
            DamacProjectController damacProjectController = new DamacProjectController();
        }
        Test.stopTest();
    }
    
    @isTest static void filterProjects(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            ApexPages.currentPage().getParameters().put('locationNamesSelected','\'Dubai\'');
            ApexPages.currentPage().getParameters().put('projectTypeSelected','\'Residential\'');
            ApexPages.currentPage().getParameters().put('BedroomsSelected','\'1\'');
            ApexPages.currentPage().getParameters().put('sfdc.tabName','\'1\'');
            ApexPages.currentPage().getParameters().put('Bedrooms','1');
            ApexPages.currentPage().getParameters().put('type','1');
            ApexPages.currentPage().getParameters().put('Location','1');
            DamacProjectController damacProjectController = new DamacProjectController();
            damacProjectController.filterProjects();
            
        }
        
        Test.stopTest();
    }
    
    
}