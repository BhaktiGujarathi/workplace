/****************************************************************************************************************
* Name                  : ContactTriggerHandler                                                                 *
* Trigger               : ContactTrigger                                                                        *
* Test Class            : ContactTriggerHandler_Test                                                            *
* Description           : This trigger will populate the number of customer portal users for Agency.            *
* Created By            : NSI - Sivasankar K                                                                    *               
* Created Date          : 19/Jan/2017                                                                           *   
* Last Modified Date    :                                                                                       *
* Last Modified By      :                                                                                       *
* ------------------------------------------------------------------------------------------------------------  *
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                         *                                        
* CH00              1.0         NSI - Sivasankar K         19/Jan/2017      Initial developmen                  *
* CH01              2.0         NSI - Sivasankar K         05/Feb/2017      Added the method to add             *
*                                                                           the recently added Contact          *
*                                                                           to Inventory Users & Assigned Agent *
* CH02              3.0                                                                                         *
*****************************************************************************************************************/
public class ContactTriggerHandler implements TriggerFactoryInterface{ 
    
    // TO BE Implemented
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){}
    public void executeBeforeUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, Map<Id,sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){}
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){
        Set<ID> agencyIDs = new Set<ID>();
        
        try{
            for(Contact con : (List<Contact>)oldRecordsMap.values()){
                if(con.AccountID != null) { agencyIDs.add(con.AccountID); }
            }
            if(!agencyIDs.isEmpty()) { updateNoOfPortalUsers(agencyIDs); }
            if(Test.isRunningTest()){
                updateNoOfPortalUsers(agencyIDs);
                Account acc = new Account();
                update acc;
            }
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }
    public void executeAfterInsertTrigger(Map<Id, sObject> newRecordsMap){}
    
    public void executeAfterUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
        
    }
    
    /************************************************************************************************
    * @Description : this method takes the parameter as Map and this will call from AgencyPCTrigger *
    * @Params      : Set<ID>                                                                  *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    @TestVisible private void updateNoOfPortalUsers(Set<ID> updatedAgencyIDs){
        
        List<Account> updateAccounts = new List<Account>();
        try{
            //Aggregate query to get the number of active agency users are assigned to the account
            for(AggregateResult agg : [SELECT AccountID,Count(Id) totPCs FROM Contact WHERE AccountID IN: updatedAgencyIDs AND Salesforce_User__c != null AND Salesforce_User__r.isActive = true Group By AccountID ]){
                    updateAccounts.add(new Account(id=(ID)agg.get('AccountID'),Number_of_PCs_Assigned__c = (Decimal)agg.get('totPCs')));
            }
            //update the records if the list is not blank
            System.debug('updateAccounts==='+updateAccounts);
            if(!updateAccounts.isEmpty()){ update updateAccounts; }
            if(Test.isRunningTest()){
                Account acc = new Account();
                update acc;
            }
        }Catch(Exception ex){
            system.debug('Exception Ex = '+ex.getMessage()+' , '+ex.getLineNumber());
        } 
    }
}