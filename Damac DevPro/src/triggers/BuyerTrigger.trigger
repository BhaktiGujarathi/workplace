/**************************************************************************************************
* Name               : BuyerTrigger                                                             *
* Description        : This is a trigger on Buyer object.                                       *
* Created Date       : 16/04/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         Kaavya      16/04/2017                                                              *
**************************************************************************************************/
trigger BuyerTrigger on Buyer__c(before insert, before update, after insert, after update) {
  TriggerFactoryCls.createHandler(Buyer__c.sObjectType);
}// End of trigger