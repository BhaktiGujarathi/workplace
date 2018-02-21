/**************************************************************************************************
* Name               : InventoryUserTriggerHandler                                                *
* Description        : This is a handler class to manage Inventory User object.                   *
*                      - Used to update the Is Assigned flag on the inventory.                    *
* Created Date       : 30/01/2017                                                                 *
* Created By         : NSI - Vineet                                                               *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE          Description                                         *
* 1.0         NSI - Vineet      30/01/2017    Initial Draft                                       *
**************************************************************************************************/
public class InventoryUserTriggerHandler extends UtilitySharingManager implements TriggerFactoryInterface{ 
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after insert.                        *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){ 
        try{
            updateInVentoriesWithIsAssigned((Map<Id, Inventory_User__c>) newRecordsMap);
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }    
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after delete.                        *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterDeleteTrigger(Map<Id, sObject> oldRecordsMap){ 
        try{
            updateInVentoriesWithIsAssigned((Map<Id, Inventory_User__c>) oldRecordsMap);
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }  
    
    /*********************************************************************************************
    * @Description : Method to update related inventory as Is Assigned = true                     *
    * @Params      : Map<Id, Inventory_User__c>                                                  *
    * @Return      : void                                                                        *
    *********************************************************************************************/ 
    @TestVisible  private void updateInVentoriesWithIsAssigned(Map<Id, Inventory_User__c> inventoruUsersMap){
        List<Inventory__c> updateInventory = new List<Inventory__c>();
        Set<ID> updateInventoryIDs = new Set<ID>();
        System.debug('Trigger execution '+Trigger.isInsert);
        for(Inventory_User__c invUser : inventoruUsersMap.values()){
            if(!updateInventoryIDs.contains(invUser.Inventory__c)){
                updateInventory.add(new Inventory__c(id = invUser.Inventory__c,Is_Assigned__c = (Trigger.isDelete) ? false : true));
                updateInventoryIDs.add(invUser.Inventory__c);
            }
        }
        if(!updateInventory.isEmpty() & updateInventory.size() > 0)
            update updateInventory;
    }
    
    // TOBE Implemented
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){}
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, map<Id,sObject> oldRecordsMap){}
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
}// End of class