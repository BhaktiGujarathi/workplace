public with sharing class TransactionTestDataFactory {
    
    // method for Receivabel
    public static List<Receivable__c> getReceivableData(List<Receivable__c> pRecList, 
                                                        Id pAccountId,
                                                        Integer pCount)
    {
        pRecList = TestDataUtility.getReceivableRecords(pCount);
        for(Receivable__c recObj: pRecList)
        {
            recObj.Due_From_Account__c = pAccountId;
        }
        
        return pRecList;
    }
    
    // method for Account
    public static List<Account> getAccountData(List<Account> pAccList,
                                               Integer pCount)
    {
        pAccList = TestDataUtility.getAccountRecords(pCount);
        
        return pAccList;
    }
    
    // method for payable
    public static List<Payable__c> getPayableData(List<Payable__c> pPayList,
                                                  Id pAccountId,
                                                  Integer pCount)
    {
        pPayList = TestDataUtility.getPayableRecords(pCount);
        for(Payable__c payObj: pPayList)
        {
            payObj.Account__c = pAccountId;
        }
        
        return pPayList;
    }
    
    // method for transaction
    public static List<Transaction__c> getTransactionData(List<Transaction__c> pTransList,
                                                  Id pAccountId,
                                                  Id pRecordtypeId,
                                                  Integer pCount)
    {
        pTransList = TestDataUtility.getTransactionRecords(pCount);
        for(Transaction__c transObj: pTransList)
        {
            transObj.Account__c = pAccountId;
            transObj.RecordTypeId = pRecordtypeId;
        }
        
        return pTransList;
    }
}