public without sharing class MerchantStatementSummaryController
{
    public static Map<String,Decimal> mapIncludeCountMrchntStmnt                        {get;set;}
    public List<Schema.FieldSetMember> merchntStmntFieldsetList                         {get;set;}
    public Map<String,List<MerchantStatementWrapper>> mapmerchstmWrap                   {get;set;}
    public Set<String> merchntStmntFieldAPISet                                          {get;set;}
    public string midAccountNo                                                          {get;set;}
    public boolean displayNewPopup                                                      {get;set;}
    public boolean mrchntErrorRecordsPopup                                              {get;set;}
    public List<Credit_Card__c> merchantStatements                                      {get;set;}
    public List<Credit_Card__c> newmerchantStatements                                   {get;set;}
    public List<Credit_Card__c> errormerchantStatements                                 {get;set;}
    public Integer merchantStmntIndexToRemove                                           {get;set;}
    public Map<String,Decimal> mapMerchStmTotalFields                                   {get;set;}
    public String merchntStmErrorOnPopup                                                {get;set;}
    public Boolean displayAccountView                                                   {get;set;}
    public Boolean renderNewOption                                                      {get;set;}
    public Boolean newMidAccountPopup                                                   {get;set;}
    public String newMidAccountNumber                                                   {get;set;}
    public Boolean updateAllAccountNos                                                  {get;set;}
    public Integer removeNewIndex                                                       {get;set;}
    public Boolean midAccNosRunFirst                                                    {get;set;}
    public integer newRowIndex                                                          {get;set;}
    public Boolean isInConsole                                                          {get;set;}
    public String OpportunityId                                                         {get;set;}
    public String accountId                                                             {get;set;}
    public String isAccountView                                                         {get;set;}
    public Boolean renderMrchntStmntPageMessage                                         {get;set;}
    public String newMrchntError                                                        {get;set;}
    public list<selectOption> midAccountNos;
    public List<MerchantStatementSummaryWrapper> listMerchntStmntSumWrap;
    public List<MerchantStatementSummaryWrapper> templistMerchntStmntSumWrap;
    private Integer merchantStmntNmbrOfRecordsToCreate;
    private static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    private static Map<String, Schema.SObjectType> globalMap;
    private String merchantStmntFieldsString = '';
    private Boolean merchntStmntFirstRun;
    private Boolean mrchntStmntSingleErrorOnSave ;
    private Map<Id, Credit_Card__c> mrchntStmtFromDbMap;
    private List<Credit_Card__c> merchntStmnts;
    private Set<Id> oppIds;
    private static final String IS_CONSOLE_PARAM = 'isConsole';


    //Constructor
    public MerchantStatementSummaryController()
    {
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        accountId = Apexpages.currentPage().getParameters().get('accId');
        isAccountView = ApexPages.currentPage().getParameters().get('isAccountView');
        isInConsole = ApexPages.currentPage().getParameters().get(IS_CONSOLE_PARAM) == '1' ? true : false;
        renderNewOption = false;
        newMidAccountPopup = false;
        updateAllAccountNos = false;
        midAccNosRunFirst = true;
        renderMrchntStmntPageMessage = false;
        merchntStmntFieldAPISet = new Set<String>();
        mapmerchstmWrap = new Map<String,List<MerchantStatementWrapper>>();
        merchantStatements = new List<Credit_Card__c>();
        listMerchntStmntSumWrap = new List<MerchantStatementSummaryWrapper>();
        mrchntStmtFromDbMap = new Map<Id, Credit_Card__c>();
        merchntStmnts = new List<Credit_Card__c>();
        errormerchantStatements = new List<Credit_Card__c>();
        oppIds = new Set<Id>();
        midAccountNos = new list<selectOption>();
        merchntStmntFieldSetList = new List<Schema.FieldSetMember>();
        merchantStmntNmbrOfRecordsToCreate = Integer.valueOf(Label.GRIDCreditCardCreateCount);
        globalMap = GRIDOnloadStaticVariable.getGlobalMap();
        customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
        Schema.DescribeSObjectResult mrchntStmntDescbResult = globalMap.get(customMetaDataSettingMap.get('Credit_Cards').Object_API_Name__c).getDescribe();
        fetchMrchntFieldsFromFieldSet();
        //merchntStmntFieldsetList = descresStmntDescbResult.FieldSets.getMap().get(customMetaDataSettingMap.get('Credit_Cards').Fieldset_Name__c).getFields();
        merchntStmntFieldAPISet = buildSetFromFieldListMerchantStatement(merchntStmntFieldsetList);

        if(opportunityId != null && opportunityId != '' && isAccountView == 'false')
        {
            displayAccountView = false;
            merchntStmntFirstRun = true;
            merchantStatements = getMerchantStatementsFromOpportunity(
                opportunityId,
                merchntStmntFieldAPISet,
                null
            );
        }
        else
        {
            displayAccountView = true;
            merchntStmntFirstRun = true;
            filterMerchntByAccountOnLoad(accountId);
            fetchMrchntStmntRecords(oppIds);
            //if(merchntStmnts.size() == 0 && merchntStmnts.isEmpty()) {
            merchantStatements = getMerchntStatementFromAccount(
                opportunityId,
                merchntStmntFieldAPISet,
                null
            );
        }
    }

    /**
     * Getter for MID account numbers select option
    */
    public List<SelectOption> getmidAccountNos() {
        if(midAccNosRunFirst)
        {
            midAccountNos = new list<selectOption>();
            if(isAccountView == 'true')
            {
                merchantStatements = getMerchntStatementFromAccount(accountId,merchntStmntFieldAPISet,null);
            }
            else
            {
                merchantStatements = getMerchantStatementsFromOpportunity(opportunityId,merchntStmntFieldAPISet,null);
                //merchantStatements = getMerchantStatementsFromOpportunity(opportunityId,descresStmntFieldsApiSet,null);
            }
            if(merchantStatements != Null && merchantStatements.size() > 0)
            {

                set<string> setMidAccountNos = New set<string>();
                for(Credit_Card__c merchntStmnt : merchantStatements )
                {
                    if(merchntStmnt.MID_Account_Number__c != null 
                        && merchntStmnt.MID_Account_Number__c != '--None--')
                    {
                        setMidAccountNos.add(merchntStmnt.MID_Account_Number__c);
                    }
                }
                list<string> midAccountNosStr = new list<string>();
                midAccountNosStr.addAll(setMidAccountNos);
                midAccountNosStr.sort();

                for(String strBankAccNo : midAccountNosStr)
                {
                    midAccountNos.add(new selectOption(strBankAccNo,strBankAccNo));
                }
            }
        }
        return midAccountNos;
    }

    /**
     * Which add new MID number while creating new reocords of merchant statements
    */
    public void doneForAllMerchntStmnt()
    {
        if(newMidAccountNumber == '') {
            newMrchntError = 'Please Enter New Merchant Statement Number';
            return;
        }

        if(updateAllAccountNos)
        {
            for(Credit_Card__c bankAccount : newmerchantStatements)
            {
                bankAccount.MID_Account_Number__c = newMidAccountNumber;
            }
        }
        else
        {
            newmerchantStatements[newRowIndex].MID_Account_Number__c = newMidAccountNumber;
        }
        displayNewPopup = true;
        newMidAccountPopup = false;
        midAccNosRunFirst = true;
    }

    public void closeMIDAccountUpdate() {
        newMidAccountPopup = false;
        displayNewPopup = true;
    }

    /**
     * back to opportunity or account
    */
    public pageReference backToParentRecord() {
        renderMrchntStmntPageMessage = true;
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
    public void saveMerchntStatment()
    {
        System.debug('>>>Save Merchnt Stmnt');
        errormerchantStatements = new List<Credit_Card__c>();
        String merchantStatementMsgStr = '';
        String merchantStatementSuccessMsgStr = '';
        Boolean merchantStatementIsUpdated = false;
        mrchntStmntSingleErrorOnSave = false;
        renderMrchntStmntPageMessage = true;
        //mrchntStmEditAll = false;
        mrchntErrorRecordsPopup = false;
        List<Credit_Card__c> merchantStatementListToUpdate = new List<Credit_Card__c>();
        Map<Integer, MerchantStatementWrapper > merchantStatementErrorToWraperIndexMap = new map<Integer, MerchantStatementWrapper >();
        List<Credit_Card__c> tempMerchntStmnts;
        if(isAccountView == 'true') {
            /*ActiontempMerchntStmnts = getMerchntStatementFromAccount(
                accountId,
                merchntStmntFieldAPISet,
                midAccountNo
            );*/
        } else {
            tempMerchntStmnts = getMerchantStatementsFromOpportunity(
                opportunityId,
                merchntStmntFieldAPISet,
                midAccountNo
            );
        }
        mrchntStmtFromDbMap = getMrchntStmtMapFromList(tempMerchntStmnts);
        for (MerchantStatementSummaryWrapper mrchntstmMonthSumWarpper: listMerchntStmntSumWrap)
        {
            for(MerchantStatementWrapper mrchntStmntWraperInstance : mrchntstmMonthSumWarpper.lstMerchntStmntMonthSum)
            {
                Credit_Card__c merchantStatementDBObj = mrchntStmtFromDbMap.get(mrchntStmntWraperInstance.merchantStatement.Id);
                if(merchantStatementDBObj != null)
                {
                    merchantStatementIsUpdated = false;
                    for(String merchantStatementFieldInstance :merchntStmntFieldAPISet)
                    {
                        if(!merchantStatementFieldInstance.contains('.Name'))
                        {
                            merchantStatementIsUpdated  = merchantStatementIsUpdated ||
                            (mrchntStmntWraperInstance.merchantStatement.get(merchantStatementFieldInstance)
                            != merchantStatementDBObj.get(merchantStatementFieldInstance));
                        }
                    }
                }
                else
                {
                    merchantStatementIsUpdated = true;
                }
                merchantStatementListToUpdate.add(mrchntStmntWraperInstance.merchantStatement);
                merchantStatementErrorToWraperIndexMap.put(
                    merchantStatementListToUpdate.size()-1,
                    mrchntStmntWraperInstance
                );
                /*if(merchantStatementIsUpdated)
                {
                    merchantStatementListToUpdate.add(mrchntStmntWraperInstance.merchantStatement);
                    merchantStatementErrorToWraperIndexMap.put(
                        merchantStatementListToUpdate.size()-1,
                        mrchntStmntWraperInstance
                    );
                }*/
                mrchntStmntWraperInstance.editMerchantStmnt = false;
            }
        }
        try
        {
            if(merchantStatementListToUpdate != null && merchantStatementListToUpdate.size() >0)
            {

                List<Database.upsertResult> results = Database.upsert(
                    merchantStatementListToUpdate,
                    false);
                for (Integer i =0; i < results.size(); i++)
                {
                    if (!results[i].isSuccess())
                    {
                        mrchntErrorRecordsPopup = true;
                        errormerchantStatements.add(merchantStatementListToUpdate[i]);
                        for (Database.Error err : results[i].getErrors())
                        {
                            String recordError = err.getMessage();
                            if(!recordError.contains('insufficient access rights on'))
                            {
                                merchantStatementErrorToWraperIndexMap.get(i).errorMsgMrchntStmnt = recordError;
                                merchntStmErrorOnPopup = recordError;
                            }
                            mrchntStmntSingleErrorOnSave = true;
                            merchantStatementMsgStr = recordError;
                        }
                    }
                    else if(results[i].isSuccess())
                    {
                        merchantStatementSuccessMsgStr = 'Record(s) saved successfully.';
                        merchantStatementErrorToWraperIndexMap.get(i).editMerchantStmnt = false;
                    }
                }
                if(mrchntStmntSingleErrorOnSave == false /*&& !bankStmntIsNewBtnPress*/)
                {
                    if(isAccountView == 'true') {
                        tempMerchntStmnts = getMerchntStatementFromAccount(
                            accountId,
                            merchntStmntFieldAPISet,
                            midAccountNo
                        );
                    } else {
                        merchantStatements = getMerchantStatementsFromOpportunity(
                            opportunityId,
                            merchntStmntFieldAPISet,
                            midAccountNo
                        );
                    }
                    merchntStmntFirstRun = true;
                }
                if(String.isNotBlank(merchantStatementMsgStr))
                {
                    ApexPages.addMessage(new Apexpages.Message(
                        ApexPages.Severity.Error, merchantStatementMsgStr));
                }
                else if(String.isNotBlank(merchantStatementSuccessMsgStr))
                {
                    ApexPages.addMessage(new Apexpages.Message(
                        ApexPages.Severity.Info,merchantStatementSuccessMsgStr));
                }
            }
            /*if(isAccountView == 'false')
            {
                merchantStatements = getMerchantStatementsFromOpportunity(
                    opportunityId,
                    merchntStmntFieldAPISet,
                    null
                );
            }
            else
            {
                fetchMrchntStmntRecords(oppIds);
                merchantStatements = getMerchntStatementFromAccount(
                    opportunityId,
                    merchntStmntFieldAPISet,
                    null
                );
            }*/
            filterBasedOnMidNo();
            getlistMerchntStmntSumWrap();
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(
             ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             merchntStmntFirstRun = false;
        }
    }

    /*
      * method to delete payables
    */
    public void deleteMerchntStatement()
    {
        
        if(merchantStatements[merchantStmntIndexToRemove] != null)
        {
            try
            {
                filterBasedOnMidNo();
                delete merchantStatements[merchantStmntIndexToRemove];
                merchantStatements.remove(merchantStmntIndexToRemove);
                if(merchantStatements.isEmpty()) {
                    midAccountNo = 'All';
                    filterBasedOnMidNo();
                }
                merchntStmntFirstRun = true;
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
    public Map<Id, Credit_Card__c> getMrchntStmtMapFromList(List<Credit_Card__c> pbnkStmtLst)
    {
        mrchntStmtFromDbMap.clear();
        for(Credit_Card__c bnkStmtInstance :pbnkStmtLst)
        {
            mrchntStmtFromDbMap.put(bnkStmtInstance.Id, bnkStmtInstance);
        }
        return mrchntStmtFromDbMap;
    }

    /**
     * Getter for bank account summary details
    */
    public List<Credit_Card__c> getLstBnkStmFromLstMerchantStatementSummaryWrapper(
        List<MerchantStatementSummaryWrapper> listMerchntStmntSumWrap)
    {
        List<Credit_Card__c> tempmerchnts = new List<Credit_Card__c>();
        for(MerchantStatementSummaryWrapper mrchntStmtMonthSumWrap : listMerchntStmntSumWrap)
        {
            List<MerchantStatementWrapper> lstMerchntStmntMonthSum = mrchntStmtMonthSumWrap.lstMerchntStmntMonthSum;
            for(MerchantStatementWrapper mrchntStmntWrap : lstMerchntStmntMonthSum )
            {
                tempmerchnts.add(mrchntStmntWrap.merchantStatement);
            }
        }
        return tempmerchnts;
    }

    /**
     * To get bank account statement based on month and calculate summation
     */
    public List<MerchantStatementSummaryWrapper> getlistMerchntStmntSumWrap()
    {
        if(merchntStmntFirstRun)
        {
            listMerchntStmntSumWrap = new List<MerchantStatementSummaryWrapper>();
            mapMerchStmTotalFields = new Map<String,Decimal>();
            mapIncludeCountMrchntStmnt = new Map<String,Decimal>();
            Integer tempIncludeInAverageCount = 1;
            for(Integer i = 0; i < merchantStatements.size(); i++)
            {
                Credit_Card__c mrchntStmt = merchantStatements[i];
                String combKeyMonthYear = mrchntStmt.Month__c + mrchntStmt.Year__c;
                List<MerchantStatementWrapper> tempMerchntStmWrapper;
                if(mapmerchstmWrap.containsKey(combKeyMonthYear))
                {
                    tempMerchntStmWrapper = mapmerchstmWrap.get(combKeyMonthYear);
                }
                else
                {
                    tempMerchntStmWrapper = new List<MerchantStatementWrapper>();
                }
                tempMerchntStmWrapper.add(new MerchantStatementWrapper(mrchntStmt,i,false,''));
                mapmerchstmWrap.put(combKeyMonthYear,tempMerchntStmWrapper);
            }

            for(String  combKeyMonthYear : mapmerchstmWrap.keySet())
            {
                List<MerchantStatementWrapper> lsttempMerchntStmWrapper = mapmerchstmWrap.get(combKeyMonthYear);
                Map<String,Decimal> mapMrchntStmSummaryFields =  new  Map<String,Decimal>();
                String tempMonth;
                String tempYear;
                for(MerchantStatementWrapper mrchntWrapper : lsttempMerchntStmWrapper)
                {
                    Credit_Card__c tempMrchntStmnt = mrchntWrapper.merchantStatement;
                    tempMonth = tempMrchntStmnt.Month__c;
                    tempYear = tempMrchntStmnt.Year__c;

                    if(tempMrchntStmnt.Include_in_average__c && tempMrchntStmnt.Month__c != NULL && tempMrchntStmnt.Year__c != NULL)
                    {
                        for(Schema.FieldSetMember fieldInstance: merchntStmntFieldsetList)
                        {
                            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency')
                               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
                               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
                            {
                                String fieldApiName = fieldInstance.getFieldPath();
                                if(tempMrchntStmnt.get(fieldApiName) != null)
                                {
                                    if(mapMrchntStmSummaryFields.containsKey(fieldApiName))
                                    {

                                        {
                                            mapMrchntStmSummaryFields.put(
                                                fieldApiName,
                                                mapMrchntStmSummaryFields.get(fieldApiName) +
                                                (Decimal)(tempMrchntStmnt.get(fieldApiName))
                                            );
                                        }
                                    }
                                    else
                                    {
                                        mapMrchntStmSummaryFields.put(
                                            fieldApiName,
                                            (Decimal)(tempMrchntStmnt.get(fieldApiName))
                                        );
                                    }
                                    if(mapMerchStmTotalFields.containsKey(fieldApiName))
                                    {
                                        mapMerchStmTotalFields.put(
                                            fieldApiName,
                                            mapMerchStmTotalFields.get(fieldApiName) +
                                            (Decimal)(tempMrchntStmnt.get(fieldApiName))
                                        );
                                    }
                                    else
                                    {
                                        mapMerchStmTotalFields.put(
                                            fieldApiName,
                                            (Decimal)(tempMrchntStmnt.get(fieldApiName))
                                        );
                                    }
                                }
                            }
                        }
                    }
                }
                listMerchntStmntSumWrap.add(new MerchantStatementSummaryWrapper(
                    combKeyMonthYear,
                    mapMrchntStmSummaryFields,
                    lsttempMerchntStmWrapper,
                    tempMonth,
                    tempYear)
                );
            }
            /*Average Calculation*/
            for(MerchantStatementSummaryWrapper merStmtSumWrap: listMerchntStmntSumWrap)
            {
                for(Schema.FieldSetMember fieldInstance: merchntStmntFieldsetList)
                {
                    if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency')
                        || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
                        || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
                    {
                        String fieldApiName = fieldInstance.getFieldPath();
                        if(!mapIncludeCountMrchntStmnt.containsKey(fieldApiName))
                        {
                             mapIncludeCountMrchntStmnt.put(fieldApiName,0.00);
                        }

                        if(merStmtSumWrap.mapMerchntStmentFields.get(fieldApiName) != NULL)
                        {
                            mapIncludeCountMrchntStmnt.put(fieldApiName,mapIncludeCountMrchntStmnt.get(fieldApiName)+1);
                        }
                    }
                }
            }
        }
        merchntStmntFirstRun = false;
        mapmerchstmWrap.clear();
        return listMerchntStmntSumWrap;
    }

    /**
     * Fetch Merchant Statement from opportunity
    */
    public List<Credit_Card__c> getMerchantStatementsFromOpportunity(
            String opportunityId,
            Set<String> SetOffieldSetApi,
            String midAccountNo
    ) {
        if(opportunityId <> null && opportunityId <> '' )
        {
            String QueryCondition = '';
            String mrchntStmntQueryString = '';

            if(midAccountNo == null || midAccountNo == 'All' /*|| midAccountNo == '--None--'*/)
            {
                QueryCondition = '';
            }
            else
            {
                QueryCondition = ' AND MID_Account_Number__c like:midAccountNo ';
            }
            merchantStmntFieldsString = MCAUtility.getStringfromSet(SetOffieldSetApi, null);
            if(merchantStmntFieldsString.Contains('Year__c')) {
                merchantStmntFieldsString = merchantStmntFieldsString.remove('Year__c,');
            }
            if(merchantStmntFieldsString.Contains('Month__c')) {
                merchantStmntFieldsString = merchantStmntFieldsString.remove('Month__c,');
            }
            if(merchantStmntFieldsString.Contains('MID_Account_Number__c')) {
                merchantStmntFieldsString = merchantStmntFieldsString.remove('MID_Account_Number__c,');
            }
            mrchntStmntQueryString = 'SELECT Month__c, Year__c, MID_Account_Number__c, Include_in_average__c, ' 
            +merchantStmntFieldsString+
            ' FROM Credit_Card__c WHERE Opportunity__c =:opportunityId '+
            QueryCondition+' ORDER BY  Year__c,Month__c';
            System.debug('>>mrchntStmntQueryString>>>'+mrchntStmntQueryString);
            return database.query(mrchntStmntQueryString);
        }
        return new List<Credit_Card__c>();
    }

    /**
     * To get merchant Statement from account
    */
    public List<Credit_Card__c> getMerchntStatementFromAccount(
            String pAccountId,
            Set<String> pmerchntStmntFieldAPISet,
            String midAccountNo
    ) {
        if(pAccountId <> null && pAccountId <> '') {
            String QueryCondition = '';
            String mrchntStmntQueryString = '';

            if(midAccountNo == null || midAccountNo == 'All')
            {
                QueryCondition = '';
            }
            else
            {
                QueryCondition = ' AND MID_Account_Number__c like:midAccountNo';
            }

            merchantStmntFieldsString = MCAUtility.getStringfromSet(pmerchntStmntFieldAPISet, null);
            if(merchantStmntFieldsString.Contains('Year__c')) {
                merchantStmntFieldsString = merchantStmntFieldsString.remove('Year__c,');
            }
            if(merchantStmntFieldsString.Contains('Month__c')) {
                merchantStmntFieldsString = merchantStmntFieldsString.remove('Month__c,');
            }
            if(merchantStmntFieldsString.Contains('MID_Account_Number__c')) {
                merchantStmntFieldsString = merchantStmntFieldsString.remove('MID_Account_Number__c,');
            }
            mrchntStmntQueryString = 'SELECT Month__c, Year__c, MID_Account_Number__c, Include_in_average__c, ' 
            +merchantStmntFieldsString+
            ' FROM Credit_Card__c WHERE Opportunity__c IN :oppIds '+
            QueryCondition+' ORDER BY  Year__c,Month__c';
            return database.query(mrchntStmntQueryString);
        }
        return new List<Credit_Card__c>();
    }

    /**
     * To get filter result based on Account number
    */
    public void filterBasedOnMidNo()
    {
        if(isAccountView == 'true') {
            merchantStatements = getMerchntStatementFromAccount(accountId,merchntStmntFieldAPISet,midAccountNo);
        } else {
            merchantStatements = getMerchantStatementsFromOpportunity(opportunityId,merchntStmntFieldAPISet,midAccountNo);
        }
        merchntStmntFirstRun = true;
    }

    /**
     * Refresh merchant statements
    */
    public void refreshMerchantStatements()
    {
        renderMrchntStmntPageMessage = true;
        merchntStmntFirstRun = true;
        merchantStatements = getMerchantStatementsFromOpportunity(opportunityId,merchntStmntFieldAPISet,midAccountNo);
    }

    /**
     * To close popup
     */
    public void closeNewPopup()
    {
        displayNewPopup = false;
    }

    /**
     * To display popup on New creation
    */
    public void showNewPopup()
    {
        renderNewOption = true;
        displayNewPopup = true;
        dateTime mrchntStmntMnth;
        String mrchntStmntMnthValue;
        globalMap = GRIDOnloadStaticVariable.getGlobalMap();
        customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
        Schema.DescribeSObjectResult mrchntStmntDescbResult = globalMap.get(
            customMetaDataSettingMap.get('Credit_Cards').Object_API_Name__c).getDescribe();
        newmerchantStatements = new List<Credit_Card__c>();
        for(Integer i = merchantStmntNmbrOfRecordsToCreate; i> 0; i--)
        {
            Credit_Card__c merchntStmntNew = new Credit_Card__c();
            DefaultValueHelper.populateValues(merchntStmntNew, merchntStmntFieldsetList, mrchntStmntDescbResult);
            if(Label.GRIDCreditCardMonthAutomation.equalsIgnoreCase('true'))
            {
                Date mrchntStmntTodayDate = date.Today();
                mrchntStmntMnth = mrchntStmntTodayDate.addMonths(-i);
                mrchntStmntMnthValue = (mrchntStmntMnth.month() <10? '0'+mrchntStmntMnth.month()+' - '
                    +mrchntStmntMnth.format('MMMM'):''+mrchntStmntMnth.month()+' - '
                    +mrchntStmntMnth.format('MMMM'));
                merchntStmntNew.Opportunity__c = opportunityId;
                merchntStmntNew.OwnerId = UserInfo.getUserId();
                merchntStmntNew.Month__c = mrchntStmntMnthValue;
                merchntStmntNew.Year__c = String.valueOf(mrchntStmntMnth.Year());
                merchntStmntNew.Include_in_average__c = true;
            }else
            {
                merchntStmntNew.Opportunity__c = opportunityId;
                merchntStmntNew.Include_in_average__c = true;
            }
            newmerchantStatements.add(merchntStmntNew);
        }
        System.debug('>>>newmerchantStatements mrchnt>>>>'+newmerchantStatements);
    }

    /**
     * When --New-- selected from Merchnat Statement MID No while creating new summary record
    */
    public void setNewOptionPopup() {
        for(Credit_Card__c mrchntAccount : newmerchantStatements) {
            if(mrchntAccount.MID_Account_Number__c == '--New--') {
                displayNewPopup = false;
                newMidAccountPopup = true;
            }
        }
    }

    /**
    * While saving error record
    */
    public void errorSave()
    {
        for(Integer i = 0 ; i  < errormerchantStatements.size(); i++)
        {
            merchantStatements.add(i, errormerchantStatements[i]);
        }
        merchntStmntFirstRun =  true;
        saveMerchntStatment();
        if(errormerchantStatements.size() == 0) {
            closeErrorPopup();
        }
    }

    /**
     * To close error popup
     */
    public void closeErrorPopup()
    {
        mrchntErrorRecordsPopup = false;
        merchntStmntFirstRun =  true;
    }

    /**
     * Remove row of new merchant statement list
    */
    public void removeNewRow() {
       // ApexPages.currentPage().getParameters().get('removeNewIndex');
        newmerchantStatements.remove(removeNewIndex);
    }

    /**
     * Action for the button of save which get on popup while creationg new records
    */
     public void newSave()
     {
        if(merchantStatements.size() > 0) {
            for(Integer i = 0 ; i  < newmerchantStatements.size(); i++) {
                merchantStatements.add(i,newmerchantStatements[i]);
            }
        } else {
            merchantStatements.addAll(newmerchantStatements);
        }
        merchntStmntFirstRun =  true;
        listMerchntStmntSumWrap = getlistMerchntStmntSumWrap();
        saveMerchntStatment();
        closeNewPopup();
    }

    /**
     * Fetch fieldset name from custom setting
    */
    private List<FO_Sales_Summary__c> fetchRecordsFromFieldSet()
    {
        return [SELECT Id,
                       Custom_Merchant_Statement_Fieldset_API_N__c,
                       Override_Grid_Merchant_Statement_Fieldse__c
                  FROM FO_Sales_Summary__c
                 WHERE Override_Grid_Merchant_Statement_Fieldse__c = true];
    }

    /**
     * Assign the fieldset of merchnt statement from custom setting or custom metadata type.
    */
    private void fetchMrchntFieldsFromFieldSet() {
        List<FO_Sales_Summary__c> merchStmntFieldsFromCustomSetting = fetchRecordsFromFieldSet();
        schema.FieldSet merchntStmntFieldSet;
        List<Schema.FieldSetMember> tempmerchntStmntFieldSetList;
        if (merchStmntFieldsFromCustomSetting.size() > 0 ) {
            for(FO_Sales_Summary__c customSettingFields : merchStmntFieldsFromCustomSetting) {
                if(customSettingFields.Override_Grid_Merchant_Statement_Fieldse__c &&
                    customSettingFields.Custom_Merchant_Statement_Fieldset_API_N__c != null) {
                    merchntStmntFieldSet = Schema.getGlobalDescribe().
                        get('Credit_Card__c')
                        .getDescribe().FieldSets.getMap()
                        .get(customSettingFields.Custom_Merchant_Statement_Fieldset_API_N__c);
                    if(merchntStmntFieldSet != null) {
                        tempmerchntStmntFieldSetList = merchntStmntFieldSet.getFields();
                    }
                }
            }
        } else {
            Schema.DescribeSObjectResult merchntStmntDescbResult = globalMap.get(customMetaDataSettingMap.get('Credit_Cards').Object_API_Name__c).getDescribe();
            tempmerchntStmntFieldSetList = merchntStmntDescbResult.FieldSets.getMap().get(customMetaDataSettingMap.get('Credit_Cards').Fieldset_Name__c).getFields();
        }

        Set<Schema.FieldSetMember> setSchemaMrchnt = new Set<Schema.FieldSetMember>();
        setSchemaMrchnt.addAll(tempmerchntStmntFieldSetList);
        Set<String> setToRemoveFields = new Set<String>();
        for(Schema.FieldSetMember fieldSetData : setSchemaMrchnt) {
            if(fieldSetData.getfieldPath() == 'MID_Account_Number__c' ) {
                setSchemaMrchnt.remove(fieldSetData);
            }
            if(fieldSetData.getfieldPath() == 'Month__c' ) {
                setSchemaMrchnt.remove(fieldSetData);
            }
            if(fieldSetData.getfieldPath() == 'Year__c' ) {
                setSchemaMrchnt.remove(fieldSetData);
            }
            if(fieldSetData.getfieldPath() == 'Include_in_average__c' ) {
                setSchemaMrchnt.remove(fieldSetData);
            }
        }
        merchntStmntFieldSetList.addAll(setSchemaMrchnt);
    }

    /**
     * Method to build a Set of FieldApi name From List of FieldSetMember
     */
    private Set<String> buildSetFromFieldListMerchantStatement(List<Schema.FieldSetMember> merchntStmntFieldSetList)
    {
        String merchntStmntreferenceField;
        for(Schema.FieldSetMember fieldInstance :merchntStmntFieldSetList)
        {
            merchntStmntFieldAPISet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                merchntStmntreferenceField = '';
                if(fieldInstance.getfieldPath().contains('__c'))
                {
                    merchntStmntreferenceField += fieldInstance.getfieldPath().substringBefore('__c')+'__r.Name';
                }
                else
                {
                    merchntStmntreferenceField += fieldInstance.getfieldPath().substringBefore('Id')+'.Name';
                }
                merchntStmntFieldAPISet.add(merchntStmntreferenceField);
            }
        }
        return merchntStmntFieldAPISet;
    }

    /**
     * Display mrchnt accounts related to first picklist value for this fetch account related opportunity
    */
    private void filterMerchntByAccountOnLoad(Id accountId)
    {
        oppIds = new Set<Id>();
        List<Account> accounts = new List<Account>();
        accounts = [SELECT Id,
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
     * Fetch merchant statement records based on mid no
    */
    private List<Credit_Card__c> fetchMrchntStmntRecords(Set<Id> parentIds)
    {

        merchntStmnts = [Select Opportunity__c
                              , Id
                              , MID_Account_Number__c
                           From Credit_Card__c
                           WHERE Opportunity__c IN :parentIds
                            AND MID_Account_Number__c != '--None--'
                            AND MID_Account_Number__c != null
                            Order by MID_Account_Number__c asc];
        return merchntStmnts;
    }

    /**
     * Merchant statement wrapper
    */
    public Class MerchantStatementWrapper {
        public Credit_Card__c merchantStatement                                         {get; set;}
        public Integer indexMerchntStmnt                                                {get; set;}
        public Boolean editMerchantStmnt                                                {get; set;}
        public String errorMsgMrchntStmnt                                               {get; set;}

        //constructor
        public MerchantStatementWrapper(
                Credit_Card__c objMerchantStatement,
                Integer objIndex,
                Boolean objEdit,
                String objError) {
            merchantStatement = objMerchantStatement;
            indexMerchntStmnt = objIndex;
            editMerchantStmnt = objEdit;
            errorMsgMrchntStmnt = objError;
        }
    }

    /**
     *Wrapper class for summary
    */
    public Class MerchantStatementSummaryWrapper {
        public String keyStrngMerchntStmnt                                              {get;set;}
        public String Month                                                             {get;set;}
        Public String Year                                                              {get;set;}
        public Map<String,Decimal> mapMerchntStmentFields                               {get;set;}
        public List<MerchantStatementWrapper> lstMerchntStmntMonthSum                   {get;set;}

        //constructor
        public MerchantStatementSummaryWrapper(
                String  objKeyStrngMerchntStmnt,
                Map<String,Decimal> objMapMerchntStmentFields,
                List<MerchantStatementWrapper> objlstMerchntStmntMonthSum,
                String objMonth,
                String objYear
        ) {
            keyStrngMerchntStmnt = objKeyStrngMerchntStmnt;
            lstMerchntStmntMonthSum = objlstMerchntStmntMonthSum;
            mapMerchntStmentFields = objMapMerchntStmentFields;
            Month = objMonth;
            Year = objYear;
        }
    }
}