/**************************************************************************************************
* Name               : Test_DamacProjectUnitController                                             
* Description        : An apex page controller for DamacProjectUnitController                                         
* Created Date       : NSI - Diana                                                                        
* Created By         : 02/21/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          02/21/2017                                                           
**************************************************************************************************/
@isTest
public class Test_DamacProjectUnitController {
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
            ApexPages.currentPage().getParameters().put('Id',property.ID);
        }
    }
    
    @isTest static void showProjects(){
        Test.startTest();
        init();
        System.runAs(portalUser){
            DamacProjectUnitsController  damacProjectController = new DamacProjectUnitsController();
        }
        Test.stopTest();
    }
    
    @isTest static void filterInventories(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            ApexPages.currentPage().getParameters().put('locationNamesSelected','\'Dubai\'');
            ApexPages.currentPage().getParameters().put('projectTypeSelected','\'Residential\'');
            ApexPages.currentPage().getParameters().put('BedroomsSelected','\'1\'');
            ApexPages.currentPage().getParameters().put('Location','\'1\'');
            ApexPages.currentPage().getParameters().put('sfdc.tabName','\'1\'');
            ApexPages.currentPage().getParameters().put('MinPrice','12333');
            ApexPages.currentPage().getParameters().put('MaxPrice','343223');
            ApexPages.currentPage().getParameters().put('UnitBedrooms','1');
            ApexPages.currentPage().getParameters().put('Bedrooms','1');
            
            
            
            DamacProjectUnitsController damacProjectController = new DamacProjectUnitsController();
            damacProjectController.filterInventories();
            
        }
        
        Test.stopTest();
    }
}