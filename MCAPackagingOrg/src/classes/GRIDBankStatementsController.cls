global with sharing class GRIDBankStatementsController {
    //Constant Variable
    private static final String ERROR_MSG = 'Please complete required fields and click on quick save before creating loan balance, credit cards and bank statements records.';
    public String OpportunityId;
    public List<Bank_Account__c> bankStmntLst;
    public Map<Id, Bank_Account__c> bankStmntFromDbMap;
    public List<BankStatementWrapper> bankStmntWrapperLst;
    public String bankStmntAggregateQueryStr = '';
    public String bankStmntFieldsString = '';
    public Set<String> bankStmntFieldsApiSet;
    public Boolean bankStmntFirstRun;
    public Boolean bankStmntIsNewBtnPress;
    public Boolean bankStmntSingleErrorOnSave;
    public Integer bankStmntNmbrOfRecordsToCreate;
    public String bankStmntFieldType;
    
    public static Map<String, Schema.SObjectType> globalMap;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    
    public List<Schema.FieldSetMember> bankStmntFieldsetList                            {get; set;}
    public Set<string> bankStmntFieldSumSet                                             {get; set;}
    public Map<String, Decimal> bankStmntFieldToSumMap                                  {get; set;}
    public Integer bankStmntRecordCount                                                 {get; set;}
    public Integer bankStmntBlockSize                                                   {get; set;}
    public Integer bankStmntOffsetsize                                                  {get; set;}
    public Integer bankStmntIndexToRemove                                               {get; set;}
    public string bankStmntSortDirection                                                {get; set;}
    public String bankStmntSortExpression                                               {get; set;}
    public boolean isDisable                                                            {get; set;}
    public Boolean bankStmntEditAll;
    public String bankStmntSortExprFieldApi                                             {get; set;}
    public Boolean bankStmntIsRefrenceField                                             {get; set;}
    public String bankStmntRefrenceFieldLabel                                           {get; set;}
    // Editall Attribute
    public Boolean bankStmntEditAllFlag                                                 {get; set;}
    // boolean to handle save success message on navigation
    public Boolean bankStmntPageNavigated;
    
    // constructor
    public GRIDBankStatementsController() 
    {
        if(GRIDOnloadStaticVariable.flipBankStatement())
        {
            isDisable = false;
            opportunityId = Apexpages.currentPage().getParameters().get('id');
            if(opportunityId == null || opportunityId == '') {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, ERROR_MSG));
                isDisable = true;
            }
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
            
            bankStmntBlockSize = (Integer)customMetaDataSettingMap.get('Bank_Statements').PageSize__c;
            bankStmntOffsetsize = 0;

            bankStmntLst = new List<Bank_Account__c>();
            bankStmntFromDbMap = new Map<Id, Bank_Account__c>();
            bankStmntWrapperLst = new List<BankStatementWrapper>();
            bankStmntFieldToSumMap = new Map<String, Decimal>();
            bankStmntFieldSumSet = new Set<String>();
            bankStmntFieldsApiSet = new Set<String>();
            bankStmntFieldsetList = new List<Schema.FieldSetMember>();
            bankStmntIsNewBtnPress = false;
            bankStmntSortDirection = 'DESC';
            bankStmntSortExpression = 'CreatedDate';
            bankStmntFieldType = '';
            bankStmntEditAll = false;
            bankStmntPageNavigated = false;
            
            bankStmntNmbrOfRecordsToCreate = Integer.valueOf(Label.GRIDBankStatementCreateCount);

            Schema.DescribeSObjectResult bankStmntDescbResult = globalMap.get(customMetaDataSettingMap.get('Bank_Statements').Object_API_Name__c).getDescribe();
            bankStmntFieldsetList = bankStmntDescbResult.FieldSets.getMap().get(customMetaDataSettingMap.get('Bank_Statements').Fieldset_Name__c).getFields();

            GRIDUtility.ReferenceFieldWrapper refWrap = new GRIDUtility.ReferenceFieldWrapper(bankStmntFieldsetList, ' ', false);
            refWrap = GRIDUtility.isReferenceFieldPresent(refWrap);
            bankStmntIsRefrenceField = refWrap.isReferenceField;
            bankStmntRefrenceFieldLabel = refWrap.refrenceFieldLabel;
            
            if(!bankStmntIsRefrenceField)
            {
                bankStmntAggregateQueryStr = buildBankStatementAggregateQuery(bankStmntFieldsetList);
                bankStmntFieldToSumMap = getBankStatementFieldSum(bankStmntAggregateQueryStr);
                bankStmntFieldsApiSet = buildSetFromFieldListBankStatement(bankStmntFieldsetList);
                if(opportunityId != null && opportunityId != '')
                    bankStmntLst = getBankStatementFromDB(opportunityId, bankStmntBlockSize, bankStmntOffsetsize, bankStmntFieldsApiSet, bankStmntSortExpression, bankStmntSortDirection);
                bankStmntFirstRun = true;
            }
        }
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListBankStatement(List<Schema.FieldSetMember> pBankStmntFieldsetList)
    {
        String bankStmntReferenceField;
        for(Schema.FieldSetMember fieldInstance :pBankStmntFieldsetList)
        {
            
            bankStmntFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                bankStmntReferenceField = '';
                if(fieldInstance.getfieldPath().contains('__c'))
                {
                    bankStmntReferenceField += fieldInstance.getfieldPath().substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    bankStmntReferenceField += fieldInstance.getfieldPath().substringBefore('Id')+'.Name';
                }
                bankStmntFieldsApiSet.add(bankStmntReferenceField);
            }
        }
        
        return bankStmntFieldsApiSet;
    }
    
    // method to build dynamic query for SUM and COUNT
    public String buildBankStatementAggregateQuery(List<Schema.FieldSetMember> pBankStmntFieldsetList)
    {
        bankStmntAggregateQueryStr = 'SELECT ';

        for(Schema.FieldSetMember fieldInstance :pBankStmntFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency') 
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
            {
                bankStmntAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                bankStmntFieldSumSet.add(fieldInstance.getFieldPath());
                
            }
            bankStmntFieldToSumMap.put(fieldInstance.getFieldPath(), -999.999);
        }
        bankStmntAggregateQueryStr= bankStmntAggregateQueryStr.removeEnd(', ');
        bankStmntAggregateQueryStr += ' FROM Bank_Account__c Where  Opportunity__c = \''+opportunityId+'\'AND Include_in_average__c = true GROUP BY Month__c, Year__c';
        //bankStmntAggregateQueryStr += 'COUNT(Id) bankStmntCount FROM Bank_Account__c Where  Opportunity__c = \''+opportunityId+'\'';
        
        return bankStmntAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getBankStatementFieldSum(String pBankStmntAggregateQueryStr)
    {
        if(opportunityId <> null && opportunityId <> '') {
            List<SObject> bankStmntSumQueryResult = new List<SObject>();
            List<SObject> bankStmntCountQueryResult = new List<SObject>();
            Map<String, Decimal> bankStmntFieldNameToSumMap = new Map<String, Decimal>();
            Decimal bankStmntFieldSum;
            Integer bankStmntCount = 0;
            bankStmntSumQueryResult = Database.query(pBankStmntAggregateQueryStr);
            
             for(String fieldName :bankStmntFieldSumSet)
            {
                
                bankStmntFieldSum = 0;
                for(Integer i = 0; i < bankStmntSumQueryResult.size(); i++)
                {
                    
                    if(bankStmntSumQueryResult[i].get(fieldName) != null)
                    {
                        if(!bankStmntFieldNameToSumMap.containsKey(fieldName))
                        {
                            bankStmntFieldNameToSumMap.put(fieldName,(Decimal)bankStmntSumQueryResult[i].get(fieldName));
                        }
                        else 
                        {
                            bankStmntFieldSum = bankStmntFieldNameToSumMap.get(fieldName);
                            bankStmntFieldSum  += (Decimal)bankStmntSumQueryResult[i].get(fieldName);
                            bankStmntFieldNameToSumMap.put(fieldName, bankStmntFieldSum);
                        }
                        
                    }

                }
            }
            
            for(String fieldName :bankStmntFieldSumSet) 
            {
                bankStmntFieldToSumMap.put(fieldName,0);
                if(bankStmntFieldNameToSumMap.get(fieldName) != null)
                {
                    bankStmntFieldToSumMap.put(fieldName, ((Decimal)bankStmntFieldNameToSumMap.get(fieldName)/bankStmntSumQueryResult.size())); 
                }
            }
            
           
            bankStmntCountQueryResult = database.query('Select Count(Id) bankStmntCount From Bank_Account__c Where Opportunity__c = \''+opportunityId+'\'');
            bankStmntRecordCount = (Integer)bankStmntCountQueryResult[0].get('bankStmntCount');
            
             
            return bankStmntFieldToSumMap;
        }
        bankStmntRecordCount = 0;
        return null;
    }
    
    // method to get Bank Statements from DB
    public List<Bank_Account__c> getBankStatementFromDB(String pOpportunityId, Integer pBankStmntBlockSize, Integer pBankStmntOffsetSize, Set<String> pBankStmntFieldsApiSet,
                                                        String pbankStmntSortExpression, String pbankStmntSortDirection) 
    {
        if(pOpportunityId <> null && pOpportunityId <> '') {
            String bankStmntQueryStr = '';
            bankStmntFieldsString = MCAUtility.getStringfromSet(pBankStmntFieldsApiSet, null);
            bankStmntQueryStr = 'Select ' +bankStmntFieldsString+ 
                            ' From Bank_Account__c Where Opportunity__c =:pOpportunityId ORDER BY '+pbankStmntSortExpression+' '+pbankStmntSortDirection+' NULLS LAST LIMIT '
                            +pBankStmntBlockSize+' Offset ' +pBankStmntOffsetSize;
    
            return database.query(bankStmntQueryStr);
        }
        return new List<Bank_Account__c>();
    }
    
    // method to get the wrapper list
    public List<BankStatementWrapper> getBankStmntWrapperLst() 
    {
        if(bankStmntFirstRun)
        {
            bankStmntWrapperLst = new List<BankStatementWrapper>();
        }
        if(bankStmntLst<> null && bankStmntLst.size() > 0 ) {
            if(bankStmntFirstRun)
            {
                //bankStmntWrapperLst = new List<BankStatementWrapper>();
                for (Integer i = 0; i < bankStmntLst.size(); i++) 
                {
                    bankStmntWrapperLst.add(new BankStatementWrapper(bankStmntLst[i], i, bankStmntEditAllFlag));
                }
                bankStmntFirstRun = false;
            }
        }
        //bankStmntFieldToSumMap = getBankStatementFieldSum(bankStmntAggregateQueryStr);

        return bankStmntWrapperLst;
    }
    
    // method to build a map from a list from DB
    public Map<Id, Bank_Account__c> getBankStatementMapFromList(List<Bank_Account__c> pBankStmntLst) 
    {
        bankStmntFromDbMap.clear();
        for(Bank_Account__c bankStmntInstance :pBankStmntLst) 
        {
            bankStmntFromDbMap.put(bankStmntInstance.Id, bankStmntInstance);
        }
        return bankStmntFromDbMap;
    }
    
    // method to create new payables
    public void newBankStatement() 
    {
        bankStmntIsNewBtnPress = true;
        if(!bankStmntEditAll)
        {
            saveBankStatements();
        }
        else
        {
            bankStmntSingleErrorOnSave = false;
        }
        bankStmntIsNewBtnPress = false;
        dateTime bankStmntMnth;
        String bankStmntMnthValue;
        
        if(!bankStmntSingleErrorOnSave) 
        {
            // to add new record only on first page
            if(bankStmntOffsetsize <> 0) 
            {
                bankStmntOffsetsize = 0;
                beginningBankStatements();
            }
            
            for(Integer i = bankStmntNmbrOfRecordsToCreate; i> 0; i--)
            {
                Bank_Account__c bankStmntNew;
                if(Label.GRIDBankStatementMonthAutomation.equalsIgnoreCase('true')) 
                {
                    Date bankStmntTodayDate = date.Today();
                    bankStmntMnth = bankStmntTodayDate.addMonths(-i);
                    bankStmntMnthValue = (bankStmntMnth.month() <10? '0'+bankStmntMnth.month()+' - '+bankStmntMnth.format('MMMM'):''+bankStmntMnth.month()+' - '+bankStmntMnth.format('MMMM'));
                    
                    bankStmntNew = new Bank_Account__c(Opportunity__c = opportunityId,
                                                       OwnerId = UserInfo.getUserId(),
                                                       Month__c = bankStmntMnthValue,
                                                       Year__c = String.valueOf(bankStmntMnth.Year()),
                                                       Include_in_average__c = true
                                                       );
                }
                else
                {
                    bankStmntNew = new Bank_Account__c(Opportunity__c = opportunityId,Include_in_average__c = true);
                }
                
                //need to add at 0th index if list size > 0 else simple add will work
                if(bankStmntWrapperLst.size() > 0 && bankStmntLst.size() > 0) 
                {
                    bankStmntWrapperLst.add(0,new BankStatementWrapper(bankStmntNew, null, true));
                    bankStmntLst.add(0, bankStmntNew);
                }
                else
                {
                    bankStmntWrapperLst.add(new BankStatementWrapper(bankStmntNew, null, true));
                    bankStmntLst.add(bankStmntNew);
                }
            }
            
            // reindexing
            for(Integer i = 0; i < bankStmntWrapperLst.size(); i++)
            {
                bankStmntWrapperLst[i].bankStmntIndex = i;
            }
        }
    }
    
    // method to delete payables
    public void deleteBankStatement()
    {
        if(bankStmntWrapperLst[bankStmntIndexToRemove].BankStmnt.Id != null) 
         {
            try
            {
                delete bankStmntWrapperLst[bankStmntIndexToRemove].BankStmnt;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
         
         bankStmntLst.remove(bankStmntIndexToRemove);
         bankStmntWrapperLst.remove(bankStmntIndexToRemove);
         
          //re-indexing
         for(Integer i=0;i<bankStmntWrapperLst.size();i++)
         {
            bankStmntWrapperLst[i].bankStmntIndex = i;
         }
         if(bankStmntWrapperLst.size() <= 0)
         {
             refreshBankStatements();
         }
         bankStmntFieldToSumMap = getBankStatementFieldSum(bankStmntAggregateQueryStr);
        
    }
    
    // method to cave payable
    public void saveBankStatements()
    {
        String bankStmntMsgStr = '';
        String bankStmntSuccessMsgStr ='';
        bankStmntSingleErrorOnSave = false;
        Boolean bankStmntIsUpdated = false;
        bankStmntEditAll = false;
        List<Bank_Account__c> bankStmntListToUpdate = new List<Bank_Account__c>();
        Map<Integer, Integer> bankStmntErrorToWraperIndexMap = new map<Integer, Integer>();
        
        List<Bank_Account__c> bankStmntTempLst = getBankStatementFromDB(opportunityId, bankStmntBlockSize, bankStmntOffsetsize, bankStmntFieldsApiSet, bankStmntSortExpression, bankStmntSortDirection);
        bankStmntFromDBMap = getBankStatementMapFromList(bankStmntTempLst);
        for(BankStatementWrapper bankStmntWraperInstance :bankStmntWrapperLst) 
        {
            Bank_Account__c bankStmntDBObj = bankStmntFromDBMap.get(bankStmntWraperInstance.BankStmnt.Id);
            if(bankStmntDBObj != null)
            {
                bankStmntIsUpdated = false;
                for(String bankStmntFieldInstance :bankStmntFieldsApiSet)
                {
                    if(!bankStmntFieldInstance.contains('.Name')) 
                    {
                        bankStmntIsUpdated  = bankStmntIsUpdated ||(bankStmntWraperInstance.BankStmnt.get(bankStmntFieldInstance) != bankStmntDBObj.get(bankStmntFieldInstance));
                    }
                }
            }
            else
            {
                if(!bankStmntIsNewBtnPress)
                {
                    bankStmntIsUpdated = true;
                }
            }
            if(bankStmntIsUpdated)
            {
                bankStmntListToUpdate.add(bankStmntWraperInstance.BankStmnt);
                bankStmntErrorToWraperIndexMap.put(bankStmntListToUpdate.size()-1, bankStmntWraperInstance.bankStmntIndex);
            }
            bankStmntWraperInstance.bankStmntEdit = bankStmntEditAllFlag;
        }

        try
        {
            if(bankStmntListToUpdate != null && bankStmntListToUpdate.size() >0)
            {
                List<Database.upsertResult> results = Database.upsert(bankStmntListToUpdate, false);
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
                             
                                  bankStmntWrapperLst[bankStmntErrorToWraperIndexMap.get(i)].bankStmntEdit = true; 
                                  
                             }*/
                              if(!recordError.contains('insufficient access rights on'))
                              {
                                  bankStmntWrapperLst[bankStmntErrorToWraperIndexMap.get(i)].bankStmntEdit = true; 
                              }
                              bankStmntSingleErrorOnSave = true;
                              bankStmntMsgStr = bankStmntMsgStr + 'Error Record '+(bankStmntErrorToWraperIndexMap.get(i)+1)+' : '+ recordError  + '<br />'; 
                        }
                        
                    }
                    else if(results[i].isSuccess())
                    {
                         bankStmntSuccessMsgStr = bankStmntSuccessMsgStr+ 'Success Record '+(bankStmntErrorToWraperIndexMap.get(i)+1)+' : '+ 'saved successfully!' + '<br />';
                         bankStmntWrapperLst[bankStmntErrorToWraperIndexMap.get(i)].bankStmntEdit = bankStmntEditAllFlag;
                    }
                }
                if(bankStmntSingleErrorOnSave == false && !bankStmntIsNewBtnPress)
                {
                  bankStmntLst = getBankStatementFromDB(opportunityId, bankStmntBlockSize, bankStmntOffsetsize, bankStmntFieldsApiSet, bankStmntSortExpression, bankStmntSortDirection);
                  bankStmntFieldToSumMap = getBankStatementFieldSum(bankStmntAggregateQueryStr);
                  bankStmntFirstRun = true;
                }
                if(String.isNotBlank(bankStmntMsgStr)  || String.isNotBlank(bankStmntSuccessMsgStr)) 
                {
                    if(bankStmntPageNavigated)
                    {
                        bankStmntPageNavigated = false;
                        bankStmntSuccessMsgStr = 'Last changes made by you were saved successfully!';
                    }
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, bankStmntMsgStr  +'<br/>'+ bankStmntSuccessMsgStr));
                }
            }
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             bankStmntFirstRun = false;
        }
    }
    
    // method to edit all commissions
    public void editAllBankStatements()
    {
        bankStmntFirstRun = false;
        bankStmntEditAll = true;
        for(Integer i=0; i< bankStmntWrapperLst.size(); i++) 
        {
            bankStmntWrapperLst[i].bankStmntEdit = true;
        }
        
    }
    
    // method to refresh
    public void refreshBankStatements()
    {
        bankStmntLst = getBankStatementFromDB(opportunityId, bankStmntBlockSize, bankStmntOffsetsize, bankStmntFieldsApiSet, bankStmntSortExpression, bankStmntSortDirection);
        bankStmntFieldToSumMap = getBankStatementFieldSum(bankStmntAggregateQueryStr);
        bankStmntFirstRun = true;
        system.debug('>>> bankStmntWrapperLst.size() : '+bankStmntWrapperLst.size());
    }
    
    //method for the first page of list to be displayed
    public void beginningBankStatements() 
    {
        bankStmntPageNavigated = true;
        saveBankStatements();
        if(!bankStmntSingleErrorOnSave)
        {
            bankStmntOffsetsize = 0;
            bankStmntLst = getBankStatementFromDB(opportunityId, bankStmntBlockSize, bankStmntOffsetsize, bankStmntFieldsApiSet, bankStmntSortExpression, bankStmntSortDirection);
            bankStmntFirstRun = true;
        }
    }
    
    //method for previous page of list to be displayed
    public void previousBankStatements() 
    {
        bankStmntPageNavigated = true;
        saveBankStatements();
        if(!bankStmntSingleErrorOnSave && bankStmntBlockSize <= bankStmntOffsetsize)
        {
            bankStmntOffsetsize = bankStmntOffsetsize - bankStmntBlockSize;
            bankStmntLst = getBankStatementFromDB(opportunityId, bankStmntBlockSize, bankStmntOffsetsize, bankStmntFieldsApiSet, bankStmntSortExpression, bankStmntSortDirection);
            bankStmntFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void nextBankStatements() 
    {
        bankStmntPageNavigated = true;
        saveBankStatements();
        if(!bankStmntSingleErrorOnSave && bankStmntOffsetsize <= bankStmntRecordCount) 
        {
            bankStmntOffsetsize = bankStmntOffsetsize + bankStmntBlockSize;
            bankStmntLst = getBankStatementFromDB(opportunityId, bankStmntBlockSize, bankStmntOffsetsize, bankStmntFieldsApiSet, bankStmntSortExpression, bankStmntSortDirection);
            bankStmntFirstRun = true;
        }
    }
    
    //method for last page of list to be displayed
    public void endBankStatements() 
    {
        bankStmntPageNavigated = true;
        saveBankStatements();
        if(!bankStmntSingleErrorOnSave && math.mod(bankStmntRecordCount , bankStmntBlockSize) == 0){
            bankStmntOffsetsize = bankStmntBlockSize * ((bankStmntRecordCount/bankStmntBlockSize)-1);
        } else if (math.mod(bankStmntRecordCount , bankStmntBlockSize) != 0){
            bankStmntOffsetsize = bankStmntBlockSize * ((bankStmntRecordCount/bankStmntBlockSize));
        }
        bankStmntLst = getBankStatementFromDB(opportunityId, bankStmntBlockSize, bankStmntOffsetsize, bankStmntFieldsApiSet, bankStmntSortExpression, bankStmntSortDirection);
        bankStmntFirstRun = true;
    }
    
    //method to sort list of offers
    public void sortBankStatements()
    {
            string bankStmntReferenceFieldName = '';
            bankStmntFieldType = Apexpages.currentPage().getParameters().get('bankStmntTypeParam');
            if(bankStmntFieldType.equalsIgnoreCase('REFERENCE'))
            {
                if(bankStmntSortExpression.contains('__c'))
                {
                    bankStmntReferenceFieldName += bankStmntSortExpression.substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    bankStmntReferenceFieldName += bankStmntSortExpression.substringBefore('Id')+'.Name';
                }
                bankStmntSortExpression = string.valueOf(bankStmntReferenceFieldName);
            }
            refreshBankStatements();
    }
    
    // wrapper for loanBalances
    public class BankStatementWrapper
    {
        public Bank_Account__c BankStmnt                                                 {get;set;}
        public Integer bankStmntIndex                                                    {get;set;}
        public Boolean bankStmntEdit                                                     {get;set;}
        public BankStatementWrapper(Bank_Account__c bankStmntInstance, Integer pBankStmntIndex, Boolean pBankStmntEdit) {
            BankStmnt = bankStmntInstance;
            bankStmntIndex = pBankStmntIndex;
            bankStmntEdit = pBankStmntEdit;
        }
    }
}