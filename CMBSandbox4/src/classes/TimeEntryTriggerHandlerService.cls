public with sharing class TimeEntryTriggerHandlerService {
    
    public Set<Id> projectIdsSet = new Set<Id>();
    public Decimal sumOfHoursThisMonth = 0;
    public List<HarvestProject__c> toUpDateProjects = new List<HarvestProject__c>();
    public List<HarvestProject__c> projectList  = new List<HarvestProject__c>();
    
    public TimeEntryTriggerHandlerService() {
    }
    
    public void sumTotalHoursThisMonthOnProject(List<HarvestTimeEntry__c> timeEntryNewList, List<HarvestTimeEntry__c> timeEntryOldList) {
        if(timeEntryNewList != Null) {
            for(HarvestTimeEntry__c timeEntryObj :timeEntryNewList) {
                if(timeEntryObj.HarvestProject__c <> Null) {
                    projectIdsSet.add(timeEntryObj.HarvestProject__c);
                }
            }
        }
        
        if(timeEntryOldList != Null) {
            for(HarvestTimeEntry__c timeEntryObj :timeEntryOldList) {
                if(timeEntryObj.HarvestProject__c <> Null) {
                    projectIdsSet.add(timeEntryObj.HarvestProject__c);
                }
            }
        }
        
        if(projectIdsSet != Null) {
            projectList = [Select Id,
                                  Hours_This_Month__c,
                                  (Select Id,
                                          Hours_For_Client__c,
                                          This_Month__c 
                                   From  HarvestTimeCards__r
                                   Where This_Month__c = True)
                           From HarvestProject__c
                           Where Id IN : projectIdsSet];
        }
        if(projectList != Null) {
            for(HarvestProject__c projectObj : projectList) {
                sumOfHoursThisMonth = 0;
                for(HarvestTimeEntry__c timeEntryObj : projectObj.HarvestTimeCards__r) {
                    if(timeEntryObj.Hours_For_Client__c != null) {
                        sumOfHoursThisMonth = sumOfHoursThisMonth + timeEntryObj.Hours_For_Client__c;
                    }
                }
                projectObj.Hours_This_Month__c = 0;
                projectObj.Hours_This_Month__c = sumOfHoursThisMonth;
                toUpDateProjects.add(projectObj);
            }
        }
         
        try {
            update toUpDateProjects;
        } catch (DMLException ex) {
            System.Debug(ex.getDMLMessage(0));
        }
    }
    
    public void timeEntryRollUpOnAccount(List<HarvestTimeEntry__c> timeEntryNewList, List<HarvestTimeEntry__c> timeEntryOldList)
    {
        Set<Id> accountIdsSet = new Set<Id>();
        List<HarvestTimeEntry__c> timeEntryList  = new List<HarvestTimeEntry__c>();
        map<Id, Account> accountIdToAccountMap = new map<Id, Account>();
        List<Account> accountsToUpdateList = new List<Account>();
        Decimal durationLast30Days = 0.00;
        Decimal hoursLast30Days = 0.00;
        Decimal totalUninvoicedHours = 0.00;
        Decimal totalUninvoicedFees = 0.00;
        Decimal totalContractorCost = 0.00;
        Date lastTimeEntryLoggedDate;
        List<Account> resultAccount = new List<Account>();
        
        // prepare set of accountIds
        if(timeEntryNewList != Null) {
            for(HarvestTimeEntry__c timeEntryObj :timeEntryNewList) {
                if(timeEntryObj.Client_Account_ID__c <> Null) {
                    accountIdsSet.add(timeEntryObj.Client_Account_ID__c);
                }
            }
        }
        
        if(timeEntryOldList != Null) {
            for(HarvestTimeEntry__c timeEntryObj :timeEntryOldList) {
                if(timeEntryObj.Client_Account_ID__c <> Null) {
                    accountIdsSet.add(timeEntryObj.Client_Account_ID__c);
                }
            }
        }
        // get list of time entries for account id in set and date in last 30 days
        if(accountIdsSet!= Null) {
            timeEntryList = [Select id,
                                    Duration__c,
                                    Hours_For_Client__c,
                                    Date__c,
                                    Client_Account_ID__c,
                                    HarvestProject__c,
                                    Invoice_Sent_to_Client__c,
                                    Fee_to_Client__c,
                                    CreatedDate,
                                    Contractor_Cost__c,
                                    HarvestProject__r.Account__r.Duration_Last_30_days__c,
                                    HarvestProject__r.Account__r.Hours_Last_30_days__c,
                                    HarvestProject__r.Account__r.Total_UnInvoiced_Fees__c,
                                    HarvestProject__r.Account__r.Total_UnInvoiced_Hours__c,
                                    HarvestProject__r.Account__r.Most_Recent_Time_Entry_Date__c,
                                    HarvestProject__r.Account__r.Total_contractor_cost__c
                            From HarvestTimeEntry__c
                            Where HarvestProject__r.Account__r.Id IN:accountIdsSet
                            ];
        }
        
        // prepare map
        Account accountObj;
        
            for(Id idInstnace : accountIdsSet) {
                durationLast30Days = 0.00;
                hoursLast30Days = 0.00;
                totalUninvoicedHours = 0.00;
                totalUninvoicedFees = 0.00;
                totalContractorCost = 0.00;
                lastTimeEntryLoggedDate = date.newInstance(2000, 01, 01);

                accountObj = new account(id = idInstnace);
                if(timeEntryList != null && !timeEntryList.isEmpty())
                {
                    for(HarvestTimeEntry__c entryObj :timeEntryList)
                    {
                        if(entryObj.HarvestProject__r.Account__r.Id == idInstnace)
                        {
                            if(entryObj.Invoice_Sent_to_Client__c == False)
                            {
                                totalUninvoicedHours  = totalUninvoicedHours + decimalValue(entryObj.Hours_For_Client__c);
                                totalUninvoicedFees = totalUninvoicedFees + decimalValue(entryObj.Fee_to_Client__c);
                            }
                            system.debug('entryObj.Date__c'+entryObj.Date__c);
                            if(entryObj.Date__c!=null && 30 >= entryObj.Date__c.daysBetween(System.today()))
                            {
                                durationLast30Days = durationLast30Days + decimalValue(entryObj.Duration__c);
                                hoursLast30Days = hoursLast30Days + decimalValue(entryObj.Hours_For_Client__c);
                            }
                            totalContractorCost = totalContractorCost + decimalValue(entryObj.Contractor_Cost__c);
                            if( entryObj.Date__c!=null && lastTimeEntryLoggedDate < entryObj.Date__c)
                                lastTimeEntryLoggedDate = entryObj.Date__c;
                        }
                        accountObj.Total_contractor_cost__c = totalContractorCost;
                        accountObj.Total_UnInvoiced_Hours__c = totalUninvoicedHours;
                        accountObj.Total_UnInvoiced_Fees__c = totalUninvoicedFees;
                        accountObj.Most_Recent_Time_Entry_Date__c = lastTimeEntryLoggedDate;
                        accountObj.Duration_Last_30_days__c = durationLast30Days;
                        accountObj.Hours_Last_30_days__c = hoursLast30Days;
                    }
                }
              /*  else 
                {
                     accountObj.Total_contractor_cost__c = totalContractorCost;
                     accountObj.Total_UnInvoiced_Hours__c = totalUninvoicedHours;
                     accountObj.Total_UnInvoiced_Fees__c = totalUninvoicedFees;
                     accountObj.Most_Recent_Time_Entry_Date__c = null;
                     accountObj.Duration_Last_30_days__c = durationLast30Days;
                     accountObj.Hours_Last_30_days__c = hoursLast30Days;
                }
*/                
                resultAccount.add(accountObj);
            }

        try {
            update resultAccount;
        } catch (DMLException ex) {
            System.Debug(ex.getDMLMessage(0));
        }
    }
    public decimal decimalValue(decimal decValue){
        return((decValue!=null && decvalue>0)?decValue:0);
  } 
    
    
}