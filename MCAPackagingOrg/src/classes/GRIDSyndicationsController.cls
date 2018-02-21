global with sharing class GRIDSyndicationsController {
    
    public static Map<String, Schema.SObjectType> globalMap;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    
    public Map<String, Decimal> syndFieldToSumMap                                       {get; set;}
    public List<Schema.FieldSetMember> syndFieldsetList                                 {get; set;}
    public Set<String> syndFieldSumSet                                                  {get; set;}
    public Integer syndOffsetSize                                                       {get; set;}
    public Integer syndBlockSize                                                        {get; set;}
    public Integer syndRecordCount                                                      {get; set;}
    public Integer syndIndexToRemove                                                    {get; set;}
    public String syndSortExpression                                                    {get; set;}
    public string syndSortDirection                                                     {get; set;}
    public Boolean syndSingleErrorOnSave                                                {get; set;}
   
    public String syndFieldType;
    public String syndQueryStr;
    public String syndFieldsString = '';
    public String syndAggregateQueryStr = '';
    public Map<Id, Syndication__c> syndFromDbMap;
    public List<SyndWrapper> syndWrapperLst;
    public List<Syndication__c> syndLst;
    public Set<String> syndFieldsApiSet;
    public Boolean syndFirstRun;
    public Boolean syndIsNewBtnPress;
    public Boolean syndEditAll                                                          {get; set;}
    public String syndSortExprFieldApi                                                  {get; set;}
    public String opportunityId;
    public Boolean syndIsRefrenceField                                                  {get; set;}
    public String syndRefrenceFieldLabel                                                {get; set;}
    public boolean syndIsDisable                                                        {get; set;}
    // Editall Attribute
    public Boolean syndEditAllFlag                                                      {get; set;}
    // boolean to handle save success message on navigation
    public Boolean syndPageNavigated;
    
    // constructor
    public GRIDSyndicationsController()
    {
   
        if(GRIDOnloadStaticVariable.flipSynd())
        {
            syndIsDisable = false;
            opportunityId = Apexpages.currentPage().getParameters().get('id');
            if(opportunityId == null || opportunityId == '') {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, 'Opportunity does not exist.'));
                syndIsDisable = true;
            }
            
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
            
            syndIsNewBtnPress = false;
            syndOffsetSize = 0;
            syndBlockSize = (Integer)customMetaDataSettingMap.get('Syndications').PageSize__c;
            syndLst = new List<Syndication__c>();
            syndFieldsApiSet = new Set<String>();
            syndWrapperLst = new List<SyndWrapper>();
            syndFieldSumSet = new Set<String>();
            syndFieldToSumMap = new Map<String, Decimal>();
            syndFromDbMap = new Map<Id, Syndication__c>();
            syndSortDirection = 'DESC';
            syndSortExpression = 'CreatedDate';
            syndFieldType = '';
            syndQueryStr = '';
            syndEditAll = false;
            syndPageNavigated = false;
            
            Schema.DescribeSObjectResult syndDescbResult = globalMap.get(customMetaDataSettingMap.get('Syndications').Object_API_Name__c).getDescribe();
            syndFieldsetList = syndDescbResult.FieldSets.getMap().get(customMetaDataSettingMap.get('Syndications').Fieldset_Name__c).getFields();
            
            GRIDUtility.ReferenceFieldWrapper refWrap = new GRIDUtility.ReferenceFieldWrapper(syndFieldsetList, ' ', false);
            refWrap = GRIDUtility.isReferenceFieldPresent(refWrap);
            syndIsRefrenceField = refWrap.isReferenceField;
            syndRefrenceFieldLabel = refWrap.refrenceFieldLabel;
            system.debug('>>> syndIsRefrenceField : '+syndIsRefrenceField);
            if(!syndIsRefrenceField)
            {
                syndAggregateQueryStr = buildSyndAggregateQuery(syndFieldsetList);
                syndFieldToSumMap = getSyndFieldSum(syndAggregateQueryStr);
                syndFieldsApiSet = buildSetFromListSynd(syndFieldsetList);
                if(opportunityId != null && opportunityId != '')
                    syndLst = getSyndicationsFromDB(opportunityId, syndBlockSize, syndOffsetSize, syndFieldsApiSet, syndSortExpression, syndSortDirection);
                syndFirstRun = true;
            }
        }
    }
    
    // metyhod to get syndications from DB
    public List<Syndication__c> getSyndicationsFromDB(String pOpportunityId, Integer pSyndBlockSize, Integer pSyndOffsetSize, Set<String> pSyndFieldsApiSet,
                                                      String pSyndSortExpression, String pSyndSortDirection) 
    {
        
        if(pOpportunityId <> null && pOpportunityId <> '') 
        {
            syndFieldsString = MCAUtility.getStringfromSet(pSyndFieldsApiSet, null);
            syndQueryStr = 'SELECT ' +syndFieldsString+ 
                           ' FROM Syndication__c WHERE Opportunity__c =:pOpportunityId ORDER BY '+pSyndSortExpression+' '+pSyndSortDirection+' NULLS LAST LIMIT '
                           +pSyndBlockSize+' Offset ' +pSyndOffsetSize;
            return database.query(syndQueryStr);
        }
        return new List<Syndication__c>();
    }
    
    // method to get List wrapper 
    public List<SyndWrapper> getSyndWrapperLst()
    {
        if(syndFirstRun)
        {
            syndWrapperLst = new List<SyndWrapper>();
        }
        if(syndLst <> null && syndLst.size() > 0 ) {
            if(syndFirstRun)
            {
                //syndWrapperLst = new List<SyndWrapper>();
                for (Integer i = 0; i < syndLst.size(); i++) 
                {
                    syndWrapperLst.add(new SyndWrapper(syndLst[i], i, syndEditAllFlag));
                }
                syndFirstRun = false;
            }
        }
       // syndFieldToSumMap = getSyndFieldSum(syndAggregateQueryStr);

        return syndWrapperLst;
    }
    
    // method to create new syndications
    public void newSynd()
    {
        syndIsNewBtnPress = true;
        if(!syndEditAll)
        {
            saveAllSynd();
        }
        else
        {
            syndSingleErrorOnSave = false;
        }
        
        syndIsNewBtnPress = false;
   
        if(!syndSingleErrorOnSave)
        {
            // to add new record only on first page
            if(syndOffsetsize <> 0) 
            {
                syndOffsetsize = 0;
                beginningSynd();
            }
            
            Syndication__c syndNew = new Syndication__c(Opportunity__c = opportunityId, Memo__c = 'abc',
                                                        Syndication_Amt__c = 3000, 
                                                        Servicing_Fee__c = 200);
            if(syndWrapperLst.size() > 0 && syndLst.size() > 0)
            {
                syndWrapperLst.add(0,new SyndWrapper(syndNew, null, true));
                syndLst.add(0,syndNew);
            }
            else
            {
                syndWrapperLst.add(new SyndWrapper(syndNew, null, true));
                syndLst.add(syndNew);
            }

            // reindexing
            for(Integer i=0; i<syndWrapperLst.size(); i++)
            {
                syndWrapperLst[i].syndIndex = i;
            }
        }
    }
    
    // method to editAll syndications
    public void editAllSynd() 
    {
        syndFirstRun = false;
        syndEditAll = true;
        for(Integer i = 0; i < syndWrapperLst.size(); i++) 
        {
            syndWrapperLst[i].syndEdit = true;
        }
        
    }
    
    // method to save syndictaions
    public void saveAllSynd()
    {
       
        String syndMsgStr = '';
        String syndSuccessMsgStr ='';
        syndSingleErrorOnSave = false;
        Boolean syndIsUpdated = false;
        
        syndEditAll = false; 
        List<Syndication__c> syndListToUpdate = new List<Syndication__c>();
        Map<Integer, Integer> syndErrorToWraperIndexMap = new map<Integer, Integer>();
        List<Syndication__c> syndTempLst = getSyndicationsFromDB(opportunityId, syndBlockSize, syndOffsetSize, syndFieldsApiSet, syndSortExpression, syndSortDirection);
        syndFromDbMap = getSyndMapFromList(syndTempLst);
        
        for(SyndWrapper syndWrapperInstance :syndWrapperLst) 
        {
            Syndication__c syndDBObj = syndFromDbMap.get(syndWrapperInstance.synd.Id);
            if(syndDBObj != null)
            {
                syndIsUpdated = false;
                for(String syndFieldInstance :syndFieldsApiSet)
                {
                    // check old and new value only if field is direct field on object and not on reference object
                    if(!syndFieldInstance.contains('.Name')) 
                    {
                        syndIsUpdated  = syndIsUpdated ||(syndWrapperInstance.synd.get(syndFieldInstance) != syndDBObj.get(syndFieldInstance));
                    }
                }
            }
            else
            {
                if(!syndIsNewBtnPress) 
                {
                    syndIsUpdated = true;
                }
            }

            if(syndIsUpdated) 
            {
                syndListToUpdate.add(syndWrapperInstance.synd);
                syndErrorToWraperIndexMap.put(syndListToUpdate.size()-1, syndWrapperInstance.syndIndex);
            }
            syndWrapperInstance.syndEdit = syndEditAllFlag;
        }

        try
        {
            if(syndListToUpdate != null && syndListToUpdate.size() >0)
            {
                List<Database.upsertResult> results = Database.upsert(syndListToUpdate, false);
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
                                 syndWrapperLst[syndErrorToWraperIndexMap.get(i)].syndEdit = true; 
                                 
                             }*/
                             if(!recordError.contains('insufficient access rights on'))
                             {
                                 syndWrapperLst[syndErrorToWraperIndexMap.get(i)].syndEdit = true; 
                             }
                             syndSingleErrorOnSave = true;
                             syndMsgStr = syndMsgStr + 'Error Record '+(syndErrorToWraperIndexMap.get(i)+1)+' : '+ recordError + '<br />'; 
                            
                        }
                    }
                    else if(results[i].isSuccess())
                    {
                         syndSuccessMsgStr = syndSuccessMsgStr+ 'Success Record '+(syndErrorToWraperIndexMap.get(i)+1)+' : '+ 'saved successfully!' + '<br />';
                         syndWrapperLst[syndErrorToWraperIndexMap.get(i)].syndEdit = syndEditAllFlag;
                    }
                }
                if(syndSingleErrorOnSave == false && !syndIsNewBtnPress)
                {
                    syndLst = getSyndicationsFromDB(opportunityId, syndBlockSize, syndOffsetSize, syndFieldsApiSet, syndSortExpression, syndSortDirection);
                    syndFieldToSumMap = getSyndFieldSum(syndAggregateQueryStr);
                    syndFirstRun = true;
                    
                }
                if(String.isNotBlank(syndMsgStr) || String.isNotBlank(syndSuccessMsgStr)) 
                {
                    if(syndPageNavigated)
                    {
                        syndPageNavigated = false;
                        syndSuccessMsgStr = 'Last changes made by you were saved successfully!';
                    }
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,syndMsgStr  +'<br/>'+ syndSuccessMsgStr));
                }
                
              
            }
            
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             syndFirstRun = false;
        }
    }
    
    // method to build a map of Id-to-syndications from List
    public Map<Id, Syndication__c> getSyndMapFromList(List<Syndication__c> pSyndLst) 
    {
        syndFromDbMap.clear();
        for(Syndication__c syndInstance :pSyndLst) 
        {
            syndFromDbMap.put(syndInstance.Id, syndInstance);
        }
        return syndFromDbMap;
    }
    
    // method to refresh the syndiaction table
    public void refreshSynd()
    {
        
            syndLst = getSyndicationsFromDB(opportunityId, syndBlockSize, syndOffsetSize, syndFieldsApiSet, syndSortExpression, syndSortDirection);
            syndFieldToSumMap = getSyndFieldSum(syndAggregateQueryStr);
            syndFirstRun = true;
        
    }
    
    // method to delete syndications
    public void deleteSynd()
    {
        if(syndWrapperLst[syndIndexToRemove].synd.Id != null) 
         {
            try
            {
                delete syndWrapperLst[syndIndexToRemove].synd;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
         
         syndLst.remove(syndIndexToRemove);
         syndWrapperLst.remove(syndIndexToRemove);
         // reindexing
            for(Integer i=0; i<syndWrapperLst.size(); i++)
            {
                syndWrapperLst[i].syndIndex = i;
            }
            if(syndWrapperLst.size() <= 0)
            {
                refreshSynd();
            }
            syndFieldToSumMap = getSyndFieldSum(syndAggregateQueryStr);
         //refreshSynd();
    }
    
    // method to build dynamic query for SUM and COUNT
    public String buildSyndAggregateQuery(List<Schema.FieldSetMember> pSyndFieldsetList)
    {
        syndAggregateQueryStr = 'SELECT ';
        
        for(Schema.FieldSetMember fieldInstance :pSyndFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency') 
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
            {
                syndAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                syndFieldSumSet.add(fieldInstance.getFieldPath());
            }
            syndFieldToSumMap.put(fieldInstance.getFieldPath(), -999.999);
        }
        syndAggregateQueryStr += 'COUNT(Id) syndCount FROM Syndication__c Where Opportunity__c = \''+opportunityId+'\'';
        
        return syndAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getSyndFieldSum(String pSyndAggregateQueryStr)
    {
        if(opportunityId <> null && opportunityId <> '')
        {
            List<SObject> syndSumQueryResult = new List<SObject>();
            syndSumQueryResult = Database.query(pSyndAggregateQueryStr);
            
            for(String fieldName :syndFieldSumSet) 
            {
                syndFieldToSumMap.put(fieldName,0);
                if(syndSumQueryResult[0].get(fieldName) != null)
                {
                    syndFieldToSumMap.put(fieldName, (Decimal)syndSumQueryResult[0].get(fieldName)); 
                }
            }
            syndRecordCount = (Integer)syndSumQueryResult[0].get('syndCount');
           
            return syndFieldToSumMap;
        }
        syndRecordCount = 0;
        return null;
    }
    
    //method for the first page of list to be displayed
    public void beginningSynd() 
    {
        syndPageNavigated = true;
        saveAllSynd();
        if(!syndSingleErrorOnSave) 
        {
            syndOffsetsize = 0;
            syndLst = getSyndicationsFromDB(opportunityId, syndBlockSize, syndOffsetSize, syndFieldsApiSet, syndSortExpression, syndSortDirection);
            syndFirstRun = true;
        }
    }
    
    //method for previous page of list to be displayed
    public void previousSynd() 
    {
        syndPageNavigated = true;
        saveAllSynd();
        if(!syndSingleErrorOnSave && syndBlockSize <= syndOffsetSize) 
        {
            syndOffsetSize = syndOffsetSize - syndBlockSize;
            syndLst = getSyndicationsFromDB(opportunityId, syndBlockSize, syndOffsetSize, syndFieldsApiSet, syndSortExpression, syndSortDirection);
            syndFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void nextSynd() 
    {
        syndPageNavigated = true;
        saveAllSynd();
        if(!syndSingleErrorOnSave && syndOffsetsize <= syndRecordCount) 
        {
            syndOffsetSize = syndOffsetsize + syndBlockSize;
            syndLst = getSyndicationsFromDB(opportunityId, syndBlockSize, syndOffsetsize, syndFieldsApiSet, syndSortExpression, syndSortDirection);
            syndFirstRun = true;
        }
    }
    
    //method for last page of list to be displayed
    public void endSynd() 
    {
        syndPageNavigated = true;
        saveAllSynd();
        if(!syndSingleErrorOnSave && math.mod(syndRecordCount, syndBlockSize) == 0){
            syndOffsetsize = syndBlockSize * ((syndRecordCount/syndBlockSize)-1);
        } else if (!syndSingleErrorOnSave && math.mod(syndRecordCount, syndBlockSize) != 0){
            syndOffsetsize = syndBlockSize * ((syndRecordCount/syndBlockSize));
        }
        syndLst = getSyndicationsFromDB(opportunityId, syndBlockSize, syndOffsetSize, syndFieldsApiSet, syndSortExpression, syndSortDirection);
        syndFirstRun = true;
    }
    
    //method to sort list of syndicates
    public void sortSynd()
    {
            string syndReferenceFieldName = '';
            syndFieldType = Apexpages.currentPage().getParameters().get('syndTypeParam');
            if(syndFieldType.equalsIgnoreCase('REFERENCE'))
            {
                if(syndSortExpression.contains('__c'))
                {
                    syndReferenceFieldName += syndSortExpression.substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    syndReferenceFieldName += syndSortExpression.substringBefore('Id')+'.Name';
                }
                syndSortExpression = string.valueOf(syndReferenceFieldName);
            }
            refreshSynd();
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromListSynd(List<Schema.FieldSetMember> pSyndFieldsetList)
    {
        String syndReferenceField;
        for(Schema.FieldSetMember fieldInstance :pSyndFieldsetList)
        {
            
            syndFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                syndReferenceField = '';
                if(fieldInstance.getfieldPath().contains('__c'))
                {
                    syndReferenceField += fieldInstance.getfieldPath().substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    syndReferenceField += fieldInstance.getfieldPath().substringBefore('Id')+'.Name';
                }
                syndFieldsApiSet.add(syndReferenceField);
            }
        }
        return syndFieldsApiSet;
    }
    
    // wrapper class
    public class SyndWrapper 
    {
        public Syndication__c synd                                                       {get;set;}
        public Integer syndIndex                                                         {get;set;}
        public Boolean syndEdit                                                          {get;set;}
        public SyndWrapper(Syndication__c syndInstance, Integer pSyndIndex, Boolean pSyndEdit) 
        {
            synd = syndInstance;
            syndIndex = pSyndIndex;
            syndEdit = pSyndEdit;
        }
    }

}