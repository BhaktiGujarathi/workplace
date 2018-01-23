global with sharing class RecordLockUtility {
    
    // variable declaration
    public String returnToId;
    public static Boolean isLockedFlag;
    
    public RecordLockUtility() {
        isLockedFlag = false;
    }
        
    WebService Static Boolean checkIsLocked(Id pRecordId) {
        return Approval.isLocked(pRecordId);
    }
    
    public Static Boolean verifyIfLocked(Id pRecordId) {
        return Approval.isLocked(pRecordId);
    }
    
    public PageReference returnBack() { 
        returnToId = ApexPages.currentPage().getParameters().get('returnId');

        if(returnToId != null && returnToId != '') {
            return new PageReference('/'+returnToId);
        }
        else {
            return null;
        }
    }
    
    public static PageReference redirectIfLocked(String recordId) {
        isLockedFlag = verifyIfLocked(recordId);

        if(isLockedFlag) {
            return new PageReference('/apex/RecordLockedError?returnId='+recordId);
        }
        else {
            return null;
        }
    }
}