public with sharing class ApplyCreditOnInvoicePageExtension { 
    
    public Invoice__c invoiceObj;
    public ApexPages.StandardController standardController;
    
    public List<Credit__c> creditAssociatedToParentAccountList;
    public List<CreditWraper> creditWraperList;
    public Id creditId;
    public String creditName;
    public String lineItemName;
    
    public Credit_Line_Item__c creditLineItemObj                                 {get; set;}
    public Credit__c creditObj                                                   {get; set;}
    public Boolean creditFlag                                                    {get; set;}
    public Boolean popupFlag                                                     {get; set;}
    public Boolean creditCreated                                                 {get; set;}
    
        
    public ApplyCreditOnInvoicePageExtension(ApexPages.StandardController stdCont) {
        standardController = stdCont;
        invoiceObj = (Invoice__c)stdCont.getRecord();
        
        creditAssociatedToParentAccountList = new List<Credit__c>();
        creditWraperList = new List<CreditWraper>();
        creditName = '';
        lineItemName = '';

        creditFlag = false;
        popupFlag = false;
        creditCreated = false;
    }
     
    // method to fetch related credit list from DB
    public List<Credit__c> fetchCreditAssociatedToParentAccountListFromDB()
    {
        creditAssociatedToParentAccountList.clear();
        invoiceObj = [Select Id, Name, Account__c
                      From Invoice__c
                      Where Id =:invoiceObj.Id];

        creditAssociatedToParentAccountList = [Select id, 
                                                      Name,
                                                      Account__c,
                                                      Total_Credit_Amount__c,
                                                      Total_Credit_Amount_Remaining__c,
                                                      Total_Credit_Hours__c,
                                                      Total_Credit_Hours_Remaining__c,
                                                      Reason__c,
                                                      Approval_Date__c,
                                                      Approved_by__r.Name,
                                                      Description__c
                                               From Credit__c
                                               Where Account__c =:invoiceObj.Account__c AND Open_Credit__c = TRUE];
                                      
        return creditAssociatedToParentAccountList;
    }
    
    // method to get wraperlist to be displayed on page
    public List<CreditWraper> getCreditWraperList()
    {
            if(creditWraperList == null || creditWraperList.isEmpty()) 
            {
                creditAssociatedToParentAccountList = fetchCreditAssociatedToParentAccountListFromDB();
                
                for(Integer i = 0; i < creditAssociatedToParentAccountList.size(); i++)
                {
                    creditWraperList.add(new CreditWraper(creditAssociatedToParentAccountList[i], i));
                }
            }

        return creditWraperList;   
    } 
    
    // method to select a credit and apply
    public void createCreditLineItem()
    {
        if(creditFlag)
        {
            for(CreditWraper wrapperInstance : creditWraperList)
            {
                if(wrapperInstance.isSelected)
                {
                    creditId = wrapperInstance.credit.Id;
                    creditName = wrapperInstance.credit.Name;
                }
            }
        }
        creditLineItemObj = new Credit_Line_Item__c();
        creditLineItemObj.Invoice__c = invoiceObj.Id;
        creditLineItemObj.Credit__c = creditId;
        popupFlag = true;
        creditCreated = false;
    }
    
    // method to create/ insert creditLineItem
    public PageReference onClickApply()
    {
        if(creditFlag)
        {
            insertLineItem();
            popupFlag = false;

        }
        
        else 
        {
            
            insertCredit();
            insertLineItem();
            popupFlag = false;
        }
        refreshBlock();
        return null;
    }
    
    
    public void insertLineItem() 
    {
        try 
        {
            insert creditLineItemObj;
            assignCreditHoursAndAmount();
            lineItemName = [SELECT Id, 
                                   Name
                            FROM Credit_Line_Item__c
                            WHERE Id=: creditLineItemObj.Id][0].Name;           
            ApexPages.addmessage(new ApexPages.message(apexPages.severity.INFO, 'CreditLine Item '+lineItemName+' created for '+creditName+'!'));
            creditWraperList.clear();
        }
        catch(Exception exObj)
        {
            ApexPages.addmessage(new ApexPages.message(apexPages.severity.FATAL, 'Error: '+exObj.getMessage()));
        }
    }
    
    public void assignCreditHoursAndAmount()
    {
        if(creditCreated)
        {
            if(creditLineItemObj.Hours_Credited__c != null)
            {
                creditObj.Total_Credit_Hours__c = creditLineItemObj.Hours_Credited__c;
            }
            else if(creditLineItemObj.Amount_Credited__c != null)
            {
                creditObj.Total_Credit_Amount__c = creditLineItemObj.Amount_Credited__c;
            }                   
            update creditObj; 
        }
    }
      
    // method to create a credit
    public void insertCredit() 
    {
        creditObj = new Credit__c();
        creditObj.Account__c = invoiceObj.Account__c;
        creditObj.Approval_Date__c = system.today();
        Id userId = userinfo.getuserid();
        creditObj.Approved_by__c = [SELECT Id, Name
                                      FROM Contact
                                      WHERE OwnerId = :userId][0].Id;
        try
        {
            insert creditObj;
            creditId = creditObj.Id;
            creditName = [SELECT id, Name 
                          FROM Credit__c
                          WHERE Id =:creditId][0].Name;
            creditLineItemObj.Credit__c = creditId;
            creditFlag = false;
            creditCreated = true;
            creditWraperList.clear();
            ApexPages.addmessage(new ApexPages.message(apexPages.severity.Info, 'Credit Record '+creditName+' Created!'));
        }
        catch(Exception exObj)
        {
            ApexPages.addmessage(new ApexPages.message(apexPages.severity.FATAL, 'Error: '+exObj.getMessage()));
        }
        
    }
    
    public Pagereference cancelCreate()
    {
        popupFlag = false;
        creditFlag = false;
        creditCreated = false;
        return null;
    }
    
    // method to validate that only one checkbox is checked at a time.
    public void checkboxValidation()
    {
        String indexToCheck = Apexpages.currentPage().getParameters().get('indexToCheck');
        if(creditWraperList[Integer.valueOf(indexToCheck)].isSelected) 
        {
            Integer checkboxCount = 0;            
            for(CreditWraper wrapperInstance :creditWraperList)
            {
                if(wrapperInstance.isSelected)
                {
                    checkboxCount ++;
                }
            }
            
            if(checkboxCount > 1)
            {
                creditWraperList[Integer.valueOf(indexToCheck)].isSelected = false;
                ApexPages.addmessage(new ApexPages.message(apexPages.severity.FATAL, 'Error: You can check only one checkbox at a time!'));
            }
            creditFlag = true;
        }
        else 
           {
               creditId = null;
               popupFlag = false;
               creditFlag = false;
               creditCreated = false;
               creditWraperList.clear();
           }
        
    }
    
    public void refreshBlock() {
        creditId = null;
        popupFlag = false;
        creditFlag = false;
        creditCreated = false;
        creditWraperList.clear();
    }
    
    public PageReference backToInvoice()
    {
        pagereference backToPage = new pagereference('/'+invoiceObj.Id);
        return backToPage;
    }
    
    public class CreditWraper 
    {
        public Credit__c credit                                           {get; set;}
        public Boolean isSelected                                         {get; set;}
        public Integer creditIndex                                        {get; set;}
        
        public CreditWraper(Credit__c pCredit, Integer pIndex) 
        {
            credit = pCredit;
            isSelected = false;
            creditIndex = pIndex;
        }
    }
     
}