public without sharing class CreditCardHandlerService {
    public void accountRollup(map<Id, Credit_Card__c> creditCardNewMap, map<Id, Credit_Card__c> creditCardOldMap){
        set<Id> setAccount = new set<Id>();// to  fetch  related account
        Map<String, List<Credit_Card__c>> mapYearMonthToCreditCard = new Map<String, List<Credit_Card__c>>();
        List<Credit_Card__c> bankStatmentList = new List<Credit_Card__c>();
        //decimal totalbankstatements = 0;
        decimal avgProcessedCurrencyMonthly=0;
        decimal avgTransactionHoursMonthly=0;
        decimal avgMonthlyBatches=0;
        
        list<Account> accountListResult = new list<Account>(); // list of account that will be updated
        // add to set for insert or update
        if (creditCardNewMap!= null){
            for(Credit_Card__c cardObj :creditCardNewMap.Values()){
                if(cardObj.Account__c != null){
                    setAccount.add(cardObj.Account__c); 
                }
            }
        }// add to set for update or delete 
        if (creditCardOldMap!= null){
            for(Credit_Card__c cardObj: creditCardOldMap.Values()){
                if(cardObj.Account__c != null){
                    setAccount.add(cardObj.Account__c); 
                }
            }
        }
        // fetching list of account to be updated
        list<Account> lstAcc=[Select a.Monthly_Batches_Avg__c,
                                    a.CC_transactions_Monthly_Avg__c,
                                    a.Monthly_CC_Avg_All__c,
                                    (Select Account__c,
                                            Total_Net_Processed_All__c,
                                            Number_of_Transactions_All__c,
                                            Batches__c,
                                            Year__c,
                                            Month__c
                                     From Credit_Cards1__r
                                     Where Include_in_average__c = true)
                               From Account a
                               Where a.Id IN : setAccount];
        if(!lstAcc.isEmpty()) {
            for(Account accountObj : lstAcc) {
                mapYearMonthToCreditCard.clear();
                avgProcessedCurrencyMonthly = 0;
                avgTransactionHoursMonthly = 0;
                avgMonthlyBatches = 0;
                if(!accountObj.Credit_Cards1__r.isEmpty()) {
                    for(Credit_Card__c cardObj : accountObj.Credit_Cards1__r) {
                        String yearMonthKey = String.ValueOf(cardObj.Year__c) + String.ValueOf(cardObj.Month__c);
                        if(!mapYearMonthToCreditCard.containsKey(yearMonthKey)) {
                            mapYearMonthToCreditCard.put(yearMonthKey, new List<Credit_Card__c>{cardObj});
                        }
                        else {
                            bankStatmentList.clear();
                            bankStatmentList = mapYearMonthToCreditCard.get(yearMonthKey);
                            bankStatmentList.add(cardObj);
                            mapYearMonthToCreditCard.put(yearMonthKey, bankStatmentList);
                        }
                        if(cardObj.Total_Net_Processed_All__c <> Null)
                            avgProcessedCurrencyMonthly += cardObj.Total_Net_Processed_All__c;
                        if(cardObj.Number_of_Transactions_All__c <> Null)
                            avgTransactionHoursMonthly += cardObj.Number_of_Transactions_All__c;
                        if(cardObj.Batches__c <> Null) 
                            avgMonthlyBatches += cardObj.Batches__c;
                    }
                }
                    accountObj.Monthly_Batches_Avg__c = avgMonthlyBatches/mapYearMonthToCreditCard.size();
                    accountObj.CC_transactions_Monthly_Avg__c = avgTransactionHoursMonthly/mapYearMonthToCreditCard.size();
                    accountObj.Monthly_CC_Avg_All__c = avgProcessedCurrencyMonthly/mapYearMonthToCreditCard.size();
                    accountListResult.add(accountObj);
            }
            update accountListResult;
        }
    }
}