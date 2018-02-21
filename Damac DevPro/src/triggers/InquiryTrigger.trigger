/******************************************************************************************
 *  Author   : Ravindra Babu Nagaboina
 *  Company  : NSI DMCC
 *  Date     : 08th Jan 2017
 --------------------------------------------------------------------------------------------------------------------------
 Modification History 
 ----------------------------------------------------------------------------------------
 V.No   Date            Updated By          Description
 ----------------------------------------------------------------------------------------              
 V1.0  08/Jan/2016      Ravi                Created
*******************************************************************************************/
trigger InquiryTrigger on Inquiry__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerFactoryCls.createHandler(Inquiry__c.sObjectType);
}