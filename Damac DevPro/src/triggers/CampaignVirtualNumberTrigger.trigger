/**************************************************************************************************
* Name               : CampaignVirtualNumberTrigger                                               *
* Description        : This is a trigger on JO_Campaign_Virtual_Number__c object.                 *
* Created Date       : 16/01/2017                                                                 *
* Created By         : NSI                                                                        *
* Last Modified Date :                                                                            *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         NSI         16/01/2017                                                              *
**************************************************************************************************/
trigger CampaignVirtualNumberTrigger on JO_Campaign_Virtual_Number__c (before insert, before update) {
 	TriggerFactoryCls.createHandler(JO_Campaign_Virtual_Number__c.sObjectType);      
}// End of trigger.