/*
 *
 * BFI-305
 * Current and Maximum Workload on User are not Updated
 * Write a trigger that will update the Current Workload and Maximum Workload on the User record whenever a scorecard is created, updated, or deleted
 *
 */
public class UpdateUsersForScorecards{
	
	public static void updateUsers(List<Sales_Rep_Report_Card__c> scorecardsList, boolean deleted){
		List<Id> representativeIds = new List<Id>();
		List<User> usersToUpdate = new List<User>();

		for(Sales_Rep_Report_Card__c scorecard : scorecardsList){
			representativeIds.add(scorecard.Sales_Rep__c);				
		}

		Map<Id,User> usersMap = new Map<Id,User>([select id, cmblre__Current_Workload__c, cmblre__Maximum_Workload__c from User where id IN:representativeIds]);

		for(Sales_Rep_Report_Card__c scorecard : scorecardsList){
			if(usersMap.containsKey(scorecard.Sales_Rep__c)){

				User representative = usersMap.get(scorecard.Sales_Rep__c);
			
				//If the scorecard is being deleted.
				if(deleted){
					representative.cmblre__Current_Workload__c = 0;
					representative.cmblre__Maximum_Workload__c = 0;
//					system.assert(false, 'DELETED CURRENT WORKLOAD:	' + representative.cmblre__Current_Workload__c + '	MAXIMUM WORKLOAD:    ' + representative.cmblre__Maximum_Workload__c);
				}else{
					// If the scorecard was just created or is being updated we copy the representative current and maximum workload from the scorecard to the user.
					representative.cmblre__Current_Workload__c = scorecard.Sales_Rep_Workload_Hours__c;
					representative.cmblre__Maximum_Workload__c = scorecard.Sales_Rep_Maximum_Workload_Hours__c;	
//					system.assert(false, 'NOT DELETED CURRENT WORKLOAD:	' + representative.cmblre__Current_Workload__c + '	MAXIMUM WORKLOAD:    ' + representative.cmblre__Maximum_Workload__c);				
				}

				usersToUpdate.add(representative);
			}
		}

		update usersToUpdate;
	}	
}