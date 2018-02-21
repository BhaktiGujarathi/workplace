@isTest
private class Test_DamacInventoryDetail {
	
	 public static Contact adminContact;
    public static User portalUser;
    public static Account adminAccount;
    public static User portalOnlyAgent;
    private static Inventory__c inventoryObj;
    
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
           inventoryObj = InitialiseTestData.getInventoryDetails('INV-001','123','ACZ11',123,123);
           insert inventoryObj;
        }
    }

	@isTest static void InventoryPDFDetail() {
		Test.startTest();
		init();

		System.runAs(portalUser){
			ApexPages.StandardController inventoryStd = new ApexPages.StandardController(inventoryObj);
			InventoryPDFDetailPage inventory = new InventoryPDFDetailPage(inventoryStd);
		}

		Test.stopTest();
	}
	

	
}