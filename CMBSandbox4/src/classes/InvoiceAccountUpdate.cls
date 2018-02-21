/*
* Version       Date             Author         Description
*...1.0                          Shraddha P     This method updates Account summary fields with sum of Invoice fields
                                                   1. Account Total $ Invoiced = sum of Invoice Amount
                                                   2. Account Hours Invoiced = sum of Invoice Hours
                                                   3. Total Paid Invoices = sum of Amount Paid
                                                   4. Total Invoice Credit Hours = Credit_Hours_2__c
                                                   5. Total Invoice Credit Amt $ = sum of Credit Hours($)
*   1.2         05/10/2015       Ashwini S      Modification on roll up for Invoice Credit Hours  & Invoice Credit Amt 
*/
 
public with sharing class InvoiceAccountUpdate {
  public InvoiceAccountUpdate(){}

  public void accountRollup(map<Id, Invoice__c> mapNewInvoice, map<Id, Invoice__c> mapOldInvoice){
      set<Id> setAccount = new set<Id>();// to get related unique accounts
      decimal totalInvoiced=0;
      decimal accountHourInvoiced=0;
      decimal totalPaidInvoiced=0;
      decimal invoicedCreditHours=0;
      decimal invoicedCreditAmount=0;
      list<Account> accountListResult = new list<Account>(); // list of account that will be updated
      if (mapNewInvoice!= null){
            for(Invoice__c invoice: mapNewInvoice.Values()){
                if(invoice.Account__c != null){
                    setAccount.add(invoice.Account__c); 
                }
            }
        }// in case of account change on update or delete
        if (mapOldInvoice!= null){
            for(Invoice__c invoice: mapOldInvoice.Values()){
                if(invoice.Account__c != null){
                    setAccount.add(invoice.Account__c); 
                }
            }
        }
        
        list<Account> lstAcc = [Select Id,
                                       Total_Paid_Invoices__c,
                                       Total_Invoiced__c,
                                       Total_Invoice_Credit_Hours__c,
                                       Total_Invoice_Credit_Amt__c,
                                       Hours_Invoiced__c,
                                       (Select Price_Conga__c,
                                               Total_Invoice_Hours__c,
                                               Sum_of_Credit__c,
                                               Credit_Hours_2__c,
                                               Total_Amount_Paid__c 
                                       From Invoices__r where isSent__c=true)
                                From Account 
                                Where Id IN : setAccount];
                                
        if(lstAcc != null && !lstAcc.isEmpty()){  
            for(Account objAcc: lstAcc){
                totalInvoiced=0;
                accountHourInvoiced=0;
                totalPaidInvoiced=0;
                invoicedCreditHours=0;
                invoicedCreditAmount=0;
                for(Invoice__c objinvoice : objAcc.Invoices__r){
                    totalInvoiced = totalInvoiced + decimalValue(objinvoice.Price_Conga__c);
                    accountHourInvoiced=accountHourInvoiced+decimalValue(objinvoice.Total_Invoice_Hours__c);
                    totalPaidInvoiced=totalPaidInvoiced+decimalValue(objinvoice.Total_Amount_Paid__c);
                    invoicedCreditHours=invoicedCreditHours+decimalValue(objinvoice.Credit_Hours_2__c);
                    invoicedCreditAmount=invoicedCreditAmount+decimalValue(objinvoice.Sum_of_Credit__c);
                }
                objAcc.Total_Invoiced__c=totalInvoiced;
                objAcc.Hours_Invoiced__c=accountHourInvoiced;
                objAcc.Total_Paid_Invoices__c=totalPaidInvoiced;
                objAcc.Total_Invoice_Credit_Hours__c=invoicedCreditHours;
                objAcc.Total_Invoice_Credit_Amt__c=invoicedCreditAmount;
                accountListResult.add(objAcc);
            }
        }
        if(!accountListResult.isEmpty()){
            update accountListResult;
        }
  }
  
  //to convert null value into decimal
  public decimal decimalValue(decimal decValue){
        return(decValue!=null?decValue:0);
  } 

}