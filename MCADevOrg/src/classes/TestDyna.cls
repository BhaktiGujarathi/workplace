public with sharing class TestDyna {
    
        private String AccId;
        private String OppId;
        public String Owner1LastName{get;set;}
        public String Owner2LastName{get;set;}
        public Account objAccount{get;set;}
        public Opportunity opportunity {get; set;}
        public list <Contact> contactForMappingLst {get;set;}
        public list <Contact> contactForMappingtoUpdateLst;
        public list <Opportunity> opportunitytoUpdateLst;
        public CongaButtonUrl__c createPDF{get;set;}
        public CongaButtonUrl__c emailPDF{get;set;}
        public CongaButtonUrl__c faxPDF{get;set;}
        public CongaButtonUrl__c docusign{get;set;}
        public Contact conForOwner1{get;set;}
        public Contact conForOwner2{get;set;}
        public String isConsole{get;set;}
        public list<Contact> oldContactOwner1;
        public list<Contact> oldContactOwner2;
        private ApexPages.StandardController stdController; 
        private final String selectAccountError = 'Please select Account on opportunity';
        private String CheckWhereCondition;
        public String FedralTaxId { get; set; }       
        //public String docusign1 = 'https://composer.congamerge.com?sessionId={!API.Session_ID}&serverUrl= {!API.Partner_Server_URL_80}&id='+Opportunity.Id+'&TemplateID='+system.Label.FundingApplicationTemplateId+'&DocuSignVisible=1&DocuSignR1Id="+records[0].ContactId+"&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&FlattenPDFForms=1&DS7=7&DocuSignEmailSubject=Funding+Application';
        
        
                
        public TestDyna(ApexPages.StandardController stdController){
                isConsole = ApexPages.currentPage().getParameters().get('console');
                contactForMappingtoUpdateLst = new List<Contact>();
                opportunitytoUpdateLst = new List<Opportunity>();
                this.stdController = stdController;
                objAccount = new Account();
                opportunity = new Opportunity();
                conForOwner1 = new Contact();
                conForOwner2 = new Contact();
                oldContactOwner1 = new list<Contact>();
                oldContactOwner2 = new list<Contact>();
                Owner1LastName = ''; 
                Owner2LastName = '';
                FedralTaxId = null;
                emailPDF = CongaButtonUrl__c.getInstance('Email PDF');
                createPDF = CongaButtonUrl__c.getInstance('Create PDF');
                faxPDF = CongaButtonUrl__c.getInstance('Fax PDF');
                docusign = CongaButtonUrl__c.getInstance('Docusign');                
                contactForMappingLst =  new list<Contact>();
                
                try{
                        AccId = ApexPages.currentPage().getParameters().get('id');
                        
                        list<Account> listAccount = new list<Account>();
                        listAccount = [Select Id, Name, Legal_Name__c, Type_of_Entity__c, Federal_Tax_ID_No__c, BillingStreet, BillingCity, BillingState,
                                                BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Phone, Cellular_No__c,
                                                Fax, Date_Business_Established__c, Years_in_Business__c, Industry, Website, Email__c, Bank_Name__c, Bank_Contact__c,
                                                Bank_Phone__c, Business_Name__c, Business_Contact_Account__c, Business_Phone__c, Landlord_Mortgagee__c,
                                                Landlord_Contact_Name__c, Landlord_Phone__c, Lease_start_date__c, Time_Left_On_Lease__c, Monthly_Payment__c,
                                                Square_Footage__c, Gross_monthly_Sales__c//, Monthly_CC_Avg_All__c
                                                 From Account Where Id =: AccId limit 1];
                        if(!listAccount.isEmpty())
                            objAccount = listAccount[0];
                        
                        OppId = ApexPages.currentPage().getParameters().get('oppId');
                        opportunity = [Select Balance__c ,Cash_Advance_Company__c,AccountId,Use_of_Proceeds__c,Gross_monthly_Sales__c,Credit_Card_Sales__c,
                                                                  Ever_used_a_Business_Cash_Advance__c,Owner_1_Ownership__c,Owner_2_Ownership__c,
                                                                  Amount_Requested__c,Owner_1__c,Owner_2__c,Application__c,
                                                                  Credit_Card_Statements__c,Bank_Statements__c,StageName
                                                                  from Opportunity where Id =: OppId ];
                                                                  
                if(opportunity.Owner_1__c != null || opportunity.Owner_2__c != null){
                       contactForMappingLst = [Select Title,Id,Name,
                                                                          Social_Security_Number1__c,
                                                                          Of_Ownership__c,
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
                                                                          Drivers_License__c,
                                                                          Birthdate 
                                                           From Contact
                                                   where Id =: opportunity.Owner_1__c
                                                   or Id = : opportunity.Owner_2__c];
                   }
                   for(Contact con : contactForMappingLst){
                       if(opportunity.Owner_1__c != null && opportunity.Owner_1__c == con.Id){
                           conForOwner1 = con;
                           Owner1LastName = con.LastName;
                       }
                       else if(opportunity.Owner_2__c != null && opportunity.Owner_2__c == con.Id){
                               conForOwner2 = con;
                               Owner2LastName = con.LastName;
                       }
                   }
                   
                   for(Account acc : listAccount){
                      FedralTaxId = acc.Federal_Tax_ID_No__c;
                   }
                }catch(Exception e){
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
                }
                
        }
        
        
        public PageReference Save(){
                try{
                if((FedralTaxId <> null) && (!Pattern.matches('[0-9]{2}-[0-9]{7}', FedralTaxId) &&(FedralTaxId.length() > 0) ) ){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'The required format for Federal tax ID is ##-#######')); 
                    return null;
                }
                else{
                this.QuickSave1();
                //PageReference pageRef = new PageReference(Page.FundingApplicationView.getURL()+'?id='+AccId+'&oppId='+OppId);
                PageReference pageRef = new PageReference('/'+OppId);
                pageRef.setRedirect(true);
                return pageRef;
                  }
                }
                catch(Exception e){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
                return null;    
                }
                
        } 
        public void QuickSave1(){
                contactForMappingtoUpdateLst.clear();
                if((FedralTaxId <> null) && (!Pattern.matches('[0-9]{2}-[0-9]{7}', FedralTaxId) &&(FedralTaxId.length() > 0) ) ){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'The required format for Federal tax ID is ##-#######')); 
                    
                }
                else{
                try{
                if(conForOwner1.FirstName != null)
                {
                   CheckWhereCondition =  accId.substring(0,15)+'-'+conForOwner1.FirstName+'-'+Owner1LastName+'-Business Owner';
                }
                else
                {
                   CheckWhereCondition =  accId.substring(0,15)+'-'+Owner1LastName+'-Business Owner';
                }
                if(Owner1LastName != ''){
                                // update or create new - owner1 present
                                system.debug('***conForOwner1'+conForOwner1);
                                String accId = '';
                                if(opportunity.AccountId != null)
                                        accId = opportunity.AccountId;
                                oldContactOwner1 = [Select Title,Id,Name,
                                                                          Social_Security_Number1__c,
                                                                          Of_Ownership__c,
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
                                                                          Drivers_License__c,
                                                                          Birthdate 
                                                           From Contact
                                                           where Combination_Key_For_Owner__c like : '%' + accId.substring(0,15)+'-'+conForOwner1.FirstName+'-'+Owner1LastName+'-Business Owner' +'%'];
                                                           //Combination_Key_For_Owner__c =: accId.substring(0,15)+'-'+conForOwner1.FirstName+'-'+Owner1LastName+'-Business Owner'];
                                                          // AND LastName =: Owner1LastName AND FirstName =: conForOwner1.FirstName];
                                system.debug('***accId.substring(0,14)'+accId.substring(0,15));
                                system.debug('***oldContactOwner1'+oldContactOwner1);
                                system.debug('***combination key'+accId.substring(0,15)+'-'+conForOwner1.FirstName+'-'+Owner1LastName+'-Business Owner');
                                                           //AND Contact_Roles__c =: conForOwner1.Contact_Roles__c];
                                if(oldContactOwner1.size()>0)
                                {// if contact already exist
                                        oldContactOwner1[0].LastName = Owner1LastName;
                                        oldContactOwner1[0].AccountId = opportunity.AccountId;
                                        oldContactOwner1[0].Title = conForOwner1.Title;
                                        oldContactOwner1[0].Of_Ownership__c = conForOwner1.Of_Ownership__c;
                                        oldContactOwner1[0].MailingStreet = conForOwner1.MailingStreet;
                                        oldContactOwner1[0].MailingState = conForOwner1.MailingState;
                                        oldContactOwner1[0].MailingPostalCode = conForOwner1.MailingPostalCode;
                                        oldContactOwner1[0].MailingCountry = conForOwner1.MailingCountry;
                                        oldContactOwner1[0].MailingCity = conForOwner1.MailingCity;
                                        oldContactOwner1[0].HomePhone = conForOwner1.HomePhone;
                                        oldContactOwner1[0].Drivers_License__c = conForOwner1.Drivers_License__c;
                                        oldContactOwner1[0].Birthdate = conForOwner1.Birthdate;
                                        oldContactOwner1[0].Social_Security_Number1__c = conForOwner1.Social_Security_Number1__c;

                                        update oldContactOwner1[0];
                                        system.debug('*******oldContactOwner1****'+oldContactOwner1);
                                        opportunity.Owner_1__c = oldContactOwner1[0].Id;
                                        opportunity.Avg_Monthly_CC_sales__c = opportunity.Credit_Card_Sales__c;
                                        system.debug('I am here...'+opportunity.Application__c +'And' + opportunity.StageName);
                                        if((opportunity.Application__c == true)&&(opportunity.StageName == 'Prospecting' || opportunity.StageName == 'Application Sent' || opportunity.StageName == 'Application Missing Info' || opportunity.StageName == 'Renewal Prospecting' || opportunity.StageName == 'Renewal Requested' || opportunity.StageName == 'Declined' || opportunity.StageName == 'Closed Lost'))
                                        {
                                            
                                          opportunity.StageName = 'Application In';
                                        }
                                        update opportunity;
                                        system.debug('***if-opportunity'+opportunity);
                                }       
                                else{// create new
                                        system.debug('***else');
                                        conForOwner1.LastName = Owner1LastName;
                                        conForOwner1.AccountId = opportunity.AccountId;
                                        upsert conForOwner1;
                                        opportunity.Owner_1__c = conForOwner1.Id;
                                        opportunity.Avg_Monthly_CC_sales__c = opportunity.Credit_Card_Sales__c;
                                        if((opportunity.Application__c == true)&&(opportunity.StageName == 'Prospecting' || opportunity.StageName == 'Application Sent' || opportunity.StageName == 'Application Missing Info' || opportunity.StageName == 'Renewal Prospecting' || opportunity.StageName == 'Renewal Requested' || opportunity.StageName == 'Declined' || opportunity.StageName == 'Closed Lost'))
                                        {
                                          opportunity.StageName = 'Application In';
                                        }
                                        update opportunity;
                                        system.debug('***else-opportunity'+opportunity);
                                }                  
                        
                }// end of-if last name
                else{
                //empty - update and create new contact record. opp owner1 == null
                        opportunity.Owner_1__c = null;
                        opportunity.Avg_Monthly_CC_sales__c = opportunity.Credit_Card_Sales__c;
                        if((opportunity.Application__c == true)&&(opportunity.StageName == 'Prospecting' || opportunity.StageName == 'Application Sent' || opportunity.StageName == 'Application Missing Info' || opportunity.StageName == 'Renewal Prospecting' || opportunity.StageName == 'Renewal Requested' || opportunity.StageName == 'Declined' || opportunity.StageName == 'Closed Lost'))
                            {
                              opportunity.StageName = 'Application In';
                            }
                                        update opportunity;
                }
                if(conForOwner2.FirstName != null)
                {
                   CheckWhereCondition =  accId.substring(0,15)+'-'+conForOwner2.FirstName+'-'+Owner2LastName+'-Business Owner';
                }
                else
                {
                   CheckWhereCondition =  accId.substring(0,15)+'-'+Owner2LastName+'-Business Owner';
                }
                if(Owner2LastName != ''){
                    //Nachiket 1.3
                    string whereClasue =  accId.substring(0,15)+'-'+conForOwner2.FirstName+'-'+Owner2LastName+'-Business Owner' ;
                                oldContactOwner2 = [Select Title,Id,Name,
                                                                          Social_Security_Number1__c,
                                                                          Of_Ownership__c,
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
                                                                          Drivers_License__c,
                                                                          Birthdate 
                                                           From Contact
                                                           where Combination_Key_For_Owner__c like : '%'+whereClasue+'%'];
                                                           //Combination_Key_For_Owner__c =: accId.substring(0,15)+'-'+conForOwner2.FirstName+'-'+Owner2LastName+'-Business Owner'];
                                                           // LastName =: Owner2LastName AND FirstName =: conForOwner2.FirstName]; 
                                                          // AND Contact_Roles__c =: conForOwner2.Contact_Roles__c];
                                                 system.debug('*******oldContactOwner2****'+oldContactOwner2);
                                                 system.debug('*******oldContactOwner2****'+accId.substring(0,15)+'-'+conForOwner2.FirstName+'-'+Owner2LastName+'-Business Owner');
                                                 //Nachiket 1.3         
                                                 if((accId.substring(0,15)+'-'+conForOwner1.FirstName+'-'+Owner1LastName+'-Business Owner' ==
                                                     accId.substring(0,15)+'-'+conForOwner2.FirstName+'-'+Owner2LastName+'-Business Owner') 
                                                     && oldContactOwner2.size()>1)
                                                  {
                                                         oldContactOwner2[1].LastName = Owner2LastName;
                                                         oldContactOwner2[1].AccountId = opportunity.AccountId;
                                                         oldContactOwner2[1].Title = conForOwner2.Title;
                                                         //oldContactOwner2[0].Of_Ownership__c = conForOwner2.Of_Ownership__c;
                                                         oldContactOwner2[1].MailingStreet = conForOwner2.MailingStreet;
                                                         oldContactOwner2[1].MailingState = conForOwner2.MailingState;
                                                         oldContactOwner2[1].MailingPostalCode = conForOwner2.MailingPostalCode;
                                                         oldContactOwner2[1].MailingCountry = conForOwner2.MailingCountry;
                                                         oldContactOwner2[1].MailingCity = conForOwner2.MailingCity;
                                                         oldContactOwner2[1].HomePhone = conForOwner2.HomePhone;
                                                         oldContactOwner2[1].Drivers_License__c = conForOwner2.Drivers_License__c;
                                                         oldContactOwner2[1].Birthdate = conForOwner2.Birthdate;
                                                         oldContactOwner2[1].Social_Security_Number1__c = conForOwner2.Social_Security_Number1__c;
                                                         update oldContactOwner2[1];
                                                         system.debug('*******oldContactOwner2 updated same combination****'+oldContactOwner2);
                                                         opportunity.Owner_2__c = oldContactOwner2[1].Id;
                                                         opportunity.Avg_Monthly_CC_sales__c = opportunity.Credit_Card_Sales__c;
                                                     if((opportunity.Application__c == true)&&(opportunity.StageName == 'Prospecting' || opportunity.StageName == 'Application Sent' || opportunity.StageName == 'Application Missing Info' || opportunity.StageName == 'Renewal Prospecting' || opportunity.StageName == 'Renewal Requested' || opportunity.StageName == 'Declined' || opportunity.StageName == 'Closed Lost'))
                                                            {
                                                              opportunity.StageName = 'Application In';
                                                            }
                                                            update opportunity;
                                                            system.debug('***if-opportunity'+opportunity);
                                                      }  
                                                 //Nachiket 1.3     
                                                 else if((accId.substring(0,15)+'-'+conForOwner1.FirstName+'-'+Owner1LastName+'-Business Owner' !=
                                                     accId.substring(0,15)+'-'+conForOwner2.FirstName+'-'+Owner2LastName+'-Business Owner') 
                                                     && oldContactOwner2.size()>0)
                                                  {
                                                         oldContactOwner2[0].LastName = Owner2LastName;
                                                         oldContactOwner2[0].AccountId = opportunity.AccountId;
                                                         oldContactOwner2[0].Title = conForOwner2.Title;
                                                         //oldContactOwner2[0].Of_Ownership__c = conForOwner2.Of_Ownership__c;
                                                         oldContactOwner2[0].MailingStreet = conForOwner2.MailingStreet;
                                                         oldContactOwner2[0].MailingState = conForOwner2.MailingState;
                                                         oldContactOwner2[0].MailingPostalCode = conForOwner2.MailingPostalCode;
                                                         oldContactOwner2[0].MailingCountry = conForOwner2.MailingCountry;
                                                         oldContactOwner2[0].MailingCity = conForOwner2.MailingCity;
                                                         oldContactOwner2[0].HomePhone = conForOwner2.HomePhone;
                                                         oldContactOwner2[0].Drivers_License__c = conForOwner2.Drivers_License__c;
                                                         oldContactOwner2[0].Birthdate = conForOwner2.Birthdate;
                                                         oldContactOwner2[0].Social_Security_Number1__c = conForOwner2.Social_Security_Number1__c;
                                                         update oldContactOwner2[0];
                                                         system.debug('*******oldContactOwner2 updated different combination****'+oldContactOwner2);
                                                         opportunity.Owner_2__c = oldContactOwner2[0].Id;
                                                         opportunity.Avg_Monthly_CC_sales__c = opportunity.Credit_Card_Sales__c;
                                                     if((opportunity.Application__c == true)&&(opportunity.StageName == 'Prospecting' || opportunity.StageName == 'Application Sent' || opportunity.StageName == 'Application Missing Info' || opportunity.StageName == 'Renewal Prospecting' || opportunity.StageName == 'Renewal Requested' || opportunity.StageName == 'Declined' || opportunity.StageName == 'Closed Lost'))
                                                            {
                                                              opportunity.StageName = 'Application In';
                                                            }
                                                            update opportunity;
                                                            system.debug('***if-opportunity'+opportunity);
                                                  } 
                                                  else{// update existing or create new
                                                        conForOwner2.LastName = Owner2LastName;
                                                        conForOwner2.AccountId = opportunity.AccountId;
                                                        upsert conForOwner2;
                                                        opportunity.Owner_2__c = conForOwner2.Id;
                                                   if((opportunity.Application__c == true)&&(opportunity.StageName == 'Prospecting' || opportunity.StageName == 'Application Sent' || opportunity.StageName == 'Application Missing Info' || opportunity.StageName == 'Renewal Prospecting' || opportunity.StageName == 'Renewal Requested' || opportunity.StageName == 'Declined' || opportunity.StageName == 'Closed Lost'))
                                                        {
                                                          opportunity.StageName = 'Application In';
                                                        }
                                                                        update opportunity;
                                                                        system.debug('***else-opportunity'+opportunity);
                                                                  }
                        
                }
                else{
                        opportunity.Owner_2__c = null;
                        opportunity.Avg_Monthly_CC_sales__c = opportunity.Credit_Card_Sales__c;
                            if((opportunity.Application__c == true)&&(opportunity.StageName == 'Prospecting' || opportunity.StageName == 'Application Sent' || opportunity.StageName == 'Application Missing Info' || opportunity.StageName == 'Renewal Prospecting' || opportunity.StageName == 'Renewal Requested' || opportunity.StageName == 'Declined' || opportunity.StageName == 'Closed Lost'))
                                        {
                                          opportunity.StageName = 'Application In';
                                        }
                                        update opportunity;
                }
                
                //Account objAccount = [Select Id, Gross_monthly_Sales__c, Monthly_CC_Avg_All__c,Industry, Years_in_Business__c from Account where id =: AccId];
                objAccount.Gross_monthly_Sales__c = opportunity.Gross_monthly_Sales__c;
                //objAccount.Monthly_CC_Avg_All__c = opportunity.Credit_Card_Sales__c;
                objAccount.Federal_Tax_ID_No__c = FedralTaxId;
                update objAccount;
                system.debug('****objAccount****'+objAccount);
                  }
                  catch(Exception e){
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
                }
                }
                
        }
        
        
        public PageReference cancel(){
            system.debug('***OppId***'+OppId);
                return new PageReference('/'+OppId);
        }
        
        public PageReference cancel1(){
            return new PageReference('/'+OppId);
        }
        
        
        public PageReference docuSign(){
                return new PageReference('/'+OppId);
        }
        
        public void docuSign1(){
                //return new PageReference('/'+OppId);
        }
        
        public PageReference SendCongaPDF1(){
              try{
                this.QuickSave1();
              }
              catch(Exception e){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
              }
               return new PageReference('/'+OppId);
        }
        public PageReference submissionWizard1(){
        system.debug('***submissionWizard1**');
               try{
                 //pageRef = new PageReference();
                this.QuickSave1();
                //redirectOpp();
                //pageRef = '/'+OppId;
              }
              catch(Exception e){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
              }
             return new PageReference('/'+OppId);
             //return new PageReference('/apex/SubmissionWizard?id='+OppId+'&accId='+opportunity.AccountId);
        }
        
       /* public void submissionWizard1(){
            system.debug('***submissionWizard1**');
               try{
                this.QuickSave1();
                system.debug('***submissionWizard1 QuickSave1**');
                //return new PageReference('/'+OppId);
              }
              catch(Exception e){
                system.debug('***submissionWizard1 catch**');
                //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
              }
             //return new PageReference('/'+OppId);
        }*/
        public PageReference openConga1(){
              try{
                this.QuickSave1();
              }
              catch(Exception e){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
              }
               return new PageReference('/'+OppId);
        }
        
        public PageReference editPage(){
                PageReference pageRef = new PageReference(Page.FundingApplication.getUrl()+'?id='+AccId+'&oppId='+OppId);
                pageRef.setRedirect(true);
                return pageRef;
        }
        
 

}