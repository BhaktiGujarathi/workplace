/******************************************************************************************
 *  Author   : Charan Vuyyuru
 *  Company  : NSI DMCC
 *  Date     : 25th Jan 2017
 --------------------------------------------------------------------------------------------------------------------------
 Modification History 
 ----------------------------------------------------------------------------------------
 V.No   Date            Updated By          Description
 ----------------------------------------------------------------------------------------              
 V1.0  25/Jan/2017      Charan                Created
*******************************************************************************************/
trigger AddressTrigger on Address__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  TriggerFactoryCls.createHandler(Address__c.sObjectType);
}