public with sharing class GRIDCreditCardsController {

    public Id OpportunityId;
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
    
    public static Map<String, Schema.SObjectType> globalMap;
    
    public List<Schema.FieldSetMember> cardFieldsetList                                 {get; set;}
    public Set<string> cardFieldSumSet                                                  {get; set;}
    public Map<String, Decimal> cardFieldToSumMap                                       {get; set;}
    public Integer cardRecordCount                                                      {get; set;}
    public Integer cardBlockSize                                                        {get; set;}
    public Integer cardOffsetsize                                                       {get; set;}
    public Integer cardIndexToRemove                                                    {get; set;}
    public string cardSortDirection                                                     {get; set;}
    public String cardSortExpression                                                    {get; set;}
    
    // constructor
    public GRIDCreditCardsController() 
    {
        if(GRIDOnloadStaticVariable.flipCreditCard())
        {
            opportunityId = Apexpages.currentPage().getParameters().get('id');

            cardBlockSize = (Integer)GRIDTabSetting__c.getValues('Credit Card').PageSize__c;
            cardOffsetsize = 0;

            cardLst = new List<Credit_Card__c>();
            cardFromDbMap = new Map<Id, Credit_Card__c>();
            cardWrapperLst = new List<CreditCardWrapper>();
            cardFieldToSumMap = new Map<String, Decimal>();
            cardFieldSumSet = new Set<String>();
            cardFieldsApiSet = new Set<String>();
            cardFieldsetList = new List<Schema.FieldSetMember>();
            cardIsNewBtnPress = false;
            cardSortDirection = 'DESC';
            cardSortExpression = 'CreatedDate';
            cardFieldType = '';
            
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            Schema.DescribeSObjectResult cardDescbResult = globalMap.get('Credit_Card__c').getDescribe();
            cardFieldsetList = cardDescbResult.FieldSets.getMap().get(GRIDTabSetting__c.getValues('Credit Card').Fieldset_Name__c).getFields();
            
            cardNmbrOfRecordsToCreate = Integer.valueOf(Label.GRIDCreditCardCreateCount);
            
            cardAggregateQueryStr = buildCreditCardAggregateQuery(cardFieldsetList);
            cardFieldsApiSet = buildSetFromFieldListCreditCard(cardFieldsetList);
            cardLst = getCreditCardFromDB(opportunityId, cardBlockSize, cardOffsetsize, cardFieldsApiSet, cardSortExpression, cardSortDirection);
            cardFirstRun = true;
        }
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListCreditCard(List<Schema.FieldSetMember> pCardFieldsetList)
    {
        String cardReferenceField;
        for(Schema.FieldSetMember fieldInstance :pCardFieldsetList)
        {
            cardReferenceField = '';
            cardFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
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
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double'))
            {
                cardAggregateQueryStr += 'AVG('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                cardFieldSumSet.add(fieldInstance.getFieldPath());
                
            }
            //cardFieldsApiSet.add(fieldInstance.getfieldPath());
            cardFieldToSumMap.put(fieldInstance.getFieldPath(), 100);
        }
        
        cardAggregateQueryStr += 'COUNT(Id) cardCount FROM Credit_Card__c Where  Opportunity__c = \''+opportunityId+'\'';
        
        return cardAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getCreditCardFieldSum(String pCardAggregateQueryStr)
    {
        List<SObject> cardSumQueryResult = new List<SObject>();
        cardSumQueryResult = Database.query(pCardAggregateQueryStr);
        
        for(String fieldName :cardFieldSumSet) 
        {
            if(cardSumQueryResult[0].get(fieldName) != null)
            {
                cardFieldToSumMap.put(fieldName, (Decimal)cardSumQueryResult[0].get(fieldName)); 
            }
        }
        cardRecordCount = (Integer)cardSumQueryResult[0].get('cardCount');
       
        return cardFieldToSumMap;
    }
    
    // method to get CreditCards from DB
    public List<Credit_Card__c> getCreditCardFromDB(Id pOpportunityId, Integer pCardBlockSize, Integer pCardOffsetSize, Set<String> pCardFieldsApiSet,
                                                      String pcardSortExpression, String pcardSortDirection) 
    {
        String cardQueryStr = '';
        cardFieldsString = DEWUtility.getStringfromSet(pCardFieldsApiSet, null);
        cardQueryStr = 'Select ' +cardFieldsString+ 
                        ' From Credit_Card__c Where Opportunity__c =:pOpportunityId ORDER BY '+pcardSortExpression+' '+pcardSortDirection+' NULLS LAST LIMIT '
                        +pCardBlockSize+' Offset ' +pCardOffsetSize;

        return database.query(cardQueryStr);
    }
    
    // method to get the wrapper list
    public List<CreditCardWrapper> getCardWrapperLst() 
    {
        if(cardFirstRun)
        {
            cardWrapperLst = new List<CreditCardWrapper>();
            for (Integer i = 0; i < cardLst.size(); i++) 
            {
                cardWrapperLst.add(new CreditCardWrapper(cardLst[i], i, false));
            }
            cardFirstRun = false;
        }
        cardFieldToSumMap = getCreditCardFieldSum(cardAggregateQueryStr);

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
        cardIsNewBtnPress = true;
        saveCreditCards();
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
                Credit_Card__c cardNew;
                if(Label.GRIDCreditCardMonthAutomation.equalsIgnoreCase('true')) 
                {
                    Date cardTodayDate = date.Today();
                    cardMnth = cardTodayDate.addMonths(-i);
                    cardMnthValue = (cardMnth.month() <10? '0'+cardMnth.month()+' - '+cardMnth.format('MMMM'):''+cardMnth.month()+' - '+cardMnth.format('MMMM'));
                    
                    cardNew = new Credit_Card__c(Opportunity__c = opportunityId,
                                                                Month__c = cardMnthValue,
                                                                Year__c = String.valueOf(cardMnth.Year()));
                }
                else
                {
                    cardNew = new Credit_Card__c(Opportunity__c = opportunityId);
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
        
        /*if(!cardSingleErrorOnSave)
        {
            Credit_Card__c cardNew = new Credit_Card__c(Opportunity__c = opportunityId);
            
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
            // reindexing
            for(Integer i = 0; i < cardWrapperLst.size(); i++)
            {
                cardWrapperLst[i].cardIndex = i;
            }
        }*/
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
        //refreshcardances();
    }
    
    // method to cave payable
    public void saveCreditCards()
    {
        String cardMsgStr = '';
        cardSingleErrorOnSave = false;
        Boolean cardIsUpdated = false;
        List<Credit_Card__c> cardListToUpdate = new List<Credit_Card__c>();
        Map<Integer, Integer> cardErrorToWraperIndexMap = new map<Integer, Integer>();
        
        List<Credit_Card__c> cardTempLst = getCreditCardFromDB(opportunityId, cardBlockSize, cardOffsetsize, cardFieldsApiSet, cardSortExpression, cardSortDirection);
        cardFromDBMap = getCreditCardMapFromList(cardTempLst);
        
        for(CreditCardWrapper cardWraperInstance :cardWrapperLst) 
        {
            Credit_Card__c cardDBObj = cardFromDBMap.get(cardWraperInstance.Card.Id);
            if(cardDBObj != null)
            {
                cardIsUpdated = false;
                for(String cardFieldInstance :cardFieldsApiSet)
                {
                    if(!cardFieldInstance.contains('__r.Name')) 
                    {
                        cardIsUpdated  = cardIsUpdated ||(cardWraperInstance.Card.get(CardFieldInstance) != cardDBObj.get(cardFieldInstance));
                    }
                }
            }
            else
            {
                if(!cardIsNewBtnPress)
                {
                    cardIsUpdated = true;
                }
            }
            if(cardIsUpdated)
            {
                cardListToUpdate.add(cardWraperInstance.card);
                cardErrorToWraperIndexMap.put(cardListToUpdate.size()-1, cardWraperInstance.cardIndex);
            }
            cardWraperInstance.cardEdit = false;
        }

        try
        {
            if(cardListToUpdate != null && cardListToUpdate.size() >0)
            {
                List<Database.upsertResult> results = Database.upsert(cardListToUpdate, false);
                for (Integer i =0; i < results.size(); i++) 
                {
                    if (!results[i].isSuccess())
                    {
                        for (Database.Error err : results[i].getErrors())
                        {
                              //+1 is added for Display on VF page only  
                              cardMsgStr = cardMsgStr + 'Error Record '+(cardErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!cardMsgStr.contains('insufficient access rights on object id'))
                        {
                            cardWrapperLst[cardErrorToWraperIndexMap.get(i)].cardEdit = true; 
                            //note on insuffivient privilage
                            cardSingleErrorOnSave = true;
                        }
                    }
                    /*else
                    {
                         cardWrapperLst[cardErrorToWraperIndexMap.get(i)].cardEdit = false;
                    }*/
                }
                if(cardSingleErrorOnSave == false && !cardIsNewBtnPress)
                {
                  cardLst = getCreditCardFromDB(opportunityId, cardBlockSize, cardOffsetsize, cardFieldsApiSet, cardSortExpression, cardSortDirection);
                  cardFieldToSumMap = getCreditCardFieldSum(cardAggregateQueryStr);
                  cardFirstRun = true;
                }
                if(String.isNotBlank(cardMsgStr)) 
                {
                       ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, cardMsgStr));
                }
            }
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             cardFirstRun = false;
        }
    }
    
    // method to edit all commissions
    public void editAllCreditCards()
    {
        cardFirstRun = false;
        for(Integer i=0; i< cardWrapperLst.size(); i++) 
        {
            cardWrapperLst[i].cardEdit = true;
        }
    }
    
    // method to refresh
    public void refreshCreditCards()
    {
        cardLst = getCreditCardFromDB(opportunityId, cardBlockSize, cardOffsetsize, cardFieldsApiSet, cardSortExpression, cardSortDirection);
        cardFirstRun = true;
    }
    
    //method for the first page of list to be displayed
    public void beginningCreditCards() 
    {
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