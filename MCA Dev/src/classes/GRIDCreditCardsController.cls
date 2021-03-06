/**
 *  This class is a helper class for setting default values
 *
 *  Version     Author                      Date(DD/MM/YYYY)            Description
 *  1.0                                                                 Initial draft[]
 *  1.1         Ajinkya Hingne              13/10/2016                  Show default vals when creating new record
 *  1.2         Merul Shah                  07/11/2016                  Added to display arrows
                                                                        for field function
 */
global with sharing class GRIDCreditCardsController {
    //Constant Variable
    private static final String ERROR_MSG = 'Please complete required fields and click on quick save before creating Open balance, credit cards and bank statements records.';
    public String OpportunityId;
    public List<Credit_Card__c> cardLst;
    public Map<Id, Credit_Card__c> cardFromDbMap;
    public List<CreditCardWrapper> cardWrapperLst;
    public String cardAggregateQueryStr = '';
    public String cardFieldsString = '';
    public Set<String> cardFieldsApiSet;
    public Boolean cardFirstRun;
    public Boolean cardIsNewBtnPress;
    public Boolean cardSingleErrorOnSave;
    public Integer cardNmbrOfRecordsToCreate;
    public String cardFieldType;
    public Boolean cardEditAll;
    public static Map<String, Schema.SObjectField> mapObjectField;
    public static Map<String, Schema.SObjectType> globalMap;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    public static Schema.DescribeSObjectResult cardDescbResult;
    public List<Schema.FieldSetMember> cardFieldsetList                                 {get; set;}
    public Set<String> cardFieldSumSet                                                  {get; set;}
    public Set<String> cardCurrencyFields                                               {get; set;}
    public Opportunity opportunityObj                                                   {get; set;}
    public Map<String, Decimal> cardFieldToSumMap                                       {get; set;}
    public Integer cardRecordCount                                                      {get; set;}
    public Integer cardBlockSize                                                        {get; set;}
    public Integer cardOffsetsize                                                       {get; set;}
    public Integer cardIndexToRemove                                                    {get; set;}
    public string cardSortDirection                                                     {get; set;}
    public String cardSortExpression                                                    {get; set;}
    public boolean isDisable                                                            {get; set;}
    public String cardSortExprFieldApi                                                  {get; set;}
    public Boolean cardIsRefrenceField                                                  {get; set;}
    public String  cardRefrenceFieldLabel                                               {get; set;}
    // Editall Attribute
    public Boolean cardEditAllFlag                                                      {get; set;}
    public Boolean displaySortingArrow                                                  {get; set;}
    public String fieldPathResult                                                       {get; set;}
    // boolean to handle save success message on navigation
    public Boolean cardPageNavigated;
    public String currencyMerchantStatement                                            {get; set;}

    // constructor
    public GRIDCreditCardsController()
    {
        if(GRIDOnloadStaticVariable.flipCreditCard())
        {
            isDisable = false;
            opportunityObj = new Opportunity();
            opportunityId = Apexpages.currentPage().getParameters().get('id');
             if(opportunityId == null || opportunityId == '') {
                //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, ERROR_MSG));
                isDisable = true;
            }else
             {
                opportunityObj = [SELECT AccountId
                                       , Id
                                       , Name
                                  FROM Opportunity
                                  WHERE Id =: opportunityId ];
             }
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();

            cardBlockSize = (Integer)customMetaDataSettingMap.get('Credit_Cards').PageSize__c;
            cardOffsetsize = 0;

            cardLst = new List<Credit_Card__c>();
            cardFromDbMap = new Map<Id, Credit_Card__c>();
            cardWrapperLst = new List<CreditCardWrapper>();
            cardFieldToSumMap = new Map<String, Decimal>();
            cardFieldSumSet = new Set<String>();
            cardCurrencyFields = new Set<String>();
            cardFieldsApiSet = new Set<String>();
            cardFieldsetList = new List<Schema.FieldSetMember>();
            cardIsNewBtnPress = false;
            cardSortDirection = 'DESC';
            cardSortExpression = 'CreatedDate';
            cardFieldType = '';
            currencyMerchantStatement = MultiCurrencyHelper.getUserCurrencySymbol();
            cardEditAll = false;
            cardPageNavigated = false;
            displaySortingArrow = true;
            fieldPathResult = '';
            cardDescbResult = globalMap.get(customMetaDataSettingMap.get('Credit_Cards').Object_API_Name__c).getDescribe();
            cardFieldsetList = cardDescbResult.FieldSets.getMap().get(customMetaDataSettingMap.get('Credit_Cards').Fieldset_Name__c).getFields();
            cardNmbrOfRecordsToCreate = Integer.valueOf(Label.GRIDCreditCardCreateCount);
            GRIDUtility.ReferenceFieldWrapper refWrap = new GRIDUtility.ReferenceFieldWrapper(cardFieldsetList, ' ', false);
            refWrap = GRIDUtility.isReferenceFieldPresent(refWrap);
            cardIsRefrenceField = refWrap.isReferenceField;
            cardRefrenceFieldLabel = refWrap.refrenceFieldLabel;
            if(!cardIsRefrenceField )
            {
                cardAggregateQueryStr = buildCreditCardAggregateQuery(cardFieldsetList);
                cardFieldToSumMap = getCreditCardFieldSum(cardAggregateQueryStr);
                cardFieldsApiSet = buildSetFromFieldListCreditCard(cardFieldsetList);
                if(opportunityId != null && opportunityId != '')
                    cardLst = getCreditCardFromDB(opportunityId, cardBlockSize, cardOffsetsize, cardFieldsApiSet, cardSortExpression, cardSortDirection);
                cardFirstRun = true;
            }
            setDisplaySoringArrows(cardDescbResult, cardFieldsetList);
        }
    }

    /**
     * To display sorting arrows for fields whose data type other than longtextares
     */
    public void setDisplaySoringArrows(
            Schema.DescribeSObjectResult descObjResult,
            List<Schema.FieldSetMember> fieldSetList
    ) {
        Map<String, Schema.SObjectField> MAP_OBJECT_FIELD = descObjResult.fields.getMap();
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
    public Set<String> buildSetFromFieldListCreditCard(List<Schema.FieldSetMember> pCardFieldsetList)
    {
        String cardReferenceField;
        for(Schema.FieldSetMember fieldInstance :pCardFieldsetList)
        {

            cardFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                cardReferenceField = '';
                if(fieldInstance.getfieldPath().contains('__c'))
                {
                    cardReferenceField += fieldInstance.getfieldPath().substringBefore('__c')+'__r.Name';
                }
                else
                {
                    cardReferenceField += fieldInstance.getfieldPath().substringBefore('Id')+'.Name';
                }
                cardFieldsApiSet.add(cardReferenceField);
            }
        }

        return cardFieldsApiSet;
    }

    // method to build dynamic query for SUM and COUNT
    public String buildCreditCardAggregateQuery(List<Schema.FieldSetMember> pCardFieldsetList)
    {
        cardAggregateQueryStr = 'SELECT ';
        for(Schema.FieldSetMember fieldInstance :pCardFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency')
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
            {
                cardAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                cardAggregateQueryStr += 'COUNT('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+'COUNT'+ ', ';
                cardFieldSumSet.add(fieldInstance.getFieldPath());
            }
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency')) {
                cardCurrencyFields.add(fieldInstance.getFieldPath());
            }
            cardFieldToSumMap.put(fieldInstance.getFieldPath(), -999.999);
        }
        cardAggregateQueryStr = cardAggregateQueryStr.removeEnd(', ');
        cardAggregateQueryStr += ' ,COUNT(Id) FROM Credit_Card__c Where Opportunity__c = \''+opportunityId+'\' AND Include_in_average__c = true AND Month__c != NULL AND Year__c != NULL GROUP BY Month__c, Year__c';
        return cardAggregateQueryStr;
    }

    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getCreditCardFieldSum(String pCardAggregateQueryStr)
    {

        if(opportunityId <> null && opportunityId <> ''){
            List<SObject> cardSumQueryResult = new List<SObject>();
            Map<String, Decimal> cardFieldNameToSumMap = new Map<String, Decimal>();
            Decimal cardFieldSum;
            Integer cardCount = 0;
            cardSumQueryResult = Database.query(pCardAggregateQueryStr);
            for(String fieldName :cardFieldSumSet)
            {
                cardFieldSum = 0;
                for(Integer i = 0; i < cardSumQueryResult.size(); i++)
                {

                    if(cardSumQueryResult[i].get(fieldName) != null)
                    {
                        if(!cardFieldNameToSumMap.containsKey(fieldName))
                        {
                            cardFieldNameToSumMap.put(fieldName,(Decimal)cardSumQueryResult[i].get(fieldName));
                        }
                        else
                        {
                            cardFieldSum = cardFieldNameToSumMap.get(fieldName);
                            cardFieldSum  += (Decimal)cardSumQueryResult[i].get(fieldName);
                            cardFieldNameToSumMap.put(fieldName, cardFieldSum);
                        }

                        if(!cardFieldNameToSumMap.containsKey(fieldName+'COUNT'))
                        {
                            cardFieldNameToSumMap.put(fieldName+'COUNT',(Decimal)cardSumQueryResult[i].get(fieldName+'COUNT'));
                            if((Decimal)cardSumQueryResult[i].get(fieldName+'COUNT') > 0)
                            {
                                cardFieldNameToSumMap.put(fieldName+'COUNT',1);
                            }
                        }
                        else
                        {
                            cardFieldNameToSumMap.put(fieldName+'COUNT', cardFieldNameToSumMap.get(fieldName+'COUNT')+1);
                        }

                    }


                }
            }

            for(String fieldName :cardFieldSumSet)
            {
                cardFieldToSumMap.put(fieldName,0);
                if(cardFieldNameToSumMap.get(fieldName) != null)
                {
                    Decimal value = (Decimal)cardFieldNameToSumMap.get(fieldName) / (Decimal)cardFieldNameToSumMap.get(fieldName+'COUNT');
                    value = cardCurrencyFields.contains(fieldName) && MultiCurrencyHelper.isMultiCurrencyEnabled()
                            ? MultiCurrencyHelper.convertToUserCurrency(value)
                            : value;
                    cardFieldToSumMap.put(fieldName, value);
                }
            }

            List<SObject> cardCountQueryResult = new List<SObject>();
            cardCountQueryResult = database.query('Select Count(Id) cardCount From Credit_Card__c Where Opportunity__c = \''+opportunityId+'\'');
            cardRecordCount = (Integer)cardCountQueryResult[0].get('cardCount');
            return cardFieldToSumMap;
        }
        cardRecordCount = 0;
        return null;
    }

    // method to get CreditCards from DB
    public List<Credit_Card__c> getCreditCardFromDB(String pOpportunityId, Integer pCardBlockSize, Integer pCardOffsetSize, Set<String> pCardFieldsApiSet,
                                                      String pcardSortExpression, String pcardSortDirection)
    {
        if(pOpportunityId <> null && pOpportunityId <> '')
        {
            String cardQueryStr = '';
            cardFieldsString = MCAUtility.getStringfromSet(pCardFieldsApiSet, null);
            cardQueryStr = 'Select ' +cardFieldsString+
                            ' From Credit_Card__c Where Opportunity__c =:pOpportunityId ORDER BY '+pcardSortExpression+' '+pcardSortDirection+' NULLS LAST LIMIT '
                            +pCardBlockSize+' Offset ' +pCardOffsetSize;

            return database.query(cardQueryStr);
        }
        return new List<Credit_Card__c>();
    }

    // method to get the wrapper list
    public List<CreditCardWrapper> getCardWrapperLst()
    {
        if(cardFirstRun)
        {
            cardWrapperLst = new List<CreditCardWrapper>();
        }
        if(cardLst <> null && cardLst.size() > 0 ) {
            if(cardFirstRun)
            {
                //cardWrapperLst = new List<CreditCardWrapper>();
                for (Integer i = 0; i < cardLst.size(); i++)
                {
                    cardWrapperLst.add(new CreditCardWrapper(cardLst[i], i, cardEditAllFlag));
                }
                cardFirstRun = false;
            }
        }
        //cardFieldToSumMap = getCreditCardFieldSum(cardAggregateQueryStr);
        return cardWrapperLst;
    }

    // method to build a map from a list from DB
    public Map<Id, Credit_Card__c> getCreditCardMapFromList(List<Credit_Card__c> pCardLst)
    {
        cardFromDbMap.clear();
        for(Credit_Card__c cardInstance :pCardLst)
        {
            cardFromDbMap.put(CardInstance.Id, CardInstance);
        }
        return cardFromDbMap;
    }

    // method to create new payables
    public void newCreditCard()
    {
        globalMap = GRIDOnloadStaticVariable.getGlobalMap();
        customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
        Schema.DescribeSObjectResult cardDescbObjResult = globalMap.get(customMetaDataSettingMap.get('Credit_Cards').Object_API_Name__c).getDescribe();
        cardIsNewBtnPress = true;
        if(!cardEditAll)
        {
            saveCreditCards();
        }
        else
        {
            cardSingleErrorOnSave = false;
        }
        cardIsNewBtnPress = false;
        dateTime cardMnth;
        String cardMnthValue;
        if(!cardSingleErrorOnSave)
        {
            // to add new record only on first page
            if(cardOffsetsize <> 0)
            {
                cardOffsetsize = 0;
                beginningCreditCards();
            }

            for(Integer i = cardNmbrOfRecordsToCreate; i> 0; i--)
            {
                Credit_Card__c cardNew =new Credit_Card__c();
                DefaultValueHelper.populateValues(cardNew, cardFieldsetList, cardDescbObjResult);
                if(Label.GRIDCreditCardMonthAutomation.equalsIgnoreCase('true'))
                {
                    Date cardTodayDate = date.Today();
                    cardMnth = cardTodayDate.addMonths(-i);
                    cardMnthValue = (cardMnth.month() <10? '0'+cardMnth.month()+' - '+cardMnth.format('MMMM'):''+cardMnth.month()+' - '+cardMnth.format('MMMM'));
                    cardNew.Opportunity__c = opportunityId;
                    cardNew.Month__c = cardMnthValue;
                    cardNew.Year__c = String.valueOf(cardMnth.Year());
                    cardNew.Include_in_average__c = true;

                }
                else
                {
                    cardNew.Opportunity__c = opportunityId;
                    cardNew.Include_in_average__c = true;
                }
                //need to add at 0th index if list size > 0 else simple add will work
                if(cardWrapperLst.size() > 0 && cardLst.size() > 0)
                {
                    cardWrapperLst.add(0,new CreditCardWrapper(cardNew, null, true));
                    cardLst.add(0, cardNew);
                }
                else
                {
                    cardWrapperLst.add(new CreditCardWrapper(cardNew, null, true));
                    cardLst.add(cardNew);
                }
            }

            // reindexing
            for(Integer i = 0; i < cardWrapperLst.size(); i++)
            {
                cardWrapperLst[i].cardIndex = i;
            }
        }


    }

    // method to delete payables
    public void deleteCreditCard()
    {
        if(cardWrapperLst[cardIndexToRemove].Card.Id != null)
         {
            try
            {
                delete cardWrapperLst[cardIndexToRemove].Card;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }

         cardLst.remove(cardIndexToRemove);
         cardWrapperLst.remove(cardIndexToRemove);

        //re-indexing
        for(Integer i=0;i < cardWrapperLst.size();i++)
        {
            cardWrapperLst[i].cardIndex = i;
        }

        if(cardWrapperLst.size() <= 0)
        {
            refreshCreditCards();
        }
        cardFieldToSumMap = getCreditCardFieldSum(cardAggregateQueryStr);
        //refreshcardances();
    }

    // method to save payable
    public void saveCreditCards()
    {
        String cardMsgStr = '';
        String cardSuccessMsgStr ='';
        cardSingleErrorOnSave = false;
        Boolean cardIsUpdated = false;
        cardEditAll = false;
        List<Credit_Card__c> cardListToUpdate = new List<Credit_Card__c>();
        Map<Integer, Integer> cardErrorToWraperIndexMap = new map<Integer, Integer>();

        List<Credit_Card__c> cardTempLst = getCreditCardFromDB(
            opportunityId,
            cardBlockSize,
            cardOffsetsize,
            cardFieldsApiSet,
            cardSortExpression,
            cardSortDirection
        );
        cardFromDBMap = getCreditCardMapFromList(cardTempLst);

        for(CreditCardWrapper cardWraperInstance :cardWrapperLst) {
            Credit_Card__c cardDBObj = cardFromDBMap.get(cardWraperInstance.Card.Id);
            if(cardDBObj != null) {
                cardIsUpdated = false;
                for(String cardFieldInstance :cardFieldsApiSet) {
                    if(!cardFieldInstance.contains('.Name')) {
                        cardIsUpdated = cardIsUpdated || 
                            (cardWraperInstance.Card.get(CardFieldInstance) != cardDBObj.get(cardFieldInstance));
                    }
                }
            } else {
                if(!cardIsNewBtnPress) {
                    cardIsUpdated = true;
                }
            }
            if(cardIsUpdated) {
                cardListToUpdate.add(cardWraperInstance.card);
                cardErrorToWraperIndexMap.put(cardListToUpdate.size()-1, cardWraperInstance.cardIndex);
            }
            cardWraperInstance.cardEdit = cardEditAllFlag;
        }

        try {
            if(cardListToUpdate != null && cardListToUpdate.size() >0) {
                List<Database.upsertResult> results = Database.upsert(cardListToUpdate, false);
                for (Integer i =0; i < results.size(); i++) {
                    if (!results[i].isSuccess())
                    {
                        for (Database.Error err : results[i].getErrors()) {
                            String recordError = err.getMessage();
                            if(!recordError.contains('insufficient access rights on')) {
                                 cardWrapperLst[cardErrorToWraperIndexMap.get(i)].cardEdit = true;
                            }
                            cardSingleErrorOnSave = true;
                            if(results.size() > 1) {
                                cardMsgStr = cardMsgStr 
                                    + 'Error Record '
                                    +(cardErrorToWraperIndexMap.get(i)+1)
                                    +' : '+ recordError + '<br />';
                             } else {
                                cardMsgStr = cardMsgStr 
                                    + 'Error Record '
                                    +(cardErrorToWraperIndexMap.get(i)+1)
                                    +' : '+ recordError ;
                             }
                        }
                    }
                    else if(results[i].isSuccess())
                    {
                        if(cardListToUpdate.size() > 1) {
                            cardSuccessMsgStr = cardSuccessMsgStr
                                + 'Success Record '
                                +(cardErrorToWraperIndexMap.get(i)+1)
                                +' : '+ 'saved successfully!' + '<br />';
                        } else {
                            cardSuccessMsgStr = cardSuccessMsgStr
                                + 'Success Record '
                                +(cardErrorToWraperIndexMap.get(i)+1)
                                +' : '+ 'saved successfully!';
                        }
                        cardWrapperLst[cardErrorToWraperIndexMap.get(i)].cardEdit = cardEditAllFlag;
                    }
                }
                cardSuccessMsgStr = cardSuccessMsgStr.removeEnd('<br />');
                cardMsgStr = cardMsgStr.removeEnd('<br />');
                if(cardSingleErrorOnSave == false && !cardIsNewBtnPress) {
                    cardLst = getCreditCardFromDB(
                        opportunityId,
                        cardBlockSize,
                        cardOffsetsize,
                        cardFieldsApiSet,
                        cardSortExpression,
                        cardSortDirection
                    );
                    cardFieldToSumMap = getCreditCardFieldSum(cardAggregateQueryStr);
                    cardFirstRun = true;
                }
                if(String.isNotBlank(cardMsgStr) || String.isNotBlank(cardSuccessMsgStr)) {
                    if(cardPageNavigated) {
                        //cardPageNavigated = false;
                        cardSuccessMsgStr = 'Last changes made by you were saved successfully!';
                    }
                    if(String.isNotBlank(cardMsgStr)) {
                        if(String.isNotBlank(cardSuccessMsgStr)) {
                            ApexPages.addMessage(new Apexpages.Message(
                                ApexPages.Severity.Info, cardMsgStr +'<br/>'
                                + cardSuccessMsgStr.removeEnd('<br />'))
                            );
                        } else {
                            ApexPages.addMessage(new Apexpages.Message(
                                ApexPages.Severity.Info, cardMsgStr )
                            );
                        }
                    } else {
                        ApexPages.addMessage(new Apexpages.Message(
                            ApexPages.Severity.Info, cardSuccessMsgStr)
                        );
                    }
                }
            }
            cardPageNavigated = false;
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new Apexpages.Message(
                ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e))
            );
            cardFirstRun = false;
        }
    }

    // method to edit all commissions
    public void editAllCreditCards()
    {
        cardFirstRun = false;
        cardEditAll = true;
        for(Integer i=0; i< cardWrapperLst.size(); i++)
        {
            cardWrapperLst[i].cardEdit = true;
        }

    }

    // method to refresh
    public void refreshCreditCards()
    {
        cardLst = getCreditCardFromDB(opportunityId, cardBlockSize, cardOffsetsize, cardFieldsApiSet, cardSortExpression, cardSortDirection);
        cardFieldToSumMap = getCreditCardFieldSum(cardAggregateQueryStr);
        cardFirstRun = true;
    }

    //method for the first page of list to be displayed
    public void beginningCreditCards()
    {
        cardPageNavigated = true;
        saveCreditCards();
        if (!cardSingleErrorOnSave)
        {
            cardOffsetsize = 0;
            cardLst = getCreditCardFromDB(opportunityId, cardBlockSize, cardOffsetsize, cardFieldsApiSet, cardSortExpression, cardSortDirection);
            cardFirstRun = true;
        }
    }

    //method for previous page of list to be displayed
    public void previousCreditCards()
    {
        cardPageNavigated = true;
        saveCreditCards();
        if (!cardSingleErrorOnSave && cardBlockSize <= cardOffsetsize)
        {
            cardOffsetsize = cardOffsetsize - cardBlockSize;
            cardLst = getCreditCardFromDB(opportunityId, cardBlockSize, cardOffsetsize, cardFieldsApiSet, cardSortExpression, cardSortDirection);
            cardFirstRun = true;
        }
    }

    //method for next page of list to be displayed
    public void nextCreditCards()
    {
        cardPageNavigated = true;
        saveCreditCards();
        if (!cardSingleErrorOnSave && cardOffsetsize <= cardRecordCount)
        {
            cardOffsetsize = cardOffsetsize + cardBlockSize;
            cardLst = getCreditCardFromDB(opportunityId, cardBlockSize, cardOffsetsize, cardFieldsApiSet, cardSortExpression, cardSortDirection);
            cardFirstRun = true;
        }
    }

    //method for last page of list to be displayed
    public void endCreditCards()
    {
        cardPageNavigated = true;
        saveCreditCards();
        if(!cardSingleErrorOnSave && math.mod(cardRecordCount , cardBlockSize) == 0){
            cardOffsetsize = cardBlockSize * ((cardRecordCount/cardBlockSize)-1);
        } else if (!cardSingleErrorOnSave && math.mod(cardRecordCount , cardBlockSize) != 0){
            cardOffsetsize = cardBlockSize * ((cardRecordCount/cardBlockSize));
        }
        cardLst = getCreditCardFromDB(opportunityId, cardBlockSize, cardOffsetsize, cardFieldsApiSet, cardSortExpression, cardSortDirection);
        cardFirstRun = true;
    }

    //method to sort list of offers
    public void sortCreditCards()
    {
            string cardReferenceFieldName = '';
            cardFieldType = Apexpages.currentPage().getParameters().get('cardTypeParam');
            if(cardFieldType.equalsIgnoreCase('REFERENCE'))
            {
                if(cardSortExpression.contains('__c'))
                {
                    cardReferenceFieldName += cardSortExpression.substringBefore('__c')+'__r.Name';
                }
                else
                {
                    cardReferenceFieldName += cardSortExpression.substringBefore('Id')+'.Name';
                }
                cardSortExpression = string.valueOf(cardReferenceFieldName);
            }
            refreshCreditCards();
    }

    // wrapper for cardances
    public class CreditCardWrapper
    {
        public Credit_Card__c Card                                                       {get;set;}
        public Integer cardIndex                                                         {get;set;}
        public Boolean cardEdit                                                          {get;set;}
        public CreditCardWrapper(Credit_Card__c cardInstance, Integer pCardIndex, Boolean pCardEdit) {
            Card = cardInstance;
            cardIndex = pCardIndex;
            cardEdit = pCardEdit;
        }
    }
}