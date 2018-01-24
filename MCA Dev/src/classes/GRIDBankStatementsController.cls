/**
 *  This class is a helper class for setting default values
 *
 *  Version     Author                      Date(DD/MM/YYYY)            Description
 *  1.0                                                                 Initial draft[]
 *  1.1         Ajinkya Hingne              17/10/2016                  Show default vals when creating new record
 *  1.2         Merul Shah                  07/11/2016                  Added to display arrows
                                                                        for field function
 */

global with sharing class GRIDBankStatementsController {
    //Constant Variable
    private static final String ERROR_MSG = 'Please complete required fields and click on quick save before creating Open balance, credit cards and bank statements records.';
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
    public Opportunity opportunityObj                                                   {get; set;}
    public List<Schema.FieldSetMember> bankStmntFieldsetList                            {get; set;}
    public Set<String> bankStmntFieldSumSet                                             {get; set;}
    public Set<String> bankStmntCurrencyFields                                          {get; set;}
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
    //Editall Attribute
    public Boolean bankStmntEditAllFlag                                                 {get; set;}
    public Boolean displaySortingArrow                                                  {get; set;}
    public String fieldPathResult                                                       {get; set;}
    public String currencySymbolBnkStmnt                                                {get; set;}
    //boolean to handle save success message on navigation
    public Boolean bankStmntPageNavigated;

    // constructor
    public GRIDBankStatementsController()
    {
        if(GRIDOnloadStaticVariable.flipBankStatement())
        {
            isDisable = false;
            opportunityObj = new Opportunity();
            opportunityId = Apexpages.currentPage().getParameters().get('id');
             if(opportunityId == null || opportunityId == '')
             {
                isDisable = true;
             }
             else
             {
                opportunityObj = [SELECT AccountId
                                       , Id
                                       , Name
                                  FROM Opportunity
                                  WHERE Id =: opportunityId ];
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
            bankStmntCurrencyFields = new Set<String>();
            bankStmntFieldsApiSet = new Set<String>();
            bankStmntFieldsetList = new List<Schema.FieldSetMember>();
            bankStmntIsNewBtnPress = false;
            bankStmntSortDirection = 'DESC';
            bankStmntSortExpression = 'CreatedDate';
            currencySymbolBnkStmnt = MultiCurrencyHelper.getUserCurrencySymbol();
            bankStmntFieldType = '';
            bankStmntEditAll = false;
            bankStmntPageNavigated = false;
            displaySortingArrow = true;
            fieldPathResult = '';
            currencySymbolBnkStmnt = MultiCurrencyHelper.getUserCurrencySymbol();
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
            setDisplaySoringArrows(bankStmntDescbResult, bankStmntFieldsetList);
        }
    }

    /**
     * To display sorting arrows for fields whose data type other than longtextares
     */
    public void setDisplaySoringArrows(
            Schema.DescribeSObjectResult descObjResult,
            List<Schema.FieldSetMember> fieldSetList
    ) {
        Map<String, Schema.SObjectField> MAP_OBJECT_FIELD = new Map<String, Schema.SObjectField>();
        for(String fieldName : descObjResult.fields.getMap().keySet()) {
            MAP_OBJECT_FIELD.put(
                descObjResult.fields.getMap().get(fieldName).getDescribe().getName(),
                descObjResult.fields.getMap().get(fieldName)
            );
        }
        for(Schema.FieldSetMember fieldSetMemb : fieldSetList) {
            if(fieldSetMemb.getType() == DisplayType.TextArea) {
                Schema.SObjectField sObjFields = MAP_OBJECT_FIELD.get(fieldSetMemb.getfieldPath());
                Schema.DescribeFieldResult descFieldResult = sObjFields.getDescribe();
                if(descFieldResult.getLength() > 255 ) {
                    displaySortingArrow = false;
                    fieldPathResult = fieldSetMemb.getfieldPath();
                }
            }
            displaySortingArrow = true;
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

    //method to build dynamic query for SUM and COUNT
    public String buildBankStatementAggregateQuery(List<Schema.FieldSetMember> pBankStmntFieldsetList)
    {
        bankStmntAggregateQueryStr = 'SELECT ';
        String bankStmntAggregateWhereClause = '(Opportunity__c = \''+opportunityId+'\' AND Include_in_average__c = true AND Month__c != NULL AND Year__c != NULL)';
        for(Schema.FieldSetMember fieldInstance :pBankStmntFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency')
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
            {
                bankStmntAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                bankStmntAggregateQueryStr += 'COUNT('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+'COUNT'+ ', ';
                bankStmntFieldSumSet.add(fieldInstance.getFieldPath());
            }
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency')) {
                bankStmntCurrencyFields.add(fieldInstance.getFieldPath());
            }
            bankStmntFieldToSumMap.put(fieldInstance.getFieldPath(), -999.999);
        }
        bankStmntAggregateQueryStr= bankStmntAggregateQueryStr.removeEnd(', ');
        bankStmntAggregateQueryStr += ',COUNT(Id) FROM Bank_Account__c WHERE '+bankStmntAggregateWhereClause+' GROUP BY Month__c, Year__c';

        return bankStmntAggregateQueryStr;
    }

    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getBankStatementFieldSum(String pBankStmntAggregateQueryStr)
    {
        if(opportunityId <> null && opportunityId <> '')
        {
            List<SObject> bankStmntSumQueryResult = new List<SObject>();
            List<SObject> bankStmntCountQueryResult = new List<SObject>();
            Map<String, Decimal> bankStmntFieldNameToSumMap = new Map<String, Decimal>();
            Map<String, Decimal> bankStmntFieldNameToCountMap = new Map<String, Decimal>();
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
                        if(!bankStmntFieldNameToSumMap.containsKey(fieldName+'COUNT'))
                        {
                            bankStmntFieldNameToSumMap.put(fieldName+'COUNT',(Decimal)bankStmntSumQueryResult[i].get(fieldName+'COUNT'));
                            if((Decimal)bankStmntSumQueryResult[i].get(fieldName+'COUNT') > 0)
                            {
                                bankStmntFieldNameToSumMap.put(fieldName+'COUNT',1);
                            }
                        }
                        else
                        {
                            bankStmntFieldNameToSumMap.put(fieldName+'COUNT', bankStmntFieldNameToSumMap.get(fieldName+'COUNT')+1);
                        }
                    }
                }
            }

            for(String fieldName :bankStmntFieldSumSet)
            {
                bankStmntFieldToSumMap.put(fieldName,0);
                if(bankStmntFieldNameToSumMap.get(fieldName) != null)
                {
                    Decimal value = (Decimal)bankStmntFieldNameToSumMap.get(fieldName) / (Decimal)bankStmntFieldNameToSumMap.get(fieldName+'COUNT');
                    value = bankStmntCurrencyFields.contains(fieldName) && MultiCurrencyHelper.isMultiCurrencyEnabled()
                        ? MultiCurrencyHelper.convertToUserCurrency(value)
                        : value;
                    bankStmntFieldToSumMap.put(fieldName, value);
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

    //method to build a map from a list from DB
    public Map<Id, Bank_Account__c> getBankStatementMapFromList(List<Bank_Account__c> pBankStmntLst)
    {
        bankStmntFromDbMap.clear();
        for(Bank_Account__c bankStmntInstance :pBankStmntLst)
        {
            bankStmntFromDbMap.put(bankStmntInstance.Id, bankStmntInstance);
        }
        return bankStmntFromDbMap;
    }

    //method to create new payables
    public void newBankStatement()
    {
        globalMap = GRIDOnloadStaticVariable.getGlobalMap();
        customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
        Schema.DescribeSObjectResult bnkStmentDescbResult = globalMap.get(customMetaDataSettingMap.get('Bank_Statements').Object_API_Name__c).getDescribe();
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
                Bank_Account__c bankStmntNew = new Bank_Account__c();
                DefaultValueHelper.populateValues(bankStmntNew, bankStmntFieldsetList, bnkStmentDescbResult);
                if(Label.GRIDBankStatementMonthAutomation.equalsIgnoreCase('true')) {
                    Date bankStmntTodayDate = date.Today();
                    bankStmntMnth = bankStmntTodayDate.addMonths(-i);
                    bankStmntMnthValue = (bankStmntMnth.month() <10? '0'+bankStmntMnth.month()+' - '+bankStmntMnth.format('MMMM'):''+bankStmntMnth.month()+' - '+bankStmntMnth.format('MMMM'));
                    bankStmntNew.Opportunity__c = opportunityId;
                    bankStmntNew.OwnerId = UserInfo.getUserId();
                    bankStmntNew.Month__c = bankStmntMnthValue;
                    bankStmntNew.Year__c = String.valueOf(bankStmntMnth.Year());
                    bankStmntNew.Include_in_average__c = true;
                }
                else {
                    bankStmntNew.Opportunity__c = opportunityId;
                    bankStmntNew.Include_in_average__c = true;
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

        List<Bank_Account__c> bankStmntTempLst = getBankStatementFromDB(
            opportunityId,
            bankStmntBlockSize,
            bankStmntOffsetsize,
            bankStmntFieldsApiSet,
            bankStmntSortExpression,
            bankStmntSortDirection
        );
        bankStmntFromDBMap = getBankStatementMapFromList(bankStmntTempLst);
        for(BankStatementWrapper bankStmntWraperInstance :bankStmntWrapperLst){
            Bank_Account__c bankStmntDBObj = bankStmntFromDBMap.get(bankStmntWraperInstance.BankStmnt.Id);
            if(bankStmntDBObj != null)
            {
                bankStmntIsUpdated = false;
                for(String bankStmntFieldInstance :bankStmntFieldsApiSet)
                {
                    if(!bankStmntFieldInstance.contains('.Name'))
                    {
                        bankStmntIsUpdated  = bankStmntIsUpdated 
                            ||(bankStmntWraperInstance.BankStmnt.get(
                                bankStmntFieldInstance) != bankStmntDBObj.get(bankStmntFieldInstance));
                    }
                }
            }else {
                if(!bankStmntIsNewBtnPress) {
                    bankStmntIsUpdated = true;
                }
            }
            if(bankStmntIsUpdated) {
                bankStmntListToUpdate.add(bankStmntWraperInstance.BankStmnt);
                bankStmntErrorToWraperIndexMap.put(
                    bankStmntListToUpdate.size()-1, bankStmntWraperInstance.bankStmntIndex
                );
            }
            bankStmntWraperInstance.bankStmntEdit = bankStmntEditAllFlag;
        }

        try {
            if(bankStmntListToUpdate != null && bankStmntListToUpdate.size() >0)
            {
                List<Database.upsertResult> results = Database.upsert(bankStmntListToUpdate, false);
                for (Integer i =0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        for (Database.Error err : results[i].getErrors()) {
                            String recordError = err.getMessage();
                            if(!recordError.contains('insufficient access rights on')) {
                                bankStmntWrapperLst[bankStmntErrorToWraperIndexMap.get(i)].bankStmntEdit = true;
                            }
                            bankStmntSingleErrorOnSave = true;
                            if(results.size() > 1) {
                                bankStmntMsgStr = bankStmntMsgStr
                                    + 'Error Record '
                                    +(bankStmntErrorToWraperIndexMap.get(i)+1)
                                    +' : '+ recordError  + '<br />';
                             } else {
                                bankStmntMsgStr = bankStmntMsgStr
                                    + 'Error Record '
                                    +(bankStmntErrorToWraperIndexMap.get(i)+1)
                                    +' : '+ recordError ;
                             }
                        }
                    } else if(results[i].isSuccess()) {
                        if(bankStmntListToUpdate.size() > 1) {
                            bankStmntSuccessMsgStr = bankStmntSuccessMsgStr
                                + 'Success Record '
                                +(bankStmntErrorToWraperIndexMap.get(i)+1)
                                +' : '+ 'saved successfully!' + '<br />';
                            
                        } else {
                           bankStmntSuccessMsgStr = bankStmntSuccessMsgStr
                                + 'Success Record '
                                +(bankStmntErrorToWraperIndexMap.get(i)+1)
                                +' : '+ 'saved successfully!';
                        }
                        bankStmntWrapperLst[bankStmntErrorToWraperIndexMap.get(i)].bankStmntEdit = bankStmntEditAllFlag;
                    }
                }
                bankStmntSuccessMsgStr = bankStmntSuccessMsgStr.removeEnd('<br />');
                bankStmntMsgStr = bankStmntMsgStr.removeEnd('<br />');
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
                        bankStmntSuccessMsgStr = 'Last changes made by you were saved successfully!';
                    }
                    if(String.isNotBlank(bankStmntMsgStr)) {
                        if(String.isNotBlank(bankStmntSuccessMsgStr)) {
                            ApexPages.addMessage(new Apexpages.Message(
                                ApexPages.Severity.Info,bankStmntMsgStr +'<br/>'
                                + bankStmntSuccessMsgStr.removeEnd('<br />'))
                            );
                        } else {
                            ApexPages.addMessage(new Apexpages.Message(
                                ApexPages.Severity.Info,bankStmntMsgStr)
                            );
                        }
                    } else {
                        ApexPages.addMessage(new Apexpages.Message(
                            ApexPages.Severity.Info,bankStmntSuccessMsgStr)
                        );
                    }
                }
            }
            bankStmntPageNavigated = false;
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