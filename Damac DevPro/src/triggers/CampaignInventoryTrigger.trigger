/****************************************************************************************************************
* Trigger               : CampaignInventoryTrigger                                                              *
* Description           : This trigger will create the Inventory User and delete the inventory user             *
* Created By            : NSI - Sivasankar K                                                                    *               
* Created Date          : 13/Feb/2017                                                                           *   
* Last Modified Date    :                                                                                       *
* Last Modified By      :                                                                                       *
* ------------------------------------------------------------------------------------------------------------  *
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                         *
* CH00              1.0         NSI - Sivasankar K         13/Feb/2017      Initial developmen                  *
* CH01              2.0                                                                                         *
*****************************************************************************************************************/
trigger CampaignInventoryTrigger on Campaign_Inventory__c (before insert,after insert,before update,after update,before delete,after delete) {
    TriggerFactoryCls.createHandler(Campaign_Inventory__c.sObjectType);
}