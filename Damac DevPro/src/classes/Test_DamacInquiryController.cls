/**************************************************************************************************
* Name               : Test_DamacInquiryController                                               
* Description        : An apex page controller for DamacInquiryController                                         
* Created Date       : NSI - Diana                                                                        
* Created By         : 02/21/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          02/21/2017                                                           
**************************************************************************************************/
@isTest
public class Test_DamacInquiryController {
	
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
            Inquiry__c CIL = InitialiseTestData.getInquiryDetails(DAMAC_Constants.CIL_RT,1);
            insert CIL;
        }
        
        System.runAs(portalOnlyAgent){
            Inquiry__c CIL = InitialiseTestData.getInquiryDetails(DAMAC_Constants.CIL_RT,2);
            insert CIL;
        } 
        
        ApexPages.currentPage().getParameters().put('sfdc.tabName','aX982364');
    }
    
    @isTest static void showCILForAdmin(){
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            DamacInquiryController inquiry = new DamacInquiryController();
            inquiry.loadCILData();
            system.assert(inquiry.CILLists.size()==2);
        }
        
        Test.stopTest();
    }
    
    @isTest static void showCILForAgent(){
        Test.startTest();
        init();
        
        System.runAs(portalOnlyAgent){
             DamacInquiryController inquiry = new DamacInquiryController();
            inquiry.loadCILData();
            system.assert(inquiry.CILLists.size()==1);
        }
        
        Test.stopTest();
    }
}