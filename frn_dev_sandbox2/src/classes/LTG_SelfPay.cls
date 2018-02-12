public with sharing class LTG_SelfPay {

    Boolean isLockedFlag = False ;
    Id pRecordId;

    public LTG_SelfPay(ApexPages.StandardController controller) {
    }

    public PageReference selfPAyMethod() {
        PageReference pageRef;
        pRecordId = ApexPages.CurrentPage().getparameters().get('id');
        isLockedFlag = RecordLockUtility.checkIsLocked(pRecordId);
        if(isLockedFlag == false) {
            pageRef= new PageReference('/apex/PPFrnFacilitySelectionForPAWAutoCreation?id='+pRecordId);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Record is locked.'));
            return null;
        }        
    }
}