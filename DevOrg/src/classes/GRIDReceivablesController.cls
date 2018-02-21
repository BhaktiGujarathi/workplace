public with sharing class GRIDReceivablesController 
{

   
    public Id OpportunityId;
    public List<Receivable__c> recLst;
    public Map<Id, Receivable__c> recFromDbMap;
    public List<ReceivableWrapper> recWrapperLst;
    public String recAggregateQueryStr = '';
    public String recFieldsString = '';
    public Set<String> recFieldsApiSet;
    public Boolean recFirstRun;
    public Boolean recIsNewBtnPress;
    public Boolean recSingleErrorOnSave;
    public String recFieldType;
    public Boolean recEditAll;
    
    public static Map<String, Schema.SObjectType> globalMap;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;

    public List<Schema.FieldSetMember> recFieldsetList                                  {get; set;}
    public Set<string> recFieldSumSet                                                   {get; set;}
    public Map<String, Decimal> recFieldToSumMap                                        {get; set;}
    public Integer recRecordCount                                                       {get; set;}
    public Integer recBlockSize                                                         {get; set;}
    public Integer recOffsetsize                                                        {get; set;}
    public Integer recIndexToRemove                                                     {get; set;}
    public string recSortDirection                                                      {get; set;}
    public String recSortExpression                                                     {get; set;}
    
  
    
    public GRIDReceivablesController() 
    {
        if(GRIDOnloadStaticVariable.flipReceivable())
        {
        
            opportunityId = Apexpages.currentPage().getParameters().get('id');
            
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
            
            recBlockSize = (Integer)customMetaDataSettingMap.get('Receivables').PageSize__c;
            recOffsetsize = 0;
    
            recLst = new List<Receivable__c>();
            recFromDbMap = new Map<Id, Receivable__c>();
            recWrapperLst = new List<ReceivableWrapper>();
            recFieldToSumMap = new Map<String, Decimal>();
            recFieldSumSet = new Set<String>();
            recFieldsApiSet = new Set<String>();
            recFieldsetList = new List<Schema.FieldSetMember>();
            recIsNewBtnPress = false;
            recSortDirection = 'DESC';
            recSortExpression = 'CreatedDate';
            recFieldType = '';
            recEditAll = false;
        
            Schema.DescribeSObjectResult recDescbResult = globalMap.get('Receivable__c').getDescribe();
            recFieldsetList = recDescbResult.FieldSets.getMap().get(customMetaDataSettingMap.get('Receivables').Fieldset_Name__c).getFields();
        
            recAggregateQueryStr = buildRecAggregateQuery(recFieldsetList);
            recFieldsApiSet = buildSetFromFieldListReceivable(recFieldsetList);
            recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet, recSortExpression, recSortDirection);
            recFirstRun = true;
        }
    }
        
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListReceivable(List<Schema.FieldSetMember> pRecFieldsetList)
    {
        String recReferenceField;
        for(Schema.FieldSetMember fieldInstance :pRecFieldsetList)
        {
            recReferenceField = '';
            recFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                if(fieldInstance.getfieldPath().contains('__c'))
                {
                    recReferenceField += fieldInstance.getfieldPath().substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    recReferenceField += fieldInstance.getfieldPath().substringBefore('Id')+'.Name';
                }
                recFieldsApiSet.add(recReferenceField);
            }
        }
        
        return recFieldsApiSet;
    }
    
    // method to build dynamic query for SUM and COUNT
    public String buildRecAggregateQuery(List<Schema.FieldSetMember> pRecFieldsetList)
    {
        recAggregateQueryStr = 'SELECT ';
        
        for(Schema.FieldSetMember fieldInstance :pRecFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency') 
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double'))
            {
                recAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                recFieldSumSet.add(fieldInstance.getFieldPath());
                
            }
            //recFieldsApiSet.add(fieldInstance.getfieldPath());
            recFieldToSumMap.put(fieldInstance.getFieldPath(), -999.999);
        }
        
        recAggregateQueryStr += 'COUNT(Id) recCount FROM Receivable__c Where Opportunity__c = \''+opportunityId+'\'';
        
        return recAggregateQueryStr;
    }

    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getRecFieldSum(String pRecAggregateQueryStr)
    {
        List<SObject> recSumQueryResult = new List<SObject>();
        recSumQueryResult = Database.query(pRecAggregateQueryStr);
        
        for(String fieldName :recFieldSumSet) 
        {
            if(recSumQueryResult[0].get(fieldName) != null)
            {
                
                recFieldToSumMap.put(fieldName, (Decimal)recSumQueryResult[0].get(fieldName)); 
            }
        }
        recRecordCount = (Integer)recSumQueryResult[0].get('recCount');
       
        return recFieldToSumMap;
    }
    
    // method to get payables from DB
    public List<Receivable__c> getReceivableFromDB(Id pOpportunityId, Integer pRecBlockSize, Integer pRecOffsetSize, Set<String> pRecFieldsApiSet,
                                             String pRecSortExpression, String pRecSortDirection) 
    {
        
        String recQueryStr = '';
        recFieldsString = DEWUtility.getStringfromSet(pRecFieldsApiSet, null);
        recQueryStr = 'Select ' +recFieldsString+ 
                        ' From Receivable__c Where Opportunity__c =:pOpportunityId ORDER BY '+pRecSortExpression+' '+pRecSortDirection+' NULLS LAST LIMIT '
                        +pRecBlockSize+' Offset ' +pRecOffsetSize;

        return database.query(recQueryStr);
    }
    
    // method to get the wrapper list
    public List<ReceivableWrapper> getRecWrapperLst() 
    {
        if(recFirstRun)
        {
            recWrapperLst = new List<ReceivableWrapper>();
            for (Integer i = 0; i < recLst.size(); i++) 
            {
                recWrapperLst.add(new ReceivableWrapper(recLst[i], i, false));
            }
            // moved inside if condition for getting aggregate results only if firstrun is true
            recFieldToSumMap = getRecFieldSum(recAggregateQueryStr);
            recFirstRun = false;
        }
        
        return recWrapperLst;
    }
    
    // method to build a map from a list from DB
    public Map<Id, Receivable__c> getRecMapFromList(List<Receivable__c> pRecLst) 
    {
        recFromDbMap.clear();
        for(Receivable__c recInstance :pRecLst) 
        {
            recFromDbMap.put(recInstance.Id, recInstance);
        }
        return RecFromDbMap;
    }
    
    // method to create new Receivables
    public void newRec() 
    {
        recIsNewBtnPress = true;
        if(!recEditAll)
        {
            saveReceivables();
        }
        else
        {
            recSingleErrorOnSave = false;
        }
        recIsNewBtnPress = false;
        
        if(!recSingleErrorOnSave)
        {
            // to add new record only on first page
            if(recOffsetsize <> 0) 
            {
                recOffsetsize = 0;
                beginningReceivable();
            }
            
            Receivable__c recNew = new Receivable__c(Due_Date__c = system.today(),
                                               Opportunity__c = opportunityId,
                                               OwnerId = userinfo.getUserId());
            //recWrapperLst.add(0, new ReceivableWrapper(recNew, null, true));
           // recLst.add(0, recNew);
            
            
             /*need to add at 0th index if list size > 0 else simple add will work*/
               if(recWrapperLst.size() > 0 && recLst.size() > 0)
               {
                 recWrapperLst.add(0,new ReceivableWrapper(recNew, null, true));
                 recLst.add(0,recNew);
               }
               else
               {
                 recWrapperLst.add(new ReceivableWrapper(recNew, null, true));
                 recLst.add(recNew);
               }
            
            // reindexing
            for(Integer i=0; i<recWrapperLst.size(); i++)
            {
                recWrapperLst[i].recIndex = i;
            }
        }
    }
    
    // method to delete payables
    public void deleteRec()
    {
        if(recWrapperLst[recIndexToRemove].rec.Id != null) 
         {
            try
            {
                delete recWrapperLst[recIndexToRemove].rec;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
         
         recLst.remove(recIndexToRemove);
         recWrapperLst.remove(recIndexToRemove);
         
          //re-indexing
             for(Integer i=0;i<recWrapperLst.size();i++)
             {
               recWrapperLst[i].recIndex = i;
             }
        
        if(recWrapperLst.size() <= 0) 
        {
            refreshReceivables();
        }
        recFieldToSumMap = getRecFieldSum(recAggregateQueryStr);
    }
    
    // method to cave payable
    public void saveReceivables()
    {
        String recMsgStr = '';
        recSingleErrorOnSave = false;
        Boolean recIsUpdated = false;
        recEditAll = false;
        List<Receivable__c> recListToUpdate = new List<Receivable__c>();
        Map<Integer, Integer> recErrorToWraperIndexMap = new map<Integer, Integer>();
        
        List<Receivable__c> recTempLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet, recSortExpression, recSortDirection);
        recFromDBMap = getRecMapFromList(recTempLst);
        
        for(ReceivableWrapper recWraperInstance :recWrapperLst) 
        {
            Receivable__c recDBObj = recFromDBMap.get(recWraperInstance.rec.Id);
            if(recDBObj != null)
            {
                recIsUpdated = false;
                for(String recFieldInstance :recFieldsApiSet)
                {
                    if(!recFieldInstance.contains('.Name'))
                    {
                        recIsUpdated  = recIsUpdated ||(recWraperInstance.rec.get(recFieldInstance) != recDBObj.get(recFieldInstance));
                    }
                }
            }
            else
            {
                   if(!recIsNewBtnPress) 
                   {
                     recIsUpdated = true;
                   }
            }

            if(recIsUpdated) 
            {
                recListToUpdate.add(recWraperInstance.rec);
                recErrorToWraperIndexMap.put(recListToUpdate.size()-1, recWraperInstance.recIndex);
            }
            
            recWraperInstance.recEdit = false;
        }
        
        try
        {
            if(recListToUpdate != null && recListToUpdate.size() >0)
            {
                List<Database.upsertResult> results = Database.upsert(recListToUpdate, false);
                for (Integer i =0; i < results.size(); i++) 
                {
                    if (!results[i].isSuccess())
                    {
                        for (Database.Error err : results[i].getErrors())
                        {
                              //+1 is added for Display on VF page only  
                              recMsgStr = recMsgStr + 'Error Record '+(recErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!recMsgStr.contains('insufficient access rights on object id'))
                        {
                            recWrapperLst[recErrorToWraperIndexMap.get(i)].recEdit = true; 
                            //note on insuffivient privilage
                            recSingleErrorOnSave = true;
                        }
                    }
                   /* else
                    {
                         recWrapperLst[recErrorToWraperIndexMap.get(i)].recEdit = false;
                    }*/
                }
                if(recSingleErrorOnSave == false && !recIsNewBtnPress)
                {
                  recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet, recSortExpression, recSortDirection);
                  recFieldToSumMap = getRecFieldSum(recAggregateQueryStr);
                  recFirstRun = true;
                }
                if(String.isNotBlank(recMsgStr)) 
                {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,recMsgStr));
                }
            }
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             recFirstRun = false;
        }
    }
    
    //method for the first page of list to be displayed
    public void beginningReceivable() 
    {
        saveReceivables();
        if(!recSingleErrorOnSave) 
        {
            recOffsetsize = 0;
            recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet, recSortExpression, recSortDirection);
            recFirstRun = true;
        }
    }
    
    //method for previous page of list to be displayed
    public void previousReceivable() 
    {
        saveReceivables();
        if(!recSingleErrorOnSave && recBlockSize <= recOffsetsize)
        {
            recOffsetsize = recOffsetsize - recBlockSize;
            recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet, recSortExpression, recSortDirection);
            recFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void nextReceivable() 
    {  
       saveReceivables();
        if(!recSingleErrorOnSave && recOffsetsize <= recRecordCount) 
        {
            recOffsetsize = recOffsetsize + recBlockSize;
            recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet, recSortExpression, recSortDirection);
            recFirstRun = true;
        }
    }
    
    //method for last page of list to be displayed
    public void endReceivable() 
    {
        saveReceivables();
        if(!recSingleErrorOnSave && math.mod(recRecordCount , recBlockSize) == 0){
            recOffsetsize = recBlockSize * ((recRecordCount/recBlockSize)-1);
        } else if (!recSingleErrorOnSave && math.mod(recRecordCount , recBlockSize) != 0){
            recOffsetsize = recBlockSize * ((recRecordCount/recBlockSize));
        }
        
            recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet, recSortExpression, recSortDirection);
            recFirstRun = true;
    }
    
    //method to sort list of Payables
    public void sortReceivables()
    {
            string recReferenceFieldName = '';
            recFieldType = Apexpages.currentPage().getParameters().get('recTypeParam');
            if(recFieldType.equalsIgnoreCase('REFERENCE'))
            {
                if(recSortExpression.contains('__c'))
                {
                    recReferenceFieldName += recSortExpression.substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    recReferenceFieldName += recSortExpression.substringBefore('Id')+'.Name';
                }
                recSortExpression = string.valueOf(recReferenceFieldName);
            }
            
            refreshReceivables();
           
    }
    
    // method to edit all Receivable
    public void editAllReceivables()
    {
        recFirstRun = false;
        recEditAll = true;
        for(Integer i=0; i< recWrapperLst.size(); i++) 
        {
            recWrapperLst[i].recEdit = true;
        }

    }
    
    // method to refresh
    public void refreshReceivables() 
    {
        recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet, recSortExpression, recSortDirection);
        recFirstRun = true;
    }
    
    // wrapper for Receivable
    public class ReceivableWrapper
    {
        public Receivable__c rec                                                         {get;set;}
        public Integer recIndex                                                          {get;set;}
        public Boolean recEdit                                                           {get;set;}
        public ReceivableWrapper(Receivable__c recInstance, Integer pRecIndex, Boolean pRecEdit) 
        {
            rec = recInstance;
            recIndex = pRecIndex;
            recEdit = pRecEdit;
        }
    }
}