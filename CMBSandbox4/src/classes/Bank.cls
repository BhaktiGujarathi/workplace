global with sharing class Bank {
	
	public String    name;
    public String    bankId;
    public String    billingCity;
    public String    billingPostalCode;
    public String    billingState;
    public String    billingStreet;
    public String    email;
    public String    phone;
    public String    website;
    public Program[] programs;
    
    public Bank(Bank__c b) {
        name = b.Name;
        bankId = b.Bank_Id__c;
        billingCity = b.Billing_City__c;
        billingPostalCode = b.Billing_Postal_Code__c;
        billingState = b.Billing_State__c;
        billingStreet = b.Billing_Street__c;
        email = b.Email__c;
        phone = b.Phone__c;
        website = b.Website__c;
        programs = new Program[]{};
    }
}