global with sharing class GRIDStipsController
{
    public static Map<String, Schema.SObjectType> globalMap;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    
    public List<Schema.FieldSetMember> stipsFieldsetList                                {get; set;}
    public Integer stipsBlockSize                                                       {get; set;}
    public Integer stipsOffsetSize                                                      {get; set;}
    public Map<String, Decimal> stipsFieldToSumMap                                      {get; set;}
    public Set<String> stipsFieldSumSet                                                 {get; set;}
    public Integer stipsRecordCount                                                     {get; set;}
    public Integer stipsIndexToRemove                                                   {get; set;}
    public Opportunity opportunity                                                      {get; set;}
    public String stipsSortExpression                                                   {get; set;}
    public String stipsSortFieldApi                                                     {get; set;}
    public string stipsSortDirection                                                    {get; set;}
    public String DestURL                                                               {get; set;}
    public String addAttachmentURL                                                      {get; set;}
    public String stipsFieldType;
    public Map<Id, Stips__c> stipsFromDbMap;
    public List<StipsWrapper> stipsWrapperLst; 
    public List<Stips__c> stipsLst;
    public Set<String> stipsFieldsApiSet;
    public String stipsFieldsString = '';
    public String stipsAggregateQueryStr='';
    public Boolean stipsFirstRun;
    public Boolean stipsSingleErrorOnSave;
    public Boolean stipsIsNewBtnPress;
    public String opportunityId;
    public Map<Id, List<ID>> mapIDANDListAttach;
    public Set<ID> stipIDset;
    public Boolean stipsEditAll;
    public Boolean stipsStatusToCompleted;
    public String stipsSortExprFieldApi                                                 {get; set;}
    public Boolean stipsIsRefrenceField                                                 {get; set;}
    public String  stipsRefrenceFieldLabel                                              {get; set;}
    public boolean stipsIsDisable                                                       {get; set;}
    // Editall Attribute
    public Boolean stipsEditAllFlag                                                     {get; set;}
    // boolean to handle save success message on navigation
    public Boolean stipsPageNavigated;
    
    public GRIDStipsController() 
    {
       if(GRIDOnloadStaticVariable.flipStips())
        {
            stipsIsDisable = false;
            opportunityId = Apexpages.currentPage().getParameters().get('id');
            //Opportunity opportunity = new Opportunity();
            if(opportunityId == null || opportunityId == '') {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, 'Opportunity does not exist'));
                stipsIsDisable = true; 
            }
            opportunity = [Select Id, Name, AccountId,  /*Open_Stip_Count__c,*/ Owner_1__c,Owner_1__r.Email, OwnerId from Opportunity where Id=:opportunityId ];
            if(system.Label.GRIDEmailStips == 'Opportunity Owner')
            {
             DestURL = '/_ui/core/email/author/EmailAuthor?p3_lkid='+opportunity.Id+'&retURL=%2F'+opportunity.Id+'&template_id='+system.Label.GRIDEmailStipsTemplateId+'&p24='+[select Email, Id From User where Id =: opportunity.OwnerId].Email;
            }
            else
            {
             DestURL = '/_ui/core/email/author/EmailAuthor?p3_lkid='+opportunity.Id+'&retURL=%2F'+opportunity.Id+'&template_id='+system.Label.GRIDEmailStipsTemplateId+'&p2='+Opportunity.Owner_1__c+'&p2_lkid='+ Opportunity.Owner_1__c;
            }
            
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
            
            stipsEditAll = false;
            stipsFieldType = '';
            stipsSortExpression = 'CreatedDate';
            stipsSortFieldApi = 'CreatedDate';
            stipsSortDirection = 'DESC';
            stipsBlockSize = (Integer)customMetaDataSettingMap.get('Stips').PageSize__c;
            stipsOffsetsize = 0;
            stipsIsNewBtnPress = false;
            stipsPageNavigated = false;
            
            stipsLst = new List<Stips__c>();
            stipIDset = new Set<ID>();
            stipsFieldSumSet = new Set<String>();
            stipsFieldsApiSet = new set<String>();
            stipsWrapperLst = new List<StipsWrapper>();
            stipsFromDbMap = new Map<Id, Stips__c>();
            stipsFieldToSumMap = new Map<String, Decimal>();
            mapIDANDListAttach = new Map<Id, List<ID>>();
            Schema.DescribeSObjectResult stipsDescbResult = globalMap.get(customMetaDataSettingMap.get('Stips').Object_API_Name__c).getDescribe();
            stipsFieldsetList = stipsDescbResult.FieldSets.getMap().get(customMetaDataSettingMap.get('Stips').Fieldset_Name__c).getFields();
            
            GRIDUtility.ReferenceFieldWrapper refWrap = new GRIDUtility.ReferenceFieldWrapper(stipsFieldsetList, ' ', false);
            refWrap = GRIDUtility.isReferenceFieldPresent(refWrap);
            stipsIsRefrenceField= refWrap.isReferenceField;
            stipsRefrenceFieldLabel = refWrap.refrenceFieldLabel;
            
            if(!stipsIsRefrenceField)
            {
                stipsAggregateQueryStr = buildStipsAggregateQuery(stipsFieldsetList);
                stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
                stipsFieldsApiSet = buildSetFromFieldListstips(stipsFieldsetList);
                stipsFieldsApiSet.add('Name'); 
                if(opportunityId != null && opportunityId != '')
                    stipsLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetSize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
                stipsFirstRun = true;
            }       
        }
        redirectToAddAttachment();
    }
    
    // redirect to add attachment page
    public void redirectToAddAttachment() {
        addAttachmentURL = '/apex/oppmultipleattachment?id='+opportunityId+'&retURL=/'+opportunityId+'&accId=&isStips=true&stipID=';
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListstips(List<Schema.FieldSetMember> pStipsFieldsetList)
    {
        
        for(Schema.FieldSetMember fieldInstance :pStipsFieldsetList)
        {
            
            stipsFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                String stipsReferenceField = '';
                if(fieldInstance.getfieldPath().contains('__c'))
                {
                    stipsReferenceField += fieldInstance.getfieldPath().substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    stipsReferenceField += fieldInstance.getfieldPath().substringBefore('Id')+'.Name';
                }
                stipsFieldsApiSet.add(stipsReferenceField);
            }
            
        }
        
        return stipsFieldsApiSet;
    }
    
    // method to get stips from DB
    public List<Stips__c> getStipsFromDB(String pOpportunityId, Integer pStipsBlockSize, Integer pStipsOffsetSize, Set<String> pStipsFieldsApiSet,
                                         String pStipsSortExpression, String pStipsSortDirection) 
    {
        if(pOpportunityId <> null && pOpportunityId <> '') 
        {
            String stipsQueryStr = '';
            stipsFieldsString = MCAUtility.getStringfromSet(pStipsFieldsApiSet, null);
            stipsQueryStr = 'Select ' +stipsFieldsString+ 
                            ' From Stips__c Where Opportunity__c =:pOpportunityId ORDER BY '+pStipsSortExpression+' '+pStipsSortDirection+ ' NULLS LAST LIMIT '
                            +pStipsBlockSize+' Offset ' +pStipsOffsetSize;
            return database.query(stipsQueryStr);
        }
        return new List<Stips__c>();
    }
    
    //getter of wrapperList
    public List<StipsWrapper> getStipsWrapperLst() 
    {
        if(stipsFirstRun)
        {
            stipsWrapperLst = new List<StipsWrapper>();
        }
        if(stipsLst<> null && stipsLst.size() > 0 )
        {
            if(stipsFirstRun)
            {
                //stipsWrapperLst = new List<StipsWrapper>();
                stipIDset.clear();
                for(Stips__c tempStip : stipsLst)
                {
                    stipIDset.add(tempStip.id);
                }
            
                getStipRelatedAttachment();
            
                for (Integer i = 0; i < stipsLst.size(); i++) 
                {
                    if(mapIDANDListAttach != null && mapIDANDListAttach.size()>0 && mapIDANDListAttach.get(stipsLst[i].id) != null)
                      stipsWrapperLst.add(new StipsWrapper(stipsLst[i], i, stipsEditAllFlag,(mapIDANDListAttach.get(stipsLst[i].id)).size(),mapIDANDListAttach.get(stipsLst[i].id)));
                    else
                    stipsWrapperLst.add(new StipsWrapper(stipsLst[i], i, stipsEditAllFlag, 0,null));
                }
                stipsFirstRun = false;
            }
        }
        //stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
        return stipsWrapperLst;
    }
    
    
    
    // get all attachment 
    public void getStipRelatedAttachment() 
    {
        mapIDANDListAttach.clear();
        for(Stips_Attachment__c objStipsAttachment : [SELECT id
                                                             , Attachment_ID__c
                                                             , Stips__c
                                                      FROM Stips_Attachment__c
                                                      WHERE Stips__c IN: stipIDset])
        {
            if(mapIDANDListAttach.get(objStipsAttachment.Stips__c) == null) 
            {
                mapIDANDListAttach.put(objStipsAttachment.Stips__c, new List<ID>{objStipsAttachment.Attachment_ID__c});
            } 
            else 
            {
                mapIDANDListAttach.get(objStipsAttachment.Stips__c).add(objStipsAttachment.Attachment_ID__c);
            }
           
        }
        
        
    }
    

    // method to create new stip
    public void newStips() 
    {
        stipsIsNewBtnPress = true;
        if(!stipsEditAll) 
        {
            saveAllStips();
        }
        else
        {
            stipsSingleErrorOnSave = false;
        }
        stipsIsNewBtnPress = false;
        
        if(!stipsSingleErrorOnSave)
        {
            // to add new record only on first page
            if(stipsOffsetsize <> 0) 
            {
                stipsOffsetsize = 0;
                beginningStips();
            }
            
            Stips__c stipsNew = new Stips__c(Status__c = 'Pending', 
                                             Date_Requested__c = system.today(),
                                             Opportunity__c = opportunityId
                                             );
            
             /*need to add at 0th index if list size > 0 else simple add will work*/
               if(stipsWrapperLst.size() > 0 && stipsLst.size() > 0)
               {
                 stipsWrapperLst.add(0,new StipsWrapper(stipsNew, null,true,0,null));
                 stipsLst.add(0,stipsNew);
               }
               else
               {
                 stipsWrapperLst.add(new StipsWrapper(stipsNew, null,true,0,null));
                 stipsLst.add(stipsNew);
               } 
            
            // reindexing
            for(Integer i=0; i<stipsWrapperLst.size(); i++)
            {
                stipsWrapperLst[i].stipsIndex = i;
            }
        }
    }
    
    //method to delete
    public void deleteStips() 
    {
        if(stipsWrapperLst[stipsIndexToRemove].stips.Id != null) 
         {
            try
            {
                delete stipsWrapperLst[stipsIndexToRemove].stips;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
         
         stipsLst.remove(stipsIndexToRemove);
         stipsWrapperLst.remove(stipsIndexToRemove);
         //refreshStips();
         
          //re-indexing
         for(Integer i=0;i<stipsWrapperLst.size();i++)
         {
           stipsWrapperLst[i].stipsIndex = i;
         }
         if(stipsWrapperLst.size() <= 0)
         {
             refreshStips();
         }
         stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
    }
    
    // method to refresh
    public void refreshStips() 
    {
        stipsLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetSize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
        stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
        stipsFirstRun = true;
    }
 
    // method to save
    public void saveAllStips()
    {
        String stipsMsgStr = '';
        String stipsSuccessMsgStr ='';
        stipsSingleErrorOnSave = false;
        Boolean stipsIsUpdated = false;
        stipsEditAll = false;
        List<Stips__c> stipsListToUpdate = new List<Stips__c>();
        Map<Integer, Integer> stipsErrorToWraperIndexMap = new map<Integer, Integer>();
        
        List<Stips__c> stipsTempLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetsize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
        stipsFromDbMap = getStipsMapFromList(stipsTempLst);
        
        for(StipsWrapper stipsWraperInstance :stipsWrapperLst) 
        {
            Stips__c stipsDBObj = stipsFromDbMap.get(stipsWraperInstance.stips.Id);
            if(stipsDBObj != null)
            {
                stipsIsUpdated = false;
                for(String stipsFieldInstance :stipsFieldsApiSet)
                {
                    if(!stipsFieldInstance.contains('.Name')) 
                    {
                        stipsIsUpdated  = stipsIsUpdated ||(stipsWraperInstance.stips.get(stipsFieldInstance) != stipsDBObj.get(stipsFieldInstance));
                    }
                }
            }
            else
            {
                if(!stipsIsNewBtnPress) 
                {
                    stipsIsUpdated = true;
                }
            }

            if(stipsIsUpdated) 
            {
                stipsListToUpdate.add(stipsWraperInstance.stips);
                stipsErrorToWraperIndexMap.put(stipsListToUpdate.size()-1, stipsWraperInstance.stipsIndex);
               
            }
            
             stipsWraperInstance.stipsEdit = stipsEditAllFlag;
                        
        }

        try
        {
            if(stipsListToUpdate != null && stipsListToUpdate.size() >0)
            {
                List<Database.upsertResult> results = Database.upsert(stipsListToUpdate, false);
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
                                stipsWrapperLst[stipsErrorToWraperIndexMap.get(i)].stipsEdit = true; 
                                
                             }*/
                             
                             if(!recordError.contains('insufficient access rights on'))
                             {
                                 stipsWrapperLst[stipsErrorToWraperIndexMap.get(i)].stipsEdit = true; 
                             }
                             stipsSingleErrorOnSave = true;
                             stipsMsgStr = stipsMsgStr + 'Error Record '+(stipsErrorToWraperIndexMap.get(i)+1)+' : '+ recordError + '<br />'; 
                            
                        }
                    }
                    else if(results[i].isSuccess())
                    {
                        stipsSuccessMsgStr = stipsSuccessMsgStr+ 'Success Record '+(stipsErrorToWraperIndexMap.get(i)+1)+' : '+ 'saved successfully!' + '<br />';
                        stipsWrapperLst[stipsErrorToWraperIndexMap.get(i)].stipsEdit = stipsEditAllFlag;
                    }
                }
                if(stipsSingleErrorOnSave == false && !stipsIsNewBtnPress)
                {
                    stipsLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetSize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
                    stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
                    stipsFirstRun = true;
                }
                if(String.isNotBlank(stipsMsgStr) || String.isNotBlank(stipsSuccessMsgStr)) 
                {
                    if(stipsPageNavigated)
                    {
                        stipsPageNavigated = false;
                        stipsSuccessMsgStr = 'Last changes made by you were saved successfully!';
                    }
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,stipsMsgStr +'<br/>'+ stipsSuccessMsgStr));
                }
               
                    
            }
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             stipsFirstRun = false;
        }
              
    }
 
    // method to edit all stips
     public void editAllStips() 
     {
        stipsFirstRun = false;
        stipsEditAll = true;
        for(Integer i=0; i< stipsWrapperLst.size(); i++) 
        {
            stipsWrapperLst[i].stipsEdit = true;
        }
        
    }
    
    // method to build a map of Id-to-Stips from List
    public Map<Id, Stips__c> getStipsMapFromList(List<Stips__c> pStipsLst) 
    {
        stipsFromDbMap.clear();
        for(Stips__c stipsInstance :pStipsLst) 
        {
                stipsFromDbMap.put(stipsInstance.Id, stipsInstance);
        }
        return stipsFromDbMap;
    }
    
    // method to build dynamic query for SUM and COUNT
    public String buildStipsAggregateQuery(List<Schema.FieldSetMember> pStipsFieldsetList)
    {
        stipsAggregateQueryStr = 'SELECT ';
        /*
        for(Schema.FieldSetMember fieldInstance :pStipsFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency') 
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
            {
                stipsAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                stipsFieldSumSet.add(fieldInstance.getFieldPath());
                
            }
            //stipsFieldsApiSet.add(fieldInstance.getfieldPath());
            stipsFieldToSumMap.put(fieldInstance.getFieldPath(), -999.999);
        }*/
        
        stipsAggregateQueryStr += 'COUNT(Id) stipsCount FROM Stips__c Where Opportunity__c = \''+opportunityId+'\'';
        
        return stipsAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getStipsFieldSum(String pStipsAggregateQueryStr)
    {
        if(opportunityId <> null && opportunityId <> '') 
        {
            List<SObject> stipsSumQueryResult = new List<SObject>();
            stipsSumQueryResult = Database.query(pStipsAggregateQueryStr);
        
            for(String fieldName :stipsFieldSumSet) 
            {
                if(stipsSumQueryResult[0].get(fieldName) != null)
                {
                    stipsFieldToSumMap.put(fieldName, (Decimal)stipsSumQueryResult[0].get(fieldName)); 
                }
            }
            stipsRecordCount = (Integer)stipsSumQueryResult[0].get('stipsCount');
            return stipsFieldToSumMap;
        }
        stipsRecordCount = 0;
        return null;
    }
    
    
        public void collectStipData() 
     {
        if((Limits.getHeapSize()+(ApexPages.currentPage().getParameters().get('data')).length()+(ApexPages.currentPage().getParameters().get('data')).length())< 6000000 ) {
        
            // Assign value to attachment
            Attachment objAttachment = new Attachment();  
            objAttachment.Body= EncodingUtil.base64Decode(ApexPages.currentPage().getParameters().get('data').substringAfter('base64,'));
            objAttachment.ParentId = ApexPages.currentPage().getParameters().get('id');
            objAttachment.Name = ApexPages.currentPage().getParameters().get('name');
        
        
            try
            {
                insert objAttachment;
                Stips_Attachment__c objStipsAtt = new Stips_Attachment__c();
                objStipsAtt.Attachment_ID__c = objAttachment.id;
                objStipsAtt.Stips__c = ApexPages.currentPage().getParameters().get('stipID');
                //            Integer wrapperListIndexController = integer.valueOf(ApexPages.currentPage().getParameters().get('wrapperListIndex'));
                insert objStipsAtt;
                /*
                stipsStatusToCompleted = boolean.valueof(system.label.GRIDStipsStatusToCompleted);
                if(stipsStatusToCompleted == true && objStipsAtt.Id!=null && stipsWrapperLst[wrapperListIndexController].stips.Status__c!= 'Completed') 
                {
                    stipsWrapperLst[wrapperListIndexController].stips.Status__c = 'Completed';
                    update stipsWrapperLst[wrapperListIndexController].stips;
                }
                */

                stipsLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetSize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
                stipsFirstRun = true;
            } 
            catch(Exception e) 
            {
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, ApexPages.currentPage().getParameters().get('stipID')));
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            
            }
        }else {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'Apex heap size too large, Please use Attach File button to upload the file.')); 
        }
        
    }

    //to get attachments to download from vf page
    @RemoteAction
    global static List<AttachmentResponse> getAttachments(Id oppID, String listAttID) 
    {

         Map<String,Integer> mapCopyCount = new  Map<String,Integer>();
         listAttID = listAttID.remove('[');
         listAttID = listAttID.remove(']');
         listAttID = listAttID.remove(' ');
         List<String> listAtt = listAttID.split(',');
         List<AttachmentResponse> listAttch = new List<AttachmentResponse>();
        
        for(Attachment objAttach :[SELECT id
                                            , Name
                                            , body
                                    FROM Attachment 
                                    WHERE  id IN: listAtt]) 
        {
            /*if(mapCopyCount.containskey(objAttach.Name))
            {
                //existing
                Integer tempCount= mapCopyCount.get(objAttach.Name)+1;
                mapCopyCount.put(objAttach.Name,tempCount);
                String fileName = objAttach.Name.substringBeforeLast('.');
                String extension = objAttach.Name.substringAfterLast('.'); 
               // String[] FileSplitString= objAttach.Name.split('\\.');

                listAttch.add(new AttachmentResponse(fileName +'('+tempCount+').'+extension, EncodingUtil.base64Encode(objAttach.body)));
            
            }
            else
            {
                //new
                listAttch.add(new AttachmentResponse(objAttach.Name, EncodingUtil.base64Encode(objAttach.body)));
                mapCopyCount.put(objAttach.Name,0);
            }*/
            
             listAttch.add(new AttachmentResponse(objAttach.Name, EncodingUtil.base64Encode(objAttach.body),objAttach.Name.substringAfterLast('.')));
            
        }
        
        return listAttch;
    }
    
    
    //method for the first page of list to be displayed
    public void beginningStips() 
    {
        stipsPageNavigated = true;
        saveAllStips();
        if(!stipsSingleErrorOnSave)
        {
            stipsOffsetsize = 0;
            stipsLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetSize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
            stipsFirstRun = true;
        }
    }
    
    //method for previous page of list to be displayed
    public void previousStips() 
    {
        stipsPageNavigated = true;
        saveAllStips();
        if(!stipsSingleErrorOnSave && stipsBlockSize <= stipsOffsetSize) 
        {
            stipsOffsetSize = stipsOffsetSize - stipsBlockSize;
            stipsLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetSize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
            stipsFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void nextStips() 
    {
        stipsPageNavigated = true;
        saveAllStips();
        if(!stipsSingleErrorOnSave && stipsOffsetsize <= stipsRecordCount) 
        {
            stipsOffsetSize = stipsOffsetsize + stipsBlockSize;
            stipsLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetsize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
            stipsFirstRun = true;
        }
    }
    
    //method for last page of list to be displayed
    public void endStips() 
    {
        stipsPageNavigated = true;
        saveAllStips();
        if(!stipsSingleErrorOnSave && math.mod(stipsRecordCount , stipsBlockSize) == 0){
            stipsOffsetsize = stipsBlockSize * ((stipsRecordCount/stipsBlockSize)-1);
        } else if (!stipsSingleErrorOnSave && math.mod(stipsRecordCount , stipsBlockSize) != 0){
            stipsOffsetsize = stipsBlockSize * ((stipsRecordCount/stipsBlockSize));
        }
        //stipsOffsetSize = stipsRecordCount-MAth.mod(stipsRecordCount,stipsBlockSize);
        stipsLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetSize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
        stipsFirstRun = true;
    }
    
    //method to sort list of Stips
    public void sortStips()
    {
            string stipsRefernceFieldName = '';
            stipsFieldType = Apexpages.currentPage().getParameters().get('stipstypeParam');
            if(stipsFieldType.equalsIgnoreCase('REFERENCE'))
            {
                if(stipsSortExpression.contains('__c'))
                {
                    stipsRefernceFieldName += stipsSortExpression.substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    stipsRefernceFieldName += stipsSortExpression.substringBefore('Id')+'.Name';
                }
                stipsSortExpression = string.valueOf(stipsRefernceFieldName);
            }
            refreshStips();
    }

    public class StipsWrapper 
    {
        public Stips__c stips                                    {get;set;}
        public Integer stipsIndex                                {get;set;}
        public Boolean stipsEdit                                 {get;set;}
        public Integer noAttachment                              {get;set;}
        public String noOfAttachmentString                       {get;set;}
        public List<ID> listAttachID                             {get;set;}
        public StipsWrapper(Stips__c stipsInstance, Integer pStipsIndex, Boolean pStipsEdit,Integer pNoAttachment,
                        List<ID> pListAttachID) 
        {
            stips = stipsInstance;
            stipsIndex = pStipsIndex;
            stipsEdit = pStipsEdit;
            noAttachment = pNoAttachment;
            listAttachID = pListAttachID;
            noOfAttachmentString =  noAttachment>1?noAttachment+' files':(noAttachment == 1?noAttachment+' file':'');
            
        }
    }
    
    
    // Wrapper to store attchemnt data
    // Note javascript don't no the object structure like Attchement, account, lead
    global class AttachmentResponse
    {
        public String attName {get;set;}
        public String attchBody {get;set;}
        public String nameExt {get;set;}
        public AttachmentResponse(String attName, String attchBody,String nameExt)
        {
            this.attName = attName;
            this.attchBody = attchBody;
            this.nameExt = nameExt;
        }
    }// end inner class AttachmentResponse

    
}