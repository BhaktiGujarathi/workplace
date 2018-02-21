/* 
 *  Apex controller for FundingApplication Page.
 *  Revision History: 
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Sneha P.               17-02-2014           Initial Draft 
 *  1.1               Shraddha P.            18-10-2014           updated style
 *  1.2               Nachiket Deshpande     22 Dec 2014          Added Validation to Check fedral Tax in Proper Format.
 *                                                                e.g ##-####### (12-1234567)
 *  1.3               Nachiket Deshpande     11 May 2015          Updated query for ownere using like operator to avoid error of 
 *                                                                unique combination key for owner 
 *  1.4               Yogesh Mahajan         21-09-2015           Added owner 3 and owner 4 for the opportunity.
 */
public with sharing class FundingApplicationController {
        
    public String Owner1LastName                {get;set;}
    public String Owner2LastName                {get;set;}
    public String Owner3LastName                {get;set;}
    public String Owner4LastName                {get;set;}
    
    public Account objAccount                   {get;set;}
    public Opportunity opportunity              {get;set;}
    public list <Contact> contactForMappingLst  {get;set;}
    public CongaButtonUrl__c createPDF          {get;set;}
    public CongaButtonUrl__c emailPDF           {get;set;}
    public CongaButtonUrl__c faxPDF             {get;set;}
    public CongaButtonUrl__c docusign           {get;set;}
    public CongaButtonUrl__c submitToBanks      {get;set;}
    public Contact conForOwner1                 {get;set;}
    public Contact conForOwner2                 {get;set;}
    public Contact conForOwner3                 {get;set;}
    public Contact conForOwner4                 {get;set;}
    public String isConsole                     {get;set;}

    public list <Contact> contactForMappingtoUpdateLst;
    public list <Opportunity> opportunitytoUpdateLst;
    public list<Contact> oldContactOwner1;
    public list<Contact> oldContactOwner2;
    public list<Contact> oldContactOwner3;
    public list<Contact> oldContactOwner4;

    private ApexPages.StandardController stdController; 

    private final String selectAccountError = 'Please select Account on opportunity';
    private String CheckWhereCondition;
    public String Owner1FirstName;
    public String Owner2FirstName;
    public String Owner3FirstName;
    public String Owner4FirstName;
    private String AccId;
    private String OppId;
    public Boolean flag;

public FundingApplicationController(ApexPages.StandardController stdController){
        
        isConsole = ApexPages.currentPage().getParameters().get('console');
        emailPDF = CongaButtonUrl__c.getInstance('Email PDF');
        createPDF = CongaButtonUrl__c.getInstance('Create PDF');
        faxPDF = CongaButtonUrl__c.getInstance('Fax PDF');
        docusign = CongaButtonUrl__c.getInstance('Docusign');
        submitToBanks = CongaButtonUrl__c.getInstance('Submit To Banks');
        
        objAccount = new Account();
        opportunity = new Opportunity();
        conForOwner1 = new Contact();
        conForOwner2 = new Contact();
        conForOwner3 = new Contact();
        conForOwner4 = new Contact();
        
        contactForMappingtoUpdateLst = new List<Contact>();
        opportunitytoUpdateLst = new List<Opportunity>();
        oldContactOwner1 = new list<Contact>();
        oldContactOwner2 = new list<Contact>();
        oldContactOwner3 = new list<Contact>();
        oldContactOwner4 = new list<Contact>();
        
        contactForMappingLst =  new list<Contact>();
        
        this.stdController = stdController;
        
        Owner1LastName = ''; 
        Owner2LastName = '';
        Owner3LastName = ''; 
        Owner4LastName = '';
        Owner1FirstName = '';
        Owner2FirstName = '';
        Owner3FirstName = '';
        Owner4FirstName = '';
        flag = true;

        try{
            AccId = ApexPages.currentPage().getParameters().get('id');

            list<Account> listAccount = new list<Account>();
            listAccount = [SELECT Id, Name, McaApp__Legal_Name__c, McaApp__Type_of_Entity__c, 
                                    McaApp__Federal_Tax_ID_No__c, BillingStreet, BillingCity, 
                                    BillingState, BillingPostalCode, ShippingStreet, ShippingCity, 
                                    ShippingState, ShippingPostalCode, Phone, McaApp__Cellular_No__c, 
                                    Fax, McaApp__Date_Business_Established__c, McaApp__Years_in_Business__c, 
                                    Industry, Website, McaApp__Email__c, McaApp__Bank_Name__c, McaApp__Bank_Contact__c,
                                    McaApp__Bank_Phone__c, McaApp__Business_Name__c, McaApp__Business_Contact_Account__c, 
                                    McaApp__Business_Phone__c, McaApp__Landlord_Mortgagee__c, McaApp__Landlord_Contact_Name__c, 
                                    McaApp__Landlord_Phone__c, McaApp__Lease_start_date__c, McaApp__Time_Left_On_Lease__c, 
                                    McaApp__Monthly_Payment__c, McaApp__Square_Footage__c, McaApp__Gross_monthly_Sales__c, 
                                    McaApp__Monthly_CC_Avg_All__c 
                        FROM Account 
                        WHERE Id =: AccId limit 1];
                        
            if(!listAccount.isEmpty())
                objAccount = listAccount[0];

            OppId = ApexPages.currentPage().getParameters().get('oppId');
            opportunity = [SELECT McaApp__Balance__c ,McaApp__Cash_Advance_Company__c,AccountId,McaApp__Use_of_Proceeds__c,
                                    McaApp__Gross_monthly_Sales__c,McaApp__Credit_Card_Sales__c, 
                                    McaApp__Ever_used_a_Business_Cash_Advance__c,McaApp__Owner_1_Ownership__c, 
                                    McaApp__Owner_2_Ownership__c, McaApp__Amount_Requested__c, 
                                    McaApp__Owner_1__c,McaApp__Owner_2__c,McaApp__Application__c, 
                                    McaApp__Credit_Card_Statements__c, Owner_3__c, Owner_4__c,
                                    McaApp__Bank_Statements__c,StageName
                          FROM Opportunity 
                          WHERE Id =: OppId ];
                      
            if(opportunity.McaApp__Owner_1__c != null || opportunity.McaApp__Owner_2__c != null){
                contactForMappingLst = [SELECT Title,Id,Name,
                                                  McaApp__Social_Security_Number__c,
                                                  McaApp__Of_Ownership__c,
                                                  MobilePhone,
                                                  Email,
                                                  LastName,
                                                  FirstName,
                                                  MailingStreet,
                                                  MailingState,
                                                  MailingPostalCode,
                                                  MailingCountry,
                                                  MailingCity,
                                                  HomePhone,
                                                  McaApp__Drivers_License__c,
                                                  Birthdate 
                                       FROM Contact
                                       WHERE Id =: opportunity.McaApp__Owner_1__c
                                       OR Id = : opportunity.McaApp__Owner_2__c
                                       OR Id = : opportunity.Owner_3__c
                                       OR Id = : opportunity.Owner_4__c];
            }//End if
            
            for(Contact con : contactForMappingLst){
                if(opportunity.McaApp__Owner_1__c != null && opportunity.McaApp__Owner_1__c == con.Id){
                    conForOwner1 = con;
                    Owner1LastName = con.LastName;
                    Owner1FirstName = con.FirstName;
                }else if(opportunity.McaApp__Owner_2__c != null && opportunity.McaApp__Owner_2__c == con.Id){
                    conForOwner2 = con;
                    Owner2LastName = con.LastName;
                    Owner2FirstName = con.FirstName;
                }else if(opportunity.Owner_3__c != null && opportunity.Owner_3__c == con.Id){
                    conForOwner3 = con;
                    Owner3LastName = con.LastName;
                    Owner3FirstName = con.FirstName;
                }else if(opportunity.Owner_4__c != null && opportunity.Owner_4__c == con.Id){
                    conForOwner4 = con;
                    Owner4LastName = con.LastName;
                    Owner4FirstName = con.FirstName;
                }//End else - if
            }//End for

        }catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }//End try - catch

    }// end FundingApplicationController()
        
        
    public PageReference Save(){
        try{
            this.QuickSave1();
            //PageReference pageRef = new PageReference(Page.FundingApplicationView.getURL()+'?id='+AccId+'&oppId='+OppId);
            PageReference pageRef = new PageReference('/'+OppId);
            pageRef.setRedirect(true);
            if(flag == true)
                return pageRef;
            else
                return null;
        }
        catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
            return null;    
        }//End try - catch

    }// End Save() 
    
    // It is used to save (upsert) the application page values
    public void QuickSave1(){
        List<Contact> listContactUpsert = new List<Contact>();
        List<Opportunity> listOppUpdate = new List<Opportunity>();
        Map<String, Contact> mapCombinationWithContact = new Map<String, Contact>();
        flag = true;
        contactForMappingtoUpdateLst.clear();
        String owner1Key;
        if(Owner1FirstName != null){
            owner1Key =  accId.substring(0,15)+'-'+Owner1FirstName+'-'+Owner1LastName+'-Business Owner';
        }else{
            owner1Key =  accId.substring(0,15)+'-'+Owner1LastName+'-Business Owner';
        }//End Else - If
        
        String owner2Key;
        if(Owner2FirstName != null ){
            owner2Key =  accId.substring(0,15)+'-'+Owner2FirstName+'-'+Owner2LastName+'-Business Owner';
        }else{
            owner2Key =  accId.substring(0,15)+'-'+Owner2LastName+'-Business Owner';
        }//End Else - If
        
        String owner3Key;
        if(Owner3FirstName != null){
            owner3Key =  accId.substring(0,15)+'-'+Owner3FirstName+'-'+Owner3LastName+'-Business Owner';
        }else{
            owner3Key =  accId.substring(0,15)+'-'+Owner3LastName+'-Business Owner';
        }//End Else - If
        
        String owner4Key;
        if(Owner4FirstName != null){
            owner4Key =  accId.substring(0,15)+'-'+Owner4FirstName+'-'+Owner4LastName+'-Business Owner';
        }else{
            owner4Key =  accId.substring(0,15)+'-'+Owner4LastName+'-Business Owner';
        }//End Else - If
        
        //Filter for where condition
        String[] filters = new String[]{'%' +owner1Key+'%','%' + owner2Key+'%',
                                        '%' + owner3Key+'%', '%' +owner4Key+'%'};
        
        try{
            
            List<Contact> listOldContact = [SELECT Id,
                                                    Name,
                                                    Email,
                                                    Title,
                                                    LastName,
                                                    FirstName,
                                                    HomePhone,
                                                    Birthdate,
                                                    MobilePhone,
                                                    MailingCity,
                                                    MailingState,
                                                    MailingStreet,
                                                    MailingCountry,
                                                    MailingPostalCode,
                                                    McaApp__Of_Ownership__c,
                                                    McaApp__Drivers_License__c,
                                                    McaApp__Social_Security_Number__c,
                                                    McaApp__Combination_Key_For_Owner__c
                                            FROM Contact
                                            WHERE McaApp__Combination_Key_For_Owner__c LIKE :filters];
                                            
            system.debug('Inside Try----->'+listOldContact);
            if(listOldContact.size() > 0) {
                // It is used to create map of contact as per the unique key (McaApp__Combination_Key_For_Owner__c)                         
                for(Contact objContact: listOldContact) {
                    mapCombinationWithContact.put(objContact.McaApp__Combination_Key_For_Owner__c, objContact);
                    
                    if(objContact.McaApp__Combination_Key_For_Owner__c.contains(owner1Key)){
                        owner1Key = objContact.McaApp__Combination_Key_For_Owner__c;
                        System.debug('Inside If');
                    }
                    if(objContact.McaApp__Combination_Key_For_Owner__c.contains(owner2Key))
                        owner2Key = objContact.McaApp__Combination_Key_For_Owner__c;
                     
                    if(objContact.McaApp__Combination_Key_For_Owner__c.contains(owner3Key))
                        owner3Key = objContact.McaApp__Combination_Key_For_Owner__c;
                    
                    if(objContact.McaApp__Combination_Key_For_Owner__c.contains(owner4Key))
                        owner4Key = objContact.McaApp__Combination_Key_For_Owner__c;
                }//End For
            }//End If                               
            
            filters = new String[]{owner1Key, owner2Key, owner3Key, owner4Key};
            system.debug('filters------>'+filters);
            system.debug('filters------>'+mapCombinationWithContact);
            Integer counter = 1;
            Contact objContact;
            Contact objOldContact;
            // Upsert / update the contact
            for (String combinationKey: filters) {
                
                objOldContact = new Contact();
                objContact = new Contact();
                if(mapCombinationWithContact.get(combinationKey) != null ) 
                    objOldContact = mapCombinationWithContact.get(combinationKey);
                system.debug('objOldContact------>'+objOldContact);
                // if contact already exist
                if (counter == 1) {
                    if(Owner1LastName != null)
                        objContact = assignContact(conForOwner1, Owner1LastName, opportunity.AccountId);
                    else 
                        opportunity.McaApp__Owner_1__c = null;
                    // Add contact id
                    if(objOldContact != null)
                        objContact.id = objOldContact.id;
                    
                    //oldContactOwner1[0] = objContact;
                }else if (counter == 2) {
                    if(Owner2LastName != null)
                        objContact = assignContact(conForOwner2, Owner2LastName, opportunity.AccountId);
                    else 
                        opportunity.McaApp__Owner_1__c = null;
                    // Add contact id
                    if(objOldContact != null)
                        objContact.id = objOldContact.id;
                    //oldContactOwner2[0] = objContact;
                }else if (counter == 3) {
                    if(Owner3LastName != null)
                        objContact = assignContact(conForOwner3, Owner3LastName, opportunity.AccountId);
                    else 
                        opportunity.McaApp__Owner_1__c = null;
                    // Add contact id
                    if(objOldContact != null)
                        objContact.id = objOldContact.id;
                    //oldContactOwner3[0] = objContact;
                }else if (counter == 4) {
                    if(Owner4LastName != null)
                        objContact = assignContact(conForOwner4, Owner4LastName, opportunity.AccountId);
                    else 
                        opportunity.McaApp__Owner_1__c = null;
                    // Add contact id
                    if(objOldContact != null)
                        objContact.id = objOldContact.id;
                    //oldContactOwner4[0] = objContact;
                }//End Else - If
                
                // Add to the list of contact to upsert
                listContactUpsert.add(objContact);
                counter++;
            }//End For
            
            //Update Opportunity
            opportunity.McaApp__Avg_Monthly_CC_sales__c = opportunity.McaApp__Credit_Card_Sales__c;
            
            if((opportunity.McaApp__Application__c == true)
            &&(opportunity.StageName == 'Prospecting' 
            || opportunity.StageName == 'Application Sent' 
            || opportunity.StageName == 'Application Missing Info' 
            || opportunity.StageName == 'Renewal Prospecting' 
            || opportunity.StageName == 'Renewal Requested' 
            || opportunity.StageName == 'Declined' 
            || opportunity.StageName == 'Closed Lost')) {

                opportunity.StageName = 'Application In';
            }//End If
            
            if(listContactUpsert.size() > 0)
                upsert listContactUpsert;
            
            opportunity.McaApp__Owner_1__c = listContactUpsert[0].id;
            opportunity.McaApp__Owner_2__c = listContactUpsert[1].id;
            opportunity.Owner_3__c = listContactUpsert[2].id;
            opportunity.Owner_4__c = listContactUpsert[3].id;
            if(opportunity != null)
                update opportunity;
            
            objAccount.McaApp__Gross_monthly_Sales__c = opportunity.McaApp__Gross_monthly_Sales__c;
            //objAccount.Monthly_CC_Avg_All__c = opportunity.Credit_Card_Sales__c;
            update objAccount;
            system.debug('****objAccount****'+objAccount);
        }catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
            flag = false;
        }//End try - catch
    }// end QuickSave1()

    public PageReference cancel(){
        system.debug('***OppId***'+OppId);
        return new PageReference('/'+OppId);
    }//End cancel()         

    public PageReference SendCongaPDF1(){
        try{
            this.QuickSave1();
        }catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }//End try - catch
        return new PageReference('/'+OppId);
    }//End SendCongaPDF1()
        
        
    public PageReference submissionWizard1(){
        system.debug('***submissionWizard1**');
        try{
            //pageRef = new PageReference();
            this.QuickSave1();
            //redirectOpp();
            //pageRef = '/'+OppId;
        }catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }//End try - catch
        return new PageReference('/'+OppId);
        //return new PageReference('/apex/SubmissionWizard?id='+OppId+'&accId='+opportunity.AccountId);
    }//End submissionWizard1()
    
    public PageReference openConga1(){
        try{
            this.QuickSave1();
        }
        catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }//End try - catch
        return new PageReference('/'+OppId);
    }//End openConga1()
        
    public PageReference editPage(){
        PageReference pageRef = new PageReference(Page.FundingApplication.getUrl()+'?id='+AccId+'&oppId='+OppId);
        pageRef.setRedirect(true);
        return pageRef;
    }//End editPage()
    
    // It is used to assign contact value
    public Contact assignContact(Contact objCon, String lastName, Id accID) {
        Contact objContact = new Contact();
        objContact.LastName = lastName;
        objContact.AccountId = accID;
        objContact.Title = objCon.Title;
        objContact.FirstName = objCon.FirstName;
        objContact.McaApp__Of_Ownership__c = objCon.McaApp__Of_Ownership__c;
        objContact.MailingStreet = objCon.MailingStreet;
        objContact.MailingState = objCon.MailingState;
        objContact.MailingPostalCode = objCon.MailingPostalCode;
        objContact.MailingCountry = objCon.MailingCountry;
        objContact.MailingCity = objCon.MailingCity;
        objContact.MobilePhone = objCon.MobilePhone;
        objContact.Email = objCon.Email;
        objContact.HomePhone = objCon.HomePhone;
        objContact.McaApp__Drivers_License__c = objCon.McaApp__Drivers_License__c;
        objContact.Birthdate = objCon.Birthdate;
        objContact.McaApp__Social_Security_Number__c = objCon.McaApp__Social_Security_Number__c;
        
        return objContact;
    }//end assignContact()
}