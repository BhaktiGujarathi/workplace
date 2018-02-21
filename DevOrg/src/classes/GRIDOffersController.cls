public with sharing class GRIDOffersController {
    
    public Id OpportunityId;
    public List<Offer__c> offrLst;
    public Map<Id, Offer__c> offrFromDbMap;
    public List<OfferWrapper> offrWrapperLst;
    public String offrAggregateQueryStr = '';
    public String offrFieldsString = '';
    public Set<String> offrFieldsApiSet;
    public Boolean offrFirstRun;
    public Boolean offrIsNewBtnPress;
    public Boolean offrSingleErrorOnSave;
    public String offrFieldType;
    
    public static Map<String, Schema.SObjectType> globalMap;

    public List<Schema.FieldSetMember> offrFieldsetList                                 {get; set;}
    public Set<string> offrFieldSumSet                                                  {get; set;}
    public Map<String, Decimal> offrFieldToMaxMap                                       {get; set;}
    public Map<String, Decimal> offrFieldToMinMap                                       {get; set;}
    public Integer offrRecordCount                                                      {get; set;}
    public Integer offrBlockSize                                                        {get; set;}
    public Integer offrOffsetsize                                                       {get; set;}
    public Integer offrIndexToRemove                                                    {get; set;}
    public string offrSortDirection                                                      {get; set;}
    public String offrSortExpression                                                     {get; set;}
    
    public GRIDOffersController() 
    {
        if(GRIDOnloadStaticVariable.flipOffer())
        {
        
            opportunityId = Apexpages.currentPage().getParameters().get('id');
        
            offrBlockSize = (Integer)GRIDTabSetting__c.getValues('Offer').PageSize__c;
            offrOffsetsize = 0;
    
            offrLst = new List<Offer__c>();
            offrFromDbMap = new Map<Id, Offer__c>();
            offrWrapperLst = new List<OfferWrapper>();
            offrFieldToMaxMap = new Map<String, Decimal>();
            offrFieldToMinMap = new Map<String, Decimal>();
            offrFieldSumSet = new Set<String>();
            offrFieldsApiSet = new Set<String>();
            offrFieldsetList = new List<Schema.FieldSetMember>();
            offrIsNewBtnPress = false;
            offrSortDirection = 'DESC';
            offrSortExpression = 'CreatedDate';
            offrFieldType = '';
        
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            Schema.DescribeSObjectResult offrDescbResult = globalMap.get('Offer__c').getDescribe();
            offrFieldsetList = offrDescbResult.FieldSets.getMap().get(GRIDTabSetting__c.getValues('Offer').Fieldset_Name__c).getFields();
        
            offrAggregateQueryStr = buildOfferAggregateQuery(offrFieldsetList);
            offrFieldsApiSet = buildSetFromFieldListOffer(offrFieldsetList);
            system.debug('>>> offrFieldsApiSet : '+offrFieldsApiSet);
            offrLst = getOfferFromDB(opportunityId, offrBlockSize, offrOffsetsize, offrFieldsApiSet, offrSortExpression, offrSortDirection);
            offrFirstRun = true;
        }
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListOffer(List<Schema.FieldSetMember> pOffrFieldsetList)
    {
        String offrReferenceField;
        for(Schema.FieldSetMember fieldInstance :pOffrFieldsetList)
        {
            offrReferenceField = '';
            offrFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                if(fieldInstance.getfieldPath().contains('__c'))
                {
                    offrReferenceField += fieldInstance.getfieldPath().substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    offrReferenceField += fieldInstance.getfieldPath().substringBefore('Id')+'.Name';
                }
                offrFieldsApiSet.add(offrReferenceField);
            }
        }
        
        return offrFieldsApiSet;
    }
    
    // method to build dynamic query for SUM and COUNT
    public String buildOfferAggregateQuery(List<Schema.FieldSetMember> pOffrFieldsetList)
    {
        offrAggregateQueryStr = 'SELECT ';
        
        for(Schema.FieldSetMember fieldInstance :pOffrFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency') 
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double'))
            {
                offrAggregateQueryStr += 'MAX('+fieldInstance.getFieldPath()+') '+'Max'+fieldInstance.getFieldPath()+ ', ';
                offrAggregateQueryStr += 'MIN('+fieldInstance.getFieldPath()+') '+'Min'+fieldInstance.getFieldPath()+ ', ';
                offrFieldSumSet.add(fieldInstance.getFieldPath());
                
            }
            offrFieldToMaxMap.put(fieldInstance.getFieldPath(), -999.999);
            offrFieldToMinMap.put(fieldInstance.getFieldPath(), -999.999);
        }
        
        offrAggregateQueryStr += 'COUNT(Id) offrCount FROM Offer__c Where Opportunity__c = \''+opportunityId+'\'';
        
        return offrAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public void getOfferFieldSum(String pOffrAggregateQueryStr)
    {
        List<SObject> offrSumQueryResult = new List<SObject>();
        offrSumQueryResult = Database.query(pOffrAggregateQueryStr);
        
        for(String fieldName :offrFieldSumSet) 
        {
            if(offrSumQueryResult[0].get('Min'+fieldName) != null)
            {
                offrFieldToMinMap.put(fieldName, (Decimal)offrSumQueryResult[0].get('Min'+fieldName)); 
            }
            if(offrSumQueryResult[0].get('Max'+fieldName) != null)
            {
                offrFieldToMaxMap.put(fieldName, (Decimal)offrSumQueryResult[0].get('Max'+fieldName)); 
            }
        }
        offrRecordCount = (Integer)offrSumQueryResult[0].get('offrCount');
       
    }
    
    // method to get offrables from DB
    public List<Offer__c> getOfferFromDB(Id pOpportunityId, Integer pOffrBlockSize, Integer pOffrOffsetSize, Set<String> pOffrFieldsApiSet,
                                         String pOffrSortExpression, String pOffrSortDirection)  
    {
        //offrLst.clear();
        String offrQueryStr = '';
        offrFieldsString = DEWUtility.getStringfromSet(pOffrFieldsApiSet, null);
        
        offrQueryStr = 'Select ' +offrFieldsString+ 
                        ' From Offer__c Where Opportunity__c =:pOpportunityId ORDER BY '+pOffrSortExpression+' '+pOffrSortDirection+' NULLS LAST LIMIT '
                        +pOffrBlockSize+' Offset ' +pOffrOffsetSize;
        system.debug('>>> offrQueryStr : '+offrQueryStr);
        return database.query(offrQueryStr);
    }
    
    // method to get the wrapper list
    public List<OfferWrapper> getOffrWrapperLst() 
    {
        if(offrFirstRun)
        {
            offrWrapperLst = new List<OfferWrapper>();
            for (Integer i = 0; i < offrLst.size(); i++) 
            {
                offrWrapperLst.add(new OfferWrapper(offrLst[i], i, false));
            }
            // moved inside if condition for getting aggregate results only if firstrun is true
            getOfferFieldSum(offrAggregateQueryStr);
            offrFirstRun = false;
        }
        
        return offrWrapperLst;
    }
    
    // method to build a map from a list from DB
    public Map<Id, Offer__c> getOfferMapFromList(List<Offer__c> pOffrLst) 
    {
        offrFromDbMap.clear();
        for(Offer__c offrInstance :pOffrLst) 
        {
            offrFromDbMap.put(offrInstance.Id, offrInstance);
        }
        return offrFromDbMap;
    }
    
    // method to create new offrables
    public void newOffer() 
    {
        offrIsNewBtnPress = true;
        saveOffers();
        offrIsNewBtnPress = false;
        
        if(!offrSingleErrorOnSave)
        {
            // to add new record only on first page
            if(offrOffsetsize <> 0) 
            {
                offrOffsetsize = 0;
                beginningOffers();
            }
            
            Offer__c offrNew = new Offer__c(Opportunity__c = opportunityId);
            
             /*need to add at 0th index if list size > 0 else simple add will work*/
               if(offrWrapperLst.size() > 0 && offrLst.size() > 0)
               {
                 offrWrapperLst.add(0,new OfferWrapper(offrNew, null, true));
                 offrLst.add(0,offrNew);
               }
               else
               {
                 offrWrapperLst.add(new OfferWrapper(offrNew, null, true));
                 offrLst.add(offrNew);
               }
            
            // reindexing
            for(Integer i=0; i<offrWrapperLst.size(); i++)
            {
                offrWrapperLst[i].offrIndex = i;
            }
        }
    }
    
    // method to delete offrables
    public void deleteOffer()
    {
        if(offrWrapperLst[offrIndexToRemove].offr.Id != null) 
         {
            try
            {
                delete offrWrapperLst[offrIndexToRemove].offr;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
         
         offrLst.remove(offrIndexToRemove);
         offrWrapperLst.remove(offrIndexToRemove);
         
          //re-indexing
             for(Integer i=0;i<offrWrapperLst.size();i++)
             {
               offrWrapperLst[i].offrIndex = i;
             }
        // refreshCommissions();
        getOfferFieldSum(offrAggregateQueryStr);
    }
    
    // method to cave offrable
    public void saveOffers()
    {
        String offrMsgStr = '';
        offrSingleErrorOnSave = false;
        Boolean offrIsUpdated = false;
        List<Offer__c> offrListToUpdate = new List<Offer__c>();
        Map<Integer, Integer> offrErrorToWraperIndexMap = new map<Integer, Integer>();
        
        List<Offer__c> offrTempLst = getOfferFromDB(opportunityId, offrBlockSize, offrOffsetsize, offrFieldsApiSet, offrSortExpression, offrSortDirection);
        offrFromDBMap = getOfferMapFromList(offrTempLst);
        
        for(OfferWrapper offerWraperInstance :offrWrapperLst) 
        {
            Offer__c offrDBObj = offrFromDBMap.get(offerWraperInstance.offr.Id);
            if(offrDBObj != null)
            {
                offrIsUpdated = false;
                for(String offrFieldInstance :offrFieldsApiSet)
                {
                    if(!offrFieldInstance.contains('__r.Name')) 
                    {
                        offrIsUpdated  = offrIsUpdated ||(offerWraperInstance.offr.get(offrFieldInstance) != offrDBObj.get(offrFieldInstance));
                    }
                }
            }
            else
            {
                   if(!offrIsNewBtnPress) 
                   {
                     offrIsUpdated = true;
                   }
            }

            if(offrIsUpdated) 
            {
                offrListToUpdate.add(offerWraperInstance.offr);
                offrErrorToWraperIndexMap.put(offrListToUpdate.size()-1, offerWraperInstance.offrIndex);
            }
            
            offerWraperInstance.offrEdit = false;
        }
        
        try
        {
            if(offrListToUpdate != null && offrListToUpdate.size() >0)
            {
                List<Database.upsertResult> results = Database.upsert(offrListToUpdate, false);
                for (Integer i =0; i < results.size(); i++) 
                {
                    if (!results[i].isSuccess())
                    {
                        for (Database.Error err : results[i].getErrors())
                        {
                              //+1 is added for Display on VF page only  
                              offrMsgStr = offrMsgStr + 'Error Record '+(offrErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!offrMsgStr.contains('insufficient access rights on object id'))
                        {
                            offrWrapperLst[offrErrorToWraperIndexMap.get(i)].offrEdit = true; 
                            //note on insuffivient privilage
                            offrSingleErrorOnSave = true;
                        }
                    }
                   /* else
                    {
                         offrWrapperLst[offrErrorToWraperIndexMap.get(i)].offrEdit = false;
                    }*/
                }
                if(offrSingleErrorOnSave == false && !offrIsNewBtnPress)
                {
                  offrLst = getOfferFromDB(opportunityId, offrBlockSize, offrOffsetsize, offrFieldsApiSet, offrSortExpression, offrSortDirection);
                  //offrFieldToSumMap = 
                  getOfferFieldSum(offrAggregateQueryStr);
                  offrFirstRun = true;
                }
                if(String.isNotBlank(offrMsgStr)) 
                {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,offrMsgStr));
                }
            }
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             offrFirstRun = false;
        }
    }
    
    //method for the first page of list to be displayed
    public void beginningOffers() 
    {
        saveOffers();
        if(!offrSingleErrorOnSave) 
        {
            offrOffsetsize = 0;
            offrLst = getOfferFromDB(opportunityId, offrBlockSize, offrOffsetsize, offrFieldsApiSet, offrSortExpression, offrSortDirection);
            offrFirstRun = true;
        }
    }
    
    //method for previous page of list to be displayed
    public void previousOffers() 
    {
        saveOffers();
        if(!offrSingleErrorOnSave && offrBlockSize <= offrOffsetsize)
        {
            offrOffsetsize = offrOffsetsize - offrBlockSize;
            offrLst = getOfferFromDB(opportunityId, offrBlockSize, offrOffsetsize, offrFieldsApiSet, offrSortExpression, offrSortDirection);
            offrFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void nextOffers() 
    {
       saveOffers();
        if(!offrSingleErrorOnSave && offrOffsetsize <= offrRecordCount) 
        {
            offrOffsetsize = offrOffsetsize + offrBlockSize;
            offrLst = getOfferFromDB(opportunityId, offrBlockSize, offrOffsetsize, offrFieldsApiSet, offrSortExpression, offrSortDirection);
            offrFirstRun = true;
        }
    }
    
    //method for last page of list to be displayed
    public void endOffers() 
    {
        saveOffers();
        if(!offrSingleErrorOnSave && math.mod(offrRecordCount , offrBlockSize) == 0){
            offrOffsetsize = offrBlockSize * ((offrRecordCount/offrBlockSize)-1);
        } else if (!offrSingleErrorOnSave && math.mod(offrRecordCount , offrBlockSize) != 0){
            offrOffsetsize = offrBlockSize * ((offrRecordCount/offrBlockSize));
        }
            offrLst = getOfferFromDB(opportunityId, offrBlockSize, offrOffsetsize, offrFieldsApiSet, offrSortExpression, offrSortDirection);
            offrFirstRun = true;
    }
    
    // method to edit all commissions
    public void editAllOffers()
    {
        offrFirstRun = false;
        for(Integer i=0; i< offrWrapperLst.size(); i++) 
        {
            offrWrapperLst[i].offrEdit = true;
        }
    }
    
    // method to refresh
    public void refreshOffers() 
    {
        offrLst = getOfferFromDB(opportunityId, offrBlockSize, offrOffsetsize, offrFieldsApiSet, offrSortExpression, offrSortDirection);
        offrFirstRun = true;
    }
    
    //method to sort list of offers
    public void sortOffers()
    {
            string offrReferenceFieldName = '';
            offrFieldType = Apexpages.currentPage().getParameters().get('offrTypeParam');
            if(offrFieldType.equalsIgnoreCase('REFERENCE'))
            {
                if(offrSortExpression.contains('__c'))
                {
                    offrReferenceFieldName += offrSortExpression.substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    offrReferenceFieldName += offrSortExpression.substringBefore('Id')+'.Name';
                }
                offrSortExpression = string.valueOf(offrReferenceFieldName);
            }
            refreshOffers();
    }
    
    // wrapper for offers
    public class OfferWrapper
    {
        public Offer__c offr                                                             {get;set;}
        public Integer offrIndex                                                         {get;set;}
        public Boolean offrEdit                                                          {get;set;}
        public OfferWrapper(Offer__c offrInstance, Integer pOffrIndex, Boolean pOffrEdit) {
            offr = offrInstance;
            offrIndex = pOffrIndex;
            offrEdit = pOffrEdit;
        }
    }
    
}