/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class NVMSOrderFormExtensionTest {
	static testMethod void initSetup(){
		List<NVMS_Configuration__c> configList = new List<NVMS_Configuration__c>();
    	NVMS_Configuration__c config = new NVMS_Configuration__c();
    	config.name = 'CALLBACK_URL';
    	config.value__c = 'http://nvms-developer-edition.na22.force.com/refurl';
    	configList.add(config);
    	config = new NVMS_Configuration__c();
    	config.name = '	DEFAULT_SERVICES';
    	config.value__c = '2900';
    	configList.add(config);
    	config = new NVMS_Configuration__c();
    	config.name = 'END_POINT_SUFFIX';
    	config.value__c = 'NVMSExchangeDemo.asmx';
    	configList.add(config);
    	config = new NVMS_Configuration__c();
    	config.name = 'END_POINT_URL';
    	config.value__c = 'http://exchange2.nvms.com/';
    	configList.add(config);
    	config = new NVMS_Configuration__c();
    	config.name = 'NVMS_TOKEN';
    	config.value__c = 'bf1ea5b0-fb90-4d94-a909-00172c5c3290';
    	configList.add(config);
    	config = new NVMS_Configuration__c();
    	config.name = 'NVMS_USER_ID';
    	config.value__c = '2089';
    	configList.add(config);
    	config = new NVMS_Configuration__c();
    	config.name = 'PropAddress';
    	config.value__c = 'Property_Address__c';
    	configList.add(config);
    	
    	insert configList;
	}
    static testMethod void NVMSOrderFormExtension() {
    	NVMSOrderFormExtensionTest.initSetup();
		Account accObj = new Account();
		accObj.name = 'Test Account';
		accObj.billingStreet = 'Test Street';
		accObj.billingCity = 'Test City';
		accObj.billingState = 'Test State';
		accObj.billingCountry = 'Test Country';
		accObj.billingPostalCode = '12345';
		insert accObj;
		
        Opportunity oppObj = new Opportunity();
        NVMSOrderFormExtension ext = new NVMSOrderFormExtension(new ApexPages.Standardcontroller(oppObj));
        ext.oppObj.name = 'Test';
        ext.oppObj.accountId = accObj.id;
        
        Test.startTest();
        ext.PopulateAddress();
        ext.addOrder();
        ext.AttachOrderPDFDocument();
        Test.stopTest();
    }
    
     static testMethod void NVMSCallbackControllerTest() {
    	NVMSOrderFormExtensionTest.initSetup();
		Account accObj = new Account();
		accObj.name = 'Test Account';
		accObj.billingStreet = 'Test Street';
		accObj.billingCity = 'Test City';
		accObj.billingState = 'Test State';
		accObj.billingCountry = 'Test Country';
		accObj.billingPostalCode = '12345';
		insert accObj;
		
        Opportunity oppObj = new Opportunity();
        NVMSOrderFormExtension ext = new NVMSOrderFormExtension(new ApexPages.Standardcontroller(oppObj));
        ext.oppObj.name = 'Test';
        ext.oppObj.accountId = accObj.id;
        ext.PopulateAddress();
        ext.addOrder();
        ApexPages.currentPage().getParameters().put('jobid','344208');
        NVMSCallbackController callback = new NVMSCallbackController();
        
        Test.startTest();
        callback.updateOpportunitySetting();
        //NVMSOrderScheduler.UpdateOrderStatus();
        Test.stopTest();
        
    }
}