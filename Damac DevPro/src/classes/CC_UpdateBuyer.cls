/**************************************************************************************************
* Name               : CC_UpdateBuyer
* Description        : This is the custom code class for invoking Primary Buyer and Joint Buyer Update webservice          
* Created Date       : 17/04/2017                                                                 
* Created By         : NSI - Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE                                                              
* 1.0         NSI - Kaavya    17/04/2017                                                        
**************************************************************************************************/
global without sharing class CC_UpdateBuyer implements NSIBPM.CustomCodeExecutable {

    
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step) {
        
        String retStr = 'Success';
        List<Id> BookingIds= new List<id>();
        try{
            for(Booking__c Bookings :[select id from Booking__c where Deal_SR__c=: step.NSIBPM__SR__c]){
                BookingIds.add(Bookings.id);
            }
            if(BookingIds.size()>0){
               
               Boolean PU=false;
               Boolean JB=false;
               List<Buyer__c> buyerlist = [select id,Primary_Buyer__c,Status__c,Change_Count__c from Buyer__c where Is_3rd_Party__c=false AND  Booking__c in:BookingIds];
               for(Buyer__c b :buyerlist){
                   if(b.Primary_Buyer__c){
                       if(b.Change_Count__c>0)
                       PU=true;
                   }
                   else if(b.Status__c=='New'||b.Status__c=='Updated'||b.Status__c=='Removed'){
                       JB=true;
                   }
               }
               if(PU)
               system.enqueueJob(new AsyncReceiptWebservice (BookingIds,'Party Update'));
               if(JB)
               system.enqueueJob(new AsyncReceiptWebservice (BookingIds,'Joint Buyer'));
              
            }  
        
         } catch (Exception e) {
            retStr = 'Error :' + e.getMessage() + '';
            Log__c objLog = new Log__c();
            objLog.Description__c ='Ids=='+BookingIds+'-Line No===>'+e.getLineNumber()+'---Message==>'+e.getMessage();
            objLog.Type__c = 'Error for Update Buyer custom code';
            insert objLog;    
        }
        
        return retStr;
    }
    
    

}