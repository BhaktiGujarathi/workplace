/**************************************************************************************************
* Name               : CC_PromoLetter
* Description        : This is the custom code class for creating Promotion letter document         
* Created Date       : 16/05/2017                                                                 
* Created By         : NSI - Kaavya Raghuram                                                       
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR          DATE                                                              
* 1.0         NSI - Kaavya    16/05/2017                                                        
**************************************************************************************************/
global without sharing class CC_PromoLetter implements NSIBPM.CustomCodeExecutable {

    
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step) {
        
        String retStr = 'Success';
        List<Id> BookingIds= new List<id>();
        Map<String,Id> PromoMap= new Map<String,Id>();
        for(NSIBPM__Document_Master__c DM :[select id,name,NSIBPM__Code__c from NSIBPM__Document_Master__c where Promotion_Letter__c=true]){
            PromoMap.put(DM.name,DM.id);
        }
        List<NSIBPM__SR_Doc__c> SRDocList= new List<NSIBPM__SR_Doc__c>();      
        try{
            for(Booking_Unit__c BU :[select id,Related_Promotion_Title__c,Registration_ID__c,Booking__r.Deal_SR__c from Booking_Unit__c where Status__c!='Removed' and Related_Promotion__c!=null and Booking__r.Deal_SR__c=: step.NSIBPM__SR__c]){
                if(BU.Related_Promotion_Title__c!=null){
                    if(PromoMap.get(BU.Related_Promotion_Title__c)!=null){
                        NSIBPM__SR_Doc__c SRDoc = new NSIBPM__SR_Doc__c();
                        SRDoc.NSIBPM__Service_Request__c=step.NSIBPM__SR__c;
                        SRDoc.Booking_Unit__c=BU.id;
                        SRDoc.NSIBPM__Generate_Document__c=true;            
                        SRDoc.NSIBPM__Document_Master__c=PromoMap.get(BU.Related_Promotion_Title__c);
                        SRDoc.name=BU.Registration_ID__c+'- Promotion Letter';
                        SRDoc.NSIBPM__Status__c='Generated';
                        SRDoc.NSIBPM__Is_Not_Required__c=true;
                        SRDocList.add(SRDoc);
                    }
                    
                }
            }
            insert SRDocList; 
        
         } catch (Exception e) {
            retStr = 'Error :' + e.getMessage() + '';
        }
        
        return retStr;
    }
    
    

}