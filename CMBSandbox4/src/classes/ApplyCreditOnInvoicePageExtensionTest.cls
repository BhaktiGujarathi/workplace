@isTest
public with sharing class ApplyCreditOnInvoicePageExtensionTest
{
    static testmethod void validateStandardController() 
    {
        List<Account> accountList = TestUtility.getAccountRecords(1);
        insert accountList;
        
        List<Opportunity> opportunityList = TestUtility.getOpportunityRecords(1, accountList[0].Id);
        insert opportunityList;
        
        List<Contact> contactList = TestUtility.getContactRecords(1, accountList[0].Id);
        insert contactList;
        
        List<Invoice__c> invoiceList = TestUtility.getInvoiceRecords(1, accountList[0].Id, contactList[0].Id, opportunityList[0].id);
        insert invoiceList;
        
        List<Credit__c> creditList = TestUtility.insertCredit(5, accountList[0].Id);
        for(integer i=0; i<5; i++) {
            creditList[i].Total_Credit_Amount__c =100+i;
        }
        insert creditList;
        
        List<ApplyCreditOnInvoicePageExtension.CreditWraper> creditwrpperList = new List<ApplyCreditOnInvoicePageExtension.CreditWraper>();
        
        test.startTest();
        
            ApexPages.StandardController stdCntrllr = new ApexPages.StandardController(invoiceList[0]);
            ApplyCreditOnInvoicePageExtension customExtension = new ApplyCreditOnInvoicePageExtension(stdCntrllr);
        
            PageReference pageRef = Page.ApplyCreditOnInvoicePage;
            pageRef.getParameters().put('id', String.valueOf(invoiceList[0].Id));
            Test.setCurrentPage(pageRef);
            
            creditwrpperList =  customExtension.getCreditWraperList();
            creditwrpperList[0].isSelected = true;
            pageRef.getParameters().put('indexToCheck', '0');
            customExtension.checkboxValidation();
            customExtension.creditFlag = true;
            customExtension.createCreditLineItem();
            customExtension.creditLineItemObj.Hours_Credited__c = 100;
            customExtension.creditLineItemObj.Credit__c = creditList[0].Id;
            customExtension.onClickApply();            
            customExtension.cancelCreate();
        
        test.stopTest();
    }
    
    static testmethod void validateCheckboxValidation() 
    {
        List<Account> accountList = TestUtility.getAccountRecords(1);
        insert accountList;
        
        List<Opportunity> opportunityList = TestUtility.getOpportunityRecords(1, accountList[0].Id);
        insert opportunityList;
        
        List<Contact> contactList = TestUtility.getContactRecords(1, accountList[0].Id);
        insert contactList;
        
        List<Invoice__c> invoiceList = TestUtility.getInvoiceRecords(1, accountList[0].Id, contactList[0].Id, opportunityList[0].id);
        insert invoiceList;
        
        List<Credit__c> creditList = TestUtility.insertCredit(5, accountList[0].Id);
        for(integer i=0; i<5; i++) {
            creditList[i].Total_Credit_Amount__c =100+i;
        }
        insert creditList;
        
        List<ApplyCreditOnInvoicePageExtension.CreditWraper> creditwrpperList = new List<ApplyCreditOnInvoicePageExtension.CreditWraper>();
        
        test.startTest();
            ApexPages.StandardController stdCntrllr = new ApexPages.StandardController(invoiceList[0]);
            ApplyCreditOnInvoicePageExtension customExtension = new ApplyCreditOnInvoicePageExtension(stdCntrllr);
        
            PageReference pageRef = Page.ApplyCreditOnInvoicePage;
            pageRef.getParameters().put('id', String.valueOf(invoiceList[0].Id));
            Test.setCurrentPage(pageRef);
            
            creditwrpperList =  customExtension.getCreditWraperList();
            creditwrpperList[0].isSelected = true;
            pageRef.getParameters().put('indexToCheck', '0');
            customExtension.checkboxValidation();
            
            creditwrpperList[0].isSelected = false;
            pageRef.getParameters().put('indexToCheck', '0');
            customExtension.checkboxValidation();
            customExtension.refreshBlock();
            customExtension.backToInvoice();
        test.stopTest();
    }
    
    static testmethod void validateCreateCreditObj() 
    {
        List<Account> accountList = TestUtility.getAccountRecords(1);
        insert accountList;
        
        List<Opportunity> opportunityList = TestUtility.getOpportunityRecords(1, accountList[0].Id);
        insert opportunityList;
        
        List<Contact> contactList = TestUtility.getContactRecords(1, accountList[0].Id);
        insert contactList;
        
        List<Invoice__c> invoiceList = TestUtility.getInvoiceRecords(1, accountList[0].Id, contactList[0].Id, opportunityList[0].id);
        insert invoiceList;
        
        List<Credit__c> creditList = TestUtility.insertCredit(5, accountList[0].Id);
        for(integer i=0; i<5; i++) {
            creditList[i].Total_Credit_Amount__c =100+i;
        }
        insert creditList;
        
        List<ApplyCreditOnInvoicePageExtension.CreditWraper> creditwrpperList = new List<ApplyCreditOnInvoicePageExtension.CreditWraper>();
        
        test.startTest();
        
            ApexPages.StandardController stdCntrllr = new ApexPages.StandardController(invoiceList[0]);
            ApplyCreditOnInvoicePageExtension customExtension = new ApplyCreditOnInvoicePageExtension(stdCntrllr);
        
            PageReference pageRef = Page.ApplyCreditOnInvoicePage;
            pageRef.getParameters().put('id', String.valueOf(invoiceList[0].Id));
            Test.setCurrentPage(pageRef);
            
            creditwrpperList =  customExtension.getCreditWraperList();
            customExtension.createCreditLineItem();
            customExtension.creditLineItemObj.Hours_Credited__c = 100;
            customExtension.creditLineItemObj.Credit__c = creditList[0].Id;
            customExtension.onClickApply();
            customExtension.creditCreated = true;
            customExtension.assignCreditHoursAndAmount();
            customExtension.cancelCreate();
        
        test.stopTest();
    }   
}