/**
 *
 * Description :
 *  1.Used to calculate the average on account from all associated Credit card records
 *  2.Used to calculate the total number of credit card records associated with the account.
 *
 *  Version       Author             Date(dd/mm/yyyy)       Description
 *    1.0
 *    1.1      Ashwini Singh          26/10/2015            To update the average fields on account
 *                                                         in correspondence to the associated credit
 *                                                         card records.
 *
 **/
 
public without sharing class BankAccountHandlerServiceAfter {

  public BankAccountHandlerServiceAfter(){}
  
  
  
   //   FO-1630
    public void opportunityRollUpBankStatment(map<Id, Bank_Account__c> bankAccountNewMap, map<Id, Bank_Account__c> bankAccountOldMap)
    {
          system.debug('Enter in Delete');
          set<Id> setOpportunityId = new set<Id>();
          Map<id,List<AggregateResult>> mapOppIDAgrrResultBankStm = new Map<id,List<AggregateResult>>();
          List<Opportunity> opportunityListResult = new List<Opportunity>();
          
          Decimal sumNSF = 0;                                     
          Decimal sumNDB = 0;                                     
          Decimal sumMonthlyBalance = 0; 
          Decimal sumDepositsCurrencyMonthly = 0;                                     
          Decimal sumDepositsHoursMonthly = 0;   
          
          Decimal countNSF = 0;                                   
          Decimal countNDB = 0;                                     
          Decimal countMonthlyBalance = 0; 
          Decimal countDepositsCurrencyMonthly = 0;                                     
          Decimal countDepositsHoursMonthly  = 0; 
          
          Decimal avgNSF = 0;                                     
          Decimal avgNDB = 0;                                     
          Decimal avgMonthlyBalance = 0; 
          Decimal avgDepositsCurrencyMonthly = 0;                                     
          Decimal avgDepositsHoursMonthly  = 0; 
           
            if (bankAccountNewMap != null)
            {
                for(Bank_Account__c stmt: bankAccountNewMap.Values())
                {
                    if(stmt.Opportunity__c != null){
                        setOpportunityId.add(stmt.Opportunity__c);
                    }
                }
            }
            
            if (bankAccountOldMap != null)
            {
                for(Bank_Account__c stmt: bankAccountOldMap.Values())
                {
                    if(stmt.Opportunity__c != null){
                        setOpportunityId.add(stmt.Opportunity__c);
                    }
                }
            }
            
        
              AggregateResult[] groupedResults = [SELECT Month__c,
                                                         Year__c,
                                                         Opportunity__c,
                                                         COUNT(Number_of_NSFs__c) numNSFCnt,
                                                         COUNT(Number_of_Negative_Days__c) numNegDayCnt,
                                                         COUNT(Average_Daily_Balance__c) avgDailyBalanceCnt,
                                                         COUNT(Deposits__c) despCnt,
                                                         COUNT(No_Deposits__c) numDepCnt,
                                                         
                                                         SUM(Number_of_NSFs__c) numNSFSum,
                                                         SUM(Number_of_Negative_Days__c) numNegDaySum,
                                                         SUM(Average_Daily_Balance__c) avgDailyBalanceSum,
                                                         SUM(Deposits__c) despSum,
                                                         SUM(No_Deposits__c) numDepSum 
                                                  FROM Bank_Account__c 
                                                  WHERE Include_in_average__c = true 
                                                  AND Opportunity__c IN :setOpportunityId 
                                                  AND Month__c != NULL
                                                  AND Year__c != NULL
                                                  GROUP BY Month__c,Year__c, Opportunity__c];
                                                  
                                           
              
          // mapping is remaining.
          Map<id,Opportunity> mapIdOpp = new  Map<id,Opportunity>([SELECT Id,
                                                                          Name,
                                                                          NDBs_Avg__c,
                                                                          NSFs_Avg__c,
                                                                          Average_Daily_Balance__c,
                                                                          Gross_monthly_Sales__c,
                                                                          Avg_Number_Bank_Deposits__c
                                                                    FROM Opportunity
                                                                    WHERE Id IN :setOpportunityId ]);
                                                                    
      
          for (Integer i=0 ; i < groupedResults.size();i++)  
          {
              
              if(mapOppIDAgrrResultBankStm.containsKey((ID)groupedResults[i].get('Opportunity__c')))
              {
                  List<AggregateResult> tempAggr = mapOppIDAgrrResultBankStm.get((ID)groupedResults[i].get('Opportunity__c'));
                  tempAggr.add(groupedResults[i]); 
              }
              else
              {
                  List<AggregateResult> lstAgrRes  = new List<AggregateResult>();
                  lstAgrRes.add(groupedResults[i]);
                  mapOppIDAgrrResultBankStm.put((ID)groupedResults[i].get('Opportunity__c'),lstAgrRes);
              
              }
             
          }
        
        for(ID oppID: mapOppIDAgrrResultBankStm.keySet()) 
        { 
           Opportunity opportunityObj =  mapIdOpp.get(oppID);
           if(opportunityObj != NULL)
           {
               List<AggregateResult> groupedResult = mapOppIDAgrrResultBankStm.get(oppID);
               for (Integer i=0 ; i < groupedResult.size();i++)  
               {
                      sumNSF = sumNSF + treatNullAsZero((Decimal)groupedResult[i].get('numNSFSum'));
                      sumNDB = sumNDB + treatNullAsZero((Decimal)groupedResult[i].get('numNegDaySum'));
                      sumMonthlyBalance = sumMonthlyBalance + treatNullAsZero((Decimal)groupedResult[i].get('avgDailyBalanceSum'));
                      sumDepositsCurrencyMonthly = sumDepositsCurrencyMonthly + treatNullAsZero((Decimal)groupedResult[i].get('despSum'));  
                      sumDepositsHoursMonthly = sumDepositsHoursMonthly + treatNullAsZero((Decimal)groupedResult[i].get('numDepSum'));
                      
                      countNSF = (((Decimal)groupedResult[i].get('numNSFCnt') != 0) ? countNSF + 1: countNSF);
                      countNDB = (((Decimal)groupedResult[i].get('numNegDayCnt') != 0) ? countNDB + 1: countNDB);
                      countMonthlyBalance = (((Decimal)groupedResult[i].get('avgDailyBalanceCnt') != 0) ? countMonthlyBalance + 1: countMonthlyBalance);
                      countDepositsCurrencyMonthly = (((Decimal)groupedResult[i].get('despCnt') != 0) ? countDepositsCurrencyMonthly + 1: countDepositsCurrencyMonthly);
                      countDepositsHoursMonthly = (((Decimal)groupedResult[i].get('numDepCnt') != 0) ? countDepositsHoursMonthly + 1: countDepositsHoursMonthly);
                }
                
                  
                    opportunityObj.NDBs_Avg__c = sumNDB / treatNullCntAsOne(countNDB);
                    opportunityObj.NSFs_Avg__c = sumNSF / treatNullCntAsOne(countNSF);
                    opportunityObj.Average_Daily_Balance__c = sumMonthlyBalance / treatNullCntAsOne(countMonthlyBalance);
                    opportunityObj.Gross_monthly_Sales__c = sumDepositsCurrencyMonthly / treatNullCntAsOne(countDepositsCurrencyMonthly);
                    opportunityObj.Avg_Number_Bank_Deposits__c = sumDepositsHoursMonthly / treatNullCntAsOne(countDepositsHoursMonthly);
                    opportunityListResult.add(opportunityObj);
               
           }
           
           
        }
       
        update opportunityListResult;
       
    }
    
    public Decimal treatNullAsZero(Decimal value)
    {
        return (value == NULL ? 0 : value);
    }
    
     public Decimal treatNullCntAsOne(Decimal value)
    {
        return (value == 0 ? 1 : value);
    }
  
  
  
  
  
  //Function used to update Account on Bank Statements to Acc of opportunity
  /*  public void updateNoOfBankAcc(map<Id, Bank_Account__c> bankAccountOldMap, list<Bank_Account__c> BankAccountList, String frmOperation){
        set<Id> setAccountId = new set<Id>();
        set<Id> setOldAccountId = new set<Id>();
        map<Id,Account> updatedAccMap = new map<Id,Account>();
        
        // Loop through all the newly created records
        for(Bank_Account__c bankAcc: BankAccountList){
            //If the lookup filed is not empty
            if(frmOperation != BankAccountHandler.frmUpdate && bankAcc.Account__c != null){
                //maintain a set of  IDs
                setAccountId.add(bankAcc.Account__c);
            }
            
            //If from Update and the Count is changed
            if(frmOperation == BankAccountHandler.frmUpdate && bankAccountOldMap.get(bankAcc.Id).Account__c != bankAcc.Account__c ){
                
                // Maintain a set of new Account
                if(bankAcc.Account__c != null)
                    setAccountId.add(bankAcc.Account__c);
                
                // Maintain a set of old Account 
                if(bankAccountOldMap.get(bankAcc.Id).Account__c != null)    
                    setOldAccountId.add(bankAccountOldMap.get(bankAcc.Id).Account__c);
            }   
        }
        
        //Query all the Opportunities
        Map<Id,Account> accountMap = new map<Id,Account>([Select Number_Bank_Statements_Available__c 
                                                                       from Account  
                                                                       where Id IN: setAccountId or 
                                                                             Id IN : setOldAccountId]);
        
        Account acc; 
        
        for(Bank_Account__c bankAcc: BankAccountList){
            //If the lookup field is not empty
            if(bankAcc.Account__c != null && accountMap.size() > 0 && accountMap.containsKey(bankAcc.Account__c)){
                
                acc = ( (updatedAccMap.size() > 0 && accountMap.containsKey(bankAcc.Account__c)) ?
                                updatedAccMap.get(bankAcc.Account__c )  : 
                                    new Account( Id = bankAcc.Account__c, 
                                                 Number_Bank_Statements_Available__c = accountMap.get(bankAcc.Account__c).Number_Bank_Statements_Available__c));
                
                if((frmOperation == BankAccountHandler.frmInsert || 
                                   (frmOperation == BankAccountHandler.frmUpdate &&  bankAccountOldMap.get(bankAcc.Id).Account__c != bankAcc.Account__c)
                                   ))
                    acc.Number_Bank_Statements_Available__c = 1+ (acc.Number_Bank_Statements_Available__c == null ? 0 : acc.Number_Bank_Statements_Available__c ); 
                else if(frmOperation == BankAccountHandler.frmDelete)
                    acc.Number_Bank_Statements_Available__c = (acc.Number_Bank_Statements_Available__c == null ? 0 : acc.Number_Bank_Statements_Available__c ) - 1; 
                updatedAccMap.put(acc.Id, acc);
            }
            
            // If it is an update operation, get the old Account and subtract the count from the previuos account   
            if(frmOperation == BankAccountHandler.frmUpdate && bankAccountOldMap.get(bankAcc.Id).Account__c != bankAcc.Account__c &&
                                            accountMap.size() > 0 && 
                                            bankAccountOldMap.get(bankAcc.Id).Account__c != null &&
                                            accountMap.containsKey(bankAccountOldMap.get(bankAcc.Id).Account__c)  ){
                
                //get the old Account
                Account account = ((updatedAccMap.size() > 0 && updatedAccMap.containsKey(bankAccountOldMap.get(bankAcc.Id).Account__c)) ?
                                    updatedAccMap.get(bankAccountOldMap.get(bankAcc.Id).Account__c)  : 
                                new Account( Id = bankAccountOldMap.get(bankAcc.Id).Account__c , 
                                            Number_Bank_Statements_Available__c = accountMap.get(bankAccountOldMap.get(bankAcc.Id).Account__c).Number_Bank_Statements_Available__c ));
            
                account.Number_Bank_Statements_Available__c = (account.Number_Bank_Statements_Available__c == null ? 0 : account.Number_Bank_Statements_Available__c ) - 1; 
                updatedAccMap.put(account.Id, account);
            }
        }
        /*if(updatedAccMap.size() > 0)
            update updatedAccMap.Values();*/
   /* }
    */
  
  //Commented as per FO-1630
  /*  public void accountRollup(map<Id, Bank_Account__c> bankAccountNewMap, map<Id, Bank_Account__c> bankAccountOldMap){
        set<Id> setAccount = new set<Id>();// to  fetch  related account
        Map<String, List<Bank_Account__c>> mapYearMonthToBankStatement = new Map<String, List<Bank_Account__c>>();
        List<Bank_Account__c> bankStatmentList = new List<Bank_Account__c>();
        decimal totalbankstatements = 0;
        decimal avgDepositsCurrencyMonthly=0;
        decimal avgDepositsHoursMonthly=0;
        decimal avgMonthlyBalance=0;
        decimal avgNSF=0;
        decimal avgNDB=0;
        list<Account> accountListResult = new list<Account>(); // list of account that will be updated
        // add to set for insert or update
        if (bankAccountNewMap!= null){
            for(Bank_Account__c stmt: bankAccountNewMap.Values()){
                if(stmt.Account__c != null){
                    setAccount.add(stmt.Account__c);
                }
            }
        }// add to set for update or delete 
        if (bankAccountOldMap!= null){
            for(Bank_Account__c stmt: bankAccountOldMap.Values()){
                if(stmt.Account__c != null){
                    setAccount.add(stmt.Account__c);
                }
            }
        }
        // fetching list of account to be updated
        list<Account> lstAcc=[Select a.NSFs_Avg__c,
                                    a.NDBs_Avg__c,
                                    a.Monthly_Deposits_Avg__c,
                                    a.Monthly_Bank_Deposit_Avg_All__c,
                                    a.Avg_Monthly_Balance__c,
                                    (Select Account__c,
                                            Average_Daily_Balance__c,
                                            Deposits__c,
                                            Number_of_NSFs__c,
                                            Number_of_Negative_Days__c,
                                            No_Deposits__c,
                                            Year__c,
                                            Month__c
                                     From Bank_Accounts1__r
                                     Where Include_in_average__c = true)
                               From Account a
                               Where a.Id IN : setAccount];
        
        //if the List of queried accounts is not empty
        if(!lstAcc.isEmpty()) {
            //for every account in the list
            for(Account accountObj : lstAcc) {
                mapYearMonthToBankStatement.clear();
                totalbankstatements = 0;
                avgDepositsCurrencyMonthly = 0;
                avgDepositsHoursMonthly = 0;
                avgMonthlyBalance = 0;
                avgNSF = 0;
                avgNDB = 0;
                
                //if the account has associated BankAccount records
                if(!accountObj.Bank_Accounts1__r.isEmpty()) {
                    for(Bank_Account__c bankAccountObj : accountObj.Bank_Accounts1__r) {
                        totalbankstatements = accountObj.Bank_Accounts1__r.size();
                        String yearMonthKey = String.ValueOf(bankAccountObj.Year__c) + String.ValueOf(bankAccountObj.Month__c);
                        if(!mapYearMonthToBankStatement.containsKey(yearMonthKey)) 
                        {
                            mapYearMonthToBankStatement.put(yearMonthKey, new List<Bank_Account__c>{bankAccountObj});
                        }
                        else 
                        {
                            bankStatmentList.clear();
                            bankStatmentList = mapYearMonthToBankStatement.get(yearMonthKey);
                            bankStatmentList.add(bankAccountObj);
                            mapYearMonthToBankStatement.put(yearMonthKey, bankStatmentList);
                        }
                        
                        //calculate the average of fields
                        if(bankAccountObj.No_Deposits__c <> Null)
                            avgDepositsHoursMonthly += bankAccountObj.No_Deposits__c;
                        if(bankAccountObj.Deposits__c <> Null)
                            avgDepositsCurrencyMonthly += bankAccountObj.Deposits__c;
                        if(bankAccountObj.Average_Daily_Balance__c <> Null)
                            avgMonthlyBalance += bankAccountObj.Average_Daily_Balance__c;
                        if(bankAccountObj.Number_of_NSFs__c <> Null)
                            avgNSF += bankAccountObj.Number_of_NSFs__c;
                        if(bankAccountObj.Number_of_Negative_Days__c <> Null) 
                            avgNDB += bankAccountObj.Number_of_Negative_Days__c;
                    }
                }
                if(mapYearMonthToBankStatement.size() <> 0) {
                    //assign the calculated values to the account 
                    accountObj.NDBs_Avg__c = avgNDB/mapYearMonthToBankStatement.size();
                    accountObj.NSFs_Avg__c = avgNSF/mapYearMonthToBankStatement.size();
                    accountObj.Avg_Monthly_Balance__c = avgMonthlyBalance/mapYearMonthToBankStatement.size();
                    accountObj.Monthly_Bank_Deposit_Avg_All__c = avgDepositsCurrencyMonthly/mapYearMonthToBankStatement.size();
                    accountObj.Monthly_Deposits_Avg__c = avgDepositsHoursMonthly/mapYearMonthToBankStatement.size();
                    accountObj.Number_Bank_Statements_Available__c = totalbankstatements;
                    accountListResult.add(accountObj);
                }
            }
            //if the list of account to updated is not empty 
            if(!accountListResult.isEmpty()) {
                    update accountListResult;
                }
         
        }
    }*/
    
   
    
    
    
    
    
    //new function
    /*
    public void opportunityRollup(map<Id, Bank_Account__c> bankAccountNewMap, map<Id, Bank_Account__c> bankAccountOldMap)
    {
        set<Id> setOpportunityId = new set<Id>();
        Map<String, List<Bank_Account__c>> mapYearMonthToBankStatement = new Map<String, List<Bank_Account__c>>();
        List<Bank_Account__c> bankStatmentList = new List<Bank_Account__c>();
        decimal totalbankstatements = 0;
        decimal avgDepositsCurrencyMonthly=0;
        decimal avgDepositsHoursMonthly=0;
        decimal avgMonthlyBalance=0;
        decimal avgNSF=0;
        decimal avgNDB=0;
        list<Opportunity> opportunityListResult = new list<Opportunity>(); // list of Opportunity that will be updated
        // add to set for insert or update
        if (bankAccountNewMap!= null){
            for(Bank_Account__c stmt: bankAccountNewMap.Values()){
                if(stmt.Opportunity__c != null){
                    setOpportunityId.add(stmt.Opportunity__c);
                }
            }
        }// add to set for update or delete 
        if (bankAccountOldMap!= null){
            for(Bank_Account__c stmt: bankAccountOldMap.Values()){
                if(stmt.Opportunity__c != null){
                    setOpportunityId.add(stmt.Opportunity__c);
                }
            }
        }
        // fetching list of opportunity to be updated
         list<Opportunity> lstOpp=[select o.NDBs_avg__c,
                                         o.NSFs_avg__c,
                                         o.Gross_monthly_Sales__c,
                                         o.Avg_Number_Bank_Deposits__c,
                                         o.Average_Daily_Balance__c,
                                       (Select Account__c,
                                            Average_Daily_Balance__c,
                                            Deposits__c,
                                            Number_of_NSFs__c,
                                            Number_of_Negative_Days__c,
                                            No_Deposits__c,
                                            Year__c,
                                            Month__c
                                     From Bank_Accounts__r
                                     Where Include_in_average__c = true)
                               From Opportunity o
                               Where o.Id IN : setOpportunityId];
        
        //if the List of queried accounts is not empty
        if(!lstOpp.isEmpty()) 
        {
            //for every account in the list
            for(Opportunity opportunityObj : lstOpp) 
            {
                mapYearMonthToBankStatement.clear();
                totalbankstatements = 0;
                avgDepositsCurrencyMonthly = 0;
                avgDepositsHoursMonthly = 0;
                avgMonthlyBalance = 0;
                avgNSF = 0;
                avgNDB = 0;
                
                //if the account has associated BankAccount records
                if(!opportunityObj.Bank_Accounts__r.isEmpty()) {
                    for(Bank_Account__c bankAccountObj : opportunityObj.Bank_Accounts__r) {
                        totalbankstatements = opportunityObj.Bank_Accounts__r.size();
                        String yearMonthKey = String.ValueOf(bankAccountObj.Year__c) + String.ValueOf(bankAccountObj.Month__c);
                        if(!mapYearMonthToBankStatement.containsKey(yearMonthKey)) 
                        {
                            mapYearMonthToBankStatement.put(yearMonthKey, new List<Bank_Account__c>{bankAccountObj});
                        }
                        else 
                        {
                            bankStatmentList.clear();
                            bankStatmentList = mapYearMonthToBankStatement.get(yearMonthKey);
                            bankStatmentList.add(bankAccountObj);
                            mapYearMonthToBankStatement.put(yearMonthKey, bankStatmentList);
                        }
                        //calculate the average of fields
                        if(bankAccountObj.No_Deposits__c <> Null)
                            avgDepositsHoursMonthly += bankAccountObj.No_Deposits__c;
                        if(bankAccountObj.Deposits__c <> Null)
                            avgDepositsCurrencyMonthly += bankAccountObj.Deposits__c;
                        if(bankAccountObj.Average_Daily_Balance__c <> Null)
                            avgMonthlyBalance += bankAccountObj.Average_Daily_Balance__c;
                        if(bankAccountObj.Number_of_NSFs__c <> Null)
                            avgNSF += bankAccountObj.Number_of_NSFs__c;
                        if(bankAccountObj.Number_of_Negative_Days__c <> Null) 
                            avgNDB += bankAccountObj.Number_of_Negative_Days__c;
                    }
                }
                if(mapYearMonthToBankStatement.size() <> 0) 
                {
                    //assign the calculated values to the account 
                    opportunityObj.NDBs_Avg__c = avgNDB/mapYearMonthToBankStatement.size();
                    opportunityObj.NSFs_Avg__c = avgNSF/mapYearMonthToBankStatement.size();
                    opportunityObj.Average_Daily_Balance__c = avgMonthlyBalance/mapYearMonthToBankStatement.size();
                    opportunityObj.Gross_monthly_Sales__c = avgDepositsCurrencyMonthly/mapYearMonthToBankStatement.size();
                    opportunityObj.Avg_Number_Bank_Deposits__c = avgDepositsHoursMonthly/mapYearMonthToBankStatement.size();
                    opportunityListResult.add(opportunityObj);
                }
            }
            
            //if the list of account to updated is not empty 
            if(!opportunityListResult.isEmpty()) 
            {
                update opportunityListResult;
            }
        }
    }
    */
}