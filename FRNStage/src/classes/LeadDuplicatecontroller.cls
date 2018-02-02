public class LeadDuplicatecontroller{
    
    public static final String TRUE_VALUE                = 'true';

    public Id                   leadId                  {get;set;}
    public List<Lead>           duplicateLeadList       {get;set;}
    public List<Opportunity>    duplicateOppContacts    {get;set;}
    public List<Contact>        duplicateContact        {get;set;}
    public SearchParams         searchParameters        {get;set;}


    public class SearchParams {
        String LeadID;
        String LeadName;
        String Leadphone;
        String LeadMphone;
        String LeadWphone;
        String isOnEditMode;
        String findDuplicateType;

        public Boolean isBlank(){
            return   String.isBlank(LeadName)
                  && String.isBlank(Leadphone)
                  && String.isBlank(LeadMphone)
                  && String.isBlank(LeadWphone);
        }

        public SearchParams resolveParams(Id leadId){
            this.LeadID = leadId;
            this.isOnEditMode = ApexPages.currentPage().getParameters().get('onEditMode');
            
            if( TRUE_VALUE.equalsIgnoreCase(this.isOnEditMode) == true ){
                this.LeadName = ApexPages.currentPage().getParameters().get('LName');
                this.Leadphone = ApexPages.currentPage().getParameters().get('LPhone');
                this.LeadMphone = ApexPages.currentPage().getParameters().get('LMPhone');
                this.LeadWphone = ApexPages.currentPage().getParameters().get('LWPhone');
            } else {
                resolveParamsWithLead(leadId);
            }
            return this;
        }

        public SearchParams resolveParamsWithLead(Id leadId){
            Lead parentLead = [
                Select Id
                     , Name
                     , Phone
                     , MobilePhone
                     , Work_Phone__c
                  FROM Lead
                 WHERE Id = :LeadID
                 LIMIT 1
            ];

            if( parentLead != null ){
                this.LeadName   = parentLead.Name;
                this.Leadphone  = parentLead.Phone;
                this.LeadMphone = parentLead.MobilePhone;
                this.LeadWphone = parentLead.Work_Phone__c;
            }

            return this;
        }
   }
    
    public LeadDuplicatecontroller (ApexPages.StandardController controller){
        Lead leadRecord = (Lead)controller.getRecord();
        leadId = leadRecord!=null ? leadRecord.Id : null;   
    }

    public SearchParams initializeParams(){
        if( searchParameters == null ){
            searchParameters  = new SearchParams().resolveParams(leadId);  
        }
        return searchParameters;
    }

    public PageReference initializeLeadSearch(){
        duplicateLeadList         = searchForDuplicateLeads(initializeParams());
        return null;
    }

    public PageReference initializeOpportunitySearch(){
        duplicateOppContacts      = searchForDuplicateOpportunities(initializeParams());
        return null;
    }

    public PageReference initializeContactSearch(){
        duplicateContact          = searchForDuplicateContacts(initializeParams());
        return null;
    }

    //search methods 
    //Search For Duplicate Lead Records
    public static List<Lead> searchForDuplicateLeads(SearchParams searchParam){

        if( searchParam == null || searchParam.isBlank() )
            return new List<Lead>();

        List<Lead> duplicateLeadList = [ 
               SELECT Id 
                    , Name
                    , Phone
                    , MobilePhone
                    , Email
                    , Owner.name
                    , CreatedDate
                    , Caller_First_Name__c
                    , Caller_Last_Name__c
                    , Caller_Phone__c
                    , Caller_Mobile__c
                    , Status
                    , Work_Phone__c
                 FROM Lead 
                WHERE IsConverted = false 
                  AND (
                            ( Name   		<> null AND Name          	=  :searchParam.LeadName )
                        OR  ( MobilePhone   <> null AND MobilePhone     = :searchParam.Leadphone )
                        OR  ( Phone         <> null AND Phone           = :searchParam.Leadphone )
                        OR  ( Work_Phone__c <> null AND Work_Phone__c   = :searchParam.Leadphone )

                        OR  ( MobilePhone   <> null AND MobilePhone     = :searchParam.LeadMphone )
                        OR  ( Phone         <> null AND Phone           = :searchParam.LeadMphone )
                        OR  ( Work_Phone__c <> null AND Work_Phone__c   = :searchParam.LeadMphone )

                        OR  ( MobilePhone   <> null AND MobilePhone     = :searchParam.LeadWphone )
                        OR  ( Phone         <> null AND Phone           = :searchParam.LeadWphone )
                        OR  ( Work_Phone__c <> null AND Work_Phone__c   = :searchParam.LeadWphone )

                      )
                  AND Id  != :searchParam.LeadID
             ORDER BY Name ASC
                LIMIT 50000
        ];

        return duplicateLeadList;
    }

    //Search for duplicate Opportunity Records
    public static List<Opportunity> searchForDuplicateOpportunities(SearchParams searchParam){

        if( searchParam == null || searchParam.isBlank() )
            return new List<Opportunity>();

        // Matching Opportunities
        List<Opportunity> opportunityList  = [
            SELECT Id
                 , Name
                 , Contact__r.Name
                 , Contact__r.FirstName
                 , Contact__r.LastName
                 , Contact__r.MobilePhone
                 , Contact__r.Phone
                 , Contact__r.Email
                 , Contact__r.MailingStreet
                 , Contact__r.MailingCity
                 , Contact__r.MailingStateCode
                 , Contact__r.MailingPostalCode
                 , Owner.name
                 , CreatedDate
                 , StageName
                 , Contact__r.HomePhone
                 , Contact__r.OtherPhone
                 , Contact__r.Work_Phone__c
              FROM Opportunity 
             WHERE Contact__c != null 
               AND (
                            ( Contact__r.Name         <> null AND Contact__r.Name 		   = :searchParam.LeadName )
                        OR  (Contact__r.MobilePhone   <> null AND Contact__r.MobilePhone   = :searchParam.Leadphone)
                        OR  (Contact__r.Phone         <> null AND Contact__r.Phone         = :searchParam.Leadphone)
                        OR  (Contact__r.HomePhone     <> null AND Contact__r.HomePhone     = :searchParam.Leadphone)
                        OR  (Contact__r.OtherPhone    <> null AND Contact__r.OtherPhone    = :searchParam.Leadphone)
                        OR  (Contact__r.Work_Phone__c <> null AND Contact__r.Work_Phone__c = :searchParam.Leadphone)

                        OR  (Contact__r.MobilePhone   <> null AND Contact__r.MobilePhone   = :searchParam.LeadMphone)
                        OR  (Contact__r.Phone         <> null AND Contact__r.Phone         = :searchParam.LeadMphone)
                        OR  (Contact__r.HomePhone     <> null AND Contact__r.HomePhone     = :searchParam.LeadMphone)
                        OR  (Contact__r.OtherPhone    <> null AND Contact__r.OtherPhone    = :searchParam.LeadMphone)
                        OR  (Contact__r.Work_Phone__c <> null AND Contact__r.Work_Phone__c = :searchParam.LeadMphone)

                        OR  (Contact__r.MobilePhone   <> null AND Contact__r.MobilePhone   = :searchParam.LeadWphone)
                        OR  (Contact__r.Phone         <> null AND Contact__r.Phone         = :searchParam.LeadWphone)
                        OR  (Contact__r.HomePhone     <> null AND Contact__r.HomePhone     = :searchParam.LeadWphone)
                        OR  (Contact__r.OtherPhone    <> null AND Contact__r.OtherPhone    = :searchParam.LeadWphone)
                        OR  (Contact__r.Work_Phone__c <> null AND Contact__r.Work_Phone__c = :searchParam.LeadWphone)

                   )      
             ORDER BY Name ASC
             LIMIT 50000
        ];

        return opportunityList;
    }
    
    //Search for duplicate Contact Records
    public static List<Contact> searchForDuplicateContacts(SearchParams searchParam){

        if( searchParam == null || searchParam.isBlank() )
            return new List<Contact>();

        //Matching Contact
        List<Contact> contactList = [ 
            SELECT Id
                 , Name
                 , Phone
                 , HomePhone
                 , MobilePhone
                 , OtherPhone
                 , Work_Phone__c
                 , Email
                 , MailingStreet
                 , MailingCity
                 , MailingStateCode
                 , MailingPostalCode
                 , Owner.Name
                 , CreatedDate 
              FROM Contact
             WHERE  ( Name         <> null  AND Name 		  = :searchParam.LeadName)

                OR  ( Phone         <> null AND Phone         = :searchParam.Leadphone )
                OR  ( HomePhone     <> null AND HomePhone     = :searchParam.Leadphone )
                OR  ( MobilePhone   <> null AND MobilePhone   = :searchParam.Leadphone )
                OR  ( OtherPhone    <> null AND OtherPhone    = :searchParam.Leadphone )
                OR  ( Work_Phone__c <> null AND Work_Phone__c = :searchParam.Leadphone )

                OR  ( Phone         <> null AND Phone         = :searchParam.LeadMphone )
                OR  ( HomePhone     <> null AND HomePhone     = :searchParam.LeadMphone )
                OR  ( MobilePhone   <> null AND MobilePhone   = :searchParam.LeadMphone )
                OR  ( OtherPhone    <> null AND OtherPhone    = :searchParam.LeadMphone )
                OR  ( Work_Phone__c <> null AND Work_Phone__c = :searchParam.LeadMphone )

                OR  ( Phone         <> null AND Phone         = :searchParam.LeadWphone )
                OR  ( HomePhone     <> null AND HomePhone     = :searchParam.LeadWphone )
                OR  ( MobilePhone   <> null AND MobilePhone   = :searchParam.LeadWphone )
                OR  ( OtherPhone    <> null AND OtherPhone    = :searchParam.LeadWphone )
                OR  ( Work_Phone__c <> null AND Work_Phone__c = :searchParam.LeadWphone )

             LIMIT 50000
        ];

        return contactList;
    }

}