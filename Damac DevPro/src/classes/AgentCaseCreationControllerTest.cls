/*
* Name : Pavithra Gajendra
* Date : 02/08/2017
* Purpose : Test class for Controller for case creation by agent 
* Company : NSI Gulf
* 
*/
@isTest(SeeAllData=true)
private class AgentCaseCreationControllerTest {

	public static contact agentContact ;
	public static User portalUser ;
	public static Case__c newCase = new Case__c();
	public static Agency_Tier_Case_Status__c agencyTier ;


    /*
    * Initialise Data
    */
	static void init(){

		agentContact = InitialiseTestData.getCorporateAgencyContact('Agent1');
        insert agentContact;  
        
        CollaborationGroup colGroup = InitialiseTestData.getDefaultCollaborationGroup('DAMAC Agents 3'); 
        insert colGroup ;

        portalUser = InitialiseTestData.getPortalUser('test456@email.com',agentContact.Id);
        insert portalUser;
        
        String agencyTierValue = 'SILVER';
        if(agentContact.Account.Agency_Tier__c !='N/A' && agentContact.Account.Agency_Tier__c !=null){
            agencyTierValue = agentContact.Account.Agency_Tier__c ;
        }
        agencyTierValue = 'Test';
        System.debug('Agency TierValue '+agencyTierValue);
        agencyTier = InitialiseTestData.getAgencyTierDetails(agencyTierValue);
        System.debug('Agency Tier '+agencyTier);
        insert agencyTier ;
	}
	
	/*
    * Create Case as portal User 
    */
	@isTest static void createCasePortalUser() {
		
		   Test.StartTest();
		   init();
		   Account newAcc = InitialiseTestData.getCorporateAccount('Agent 2');
		   newAcc.Quarter_2_Sales__c = 200000000 ;
		   insert newAcc ;
		   
		  Contact agentContact1  = new Contact();
          agentContact1.LastName = 'Agent 2';
          agentContact1.AccountId = newAcc.Id ; 
          insert agentContact1 ;    
            
          User portalUser1 = InitialiseTestData.getPortalUser('test4567@email.com',agentContact1.Id);
          insert portalUser1;
		   
		   system.runAs(portalUser1) {
			   ApexPages.StandardController sc = new ApexPages.StandardController(newCase);
	           AgentCaseCreationController casePage = new AgentCaseCreationController(sc); 	
	           newCase.Case_Subject__c = 'Book a Hotel' ;
	           newCase.Priority__c = 'Medium' ;
	           newCase.Case_Description__c = 'Testing Case Creation from Page' ;
	           newCase.Date_Time__c = Datetime.now()+5 ;
	           casePage.saveCase();
            }
           Test.stopTest();
       
	}
	
	    /*
        * Create Case as portal User with no subject 
        */
		@isTest static void createCaseWithNoSubUser() {
		   Test.StartTest();
		   init();
		   system.runAs(portalUser) {
			   ApexPages.StandardController sc = new ApexPages.StandardController(newCase);
	           AgentCaseCreationController casePage = new AgentCaseCreationController(sc); 	
	           newCase.Priority__c = 'Medium' ;
	           newCase.Case_Description__c = 'Testing Case Creation from Page' ;
	           newCase.Date_Time__c = Datetime.now()+5 ;
	           casePage.saveCase();
            }
           Test.stopTest();
	   }
	   
	   	/*
        * Create Case as portal User for Agency tier
        */
        @isTest static void createCasePortalUserForTier() {
		
    		   Test.StartTest();
    		   Account newAcc1 = InitialiseTestData.getCorporateAccount('Agent 3');
    		   newAcc1.Quarter_3_Sales__c = 2000000 ;
    		   insert newAcc1 ;
    		   
    		  Contact agentContact2  = new Contact();
              agentContact2.LastName = 'Agent 3';
              agentContact2.AccountId = newAcc1.Id ; 
              insert agentContact2 ;    
                
              User portalUser2 = InitialiseTestData.getPortalUser('test567@email.com',agentContact2.Id);
              insert portalUser2;
    		   
    		   system.runAs(portalUser2) {
    			   ApexPages.StandardController sc = new ApexPages.StandardController(newCase);
    	           AgentCaseCreationController casePage = new AgentCaseCreationController(sc); 	
    	           newCase.Case_Subject__c = 'Book a Hotel' ;
    	           newCase.Priority__c = 'Medium' ;
    	           newCase.Case_Description__c = 'Testing Case Creation from Page' ;
    	           newCase.Date_Time__c = Datetime.now()+5 ;
    	           casePage.saveCase();
                }
               Test.stopTest();
    	}
	   
}