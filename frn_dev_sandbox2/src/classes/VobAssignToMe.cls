public with sharing class VobAssignToMe {

	Boolean isLockedFlag = False ; // temporary value
	Id pRecordId;
	Patient_Insurance__c objPatientInsurance = new Patient_Insurance__c();

    public VobAssignToMe(ApexPages.StandardController controller) {

    }

	public PageReference VobAssignToMeMethod() {
  		PageReference pageRef;

		pRecordId = ApexPages.CurrentPage().getparameters().get('id');
		isLockedFlag = RecordLockUtility.checkIsLocked(pRecordId);
		if(isLockedFlag == false) {
			Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
			String pname = p.name;
			objPatientInsurance = [SELECT VOB_Assigned__c
								   from Patient_Insurance__c
								   where id =: pRecordId
								   limit 1];
			List<Patient_Insurance__c> lst_PatientInsurance = new List<Patient_Insurance__c>();
			Patient_Insurance__c newPatientInsurance = new Patient_Insurance__c();
			newPatientInsurance.id = pRecordId;
			newPatientInsurance.VOB_Assigned__c = UserInfo.getUserId();
			lst_PatientInsurance.add(newPatientInsurance);

			if(objPatientInsurance.VOB_Assigned__c != null) {
				//if(alert msg)
				try {
					update lst_PatientInsurance;
					System.debug('<<<<<<< lst_PatientInsurance<<<<<'+lst_PatientInsurance);
				}
				catch (Exception e) {
					system.debug('DML failed --- Error'+e);
					return null;
				}
			}
			else {
				try {
					update lst_PatientInsurance;
					System.debug('<<<<<<< lst_PatientInsurance<<<<<'+lst_PatientInsurance);
				}
				catch (Exception e) {
					system.debug('DML failed --- Error'+e);
					return null;
				}
			}
			//pageRef= new PageReference(ApexPages.currentPage().getURL());
			pageRef = ApexPages.currentPage();
  			pageRef.setRedirect(true);
        	return pageRef;
		}
		else {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Record is locked'));
			return null;
		}
	}
}