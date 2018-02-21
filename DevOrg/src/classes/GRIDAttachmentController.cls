public with sharing class GRIDAttachmentController {
    
    public Id oppId                                                                     {get; set;}
    public Opportunity opportunity                                                      {get; set;}
    public List<Attachment> attchmntLst;
    public Map<Id, Attachment> attchmntFromDbMap;
    public List<AttachmentWrapper> attchmntWrapperLst;
    public String attchmntAggregateQueryStr = '';
    public String attchmntFieldsString = '';
    public Set<String> attchmntFieldsApiSet;
    public Boolean attchmntFirstRun;
    public Boolean attchmntIsNewBtnPress;
    public Boolean attchmntSingleErrorOnSave;
    public String attchmntFieldType;
    
    public static Map<String, Schema.SObjectType> globalMap;
    
    public List<Schema.FieldSetMember> attchmntFieldsetList                             {get; set;}
    public Set<string> attchmntFieldSumSet                                              {get; set;}
    public Map<String, Decimal> attchmntFieldToSumMap                                   {get; set;}
    public Integer attchmntRecordCount                                                  {get; set;}
    public Integer attchmntBlockSize                                                    {get; set;}
    public Integer attchmntOffsetsize                                                   {get; set;}
    public Integer attchmntIndexToRemove                                                {get; set;}
    public string attchmntSortDirection                                                 {get; set;}
    public String attchmntSortExpression                                                {get; set;}
    
    // constructor
    public GRIDAttachmentController() 
    {
        if(GRIDOnloadStaticVariable.flipAttachment())
        {
            oppId = Apexpages.currentPage().getParameters().get('id');
            opportunity = [select Id, Name, AccountId from Opportunity where Id =: oppId];
            
            attchmntBlockSize = (Integer)GRIDTabSetting__c.getValues('Attachment').PageSize__c;
            attchmntOffsetsize = 0;
            attchmntRecordCount = 0;
            attchmntLst = new List<Attachment>();
            attchmntFromDbMap = new Map<Id, Attachment>();
            attchmntWrapperLst = new List<AttachmentWrapper>();
            attchmntFieldToSumMap = new Map<String, Decimal>();
            attchmntFieldSumSet = new Set<String>();
            attchmntFieldsApiSet = new Set<String>();
            attchmntFieldsetList = new List<Schema.FieldSetMember>();
            attchmntIsNewBtnPress = false;
            attchmntSortDirection = 'DESC';
            attchmntSortExpression = 'CreatedDate';
            attchmntFieldType = '';
            
            attchmntFieldsApiSet.add('ParentId');
            attchmntFieldsApiSet.add('Name');
            attchmntFieldsApiSet.add('IsPrivate');
            attchmntFieldsApiSet.add('Id');
            attchmntFieldsApiSet.add('Description');
            attchmntFieldsApiSet.add('ContentType');
            attchmntFieldsApiSet.add('BodyLength');
            attchmntFieldsApiSet.add('CreatedDate');
            attchmntFieldsApiSet.add('SystemModstamp');
            attchmntFieldsApiSet.add('Parent.Name');
                        
            attchmntAggregateQueryStr = buildAttachmentAggregateQuery();
            attchmntLst = getAttachmentFromDB(oppId, attchmntBlockSize, attchmntOffsetsize, attchmntFieldsApiSet, attchmntSortExpression, attchmntSortDirection);
            
            attchmntFirstRun = true;
        }
    }
    
    // method to build dynamic query for SUM and COUNT
    public String buildAttachmentAggregateQuery()
    {
        attchmntAggregateQueryStr = 'SELECT ';
        attchmntAggregateQueryStr += 'COUNT(Id) attchmntCount FROM Attachment Where  ParentId = \''+oppId+'\'';
        
        return attchmntAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getAttachmentFieldSum(String pAttchmntAggregateQueryStr)
    {
        List<SObject> attchmntSumQueryResult = new List<SObject>();
        attchmntSumQueryResult = Database.query(pAttchmntAggregateQueryStr);
        attchmntRecordCount = (Integer)attchmntSumQueryResult[0].get('attchmntCount');
         
        return attchmntFieldToSumMap;
    }
    
    // method to get Creditattchmnts from DB
    public List<Attachment> getAttachmentFromDB(Id pOppId, Integer pAttchmntBlockSize, Integer pAttchmntOffsetSize, Set<String> pAttchmntFieldsApiSet,
                                                String pAttchmntSortExpression, String pAttchmntSortDirection) 
    {
        String attchmntQueryStr = '';
        attchmntFieldsString = DEWUtility.getStringfromSet(pAttchmntFieldsApiSet, null);
        attchmntQueryStr = 'Select ' +attchmntFieldsString+ 
                        ' From Attachment Where ParentId =:pOppId ORDER BY '+pAttchmntSortExpression+' '+pAttchmntSortDirection+' NULLS LAST LIMIT '
                        +pAttchmntBlockSize+' Offset ' +pAttchmntOffsetSize;
        return database.query(attchmntQueryStr);
    }
    
    // method to get the wrapper list
    public List<AttachmentWrapper> getAttchmntWrapperLst() 
    {
        if(attchmntFirstRun)
        {
            attchmntWrapperLst = new List<AttachmentWrapper>();
            for (Integer i = 0; i < attchmntLst.size(); i++) 
            {
                attchmntWrapperLst.add(new AttachmentWrapper(attchmntLst[i], i, false));
            }
            attchmntFirstRun = false;
        }
        attchmntFieldToSumMap = getAttachmentFieldSum(attchmntAggregateQueryStr);

        return attchmntWrapperLst;
    }
    
    // method to edit all Attachment
    public void editAllAttachments()
    {
        attchmntFirstRun = false;
        for(Integer i=0; i< attchmntWrapperLst.size(); i++) 
        {
            attchmntWrapperLst[i].attchmntEdit = true;
        }
    }
    
    // method to refresh
    public void refreshAttachments()
    {
        attchmntLst = getAttachmentFromDB(oppId, attchmntBlockSize, attchmntOffsetsize, attchmntFieldsApiSet, attchmntSortExpression, attchmntSortDirection);
        attchmntFirstRun = true;
    }
    
    // method to delete
    public void deleteAttachment() 
    {
        if(attchmntWrapperLst[attchmntIndexToRemove].attchmnt.Id != null) 
         {
            try
            {
                delete attchmntWrapperLst[attchmntIndexToRemove].attchmnt;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
         
         attchmntLst.remove(attchmntIndexToRemove);
         attchmntWrapperLst.remove(attchmntIndexToRemove);
         
        //re-indexing
        for(Integer i=0;i < attchmntWrapperLst.size();i++)
        {
            attchmntWrapperLst[i].attchmntIndex = i;
        }
    }
    
    // method to save attachments
    public void saveAttachments()
    {
        String attchmntMsgStr = '';
        attchmntSingleErrorOnSave = false;
        Boolean attchmntIsUpdated = false;
        List<Attachment> attchmntListToUpdate = new List<Attachment>();
        Map<Integer, Integer> attchmntErrorToWraperIndexMap = new map<Integer, Integer>();
        
        List<Attachment> attchmntTempLst = getAttachmentFromDB(oppId, attchmntBlockSize, attchmntOffsetsize, attchmntFieldsApiSet, attchmntSortExpression, attchmntSortDirection);
        attchmntFromDBMap = getAttachmentMapFromList(attchmntTempLst);
        
        for(AttachmentWrapper attchmntWraperInstance :attchmntWrapperLst) 
        {
            Attachment attchmntDBObj = attchmntFromDBMap.get(attchmntWraperInstance.attchmnt.Id);
            if(attchmntDBObj != null)
            {
                attchmntIsUpdated = false;
                for(String attchmntFieldInstance :attchmntFieldsApiSet)
                {
                        attchmntIsUpdated  = attchmntIsUpdated ||(attchmntWraperInstance.attchmnt.get(attchmntFieldInstance) != attchmntDBObj.get(attchmntFieldInstance));
                }
            }
            else
            {
                if(!attchmntIsNewBtnPress)
                {
                    attchmntIsUpdated = true;
                }
            }
            if(attchmntIsUpdated)
            {
                attchmntListToUpdate.add(attchmntWraperInstance.attchmnt);
                attchmntErrorToWraperIndexMap.put(attchmntListToUpdate.size()-1, attchmntWraperInstance.attchmntIndex);
            }
            attchmntWraperInstance.attchmntEdit = false;
        }

        try
        {
            if(attchmntListToUpdate != null && attchmntListToUpdate.size() >0)
            {
                List<Database.upsertResult> results = Database.upsert(attchmntListToUpdate, false);
                for (Integer i =0; i < results.size(); i++) 
                {
                    if (!results[i].isSuccess())
                    {
                        for (Database.Error err : results[i].getErrors())
                        {
                              //+1 is added for Display on VF page only  
                              attchmntMsgStr = attchmntMsgStr + 'Error Record '+(attchmntErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!attchmntMsgStr.contains('insufficient access rights on object id'))
                        {
                            attchmntWrapperLst[attchmntErrorToWraperIndexMap.get(i)].attchmntEdit = true; 
                            //note on insuffivient privilage
                            attchmntSingleErrorOnSave = true;
                        }
                    }
                    /*else
                    {
                         attchmntWrapperLst[attchmntErrorToWraperIndexMap.get(i)].attchmntEdit = false;
                    }*/
                }
                if(attchmntSingleErrorOnSave == false && !attchmntIsNewBtnPress)
                {
                  attchmntLst = getAttachmentFromDB(oppId, attchmntBlockSize, attchmntOffsetsize, attchmntFieldsApiSet, attchmntSortExpression, attchmntSortDirection);
                  attchmntFieldToSumMap = getAttachmentFieldSum(attchmntAggregateQueryStr);
                  attchmntFirstRun = true;
                }
                if(String.isNotBlank(attchmntMsgStr)) 
                {
                       ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, attchmntMsgStr));
                }
            }
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             attchmntFirstRun = false;
        }
    }
    
    
      public void CollectData() 
      {
        String s1 = ApexPages.currentPage().getParameters().get('data');
        system.debug(s1);
        transient Blob b = EncodingUtil.base64Decode(s1.substringAfter('base64,'));
        Attachment a = new Attachment();  
        a.Body= b;
        a.ParentId = ApexPages.currentPage().getParameters().get('id');
        a.Name= ApexPages.currentPage().getParameters().get('name');
        insert a;
        
        refreshAttachments();
          
     }
    
    // method to build a map from a list from DB
    public Map<Id, Attachment> getAttachmentMapFromList(List<Attachment> pAttchmntLst) 
    {
        attchmntFromDbMap.clear();
        for(Attachment attchmntInstance :pAttchmntLst) 
        {
            attchmntFromDbMap.put(attchmntInstance.Id, attchmntInstance);
        }
        return attchmntFromDbMap;
    }
    //method for the first page of list to be displayed
    public void beginningAttachments() 
    {
       saveAttachments();
       if(!attchmntSingleErrorOnSave)
       {
            attchmntOffsetsize = 0;
            attchmntLst = getAttachmentFromDB(oppId, attchmntBlockSize, attchmntOffsetsize, attchmntFieldsApiSet, attchmntSortExpression, attchmntSortDirection);
            attchmntFirstRun = true;
       }
    }
    
    //method for previous page of list to be displayed
    public void previousAttachments() 
    {
        saveAttachments();
        if (!attchmntSingleErrorOnSave && attchmntBlockSize <= attchmntOffsetsize)
        {
            attchmntOffsetsize = attchmntOffsetsize - attchmntBlockSize;
            attchmntLst = getAttachmentFromDB(oppId, attchmntBlockSize, attchmntOffsetsize, attchmntFieldsApiSet, attchmntSortExpression, attchmntSortDirection);
            attchmntFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void nextAttachments() 
    {
        saveAttachments();
        if (!attchmntSingleErrorOnSave && attchmntOffsetsize <= attchmntRecordCount) 
        {
            attchmntOffsetsize = attchmntOffsetsize + attchmntBlockSize;
            attchmntLst = getAttachmentFromDB(oppId, attchmntBlockSize, attchmntOffsetsize, attchmntFieldsApiSet, attchmntSortExpression, attchmntSortDirection);
            attchmntFirstRun = true;
        }
    }
    
    //method for last page of list to be displayed
    public void endAttachments() 
    {
        saveAttachments();
        if(!attchmntSingleErrorOnSave && math.mod(attchmntRecordCount, attchmntBlockSize) == 0){
            attchmntOffsetsize = attchmntBlockSize * ((attchmntRecordCount/attchmntBlockSize)-1);
        } else if (!attchmntSingleErrorOnSave && math.mod(attchmntRecordCount , attchmntBlockSize) != 0){
            attchmntOffsetsize = attchmntBlockSize * ((attchmntRecordCount/attchmntBlockSize));
        }
        attchmntLst = getAttachmentFromDB(oppId, attchmntBlockSize, attchmntOffsetsize, attchmntFieldsApiSet, attchmntSortExpression, attchmntSortDirection);
        attchmntFirstRun = true;
    }
    
    //method to sort list of offers
    public void sortAttachments()
    {
            string attchmntReferenceFieldName = '';
            attchmntFieldType = Apexpages.currentPage().getParameters().get('attchmntTypeParam');
            if(attchmntFieldType.equalsIgnoreCase('REFERENCE'))
            {
                if(attchmntSortExpression.contains('__c'))
                {
                    attchmntReferenceFieldName += attchmntSortExpression.substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    attchmntReferenceFieldName += attchmntSortExpression.substringBefore('Id')+'.Name';
                }
                attchmntSortExpression = string.valueOf(attchmntReferenceFieldName);
            }
            refreshAttachments();
    }
    
    // wrapper for Attachments
    public class AttachmentWrapper
    {
        public Attachment attchmnt                                                       {get;set;}
        public Integer attchmntIndex                                                     {get;set;}
        public Boolean attchmntEdit                                                      {get;set;}
        public AttachmentWrapper(Attachment attchmntInstance, Integer pAttchmntIndex, Boolean pAttchmntEdit) {
            Attchmnt = attchmntInstance;
            attchmntIndex = pattchmntIndex;
            attchmntEdit = pattchmntEdit;
        }
    }
}