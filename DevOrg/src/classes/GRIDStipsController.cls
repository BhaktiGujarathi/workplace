global with sharing class GRIDStipsController
{

    public static Map<String, Schema.SObjectType> globalMap;
    public List<Schema.FieldSetMember> stipsFieldsetList                                {get; set;}
    public Integer stipsBlockSize                                                       {get; set;}
    public Integer stipsOffsetSize                                                      {get; set;}
    public Map<String, Decimal> stipsFieldToSumMap                                      {get; set;}
    public Set<String> stipsFieldSumSet                                                 {get; set;}
    public Integer stipsRecordCount                                                     {get; set;}
    public Integer stipsIndexToRemove                                                   {get; set;}
    public Opportunity opportunity                                                      {get; set;}
    public String stipsSortExpression                                                   {get; set;}
    public string stipsSortDirection                                                    {get; set;}
    public String DestURL                                                               {get; set;}
    
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
    public Id opportunityId;
    public Map<Id, List<ID>> mapIDANDListAttach;
    public Set<ID> stipIDset;
    public GRIDStipsController() 
    {
       if(GRIDOnloadStaticVariable.flipStips())
        {
            opportunityId = Apexpages.currentPage().getParameters().get('id');
            //Opportunity opportunity = new Opportunity();
            opportunity = [Select Id, Name, AccountId, Open_Stips__c, Owner_1__c,Owner_1__r.Email, OwnerId from Opportunity where Id=:opportunityId ];
            if(system.Label.McaGrid_EmailStips == 'Opportunity Owner')
            {
             DestURL = '/_ui/core/email/author/EmailAuthor?p3_lkid='+opportunity.Id+'&retURL=%2F'+opportunity.Id+'&template_id='+system.Label.Email_Stips_Template_Id+'&p24='+[select Email, Id From User where Id =: opportunity.OwnerId].Email;
            }
            else
            {
             DestURL = '/_ui/core/email/author/EmailAuthor?p3_lkid='+opportunity.Id+'&retURL=%2F'+opportunity.Id+'&template_id='+system.Label.Email_Stips_Template_Id+'&p2='+Opportunity.Owner_1__c+'&p2_lkid='+ Opportunity.Owner_1__c;
            }
          
            stipsFieldType = '';
            stipsSortExpression = 'CreatedDate';
            stipsSortDirection = 'DESC';
            stipsBlockSize = (Integer)GRIDTabSetting__c.getValues('Stip').PageSize__c;
            stipsOffsetsize = 0;
            stipsIsNewBtnPress = false;
            stipsLst = new List<Stips__c>();
            stipIDset = new Set<ID>();
            stipsFieldSumSet = new Set<String>();
            stipsFieldsApiSet = new set<String>();
            stipsWrapperLst = new List<StipsWrapper>();
            stipsFromDbMap = new Map<Id, Stips__c>();
            stipsFieldToSumMap = new Map<String, Decimal>();
            mapIDANDListAttach = new Map<Id, List<ID>>();
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            Schema.DescribeSObjectResult stipsDescbResult = globalMap.get('Stips__c').getDescribe();
            stipsFieldsetList = stipsDescbResult.FieldSets.getMap().get(GRIDTabSetting__c.getValues('Stip').Fieldset_Name__c).getFields();
            stipsAggregateQueryStr = buildStipsAggregateQuery(stipsFieldsetList);
            stipsFieldsApiSet = buildSetFromFieldListstips(stipsFieldsetList);
            stipsLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetSize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
            for(Stips__c tempStip : stipsLst)
            {
                stipIDset.add(tempStip.id);
            }
            stipsFirstRun = true;
        }
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListstips(List<Schema.FieldSetMember> pStipsFieldsetList)
    {
        String stipsReferenceField = '';
        for(Schema.FieldSetMember fieldInstance :pStipsFieldsetList)
        {
            stipsFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
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
    
    // metyhod to get stips from DB
    public List<Stips__c> getStipsFromDB(ID pOpportunityId, Integer pStipsBlockSize, Integer pStipsOffsetSize, Set<String> pStipsFieldsApiSet,
                                         String pStipsSortExpression, String pStipsSortDirection) 
    {
        
        String stipsQueryStr = '';
        stipsFieldsString = DEWUtility.getStringfromSet(pStipsFieldsApiSet, null);
        stipsQueryStr = 'Select Name,' +stipsFieldsString+ 
                        ' From Stips__c Where Opportunity__c =:pOpportunityId ORDER BY '+pStipsSortExpression+' '+pStipsSortDirection+ ' NULLS LAST LIMIT '
                        +pStipsBlockSize+' Offset ' +pStipsOffsetSize;
        
        return database.query(stipsQueryStr);
    }
    
    //getter of wrapperList
    public List<StipsWrapper> getStipsWrapperLst() 
    {
        if(stipsFirstRun)
        {
            stipsWrapperLst = new List<StipsWrapper>();
            getStipRelatedAttachment();
            
            for (Integer i = 0; i < stipsLst.size(); i++) 
            {
                if(mapIDANDListAttach != null && mapIDANDListAttach.size()>0 && mapIDANDListAttach.get(stipsLst[i].id) != null)
                  stipsWrapperLst.add(new StipsWrapper(stipsLst[i], i, false,(mapIDANDListAttach.get(stipsLst[i].id)).size(),mapIDANDListAttach.get(stipsLst[i].id)));
                else
                  stipsWrapperLst.add(new StipsWrapper(stipsLst[i], i, false,0,null));
               
            }
           
            stipsFirstRun = false;
            
        }
        
        stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
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
        saveAllStips();
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
                                             Opportunity__c = opportunityId,
                                             Notes__c = 'new stip');
            
             /*need to add at 0th index if list size > 0 else simple add will work*/
               if(stipsWrapperLst.size() > 0 && stipsLst.size() > 0)
               {
                 stipsWrapperLst.add(0,new StipsWrapper(stipsNew, null, true,0,null));
                 stipsLst.add(0,stipsNew);
               }
               else
               {
                 stipsWrapperLst.add(new StipsWrapper(stipsNew, null, true,0,null));
                 stipsLst.add(stipsNew);
               } 
            
            // reindexing
            for(Integer i=0; i<stipsWrapperLst.size(); i++)
            {
                stipsWrapperLst[i].stipsIndex = i;
            }
        }
    }
    
    // method to delete
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
    }
    
    // method to refresh
    public void refreshStips() 
    {
        stipsLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetSize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
        stipsFirstRun = true;
    }
 
    // method to save
    public void saveAllStips()
    {
        String stipsMsgStr = '';
        stipsSingleErrorOnSave = false;
        Boolean stipsIsUpdated = false;
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
                    if(!stipsFieldInstance.contains('__r.Name')) 
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
            
             stipsWraperInstance.stipsEdit = false;
            
            
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
                            //+1 is added for Display on VF page only  
                            stipsMsgStr = stipsMsgStr + 'Error Record '+(stipsErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!stipsMsgStr.contains('insufficient access rights on object id'))
                        {
                            stipsWrapperLst[stipsErrorToWraperIndexMap.get(i)].stipsEdit = true; 
                            //note on insuffivient privilage
                            stipsSingleErrorOnSave = true;
                        }
                    }
                  
                }
                if(stipsSingleErrorOnSave == false && !stipsIsNewBtnPress)
                {
                    stipsLst = getStipsFromDB(opportunityId, stipsBlockSize, stipsOffsetSize, stipsFieldsApiSet, stipsSortExpression, stipsSortDirection);
                    stipsFieldToSumMap = getStipsFieldSum(stipsAggregateQueryStr);
                    stipsFirstRun = true;
                }
                if(String.isNotBlank(stipsMsgStr)) 
                {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,stipsMsgStr));
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
        
        for(Schema.FieldSetMember fieldInstance :pStipsFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency') 
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double'))
            {
                stipsAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                stipsFieldSumSet.add(fieldInstance.getFieldPath());
                
            }
            //stipsFieldsApiSet.add(fieldInstance.getfieldPath());
            stipsFieldToSumMap.put(fieldInstance.getFieldPath(), 100);
        }
        
        stipsAggregateQueryStr += 'COUNT(Id) stipsCount FROM Stips__c Where Opportunity__c = \''+opportunityId+'\'';
        
        return stipsAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getStipsFieldSum(String pStipsAggregateQueryStr)
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
    
    
     public void collectStipData() 
     {
        String s1 = ApexPages.currentPage().getParameters().get('data');
        system.debug('name---->'+ApexPages.currentPage().getParameters().get('name'));
        transient Blob attchmentBody = EncodingUtil.base64Decode(s1.substringAfter('base64,'));
        // Assign value to attachment
        Attachment objAttachment = new Attachment();  
        objAttachment.Body= attchmentBody;
        objAttachment.ParentId = ApexPages.currentPage().getParameters().get('id');
        objAttachment.Name = ApexPages.currentPage().getParameters().get('name');
        
        
        try
        {
            insert objAttachment;
            Stips_Attachment__c objStipsAtt = new Stips_Attachment__c();
            objStipsAtt.Attachment_ID__c = objAttachment.id;
            objStipsAtt.Stips__c = ApexPages.currentPage().getParameters().get('stipID');
            insert objStipsAtt;
            //getStipRelatedAttachment();
            stipsFirstRun = true;
        } 
        catch(Exception e) 
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
    }
    
    
    //to get attachments to download from vf page
    @RemoteAction
    global static List<AttachmentResponse> getAttachments(Id oppID, String listAttID) 
    {
         system.debug('listAttID--->'+listAttID);
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
            if(mapCopyCount.containskey(objAttach.Name))
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
            }
            
            
            
        }
        
        return listAttch;
    }
    
    
    //method for the first page of list to be displayed
    public void beginningStips() 
    {
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
        public List<ID> listAttachID                             {get;set;}
        public StipsWrapper(Stips__c stipsInstance, Integer pStipsIndex, Boolean pStipsEdit,Integer pNoAttachment,
                        List<ID> pListAttachID) 
        {
            stips = stipsInstance;
            stipsIndex = pStipsIndex;
            stipsEdit = pStipsEdit;
            noAttachment = pNoAttachment;
            listAttachID = pListAttachID;
        }
    }
    
    
    // Wrapper to store attchemnt data
    // Note javascript don't no the object structure like Attchement, account, lead
    global class AttachmentResponse
    {
        public String attName {get;set;}
        public String attchBody {get;set;}
        public AttachmentResponse(String attName, String attchBody)
        {
            this.attName = attName;
            this.attchBody = attchBody;
        }
    }// end inner class AttachmentResponse

    
    
    
    
}