/**
* Class VobAssignToMe
*
* Class VobAssignToMe for the VobAssignToMe VF page. This class implements the functionality
* to VobAssignToMe of Patient Insurance.
*/
global class VobAssignToMe
{
    public Patient_Insurance__c newPatientInsurance;
    public VobAssignToMe(ApexPages.StandardController controller) {
        this.newPatientInsurance= (Patient_Insurance__c)controller.getRecord();
    }
    
    @RemoteAction
    global static Boolean Click_Button(Id patientInsuranceId){
        
        return true;
    }
    
    public VobAssignToMe() {
    }
    
    public PageReference RedirectToRecord() {
        PageReference pageRef;
        pageRef= new PageReference('/'+newPatientInsurance.id);          
        system.debug('pageRef'+pageRef);           
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference VobAssignToMeMethod() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newPatientInsurance =  [select id,name,VOB_Assigned__c from Patient_Insurance__c where id =: currentPIId];
        System.debug('newPatientInsurance '+newPatientInsurance);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newPatientInsurance.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {
            list<Patient_Insurance__c> lstPatientInsuranceRecords= new list<Patient_Insurance__c>();
            lstPatientInsuranceRecords = [Select Id,VOB_status__c,VOB_Assigned__c From Patient_Insurance__c Where id=: newPatientInsurance.Id limit 1];
            
            list<Patient_Insurance__c> lstPatientInsuranceRecordsToUpdate = new list<Patient_Insurance__c>();
            Patient_Insurance__c objPatientInsurance = new Patient_Insurance__c();
            objPatientInsurance.id = newPatientInsurance.Id;
            objPatientInsurance.VOB_Assigned__c = UserInfo.getUserId();
            lstPatientInsuranceRecordsToUpdate.add(objPatientInsurance);
            Patient_Insurance__c objPatientInsuranceUpdated = new Patient_Insurance__c();         
            try{
                update lstPatientInsuranceRecordsToUpdate;
                system.debug('lstPatientInsuranceRecordsToUpdate'+lstPatientInsuranceRecordsToUpdate);
                
                objPatientInsuranceUpdated = [Select Id,VOB_status__c,VOB_Assigned__c From Patient_Insurance__c Where id=:objPatientInsurance.id];
                system.debug('objPatientInsuranceUpdated-----'+objPatientInsuranceUpdated);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Record is updated.'));
                System.debug('<<<<<<<<<<<<<< Record is updated<<<<<<<<<<<<<<<<'+isLockedFlag);
                
            } catch (Exception e) {
                system.debug('DML failed --- Error'+e);
                return null;
            }
            //return (new ApexPages.StandardController(newPatientInsurance)).view(); 
            return null;        
            
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            System.debug('<<<<<<<<<<<<<< Record is locked <<<<<<<<<<<<<<<<'+isLockedFlag);
            return null;
        }
    }
}