public class StorageAccountReassign {

	public static Id storeId = [SELECT Id FROM User WHERE LastName = 'Storage Account'].Id;

	public static void storeOpps(Map<Id, Account> newAccts, Map<Id, Account> oldAccts){

		Set<Id> acctIds = newAccts.keySet();
		Opportunity[] opps = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE AccountId IN :acctIds];
		Opportunity[] updateOpps = new Opportunity[]{};

		Map<Id, List<Opportunity>> acctOpps = new Map<Id, List<Opportunity>>();

		for(Opportunity o : opps) {
			if( !acctOpps.keySet().contains(o.AccountId) ) {
				Opportunity[] oppList = new Opportunity[]{};
				oppList.add(o);
				acctOpps.put(o.AccountId, oppList);
			} else {
				acctOpps.get(o.AccountId).add(o);
			}
		}

		for(Account acct : newAccts.values()) {
			
			if(oldAccts.get(acct.Id).Opportunity_Stage_Category__c != acct.Opportunity_Stage_Category__c
				&& acct.Opportunity_Stage_Category__c == 'Duplicate Opp' && acct.Funded_Opp__c == FALSE) {
				
				for(Opportunity o : acctOpps.get(acct.Id)){
					o.OwnerId = storeId;
					updateOpps.add(o);
				}
				
			}
			
		}

		update updateOpps;

	}

}