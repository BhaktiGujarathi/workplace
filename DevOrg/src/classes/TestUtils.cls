public with sharing class TestUtils {
	
    public static OnDeckClient.Owner createOwner(string ownerNumber){
        OnDeckClient.Owner owner = new OnDeckClient.Owner();
        owner.email = 'test' + ownerNumber + '@email.test';
        owner.phone = '1234567890';
        owner.name = 'nameTest' + ownerNumber;
        owner.address.street = 'streetTest' + ownerNumber;
        owner.address.city = 'cityTest' + ownerNumber;
        owner.address.state = 's' + ownerNumber;
        owner.address.zip = 'z' + ownerNumber;
        owner.ssn = 'ssnTest' + ownerNumber;
        owner.ownershipPercentage = 50;
        owner.dob = Date.today();
        return owner;
    }
    
    public static OnDeckClient.BusinessData createBusinessData (){
        OnDeckClient.BusinessData bd = new OnDeckClient.BusinessData();
        
        bd.annualRevenue = 1;
        bd.applicationNumber = 'test';
        bd.averageBankBalance = 1;
        bd.averageCreditCardVolume = 1;
        bd.businessCredit = 'test';
        bd.businessID = 'test';
        bd.businessInceptionDate = Date.today();
        bd.businessIndustry = 'test';
        bd.businessName = 'test';
        bd.businessPhone = 'test';
        bd.companyName = 'test';
        bd.decisionStatus = 'test';
        bd.doingBusinessAs = 'test';
        bd.loanPurpose = 'test';
        bd.owner1 = createOwner('1');
        bd.owner2 = createOwner('2');
        bd.personalCredit = 'test';
        bd.prequalAmount = '1';
        bd.prequalified = 'true';
        bd.prequalTerm = 'test';
        bd.taxID = '123456780';
        bd.url = 'test';
        return bd;
    }

    public static void createSettings() {
    
        Bank_API_Settings__c settings = new Bank_API_Settings__c();
        BankIntegrationSetupController bc = new BankIntegrationSetupController();
        bc.settings.Name = 'OnDeck';
        bc.settings.Password__c = 'testPass';
        bc.settings.Attribute_1__c = 'testAttribute';
        bc.settings.Api_Url__c = 'test';
        
        bc.saveBank();
    }
}