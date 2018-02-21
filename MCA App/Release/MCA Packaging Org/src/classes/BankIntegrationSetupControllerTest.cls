@isTest
private class BankIntegrationSetupControllerTest {

    static testMethod void success() {

        BankIntegrationSetupController bc = new BankIntegrationSetupController();
        
        System.assertEquals('Home', bc.getSubtitle());
        bc.editBank();
        System.assertEquals('New null', bc.getSubtitle());
        bc.selectType();
        System.assertEquals('new', bc.mode);
        bc.settings.Name = 'new bank';
        System.assertEquals('New new bank', bc.getSubtitle());
        bc.settings.Password__c = 'Password';
        bc.saveBank();
        System.assertEquals('list', bc.mode);
        System.assertNotEquals(bc.getMaskedPassword(), null);
        bc.selectType();
        System.assertEquals('list', bc.mode);
        bc.cancel();
        System.assert(bc.getBankSettings() != null);
        
        
        bc.deleteBank();
        System.assert(bc.getBankSettings() != null);
        
        bc.newBank();
        System.assertEquals('Select Type', bc.getSubtitle());

    }
    
    static testMethod void settingsTest(){
        
        ApexPages.currentPage().getParameters().put('name', 'Home');
        BankIntegrationSetupController bc = new BankIntegrationSetupController();
        System.assertEquals('Home', bc.getSubtitle());
        System.assertEquals(bc.auxLookup.AccountId, bc.settings.Funder_Account__c);
        bc.saveBank();

    }
    
    /*
    static testMethod void selectTypeTest(){
    	//ApexPages.currentPage().getParameters().put('name', 'Home');
        BankIntegrationSetupController bc = new BankIntegrationSetupController();
        bc.settings = null;
        bc.selectType();
        system.assertEquals('new', bc.mode);
    } */
    
    static testMethod void deleteBankTest() {
    	
        ApexPages.currentPage().getParameters().put('mode', 'new');
        BankIntegrationSetupController bc = new BankIntegrationSetupController();
        bc.deleteBank(); 
        
        System.assert(bc.settings == null);
    }
    
}