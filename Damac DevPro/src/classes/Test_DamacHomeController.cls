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
public class Test_DamacHomeController {
    
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
    
    @isTest static void showMonthlyBrokerage(){
        
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            //This month
            Agent_Commission__c agentCommission = InitialiseTestData.createAgentCommission(adminAccount.Id,System.now().Date(),System.now().Date());
            insert agentCommission;
            
            //last month 
            Date twoMonthsBackDate = System.now().Date().addDays(-30);
            Agent_Commission__c agentCommission1 = InitialiseTestData.createAgentCommission(adminAccount.Id,twoMonthsBackDate,null);
            insert agentCommission1;
            
            Date twoMonthsBackDate1 = System.now().Date().addDays(-29);
            Agent_Commission__c agentCommission2 = InitialiseTestData.createAgentCommission(adminAccount.Id,twoMonthsBackDate1,null);
            insert agentCommission2;
            
        	DamacHomeController home = new DamacHomeController();
			
        }

        Test.stopTest();
    }
    
    @isTest static void showMonthlySales(){
        
        Test.startTest();
        init();
        
        System.runAs(portalUser){
            
             //This month
             NSIBPM__Service_Request__c SR1 = InitialiseTestData.createBookingServiceRequest(true,true,adminAccount.ID,System.now().Date());
             Booking__c booking1 = InitialiseTestData.createBookingRecords(adminAccount.ID,SR1,10000000,'AL');
            
            //This month
            NSIBPM__Service_Request__c SR2 = InitialiseTestData.createBookingServiceRequest(true,false,adminAccount.ID,System.now().Date().addDays(-2));
            Booking__c booking2 = InitialiseTestData.createBookingRecords(adminAccount.ID,SR2,10000000,'AR');
            
            NSIBPM__Service_Request__c SR3 = InitialiseTestData.createBookingServiceRequest(false,true,adminAccount.ID,System.now().Date().addMonths(-1));
            Booking__c booking3 = InitialiseTestData.createBookingRecords(adminAccount.ID,SR3,10000000,'AL');
            
             NSIBPM__Service_Request__c SR4 = InitialiseTestData.createBookingServiceRequest(false,true,adminAccount.ID,System.now().Date().addMonths(-2));
            Booking__c booking4 = InitialiseTestData.createBookingRecords(adminAccount.ID,SR4,10000000,'AR');
            
            NSIBPM__Service_Request__c SR5 = InitialiseTestData.createBookingServiceRequest(false,false,adminAccount.ID,System.now().Date().addMonths(-2));
            Booking__c booking5 = InitialiseTestData.createBookingRecords(adminAccount.ID,SR5,10000000,'AU');
            
            DamacHomeController home = new DamacHomeController();
        }
        
        Test.stopTest();
        
    }
    
    

}