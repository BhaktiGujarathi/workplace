/**************************************************************************************************
* Name               : AccountSalesCalculator                                                     *
* Description        : Batch class to calculate the total yearly sales. As per the below criteria:*
*                       - Roll up of all the bookings completed in the previous year.             *
*                       - Calculation is only available for Corporate agents and ,                * 
*                         only if the eligibility for tier program is enabled for them.           *
* Created Date       : 05/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      05/02/2017      Initial Draft.                                    *
**************************************************************************************************/
public class AccountSalesCalculator implements Database.Batchable<sObject>{ 
    
    private static final Id CORPORATE_AGENCY_RECORD_TYPE_ID = DamacUtility.getRecordTypeId('Account', 'Corporate Agency');
    private static final Id DEAL_SR_RECORD_TYPE_ID = DamacUtility.getRecordTypeId('NSIBPM__Service_Request__c', 'Deal');
    private static final String APPROVED = 'Approved';
    
    /********************************************************************************************* 
    * @Description : Implementing the start method of batch interface, contains query.           *
    * @Params      : Database.BatchableContext                                                   *
    * @Return      : Database.QueryLocator                                                       *
    *********************************************************************************************/  
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name, Quarter_1_Sales__c, Quarter_2_Sales__c, Quarter_3_Sales__c, Quarter_4_Sales__c, '+
                              '(SELECT Id, Total_Booking_Amount__c, Registration_Status__c, Registration_Date__c '+
                               'FROM Service_Requests_Agents__r '+
                               'WHERE Registration_Status__c =: APPROVED AND '+
                                     'Registration_Date__c = THIS_QUARTER AND '+ 
                                     'Doc_ok__c = TRUE AND '+  
                                     'DP_ok__c = TRUE AND '+
                                     'RecordTypeId =: DEAL_SR_RECORD_TYPE_ID) '+ 
                       'FROM Account '+
                       'WHERE RecordTypeId =: CORPORATE_AGENCY_RECORD_TYPE_ID AND '+
                             'Eligible_For_Tier_Program__c = TRUE'; 
        return Database.getQueryLocator(query);
    }
   
    /*********************************************************************************************
    * @Description : Implementing the execute method of batch interface, contains the criteria.  *
    * @Params      : Database.BatchableContext, List<sObject>                                    *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void execute(Database.BatchableContext BC, List<SObject> accountList){
        Map<Id, SObject> accountDetailsMap = new Map<Id, SObject>();
        if(accountList != null){
            for(SObject thisAccount : accountList){
                Account referedAccount = (Account)thisAccount; 
                system.debug('#### referedAccount = '+referedAccount);
                for(NSIBPM__Service_Request__c thisDeal : referedAccount.Service_Requests_Agents__r){
                    system.debug('#### thisDeal = '+thisDeal);
                    if(thisDeal.Total_Booking_Amount__c != null && thisDeal.Registration_Date__c != null){
                        Integer quarter = DamacUtility.getQuarterForMonth(thisDeal.Registration_Date__c.month());
                        /* Calling method to reset the sales value for future quarters if populated. */
                        thisAccount = resetSalesValues(quarter, thisAccount);
                        /* Getting the correct quarter and getting the correct field to populate the value. */
                        String fieldToPopulate = 'Quarter_'+String.valueOf(quarter)+'_Sales__c';
                        if(accountDetailsMap.containsKey((Id)thisAccount.get('Id'))){ 
                            Decimal salesValue = 
                                (accountDetailsMap.get((Id)thisAccount.get('Id')) != null && accountDetailsMap.get((Id)thisAccount.get('Id')).get(fieldToPopulate) != null ? 
                                    (Decimal)accountDetailsMap.get((Id)thisAccount.get('Id')).get(fieldToPopulate) : 0) + thisDeal.Total_Booking_Amount__c; 
                            thisAccount.put(fieldToPopulate, salesValue); 
                        }else{
                             thisAccount.put(fieldToPopulate, thisDeal.Total_Booking_Amount__c);
                        }
                        accountDetailsMap.put((Id)thisAccount.get('Id'), thisAccount);
                    }   
                }   
            }
            if(!accountDetailsMap.isEmpty() && !accountDetailsMap.values().isEmpty()){ 
                update accountDetailsMap.values();
            }
        }
    }
    
    /*********************************************************************************************
    * @Description : Implementing Finish method, to end an email after job completion.           *
    * @Params      : Database.BatchableContext                                                   *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void finish(Database.BatchableContext BC){ }
    
    /*********************************************************************************************
    * @Description : Method to reset the sales value of future quarters if populated.            *
    * @Params      : Integer, SObject                                                            *
    * @Return      : SObject                                                                     *
    *********************************************************************************************/
    private SObject resetSalesValues(Integer quarter, SObject accountRecord){
        if(quarter < 4){
            for(Integer counter = quarter + 1; quarter <= 4; quarter++){
                String fieldToPopulate = 'Quarter_'+String.valueOf(counter)+'_Sales__c';  
                if(accountRecord.get(fieldToPopulate) != null){
                    accountRecord.put(fieldToPopulate, 0.0);
                }
            }  
        }
        return accountRecord;
    }
}// End of class.