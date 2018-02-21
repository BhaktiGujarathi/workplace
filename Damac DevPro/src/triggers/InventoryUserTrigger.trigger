/**************************************************************************************************
* Name               : InventoryUserTrigger                                                       *
* Description        : This is a trigger on inventory user junction object.                       *
* Created Date       : 05/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENT                                           *
* 1.0         NSI - Vineet      05/02/2017      Initial Draft.                                    *
**************************************************************************************************/
trigger InventoryUserTrigger on Inventory_User__c (after delete, after insert, after update) {
    TriggerFactoryCls.createHandler(Inventory_User__c.sObjectType);        
}// End of trigger