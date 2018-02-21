/* Test class to calculate the Roll-up 
 * 
 * Revision History:
 *   
 * Version         Author                         Date                                     Description
 * 1.0             Shraddha P.                    28th Jan 2016                            Initial Draft
 */ 
 
@isTest
private class RollupServiceTest {
    static testMethod void calculateRollUpValidTest() {
        //create and insert Account record 
        Account objAcc = new Account();
        objAcc.Name = 'Test Account';
        insert objAcc;
        System.assertNotEquals(null, objAcc.Id);
        
        //create and insert Opportunity record
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test Opportunity';
        objOpp.StageName = 'Closed';
        objOpp.CloseDate = system.Today();
        insert objOpp;
        System.assertNotEquals(null, objOpp.Id);
        
        //insert Loan Balance record 1
        List<Loan_Balance__c> loanBalanceList1 = createLoanBalanceRecord(objOpp.Id, objAcc.Id, 10,5);
        //Loan_Balance__c objLoanBalance1 = createLoanBalanceRecord(objOpp.Id, objAcc.Id, 10,1);
        system.debug('** BEFORE INSERT ****'+loanBalanceList1);
        insert loanBalanceList1;
        //insert objLoanBalance1;
        system.debug('** AFTER INSERT ****'+loanBalanceList1[0].Id);
        system.debug('** AFTER INSERT ****'+loanBalanceList1[1].Id);
        system.debug('** AFTER INSERT ****'+loanBalanceList1[2].Id);
        System.assertNotEquals(null, loanBalanceList1[0].Id);
        System.assertNotEquals(null, loanBalanceList1[1].Id);
        System.assertNotEquals(null, loanBalanceList1[2].Id);
        System.assertEquals(6, loanBalanceList1.size());
        /*//insert Loan Balance record 2
        Loan_Balance__c objLoanBalance2 = createLoanBalanceRecord(objOpp.Id, objAcc.Id,20,2);
        insert objLoanBalance2;
        System.assertNotEquals(null, objLoanBalance2.Id);
        */
        
        //delete Loan Balance Record
        delete loanBalanceList1;
        List<Loan_Balance__c> deletedList = new List<Loan_Balance__c>([SELECT Id,Name FROM Loan_Balance__c]);
        system.debug('*** AFTER DELETE loanBalanceList1 ***'+deletedList);
        System.assertEquals(0, deletedList.size());

        //insert Merchant Payment record
        /*Merchant_Payment__c objMerchantPayment1 = createMerchantPaymentRecord(objOpp.Id,50);
        insert objMerchantPayment1;
        System.assertNotEquals(null, objMerchantPayment1.Id);

        //delete Merhant Payment Record
        delete objMerchantPayment1;
        List<Merchant_Payment__c> merchantPaymentList = new List<Merchant_Payment__c>([SELECT Id FROM Merchant_Payment__c]);
        system.debug('** AFTER DELETE merchantPaymentList****'+merchantPaymentList);
        System.assertEquals(0, merchantPaymentList.size());
        */
        //insert Syndication record 1
        Syndication__c objSyndication1 = createSyndicationRecord(objOpp.Id,1000,2000);
        insert objSyndication1;
        System.assertNotEquals(null, objSyndication1.Id);

        //insert Syndication record 2
        Syndication__c objSyndication2 = createSyndicationRecord(objOpp.Id,200.50,300.80);
        insert objSyndication2;
        System.assertNotEquals(null, objSyndication2.Id);

        //delete Syndication Record
        delete objSyndication2;
        List<Syndication__c> syndicationList = new List<Syndication__c>([SELECT Id FROM Syndication__c]);
        system.debug('** AFTER DELETE syndicationList****'+syndicationList);
        System.assertEquals(1, syndicationList.size());

        //insert Submission record
        Submission__c objSubmission1 = createSubmissionRecord(objOpp.Id);
        insert objSubmission1;
        System.assertNotEquals(null, objSubmission1.Id);

        //insert Offer record
        Offer__c objOffer1 = createOfferRecord(objSubmission1.Id,objOpp.Id);
        insert objOffer1;
        System.assertNotEquals(null, objOffer1.Id);

        //update Offer record
        objOffer1.Deal_Type__c = 'ACH';
        update objOffer1;
        System.assertEquals('ACH', objOffer1.Deal_Type__c);

        //delete Offer Record
        delete objOffer1;
        List<Offer__c> offerList = new List<Offer__c>([SELECT Id FROM Offer__c]);
        system.debug('** AFTER DELETE offerList****'+offerList);
        System.assertEquals(0, offerList.size());

        //insert Stips record
        Stips__c objStips1 = createStipsRecord(objOpp.Id);
        insert objStips1;
        System.assertNotEquals(null, objStips1.Id);

        //update Stips record
        objStips1.Name = 'Updated Stips';
        update objStips1;
        System.assertEquals('Updated Stips', objStips1.Name);

        //delete Stips Record
        delete objStips1;
        List<Stips__c> stipsList = new List<Stips__c>([SELECT Id FROM Stips__c]);
        system.debug('** AFTER DELETE stipsList****'+stipsList);
        System.assertEquals(0, stipsList.size());

        //delete Submission Record
        delete objSubmission1;
        List<Submission__c> submissionList = new List<Submission__c>([SELECT Id FROM Submission__c]);
        system.debug('** AFTER DELETE submissionList****'+submissionList);
        System.assertEquals(0, submissionList.size());
    }

    //create Loan Balance record 
    public static List<Loan_Balance__c> createLoanBalanceRecord(Id oppId, Id accId, decimal dailypayment, Integer numofrecords) {
        List<Loan_Balance__c> loanbalanceList = new List<Loan_Balance__c>();
        for(Integer index=0 ; index<=numofrecords ; index++ ) {
        Loan_Balance__c objLoanBalance = new Loan_Balance__c();
        objLoanBalance.Opportunity__c = oppId;
        objLoanBalance.Daily_Payment__c = dailypayment;
        objLoanBalance.Funder__c = accId;
        loanbalanceList.add(objLoanBalance);
        }
        return loanbalanceList;
    }

    //create Merchant Payment record
    /*public static Merchant_Payment__c createMerchantPaymentRecord(Id oppId,decimal paymentamount) {
        Merchant_Payment__c objMerchantPayment = new Merchant_Payment__c();
        objMerchantPayment.Opportunity__c = oppId;
        objMerchantPayment.Payment_Amt__c = paymentamount; 
        return objMerchantPayment;
    }*/
    
    //create Syndication__c record
    public static Syndication__c createSyndicationRecord(Id oppId,decimal syndicationamnt,decimal servicefee) {
        Syndication__c objSyndication = new Syndication__c();
        objSyndication.Opportunity__c = oppId;
        objSyndication.Syndication_Amt__c = syndicationamnt;
        objSyndication.Servicing_Fee__c = servicefee;
        return objSyndication;
    }

    //create Submission record
    public static Submission__c createSubmissionRecord(Id oppId) {
        Submission__c objSubmission = new Submission__c();
        objSubmission.Opportunity__c = oppId;
        return objSubmission;
    }

    //create Offer record
    public static Offer__c createOfferRecord(Id submissionId,Id oppId) {
        Offer__c objOffer = new Offer__c();
        objOffer.Opportunity__c = oppId;
        objOffer.Submission__c = submissionId;
        objOffer.Deal_Type__c = 'MCA';
        return objOffer;
    }

    //create Stips record
    public static Stips__c createStipsRecord(Id oppId) {
        Stips__c objStips = new Stips__c();
        objStips.Name = 'Test Stips';
        objStips.Opportunity__c = oppId;
        return objStips;
    }
}