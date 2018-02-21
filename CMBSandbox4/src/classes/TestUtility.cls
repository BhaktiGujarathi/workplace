/**
 *
 *  Description : Used to Create the data needed foe the test classes to test the functionality of 
 *                various classes.
 *
 *     Version         Author         Date(DD/MM/YYYY)           Decsrption
 *       1.0        Ashwini Singh        23/9/2015           Test the populating of the field on 
 *                                                           account with respect to the assciated 
 *                                                           Projects.
 *
 **/

public with sharing class TestUtility {

    public static List<Account> getAccountRecords(Integer recCount){
        List<Account> lstAccount = new List<Account>();
        for(Integer accCount = 1; accCount <= recCount; accCount++){
        
            lstAccount.add(new Account( 
                name='Account'+ accCount
            )
             );
            
        }// End For
        return lstAccount ;
    }//End getAccountRecords()
    
    public static List<Contact> getContactRecords(Integer recCount, Id pAccountId){
        List<Contact> lstContact = new List<Contact>();
        for(Integer accCount = 1; accCount <= recCount; accCount++){
        
            lstContact.add(new Contact( 
                                LastName='Contact'+ accCount
                                ,Contact_Type__c='Customer'
                                ,Tip_of_The_Week__c='Added - Active'
                                ,AccountId = pAccountId
                )
             );
            
        }// End For
        return lstContact ;
    }//End getContactRecords()
    
    public static List<Opportunity> getOpportunityRecords(Integer recCount,Id pAccountId){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(Integer accCount = 1; accCount <= recCount; accCount++){
        
            lstOpportunity.add(new Opportunity( 
                            name='Opportunity'+ accCount
                            ,accountid=pAccountId
                            ,CloseDate=date.today().addDays(5)
                            ,ForecastCategoryName='PipeLine'
                            ,StageName='Prospecting'
            )
             );
            
        }// End For
        return lstOpportunity ;
    }//End getOpportunityRecords()

    public static List<Invoice__c> getInvoiceRecords(Integer recCount, id accountID, id contactID, id opportunityID){
        List<Invoice__c> lstInvoice = new List<Invoice__c>();
        Integer days=30;
        for(Integer invoiceCount = 1; invoiceCount <= recCount; invoiceCount++){
         days=days+15;
            lstInvoice.add(new Invoice__c(Adjustment__c=10000
                                           ,Hours__c=2
                                           ,Rate__c=65
                                           ,Invoice_Type__c = 'Hours'
                                           ,Description__c='Description:invoice utility'
                                           ,Adjustments__c= 3
                                           ,Total_Commissions_Paid__c=10
                                           ,Date_Sent__c=date.today().addDays(-days)
                                           ,Account__c=accountID
                                           ,Billing_Contact__c=contactID
                                           ,Opportunity__c=opportunityID
             ));
            
        }// End For
        return lstInvoice;
    }//End getInvoiceRecords()
    
     public static List<Line_Item__c> getInvoiceLineItemRecords(Integer recCount, 
                                                                    Id opportunityId,Id InvoiceID, Id projectId){
        List<Line_Item__c> lstline = new List<Line_Item__c>();
        for(Integer accCount = 1; accCount <= recCount; accCount++){
        
            lstline.add(new Line_Item__c(
                                    Date__c=date.today().addDays(5)
                                    ,Opportunity__c=opportunityId
                                    ,Invoice__c=invoiceID
                                    ,Description__c='Description:invoice line item utility'
                                    ,Finish__c=date.today().addDays(4)
                                    ,Start__c=date.today()
                                    ,Credit_Hrs__c=10
                                    ,Credit_Reason__c='Deposit/PrePaid'
                                    ,Hours_Num__c=14
                                    ,isCredit_Checkbox__c=true
                                    ,Credit__c=123
                                    ,HarvestProject__c = projectId
             ));
        }// End For
        return lstline;
    }//End getInvoiceLineItemRecords()
 
    //TransactionLineCredit
    public static List<Transaction_Line_Credit__c> getTransactionLineCreditRecords(Integer recCount, 
                                                                    Id transactionId,Id InvoiceID){

        List<Transaction_Line_Credit__c> lstTransactionLine = new List<Transaction_Line_Credit__c>();
        for(Integer accCount = 1; accCount <= recCount; accCount++){

            lstTransactionLine.add(new Transaction_Line_Credit__c(
                                    Date__c=date.today().addDays(3)
                                    ,Transaction__c=transactionId
                                    ,Invoice__c=invoiceID
                                    ,Amount__c=500
             ));
            
        }// End For
        return lstTransactionLine;
    }//End getTransactionLineCredit()
    
     //Transaction
    public static List<Transaction__c> getTransactionRecords(Integer recCount,Id AccountID){

         List<Transaction__c> lstTransaction = new List<Transaction__c>();
         for(Integer accCount = 1; accCount <= recCount; accCount++){
        
            lstTransaction.add(new Transaction__c(
                                    Name='Transaction'
                                    ,Account__c=AccountID
                                    ,Amt_Non_Hourly__c=1000
                                    ,Bank_Depostied__c='Amex'
                                    ,Pmt_Method__c='Check'
                                    ,Type__c='Rev - Hourly'
                                    ,Date__c=date.today().addDays(3)
             ));
            
        }// End For
        return lstTransaction;
    }//End getTransaction()
    
    public static List<HarvestProject__c> getHarvestProjectRecords(Integer recCount, Id AccountID,
                                                            Id ContactId, Id OpportunityId) {
        List<HarvestProject__c> listProjects = new List<HarvestProject__c>();
        for(Integer i = 1; i < =  recCount; i++) {
            listProjects.add(new HarvestProject__c(
                                    Opportunity__c = OpportunityId,
                                    Account__c = AccountID,
                                    ClientProjectManager__c = ContactId,
                                    SyncStatus__c = 'Harvest Project Linked',
                                    ProjectType__c = 'New - Custom Development',
                                    Name = 'Project' + recCount,
                                    Archived__c=false,
                                    Estimated_Hours__c = 15.00,
                                    DateStarted__c = Date.Today(),
                                    Due_Date__c = Date.Today().addDays(30),
                                    ProjectHourlyRate__c = 50));
        }
        return listProjects;
    }
    
    
    public static List<HarvestTimeEntry__c> getHarvestTimeEntryRecords(Integer recCount, Id ProjectId,
                                                                      Id ContactId, Id AccountId) {
        List<HarvestTimeEntry__c> listTimeEntry = new List<HarvestTimeEntry__c>();
        for(Integer i = 1; i < = recCount; i++) {
            listTimeEntry.add(new HarvestTimeEntry__c(HarvestProject__c = ProjectId,
                                                    Developer_Name__c = ContactId,
                                                    Developer_Company__c = AccountId,
                                                    Date__c = date.Today(),
                                                    Duration__c = 8.00));
        }
        return listTimeEntry;
    }

 public static List<Commission__c> getCommissionRecords(Integer recCount,Id pAccountId,Id pOpportunityId,Id pInvoiceId){
        List<Commission__c> lstCommission = new List<Commission__c>();
        for(Integer comCount = 1; comCount <= recCount; comCount++){
        
            lstCommission.add(new Commission__c( 
                            name='Commission'+ comCount
                            ,Due_to__c=pAccountId
                            ,Invoice__c=pInvoiceId
                            ,Opportunity__c=pOpportunityId
                            ,Amount_Paid__c=1000
                            ,Status__c='Paid'
                            ,Type__c='Commission'
                            ,Date_Paid__c = System.Today()
                 )
            );
            lstCommission.add(new Commission__c( 
                            name='Commission'+ comCount
                            ,Due_to__c=pAccountId
                            ,Invoice__c=pInvoiceId
                            ,Opportunity__c=pOpportunityId
                            ,Amount_Paid__c=1000
                            ,Status__c='Paid'
                            ,Type__c='Override'
                            ,Date_Paid__c = system.Today()
                 )
            );
            
        }// End For
        return lstCommission ;
    }
    
    //Method will create dummy Harvest project Records.
    public static list<HarvestProject__c> insertHarvestProjects (Integer cnt,
                                                    Id opportunityId,
                                                    Id accountId,
                                                    Id contactId){
        list<HarvestProject__c> harvestProjectList = new list<HarvestProject__c>();
        for(Integer i=0;i<cnt;i++){
            HarvestProject__c prjct = new HarvestProject__c();
            prjct.Name = 'Test name';
            prjct.Account__c = accountId;
            prjct.Opportunity__c = opportunityId;
            prjct.ProjectType__c =  'Monthly Support';
            prjct.ProjectHourlyRate__c = 20;
            prjct.SyncStatus__c = 'Status Unknown';
            prjct.Archived__c = false;
            prjct.ClientProjectManager__c = contactId;
            harvestProjectList.add(prjct);
        }
        //insert harvestProjectList;
        return harvestProjectList;
    }
    
    // method to create estimate records
    public static list<Estimates__c> insertEstimates(Integer cnt, 
                                                           Id pOpportunityId,
                                                           Id pProjectId) {
       List<Estimates__c> estimateList = new List<Estimates__c>();
       for(Integer i=0;i<cnt;i++){   
           Estimates__c estmateObj = new Estimates__c();
           estmateObj.Date_Sent__c = system.Today() - i;
           estmateObj.Status__c = 'Open - Not Sent Yet';
           estmateObj.Name = 'TestEstimate' + i;
           estmateObj.Opportunity__c = pOpportunityId;
           estmateObj.Harvest_Projects__c = pProjectId;
           estimateList.add(estmateObj);
       }
       return estimateList;
    }
    
    // method to create credit records
    public static list<Credit__c> insertCredit(Integer cnt, 
                                                           Id accountId) {
       List<Credit__c> creditList = new List<Credit__c>();
       for(Integer i=0;i<cnt;i++){  
            Credit__c creditObj = new Credit__c();
            creditObj.Account__c = accountId;
            creditList.add(creditObj);
       }
       return creditList;
    }
    
    // method to create credit line item records
    public static list<Credit_Line_Item__c> insertCreditLineItem(Integer cnt, 
                                                           Id harvestProjectId,
                                                           Id creditId) {
       List<Credit_Line_Item__c> creditLineItemList = new List<Credit_Line_Item__c>();
       for(Integer i=0;i<cnt;i++){  
        Credit_Line_Item__c creditLineItemObj = new Credit_Line_Item__c();
        creditLineItemObj.Project__c = harvestProjectId;
        creditLineItemObj.Credit__c = creditId;
        creditLineItemObj.Credited_Date__c = date.today();
        creditLineItemObj.Credit_Reason__c = 'Deposit/PrePaid';
        creditLineItemObj.Hours_Credited__c = 10;
        creditLineItemList.add(creditLineItemObj);
       }
       return creditLineItemList;
    }
}