/**************************************************************************************************
* Name               : CC_InvokeSPA
* Description        : This is the custom code class for invoking SPA         
* Created Date       : 23/03/2017                                                                 
* Created By         : NSI - Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE                                                              
* 1.0         NSI - Kaavya    23/03/2017                                                        
**************************************************************************************************/
global without sharing class CC_InvokeSPA implements NSIBPM.CustomCodeExecutable {

    
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step) {
        
        String retStr = 'Success';
        List<Id> BookingIds= new List<id>();
        try{
            for(Booking_Unit__c BU :[select id,Booking__r.Deal_SR__c from Booking_Unit__c where Status__c!='Removed' and Booking__r.Deal_SR__c=: step.NSIBPM__SR__c]){
                List<Id> BUIds= new List<id>();
                BUIds.add(BU.id);
                system.enqueueJob(new AsyncReceiptWebservice (BUIds,'SPA'));
            }
            //if(BookingIds.size()>0)
              //system.enqueueJob(new AsyncReceiptWebservice (BookingIds,'SPA'));
        
         } catch (Exception e) {
            retStr = 'Error :' + e.getMessage() + '';
        }
        
        return retStr;
    }
    
    

}