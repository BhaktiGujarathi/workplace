public with sharing class GRIDLoanBalanceController {
    
    public Id OpportunityId;
    public List<Loan_Balance__c> loanBalLst;
    public Map<Id, Loan_Balance__c> loanBalFromDbMap;
    public List<LoanBalanceWrapper> loanBalWrapperLst;
    public String loanBalAggregateQueryStr = '';
    public String loanBalFieldsString = '';
    public Set<String> loanBalFieldsApiSet;
    public Boolean loanBalFirstRun;
    public Boolean loanBalIsNewBtnPress;
    public Boolean loanBalSingleErrorOnSave;
    public String loanBalFieldType;
    
    public static Map<String, Schema.SObjectType> globalMap;
    
    public List<Schema.FieldSetMember> loanBalFieldsetList                              {get; set;}
    public Set<string> loanBalFieldSumSet                                               {get; set;}
    public Map<String, Decimal> loanBalFieldToSumMap                                    {get; set;}
    public Integer loanBalRecordCount                                                   {get; set;}
    public Integer loanBalBlockSize                                                     {get; set;}
    public Integer loanBalOffsetsize                                                    {get; set;}
    public Integer loanBalIndexToRemove                                                 {get; set;}
    public string loanBalSortDirection                                                  {get; set;}
    public String loanBalSortExpression                                                 {get; set;}
    
    // constructor
    public GRIDLoanBalanceController() 
    {
        if(GRIDOnloadStaticVariable.flipLoanBalance())
        {
        
            opportunityId = Apexpages.currentPage().getParameters().get('id');
        
            loanBalBlockSize = (Integer)GRIDTabSetting__c.getValues('Loan Balance').PageSize__c;
            loanBalOffsetsize = 0;
    
            loanBalLst = new List<Loan_Balance__c>();
            loanBalFromDbMap = new Map<Id, Loan_Balance__c>();
            loanBalWrapperLst = new List<LoanBalanceWrapper>();
            loanBalFieldToSumMap = new Map<String, Decimal>();
            loanBalFieldSumSet = new Set<String>();
            loanBalFieldsApiSet = new Set<String>();
            loanBalFieldsetList = new List<Schema.FieldSetMember>();
            loanBalIsNewBtnPress = false;
            loanBalSortDirection = 'DESC';
            loanBalSortExpression = 'CreatedDate';
            loanBalFieldType = '';
        
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            Schema.DescribeSObjectResult loanBalDescbResult = globalMap.get('Loan_Balance__c').getDescribe();
            loanBalFieldsetList = loanBalDescbResult.FieldSets.getMap().get(GRIDTabSetting__c.getValues('Loan Balance').Fieldset_Name__c).getFields();
        
            loanBalAggregateQueryStr = buildLoanBalanceAggregateQuery(loanBalFieldsetList);
            loanBalFieldsApiSet = buildSetFromFieldListLoanBalance(loanBalFieldsetList);
            loanBalLst = getLoanBalanceFromDB(opportunityId, loanBalBlockSize, loanBalOffsetsize, loanBalFieldsApiSet, loanBalSortExpression, loanBalSortDirection);
            loanBalFirstRun = true;
        }
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListLoanBalance(List<Schema.FieldSetMember> pLoanBalFieldsetList)
    {
        String loanBalReferenceField;
        for(Schema.FieldSetMember fieldInstance :pLoanBalFieldsetList)
        {
            loanBalReferenceField = '';
            loanBalFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                if(fieldInstance.getfieldPath().contains('__c'))
                {
                    loanBalReferenceField += fieldInstance.getfieldPath().substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    loanBalReferenceField += fieldInstance.getfieldPath().substringBefore('Id')+'.Name';
                }
                loanBalFieldsApiSet.add(loanBalReferenceField);
            }
        }
        
        return loanBalFieldsApiSet;
    }
    
    // method to build dynamic query for SUM and COUNT
    public String buildLoanBalanceAggregateQuery(List<Schema.FieldSetMember> pLoanBalFieldsetList)
    {
        loanBalAggregateQueryStr = 'SELECT ';
        
        for(Schema.FieldSetMember fieldInstance :pLoanBalFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency') 
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double'))
            {
                loanBalAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                loanBalFieldSumSet.add(fieldInstance.getFieldPath());
                
            }
            //loanBalFieldsApiSet.add(fieldInstance.getfieldPath());
            loanBalFieldToSumMap.put(fieldInstance.getFieldPath(), 100);
        }
        
        loanBalAggregateQueryStr += 'COUNT(Id) loanBalCount FROM Loan_Balance__c Where  Opportunity__c = \''+opportunityId+'\'';
        
        return loanBalAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getLoanBalanceFieldSum(String pLoanBalAggregateQueryStr)
    {
        List<SObject> loanBalSumQueryResult = new List<SObject>();
        loanBalSumQueryResult = Database.query(pLoanBalAggregateQueryStr);
        
        for(String fieldName :loanBalFieldSumSet) 
        {
            if(loanBalSumQueryResult[0].get(fieldName) != null)
            {
                loanBalFieldToSumMap.put(fieldName, (Decimal)loanBalSumQueryResult[0].get(fieldName)); 
            }
        }
        loanBalRecordCount = (Integer)loanBalSumQueryResult[0].get('loanBalCount');
       
        return loanBalFieldToSumMap;
    }
    
    // method to get Loan Balances from DB
    public List<Loan_Balance__c> getLoanBalanceFromDB(Id pOpportunityId, Integer pLoanBalBlockSize, Integer pLoanBalOffsetSize, Set<String> pLoanBalFieldsApiSet,
                                                      String ploanBalSortExpression, String ploanBalSortDirection) 
    {
        //loanBalLst.clear();
        String loanBalQueryStr = '';
        loanBalFieldsString = DEWUtility.getStringfromSet(pLoanBalFieldsApiSet, null);
        loanBalQueryStr = 'Select ' +loanBalFieldsString+ 
                        ' From Loan_Balance__c Where Opportunity__c =:pOpportunityId ORDER BY '+ploanBalSortExpression+' '+ploanBalSortDirection+' NULLS LAST LIMIT '
                        +pLoanBalBlockSize+' Offset ' +pLoanBalOffsetSize;
        //loanBalLst = database.query(loanBalQueryStr);

        return database.query(loanBalQueryStr);
    }
    
    // method to get the wrapper list
    public List<LoanBalanceWrapper> getLoanBalWrapperLst() 
    {
        if(loanBalFirstRun)
        {
            loanBalWrapperLst = new List<LoanBalanceWrapper>();
            for (Integer i = 0; i < loanBalLst.size(); i++) 
            {
                loanBalWrapperLst.add(new LoanBalanceWrapper(loanBalLst[i], i, false));
            }
            loanBalFirstRun = false;
        }
        loanBalFieldToSumMap = getloanBalanceFieldSum(loanBalAggregateQueryStr);

        return loanBalWrapperLst;
    }
    
    // method to build a map from a list from DB
    public Map<Id, Loan_Balance__c> getLoanBalanceMapFromList(List<Loan_Balance__c> ploanBalLst) 
    {
        loanBalFromDbMap.clear();
        for(Loan_Balance__c loanBalInstance :ploanBalLst) 
        {
            loanBalFromDbMap.put(loanBalInstance.Id, loanBalInstance);
        }
        return loanBalFromDbMap;
    }
    
    // method to create new payables
    public void newLoanBalance() 
    {
        loanBalIsNewBtnPress = true;
        saveLoanBalances();
        loanBalIsNewBtnPress = false;
        
        if(!loanBalSingleErrorOnSave)
        {
             // to add new record only on first page
            if(loanBalOffsetsize <> 0) 
            {
                loanBalOffsetsize = 0;
                beginningLoanBalances();
            }
            
            Loan_Balance__c loanBalNew = new Loan_Balance__c(Opportunity__c = opportunityId);
            
             /*need to add at 0th index if list size > 0 else simple add will work*/
               if(loanBalWrapperLst.size() > 0 && loanBalLst.size() > 0)
               {
                 loanBalWrapperLst.add(0,new LoanBalanceWrapper(loanBalNew, null, true));
                 loanBalLst.add(0,loanBalNew);
               }
               else
               {
                 loanBalWrapperLst.add(new LoanBalanceWrapper(loanBalNew, null, true));
                 loanBalLst.add(loanBalNew);
               }
            // reindexing
            for(Integer i=0; i<loanBalWrapperLst.size(); i++)
            {
                loanBalWrapperLst[i].loanBalIndex = i;
            }
        }
    }
    
    // method to delete payables
    public void deleteLoanBalance()
    {
        if(loanBalWrapperLst[loanBalIndexToRemove].loanBal.Id != null) 
         {
            try
            {
                delete loanBalWrapperLst[loanBalIndexToRemove].loanBal;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
         
         loanBalLst.remove(loanBalIndexToRemove);
         loanBalWrapperLst.remove(loanBalIndexToRemove);
         
          //re-indexing
         for(Integer i=0;i<loanBalWrapperLst.size();i++)
         {
            loanBalWrapperLst[i].loanBalIndex = i;
         }
        // refreshLoanBalances();
    }
    
    // method to cave payable
    public void saveLoanBalances()
    {
        String loanBalMsgStr = '';
        loanBalSingleErrorOnSave = false;
        Boolean loanBalIsUpdated = false;
        List<Loan_Balance__c> loanBalListToUpdate = new List<Loan_Balance__c>();
        Map<Integer, Integer> loanBalErrorToWraperIndexMap = new map<Integer, Integer>();
        
        List<Loan_Balance__c> loanBalTempLst = getLoanBalanceFromDB(opportunityId, loanBalBlockSize, loanBalOffsetsize, loanBalFieldsApiSet, loanBalSortExpression, loanBalSortDirection);
        loanBalFromDBMap = getloanBalanceMapFromList(loanBalTempLst);
        
        for(LoanBalanceWrapper loanBalWraperInstance :loanBalWrapperLst) 
        {
            Loan_Balance__c loanBalDBObj = loanBalFromDBMap.get(loanBalWraperInstance.LoanBal.Id);
            if(loanBalDBObj != null)
            {
                loanBalIsUpdated = false;
                for(String loanBalFieldInstance :loanBalFieldsApiSet)
                {
                    if(!loanBalFieldInstance.contains('__r.Name')) 
                    {
                        loanBalIsUpdated  = loanBalIsUpdated ||(loanBalWraperInstance.LoanBal.get(loanBalFieldInstance) != loanBalDBObj.get(loanBalFieldInstance));
                    }
                }
            }
            else
            {
                if(!loanBalIsNewBtnPress)
                {
                    loanBalIsUpdated = true;
                }
            }
            if(loanBalIsUpdated)
            {
                loanBalListToUpdate.add(loanBalWraperInstance.LoanBal);
                loanBalErrorToWraperIndexMap.put(loanBalListToUpdate.size()-1, loanBalWraperInstance.loanBalIndex);
            }
            loanBalWraperInstance.loanBalEdit = false;
        }

        try
        {
            if(loanBalListToUpdate != null && loanBalListToUpdate.size() >0)
            {
                List<Database.upsertResult> results = Database.upsert(loanBalListToUpdate, false);
                for (Integer i =0; i < results.size(); i++) 
                {
                    if (!results[i].isSuccess())
                    {
                        for (Database.Error err : results[i].getErrors())
                        {
                              //+1 is added for Display on VF page only  
                              loanBalMsgStr = loanBalMsgStr + 'Error Record '+(loanBalErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!loanBalMsgStr.contains('insufficient access rights on object id'))
                        {
                            loanBalWrapperLst[loanBalErrorToWraperIndexMap.get(i)].loanBalEdit = true; 
                            //note on insuffivient privilage
                            loanBalSingleErrorOnSave = true;
                        }
                    }
                    /*else
                    {
                         loanBalWrapperLst[loanBalErrorToWraperIndexMap.get(i)].loanBalEdit = false;
                    }*/
                }
                if(loanBalSingleErrorOnSave == false && !loanBalIsNewBtnPress)
                {
                  loanBalLst = getLoanBalanceFromDB(opportunityId, loanBalBlockSize, loanBalOffsetsize, loanBalFieldsApiSet, loanBalSortExpression, loanBalSortDirection);
                  loanBalFieldToSumMap = getLoanBalanceFieldSum(loanBalAggregateQueryStr);
                  loanBalFirstRun = true;
                }
                if(String.isNotBlank(loanBalMsgStr)) 
                {
                       ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, loanBalMsgStr));
                }
            }
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             loanBalFirstRun = false;
        }
    }
    
    // method to edit all commissions
    public void editAllLoanBalances()
    {
        loanBalFirstRun = false;
        for(Integer i=0; i< loanBalWrapperLst.size(); i++) 
        {
            loanBalWrapperLst[i].loanBalEdit = true;
        }
    }
    
    // method to refresh
    public void refreshLoanBalances() 
    {
        loanBalLst = getLoanBalanceFromDB(opportunityId, loanBalBlockSize, loanBalOffsetsize, loanBalFieldsApiSet, loanBalSortExpression, loanBalSortDirection);
        loanBalFirstRun = true;
    }
    
    //method for the first page of list to be displayed
    public void beginningLoanBalances() 
    {
        saveLoanBalances();
        if(!loanBalSingleErrorOnSave)
        {
            loanBalOffsetsize = 0;
            loanBalLst = getLoanBalanceFromDB(opportunityId, loanBalBlockSize, loanBalOffsetsize, loanBalFieldsApiSet, loanBalSortExpression, loanBalSortDirection);
            loanBalFirstRun = true;
        }
    }
    
    //method for previous page of list to be displayed
    public void previousLoanBalances() 
    {
        saveLoanBalances();
        if (!loanBalSingleErrorOnSave && loanBalBlockSize <= loanBalOffsetsize)
        {
            loanBalOffsetsize = loanBalOffsetsize - loanBalBlockSize;
            loanBalLst = getLoanBalanceFromDB(opportunityId, loanBalBlockSize, loanBalOffsetsize, loanBalFieldsApiSet, loanBalSortExpression, loanBalSortDirection);
            loanBalFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void nextLoanBalances() 
    {    
        saveLoanBalances();
        if (!loanBalSingleErrorOnSave && loanBalOffsetsize <= loanBalRecordCount) 
        {
            loanBalOffsetsize = loanBalOffsetsize + loanBalBlockSize;
            loanBalLst = getLoanBalanceFromDB(opportunityId, loanBalBlockSize, loanBalOffsetsize, loanBalFieldsApiSet, loanBalSortExpression, loanBalSortDirection);
            loanBalFirstRun = true;
        }
    }
    
    //method for last page of list to be displayed
    public void endLoanBalances() 
    {
        saveLoanBalances();
        if(!loanBalSingleErrorOnSave && math.mod(loanBalRecordCount , loanBalBlockSize) == 0){
            loanBalOffsetsize = loanBalBlockSize * ((loanBalRecordCount/loanBalBlockSize)-1);
        } else if (!loanBalSingleErrorOnSave && math.mod(loanBalRecordCount , loanBalBlockSize) != 0){
            loanBalOffsetsize = loanBalBlockSize * ((loanBalRecordCount/loanBalBlockSize));
        }
        loanBalLst = getLoanBalanceFromDB(opportunityId, loanBalBlockSize, loanBalOffsetsize, loanBalFieldsApiSet, loanBalSortExpression, loanBalSortDirection);
        loanBalFirstRun = true;
    }
    
    //method to sort list of offers
    public void sortLoanBalances()
    {
            string loanBalReferenceFieldName = '';
            loanBalFieldType = Apexpages.currentPage().getParameters().get('loanBalTypeParam');
            if(loanBalFieldType.equalsIgnoreCase('REFERENCE'))
            {
                if(loanBalSortExpression.contains('__c'))
                {
                    loanBalReferenceFieldName += loanBalSortExpression.substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    loanBalReferenceFieldName += loanBalSortExpression.substringBefore('Id')+'.Name';
                }
                loanBalSortExpression = string.valueOf(loanBalReferenceFieldName);
            }
            refreshLoanBalances();
    }
    
    // wrapper for loanBalances
    public class LoanBalanceWrapper
    {
        public Loan_Balance__c LoanBal                                                   {get;set;}
        public Integer loanBalIndex                                                      {get;set;}
        public Boolean loanBalEdit                                                       {get;set;}
        public LoanBalanceWrapper(Loan_Balance__c loanBalInstance, Integer pLoanBalIndex, Boolean pLoanBalEdit) {
            LoanBal = loanBalInstance;
            loanBalIndex = pLoanBalIndex;
            loanBalEdit = pLoanBalEdit;
        }
    }
    
}