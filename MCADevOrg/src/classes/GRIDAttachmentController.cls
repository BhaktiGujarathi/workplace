global with sharing class GRIDAttachmentController {
   
    public String oppId                                                                 {get; set;}
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
    public boolean isHeapError;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    
    public List<Schema.FieldSetMember> attchmntFieldsetList                             {get; set;}
    public Set<string> attchmntFieldSumSet                                              {get; set;}
    public Map<String, Decimal> attchmntFieldToSumMap                                   {get; set;}
    public Integer attchmntRecordCount                                                  {get; set;}
    public Integer attchmntBlockSize                                                    {get; set;}
    public Integer attchmntOffsetsize                                                   {get; set;}
    public Integer attchmntIndexToRemove                                                {get; set;}
    public string attchmntSortDirection                                                 {get; set;}
    public String attchmntSortExpression                                                {get; set;}
    public Boolean attchmntEditAll;
    public String attchmntSortExprFieldApi                                              {get; set;}
    public boolean attchmntIsDisable                                                    {get; set;}
     // Editall Attribute
    public Boolean attchmntEditAllFlag                                                  {get; set;}
    // boolean to handle save success message on navigation
    public Boolean attchmntPageNavigated;
    
    // constructor
    public GRIDAttachmentController() 
    {
        if(GRIDOnloadStaticVariable.flipAttachment())
        {
            isHeapError = false;
            attchmntIsDisable = false;
            oppId = Apexpages.currentPage().getParameters().get('id');
            if(oppId == null || oppId == '') {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, 'Opportunity does not exist.'));
                attchmntIsDisable = true;
            }
            else {
                opportunity = [SELECT Id, 
                                      Name,
                                      AccountId 
                               FROM Opportunity 
                               WHERE Id =: oppId];
            }
            
            customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
            
            attchmntBlockSize = (Integer)customMetaDataSettingMap.get('Attachments').PageSize__c;
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
            attchmntEditAll = false;
            attchmntPageNavigated = false;
            
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
            attchmntFieldToSumMap = getAttachmentFieldSum(attchmntAggregateQueryStr);
            if(oppId != null && oppId != '')
                attchmntLst = getAttachmentFromDB(oppId, attchmntBlockSize, attchmntOffsetsize, 
                              attchmntFieldsApiSet, attchmntSortExpression, attchmntSortDirection);
            
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
        if(oppId <> null && oppId <> '') {
            List<SObject> attchmntSumQueryResult = new List<SObject>();
            attchmntSumQueryResult = Database.query(pAttchmntAggregateQueryStr);
            attchmntRecordCount = (Integer)attchmntSumQueryResult[0].get('attchmntCount');
         
            return attchmntFieldToSumMap;
        }
        attchmntRecordCount = 0;
        return null;
    }
    
    // method to get Creditattchmnts from DB
    public List<Attachment> getAttachmentFromDB(String pOppId, Integer pAttchmntBlockSize, Integer pAttchmntOffsetSize, Set<String> pAttchmntFieldsApiSet,
                                                String pAttchmntSortExpression, String pAttchmntSortDirection) 
    {
        if(pOppId <> null && pOppId <> '') 
        {
            String attchmntQueryStr = '';
            attchmntFieldsString = MCAUtility.getStringfromSet(pAttchmntFieldsApiSet, null);
            attchmntQueryStr = 'Select ' +attchmntFieldsString+ 
                               ' From Attachment Where ParentId =:pOppId ORDER BY '+pAttchmntSortExpression+' '+pAttchmntSortDirection+' NULLS LAST LIMIT '
                                +pAttchmntBlockSize+' Offset ' +pAttchmntOffsetSize;
            return database.query(attchmntQueryStr);
        }
        return new List<Attachment>();
    }
    
    // method to get the wrapper list
    public List<AttachmentWrapper> getAttchmntWrapperLst() 
    {
        if(attchmntFirstRun)
        {
            attchmntWrapperLst = new List<AttachmentWrapper>();
        }
        
        if(attchmntLst <> null && attchmntLst.size() >0)
        {
            if(attchmntFirstRun)
            {
                //attchmntWrapperLst = new List<AttachmentWrapper>();
                for (Integer i = 0; i < attchmntLst.size(); i++) 
                {
                    attchmntWrapperLst.add(new AttachmentWrapper(attchmntLst[i], i, attchmntEditAllFlag));
                }
                attchmntFirstRun = false;
            }
        }
        //attchmntFieldToSumMap = getAttachmentFieldSum(attchmntAggregateQueryStr);
        return attchmntWrapperLst;
    }
    
    // method to edit all Attachment
    public void editAllAttachments()
    {
        attchmntFirstRun = false;
        attchmntEditAll = true;
        for(Integer i=0; i< attchmntWrapperLst.size(); i++) 
        {
            attchmntWrapperLst[i].attchmntEdit = true;
        }
        
    }
    
    // method to refresh
    public void refreshAttachments()
    {
        attchmntLst = getAttachmentFromDB(oppId, attchmntBlockSize, attchmntOffsetsize, attchmntFieldsApiSet, attchmntSortExpression, attchmntSortDirection);
        attchmntFieldToSumMap = getAttachmentFieldSum(attchmntAggregateQueryStr);
        attchmntFirstRun = true;
        if(isHeapError)
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'Apex heap size too large, Please use Attach File button to upload the file.'));
        else
            isHeapError = false;
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
        
        if(attchmntWrapperLst.size() <= 0)
        {
            refreshAttachments();
        }
        attchmntFieldToSumMap = getAttachmentFieldSum(attchmntAggregateQueryStr);
    }
    
    // method to save attachments
    public void saveAttachments()
    {
        String attchmntMsgStr = '';
        String attchmntSuccessMsgStr ='';
        attchmntSingleErrorOnSave = false;
        Boolean attchmntIsUpdated = false;
        attchmntEditAll = attchmntEditAllFlag;
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
                    if(!attchmntFieldInstance.contains('.Name')) 
                    {
                        attchmntIsUpdated  = attchmntIsUpdated ||(attchmntWraperInstance.attchmnt.get(attchmntFieldInstance) != attchmntDBObj.get(attchmntFieldInstance));
                    }
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
            attchmntWraperInstance.attchmntEdit = attchmntEditAllFlag;
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
                             String recordError = err.getMessage();
                             /*
                             if(recordError.contains('insufficient access rights on'))
                             {
                                 recordError = 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.';
                             }
                             else
                             {
                                 attchmntWrapperLst[attchmntErrorToWraperIndexMap.get(i)].attchmntEdit = true;  
                                 
                             } */
                             if(!recordError.contains('insufficient access rights on'))
                             {
                                 attchmntWrapperLst[attchmntErrorToWraperIndexMap.get(i)].attchmntEdit = true;  
                             }
                             attchmntSingleErrorOnSave = true;
                             attchmntMsgStr = attchmntMsgStr + 'Error Record '+(attchmntErrorToWraperIndexMap.get(i)+1)+' : '+ recordError + '<br />'; 
                        }
                    }
                    else if(results[i].isSuccess())
                    {
                        attchmntSuccessMsgStr = attchmntSuccessMsgStr+ 'Success Record '+(attchmntErrorToWraperIndexMap.get(i)+1)+' : '+ 'saved successfully!' + '<br />';
                        attchmntWrapperLst[attchmntErrorToWraperIndexMap.get(i)].attchmntEdit = attchmntEditAllFlag;
                    }
                }
                if(attchmntSingleErrorOnSave == false && !attchmntIsNewBtnPress)
                {
                  attchmntLst = getAttachmentFromDB(oppId, attchmntBlockSize, attchmntOffsetsize, attchmntFieldsApiSet, attchmntSortExpression, attchmntSortDirection);
                  attchmntFieldToSumMap = getAttachmentFieldSum(attchmntAggregateQueryStr);
                  attchmntFirstRun = true;
                }
                if(String.isNotBlank(attchmntMsgStr)  || String.isNotBlank(attchmntSuccessMsgStr)) 
                {
                    if(attchmntPageNavigated)
                    {
                        //attchmntPageNavigated = false;
                        attchmntSuccessMsgStr = 'Last changes made by you were saved successfully!';
                    }  
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, attchmntMsgStr  +'<br/>'+ attchmntSuccessMsgStr));
                }
            }
            attchmntPageNavigated = false;
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             attchmntFirstRun = false;
        }
    }
    
    
     public void CollectData() 
      {
        try
        {
            isHeapError = false;
            //system.debug('----->'+Limits.getHeapSize());
            if((Limits.getHeapSize()+(ApexPages.currentPage().getParameters().get('data')).length()+(ApexPages.currentPage().getParameters().get('data')).length())< 6000000 ) {
                Attachment objAttach = new Attachment();  
                objAttach.Body= EncodingUtil.base64Decode(ApexPages.currentPage().getParameters().get('data').substringAfter('base64,'));
                objAttach.ParentId = ApexPages.currentPage().getParameters().get('id');
                objAttach.Name= ApexPages.currentPage().getParameters().get('name');
                insert objAttach;
                refreshAttachments();
            } else {
               isHeapError = true;
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'Apex heap size too large, Please use Attach File button to upload the file.')); 
            }
        }
        catch(Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        } 
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
       attchmntPageNavigated = true;
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
        attchmntPageNavigated = true;
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
        attchmntPageNavigated = true;
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
        attchmntPageNavigated = true;
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
        public AttachmentWrapper(Attachment attchmntInstance, Integer pAttchmntIndex, Boolean pAttchmntEdit) 
        {
            Attchmnt = attchmntInstance;
            attchmntIndex = pattchmntIndex;
            attchmntEdit = pattchmntEdit;
        }
    }
}