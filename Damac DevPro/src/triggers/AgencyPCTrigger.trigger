/**************************************************************************************************
* Name                  : AgencyPCTrigger    
* Test Class            : 
* Description           : This class will rollup the number of PCs assigned in Agency
* Created By            : NSI - Sivasankar                                                                        
* Created Date          : 12/Jan/2017 
* Last Modified Date    :                                                                            
* Last Modified By      :                                                                            
* -------------------------------------------------------------------------------------------------- 
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                                                      
* CH00              1.0         NSI - Sivasankar           12/Jan/2017      Initial development
* CH01              2.0
* CH02              3.0
**************************************************************************************************/
trigger AgencyPCTrigger on Agency_PC__c (After insert,After update,After delete,before delete) { 
    TriggerFactoryCls.createHandler(Agency_PC__c.sObjectType); 
}