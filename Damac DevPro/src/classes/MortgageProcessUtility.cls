public with sharing class MortgageProcessUtility {
	public static final String MORTGAGE_CASE_TYPE = 'Mortgage';
	public static final String MORTGAGE_RECTYPE_NAME = 'Mortgage';
	public static final String MORTGAGE_INITIAL_STATUS = 'Draft Request';
	public static final String MORTGAGE_SUBMIT_STATUS = 'Submitted';
	public static String MORTGAGE_CRF_NAME = 'Customer Signed CRF Form '+ System.today();
	public static String MORTGAGE_POA_NAME = 'Customer POA Form '+ System.today();

	public static String getRecordTypeId(){
		return Schema.SObjectType.Case.getRecordTypeInfosByName().get(MORTGAGE_RECTYPE_NAME).getRecordTypeId();
	}
}