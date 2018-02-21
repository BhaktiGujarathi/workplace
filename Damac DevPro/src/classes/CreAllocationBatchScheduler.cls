public with sharing class CreAllocationBatchScheduler implements Schedulable {
   	public void execute( SchedulableContext SC ) {
   		
   		set<Group> setGroupsForReallocation = CreAllocationUtility.getAllGroups();
   		
   		CreAllocationBatch cab = new CreAllocationBatch( setGroupsForReallocation );
		database.executebatch( cab );
   	}
    
    /*
    	CreAllocationBatchScheduler cabScheduler = new CreAllocationBatchScheduler();
    	String strCron = '0 0 0 1 1/1 ? *';
    	system.schedule('Monthly Rebalancing for '+system.today().month() +' '+ system.today().year(), strCron, cabScheduler );
    */
    
}