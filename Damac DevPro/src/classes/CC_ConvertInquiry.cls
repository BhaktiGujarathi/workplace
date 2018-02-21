/**************************************************************************************************
* Name               : CC_ConvertInquiry
* Description        : This is the custom code class for converting the inquiries associated with buyers          
* Created Date       : 30/04/2017                                                                 
* Created By         : NSI - Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE                                                              
* 1.0         NSI - Kaavya    30/04/2017                                                        
**************************************************************************************************/
global without sharing class CC_ConvertInquiry implements NSIBPM.CustomCodeExecutable {

    
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step) {
        system.debug('CC==== convertinquiry');
        String retStr = 'Success';
        Set<Id> inquiryIdsSet= new Set<Id>();
        try{ 
          for(Buyer__c b:[select id,Inquiry__c from Buyer__c where Inquiry__c!=null AND Booking__r.Deal_SR__c=:step.NSIBPM__SR__c]){
            inquiryIdsSet.add(b.Inquiry__c);
          } 
          system.debug('II==== '+inquiryIdsSet);
          if(!inquiryIdsSet.isEmpty()){
               InquiryConversionProcess.convertInquiry(inquiryIdsSet);
            }         
        
         }catch (Exception e) {
            retStr = 'Error :' + e.getMessage() + '';
            Log__c objLog = new Log__c(Type__c = 'Error converting Inquiry',Description__c ='Ids=='+step.NSIBPM__SR__c+'-Line No===>'+e.getLineNumber()+'---Message==>'+e.getMessage() );
            insert objLog;
         }
        
        return retStr;
    }
    
    

}