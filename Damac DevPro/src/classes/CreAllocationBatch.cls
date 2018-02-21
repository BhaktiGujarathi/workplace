public with sharing class CreAllocationBatch implements Database.Batchable<SObject>, Database.Stateful {
     
     private set<Group> setGroupsForReallocation ;
     
     public CreAllocationBatch( set<Group> setGroupsForReallocation ) {
     	this.setGroupsForReallocation = setGroupsForReallocation ;
     }
     
     public Database.Querylocator start( Database.BatchableContext bc ) {
     	return Database.getQueryLocator( CreAllocationHelper.makeQueryString( setGroupsForReallocation ) );
     }
     
     public void execute( Database.BatchableContext bc, list<GroupMember> lstGroupMembers ) {
     	if( lstGroupMembers != null && !lstGroupMembers.isEmpty() ) {
     		set<Id> setUserIds = CreAllocationUtility.extractCreId( lstGroupMembers );
     		if( setUserIds != null && !setUserIds.isEmpty() ) {
     			map<Id, Integer> mapCreIdWorkload = CreAllocationHelper.calculateCreWorkLoad( setUserIds );
     			//map<Id, map<Id, Integer>> mapCreAccountTasks = makeCustomerContactMatrix( CreAllocationUtility.getTasks( setUserIds ) );
     			
     		}
     	}
     }
     
     public void finish( Database.BatchableContext bc ) {
     	if( setGroupsForReallocation != null && !setGroupsForReallocation.isEmpty() ) {
	     	CreAllocationBatch cab = new CreAllocationBatch( setGroupsForReallocation );
	     	database.executebatch( cab );
     	}
     }
     
     private static map<Id, map<Id, Integer>> makeCustomerContactMatrix( list<Task> lstTasks ) {
     	map<Id, map<Id, Integer>> mapCreAccountTasks = new map<Id, map<Id, Integer>>();
     	if( lstTasks != null && !lstTasks.isEmpty() ) {
		 	for( Task objTask : lstTasks ) {
		 		if( objTask.AccountId != null && objTask.OwnerId != null ) {
			 		if( mapCreAccountTasks.containsKey( objTask.OwnerId ) ) {
			 			if( mapCreAccountTasks.get( objTask.OwnerId ).containsKey( objTask.AccountId ) ) {
			 				Integer counter = mapCreAccountTasks.get( objTask.OwnerId ).get(  objTask.AccountId );
			 				mapCreAccountTasks.get( objTask.OwnerId ).put( objTask.AccountId, counter + 1 ) ;
			 			}
			 			else {
			 				mapCreAccountTasks.get( objTask.OwnerId ).put( objTask.AccountId, 1 );
			 			}
			 		}
			 		else {
			 			mapCreAccountTasks.put( objTask.OwnerId, new map<Id, Integer> { objTask.AccountId => 1 } ) ;
			 		}
		 		}
		 	}
     	}
     	return mapCreAccountTasks; 
     }
     
    /* private static map<Id,list<Account>> makeCreCustomerMatrix( set<Id> setUserIds ) {
     	list<Account> lstAccounts = CreAllocationUtility.getAccountsBasedOnContact( setUserIds );
     	if( lstAccounts != null && !lstAccounts.isEmpty() ) {
     		map<Id,list<Account>> mapCreCustomerMatrix = new map<Id,list<Account>>();
     		for( Account objAcc : lstAccounts ) {
     			
     		}
     		
     	}
     }*/
}