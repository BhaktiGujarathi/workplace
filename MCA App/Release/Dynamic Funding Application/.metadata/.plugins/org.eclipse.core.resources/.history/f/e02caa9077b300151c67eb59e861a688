/* 
 *  Utility class to retrun query for each field sets.
 *  Function will return query by fetching fields from field sets.
 *  Revision History: 
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Ripal Patel            10-July 2015           Initial Draft 

 */


public with sharing class FundingApplicationUtility {
    //variable declaration
    public String query1;
    public static final string owner1 = 'McaApp__Owner_1__c';
    public static final string owner1LastName  = 'McaApp__Owner_1__r.LastName';
    public static final string owner2 = 'McaApp__Owner_2__c';
    public static final string owner2LastName = 'McaApp__Owner_2__r.LastName';
    public static final string accountName = 'Account.Name';
    public List<Schema.FieldSetMember> contact1FieldSet;
    public List<Schema.FieldSetMember> contact2FieldSet;
    
    public FundingApplicationUtility() {
        contact1FieldSet = new List<Schema.FieldSetMember>();
        contact2FieldSet = new List<Schema.FieldSetMember>();
    }
    
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Opportunity.FieldSets.ADDITIONAL_BUSINESS_INFORMATION.getFields();
    }
    //This method returns the list for BUSINESS INFORMATION section
    public Opportunity getOpportunityListBusiInfo(String opportunityId) {

        query1 = 'SELECT Id,';
        for(Schema.FieldSetMember f : this.getFields()) {
            query1 += f.getFieldPath() + ',';
        }
        system.debug('*****query1 field sets***'+query1);
        if(!query1.contains(owner1))
           query1 += owner1 + ',';
        if(!query1.contains(owner1LastName))
           query1 += owner1LastName + ',';
        if(!query1.contains(owner2))
           query1 += owner2 + ',';
        if(!query1.contains(owner2LastName))
           query1 += owner2LastName + ',';
        if(!query1.contains(accountName))
           query1 += accountName + ',';
        
        query1 = query1.subString(0, query1.length() - 1);
        query1 +=' FROM Opportunity';
        query1 += ' Where Id =';
        query1 += '\''+opportunityId+'\'' ;
        query1 +=' LIMIT 1 ';
        system.debug('*****query1***'+query1);
        return Database.query(query1);
     }
    
     public List<Schema.FieldSetMember> getFields1() {
        return SObjectType.Opportunity.FieldSets.MCAExtension1__ADDITIONAL_OWNER_OFFICER_INFORMATION.getFields();
     }
     
     
    // get contact 1 value 
    public Contact getContact1Value(Id ContactId) {
        String query = getContactQuery(getFields1(), 'McaApp__Owner_1__r.');
        if(query <> null) {
            query += ' WHERE Id =\'' + ContactId + '\' ';
            return Database.query(query);
        }
        return null;
    }// End getContact1Value()
    
    // get contact 1 value 
    public Contact getContact2Value(Id ContactId) {
        System.debug('Inside Owner 2 Field Set ----->');
        String query = getContactQuery(getFields2(), 'McaApp__Owner_2__r.');
        if(query <> null) {
            query += ' WHERE Id =\'' + ContactId + '\' ';
            return Database.query(query);
        }
        return null;
    }// End getContact2Value()
     
    // It is used to create contact query using field set.
    public String getContactQuery(List<Schema.FieldSetMember> conFields, String conAPIName) {
        Boolean isFieldPresent = false;
        String contactQuery = 'SELECT Id,';
        system.debug('conFields ------->'+conFields);
        // Iterate contact1 fields.
        for(Schema.FieldSetMember field : conFields) {
            if((field.getFieldPath()).contains(conAPIName)) {
                contactQuery += (field.getFieldPath()).replace(conAPIName, '');
                contactQuery += ',';
                system.debug('field ------->'+contactQuery);
                isFieldPresent = true;
            }    
        }//End For 
        
        contactQuery = contactQuery.removeEnd(',');
        
        contactQuery += ' FROM Contact';
        if(isFieldPresent)
            return contactQuery;
        return null;
    }// End getContact1Value()
    
     //This method returns the list for OWNER/OFFICER INFORMATION section
     public Opportunity getOpportunityListOwnerOfficerInfo(String opportunityId) {

        query1 = 'SELECT Id,';
        for(Schema.FieldSetMember f : this.getFields1()) {
            query1 += f.getFieldPath() + ',';
        }
        system.debug('*****query1 field sets***'+query1);
        if(!query1.contains(owner1))
           query1 += owner1 + ',';
        if(!query1.contains(owner1LastName))
           query1 += owner1LastName + ',';
        if(!query1.contains(owner2))
           query1 += owner2 + ',';
        if(!query1.contains(owner2LastName))
           query1 += owner2LastName + ',';
        if(!query1.contains(accountName))
           query1 += accountName + ',';
        
        query1 = query1.subString(0, query1.length() - 1);
        query1 +=' FROM Opportunity';
        query1 += ' Where Id =';
        query1 += '\''+opportunityId+'\'' ;
        query1 +=' LIMIT 1 ';
        system.debug('*****query1 final ***'+query1);
        
        return Database.query(query1);
    }
        
    public List<Schema.FieldSetMember> getFields2() {
        return SObjectType.Opportunity.FieldSets.ADDITIONAL_2nd_OWNER_OFFICER_INFORMATION.getFields();
        
    }
        
    //This method returns the list for 2nd OWNER/OFFICER INFORMATION (if applicable) section
    public Opportunity getOpportunityList2ndOwnerOfficerInfo(String opportunityId) { 

        query1 = 'SELECT Id,';
        for(Schema.FieldSetMember f : this.getFields2()) {
            query1 += f.getFieldPath() + ',';
        }
            
        system.debug('*****query1 field sets***'+query1);
        if(!query1.contains(owner1))
           query1 += owner1 + ',';
        if(!query1.contains(owner1LastName))
           query1 += owner1LastName + ',';
        if(!query1.contains(owner2))
           query1 += owner2 + ',';
        if(!query1.contains(owner2LastName))
           query1 += owner2LastName + ',';
        if(!query1.contains(accountName))
           query1 += accountName + ',';
        
        query1 = query1.subString(0, query1.length() - 1);
        query1 +=' FROM Opportunity';
        query1 += ' Where Id =';
        query1 += '\''+opportunityId+'\'' ;
        query1 +=' LIMIT 1 ';
        
        system.debug('*****owner 2***'+query1);
        return Database.query(query1);
     }
        
     public List<Schema.FieldSetMember> getFields3() {
        return SObjectType.Opportunity.FieldSets.ADDITIONAL_BANK_TRADE_INFORMATION.getFields();
     }
        
     //This method returns the list for BANK/TRADE INFORMATION section
     public Opportunity getOpportunityListBankTradeInfo(String opportunityId) {

        query1 = 'SELECT Id,';
        for(Schema.FieldSetMember f : this.getFields3()) {
            query1 += f.getFieldPath() + ',';
        }
        
        system.debug('*****query1 field sets***'+query1);
        if(!query1.contains(owner1))
           query1 += owner1 + ',';
        if(!query1.contains(owner1LastName))
           query1 += owner1LastName + ',';
        if(!query1.contains(owner2))
           query1 += owner2 + ',';
        if(!query1.contains(owner2LastName))
           query1 += owner2LastName + ',';
        if(!query1.contains(accountName))
           query1 += accountName + ',';
           
        query1 = query1.subString(0, query1.length() - 1);
        query1 +=' FROM Opportunity';
        query1 += ' Where Id =';
        query1 += '\''+opportunityId+'\'' ;
        query1 +=' LIMIT 1 ';
        system.debug('*****query1***'+query1);
        return Database.query(query1);
    }
        
    public List<Schema.FieldSetMember> getFields4() {
        return SObjectType.Opportunity.FieldSets.ADDITIONAL_PROPERTY_INFORMATION.getFields();
    }
        
    //This method returns the list for PROPERTY INFORMATION section
    public Opportunity getOpportunityPropertyInfo(String opportunityId) {

        query1 = 'SELECT Id,';
        for(Schema.FieldSetMember f : this.getFields4()) {
            query1 += f.getFieldPath() + ',';
        }
        
        system.debug('*****query1 field sets***'+query1);
        if(!query1.contains(owner1))
           query1 += owner1 + ',';
        if(!query1.contains(owner1LastName))
           query1 += owner1LastName + ',';
        if(!query1.contains(owner2))
           query1 += owner2 + ',';
        if(!query1.contains(owner2LastName))
           query1 += owner2LastName + ',';
        if(!query1.contains(accountName))
           query1 += accountName + ',';
            
        query1 = query1.subString(0, query1.length() - 1);
        query1 +=' FROM Opportunity';
        query1 += ' Where Id =';
        query1 += '\''+opportunityId+'\'' ;
        query1 +=' LIMIT 1 ';
        system.debug('*****query4***'+query1);
        return Database.query(query1);
    }
        
    public List<Schema.FieldSetMember> getFields5() {
        return SObjectType.Opportunity.FieldSets.ADDITIONAL_OTHER_INFORMATION.getFields();
    }
        
    //This method returns the list for OTHER INFORMATION section
    public Opportunity getOpportunityOtherInfo(String opportunityId) {

        query1 = 'SELECT Id,';
        for(Schema.FieldSetMember f : this.getFields5()) {
            query1 += f.getFieldPath() + ',';
        }
        
        system.debug('*****query1 field sets***'+query1);
        if(!query1.contains(owner1))
           query1 += owner1 + ',';
        if(!query1.contains(owner1LastName))
           query1 += owner1LastName + ',';
        if(!query1.contains(owner2))
           query1 += owner2 + ',';
        if(!query1.contains(owner2LastName))
           query1 += owner2LastName + ',';
        if(!query1.contains(accountName))
           query1 += accountName + ',';
        
        query1 = query1.subString(0, query1.length() - 1);
        query1+=' FROM Opportunity';
        query1 += ' Where Id =';
        query1 += '\''+opportunityId+'\'' ;
        query1 +=' LIMIT 1 ';
        system.debug('*****query***'+query1);
        return Database.query(query1);
    }
    
    //This method returns the list for BUSINESS INFORMATION section
    public Account getAccountlist(String accountId) {

        query1 = 'SELECT Id,Name, McaApp__Legal_Name__c, McaApp__Type_of_Entity__c, McaApp__Federal_Tax_ID_No__c, BillingStreet, BillingCity, BillingState,'
                 +'BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Phone, McaApp__Cellular_No__c,'
                 +'Fax, McaApp__Date_Business_Established__c, McaApp__Years_in_Business__c, Industry, Website, McaApp__Email__c, McaApp__Bank_Name__c, McaApp__Bank_Contact__c,'
                 +'McaApp__Bank_Phone__c, McaApp__Business_Name__c, McaApp__Business_Contact_Account__c, McaApp__Business_Phone__c, McaApp__Landlord_Mortgagee__c,'
                 +'McaApp__Landlord_Contact_Name__c, McaApp__Landlord_Phone__c, McaApp__Lease_start_date__c, McaApp__Time_Left_On_Lease__c, McaApp__Monthly_Payment__c,'
                 +'McaApp__Physical_Address_City__c ,McaApp__Square_Footage__c, McaApp__Gross_monthly_Sales__c, McaApp__Monthly_CC_Avg_All__c,McaApp__No_Credit_Card_Stmts__c,' 
                 +'AccountNumber,BillingCountryCode,BillingStateCode  From Account Where Id =';
        query1 += '\''+accountId+'\'' ;
        query1 +=' LIMIT 1 ';
        system.debug('*****query1***'+query1);
        return Database.query(query1); 
     } 
}