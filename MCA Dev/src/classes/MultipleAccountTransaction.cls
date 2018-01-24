public with sharing class MultipleAccountTransaction {

    //TransactionController_New baseContrllr = new TransactionController_New();
    public MultipleAccountTransaction()
    {
        
    }
    
    // method to fetch accounts with open Payables
    public static List<TransactionController_New.PayAccount> fetchAccountWithOpenPayablesFromDB(
                                         List<TransactionController_New.PayAccount> pPayAccountLst,
                                                                           List<String> pStatusLst)
    {
        TransactionController_New.PayAccount payAccountObj;
        Decimal totalAmountDue = 0.00;
        for(Account accInstance : [SELECT Id, 
                                          Name,
                                          Type,
                                          (SELECT Id,
                                                  Name,
                                                  Bill_Amount_Due__c
                                           FROM Payables__r
                                           WHERE Status__c NOT IN :pStatusLst)
                                   FROM Account])
        {
            if(!accInstance.Payables__r.isEmpty())
            {
                totalAmountDue = 0.00;
                for(Payable__c payableInstance : accInstance.Payables__r)
                {
                    totalAmountDue += treatNullValue(payableInstance.Bill_Amount_Due__c);
                }
                payAccountObj = new TransactionController_New.PayAccount(accInstance, totalAmountDue, 
                                                                          accInstance.Payables__r);
                
                pPayAccountLst.add(payAccountObj);
                
            }
        }
        
        return pPayAccountLst;
    }
    
    // method to sort list of account wrapper.
    public static List<TransactionController_New.PayAccount> sortAccountList(List<TransactionController_New.PayAccount> pPayAccountLst,
                                                            String pFieldToSort, String pSortDirection,
                                                            String pFieldType)
    {
        system.debug('>>> pFieldToSort : '+pFieldToSort);
        object obj1;
        object obj2;
        for(Integer i= 0; i< pPayAccountLst.size(); i++)
        {
            for(Integer j = i+1; j < pPayAccountLst.size(); j++)
            {
                if(pFieldToSort.equalsIgnoreCase('PayNumber'))
                {
                    obj1 = pPayAccountLst[i].payableLst.size();
                    obj2 = pPayAccountLst[j].payableLst.size(); 
                }
                if(pFieldToSort.equalsIgnoreCase('AmountDue'))
                {
                    obj1 = pPayAccountLst[i].totalAmountDue;
                    obj2 = pPayAccountLst[j].totalAmountDue; 
                }
                if(pFieldToSort.equalsIgnoreCase('Name'))
                {
                    obj1 = pPayAccountLst[i].accObj.Name;
                    obj2 = pPayAccountLst[j].accObj.Name; 
                }
                if(pFieldToSort.equalsIgnoreCase('Type'))
                {
                    obj1 = pPayAccountLst[i].accObj.Type;
                    obj2 = pPayAccountLst[j].accObj.Type; 
                }
                if(pSortDirection.equalsIgnoreCase('ASC'))
                {
                    if(pFieldType.equalsIgnoreCase('Decimal'))
                    {
                        if(obj1 != null && obj2 != null)
                        {
                            if((Decimal)obj1 > (Decimal)obj2)
                            {
                                swapWrapper(pPayAccountLst, i, j);
                            }
                         }
                        else if(obj1 == null && obj2 != null)
                        {
                            swapWrapper(pPayAccountLst, i, j);
                        }
                   }
                   if(pFieldType.equalsIgnoreCase('String'))
                    {
                        system.debug('>>>1 sorting');
                        system.debug('>>> obj1: '+obj1);
                        system.debug('>>> obj2: '+obj2);
                        if(obj1 != null && obj2 != null)
                         {
                             if((String)obj1 > (String)obj2)
                             {
                                 swapWrapper(pPayAccountLst, i, j);
                             }
                         }
                         else if(obj1 == null && obj2 != null)
                         {
                             swapWrapper(pPayAccountLst, i, j);
                         }
                    }                
                }
                else
                {
                    if(pFieldType.equalsIgnoreCase('Decimal'))
                    {
                        if(obj1 != null && obj2 != null)
                        {
                            if((Decimal)obj1 < (Decimal)obj2)
                            {
                                swapWrapper(pPayAccountLst, i, j);
                            }
                         }
                        else if(obj1 == null && obj2 != null)
                        {
                            swapWrapper(pPayAccountLst, i, j);
                        }
                   }
                   if(pFieldType.equalsIgnoreCase('String'))
                    {
                        if(obj1 != null && obj2 != null)
                         {
                             if((String)obj1 < (String)obj2)
                             {
                                 swapWrapper(pPayAccountLst, i, j);
                             }
                         }
                         else if(obj1 == null && obj2 != null)
                         {
                             swapWrapper(pPayAccountLst, i, j);
                         }
                    }                  
                }
            }
        }
        system.debug('>>> pPayAccountLst : '+pPayAccountLst);
        return pPayAccountLst;
    }
    
    // method to swap the wrapper instances
     public static void swapWrapper(List<TransactionController_New.PayAccount> pLst, Integer iIndex, Integer jIndex)
     {
        TransactionController_New.PayAccount tempWraper = pLst[iIndex];
        pLst[iIndex] = pLst[jIndex];
        pLst[jIndex] = tempWraper;
        
     }
    
    public static Decimal treatNullValue(Decimal pValue)
    {
        if(pValue == null)
            return 0.00;
        else
            return pvalue;
    }
}