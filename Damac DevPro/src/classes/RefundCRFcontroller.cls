public class RefundCRFcontroller {
    public Case objCase {get;set;}
    public List<SR_Booking_Unit__c> lstSRbookingUnit {get;set;}    
     
     public RefundCRFcontroller(ApexPages.StandardController stdController) {
        this.objCase = (Case)stdController.getRecord();
        objCase = [Select id,caseNumber,Account.Name,RecordType.name,Refund_Amount__c
                  from Case where id=:objCase.id];
        lstSRbookingUnit = [Select id,name,booking_Unit__r.Unit_Details__c from SR_Booking_Unit__c
                            where Case__c =: objCase.id];
        
    }
    
}