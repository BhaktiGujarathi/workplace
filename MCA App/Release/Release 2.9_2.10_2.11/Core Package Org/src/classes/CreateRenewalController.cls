/* 
 *  Apex controller class call from CreateRenwal page to clone an Opportunity with Owner1, owner2 and Contact Roles.
 *  Revision History: 
 * 
 *  Version           Author                 Date(DD/MM/YYYY)               Description 
 *  1.0               Shraddha P.               11/5/2015					Initial Draft 
 */

public with sharing class CreateRenewalController {
	public Id oppId									{get; set;}
	public Opportunity objOpp						{get; set;}
	
	public CreateRenewalController(){
		//get id of current Opportunity
		oppId = ApexPages.currentPage().getParameters().get('Id');
	}
	
	public pageReference create(){
		list<OpportunityContactRole> oppContactRole = new list<OpportunityContactRole>();
		Map<String, Schema.SObjectField> filterQuery = Schema.SObjectType.Opportunity.fields.getMap();
		system.debug('***filterQuery***'+filterQuery);
		string fieldnames = ' ';
        String query ;
        /*for(Schema.SObjectField s:filterQuery.values()){
            Schema.DescribeFieldResult sfield=s.getDescribe();
            if(sfield.getName() != 'CreatedDate' && sfield.getName() != 'LastModifiedById' && sfield.getName() !='LastReferencedDate' 
            && sfield.getName() !='LastModifiedDate' && sfield.getName() !='LastViewedDate' && sfield.getName() !='OwnerId')
            	fieldnames += s + ',';
        }*/
        fieldnames = fieldnames.substring(0,fieldnames.length()-1);
        query ='Select Name,NextStep,Id,LeadSource,Owner_1__c,Owner_2__c,StageName,Owner_1_Ownership__c,Owner_2_Ownership__c,AccountId,CloseDate'+' from '+ 
                 SObjectType.Opportunity.Name+ ' where '+
                 SObjectType.Opportunity.fields.Id.getSobjectField() +' = \''+ oppId + '\'';
        /*query ='Select'+fieldnames+' from '+ 
                 SObjectType.Opportunity.Name+ ' where '+
                 SObjectType.Opportunity.fields.Id.getSobjectField() +' = \''+ oppId + '\'';*/
        system.debug('***Query***'+query);
        objOpp = Database.query(query);
        system.debug('***objOpp'+objOpp);
        oppContactRole = [Select Id, OpportunityId, ContactId, Role, IsPrimary, IsDeleted From OpportunityContactRole where OpportunityId =: objOpp.Id];
        system.debug('***oppContactRole'+oppContactRole);
        
        //copy current Opportunity to new one
        Opportunity renewalOpportunity = objOpp;
        renewalOpportunity.Id = null;
        //renewalOpportunity.Previous_Opportunity__c = String.valueof(oppId);
        renewalOpportunity.Previous_Opportunity1__c = oppId;
        renewalOpportunity.StageName = 'Renewal Prospecting';
        renewalOpportunity.Type = 'Existing Customer - Renewal';
        try{
        	//insert new Oportunity
        	 if(renewalOpportunity != null)
	         	insert renewalOpportunity;
	         system.debug('***renewalOpportunity>>>'+renewalOpportunity);
	         
	         //Copy the OpportunityContactRole from current Opportunity to new Opportunity
	         for(OpportunityContactRole oppcr : oppContactRole){
	         	oppcr.id = null;
	         	oppcr.OpportunityId = objOpp.id;
	         }
	         insert oppContactRole;
	          system.debug('***objOpp.Id>>>'+objOpp.Id);
	          system.debug('***renewalOpportunity.Id>>>'+renewalOpportunity.Id);
	          
	         //Update current Opportunity with link to new Opportunity
	         Opportunity oppToUpdate = [select Id, Next_Opportunity__c from Opportunity where Id =: oppId];
	         oppToUpdate.Next_Opportunity__c = renewalOpportunity.id;
	         update oppToUpdate;
	          
        }catch(DMLException e){
        	 apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,e.getMessage());
             apexpages.addmessage(msg);
        }
		return new PageReference('/'+ renewalOpportunity.Id);
	}
}