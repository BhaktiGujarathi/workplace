/**************************************************************************************************
* Name               : CC_SendDoctoIPMS
* Description        : This is the custom code class for sending the documents details to IPMS         
* Created Date       : 30/04/2017                                                                 
* Created By         : NSI - Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE                                                              
* 1.0         NSI - Kaavya    30/04/2017                                                        
**************************************************************************************************/
global without sharing class CC_SendDoctoIPMS implements NSIBPM.CustomCodeExecutable {

    
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step) {
        
        String retStr = 'Success';
        List<Id> SRIds= new List<id>();
        try{  
            SRIds.add(step.NSIBPM__SR__c);          
            system.enqueueJob(new AsyncReceiptWebservice (SRIds,'SendDoc'));           
        
         }catch (Exception e) {
            retStr = 'Error :' + e.getMessage() + '';
         }
        
        return retStr;
    }
    
    

}