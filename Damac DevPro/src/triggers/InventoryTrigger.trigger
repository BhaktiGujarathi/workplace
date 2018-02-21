/**************************************************************************************************
* Name               : InventoryTrigger                                                           *
* Description        : This is a trigger on inventory object.                                     *
* Created Date       : 04/01/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR          DATE			COMMENTS                                              *
* 1.0         NSI - Ravindra  04/01/2017    Initial Draft                                         *
* 1.1         NSI - Ravindra  26/04/2017    Added logic to update associated booking units.       *
**************************************************************************************************/
trigger InventoryTrigger on Inventory__c (before insert, before update,after insert,after update) {
    TriggerFactoryCls.createHandler(Inventory__c.sObjectType);
    if(trigger.isafter && !DAMAC_Constants.skip_InventoryTrigger && (trigger.isinsert || trigger.isupdate)){
        List<Inventory__c> lstInv = new List<Inventory__c>();
        for(Inventory__c inv : trigger.new){
            if(inv.Status__c != null && inv.Status__c == 'Released'){
                lstInv.add(inv);
            }
        }
        if(lstInv != null && !lstInv.isempty())
        	InventoryHelper.createRec(lstInv);
        if(trigger.isupdate){
        	/* Calling the method to update the associated booking unit status, only on update of the invetory. */
        	InventoryHelper.updateAssociatedBookingUnits(trigger.newMap, trigger.oldMap);
        }
    }
}// End of trigger.