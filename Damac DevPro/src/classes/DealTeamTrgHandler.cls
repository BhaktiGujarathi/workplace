public class DealTeamTrgHandler implements TriggerFactoryInterface  {
     /*********************************************************************************************
    * @Description : Method to contain logic to be executed before Insert.mapping of the DOS HOS HOD
                     Status,Sales Office Based on the Asscoiated PC - Manager DOS , 
                     Associated PC s DOS and HOS Manager Role and 
                     Associated PCs DOS and HOS and HOD Managers Role                            
    * @Params      : List<sObject>                                                               
    * @Return      : void                                                                        
    *********************************************************************************************/
    // Mapping Accociated DOS,HOS,HOD,Sales Office ,Status.Based on Role names of the managers related to Associated PC
    public void executeBeforeInsertTrigger(list<sObject> mapNewRecords){
        try{
            set<id> associatedPcIds = new set<id>();
            map<id,id> srToShare = new map<id,id>();
            for(sObject thisSObject : mapNewRecords){
                Deal_Team__c thisTeam = (Deal_Team__c )thisSObject;
                associatedPcIds.add(thisTeam.Associated_PC__c);
                if(thisteam.Allow_Sharing_with_PC__c){
                    srToShare.put(thisTeam.Associated_Deal__c,thisTeam.Associated_PC__c);
                }
                system.debug('SR REQ ID'+thisTeam.Associated_Deal__c);
            }
            
            list<user> PCmanagers = [select id,Sales_Office__c,managerId,Manager.managerId,Manager.Manager.ManagerId,Manager_Role__c,Manager.Manager_Role__c,Manager.manager.Manager_Role__c from user where Id IN:associatedPcIds];
            //system.debug(PCManagers[0].managerId);
            //system.debug(PCManagers[0].Manager.managerId);
            //system.debug(PCManagers[0].Manager.Manager.ManagerId);
            
            //Populate Maps
            map<string,string> mapDos = new map<string,string>();
            map<string,string> maphos = new map<string,string>();
            map<string,string> maphod = new map<string,string>();
            map<string,string> salesOffice = new map<string,string>();
            if(PCmanagers!= null && PCmanagers.size() > 0){
                for(user u:PCmanagers){
                    //Check From DOS-->HOS-->HOD
                    if(u.ManagerId != null && string.valueof(u.Manager_Role__c).containsIgnoreCase('DOS')){ // PC s Man Role = DOS
                        system.debug('Man role>>>>>>>>>>>'+u.Manager_Role__c);
                        mapDos.put(u.id,u.Managerid);
                        if(string.valueof(u.Manager.Manager_Role__c).containsIgnoreCase('HOS')){ // PC s Man is DOS so DOS Man = HOS ?
                            mapHos.put(u.id,u.Manager.ManagerId);
                            if(u.Manager.Manager.ManagerId != null && string.valueof(u.Manager.Manager.Manager_Role__c).containsIgnoreCase('HOD')){// PC s Man is DOS so DOS Man is HOS so HOS Man = HOD ?
                                maphod.put(u.id,u.Manager.Manager.ManagerId);
                            }
                        }
                        // DOS and HOD no HOS
                        if(u.Manager.ManagerId != null && string.valueof(u.Manager.Manager_Role__c).containsIgnoreCase('HOD')){// PC s Man is DOS so DOS Man is HOS so HOS Man = HOD ?
                            maphod.put(u.id,u.Manager.ManagerId);
                        }
                        
                    }
                    //Check from HOS-->HOD
                    if(u.Managerid != null && string.valueof(u.Manager_Role__c).containsIgnoreCase('HOS')){ // PC s Man Role = HOS
                        mapHos.put(u.id,u.Managerid);
                        if(u.Manager.ManagerId != null && string.valueof(u.Manager.Manager_Role__c).containsIgnoreCase('HOD')){// PC s Man is DOS so DOS Man is HOS so HOS Man = HOD ?
                            maphod.put(u.id,u.Manager.ManagerId);
                        }
                    }
                    //Check HOD
                    if(u.Managerid != null && string.valueof(u.Manager_Role__c).containsIgnoreCase('HOD')){ // PC s Man Role = HOD
                        maphod.put(u.id,u.ManagerId);
                    }
                    salesOffice.put(u.id,u.Sales_Office__c);            
                }   
                system.debug('mapDos-->'+mapDos);
                system.debug('mapHos-->'+mapHos);
                system.debug('mapHod-->'+mapHOD);
                
                for(sObject thisSObject : mapNewRecords){
                    Deal_Team__c thisTeam = (Deal_Team__c )thisSObject; 
                    thisTeam.Associated_DOS__c = mapDos.get(thisteam.Associated_PC__c);
                    thisTeam.Associated_HOS__c = maphos.get(thisteam.Associated_PC__c); 
                    thisTeam.Associated_HOD__c = maphod.get(thisteam.Associated_PC__c);
                    thisTeam.User_Sales_Office__c = salesOffice.get(thisteam.Associated_PC__c);
                    thisTeam.Status__c = 'Active';                     
                    // Added on May 21 2017 by subhash following Kaavya and Riddhis Instructions
                    // IF PC is not having DOS map DOS as HOS 
                    if( mapDos.get(thisteam.Associated_PC__c) == null && maphos.get(thisteam.Associated_PC__c) != null){
                        thisTeam.Associated_DOS__c = maphos.get(thisteam.Associated_PC__c);
                    }
                    // IF PC is not having DOS,HOS map DOS as HOD 
                    if( mapDos.get(thisteam.Associated_PC__c) == null && maphos.get(thisteam.Associated_PC__c) == null && maphod.get(thisteam.Associated_PC__c) != null){
                        thisTeam.Associated_DOS__c = maphod.get(thisteam.Associated_PC__c);
                    }   
                    // Added on May 22 2017 by subhash following Kaavya and Riddhis Instructions 
                    if( maphod.get(thisteam.Associated_PC__c) == null && maphos.get(thisteam.Associated_PC__c) != null){
                        thisteam.Associated_HOD__c =  maphos.get(thisteam.Associated_PC__c);   
                    }
                                                    
                }
                sharingSRonDealToPC(srToShare);  
            }
        }catch(exception e){
        
        }
    }
    
    
    /*********************************************************************************************
    * @Description : Method to give the Sharing access for the Asscoiated PC on the SR when the 
                     Deal team is Created.          
    
    *********************************************************************************************/
   
    public void sharingSRonDealToPC(map<id,id> MapsrPcIds){
        list<NSIBPM__Service_Request__share> shares = new list<NSIBPM__Service_Request__share>();
        for(id srId:MapsrPcIds.keyset()){
            NSIBPM__Service_Request__share share = new NSIBPM__Service_Request__share();
            share.ParentId = srId;
            share.AccessLevel = 'Edit';
            share.UserOrGroupId = MapsrPcIds.get(srId);
            shares.add(share);
        }    
        insert shares;    
    }
    
    /*********************************************************************************************
    * @Description : Method to Remove the Sharing access for the Asscoiated PC on the SR when the 
                     Deal team status is Inactive           
    
    *********************************************************************************************/  
    
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){ 
        try{
            // Get Inactive Deal Teams
            List<NSIBPM__Service_Request__Share> deleteSharingRecordList = new List<NSIBPM__Service_Request__Share>();
            set<id> inactivePCids = new set<id>();
            set<id> srIds = new set<id>();
            for(sObject thisSobject:newRecordsMap.values()){
                Deal_Team__c thisTeam = (Deal_Team__c)thisSObject;
                if(thisTeam.status__c == 'Inactive'){
                    inactivePCids.add(thisTeam.Associated_PC__c);
                    srIds.add(thisTeam.Associated_deal__c);
                }
            }
            Map<Id, List<NSIBPM__Service_Request__Share>> bookingShareRecordsMap = getSharingRecords(srIds,inactivePCids);  
            for(id i:inactivePCids){
                for(NSIBPM__Service_Request__Share thisShareRecord : bookingShareRecordsMap.get(i)){
                    deleteSharingRecordList.add(thisShareRecord);  
                }        
            }
            
            if(!deleteSharingRecordList.isEmpty()){
                system.debug(deleteSharingRecordList+'deleteSharingRecordList-->');
                database.deleteResult[] result = database.delete(deleteSharingRecordList, false);
            }
        }catch(exception e){
        
        }
        
       }
    
     /*********************************************************************************************
    * @Description : Method to get sharing records from the Service request Share table.              
                                  
    *********************************************************************************************/  
    private Map<Id, List<NSIBPM__Service_Request__Share>> getSharingRecords(Set<Id> recordIdsSet,set<id> inactiveRecSet){ 
        Map<Id, List<NSIBPM__Service_Request__Share>> bookingShareRecordsMap = new Map<Id, List<NSIBPM__Service_Request__Share>>();
        for(NSIBPM__Service_Request__Share thisShareRecord : [SELECT Id, ParentId, AccessLevel, UserOrGroupId, RowCause 
                                                              FROM NSIBPM__Service_Request__Share 
                                                              WHERE ParentId IN: recordIdsSet and UserOrGroupId IN:inactiveRecSet]){
            if(bookingShareRecordsMap.containsKey(thisShareRecord.UserOrGroupId )){
                bookingShareRecordsMap.get(thisShareRecord.UserOrGroupId).add(thisShareRecord);      
            }else{
                bookingShareRecordsMap.put(thisShareRecord.UserOrGroupId , new List<NSIBPM__Service_Request__Share>{thisShareRecord});
            }   
        }   
        system.debug('#### bookingShareRecordsMap = '+bookingShareRecordsMap);
        return bookingShareRecordsMap; 
    }
    
    
     // TOBE Implemented
    //public void executeBeforeInsertTrigger(List<sObject> newRecordsList){}
    public void executeBeforeInsertUpdateTrigger(list<sObject> newAccountsList,map<Id,sObject> mapOldRecords){ }
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){ }
    public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){ }
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){ }
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){ }
    //public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){ }
    public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){ }
    
}