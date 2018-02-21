public with sharing class FundingoSettingsController {
	
	public Map<String,Boolean> formStateEditMode { get; set; }
	public Bank_Directory_Settings__c bankDirectorySettings { get; set; }
	public Application_Portal_Settings__c portalSettings { get; set; }
//	public ACH_Public_Settings__c achPublicSettings { get; set; }
//	public ACH_Credentials__c achWorksCredentials { get; set; }
//	public Bounce_Fees_Settings__c[] bounceFeeSettings { get; set; }
//	public String idDeleteFee { get; set; }

	public FundingoSettingsController() {
		init();		
	}


	private void init() {
		formStateEditMode = new Map<String,Boolean>{
			'BankDirectoryImportOptions' => false,
			'ApplicationOptions' => false,
			'PaymentProcessorOptions' => false,
			'ACHIntegrationOptions' => false,
			'ACHFeesSettingsOptions' => false,
			'ACHWorksCredentialsOptions' => false,
			'ACHWorksSettingsOptions' => false
		};

		bankDirectorySettings = Bank_Directory_Settings__c.getOrgDefaults();	
		portalSettings = Application_Portal_Settings__c.getOrgDefaults();
//		achPublicSettings = ACH_Public_Settings__c.getOrgDefaults();
//		bounceFeeSettings = new Bounce_Fees_Settings__c[]{ };


		/*if (ACH_Credentials__c.getInstance('ACH Works') != null) {
			achWorksCredentials = ACH_Credentials__c.getInstance('ACH Works');
		}
		else {
			achWorksCredentials = new ACH_Credentials__c(Name = 'ACH Works');
		}

		queryBounceFeesSettings();
*/		
	}

/*
	private void queryBounceFeesSettings() {
		for (Bounce_Fees_Settings__c fee : [SELECT Id
												 , Response_Code__c
												 , Description__c
												 , Fees__c
											  FROM Bounce_Fees_Settings__c]) {
			bounceFeeSettings.add(fee);
		}
	}
*/

	public void edit() {
		String formId = ApexPages.currentPage().getParameters().get('formId');

		if (formStateEditMode.containsKey(formId)) {
			formStateEditMode.put(formId, true);
		}
	}


	public void cancel() {
		String formId = ApexPages.currentPage().getParameters().get('formId');

		if (formStateEditMode.containsKey(formId)) {
			formStateEditMode.put(formId, false);

			init();
		}	
	}


	public void saveBankDirectorySettings() {
		if (bankDirectorySettings.Scheduled_Service_Enabled__c) {
			try {
				BankDirectoryService service = new BankDirectoryService();

				String scheduleTime = '0 0 0 ? * 1,2,3,4,5,6,7';
				bankDirectorySettings.Scheduled_Service_Job_Id__c = System.schedule('Bank Directory Import Service', scheduleTime, new BankDirectoryService());
			}
			catch (Exception ex) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
			}
			
		}
		else {
			if (bankDirectorySettings.Scheduled_Service_Job_Id__c != null) {
				try {
					System.abortJob(bankDirectorySettings.Scheduled_Service_Job_Id__c);
				}
				catch (Exception e) {}
			}
			bankDirectorySettings.Scheduled_Service_Job_Id__c = null;
		}

		upsert bankDirectorySettings;
		cancel();		
	}


	public SelectOption[] getAccountRecordTypes() {
		SelectOption[] options = new SelectOption[]{ new SelectOption('', '--None--') };

		for (RecordType rt : [select Name from RecordType 
							   where SObjectType = 'Account' 
							     and IsActive = true order by Name]) {

			options.add(new SelectOption(rt.Id, rt.Name));
		}

		return options;
	}


	public String getBankDirectorySettingsAccountRecordTypeName() {
		if (bankDirectorySettings.Account_Record_Type_Id__c != null) {
			for (RecordType rt : [select Name from RecordType 
								   where SObjectType = 'Account' 
								   	 and Id = :bankDirectorySettings.Account_Record_Type_Id__c
								     and IsActive = true order by Name]) {

				return rt.Name;
			}
		}
		return '';
	}


	public PageReference saveApplicationOptions() {

		upsert portalSettings;
		cancel();

		return null;
	}	


	/*public void saveACHIntegrationSettings() {
		String scheduleTime = '0 0 * ? * *';

		if (achPublicSettings.Scheduled_Create_Trans_Service_Enabled__c) {
			try {
				achPublicSettings.Scheduled_Create_Trans_Service_Job_ID__c = System.schedule('Create Transactions Service', scheduleTime, new ACHCreateTransactionBatchSchedule());
			}
			catch (Exception ex) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
			}
		}
		else {
			try {
				System.abortJob(achPublicSettings.Scheduled_Create_Trans_Service_Job_ID__c);
			}
			catch (Exception e) {}
			achPublicSettings.Scheduled_Create_Trans_Service_Job_ID__c = null;
		}

		if (achPublicSettings.Scheduled_Track_Trans_Service_Enabled__c) {
			try {
				achPublicSettings.Scheduled_Track_Trans_Service_Job_ID__c = System.schedule('Track Transactions Service', scheduleTime, new ACHTrackTransactionBatchSchedule());
			}
			catch (Exception ex) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
			}
		}
		else {
			try {
				System.abortJob(achPublicSettings.Scheduled_Track_Trans_Service_Job_ID__c);
			}
			catch (Exception e) {}
			achPublicSettings.Scheduled_Track_Trans_Service_Job_ID__c = null;
		}

		scheduleTime = '0 30 16 ? * *';

		if (achPublicSettings.Schedul_Send_Transaction_Service_Enabled__c) {
			try {
				achPublicSettings.Scheduled_Send_Trans_Service_Job_ID__c = System.schedule('Send Transactions Service', scheduleTime, new ACHSendTransactionBatchSchedule());
			}
			catch (Exception ex) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
			}
		}
		else {
			try {
				System.abortJob(achPublicSettings.Scheduled_Send_Trans_Service_Job_ID__c);
			}
			catch (Exception e) {}
			achPublicSettings.Scheduled_Send_Trans_Service_Job_ID__c = null;
		}

		upsert achPublicSettings;
		cancel();		
	}


    public void saveCredentials() {
    	try {
    		achWorksCredentials.Active__c = true;
    	    upsert achWorksCredentials;
    	} 
    	catch (Exception ex) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
    	}
    	cancel();
    }


    public void addFeesSettingsRow() {
    	bounceFeeSettings.add(new Bounce_Fees_Settings__c());
    }


    public void saveFeesSettings() {
    	upsert bounceFeeSettings;
    	cancel();
    }


    public void deleteFeesSetting() {
    	try {
    		delete [select id from Bounce_Fees_Settings__c where Id = :idDeleteFee];
    		bounceFeeSettings = new Bounce_Fees_Settings__c[]{};
    		queryBounceFeesSettings();
    	}
    	catch (Exception ex) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
    	}
    }*/

	public class FundingoSettingsException extends Exception {}
}