/* Class to Reflect the Roll-up of Amount of Recivables and Payables from  Opportunity
 * on to fields of campaign
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    11/06/2014                              Initial Draft
 */ 


public with sharing class CalculateRollupOnCampaign {
	
	//Variable Declaration
	private Set<Id> oppIdSet = new Set<Id>();
	private Set<Id> campaignIdSet = new Set<Id>();
	private Map<Id, Opportunity> OpportunityRecordMap = new Map<Id, Opportunity> ();
	private Map<Id, list<Opportunity>> OpportunityListRecordMap = new  Map<Id, list<Opportunity>> ();
	
	//Method to caluclate Rollup of Amounts on  After Insert of Primary Campaign
	public void PopulateValuesOnCampaign(Map<Id,Opportunity>pOpportunityoldMap,Map<Id,Opportunity>pOpportunitynewMap,
										 list<Opportunity> pOldOpportunityList,list<Opportunity> pNewOpportunityList){
        
        //iterate over Opportunity record on New Opportunity List to add Campaign Id                                    	
		for(Opportunity newOpportunityRec : pNewOpportunityList){
         	campaignIdSet.add(newOpportunityRec.CampaignId);
			campaignIdSet.remove(null);
		}//End For
         
        //Query Opportunity record on fetch  amount fields using Campaign Id added in Set
		list<Opportunity> lstOpportunity = [Select Id,
         										   CampaignId,
         										   Total_Commissions_Payable__c,
        									 	   Total_Commissions_Receivable__c,
        									 	   Total_Payables__c,
        									 	   Total_Receivables__c
        							  		 From Opportunity
        							  		 Where CampaignId IN :campaignIdSet];
        
        //iterate over Opportunity record to add Campaign Id and Opportunity record          
		for(Opportunity opp : lstOpportunity){
        	
        	if(!OpportunityListRecordMap.containskey(opp.CampaignId)){
        		OpportunityListRecordMap.put(opp.CampaignId, new List<Opportunity>{opp});
        	}//End if
               
            else{
            	OpportunityListRecordMap.get(opp.CampaignId).add(opp);
            }//End Else
        }//End For
        
        //Declare Campaign list to be updated
        list<Campaign> lstUpdateCampaign = new list<Campaign>();
        
        //Iterate over Campaign ID using Opportunity Map
        for(Id campaignId : OpportunityListRecordMap.Keyset()){
        	
        	Campaign objCampaign = new Campaign(Id = campaignId);
        	
        	//Initialise values
        	Decimal TotalCommissionsPayable = 0.0;
        	Decimal TotalCommissionsReceivable = 0.0;
        	Decimal TotalPayables = 0.0;
        	Decimal TotalReceivables = 0.0;
        	
        	for(Opportunity objOpp : OpportunityListRecordMap.get(campaignId)){
        		if(objOpp.Total_Commissions_Payable__c != null) {
        			TotalCommissionsPayable += objOpp.Total_Commissions_Payable__c;
        		}//End if
        		if(objOpp.Total_Commissions_Receivable__c != null) {
        			TotalCommissionsReceivable += objOpp.Total_Commissions_Receivable__c;
        		}//End if
        		if(objOpp.Total_Payables__c != null) {
        			TotalPayables += objOpp.Total_Payables__c;
        		}//End if
        		if(objOpp.Total_Receivables__c != null) {
        			TotalReceivables += objOpp.Total_Receivables__c;
        		}//End if
        	}//End For
        	
        	//Assign Values to Campaign Fields
        	objCampaign.Total_Commissions_Payable__c = TotalCommissionsPayable;
        	objCampaign.Total_Commissions_Receivable__c = TotalCommissionsReceivable;
        	objCampaign.Total_Payables__c = TotalPayables;
        	objCampaign.Total_Receivables__c = TotalReceivables;
        	
        	//Check if Campaign Id is null
        	if(objCampaign.Id <> null)
        		lstUpdateCampaign.add(objCampaign);
        }
        system.savepoint savePointInstance = Database.setSavepoint();
        
        try{
        	Database.update(lstUpdateCampaign);
        }catch(exception e){
        	Database.rollback(savePointInstance);
        }//End catch
    }//End PopulateValuesOnCampaign
    
    //Method to caluclate Rollup of Amounts on  Updating Primary Campaign of Opportunity Record
    public void PopulateValuesOnCampaignOnUpdate(Map<Id,Opportunity>pOpportunityoldMap,Map<Id,Opportunity>pOpportunitynewMap,
    											 list<Opportunity> pOldOpportunityList, list<Opportunity> pNewOpportunityList){
    	//set<Id> oldIdSet = new set<Id> ();										 	
        //iterate over Opportunity record on New Opportunity List to add Campaign Id                                       	
		for(Opportunity newOpportunityRec : pOldOpportunityList){
         	campaignIdSet.add(newOpportunityRec.CampaignId);
         	system.debug('****campaignIdSet before If****'+campaignIdSet);
				if(pOpportunitynewMap.get(newOpportunityRec.Id).CampaignId <> pOpportunityoldMap.get(newOpportunityRec.Id).CampaignId){
         			campaignIdSet.add(pOpportunitynewMap.get(newOpportunityRec.Id).CampaignId);
         			system.debug('****campaignIdSet After If****'+campaignIdSet);
			}//End If
		}//End For
		
		//iterate over Opportunity record on New Opportunity List to add Campaign Id       
		/*for(Opportunity newOpportunityRec : pNewOpportunityList){
			campaignIdSet.add(newOpportunityRec.CampaignId);
				if(pOpportunityoldMap.get(newOpportunityRec.Id).CampaignId <> null){
					campaignIdSet.add(pOpportunityoldMap.get(newOpportunityRec.Id).CampaignId);
				}//End If
		}//End For
		*/
		//Remove Null Campaign IDs from set
		campaignIdSet.remove(null);
        system.debug('****campaignIdSet****'+campaignIdSet);
        //Query Opportunity record on fetch  amount fields using Campaign Id added in Set 
		list<Opportunity> lstOpportunity = [Select CampaignId,
     											   Total_Commissions_Payable__c,
	    									 	   Total_Commissions_Receivable__c,
	    									 	   Total_Payables__c,
	    									 	   Total_Receivables__c
    							  		    From Opportunity
    							  		    Where CampaignId IN :campaignIdSet ];
    	system.debug('****lstOpportunity size befor loop Criteria****'+lstOpportunity.size());						  		    
    	//iterate over Opportunity record to add Campaign Id and Opportunity record						  		    
		for(Opportunity opp : lstOpportunity){
        	
			if(!OpportunityListRecordMap.containskey(opp.CampaignId)){
				OpportunityListRecordMap.put(opp.CampaignId, new List<Opportunity>{opp});
			}//End if
			else{
				OpportunityListRecordMap.get(opp.CampaignId).add(opp);
			}//End else
		}//End for
        
        //Declare List to Update Campaign
		list<Campaign> lstUpdateCampaign = new list<Campaign>();
        Campaign objCampaign;
        
        //Check if No Campaign is Asscoiated with Opportunity Record the assign zero values
        if(lstOpportunity.size() <=0 ){
			for(Id campaignId:campaignIdSet){
				objCampaign = new Campaign(Id = campaignId);
				objCampaign.Total_Commissions_Payable__c = 0.0;
				objCampaign.Total_Commissions_Receivable__c = 0.0;
				objCampaign.Total_Payables__c = 0.0;
				objCampaign.Total_Receivables__c = 0.0;
	        	
	        	//Check if Campaign Id in Null
	        	if(objCampaign.Id <> null)
        			lstUpdateCampaign.add(objCampaign);
        			//update objCampaign;
        	}//End For
        	
        	system.savepoint savePointInstance = Database.setSavepoint();
        
        	try{
        		Database.update(lstUpdateCampaign);
        	}//End try
        	catch(exception e){
        		Database.rollback(savePointInstance);
        	}//End catch
        }//End If
        
        system.debug('****lstOpportunity size befor loop of campaign Id****'+lstOpportunity.size());
         //Iterate over Campaign ID using Opportunity Map
        for(Id campaignId : OpportunityListRecordMap.Keyset()){
        	
        	objCampaign = new Campaign(Id = campaignId);
        	
        	Decimal TotalCommissionsPayable = 0.0;
        	Decimal TotalCommissionsReceivable = 0.0;
        	Decimal TotalPayables = 0.0;
        	Decimal TotalReceivables = 0.0;
        	
        	for(Opportunity objOpp : OpportunityListRecordMap.get(campaignId)){
        			
        		if(objOpp.Total_Commissions_Payable__c != null) {
        			TotalCommissionsPayable += objOpp.Total_Commissions_Payable__c;
        		}
        		if(objOpp.Total_Commissions_Receivable__c != null) {
        			TotalCommissionsReceivable += objOpp.Total_Commissions_Receivable__c;
        		}
        		if(objOpp.Total_Payables__c != null) {
        			TotalPayables += objOpp.Total_Payables__c;
        		}
        		if(objOpp.Total_Receivables__c != null) {
        			TotalReceivables += objOpp.Total_Receivables__c;
        		}
        	}//End For
        	
        	objCampaign.Total_Commissions_Payable__c = TotalCommissionsPayable;
        	objCampaign.Total_Commissions_Receivable__c = TotalCommissionsReceivable;
        	objCampaign.Total_Payables__c = TotalPayables;
        	objCampaign.Total_Receivables__c = TotalReceivables;
        	
        	if(objCampaign.Id != null)
        		lstUpdateCampaign.add(objCampaign);
        	//lstUpdateCampaign.add(objCampaign);
        }//End for
        system.debug('****lstUpdateCampaign before updatig****'+lstUpdateCampaign.size());
        system.savepoint savePointInstance = Database.setSavepoint();
        
        try{
        	Database.update(lstUpdateCampaign);
        }//End try
        catch(exception e){
        	Database.rollback(savePointInstance);
        }//End Catch
        system.debug('****lstUpdateCampaign after updatig****'+lstUpdateCampaign.size());
    }//End PopulateValuesOnCampaignOnUpdate method
    
    //Method to caluclate Rollup of Amounts on  Delete of Opportunity Record attached to primary campaign
    public void PopulateValuesOnCampaignOnDelete(Map<Id,Opportunity>pOpportunityoldMap,Map<Id,Opportunity>pOpportunitynewMap,
    											 list<Opportunity> pOldOpportunityList, list<Opportunity> pNewOpportunityList){
    											 	
        //iterate over Opportunity record on New Opportunity List to add Campaign Id                                       	
		for(Opportunity newOpportunityRec : pOldOpportunityList){
			campaignIdSet.add(newOpportunityRec.CampaignId);
			campaignIdSet.remove(null);
		}
		
		//Query Opportunity record on fetch  amount fields using Campaign Id added in Set 
		list<Opportunity> lstOpportunity = [Select CampaignId,
		 										   Total_Commissions_Payable__c,
											 	   Total_Commissions_Receivable__c,
											 	   Total_Payables__c,
											 	   Total_Receivables__c
									  		 From Opportunity
									  		 Where CampaignId IN :campaignIdSet ];
									  		 
		//iterate over Opportunity record to add Campaign Id and Opportunity record
		for(Opportunity opp : lstOpportunity){
		    	
			if(!OpportunityListRecordMap.containskey(opp.CampaignId)){
				OpportunityListRecordMap.put(opp.CampaignId, new List<Opportunity>{opp});
			}
			else{
				OpportunityListRecordMap.get(opp.CampaignId).add(opp);
			}
		}//End For
		
		Campaign objCampaign;
		list<Campaign> lstUpdateCampaign = new list<Campaign>();
		
		// All opportunities are deleted for campaign
		if(lstOpportunity.size() <=0 ){
			for(Id campaignId:campaignIdSet){
				objCampaign = new Campaign(Id = campaignId);
				objCampaign.Total_Commissions_Payable__c = 0.0;
				objCampaign.Total_Commissions_Receivable__c = 0.0;
				objCampaign.Total_Payables__c = 0.0;
				objCampaign.Total_Receivables__c = 0.0;
    	
    		if(objCampaign.Id <> null)
				lstUpdateCampaign.add(objCampaign);
			}//End For
			
        	system.savepoint savePointInstance = Database.setSavepoint();
        
        	try{
        		Database.update(lstUpdateCampaign);
           	}//End try
           	catch(exception e){
        		Database.rollback(savePointInstance);
            }//End Catch
		}//End if

		for(Id campaignId : OpportunityListRecordMap.Keyset()){
			
			objCampaign = new Campaign(Id = campaignId);
			
			Decimal TotalCommissionsPayable = 0.0;
			Decimal TotalCommissionsReceivable = 0.0;
			Decimal TotalPayables = 0.0;
			Decimal TotalReceivables = 0.0;
	        	
			for(Opportunity objOpp : OpportunityListRecordMap.get(campaignId)){
	        			
				if(objOpp.Total_Commissions_Payable__c != null) {
					TotalCommissionsPayable += objOpp.Total_Commissions_Payable__c;
				}
				if(objOpp.Total_Commissions_Receivable__c != null) {
					TotalCommissionsReceivable += objOpp.Total_Commissions_Receivable__c;
				}
				if(objOpp.Total_Payables__c != null) {
					TotalPayables += objOpp.Total_Payables__c;
				}
				if(objOpp.Total_Receivables__c != null) {
					TotalReceivables += objOpp.Total_Receivables__c;
				}
			}//End for
	        	
			objCampaign.Total_Commissions_Payable__c = TotalCommissionsPayable;
			objCampaign.Total_Commissions_Receivable__c = TotalCommissionsReceivable;
			objCampaign.Total_Payables__c = TotalPayables;
			objCampaign.Total_Receivables__c = TotalReceivables;
			
			if(objCampaign.Id <> null)
			    lstUpdateCampaign.add(objCampaign);
		}//End for
		
        system.savepoint savePointInstance = Database.setSavepoint();
        
        try{
        	Database.update(lstUpdateCampaign);
        }//End Try
        catch(exception e){
        	Database.rollback(savePointInstance);
        }//End Catch
	}//End PopulateValuesOnCampaignOnDelete Method
}//End CalculateRollupOnCampaign Class