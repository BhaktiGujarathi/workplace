@isTest
private class Test_DamacCommissionController {
	private static Contact adminContact;
    private static User portalUser;
    private static Account adminAccount;

    static void init(){
    	 adminAccount = InitialiseTestData.getAdminAccount(50000000,'Test agency');
        insert adminAccount;
        
        system.debug('--adminAccount--'+adminAccount.Agency_Tier__c);
        
        adminContact = InitialiseTestData.getAdminContact('Test Contact',adminAccount.Id);
        insert adminContact;
        
        Contact agentContact = InitialiseTestData.getAgentContact('Test Agent', adminAccount.Id);
        insert agentContact;
        
        portalUser = InitialiseTestData.getPortalUser('test@test.com', adminContact.Id, 'Admin');
    }

	@isTest static void getCommission() {
		Test.startTest();
        init();

        System.runAs(portalUser){
            Agent_Commission__c agentCommission = InitialiseTestData.createAgentCommission(adminAccount.Id,System.now().Date(),System.now().Date());
            insert agentCommission;

            DamacCommissionController commission = new DamacCommissionController();

        }
        Test.stopTest();
	}
	
}