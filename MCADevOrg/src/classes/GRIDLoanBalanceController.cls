/**
 *  This class is a helper class for setting default values
 *
 *  Version     Author                      Date(DD/MM/YYYY)            Description
 *  1.0                                                                 Initial draft[]
 *  1.1         Ajinkya Hingne              17/10/2016                  Show default vals when creating new record
 */

global with sharing class GRIDLoanBalanceController {
    //Constant Variable
    private static final String ERROR_MSG = 'Please complete required fields and click on quick save before creating loan balance, credit cards and bank statements records.';
    public String OpportunityId;
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
    public Boolean loanBalEditAll;
    
    public static Map<String, Schema.SObjectType> globalMap;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    
    public List<Schema.FieldSetMember> loanBalFieldsetList                              {get; set;}
    public Set<string> loanBalFieldSumSet                                               {get; set;}
    public Map<String, Decimal> loanBalFieldToSumMap                                    {get; set;}
    public Integer loanBalRecordCount                                                   {get; set;}
    public Integer loanBalBlockSize                                                     {get; set;}
    public Integer loanBalOffsetsize                                                    {get; set;}
    public Integer loanBalIndexToRemove                                                 {get; set;}
    public string loanBalSortDirection                                                  {get; set;}
    public String loanBalSortExpression                                                 {get; set;}
    public boolean isDisable                                                            {get; set;}
    public String loanBalSortExprFieldApi                                               {get; set;}
    public Boolean loanBalIsRefrenceField                                               {get; set;}
    public String  loanBalRefrenceFieldLabel                                            {get; set;}
    // Editall Attribute
    public Boolean loanBalEditAllFlag                                                   {get; set;}
    // boolean to handle save success message on navigation
    public Boolean loanBalPageNavigated;
    
    // constructor
    public GRIDLoanBalanceController() 
    {
        if(GRIDOnloadStaticVariable.flipLoanBalance())
        {
            isDisable = false;
            opportunityId = Apexpages.currentPage().getParameters().get('id');
            if(opportunityId == null || opportunityId == '') {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, ERROR_MSG));
                isDisable = true;
            }
            
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
            
            loanBalBlockSize = (Integer)customMetaDataSettingMap.get('Loan_Balances').PageSize__c;
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
            loanBalEditAll = false;
            loanBalPageNavigated = false;
        
            Schema.DescribeSObjectResult loanBalDescbResult = globalMap.get(customMetaDataSettingMap.get('Loan_Balances').Object_API_Name__c).getDescribe();
            loanBalFieldsetList = loanBalDescbResult.FieldSets.getMap().get(customMetaDataSettingMap.get('Loan_Balances').Fieldset_Name__c).getFields();
            
            GRIDUtility.ReferenceFieldWrapper refWrap = new GRIDUtility.ReferenceFieldWrapper(loanBalFieldsetList, ' ', false);
            refWrap = GRIDUtility.isReferenceFieldPresent(refWrap);
            loanBalIsRefrenceField = refWrap.isReferenceField;
            loanBalRefrenceFieldLabel = refWrap.refrenceFieldLabel;
            if(!loanBalIsRefrenceField) 
            {
                loanBalAggregateQueryStr = buildLoanBalanceAggregateQuery(loanBalFieldsetList);
                loanBalFieldToSumMap = getloanBalanceFieldSum(loanBalAggregateQueryStr);
                loanBalFieldsApiSet = buildSetFromFieldListLoanBalance(loanBalFieldsetList);
                if(opportunityId != null && opportunityId != '')
                loanBalLst = getLoanBalanceFromDB(opportunityId, loanBalBlockSize, loanBalOffsetsize, loanBalFieldsApiSet, loanBalSortExpression, loanBalSortDirection);
                loanBalFirstRun = true;
            }
           
        }
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListLoanBalance(List<Schema.FieldSetMember> pLoanBalFieldsetList)
    {
        String loanBalReferenceField;
        for(Schema.FieldSetMember fieldInstance :pLoanBalFieldsetList)
        {
            
            loanBalFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                loanBalReferenceField = '';
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
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
            {
                loanBalAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                loanBalFieldSumSet.add(fieldInstance.getFieldPath());
                
            }
            //loanBalFieldsApiSet.add(fieldInstance.getfieldPath());
            loanBalFieldToSumMap.put(fieldInstance.getFieldPath(), -999.999);
        }
        
        loanBalAggregateQueryStr += 'COUNT(Id) loanBalCount FROM Loan_Balance__c Where  Opportunity__c = \''+opportunityId+'\'';
        
        return loanBalAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getLoanBalanceFieldSum(String pLoanBalAggregateQueryStr)
    {
        
        if(opportunityId <> null && opportunityId <> ''){
            List<SObject> loanBalSumQueryResult = new List<SObject>();
            loanBalSumQueryResult = Database.query(pLoanBalAggregateQueryStr);
            
            for(String fieldName :loanBalFieldSumSet) 
            {
                loanBalFieldToSumMap.put(fieldName,0);
                if(loanBalSumQueryResult[0].get(fieldName) != null)
                {
                    loanBalFieldToSumMap.put(fieldName, (Decimal)loanBalSumQueryResult[0].get(fieldName)); 
                }
            }
            loanBalRecordCount = (Integer)loanBalSumQueryResult[0].get('loanBalCount');
           
            return loanBalFieldToSumMap;
        }
        loanBalRecordCount = 0;
        return null;
    }
    
    // method to get Loan Balances from DB
    public List<Loan_Balance__c> getLoanBalanceFromDB(String pOpportunityId, Integer pLoanBalBlockSize, Integer pLoanBalOffsetSize, Set<String> pLoanBalFieldsApiSet,
                                                      String ploanBalSortExpression, String ploanBalSortDirection) 
    {
        system.debug(pOpportunityId );
        //system.debug(pOpportunityId <> null && pOpportunityId <> '');
        if(pOpportunityId <> null && pOpportunityId <> '') {
        system.debug('--->'+pOpportunityId );
            //loanBalLst.clear();
            String loanBalQueryStr = '';
            loanBalFieldsString = MCAUtility.getStringfromSet(pLoanBalFieldsApiSet, null);
            loanBalQueryStr = 'Select ' +loanBalFieldsString+ 
                            ' From Loan_Balance__c Where Opportunity__c =:pOpportunityId ORDER BY '+ploanBalSortExpression+' '+ploanBalSortDirection+' NULLS LAST LIMIT '
                            +pLoanBalBlockSize+' Offset ' +pLoanBalOffsetSize;
            //loanBalLst = database.query(loanBalQueryStr);
            return database.query(loanBalQueryStr);
        }
        return new List<Loan_Balance__c>();
    }
    
    // method to get the wrapper list
    public List<LoanBalanceWrapper> getLoanBalWrapperLst() 
    {
        if(loanBalFirstRun)
        {
            loanBalWrapperLst = new List<LoanBalanceWrapper>();
        }
        if(loanBalLst <> null && loanBalLst.size() > 0) {
            if(loanBalFirstRun)
            {
                //loanBalWrapperLst = new List<LoanBalanceWrapper>();
                for (Integer i = 0; i < loanBalLst.size(); i++) 
                {
                    loanBalWrapperLst.add(new LoanBalanceWrapper(loanBalLst[i], i, loanBalEditAllFlag));
                }
                loanBalFirstRun = false;
            }
        }
        //loanBalFieldToSumMap = getloanBalanceFieldSum(loanBalAggregateQueryStr);

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
        globalMap = GRIDOnloadStaticVariable.getGlobalMap();
        customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
        Schema.DescribeSObjectResult loanBalanceDescbResult = globalMap.get(customMetaDataSettingMap.get('Loan_Balances').Object_API_Name__c).getDescribe();
        loanBalIsNewBtnPress = true;
        if(!loanBalEditAll)
        {
            saveLoanBalances();
        }
        else
        {
            loanBalSingleErrorOnSave = false;
        }
        loanBalIsNewBtnPress = false;
        
        if(!loanBalSingleErrorOnSave)
        {
             // to add new record only on first page
            if(loanBalOffsetsize <> 0) 
            {
                loanBalOffsetsize = 0;
                beginningLoanBalances();
            }
            Loan_Balance__c loanBalNew = new Loan_Balance__c();
            DefaultValueHelper.populateValues(loanBalNew, loanBalFieldsetList, loanBalanceDescbResult);
            loanBalNew.Opportunity__c = opportunityId;
            
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
         if(loanBalWrapperLst.size() <= 0)
         {
             refreshLoanBalances();
         }
         loanBalFieldToSumMap = getLoanBalanceFieldSum(loanBalAggregateQueryStr);
    }
    
    // method to cave payable
    public void saveLoanBalances()
    {
        String loanBalMsgStr = '';
        String loanBalSuccessMsgStr ='';
        loanBalSingleErrorOnSave = false;
        Boolean loanBalIsUpdated = false;
        loanBalEditAll = false;
        
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
                    if(!loanBalFieldInstance.contains('.Name')) 
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
            loanBalWraperInstance.loanBalEdit = loanBalEditAllFlag;
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
                             String recordError = err.getMessage();
                             /*
                             if(recordError.contains('insufficient access rights on'))
                             {
                                 recordError = 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.';
                             }
                             else
                             {
                             
                                loanBalWrapperLst[loanBalErrorToWraperIndexMap.get(i)].loanBalEdit = true; 
                                
                             }*/
                             if(!recordError.contains('insufficient access rights on'))
                             {
                                loanBalWrapperLst[loanBalErrorToWraperIndexMap.get(i)].loanBalEdit = true;  
                             }
                             loanBalSingleErrorOnSave = true;
                             loanBalMsgStr = loanBalMsgStr + 'Error Record '+(loanBalErrorToWraperIndexMap.get(i)+1)+' : '+ recordError + '<br />'; 
                            
                        }
                    }
                    else if(results[i].isSuccess())
                    {
                         loanBalSuccessMsgStr = loanBalSuccessMsgStr+ 'Success Record '+(loanBalErrorToWraperIndexMap.get(i)+1)+' : '+ 'saved successfully!' + '<br />';
                         loanBalWrapperLst[loanBalErrorToWraperIndexMap.get(i)].loanBalEdit = loanBalEditAllFlag;
                    }
                }
                if(loanBalSingleErrorOnSave == false && !loanBalIsNewBtnPress)
                {
                  loanBalLst = getLoanBalanceFromDB(opportunityId, loanBalBlockSize, loanBalOffsetsize, loanBalFieldsApiSet, loanBalSortExpression, loanBalSortDirection);
                  loanBalFieldToSumMap = getLoanBalanceFieldSum(loanBalAggregateQueryStr);
                  loanBalFirstRun = true;
                }
                if(String.isNotBlank(loanBalMsgStr) || String.isNotBlank(loanBalSuccessMsgStr)) 
                {
                    if(loanBalPageNavigated)
                    {
                        //loanBalPageNavigated = false;
                        loanBalSuccessMsgStr = 'Last changes made by you were saved successfully!';
                    }
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, loanBalMsgStr +'<br/>'+ loanBalSuccessMsgStr));
                }
            }
            loanBalPageNavigated = false;
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
        loanBalEditAll = true;
        for(Integer i=0; i< loanBalWrapperLst.size(); i++) 
        {
            loanBalWrapperLst[i].loanBalEdit = true;
        }
        
    }
    
    // method to refresh
    public void refreshLoanBalances() 
    {
        loanBalLst = getLoanBalanceFromDB(opportunityId, loanBalBlockSize, loanBalOffsetsize, loanBalFieldsApiSet, loanBalSortExpression, loanBalSortDirection);
        loanBalFieldToSumMap = getloanBalanceFieldSum(loanBalAggregateQueryStr);
        loanBalFirstRun = true;
    }
    
    //method for the first page of list to be displayed
    public void beginningLoanBalances() 
    {
        loanBalPageNavigated = true;
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
        loanBalPageNavigated = true;
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
        loanBalPageNavigated = true;
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
        loanBalPageNavigated = true;
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