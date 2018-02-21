/* Description: Class with method to fetch the latest payment details
 */
public with sharing class CallingListPaymentUtility {
    private Id callListId;
    
    public CallingListPaymentUtility(ApexPages.StandardController controller) {
        callListId = ApexPages.currentPage().getParameters().get('id');
    }
    
    //Method to fetch the latest payment details
    public Pagereference fetchPaymentDetails() {
        if(callListId != null) {
            List<Calling_List__c> lstCallList = [Select Id, Case__c, Call_Outcome__c From Calling_List__c 
                Where Id =: callListId and Case__c != null];
            
            if(lstCallList != null && !lstCallList.isEmpty()) {
                List<SR_Booking_Unit__c> lstSRBU = [Select Id, Booking_Unit__c, Booking_Unit__r.Registration_ID__c, Case__c 
                    From SR_Booking_Unit__c 
                    Where Case__c =: lstCallList[0].Case__c And Booking_Unit__c != null
                    And Booking_Unit__r.Registration_ID__c != null];
                    
                if(lstSRBU != null && !lstSRBU.isEmpty()) {
                    List<String> lstRegId = new List<String>();
                    for(SR_Booking_Unit__c objSRBU: lstSRBU) {
                        lstRegId.add(objSRBU.Booking_Unit__r.Registration_ID__c);
                    }
                    
                    //Callout to IPMS to fetch latest payment details of each booking unit
                    lstCallList[0].Call_Outcome__c = 'Paid';
                    update lstCallList;
                }
            }
        }
        
        return new Pagereference('/'+callListId);
    }
}