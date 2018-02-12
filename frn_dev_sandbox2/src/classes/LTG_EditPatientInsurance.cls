public with sharing class LTG_EditPatientInsurance {

    Boolean isLockedFlag ;
    Id pRecordId;
    public Patient_Insurance__c objPatientInsurance {get;set;}

    public LTG_EditPatientInsurance (ApexPages.StandardController controller) {
        pRecordId = ApexPages.CurrentPage().getparameters().get('id');
        isLockedFlag = RecordLockUtility.checkIsLocked(pRecordId);
        objPatientInsurance = [SELECT VOB_Assigned__c,Name
                               FROM Patient_Insurance__c
                               WHERE id =: pRecordId
                               LIMIT 1];
    }

    public PageReference editPatientInsuranceMethod() {

        if(!isLockedFlag) {
            if (objPatientInsurance.VOB_Assigned__c !=  NULL) {
                PageReference pageRef;
                pageRef= new PageReference('/apex/EditPatientInsPage?id='+objPatientInsurance.Id);
                return pageRef;
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            return null;
        }
        return null;
    }
    public PageReference vobEuqalsNullMethod() {
        if(!isLockedFlag) {

            if(objPatientInsurance.VOB_Assigned__c ==  NULL) {
                PageReference pageRef1;
                pageRef1= new PageReference('/apex/EditPatientInsPage?id='+objPatientInsurance.Id);
                return pageRef1;
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            return null;
        }
        return null;
    }
}