public without sharing class BankAccountSummaryController
{
    public Integer bankStmntNmbrOfRecordsToCreate;
    public static Map<String, Schema.SObjectType> globalMap;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    public static Map<String,Decimal> mapIncludeCountBankStmnt  {get;set;}
    public List<Schema.FieldSetMember> bankStmntFieldsetList    {get;set;}
    public Map<String,List<BankStatementWrapper>> mapBnkstmWrap {get;set;}
    public Set<String> bankStmntFieldsApiSet                    {get;set;}
    public string bankAccountNo                                 {get;set;}
    public boolean displayNewPopup                              {get;set;}
    public boolean errorRecordsPopup                            {get;set;}
    public List<Bank_Account__c> bankStmntLst                   {get;set;}
    public List<Bank_Account__c> newBankStmntLst                {get;set;}
    public List<Bank_Account__c> errorBankStmntLst              {get;set;}
    public Integer bankStmntIndexToRemove                       {get;set;}
    public Map<String,Decimal> mapBnkStmTotalFields             {get;set;}
    public Integer includeInAverageCount                        {get;set;}
    public String bankStmErrorOnPopup                           {get;set;}
    public Boolean displayAccountView                           {get;set;}
    public Boolean renderNewOption                              {get;set;}
    public Boolean newBankAccountPopup                          {get;set;}
    public String newBankAccountNumber                          {get;set;}
    public Boolean updateAllAccountNos                          {get;set;}
    public Integer removeNewIndex                               {get;set;}
    public Boolean bankAccNosRunFirst                           {get;set;}
    public Integer newRowIndex                                  {get;set;}
    public Boolean renderBnkStmntPageMessage                    {get;set;}
    public String newBankAccountError                           {get;set;}
    public String isInConsoleBankStmnt                          {get;set;}

    public String OpportunityId;
    public String accountId;
    public String bankStmntFieldsString = '';
    public Boolean bankStmntFirstRun;
    public List<BankStatementMonthSummaryWrapper> lstBnkStmMonthSumWrp;
    public List<BankStatementMonthSummaryWrapper> tempLstBnkStmMonthSumWrp;
    public Boolean bankStmntSingleErrorOnSave ;
    public Boolean bnkStmEditAll;
    public Map<Id, Bank_Account__c> bnkStmtFromDbMap;
    private String isAccountView;
    private List<Bank_Account__c> bankAccounts;
    private Set<Id> oppIds;

    //Constructor
    public BankAccountSummaryController()
    {
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        accountId = Apexpages.currentPage().getParameters().get('accId');
        isInConsoleBankStmnt = Apexpages.currentPage().getParameters().get('isInConsole');
        renderNewOption = false;
        newBankAccountPopup = false;
        updateAllAccountNos = false;
        bankAccNosRunFirst = true;
        renderBnkStmntPageMessage = false;
        isAccountView = ApexPages.currentPage().getParameters().get('isAccountView');
        bankStmntFieldsApiSet = new Set<String>();
        bankStmntFieldsetList = new List<Schema.FieldSetMember>();
        mapBnkstmWrap = new Map<String,List<BankStatementWrapper>>();
        bankStmntLst = new List<Bank_Account__c>();
        lstBnkStmMonthSumWrp = new List<BankStatementMonthSummaryWrapper>();
        bnkStmtFromDbMap = new Map<Id, Bank_Account__c>();
        bankAccounts = new List<Bank_Account__c>();
        errorBankStmntLst = new List<Bank_Account__c>();
        oppIds = new Set<Id>();
        bankStmntNmbrOfRecordsToCreate = Integer.valueOf(Label.GRIDBankStatementCreateCount);
        globalMap = GRIDOnloadStaticVariable.getGlobalMap();
        customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
        Schema.DescribeSObjectResult bankStmntDescbResult = globalMap.get(customMetaDataSettingMap.get('Bank_Statements').Object_API_Name__c).getDescribe();
        fetchFieldsFromFieldSet();
        bankStmntFieldsApiSet = buildSetFromFieldListBankStatement(bankStmntFieldsetList);

        if(opportunityId != null && opportunityId != '' && isAccountView == 'false')
        {
            displayAccountView = false;
            bankStmntFirstRun = true;
                bankStmntLst = getBankStatementFromDB(
                    opportunityId,
                    bankStmntFieldsApiSet,
                    null
                );
        } else {
            displayAccountView = true;
            bankStmntFirstRun = true;
            fetchBankSummaryRecords(oppIds);
            filterByAccountOnLoad(accountId);
            bankStmntLst = getBankStatementFromAccount(
                accountId,
                bankStmntFieldsApiSet,
                null
            );
        }
    }

    /**
     * Display bank accounts related to first picklist value for this fetch account related opportunity
    */
    public void filterByAccountOnLoad(Id accountId) {
        oppIds = new Set<Id>();
        List<Account> accounts = new List<Account>();
        accounts = [SELECT Id,
                           Name,
                        (SELECT AccountId,
                                ID
                            FROM Opportunities)
                      FROM Account
                      WHERE Id = :accountId];
        for(Account account : accounts) {
            for(Opportunity opportunity : account.Opportunities) {
                oppIds.add(opportunity.Id);
            }
        }
    }

    /**
     * Fetch fieldset name from custom setting
    */
    public List<FO_Sales_Summary__c> fetchRecordsFromFieldSet()
    {
        return [SELECT Id,
                       Custom_Bank_Statement_Fieldset_API_Name__c,
                       Override_Grid_Bank_Statement_Fieldset__c
                  FROM FO_Sales_Summary__c
                 WHERE Override_Grid_Bank_Statement_Fieldset__c = true];
    }

    /**
     * Assign the fieldset of bank statement from custom setting or custom metadata type.
    */
    private void fetchFieldsFromFieldSet()
    {
        List<FO_Sales_Summary__c> bankStmntFieldsFromCustomSetting = fetchRecordsFromFieldSet();

        schema.FieldSet bankStmntFieldSet;
        List<Schema.FieldSetMember> tempBankStmntFieldsetList;
        if (bankStmntFieldsFromCustomSetting.size() > 0 ) {
            for(FO_Sales_Summary__c customSettingFields : bankStmntFieldsFromCustomSetting) {
                if(customSettingFields.Override_Grid_Bank_Statement_Fieldset__c &&
                    customSettingFields.Custom_Bank_Statement_Fieldset_API_Name__c != null) {
                    bankStmntFieldSet = Schema.getGlobalDescribe().
                        get('Bank_Account__c')
                        .getDescribe().FieldSets.getMap()
                        .get(customSettingFields.Custom_Bank_Statement_Fieldset_API_Name__c);
                    if(bankStmntFieldSet != null) {
                        tempBankStmntFieldsetList = bankStmntFieldSet.getFields();
                    }
                }
            }
        } else {
            Schema.DescribeSObjectResult bankStmntDescbResult = globalMap.get(customMetaDataSettingMap.get('Bank_Statements').Object_API_Name__c).getDescribe();
            tempBankStmntFieldsetList = bankStmntDescbResult.FieldSets.getMap().get(customMetaDataSettingMap.get('Bank_Statements').Fieldset_Name__c).getFields();
        }
        Set<Schema.FieldSetMember> setSchema = new Set<Schema.FieldSetMember>();
        setSchema.addAll(tempBankStmntFieldsetList);
        Set<String> setToRemoveFields = new Set<String>();
        for(Schema.FieldSetMember fieldSetData : setSchema) {
            if(fieldSetData.getfieldPath() == 'Bank_Account_Number__c' ) {
                setSchema.remove(fieldSetData);
            }
            if(fieldSetData.getfieldPath() == 'Month__c' ) {
                setSchema.remove(fieldSetData);
            }
            if(fieldSetData.getfieldPath() == 'Year__c' ) {
                setSchema.remove(fieldSetData);
            }
            if(fieldSetData.getfieldPath() == 'Include_in_average__c' ) {
                setSchema.remove(fieldSetData);
            }
        }
        BankStmntFieldsetList.addAll(setSchema);
    }

    /**
     * fetch bank account record based on parent id
    */
    public List<Bank_Account__c> fetchBankSummaryRecords(Set<Id> parentIds)
    {

        bankAccounts = [Select Opportunity__c
                              , Id
                              , Bank_Account_Number__c
                              , Opportunity__r.Name
                           From Bank_Account__c
                           WHERE Opportunity__c IN :parentIds
                            AND Bank_Account_Number__c != '--None--'
                            AND Bank_Account_Number__c != null
                            Order by Bank_Account_Number__c asc];
        return bankAccounts;
    }

    /**
     * Get select list to filter base on account number
     */
    public list<selectOption> getlstBankAccNos()
    {
        list<selectOption> lstBankAccNos = new list<selectOption>();
        if(bankAccNosRunFirst)
        {
            if(isAccountView == 'true')
            {
                bankStmntLst = getBankStatementFromAccount(accountId,bankStmntFieldsApiSet,null);
            }
            else
            {
                bankStmntLst = getBankStatementFromDB(opportunityId,bankStmntFieldsApiSet,null);
            }
            if(bankStmntLst != Null && bankStmntLst.size() > 0)
            {

                set<string> setBankAccNos = New set<string>();
                for(Bank_Account__c objBA : bankStmntLst )
                {
                    if(objBA.Bank_Account_Number__c != null && objBA.Bank_Account_Number__c != '--None--'
                    )
                    {
                        setBankAccNos.add(objBA.Bank_Account_Number__c);
                    }
                }
                list<string> lstBankAccNosStr = new list<string>();
                lstBankAccNosStr.addAll(setBankAccNos);
                lstBankAccNosStr.sort();

                for(String strBankAccNo : lstBankAccNosStr)
                {
                    lstBankAccNos.add(new selectOption(strBankAccNo,strBankAccNo));
                }
            }
        }
        return lstBankAccNos;
    }

    /**
     * Which is action of done from popup of new bank account value
    */
    public void doneForAllBankStments()
    {
        if(newBankAccountNumber == '') {
            newBankAccountError = 'Please Enter New Bank Account Number';
            return;
        }

        if(updateAllAccountNos) {
            for(Bank_Account__c bankAccount : newBankStmntLst)
            {
                bankAccount.Bank_Account_Number__c = newBankAccountNumber;
            }
        } else {
            newBankStmntLst[newRowIndex].Bank_Account_Number__c = newBankAccountNumber;
        }
        displayNewPopup = true;
        newBankAccountPopup = false;
        bankAccNosRunFirst = true;
    }

    public void closeBankAccountPopup() {
        bankAccNosRunFirst = true;
        displayNewPopup = true;
        newBankAccountPopup = false;
    }

    /**
     * back to opportunity or account
    */
    public pageReference backToParentRecord() {
        renderBnkStmntPageMessage = true;
        PageReference pgRef;
        if(isAccountView == 'true') {
            pgRef = new PageReference('/'+accountId);
        } else {
            pgRef = new PageReference('/'+opportunityId);
        }
        return pgRef;
    }

    /*
     * Action of save button to save bank statement records
    */
    public void saveBankStatment()
    {
        renderBnkStmntPageMessage = true;
        errorBankStmntLst = new List<Bank_Account__c>();
        String bankStmntMsgStr = '';
        String bankStmntSuccessMsgStr = '';
        Boolean bankStmntIsUpdated = false;
        bankStmntSingleErrorOnSave = false;
        Boolean bnkStmIsUpdated = false;
        bnkStmEditAll = false;
        errorRecordsPopup = false;
        List<Bank_Account__c> bankStmntListToUpdate = new List<Bank_Account__c>();
        Map<Integer, BankStatementWrapper > bankStmntErrorToWraperIndexMap = new map<Integer, BankStatementWrapper >();
        List<Bank_Account__c> bankStmtTempLst;
        if(isAccountView == 'false') {
            bankStmtTempLst = getBankStatementFromDB(opportunityId,bankStmntFieldsApiSet,bankAccountNo);
        }
        bnkStmtFromDbMap = getbnkStmtMapFromList(bankStmtTempLst);
        for (BankStatementMonthSummaryWrapper bnkstmMonthSumWarpper: lstBnkStmMonthSumWrp)
        {
            for(BankStatementWrapper bankStmntWraperInstance : bnkstmMonthSumWarpper.lstBankStmntMonthSum)
            {
                Bank_Account__c bankStmntDBObj = bnkStmtFromDbMap.get(bankStmntWraperInstance.BankStmnt.Id);
                if(bankStmntDBObj != null)
                {
                    bankStmntIsUpdated = false;
                    for(String bankStmntFieldInstance :bankStmntFieldsApiSet)
                    {
                        if(!bankStmntFieldInstance.contains('.Name'))
                        {
                            bankStmntIsUpdated  = bankStmntIsUpdated ||
                            (bankStmntWraperInstance.BankStmnt.get(bankStmntFieldInstance) != bankStmntDBObj.get(bankStmntFieldInstance));
                        }
                    }
                }
                else
                {
                    bankStmntIsUpdated = true;
                }
                bankStmntListToUpdate.add(bankStmntWraperInstance.BankStmnt);
                bankStmntErrorToWraperIndexMap.put(bankStmntListToUpdate.size()-1, bankStmntWraperInstance);
                bankStmntWraperInstance.bankStmntEdit = false;
            }
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
                        errorRecordsPopup = true;
                        errorBankStmntLst.add(bankStmntListToUpdate[i]);
                        for (Database.Error err : results[i].getErrors())
                        {
                            String recordErrorBnkStmnt = err.getMessage();
                            if(!recordErrorBnkStmnt.contains('insufficient access rights on'))
                            {
                                bankStmntErrorToWraperIndexMap.get(i).bankStmErrorMsg = recordErrorBnkStmnt;
                                bankStmErrorOnPopup = recordErrorBnkStmnt ;
                            }
                            bankStmntSingleErrorOnSave = true;
                            bankStmntMsgStr = recordErrorBnkStmnt;
                        }
                    }
                    else if(results[i].isSuccess())
                    {
                        bankStmntSuccessMsgStr = 'Record(s) saved successfully.';
                        bankStmntErrorToWraperIndexMap.get(i).bankStmntEdit = false;
                    }
                }
                if(bankStmntSingleErrorOnSave == false)
                {
                    if(isAccountView == 'true') {
                        bankStmtTempLst = getBankStatementFromAccount(accountId,bankStmntFieldsApiSet,bankAccountNo);
                    } else {
                        bankStmntLst = getBankStatementFromDB(opportunityId,bankStmntFieldsApiSet,bankAccountNo);
                    }
                    bankStmntFirstRun = true;
                }
                if(String.isNotBlank(bankStmntMsgStr))
                {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, bankStmntMsgStr));
                }
                else if(String.isNotBlank(bankStmntSuccessMsgStr))
                {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,bankStmntSuccessMsgStr));
                }
            }

            if(isAccountView == 'false')
            {
                bankStmntLst = getBankStatementFromDB(
                    opportunityId,
                    bankStmntFieldsApiSet,
                    null
                );
            }
            filterByBankAccountNo();
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,
            MCAExceptionHandlerUtility.getErrorMessage(e)));
            bankStmntFirstRun = false;
        }
    }

    /**
    * method to delete payables
    */
    public void deleteBankStatement()
    {
        if(bankStmntLst[bankStmntIndexToRemove] != null)
        {
            try
            {
                filterByBankAccountNo();
                delete bankStmntLst[bankStmntIndexToRemove];
                bankStmntLst.remove(bankStmntIndexToRemove);
                if(bankStmntLst.isEmpty()) {
                    bankAccountNo = 'All';
                    filterByBankAccountNo();
                }
                bankStmntFirstRun = true;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,
                    MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
    }

    /**
    * Method to build a map from a list from DB
    */
    public Map<Id, Bank_Account__c> getbnkStmtMapFromList(List<Bank_Account__c> pbnkStmtLst)
    {
        bnkStmtFromDbMap.clear();
        for(Bank_Account__c bnkStmtInstance :pbnkStmtLst)
        {
            bnkStmtFromDbMap.put(bnkStmtInstance.Id, bnkStmtInstance);
        }
        return bnkStmtFromDbMap;
    }

    /**
     * Getter for bank account summary details
    */
    public List<Bank_Account__c> getLstBnkStmFromLstBankStatementMonthSummaryWrapper
    (List<BankStatementMonthSummaryWrapper> lstBnkStmMonthSumWrp) {
        List<Bank_Account__c> tempBnkAcc = new List<Bank_Account__c>();
        for(BankStatementMonthSummaryWrapper bnkStmtMonthSumWrap : lstBnkStmMonthSumWrp)
        {
            List<BankStatementWrapper> lstBankStmntMonthSum = bnkStmtMonthSumWrap.lstBankStmntMonthSum;
            for(BankStatementWrapper bnkStmWrap : lstBankStmntMonthSum )
            {
                tempBnkAcc.add(bnkStmWrap.BankStmnt);
            }
        }
        return tempBnkAcc;
    }

    /**
     * To get bank account statement based on month and calculate summation
     */
    public List<BankStatementMonthSummaryWrapper> getLstBnkStmMonthSumWrp()
    {

        if(bankStmntFirstRun)
        {
            lstBnkStmMonthSumWrp = new List<BankStatementMonthSummaryWrapper>();
            mapBnkStmTotalFields = new Map<String,Decimal>();
            mapIncludeCountBankStmnt = new Map<String,Decimal>();
            Integer tempIncludeInAverageCount = 1;
            String aggrBankStmtQuery;
            for(Integer i = 0; i < bankStmntLst.size(); i++)
            {
                Bank_Account__c bnkStmt = bankStmntLst[i];
                String combKeyMonthYear = bnkStmt.Month__c + bnkStmt.Year__c;
                List<BankStatementWrapper> tempbankStmWrapper;
                if(mapBnkstmWrap.containsKey(combKeyMonthYear))
                {
                    tempbankStmWrapper = mapBnkstmWrap.get(combKeyMonthYear);
                }
                else
                {
                    tempbankStmWrapper = new List<BankStatementWrapper>();
                }
                tempbankStmWrapper.add(new BankStatementWrapper(bnkStmt,i,false,''));
                mapBnkstmWrap.put(combKeyMonthYear,tempbankStmWrapper);
            }

            for(String  combKeyMonthYear : mapBnkstmWrap.keySet())
            {
                List<BankStatementWrapper> lsttempbankStmWrapper = mapBnkstmWrap.get(combKeyMonthYear);
                Map<String,Decimal> mapBnkStmSummaryFields =  new  Map<String,Decimal>();
                String tempMonth;
                String tempYear;

                for(Integer i = 0; i < lsttempbankStmWrapper.size(); i++)
                {
                    BankStatementWrapper bnkWrapper = lsttempbankStmWrapper[i];
                    Bank_Account__c tempBankStmnt = bnkWrapper.bankStmnt;
                    tempMonth = tempBankStmnt.Month__c;
                    tempYear = tempBankStmnt.Year__c;

                   if(tempBankStmnt.Include_in_average__c && tempBankStmnt.Month__c != NULL
                   && tempBankStmnt.Year__c != NULL)
                    {
                        for(Schema.FieldSetMember fieldInstance: bankStmntFieldsetList)
                        {
                            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency')
                               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
                               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
                            {
                               String fieldApiName = fieldInstance.getFieldPath();
                               if(tempBankStmnt.get(fieldApiName) != NULL)
                               {
                                   if(mapBnkStmSummaryFields.containsKey(fieldApiName))
                                   {
                                        mapBnkStmSummaryFields.put(fieldApiName,
                                            mapBnkStmSummaryFields.get(fieldApiName) +
                                            (Decimal)tempBankStmnt.get(fieldApiName));
                                    }
                                    else
                                    {
                                        mapBnkStmSummaryFields.put(fieldApiName,
                                        (Decimal)tempBankStmnt.get(fieldApiName)
                                        );
                                    }
                                    if(mapBnkStmTotalFields.containsKey(fieldApiName))
                                    {
                                        mapBnkStmTotalFields.put(
                                            fieldApiName,
                                            mapBnkStmTotalFields.get(fieldApiName) +
                                            (Decimal)( (Decimal)tempBankStmnt.get(fieldApiName))
                                        );
                                    }
                                    else
                                    {
                                        mapBnkStmTotalFields.put(
                                            fieldApiName,
                                            (Decimal)tempBankStmnt.get(fieldApiName));
                                    }
                               }
                            }
                        }
                    }
                }

                lstBnkStmMonthSumWrp.add(new BankStatementMonthSummaryWrapper(combKeyMonthYear,
                                                                              mapBnkStmSummaryFields,
                                                                              lsttempbankStmWrapper,
                                                                              tempMonth,
                                                                              tempYear));
            }
            /*Average Count Logic*/
            for(BankStatementMonthSummaryWrapper bnkstmMonthWrapper : lstBnkStmMonthSumWrp)
            {
                for(Schema.FieldSetMember fieldInstance: bankStmntFieldsetList)
                {
                    if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency')
                       || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
                       || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
                    {
                        String fieldApiName = fieldInstance.getFieldPath();
                        if(!mapIncludeCountBankStmnt.containsKey(fieldApiName))
                        {
                            mapIncludeCountBankStmnt.put(fieldApiName,0.00);
                        }
                        if(/*bnkstmMonthWrapper.mapBnkStmSummaryFields.get(fieldApiName) !=  0.00 &&*/
                            bnkstmMonthWrapper.mapBnkStmSummaryFields.get(fieldApiName) != NULL)
                        {
                            mapIncludeCountBankStmnt.put(fieldApiName,mapIncludeCountBankStmnt.get(fieldApiName)+1);
                        }
                    }
                }
            }
        }
        bankStmntFirstRun = false;
        mapBnkstmWrap.clear();
        return lstBnkStmMonthSumWrp;
    }


    /**
     * method to get Bank Statements from DB
     */
    public List<Bank_Account__c> getBankStatementFromDB(
            String pOpportunityId,
            Set<String> pBankStmntFieldsApiSet,
            String bankAccountNo
    ) {
        if(pOpportunityId <> null && pOpportunityId <> '' && isAccountView == 'false')
        {
            String bankAccountNoQryCond = '';
            String bankStmntQueryStr = '';

            if(bankAccountNo == null  || bankAccountNo == 'All' /*|| bankAccountNo == '--None--'*/)
            {
                bankAccountNoQryCond = '';
            }
            else
            {
                bankAccountNoQryCond = ' AND Bank_Account_Number__c like:bankAccountNo';
            }
            bankStmntFieldsString = MCAUtility.getStringfromSet(pBankStmntFieldsApiSet, null);
            bankStmntQueryStr = 'SELECT Year__c, Month__c, Bank_Account_Number__c, Include_in_average__c, ' +bankStmntFieldsString+
            ' FROM Bank_Account__c WHERE Opportunity__c =:pOpportunityId '+
            bankAccountNoQryCond+' ORDER BY  Year__c,Month__c';
            return database.query(bankStmntQueryStr);
        }
        return new List<Bank_Account__c>();
    }

    /**
     * To get Bank Statement from account
    */
    public List<Bank_Account__c> getBankStatementFromAccount(
            String pAccountId,
            Set<String> pBankStmntFieldsApiSet,
            String bankAccountNo
    ) {
        if(pAccountId <> null && pAccountId <> '') {

            String bankAccountNoQryCond = '';
            String bankStmntQueryStr = '';

            if(bankAccountNo == null || bankAccountNo == 'All')
            {
                bankAccountNoQryCond = '';
            }
            else
            {
                bankAccountNoQryCond = ' AND Bank_Account_Number__c like:bankAccountNo';
            }
            bankStmntFieldsString = MCAUtility.getStringfromSet(pBankStmntFieldsApiSet, null);

            if(bankStmntFieldsString.Contains('Year__c')) {
                bankStmntFieldsString = bankStmntFieldsString.remove('Year__c,');
            }
            if(bankStmntFieldsString.Contains('Month__c')) {
                bankStmntFieldsString = bankStmntFieldsString.remove('Month__c,');
            }
            if(bankStmntFieldsString.Contains('Bank_Account_Number__c')) {
                bankStmntFieldsString = bankStmntFieldsString.remove('Bank_Account_Number__c,');
            }
            bankStmntQueryStr = 'SELECT Month__c, Year__c, Bank_Account_Number__c, Include_in_average__c, ' +bankStmntFieldsString+
            ' FROM Bank_Account__c WHERE Opportunity__c IN :oppIds'+
            bankAccountNoQryCond+' ORDER BY  Year__c,Month__c';
            return database.query(bankStmntQueryStr);
        }
        return new List<Bank_Account__c>();
    }

    /**
     * To get filter result based on Account number
    */
    public void filterByBankAccountNo()
    {
        if(isAccountView == 'true') {
            bankStmntLst = getBankStatementFromAccount(accountId,bankStmntFieldsApiSet,bankAccountNo);
        } else {
            bankStmntLst = getBankStatementFromDB(opportunityId,bankStmntFieldsApiSet,bankAccountNo);
        }
        //bankStmntLst = getBankStatementFromDB(opportunityId,bankStmntFieldsApiSet,bankAccountNo);
        bankStmntFirstRun = true;
    }

    /**
     * method to build a Set of FieldApi name From List of FieldSetMember
     */
    public Set<String> buildSetFromFieldListBankStatement(List<Schema.FieldSetMember> pBankStmntFieldsetList)
    {
        String bankStmntReferenceField;
        for(Schema.FieldSetMember fieldInstance :pBankStmntFieldsetList) {
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

    /**
     *Refresh bank statements
    */
    public void refreshBankStatements()
    {
        renderBnkStmntPageMessage = true;
        bankStmntFirstRun = true;
        bankStmntLst = getBankStatementFromDB(opportunityId,bankStmntFieldsApiSet,bankAccountNo);
    }

    /**
     * To close popup
     */
    public void closeNewBankStmntPopup()
    {
        displayNewPopup = false;
    }

    /**
     * To display popup on New creation
    */
    public void showNewPopupBankStmnt()
    {
        renderNewOption = true;
        displayNewPopup = true;
        dateTime bankStmntMnth;
        String bankStmntMnthValue;
        globalMap = GRIDOnloadStaticVariable.getGlobalMap();
        customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
        Schema.DescribeSObjectResult bnkStmentDescbResult =
            globalMap.get(customMetaDataSettingMap.get('Bank_Statements').Object_API_Name__c).getDescribe();
        newBankStmntLst = new List<Bank_Account__c>();
        for(Integer i = bankStmntNmbrOfRecordsToCreate; i> 0; i--)
        {
            Bank_Account__c bankStmntNew = new Bank_Account__c();
            DefaultValueHelper.populateValues(bankStmntNew, bankStmntFieldsetList, bnkStmentDescbResult);
            if(Label.GRIDBankStatementMonthAutomation.equalsIgnoreCase('true'))
            {
                Date bankStmntTodayDate = date.Today();
                bankStmntMnth = bankStmntTodayDate.addMonths(-i);
                bankStmntMnthValue = (bankStmntMnth.month() <10? '0'+bankStmntMnth.month()+' - '
                    +bankStmntMnth.format('MMMM'):''+bankStmntMnth.month()+' - '
                    +bankStmntMnth.format('MMMM'));
                bankStmntNew.Opportunity__c = opportunityId;
                bankStmntNew.OwnerId = UserInfo.getUserId();
                bankStmntNew.Month__c = bankStmntMnthValue;
                bankStmntNew.Year__c = String.valueOf(bankStmntMnth.Year());
                bankStmntNew.Include_in_average__c = true;
            }else
            {
                bankStmntNew.Opportunity__c = opportunityId;
                bankStmntNew.Include_in_average__c = true;
            }
            newBankStmntLst.add(bankStmntNew);
        }
    }

    /**
     * This is call when --New-- selected from Bank account number while creating new summary record
    */
    public void setNewOptionBnkPopup() {

        for(Bank_Account__c bankAccount : newBankStmntLst) {
            if(bankAccount.Bank_Account_Number__c == '--New--') {
                displayNewPopup = false;
                newBankAccountPopup = true;
            }
        }
        bankAccNosRunFirst =true;
    }

    /**
    * While saving error record
    */
    public void errorSaveBankStmnt()
    {

        for(Integer i = 0 ; i  < errorBankStmntLst.size(); i++)
        {
            bankStmntLst.add(i, errorBankStmntLst[i]);
        }
        bankStmntFirstRun =  true;
        //lstBnkStmMonthSumWrp = getLstBnkStmMonthSumWrp();
        saveBankStatment();
        if(errorBankStmntLst.size() == 0) {
            closeErrorPopup();
        }
    }

    /**
     * To close error popup
     */
    public void closeErrorPopup()
    {
        errorRecordsPopup = false;
        bankStmntFirstRun =  true;
    }

    /**
     * Remove row of new bank statement list
    */
    public void removeNewRow() {
        newBankStmntLst.remove(removeNewIndex);
    }

    /**
     * Action for the button of save which get on popup while creationg new records
    */
     public void newSaveBankStmnt()
     {
        if(bankStmntLst.size() > 0) {
            for(Integer i = 0 ; i  < newBankStmntLst.size(); i++)
            {
                bankStmntLst.add(i,newBankStmntLst[i]);
            }
            
        } else {
            bankStmntLst.addAll(newBankStmntLst);
        }
        
        bankStmntFirstRun =  true;
        lstBnkStmMonthSumWrp = getLstBnkStmMonthSumWrp();
        saveBankStatment();
        closeNewBankStmntPopup();
    }

    // wrapper for loanBalances
    public class BankStatementWrapper
    {
        public Bank_Account__c BankStmnt        {get;set;}
        public Integer bankStmntIndex           {get;set;}
        public Boolean bankStmntEdit            {get;set;}
        public String bankStmErrorMsg           {get;set;}
        public BankStatementWrapper(Bank_Account__c bankStmntInstance,
                                    Integer pBankStmntIndex,
                                    Boolean pBankStmntEdit,
                                    String  pBankStmErrorMsg)
        {
            BankStmnt = bankStmntInstance;
            bankStmntIndex = pBankStmntIndex;
            bankStmntEdit = pBankStmntEdit;
            bankStmErrorMsg = pBankStmErrorMsg;
        }

    }

    public class BankStatementMonthSummaryWrapper
    {
        public String bankStatementkeyString                    {get;set;}
        public String Month                                     {get;set;}
        Public String Year                                      {get;set;}
        public Map<String,Decimal> mapBnkStmSummaryFields       {get;set;}
        public List<BankStatementWrapper> lstBankStmntMonthSum  {get;set;}
        public BankStatementMonthSummaryWrapper(String  pbankStatementkeyString,
                                                Map<String,Decimal> pmapBnkStmSummaryFields,
                                                List<BankStatementWrapper> plstBankStmntMonthSum,
                                                String pMonth,
                                                String pYear)
        {
            bankStatementkeyString = pbankStatementkeyString;
            lstBankStmntMonthSum = plstBankStmntMonthSum;
            mapBnkStmSummaryFields = pmapBnkStmSummaryFields;
            Month = pMonth;
            Year = pYear;
        }
    }
}