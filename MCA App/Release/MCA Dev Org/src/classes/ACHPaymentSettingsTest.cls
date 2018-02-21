@isTest (seealldata=true)
public class ACHPaymentSettingsTest {
    
    /*public static testMethod void runACHPaymentSettingsTest() { 
        
        runACHPaymentSettings();
    }*/
    
    /*
    public static void runACHPaymentSettings() {
        
        Map<String, Payment_Setting__c> paymentsMap = new Map<String, Payment_Setting__c>();
        Map<String, Payment__c> transactionsMap = new Map<String, Payment__c>();
        Payment__c[] transactionList = new Payment__c[]{};
        
        Payment_Setting__c pay;
        pay = createPayment('Active', '0019000000wv7wL', '0069000000Qp8yM');
        paymentsMap.put(pay.Id, pay);
        
        pay = createPayment('Pause', '0019000001EW6jc', '0069000000SyWgB');
        paymentsMap.put(pay.Id, pay);
        
        pay = createPayment('Complete', '0019000001EW6ld', '0069000000SyWhd');
        paymentsMap.put(pay.Id, pay);
        
        pay = createPayment('New', '0019000000wv7wL', '0069000000Qp8yM');
        paymentsMap.put(pay.Id, pay);
        
        ACH_Batch__c batch = [select Id from ACH_Batch__c][0];
        Payment__c tran;
        
        
        Integer j = 0;
        for (Payment_Setting__c payment : paymentsMap.values()) {
            for (Integer i = 0; i < 2; i++) {
                tran = createTransaction(batch, j, 'Fee', 'Scheduled', payment.Id);
                transactionList.add(tran);
                
                tran = createTransaction(batch, j, 'Payment', 'Scheduled', payment.Id);
                transactionList.add(tran);
                j++;
                tran = createTransaction(batch, j, 'Fee', 'Pending', payment.Id);
                transactionList.add(tran);
                tran = createTransaction(batch, j, 'Payment', 'Pending', payment.Id);
                transactionList.add(tran);
                
                j++;
                tran = createTransaction(batch, j, 'Fee', 'Settled', payment.Id);
                
                transactionList.add(tran);
                tran = createTransaction(batch, j, 'Payment', 'Settled', payment.Id);
                
                transactionList.add(tran);
                
                /*tran = createTransaction(batch, i, 'Fee', 'Failed', payment.Id);
                tran.Error_Code__c = 'R04';
                tran.Error_Description__c = 'Invalid Account Number updated';
                transactionList.add(tran);
                tran = createTransaction(batch, i, 'Payment', 'Failed', payment.Id);
                tran.Error_Code__c = 'R04';
                tran.Error_Description__c = 'Invalid Account Number updated';
                transactionList.add(tran);
                */
                
        /*        j++;
                tran = createTransaction(batch, j + 3, 'Fee', 'Failed', payment.Id);
                tran.Error_Code__c = 'X03';
                tran.Error_Description__c = 'No Account updated';
                transactionList.add(tran);
                
                tran = createTransaction(batch, j + 6, 'Payment', 'Failed', payment.Id);
                tran.Error_Code__c = 'X03';
                tran.Error_Description__c = 'No Account updated';
                transactionList.add(tran);
                
                /*tran = createTransaction(batch, i, 'Fee', 'Failed', payment.Id);
                tran.Error_Code__c = 'X04';
                tran.Error_Description__c = 'Invalid Account Number';
                transactionList.add(tran);
                tran = createTransaction(batch, i, 'Payment', 'Failed', payment.Id);
                tran.Error_Code__c = 'X04';
                tran.Error_Description__c = 'Invalid Account Number';
                transactionList.add(tran);
                
                tran = createTransaction(batch, i, 'Fee', 'Failed', payment.Id);
                tran.Error_Code__c = 'R01';
                tran.Error_Description__c = 'Insufficient Funds';
                transactionList.add(tran);
                tran = createTransaction(batch, i, 'Payment', 'Failed', payment.Id);
                tran.Error_Code__c = 'R01';
                tran.Error_Description__c = 'Insufficient Funds';
                transactionList.add(tran);
                
                tran = createTransaction(batch, i, 'Fee', 'Failed', payment.Id);
                tran.Error_Code__c = 'X02';
                tran.Error_Description__c = 'Closed Account';
                transactionList.add(tran);
                tran = createTransaction(batch, i, 'Payment', 'Failed', payment.Id);
                tran.Error_Code__c = 'X02';
                tran.Error_Description__c = 'Closed Account';
                transactionList.add(tran);
                
                tran = createTransaction(batch, i, 'Fee', 'Failed', payment.Id);
                tran.Error_Code__c = 'R09';
                tran.Error_Description__c = 'Uncollected Funds';
                transactionList.add(tran);
                tran = createTransaction(batch, i, 'Payment', 'Failed', payment.Id);
                tran.Error_Code__c = 'R09';
                tran.Error_Description__c = 'Uncollected Funds';
                transactionList.add(tran);*/
                
         /*       j++;
                tran = createTransaction(batch, j + 9, 'Fee', 'Failed', payment.Id);
                tran.Error_Code__c = 'R02';
                tran.Error_Description__c = 'Closed Account';
                transactionList.add(tran);
                
                tran = createTransaction(batch, j + 12, 'Payment', 'Failed', payment.Id);
                tran.Error_Code__c = 'R02';
                tran.Error_Description__c = 'Closed Account';
                transactionList.add(tran);
                
                
                j++;
                tran = createTransaction(batch, j, 'Fee', 'Fees Applied', payment.Id);
                transactionList.add(tran);
                
                tran = createTransaction(batch, j, 'Payment', 'Fees Applied', payment.Id);
                transactionList.add(tran);
                
            }
        }
        
        insert transactionList;
        
        /*
        
        Payment__c[] tran = [SELECT ACH_Batch__c
                                          , Payment__c
                                          , Effective_Date__c
                                          , Error_Code__c
                                          , Error_Description__c
                                          , External_Transaction_ID__c
                                          , Payment_Method__c
                                          , Payment_Setting__c
                                          , Response_Code__c
                                          , Settlement_Id__c
                                          , Status__c
                                          , Transaction_Amount__c
                                          , Transaction_Type__c 
                                       FROM Payment__c
                                      WHERE Payment_Setting__c = :pay.Id]; 
                                      
                                      */
        
    //}
    
    /*private static Payment__c createTransaction(ACH_Batch__c batch, Integer i, String transactionType, String status, String paymentId) {
        Payment__c tran = new Payment__c();
        tran.ACH_Batch__c = batch.Id;
        Date d = date.parse('11/01/2014');
        tran.Effective_Date__c = d.addDays(i);
        tran.Payment_Method__c = 'ACH';
        tran.Payment_Setting__c = paymentId;
        tran.Status__c = status;
        
        if (transactionType == 'Fee') {
            tran.Transaction_Amount__c = 10;
        }
        else {
            tran.Transaction_Amount__c = 1000;
        }
        
        tran.Transaction_Type__c = transactionType;
        
        return tran;
    }
    
    private static Payment_Setting__c createPayment(String status, String accountId, String opportunityId) {
        
        Payment_Setting__c pay = new Payment_Setting__c();
        pay.Bank_Account_Number__c = '3434455';
        pay.Type_of_Account__c = 'Savings';
        pay.Bank_Name__c = 'Test';
        pay.Bank_Phone__c = '0987654321';
        pay.Bank_Routing_Number__c = '234234';
        pay.Intial_Repayment_Amount__c = 25000;
        pay.Payment_Amount__c = 25000;
        pay.Loan_Amount__c = 1000;
        pay.Payee_Account__c = accountId;
        pay.Next_Hit_Date__c = Date.today();
        pay.Payment_Frequency__c = 'Daily';
        pay.Payment_Method__c = 'ACH';
        pay.Signed_ACH_Form__c = true;
        pay.Opportunity__c = opportunityId;
        pay.Status__c = status;
        pay.Voided_Check_Received__c = true;
        
        insert pay;
        pay = [SELECT Bank_Account_Number__c
                    , Type_of_Account__c
                    , Bank_Address__c
                    , Bank_Name__c
                    , Bank_Phone__c
                    , Bank_Routing_Number__c
                    , Intial_Repayment_Amount__c
                    , Payment_Amount__c
                    , Last_Batch_Date__c
                    , Loan_Amount__c
                    , Next_Hit_Date__c
                    , Opportunity__c
                    , Payee_Account__c
                    , Payment_Frequency__c
                    , Payment_Method__c
                    , Signed_ACH_Form__c
                    , Status__c
                    , Voided_Check_Received__c 
                 FROM Payment_Setting__c 
                WHERE Id = :pay.Id];
                
         return pay;
        
    }*/
}