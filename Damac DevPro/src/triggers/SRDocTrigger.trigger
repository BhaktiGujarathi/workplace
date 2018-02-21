/**************************************************************************************************
* Name               : SRDocTrigger                                                             *
* Description        : This is a trigger on SRDoc object.                                       *
* Created Date       : 30/03/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         Kaavya      30/03/2017                                                              *
**************************************************************************************************/
trigger SRDocTrigger on NSIBPM__SR_Doc__c(before insert, before update, after insert, after update) {
  TriggerFactoryCls.createHandler(NSIBPM__SR_Doc__c.sObjectType);
}// End of trigger