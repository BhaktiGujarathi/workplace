/******************************************************************************************
 *  Author   : Ravindra Babu Nagaboina
 *  Company  : NSI DMCC
 *  Date     : 04rd Jan 2017
 --------------------------------------------------------------------------------------------------------------------------
 Modification History 
 ----------------------------------------------------------------------------------------
 V.No   Date            Updated By          Description
 ----------------------------------------------------------------------------------------              
 V1.0  04/Jan/2016      Ravi                Created
*******************************************************************************************/
trigger LocationTrigger on Location__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerFactoryCls.createHandler(Location__c.sObjectType);
}