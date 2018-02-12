public with sharing class LTG_EditPAW {

    Boolean isLockedFlag = False ;
    Id pRecordId;
    Pay_Agreement_Worksheet__c objPAW = new Pay_Agreement_Worksheet__c();

    public LTG_EditPAW(ApexPages.StandardController controller) {
    }

    public PageReference EditPAWMethod() {
        PageReference pageRef;
        pRecordId = ApexPages.CurrentPage().getparameters().get('id');
        isLockedFlag = RecordLockUtility.checkIsLocked(pRecordId);
        objPAW = [SELECT Opportunity__c,
                         Opportunity__r.StageName,
                         Status__c
                 FROM Pay_Agreement_Worksheet__c
                 WHERE Id =: pRecordId];
        if(isLockedFlag == false) {
            String Status = objPAW.Status__c;
            String redirect = '';
            String stageName = objPAW.Opportunity__r.StageName;
            if( stagename == 'Pending Admission') {
                redirect = 'PendingAdmission';
            }
            else {
                redirect = objPAW.Id;
            }
            Id agreementID1 = objPAW.Id;
            String redirect1 = BenefitsVOBStatus.VOBStageCheck(agreementID1);
            String n = objPAW.Id;
            if(status == 'Open') {
                if(redirect != null) {
                    if(redirect =='PendingAdmission') {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Record is locked and cannot be edited / changed.'));
                    }
                    else if(redirect =='PendingAdmission(AC)') {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Record is locked and cannot be edited / changed.'));
                    }
                    else {
                        pageRef= new PageReference('/apex/PAW_New_Edit?Id='+n);
                        pageRef.setRedirect(true);
                        return pageRef;
                    }
                }
                else if(redirect1 != null) {
                    if(redirect1 =='VOBApproved') {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You cannot modify the Pay Agreement Worksheet with the related Opportunity Status is VOB Approved'));
                    }
                    else {
                        pageRef= new PageReference('/apex/PAW_New_Edit?Id='+n);
                        pageRef.setRedirect(true);
                        return pageRef;
                    }
                }
                else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Opportunity does not exist'));
                }
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This action is not allowed as status is closed/Cancelled.'));
            }
        }
        else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Record is locked.'));
        }
        return null;
    }
}