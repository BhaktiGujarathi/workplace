/**************************************************************************************************
* Name               : CC_UpdateRegnStatus
* Description        : This is the custom code class for invoking Registration Update webservice on status change         
* Created Date       : 06/04/2017                                                                 
* Created By         : NSI - Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE                                                              
* 1.0         NSI - Kaavya    06/04/2017                                                        
**************************************************************************************************/
global without sharing class CC_UpdateRegnStatus implements NSIBPM.CustomCodeExecutable {
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step) {
        String retStr = 'Success';
        List<Id> BookingIds= new List<id>();
        try{
            for(Booking__c Bookings :[select id from Booking__c where Deal_SR__c=: step.NSIBPM__SR__c]){
                BookingIds.add(Bookings.id);
            }
            if(BookingIds.size()>0){
                system.debug('#### invoking CC_UpdateRegnStatus');
                system.enqueueJob(new AsyncReceiptWebservice (BookingIds,'StatusUpdate'));
            }
        
        } catch (Exception e) {
            retStr = 'Error :' + e.getMessage() + '';
        }
        return retStr;
    }
}