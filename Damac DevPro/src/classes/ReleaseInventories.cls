global class ReleaseInventories implements Schedulable {
	global void execute(SchedulableContext SC) {
          ReleaseInventoryBatch releaseInv = new ReleaseInventoryBatch();
          Database.executeBatch(releaseInv); 
   }
}