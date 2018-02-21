/**************************************************************************************************
* Name               : AttachmentTrigger                                                          *
* Description        : This is a trigger on Attachment object.                                    *
* Created Date       : 24/04/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR        DATE        COMMENTS                                                  *
* 1.0         NSI - Vineet  24/04/2017  Initial Draft                                             *
**************************************************************************************************/
trigger AttachmentTrigger on Attachment (before insert, before update,before delete, after insert) {
    TriggerFactoryCls.createHandler(Attachment.sObjectType);
}// End of trigger