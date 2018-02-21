global class BankDirectoryService implements Schedulable {
	
	global void execute(SchedulableContext sc) {
		Admin_Bank_Directory_Settings__c bankDirectorySettings = Admin_Bank_Directory_Settings__c.getOrgDefaults();
		bankDirectorySettings.Import_Job_Id__c = Database.executeBatch(new BankDirectoryBatch(), BankDirectoryBatch.BATCH_SIZE);
    	upsert bankDirectorySettings;
	}
}