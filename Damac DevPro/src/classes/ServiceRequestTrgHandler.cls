/**************************************************************************************************
* Name               : ServiceRequestTrgHandler                                                   *
* Description        : This is a hander class for service request records.                        *
* Created Date       : 04/01/2017                                                                 *
* Created By         : NSI - Ravi                                                                 *
* Last Modified Date :                                                                            *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            Update Log                                        *
* 1.0         NSI - Ravi        04/01/2017                                                        *
* 1.1         NSI - Vineet      18/01/2017      Added logic to share service request records,     *
*                                               to PC's and his managers.                         *
* 1.2         NSI - Kaavya      27/03/2017      Update Deal ID 
**************************************************************************************************/
public class ServiceRequestTrgHandler extends UtilitySharingManager implements TriggerFactoryInterface{ 
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before insert.                       *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){
        /* Calling method to update emails to copy field. */
        populateValues((List<NSIBPM__Service_Request__c>) newRecordsList); 
        getCtryofSalesAdded((List<NSIBPM__Service_Request__c>) newRecordsList);
        checkifPCexistsonDEALSR((List<NSIBPM__Service_Request__c>) newRecordsList);
    }
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before update.                       *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
        List<NSIBPM__Service_Request__c> modifiedSrList = new List<NSIBPM__Service_Request__c>();
        List<NSIBPM__Service_Request__c> modifiedSrCtryofSaleList = new List<NSIBPM__Service_Request__c>();
        List<NSIBPM__Service_Request__c> modifiedselectUser = new List<NSIBPM__Service_Request__c>();
        /* Calling the Deal ID update method */
        updateDealId(newRecordsMap.values());
        for(Id thisKey : newRecordsMap.keySet()){
            NSIBPM__Service_Request__c newRecord = (NSIBPM__Service_Request__c)newRecordsMap.get(thisKey);
            NSIBPM__Service_Request__c oldRecord = (NSIBPM__Service_Request__c)oldRecordsMap.get(thisKey);
            if(newRecord != null && oldRecord != null &&
               ((newRecord.Agency_Email_2__c  != oldRecord.Agency_Email_2__c) ||
                (newRecord.Alternate_Agency_Email_2__c != oldRecord.Alternate_Agency_Email_2__c))){
                modifiedSrList.add(newRecord);  
            }
            if(newRecord != null && oldRecord != null && oldRecord.Country_of_Sale__c != null && newRecord.Country_of_Sale__c != oldRecord.Country_of_Sale__c){
                modifiedSrCtryofSaleList.add(newRecord);
            }
            if(newRecord != null && oldRecord != null && newRecord.Select_User_1__c != oldRecord.Select_User_1__c){
                modifiedselectUser.add(newRecord);
            }
        }
        if(!modifiedSrList.isEmpty()){
            /* Calling method to update emails to copy field. */
            populateValues(modifiedSrList);     
        }
        
        if(!modifiedSrCtryofSaleList.isEmpty()){
            getCtryofSalesAdded(modifiedSrCtryofSaleList);
        }
        if(!modifiedselectUser.isEmpty()){
            checkifPCexistsonDEALSR(modifiedselectUser);
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after insert or update.              *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> MapNewRecords, Map<Id, sObject> MapOldRecords){
        updateCampaign(MapNewRecords.values(), (Map<Id,NSIBPM__Service_Request__c>) MapOldRecords);
    }
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after insert.                        *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){ 
        /*try{
            /*Calling method to update inquiry status when a activity is created. 
            //provideAccess((Map<Id, NSIBPM__Service_Request__c>) newRecordsMap); 
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }*/
    }   
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after update.                        *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
        set<string> Set_DP_OK_SRID = new set<string>();
        try{
            /*Calling UpdateCustomerStatus to Update the Buyer Account Status as Active if DP OK is marked as True. */
           for(sObject objSR : newRecordsMap.values()){
               if(objSR.get('DP_ok__c')==true && oldRecordsMap.get(objSR.Id).get('DP_ok__c')!=objSR.get('DP_ok__c'))
                   Set_DP_OK_SRID.add(objSR.get('Id')+'');
           }
           if(Set_DP_OK_SRID!=null && Set_DP_OK_SRID.size()>0)
               DamacUtility.UpdateCustomerStatus(Set_DP_OK_SRID);
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }   
    }  
    
    /*********************************************************************************************
    * @Description : Method to contain update campaign details with booking count.               *
    * @Params      : List<NSIBPM__Service_Request__c>, Map<Id,NSIBPM__Service_Request__c>        * 
    * @Return      : void                                                                        *
    *********************************************************************************************/
    private void updateCampaign(List<NSIBPM__Service_Request__c> lstSRs, Map<Id,NSIBPM__Service_Request__c> MapOldSRs){
        List<Id> lstCamIds = new List<Id>();
        List<Campaign__c> lstCampaignUpdate = new List<Campaign__c>();
        Map<Id,decimal[]> MapCampaignInfo = new Map<Id,decimal[]>(); 
        try{
            for(NSIBPM__Service_Request__c objSR : lstSRs){
                if(String.isNotBlank(objSR.NSIBPM__Record_Type_Name__c) && 
                   objSR.NSIBPM__Record_Type_Name__c.equalsIgnoreCase('Booking')){
                    if(MapOldSRs != null){ // MapOldSRs is null means it's an insert call
                        if(objSR.Campaign__c != null && MapOldSRs.containsKey(objSR.Id) && 
                           MapOldSRs.get(objSR.Id).Booking_Status__c != objSR.Booking_Status__c )
                            lstCamIds.add(objSR.Campaign__c);
                    }else{ // for insert
                        if(objSR.Campaign__c != null){
                            lstCamIds.add(objSR.Campaign__c);
                        }
                    }
                }
            }
            
            if(!lstCamIds.isEmpty()){
                decimal[] dCamInfo = new decimal[]{0,0,0,0};
                for(NSIBPM__Service_Request__c objBooking : [SELECT Id, Name, Campaign__c, Booking_Status__c, Amount__c 
                                                             FROM NSIBPM__Service_Request__c 
                                                             WHERE Campaign__c != null AND 
                                                                   Campaign__c IN : lstCamIds AND 
                                                                   NSIBPM__Record_Type_Name__c = 'Booking']){
                    if(objBooking.Campaign__c != null){
                        dCamInfo = MapCampaignInfo.containsKey(objBooking.Campaign__c) ? MapCampaignInfo.get(objBooking.Campaign__c) : new decimal[]{0,0,0,0};
                        if(String.isNotBlank(objBooking.Booking_Status__c) && 
                           !objBooking.Booking_Status__c.equalsIgnoreCase('Closed Won') && 
                           !objBooking.Booking_Status__c.equalsIgnoreCase('Closed Lost')){
                            dCamInfo[0] += 1; // Total # of Open Bookings
                        }else if(String.isNotBlank(objBooking.Booking_Status__c) && 
                                 objBooking.Booking_Status__c.equalsIgnoreCase('Closed Won')){
                            dCamInfo[1] += 1; // Total # of Closed Won Bookings
                            dCamInfo[3] += (objBooking.Amount__c != null ? objBooking.Amount__c : 0); // Total Revenue FROM current Campaign 
                        }else if(String.isNotBlank(objBooking.Booking_Status__c) && 
                                 objBooking.Booking_Status__c.equalsIgnoreCase('Closed Lost')){
                            dCamInfo[2] += 1; // Total # of Closed Lost Bookings
                        }
                        MapCampaignInfo.put(objBooking.Campaign__c, dCamInfo);
                    }
                    
                }
                if(!MapCampaignInfo.isEmpty()){
                    Campaign__c objCam;
                    for(Id CampaignId : MapCampaignInfo.keySet()){
                        objCam = new Campaign__c(Id=CampaignId);
                        objCam.No_of_Open_Bookings__c = MapCampaignInfo.get(CampaignId)[0];
                        objCam.Number_of_Closed_Won_Bookings__c = MapCampaignInfo.get(CampaignId)[1];
                        objCam.Number_of_Closed_Lost_Booking__c = MapCampaignInfo.get(CampaignId)[2];
                        objCam.Campaign_Revenue__c = MapCampaignInfo.get(CampaignId)[3];
                        lstCampaignUpdate.add(objCam);
                    }
                    if(!lstCampaignUpdate.isEmpty()){
                        update lstCampaignUpdate;
                    }
                }
            }
        }catch(Exception ex){
            system.debug('Exception is : '+ex.getMessage());
            throw new CustomException(ex.getMessage());
        }
    } 
    
    /*********************************************************************************************
    * @Description : Method to provide access to the PC and PC's Manager.                        *
    * @Params      : Map<Id, NSIBPM__Service_Request__c>                                         *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    @TestVisible  private void provideAccess(Map<Id, NSIBPM__Service_Request__c> newRecordsMap){
        List<SObject> shareRecordsList = new List<SObject>();
        Map<Id, List<NSIBPM__Service_Request__c>> ownerBookingMap = new Map<Id, List<NSIBPM__Service_Request__c>>();  
        for(NSIBPM__Service_Request__c thisBooking : newRecordsMap.values()){
            if(thisBooking.OwnerId != null){
                if(ownerBookingMap.containsKey(thisBooking.OwnerId)){
                    ownerBookingMap.get(thisBooking.OwnerId).add(thisBooking);      
                }else{
                    ownerBookingMap.put(thisBooking.OwnerId, new List<NSIBPM__Service_Request__c>{thisBooking});        
                }
            }
        }   
        if(!ownerBookingMap.isEmpty()){
            /* Calling query utility class for getting the manager details. */
            Map<Id, User> userManagerMap = UtilityQueryManager.getUserManagerDetails(ownerBookingMap.keySet());
            for(NSIBPM__Service_Request__c thisBooking : newRecordsMap.values()){
                User userAgentRecord = userManagerMap.get(thisBooking.OwnerId);
                if(userAgentRecord.Id != null){ 
                    /* Calling sharing utility class to grant access to user hierarchy. */
                    shareRecordsList.addAll(invokeAccess(userAgentRecord, thisBooking.Id.getSobjectType().getDescribe().getName(), thisBooking.Id, ''));
                }
            }
            if(!shareRecordsList.isEmpty()){
                /* Calling queable method to insert sharing records in the sharing table. */
                //Commented to prevent the "too many queuable jobs error"
                //system.enqueueJob(new UtilitySharingManager(shareRecordsList, new List<sObject>()));
            }   
        }
    } 
    
    /*********************************************************************************************
    * @Description : Method to revoke access after the PC is removed from the booking .          *
    * @Params      : Map<Id, NSIBPM__Service_Request__c>                                         *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    @TestVisible private void revokeAccess(Map<Id, NSIBPM__Service_Request__c> newRecordsMap, Map<Id, NSIBPM__Service_Request__c> oldRecordsMap){
        Set<Id> newOwnerIdsSet = new Set<Id>();
        Set<Id> oldOwnerIdsSet = new Set<Id>();
        Set<Id> allOwnerIdsSet = new Set<Id>();
        List<NSIBPM__Service_Request__Share> deleteSharingRecordList = new List<NSIBPM__Service_Request__Share>();
        Map<Id, NSIBPM__Service_Request__c> ownerUpdatedBooking = new Map<Id, NSIBPM__Service_Request__c>();
        for(String thisKey : newRecordsMap.keySet()){
            NSIBPM__Service_Request__c newSrRecord = newRecordsMap.get(thisKey);        
            NSIBPM__Service_Request__c oldSrRecord = oldRecordsMap.get(thisKey);    
            if(newSrRecord != null && oldSrRecord != null &&
               newSrRecord.OwnerId != oldSrRecord.OwnerId){
                newOwnerIdsSet.add(newSrRecord.OwnerId);
                oldOwnerIdsSet.add(oldSrRecord.OwnerId);    
                ownerUpdatedBooking.put(oldSrRecord.OwnerId, oldSrRecord);  
            }
        }
        
        /* Calling method to get records from campaign sharing table. */
        Map<Id, List<NSIBPM__Service_Request__Share>> bookingShareRecordsMap = getSharingRecords(newRecordsMap.keySet());   
        allOwnerIdsSet.addAll(oldOwnerIdsSet);
        allOwnerIdsSet.addAll(newOwnerIdsSet);      
        if(!allOwnerIdsSet.isEmpty()){
            /* Calling query utility class for getting the manager details. */
            Map<Id, User> userManagerMap = UtilityQueryManager.getUserManagerDetails(allOwnerIdsSet);
            if(!bookingShareRecordsMap.isEmpty() && !userManagerMap.isEmpty()){
                for(NSIBPM__Service_Request__c thisBooking : ownerUpdatedBooking.values()){
                    if(bookingShareRecordsMap.containsKey(thisBooking.Id)){
                        User userAgentRecord = userManagerMap.get(thisBooking.OwnerId);
                        if(userAgentRecord != null){
                            for(NSIBPM__Service_Request__Share thisShareRecord : bookingShareRecordsMap.get(thisBooking.Id)){
                                if((userAgentRecord.Id == thisShareRecord.UserOrGroupId) ||
                                   (userAgentRecord.ManagerId != null && userAgentRecord.ManagerId == thisShareRecord.UserOrGroupId) ||
                                   (userAgentRecord.Manager.ManagerId != null && userAgentRecord.Manager.ManagerId == thisShareRecord.UserOrGroupId) ||
                                   (userAgentRecord.Manager.Manager.ManagerId != null && userAgentRecord.Manager.Manager.ManagerId == thisShareRecord.UserOrGroupId) ||
                                   (userAgentRecord.Manager.Manager.Manager.ManagerId != null && userAgentRecord.Manager.Manager.Manager.ManagerId == thisShareRecord.UserOrGroupId)){
                                    deleteSharingRecordList.add(thisShareRecord);   
                                }
                            }
                        }
                    }
                }
                if(!deleteSharingRecordList.isEmpty()){
                    database.deleteResult[] result = database.delete(deleteSharingRecordList, false);
                }
            }   
        }
        /* Calling method to grant access to the new owners. */
        //provideAccess(newRecordsMap);
        
    }
    
    /*********************************************************************************************
    * @Description : Method to get sharing records from the campaign sharing table.              *
    * @Params      : Set<Id>                                                                     *
    * @Return      : Map<Id, List<NSIBPM__Service_Request__Share>>                               *
    *********************************************************************************************/  
    private Map<Id, List<NSIBPM__Service_Request__Share>> getSharingRecords(Set<Id> recordIdsSet){ 
        Map<Id, List<NSIBPM__Service_Request__Share>> bookingShareRecordsMap = new Map<Id, List<NSIBPM__Service_Request__Share>>();
        for(NSIBPM__Service_Request__Share thisShareRecord : [SELECT Id, ParentId, AccessLevel, UserOrGroupId, RowCause 
                                                              FROM NSIBPM__Service_Request__Share 
                                                              WHERE ParentId IN: recordIdsSet]){
            if(bookingShareRecordsMap.containsKey(thisShareRecord.ParentId)){
                bookingShareRecordsMap.get(thisShareRecord.ParentId).add(thisShareRecord);      
            }else{
                bookingShareRecordsMap.put(thisShareRecord.ParentId, new List<NSIBPM__Service_Request__Share>{thisShareRecord});
            }   
        }   
        system.debug('#### bookingShareRecordsMap = '+bookingShareRecordsMap);
        return bookingShareRecordsMap; 
    }
    
    /*********************************************************************************************
    * @Description : Method to ppopulate the email fields.                                       * 
    * @Params      : List<NSIBPM__Service_Request__c>                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    private void populateValues(List<NSIBPM__Service_Request__c> serviceRequestList){
        for(NSIBPM__Service_Request__c thisSr : serviceRequestList){
            if(thisSr.Agency_Email_2__c != null){
                thisSr.Agency_Email__c = thisSr.Agency_Email_2__c;  
            }
            if(thisSr.Alternate_Agency_Email_2__c != null){
                thisSr.Alternate_Agency_Email__c = thisSr.Alternate_Agency_Email_2__c;
            }
        }   
    }
    
    /*
     * Check if PC belongs selected on SR belongs to Parent Deal Team
    */ 
    public void checkifPCexistsonDEALSR(List<NSIBPM__Service_Request__c> lstsr){
        list<id> lstDealSRIds = new list<id>();
        for(NSIBPM__Service_Request__c sr : lstsr){
            if(sr.NSIBPM__Parent_SR__c != null){
                lstDealSRIds.add(sr.NSIBPM__Parent_SR__c);
            }
        }
        //Map of Deal Id, Map of Deal Team PC id
        Map<Id,Map<Id,integer>> mpDealIDmpDTPCId = new Map<Id,Map<Id,integer>>();
        if(lstDealSRIds != null && !lstDealSRIds.isempty()){
            for(Deal_Team__c dt : [select id,name,Associated_PC__c,Associated_Deal__c from Deal_Team__c where Associated_Deal__c  in : lstDealSRIds]){
                if(mpDealIDmpDTPCId.containsKey(dt.Associated_Deal__c)){
                    Map<Id,integer> tmp = mpDealIDmpDTPCId.get(dt.Associated_Deal__c);
                    tmp.put(dt.Associated_PC__c,1);
                    mpDealIDmpDTPCId.put(dt.Associated_Deal__c,tmp);
                }
                else{
                    Map<Id,integer> tmp = new Map<Id,integer>();
                    tmp.put(dt.Associated_PC__c,1);
                    mpDealIDmpDTPCId.put(dt.Associated_Deal__c,tmp);
                }
            }
        }
        
        for(NSIBPM__Service_Request__c sr : lstsr){
            if(sr.NSIBPM__Parent_SR__c != null && sr.Select_User_1__c != null){
                if(mpDealIDmpDTPCId.containskey(sr.NSIBPM__Parent_SR__c) && mpDealIDmpDTPCId.get(sr.NSIBPM__Parent_SR__c) != null && !mpDealIDmpDTPCId.get(sr.NSIBPM__Parent_SR__c).isempty()){
                    if(!mpDealIDmpDTPCId.get(sr.NSIBPM__Parent_SR__c).containskey(sr.Select_User_1__c)){
                        sr.adderror('PC selected doesn\'t belong to the deal team');
                    }
                }
            }
        }
    }
    
    /*
     * Update country of sale added on to Account
    */ 
    public void getCtryofSalesAdded(List<NSIBPM__Service_Request__c> lstsr){
        Map<Id,string> mpSRidCtryofSale = new Map<Id,string>();
        set<Id> acctIds = new set<Id>();
        for(NSIBPM__Service_Request__c sr : lstsr){
            if(sr.NSIBPM__Customer__c != null)
                acctIds.add(sr.NSIBPM__Customer__c);
        }
        List<Agent_Site__c> lstAgentSites = [select id,name,Start_Date__c,Active__c,Agency__c,End_Date__c,Reinstated_Date__c from Agent_Site__c where Agency__c in : acctIds];
        Map<id,Map<string,Agent_Site__c>> mpAgentSites = new Map<Id,Map<String,Agent_Site__c>>();
        if(lstAgentSites != null && !lstAgentSites.isempty()){
            for(Agent_Site__c objas : lstAgentSites){
                if(mpAgentSites.containskey(objas.Agency__c)){
                    Map<string,Agent_Site__c> tmp = mpAgentSites.get(objas.Agency__c);
                    tmp.put(objas.name,objas);
                    mpAgentSites.put(objas.Agency__c,tmp);
                }
                else{
                    Map<string,Agent_Site__c> tmp = new Map<string,Agent_Site__c>();
                    tmp.put(objas.name,objas);
                    mpAgentSites.put(objas.Agency__c,tmp);
                }
            }
            
            for(NSIBPM__Service_Request__c sr : lstsr){
                String retStr = '';
                if(sr.NSIBPM__Customer__c != null && sr.Country_of_Sale__c != null){
                    for(string strSite : sr.Country_of_Sale__c.split(';')){
                        if(mpAgentSites.containskey(sr.NSIBPM__Customer__c) && mpAgentSites.get(sr.NSIBPM__Customer__c) != null && mpAgentSites.get(sr.NSIBPM__Customer__c).size() > 0 && !mpAgentSites.get(sr.NSIBPM__Customer__c).containskey(strSite)){
                            retStr = retStr+strSite+',';
                        }
                    }
                    //mpSRidCtryofSale.put(sr.id,retstr);
                    sr.New_Country_of_Sale__c = retstr;
                }
            }
        }
        //return mpSRidCtryofSale;
    }
    
    /*********************************************************************************************
    * @Description : Method to update DEAL ID .                                                  * 
    * @Params      : List<NSIBPM__Service_Request__c>                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    private void updateDealId(List<NSIBPM__Service_Request__c> serviceRequestList){
        Id dealRecordTypeID = DamacUtility.getRecordTypeId('NSIBPM__Service_Request__c', 'Deal');
        for(NSIBPM__Service_Request__c thisSR : serviceRequestList){
            if(thisSR.name != null && thisSR.Deal_ID__c == null && thisSR.recordTypeId == dealRecordTypeID){
                thisSR.Deal_ID__c = string.valueof(integer.valueof(thisSR.name.remove('SR-')));  
            }
        }   
    }
    
    // TOBE Implemented
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, Map<Id,sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
}// End of class.