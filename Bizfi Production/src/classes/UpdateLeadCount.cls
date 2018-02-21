/*
 *
 * Narrative
 * As a user, I need to know the count of leads per agent, so that I can calculate his total workload.
 * 
 * Context
 * Refer to attachment in BFI-242.
 * 
 * Acceptance Criteria
 * Create a trigger / batch / etc. that will automatically update the Lead Count field depending on the Count_Against_Pipeline__c formula checkbox as per #7 - #11.
 *
 */
public class UpdateLeadCount{
	public static boolean firstRun = true; 
	
	// 	When a Lead is created and Count_Against_Pipeline__c is checked or when a Lead is edited that causes Count_Against_Pipeline__c to be checked, the Count of Leads on the Lead Owner’s Sales Rep Scorecard record will increase by 1.
	// 	The Total Work columns will automatically recalculate.
	public static void incrementLeadCountForNewLeadsOnScorecard(List<Lead> newLeads){
		if(!newLeads.isEmpty() && newLeads != null){
			List<Sales_Rep_Report_Card__c> scorecardsToUpdate = new List<Sales_Rep_Report_Card__c>();
			List<Id> ownerIdsList = new List<Id>();

			for(Lead currentLead : newLeads){
				ownerIdsList.add(currentLead.OwnerId);
			}

			List<Sales_Rep_Report_Card__c> scorecardsForThisLeads = new List<Sales_Rep_Report_Card__c>();

			scorecardsForThisLeads = [select id, Lead_Count__c from Sales_Rep_Report_Card__c where Sales_Rep__c IN: ownerIdsList];

			if(!scorecardsForThisLeads.isEmpty()){
				for (Sales_Rep_Report_Card__c scorecard : scorecardsForThisLeads){

					scorecard.Lead_Count__c++;
					scorecardsToUpdate.add(scorecard);
				}
			}

			update scorecardsToUpdate;
		}
	}

	//	When a Lead’s owner is changed and Count_Against_Pipeline__c is checked), the Count of Leads on the new Lead Owner’s Sales Rep Scorecard record will increase by 1.
	//	The Count of Leads on the previous Lead Owner’s Sales Rep Scorecard record will decrease by 1.
	//	The Total Work columns will automatically recalculate.
	public static void updateScorecardsForChangedLeadOwners(List<Lead> newLeads, List<Lead> oldLeads){
		if(!newLeads.isEmpty() && !oldLeads.isEmpty() && newLeads != null && oldLeads != null){
			List<Id> newOwnersIdsList = new List<Id>();
			List<Id> oldOwnersIdsList = new List<Id>();
			List<Sales_Rep_Report_Card__c> scorecardsToUpdate = new List<Sales_Rep_Report_Card__c>();

			for(Lead currentLead : newLeads){
				newOwnersIdsList.add(currentLead.OwnerId);
			}			

			for(Lead currentLead : oldLeads){
				oldOwnersIdsList.add(currentLead.OwnerId);
			}

			List<Sales_Rep_Report_Card__c> scorecardsForNewLeads = new List<Sales_Rep_Report_Card__c>();
			List<Sales_Rep_Report_Card__c> scorecardsForOldLeads = new List<Sales_Rep_Report_Card__c>();

			scorecardsForNewLeads = [select id, Lead_Count__c, Sales_Rep__c from Sales_Rep_Report_Card__c where Sales_Rep__c IN: newOwnersIdsList];
			scorecardsForOldLeads = [select id, Lead_Count__c, Sales_Rep__c from Sales_Rep_Report_Card__c where Sales_Rep__c IN: oldOwnersIdsList];

			if(!scorecardsForNewLeads.isEmpty()){
				for (Sales_Rep_Report_Card__c scorecard : scorecardsForNewLeads){
					for(Lead currentLead : newLeads){
						if(currentLead.OwnerId == scorecard.Sales_Rep__c ){
							scorecard.Lead_Count__c++;
						}
					}
					scorecardsToUpdate.add(scorecard);
				}
			}

			if(!scorecardsForOldLeads.isEmpty()){
				for (Sales_Rep_Report_Card__c scorecard : scorecardsForOldLeads){
					for(Lead currentLead : oldLeads){
						if(currentLead.OwnerId == scorecard.Sales_Rep__c ){
							if(scorecard.Lead_Count__c > 0){
								scorecard.Lead_Count__c--;
							}
						}
					}
					scorecardsToUpdate.add(scorecard);			
				}
			}

			update scorecardsToUpdate;
		}
	}

	// When a Lead is deleted or when a Lead is edited that causes Count_Against_Pipeline__c to be unchecked, the Count of Leads on the Lead Owner’s Sales Rep Scorecard record will decrease by 1.
	// The Total Work columns will automatically recalculate.
	public static void updateScorecardsForDeletedLeads(List<Lead> deletedLeads){
		if(!deletedLeads.isEmpty() && deletedLeads != null){
			List<Id> ownerIdsList = new List<Id>();
			List<Sales_Rep_Report_Card__c> scorecardsToUpdate = new List<Sales_Rep_Report_Card__c>();

			for(Lead currentLead : deletedLeads){
				ownerIdsList.add(currentLead.OwnerId);
			}

			List<Sales_Rep_Report_Card__c> scorecardsForThisLeads = new List<Sales_Rep_Report_Card__c>();

			scorecardsForThisLeads = [select id, Lead_Count__c, Sales_Rep__c from Sales_Rep_Report_Card__c where Sales_Rep__c IN: ownerIdsList and Lead_Count__c > 0];

			if(!scorecardsForThisLeads.isEmpty()){
				for (Sales_Rep_Report_Card__c scorecard : scorecardsForThisLeads){
					for(Lead currentLead : deletedLeads){
						if(currentLead.OwnerId == scorecard.Sales_Rep__c ){
							if(scorecard.Lead_Count__c > 0){
								scorecard.Lead_Count__c--;
							}
						}	
					}
					scorecardsToUpdate.add(scorecard);
				}
			}

			update scorecardsToUpdate;
		}
	}
}