@isTest
private class Test_DamacLandingPageController {

	private static User guestUser;
	private static Contact adminContact;
    private static User portalUser;
    private static Account adminAccount;

	static void init(){

		guestUser = [SELECT Id from User where userType='Guest' limit 1];

        adminAccount = InitialiseTestData.getAdminAccount(50000000,'Test agency');
        insert adminAccount;
        
        adminContact = InitialiseTestData.getAdminContact('Test Contact',adminAccount.Id);
        insert adminContact;
        
        Contact agentContact = InitialiseTestData.getAgentContact('Test Agent', adminAccount.Id);
        insert agentContact;
        
        portalUser = InitialiseTestData.getPortalUser('test@test.com', adminContact.Id, 'Admin');

	}
	
	@isTest static void guestUser() {
		Test.startTest();
		init();
		System.runAs(guestUser){
			DamacLandingPageController redirect = new DamacLandingPageController();
			redirect.redirectToHome();
		}
		Test.stopTest();
	}
	
	@isTest static void loggedInUser() {
		Test.startTest();
		init();
		System.runAs(portalUser){
			DamacLandingPageController redirect = new DamacLandingPageController();
			redirect.redirectToHome();
		}
		Test.stopTest();
	}
	
}