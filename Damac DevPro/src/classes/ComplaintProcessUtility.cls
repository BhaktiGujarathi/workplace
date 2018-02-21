public with sharing class ComplaintProcessUtility {
	public static final String COMPLAINT_CASE_TYPE = 'Complaints SR';
	public static final String COMPLAINT_RECTYPE_NAME = 'Complaint';
	public static final String COMPLAINT_INITIAL_STATUS = 'Draft Request';
	public static final String COMPLAINT_SUBMIT_STATUS = 'Submitted';
	public static String COMPLAINT_CRF_NAME = 'Customer Signed CRF Form '+ System.today();
	public static String COMPLAINT_ATT1_NAME = 'Customer Attachment 1 '+ System.today();
	public static String COMPLAINT_ATT2_NAME = 'Customer Attachment 2 '+ System.today();

	public static String getRecordTypeId(){
		return Schema.SObjectType.Case.getRecordTypeInfosByName().get(COMPLAINT_RECTYPE_NAME).getRecordTypeId();
	}
}