/*
 *  Apex controller class call from CreateRenwal page to clone an Opportunity with Owner1, owner2 and Contact Roles.
 *  Revision History:
 *
 *  Version           Author                 Date(DD/MM/YYYY)       Description
 *  1.0               Shraddha P.               11/05/2015          Initial Draft
 *  2.0               Ajinkya H.                15/03/2017          Changes for supporting more Owners
 */

public with sharing class CreateRenewalController {

    public Id oppId                                 {get; set;}
    public Opportunity objOpp                       {get; set;}
    public Boolean showHeaderFlag                   {get; set;}
    public String isConsole;

    public CreateRenewalController(){
        // Get id of current Opportunity
        oppId = ApexPages.currentPage().getParameters().get('Id');
        isConsole = ApexPages.currentPage().getParameters().get('isConsole');
        if(isConsole == '1') {
            showHeaderFlag = false;
        } else {
            showHeaderFlag = true;
        }
    }

    public pageReference create() {
        List<OpportunityContactRole> oppContactRole = new List<OpportunityContactRole>();
        Map<String, Schema.SObjectField> filterQuery = Schema.SObjectType.Opportunity.fields.getMap();
        PageReference pgRef;
        String fieldnames = ' ';
        String query ;
        /*for(Schema.SObjectField s:filterQuery.values()){
            Schema.DescribeFieldResult sfield=s.getDescribe();
            if(sfield.getName() != 'CreatedDate' && sfield.getName() != 'LastModifiedById' && sfield.getName() !='LastReferencedDate'
            && sfield.getName() !='LastModifiedDate' && sfield.getName() !='LastViewedDate' && sfield.getName() !='OwnerId')
                fieldnames += s + ',';
        }*/
        fieldnames = fieldnames.substring(0,fieldnames.length()-1);
        query ='Select Name, NextStep, Id, LeadSource, Owner_1__c, Owner_2__c, StageName, Owner_1_Ownership__c,'
                +' Owner_2_Ownership__c, AccountId, CloseDate, Owner_3__c, Owner_4__c, Owner_3_Ownership__c,'
                +' Owner_4_Ownership__c '
                +' from '+ SObjectType.Opportunity.Name
                +' where '+ SObjectType.Opportunity.fields.Id.getSobjectField() +' = \''+ oppId + '\'';
        /*query ='Select'+fieldnames+' from '+
                 SObjectType.Opportunity.Name+ ' where '+
                 SObjectType.Opportunity.fields.Id.getSobjectField() +' = \''+ oppId + '\'';*/
        objOpp = Database.query(query);
        oppContactRole = [Select Id, OpportunityId, ContactId, Role, IsPrimary, IsDeleted From OpportunityContactRole where OpportunityId =: objOpp.Id];

        //copy current Opportunity to new one
        Opportunity renewalOpportunity = objOpp;
        renewalOpportunity.Id = null;
        //renewalOpportunity.Previous_Opportunity__c = String.valueof(oppId);
        renewalOpportunity.Previous_Opportunity1__c = oppId;
        renewalOpportunity.StageName = system.label.MovingRenewal_CreatedOppStage;
        renewalOpportunity.Type = system.label.MovingRenewal_CreatedOppType;//'Existing Customer - Renewal';
        try{
            //insert new Oportunity
             if(renewalOpportunity != null)
                insert renewalOpportunity;

             //Copy the OpportunityContactRole from current Opportunity to new Opportunity
             for(OpportunityContactRole oppcr : oppContactRole){
                oppcr.id = null;
                oppcr.OpportunityId = objOpp.id;
             }
             insert oppContactRole;

             //Update current Opportunity with link to new Opportunity
             Opportunity oppToUpdate = [select Id, Next_Opportunity__c from Opportunity where Id =: oppId];
             oppToUpdate.Next_Opportunity__c = renewalOpportunity.id;
             oppToUpdate.Remove_from_Renewal_Management__c = true;
             update oppToUpdate;
             if(isConsole == '1') {
                 pgRef = new PageReference('/'+ renewalOpportunity.Id+'?isdtp=vw');
             } else {
                 pgRef = new PageReference('/'+ renewalOpportunity.Id);
             }
             return pgRef;

        }catch(DMLException e){
             apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,e.getMessage());
             apexpages.addmessage(msg);
             return null;
        }
        //return new PageReference('/'+ renewalOpportunity.Id);
    }
}