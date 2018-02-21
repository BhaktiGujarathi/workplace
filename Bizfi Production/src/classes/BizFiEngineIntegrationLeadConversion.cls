public class BizFiEngineIntegrationLeadConversion{

    public static Boolean isRunning = false;

    private List<Contact>                contactsToInsert;
    private List<OpportunityContactRole> opportunitiesContactRolesToInsert;

    private List<Contact> existingContacts;

    // This preaprovals are related to a Lead, after conversion this ones should be also related to the created Opportunity.
    private List<Preapproval__c> preaprovalsToUpdate;

    private Set<String> existingContactsSet;

    public BizFiEngineIntegrationLeadConversion(){
        contactsToInsert                  = new List<Contact>();
        existingContacts                  = new List<Contact>();
        opportunitiesContactRolesToInsert = new List<OpportunityContactRole>();
    }

    public void createContacts(Map<Id, Lead> mapConvertedLead){

        preaprovalsToUpdate = [select p.id, p.Opportunity__c, p.Lead__c from Preapproval__c p where p.Lead__c IN: mapConvertedLead.keySet()];
 
        for (Lead myLead : mapConvertedLead.values()){ 
            for (Preapproval__c myPreapproval : preaprovalsToUpdate){
                if(myLead.Id == myPreapproval.Lead__c){
                    myPreapproval.Opportunity__c = myLead.ConvertedOpportunityId;
                }
            }

            update preaprovalsToUpdate;
        }
        
        for (Lead myLead : mapConvertedLead.values()){          
            createowner2(myLead);
            createowner3(myLead);
            createowner4(myLead);
        }

        if(!contactsToInsert.isEmpty()){
            insert contactsToInsert;

            //Now that the Contacts have ids we have to assign them instead of the Contact reference
            for (OpportunityContactRole myopportunitiesContactRole : opportunitiesContactRolesToInsert){
                myopportunitiesContactRole.ContactId = myopportunitiesContactRole.Contact.Id;
            }

            // Insert the Opportunity Contact Roles with the Contact id.
            insert opportunitiesContactRolesToInsert;
        }
    }

    private void createOwner2(Lead myLead){
        if(!String.isEmpty(myLead.Owner_2_First_Name__c) && !String.isEmpty(myLead.Owner_2_Last_Name__c)){
            Contact myContact = new Contact();
            myContact.FirstName = myLead.Owner_2_First_Name__c;
            myContact.LastName  = myLead.Owner_2_Last_Name__c;
            myContact.AccountId = myLead.ConvertedAccountId;

            myContact.Business_Main_Phone__c = myLead.Owner_2_Direct_Phone__c;
            myContact.MobilePhone = myLead.Owner_2_Mobile__c;
            myContact.Email = myLead.Owner_2_Email__c;
            myContact.McaApp__Social_Security_Number1__c = myLead.Owner_2_SSN__c;
            myContact.Credit_Score__c =myLead.Owner_2_Credit_Score__c;
            myContact.Birthdate_for_Workflow__c = myLead.Owner_2_Birthdate__c;
            myContact.Title = myLead.Owner_2_Title__c;
            myContact.McaApp__Of_Ownership__c = myLead.Owner_2_Ownership__c;
            myContact.MailingStreet = myLead.Owner_2_Home_Address__c;
            myContact.MailingCity = myLead.Owner_2_Home_Address_City__c;
            myContact.MailingState = myLead.Owner_2_Home_Address_State__c;
            myContact.mailingPostalCode = myLead.Owner_2_Home_Address_Zip__c;
            myContact.Authorize_Run_Credit__c = myLead.Authorize_Run_Credit_Owner_2__c;


            if(!String.isEmpty(myLead.ConvertedOpportunityId)){
                createContactRole(myContact, myLead.ConvertedOpportunityId);                    
            }

            contactsToInsert.add(myContact);
        }
    }

    private void createOwner3(Lead myLead){
        if(!String.isEmpty(myLead.Owner_3_First_Name__c) && !String.isEmpty(myLead.Owner_3_Last_Name__c)){
            Contact myContact = new Contact();
            myContact.FirstName = myLead.Owner_3_First_Name__c;
            myContact.LastName  = myLead.Owner_3_Last_Name__c;
            myContact.AccountId = myLead.ConvertedAccountId;

            myContact.Business_Main_Phone__c = myLead.Owner_3_Direct_Phone__c;
            myContact.MobilePhone = myLead.Owner_3_Mobile__c;
            myContact.Email = myLead.Owner_3_Email__c;
            myContact.McaApp__Social_Security_Number1__c = myLead.Owner_3_SSN__c;
            myContact.Credit_Score__c =myLead.Owner_3_Credit_Score__c;
            myContact.Birthdate_for_Workflow__c = myLead.Owner_3_Birthdate__c;
            myContact.Title = myLead.Owner_3_Title__c;
            myContact.McaApp__Of_Ownership__c = myLead.Owner_3_Ownership__c;
            myContact.MailingStreet = myLead.Owner_3_Home_Address__c;
            myContact.MailingCity = myLead.Owner_3_Home_Address_City__c;
            myContact.MailingState = myLead.Owner_3_Home_Address_State__c;
            myContact.mailingPostalCode = myLead.Owner_3_Home_Address_Zip__c;
            myContact.Authorize_Run_Credit__c = myLead.Authorize_Run_Credit_Owner_3__c;

            if(!String.isEmpty(myLead.ConvertedOpportunityId)){
                createContactRole(myContact, myLead.ConvertedOpportunityId);
            }

            contactsToInsert.add(myContact);
        }
    }

    private void createOwner4(Lead myLead){
        if(!String.isEmpty(myLead.Owner_4_First_Name__c) && !String.isEmpty(myLead.Owner_4_Last_Name__c)){
            Contact myContact = new Contact();
            myContact.FirstName = myLead.Owner_4_First_Name__c;
            myContact.LastName  = myLead.Owner_4_Last_Name__c;
            myContact.AccountId = myLead.ConvertedAccountId;

            myContact.Business_Main_Phone__c = myLead.Owner_4_Direct_Phone__c;
            myContact.MobilePhone = myLead.Owner_4_Mobile__c;
            myContact.Email = myLead.Owner_4_Email__c;
            myContact.McaApp__Social_Security_Number1__c = myLead.Owner_4_SSN__c;
            myContact.Credit_Score__c =myLead.Owner_4_Credit_Score__c;
            myContact.Birthdate_for_Workflow__c = myLead.Owner_4_Birthdate__c;
            myContact.Title = myLead.Owner_4_Title__c;
            myContact.McaApp__Of_Ownership__c = myLead.Owner_4_Ownership__c;
            myContact.MailingStreet = myLead.Owner_4_Home_Address__c;
            myContact.MailingCity = myLead.Owner_4_Home_Address_City__c;
            myContact.MailingState = myLead.Owner_4_Home_Address_State__c;
            myContact.mailingPostalCode = myLead.Owner_4_Home_Address_Zip__c;
            myContact.Authorize_Run_Credit__c = myLead.Authorize_Run_Credit_Owner_4__c;

            if(!String.isEmpty(myLead.ConvertedOpportunityId)){         
                createContactRole(myContact, myLead.ConvertedOpportunityId);
            }

            contactsToInsert.add(myContact);
            
        }
    }

    private void createContactRole(Contact myContact, Id myOpportunityId){
        
        //We use contact roles for opportunities.
        OpportunityContactRole myOpportunityContactRole = new OpportunityContactRole();
        myOpportunityContactRole.Contact = myContact;
        myOpportunityContactRole.OpportunityId = myOpportunityId;
        myOpportunityContactRole.Role = 'Business Owner';       

        opportunitiesContactRolesToInsert.add(myOpportunityContactRole);
        
    }


}