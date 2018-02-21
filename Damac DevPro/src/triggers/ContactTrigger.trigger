/**************************************************************************************************
* Name                  : ContactTrigger
* Test Class            : 
* Description           : This trigger will update the number of customer portal users and create new record
                          on Invenroty Users and Assigned Agents objects for new portal users.
* Created By            : NSI - Sivasankar
* Created Date          : 19/Jan/2017 
* Last Modified Date    :                                                                            
* Last Modified By      :                                                                            
* -------------------------------------------------------------------------------------------------- 
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                                                      
* CH00              1.0         NSI - Sivasankar           19/Jan/2017      Initial development
* CH01              2.0
* CH02              3.0
**************************************************************************************************/
trigger ContactTrigger on Contact (before insert,after insert, before update,after update,before delete,after delete) {
    TriggerFactoryCls.createHandler(Contact.sObjectType);
}