/**************************************************************************************************
* Name               : CampaignVirtualNumberTriggerHandler                                        *
* Description        : This is a trigger handler class for CampaignVirtualNumberTrigger.          *
*                      Has the below function:                                                    *
*                      - Checks if the virtual number is not associated to an active campaign.    *
* Created Date       : 16/01/2017                                                                 *
* Created By         : NSI                                                                        *
* Last Modified Date :                                                                            *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         NSI         16/01/2017 
* 1.0         NSI         06/04/2017                                                              *
**************************************************************************************************/
public class CampaignVirtualNumberTriggerHandler implements TriggerFactoryInterface{
    
    public string Digital_Campaign_Rtype_Id = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Digital').getRecordTypeId();
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before insert.                       *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){
        try{
            /*Calling method to update inquiry status when a activity is created. */
            checkVirtualNumberValidity((List<JO_Campaign_Virtual_Number__c>) newRecordsList);    
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }       
    }
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before update.                       *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
        try{
            /*Calling method to update inquiry status when a activity is created. */
            checkVirtualNumberValidity((List<JO_Campaign_Virtual_Number__c>) mapNewRecords.values());    
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }   
    }
    
    // TOBE Implemented.
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, Map<Id, sObject> mapOldRecords){}
    public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){}
    public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    
    /*********************************************************************************************
    * @Description : Method to validate if the selected virtual number is not associated to      *
    *                any active campaign, for the same marketing start and end date.             *
    * @Params      : List<JO_Campaign_Virtual_Number__c>                                         *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @TestVisible private void checkVirtualNumberValidity(List<JO_Campaign_Virtual_Number__c> newRecordList){
        system.debug(Digital_Campaign_Rtype_Id);
        Map<String, Campaign__c> campaignMap;
        Map<String, List<Campaign__c>> virtualNumberCampaignMap;
        Set<Id> virtualNumberIdSet = new Set<Id>();
        Set<Id> campaignIdSet = new Set<Id>();
        for(JO_Campaign_Virtual_Number__c thisRecord : newRecordList){
            virtualNumberIdSet.add(thisRecord.Related_Virtual_Number__c);   
            campaignIdSet.add(thisRecord.Related_Campaign__c);
            system.debug(virtualNumberIdSet+'>>>'+campaignIdSet);
        }   
        if(!campaignIdSet.isEmpty()){
            /* Calling method to get campaign details map. */
            campaignMap = getCampaignDetails(campaignIdSet);    
        }   
        if(!virtualNumberIdSet.isEmpty()){
            /* Calling method to get map of linked campaigns to a virtual number. */
            virtualNumberCampaignMap = getAssociatedCampaigns(virtualNumberIdSet);
            system.debug(virtualNumberCampaignMap+'>>>>>>>>>>>>>>>');   
        }
        if(campaignMap != null && virtualNumberCampaignMap != null){
            for(JO_Campaign_Virtual_Number__c thisRecord : newRecordList){
                if(campaignMap.containsKey(thisRecord.Related_Campaign__c) ){ //&& campaignMap.get(thisRecord.Related_Campaign__c).Active__c
                    if(virtualNumberCampaignMap.get(thisRecord.Related_Virtual_Number__c) != null && 
                       virtualNumberCampaignMap.get(thisRecord.Related_Virtual_Number__c).size() > 0 ){
                        for(Campaign__c thisCampaign : virtualNumberCampaignMap.get(thisRecord.Related_Virtual_Number__c)){
                            
                            
                            system.debug('Now Addding'+campaignMap.get(thisRecord.Related_Campaign__c).Recordtypeid);                           
                            system.debug('Existing>>>'+thisCampaign.Recordtypeid);
                            
                            system.debug('1>>'+(campaignMap.get(thisRecord.Related_Campaign__c).recordtypeid != thisCampaign.Recordtypeid && thisCampaign.recordtypeid == Digital_Campaign_Rtype_Id) );
                            system.debug('2>>'+(campaignMap.get(thisRecord.Related_Campaign__c).Recordtypeid == Digital_Campaign_Rtype_Id && thisCampaign.recordtypeid != Digital_Campaign_Rtype_Id ));
                            system.debug('3>>'+(campaignMap.get(thisRecord.Related_Campaign__c).Recordtypeid == Digital_Campaign_Rtype_Id && thisCampaign.recordtypeid == Digital_Campaign_Rtype_Id ) );
                            if( (campaignMap.get(thisRecord.Related_Campaign__c).recordtypeid != thisCampaign.Recordtypeid && thisCampaign.recordtypeid == Digital_Campaign_Rtype_Id)  ){
                                system.debug('1 E>>'+thisRecord.Check_Marketing_Dates_Fall_in_VN_Dates__c);
                                if(thisRecord.Check_Marketing_Dates_Fall_in_VN_Dates__c){
                                    system.debug('1 Err>>');    
                                    thisRecord.addError('The virtual number is already associated to <a target="_blank" href="/'+thisCampaign.Id+'" >'+thisCampaign.Campaign_Name__c+'</a> campaign.', false);      
                                }
                            }else if( (campaignMap.get(thisRecord.Related_Campaign__c).Recordtypeid == Digital_Campaign_Rtype_Id && thisCampaign.recordtypeid != Digital_Campaign_Rtype_Id ) ){
                                system.debug('2 E>>'+thisRecord.Check_Marketing_Dates_Fall_in_VN_Dates__c);
                                if((campaignMap.get(thisRecord.Related_Campaign__c).Marketing_Start_Date__c == thisCampaign.Marketing_Start_Date__c && 
                                    campaignMap.get(thisRecord.Related_Campaign__c).Marketing_End_Date__c == thisCampaign.Marketing_End_Date__c) ||
                                   (campaignMap.get(thisRecord.Related_Campaign__c).Marketing_Start_Date__c >= thisCampaign.Marketing_Start_Date__c && 
                                    campaignMap.get(thisRecord.Related_Campaign__c).Marketing_Start_Date__c <= thisCampaign.Marketing_End_Date__c) ||
                                   (campaignMap.get(thisRecord.Related_Campaign__c).Marketing_End_Date__c >= thisCampaign.Marketing_Start_Date__c && 
                                    campaignMap.get(thisRecord.Related_Campaign__c).Marketing_End_Date__c <= thisCampaign.Marketing_End_Date__c)){
                                    system.debug('2 Err>>');
                                    thisRecord.addError('The virtual number is already associated to <a target="_blank" href="/'+thisCampaign.Id+'" >'+thisCampaign.Campaign_Name__c+'</a> campaign.', false);      
                                }                           
                            }else if( (campaignMap.get(thisRecord.Related_Campaign__c).Recordtypeid == Digital_Campaign_Rtype_Id && thisCampaign.recordtypeid == Digital_Campaign_Rtype_Id ) ){
                                if((campaignMap.get(thisRecord.Related_Campaign__c).Marketing_Start_Date__c == thisCampaign.Marketing_Start_Date__c && 
                                    campaignMap.get(thisRecord.Related_Campaign__c).Marketing_End_Date__c == thisCampaign.Marketing_End_Date__c) ||
                                   (campaignMap.get(thisRecord.Related_Campaign__c).Marketing_Start_Date__c >= thisCampaign.Marketing_Start_Date__c && 
                                    campaignMap.get(thisRecord.Related_Campaign__c).Marketing_Start_Date__c <= thisCampaign.Marketing_End_Date__c) ||
                                   (campaignMap.get(thisRecord.Related_Campaign__c).Marketing_End_Date__c >= thisCampaign.Marketing_Start_Date__c && 
                                    campaignMap.get(thisRecord.Related_Campaign__c).Marketing_End_Date__c <= thisCampaign.Marketing_End_Date__c)){
                                    thisRecord.addError('The virtual number is already associated to <a target="_blank" href="/'+thisCampaign.Id+'" >'+thisCampaign.Campaign_Name__c+'</a> campaign.', false);      
                                }   
                            }       
                        }
                    }   
                }//else{
                    //thisRecord.addError('The associated campaign is no longer active.');  
                //} 
            }
        }
    }  
    
    /*********************************************************************************************
    * @Description : Method to get detail map of the assigned campaigns.                         *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<String, Campaign__c>                                                    *
    *********************************************************************************************/
    @TestVisible private Map<String, Campaign__c> getCampaignDetails(Set<Id> campaignIdSet){
        Map<String, Campaign__c> campaignMap = new Map<String, Campaign__c>();
        for(Campaign__c thisRecord : [SELECT Id, Name, Active__c, Marketing_Active__c, Credit_Control_Active__c,
                                             Sales_Admin_Active__c, Marketing_Start_Date__c, Marketing_End_Date__c,recordtypeid
                                     FROM Campaign__c 
                                     WHERE Id IN: campaignIdSet]){
            campaignMap.put(thisRecord.Id, thisRecord);     
        }       
        return campaignMap;
    }
    
    /*********************************************************************************************
    * @Description : Method to get detail map of all the campaigns linked to a virtual number.   *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<String, List<Campaign__c>>                                              *
    *********************************************************************************************/
    @TestVisible private Map<String, List<Campaign__c>> getAssociatedCampaigns(Set<Id> virtualNumberIdSet){
        Map<String, List<Campaign__c>> virtualNumberCampaignMap = new Map<String, List<Campaign__c>>();
        for(Virtual_Number__c thisRecord : [SELECT Id, 
                                                (SELECT Id, Name, Related_Campaign__c, Related_Campaign__r.Active__c,
                                                        Related_Campaign__r.Marketing_Active__c, 
                                                        Related_Campaign__r.Credit_Control_Active__c,
                                                        Related_Campaign__r.Sales_Admin_Active__c, 
                                                        Related_Campaign__r.Marketing_Start_Date__c, 
                                                        Related_Campaign__r.Marketing_End_Date__c,
                                                        Related_Campaign__r.Name,
                                                        Related_Campaign__r.Campaign_Name__c, 
                                                        Related_Campaign__r.Recordtypeid,Check_Marketing_Dates_Fall_in_VN_Dates__c                                                       
                                                 FROM Campaign_Virtual_Numbers__r) 
                                            FROM Virtual_Number__c 
                                            WHERE Id IN: virtualNumberIdSet]){
            for(JO_Campaign_Virtual_Number__c thisChildRecord : thisRecord.Campaign_Virtual_Numbers__r){
                if(virtualNumberCampaignMap.containsKey(thisRecord.Id)){
                    virtualNumberCampaignMap.get(thisRecord.Id).add(
                        new Campaign__c(Id = thisChildRecord.Related_Campaign__c,
                                        Campaign_Name__c = thisChildRecord.Related_Campaign__r.Campaign_Name__c,    
                                        Marketing_Active__c = thisChildRecord.Related_Campaign__r.Marketing_Active__c,
                                        Credit_Control_Active__c = thisChildRecord.Related_Campaign__r.Credit_Control_Active__c,
                                        Sales_Admin_Active__c = thisChildRecord.Related_Campaign__r.Sales_Admin_Active__c,
                                        Marketing_Start_Date__c = thisChildRecord.Related_Campaign__r.Marketing_Start_Date__c,
                                        Marketing_End_Date__c = thisChildRecord.Related_Campaign__r.Marketing_End_Date__c,
                                        Recordtypeid = thisChildRecord.Related_Campaign__r.recordtypeid));  
                }else{
                    virtualNumberCampaignMap.put(thisRecord.Id, 
                        new List<Campaign__c>{
                            new Campaign__c(Id = thisChildRecord.Related_Campaign__c,
                                            Campaign_Name__c = thisChildRecord.Related_Campaign__r.Campaign_Name__c,
                                            Marketing_Active__c = thisChildRecord.Related_Campaign__r.Marketing_Active__c,
                                            Credit_Control_Active__c = thisChildRecord.Related_Campaign__r.Credit_Control_Active__c,
                                            Sales_Admin_Active__c = thisChildRecord.Related_Campaign__r.Sales_Admin_Active__c,
                                            Marketing_Start_Date__c = thisChildRecord.Related_Campaign__r.Marketing_Start_Date__c,
                                            Marketing_End_Date__c = thisChildRecord.Related_Campaign__r.Marketing_End_Date__c,
                                            Recordtypeid = thisChildRecord.Related_Campaign__r.recordtypeid)});
                }   
            }
        }   
        return virtualNumberCampaignMap;
    }
}// End of class.