global class HarvestProjectIterable implements Iterable<HarvestProject__c> {
	
	global Iterator<HarvestProject__c> Iterator() {
		return new HarvestProjectIterator();
	} 
}