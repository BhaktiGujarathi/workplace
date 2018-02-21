/******************************************************************************************
 *  Author   : Ravindra Babu Nagaboina
 *  Company  : NSI DMCC
 *  Date     : 04rd Jan 2017
 ------------------------------------------------------------------------------------------
 Modification History 
 ----------------------------------------------------------------------------------------
 V.No   Date            Updated By          Description
 ----------------------------------------------------------------------------------------              
 V1.0  04/Jan/2016      Ravi                Created
 V2.0  30/Jan/2016      Pavithra Gajendra   Update Record Type based on the location type 
 V2.1  14/Feb/2016      Kaavya Raghuram     Commenting logic which will be done by Informatica     
*******************************************************************************************/
public with sharing class LocationTrgHandler implements TriggerFactoryInterface{
    
    /************ Start of Interface methodes ***************/
    
    public void executeBeforeInsertTrigger(list<sObject> lstNewRecords){
        //Commenting as part of V2.1
        //LocationTrgHandler.LinkFloorUnits(lstNewRecords);
        //LocationTrgHandler.updateRecordType(lstNewRecords);
    }
    
    public void executeBeforeInsertUpdateTrigger(list<sObject> lstNewRecords,map<Id,sObject> mapOldRecords){}
    public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){}
    public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){}
    public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    /************ End of Interface methodes ***************/
    
    //Commenting as part of V2.1
    /*
    public static void LinkFloorUnits(list<Location__c> lstLocations){
        try{
            map<Id,Location__c> mapFloorLocations = new map<Id,Location__c>();
            set<Id> setFloorIds = new set<Id>();
            
            for(Location__c objUnit : lstLocations){
                if(objUnit.Location_Type__c == 'Unit' && objUnit.Floor_Number__c != null){ // populate the Building Locations
                    setFloorIds.add(objUnit.Floor_Number__c);
                }
            }
            if(!setFloorIds.isEmpty()){
                mapFloorLocations = new map<Id,Location__c>([select Id,Building_Number__c from Location__c where Location_Type__c = 'Floor' AND Id IN :setFloorIds ]);
            }
            if(mapFloorLocations != null && mapFloorLocations.isEmpty() == false){
                for(Location__c objUnit : lstLocations){
                    if(objUnit.Location_Type__c == 'Unit' && objUnit.Floor_Number__c != null && mapFloorLocations.containsKey(objUnit.Floor_Number__c)){ // populate the Building Locations
                        objUnit.Building_Number__c = mapFloorLocations.get(objUnit.Floor_Number__c).Building_Number__c;
                    }
                }
            }
        }catch(Exception ex){
            system.debug('Exception is : '+ex.getMessage());
            throw new CustomException(ex.getMessage());
        }
    } */
    
    /*
    * Update Record Type based on the location type 
    */
    //Commenting as part of V2.1
    /*
    public static void updateRecordType(list<Location__c> lstLocations){
        
        Id unitRecordTypeId   = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(DAMAC_Constants.LOCATION_UNIT_RT).getRecordTypeId();
        Id buildingRecordTypeId   = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(DAMAC_Constants.LOCATION_BUILDING_RT).getRecordTypeId();
        Id floorRecordTypeId   = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(DAMAC_Constants.LOCATION_FLOOR_RT).getRecordTypeId();
        
        for(Location__c loc : lstLocations){
            if(loc.Location_Type__c==DAMAC_Constants.LOCATION_TYPE_FLOOR){
                loc.RecordTypeId = floorRecordTypeId;
            }else if(loc.Location_Type__c==DAMAC_Constants.LOCATION_TYPE_UNIT  || loc.Location_Type__c==DAMAC_Constants.LOCATION_TYPE_OFFICE ){
                loc.RecordTypeId = unitRecordTypeId;
            }else if(loc.Location_Type__c==DAMAC_Constants.LOCATION_TYPE_BUILDING){
                loc.RecordTypeId = buildingRecordTypeId;
            }
        }
    } */
}