public with sharing class CaseService {
	
	public static final String CASE_TEMP_SIGN_RECTYPE = 'Temporary Signs';
	public static final String CASE_BIZ_HR_ERROR = 'You need to give us at least 5 business days to process this request';
	/** 
	 * Performs an update operation on the list of cases
	 * @param List<Case>
	 * return 
	 */	
	public static void updateCases(List<Case> casesToUpdate) {
		update casesToUpdate;
	}

	
	/** 
	 * Sets the Attachment Uploaded flag to true for each case record
	 * @param Set<Id> caseIds
	 * return List<Case>
	 */	
	public static List<Case> prepareCasestoUpdate(Set<Id> caseIds){
		List<Case> casesToUpdate = new List<Case>();
		for(Id caseId : caseIds){
			Case c = new Case(Id = caseId, Attachment_Uploaded__c = true);
			casesToUpdate.add(c);
		}
		return casesToUpdate;
	}


	public static void validateBusinessHours(List<Case> caseList){
		
		BusinessHours bizHrs = [SELECT Id FROM BusinessHours WHERE isDefault = true];

		for(Case c : caseList){
			//Validate only for temp signs
			if(caseRecTypeMap.get(c.RecordTypeId).getName() == CASE_TEMP_SIGN_RECTYPE && c.Event_Start__c != null){
				//If Event_Start__c - Date.today() < 5 Business Days --> Throw an error	
				Long diffHrs = BusinessHours.diff(bizHrs.Id, Date.today().addDays(1), c.Event_Start__c);
				diffHrs = diffHrs/(1*60*60*1000);
				if(diffHrs < 40){
					c.addError(CASE_BIZ_HR_ERROR);
				}
			}
		}
	}

	//Map of Case Record Type Ids and Case Rec Type
	public static Map<ID, Schema.RecordTypeInfo> caseRecTypeMap{
		get{
			if(caseRecTypeMap == null){
				caseRecTypeMap = Schema.SObjectType.Case.getRecordTypeInfosById();
			}
			return caseRecTypeMap;
		}
		private set;
	} 

}