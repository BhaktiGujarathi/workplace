public with sharing class LTG_SubmitForApproval {

    public Boolean isLockedFlag = False ;
    public Id pRecordId;
    public Opportunity objOpp = new Opportunity();

    public LTG_SubmitForApproval(ApexPages.StandardController controller) {
    }
    public PageReference submitForApprovalMethod() {
        PageReference pageRef;
        pRecordId = ApexPages.CurrentPage().getparameters().get('id');
        isLockedFlag = RecordLockUtility.checkIsLocked(pRecordId);
        objOpp = [SELECT Id FROm Opportunity WHERE Id =: pRecordId];
        if(isLockedFlag == false) {
            Id oppId = objOpp.Id;
            String caseRecordType = 'Facility Approval';
            pageRef= new PageReference('/apex/FacilityApprovalVfPage?id='+oppId+'&recType='+caseRecordType);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Record is locked.'));
            return null;
        }
         return null;
    }
}