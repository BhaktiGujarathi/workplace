public with sharing class StipsHandler {
	
	public void onAfterInsert(list<Stips__c> stipsList){
		
		//For all the inserted stips pass trigger in
		StoreChildToParentHelper objHandler = new StoreChildToParentHelper();
		objHandler.copyField(stipsList);
	} 
	
	public void onAfterUpdate(){
		
	}
}