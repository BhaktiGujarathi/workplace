/**
 *  This class is a helper class for setting default values
 *
 *  Version     Author                      Date(DD/MM/YYYY)            Description
 *  1.0                                                                 Initial draft[]
 *  1.1         Ajinkya Hingne              14/10/2016                  Show default vals when creating new record
 */
global with sharing class GRIDSubmissionController {

    public String OpportunityId;
    public List<Submission__c> submisionLst;
    public Map<Id, Submission__c> submisionFromDbMap;
    public List<SubmissionWrapper> submisionWrapperLst;
    public String submisionAggregateQueryStr = '';
    public String submisionFieldsString = '';
    public Set<String> submisionFieldsApiSet;
    public Boolean submisionFirstRun;
    public Boolean submisionIsNewBtnPress;
    public Boolean submisionSingleErrorOnSave;
    public String submisionFieldType;
    public Boolean submisionEditAll;
    public static Map<String, Schema.SObjectType> globalMap;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    public List<Schema.FieldSetMember> submisionFieldsetList                            {get; set;}
    public Set<string> submisionFieldSumSet                                             {get; set;}
    public Map<String, Decimal> submisionFieldToSumMap                                  {get; set;}
    public Integer submisionRecordCount                                                 {get; set;}
    public Integer submisionBlockSize                                                   {get; set;}
    public Integer submisionOffsetsize                                                  {get; set;}
    public Integer submisionIndexToRemove                                               {get; set;}
    public string submisionSortDirection                                                {get; set;}
    public String submisionSortExpression                                               {get; set;}
    public Opportunity opportunityObj                                                   {get; set;}
    public String submisionSortExprFieldApi                                             {get; set;}
    public Boolean submisionIsRefrenceField                                             {get; set;}
    public String  submisionRefrenceFieldLabel                                          {get; set;}
    public boolean submisionIsDisable                                                   {get; set;}
    // Editall Attribute
    public Boolean submisionEditAllFlag                                                 {get; set;}
    // boolean to handle save success message on navigation
    public Boolean submisionPageNavigated;
    
    public GRIDSubmissionController() 
    {
        if(GRIDOnloadStaticVariable.flipSubmission())
        {
            submisionIsDisable= false;
            opportunityObj = new Opportunity();
            opportunityId = Apexpages.currentPage().getParameters().get('id');
             if(opportunityId == null || opportunityId == '') {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, 'Opportunity does not exist'));
                submisionIsDisable = true;
            }
            else {
                opportunityObj = [SELECT AccountId
                                       , Id
                                       , Name 
                                  FROM Opportunity 
                                  WHERE Id =: opportunityId ];
            }
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
            submisionBlockSize = (Integer)customMetaDataSettingMap.get('Submissions').PageSize__c;
            submisionOffsetsize = 0;
            submisionLst = new List<Submission__c>();
            submisionFromDbMap = new Map<Id, Submission__c>();
            submisionWrapperLst = new List<SubmissionWrapper>();
            submisionFieldToSumMap = new Map<String, Decimal>();
            submisionFieldSumSet = new Set<String>();
            submisionFieldsApiSet = new Set<String>();
            submisionFieldsetList = new List<Schema.FieldSetMember>();
            submisionIsNewBtnPress = false;
            submisionSortDirection = 'DESC';
            submisionSortExpression = 'CreatedDate';
            submisionFieldType = '';
            submisionEditAll = false;
            submisionPageNavigated = false;
            
            submisionFirstRun =false;
            Schema.DescribeSObjectResult submisionDescbResult = globalMap.get(customMetaDataSettingMap.get('Submissions').Object_API_Name__c).getDescribe();
            submisionFieldsetList = submisionDescbResult.FieldSets.getMap().get(customMetaDataSettingMap.get('Submissions').Fieldset_Name__c).getFields();
            
            GRIDUtility.ReferenceFieldWrapper refWrap = new GRIDUtility.ReferenceFieldWrapper(submisionFieldsetList, ' ', false);
            refWrap = GRIDUtility.isReferenceFieldPresent(refWrap);
            submisionIsRefrenceField = refWrap.isReferenceField;
            submisionRefrenceFieldLabel = refWrap.refrenceFieldLabel;
            
            if(!submisionIsRefrenceField)
            {
                submisionAggregateQueryStr = buildSubmissionAggregateQuery(submisionFieldsetList);
                submisionFieldToSumMap = getSubmissionFieldSum(submisionAggregateQueryStr);
                submisionFieldsApiSet = buildSetFromFieldListSubmission(submisionFieldsetList);
                if(opportunityId != null && opportunityId != '')
                    submisionLst = getSubmissionFromDB(opportunityId, submisionBlockSize, submisionOffsetsize, submisionFieldsApiSet, submisionSortExpression, submisionSortDirection);
                    String str1 = String.valueOf(Opportunity.Type.getDescribe().getDefaultValue());
                    system.debug('>>> str ' +str1 );
                    String roleDefaultValue = String.valueOf(OpportunityContactRole.Role.getDescribe().getDefaultValue());
                    system.debug('>>>roleDefaultValue : '+roleDefaultValue);
                submisionFirstRun = true;
            }
           
            
        }
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListSubmission(List<Schema.FieldSetMember> pSubmisionFieldsetList)
    {
        String submisionReferenceField;
        for(Schema.FieldSetMember fieldInstance :pSubmisionFieldsetList)
        {
            
            submisionFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                submisionReferenceField = '';
                if(fieldInstance.getfieldPath().contains('__c'))
                {
                    submisionReferenceField += fieldInstance.getfieldPath().substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    submisionReferenceField += fieldInstance.getfieldPath().substringBefore('Id')+'.Name';
                }
                submisionFieldsApiSet.add(submisionReferenceField);
            }
        }
        
        return submisionFieldsApiSet;
    }
    
    // method to build dynamic query for SUM and COUNT
    public String buildSubmissionAggregateQuery(List<Schema.FieldSetMember> pSubmisionFieldsetList)
    {
        submisionAggregateQueryStr = 'SELECT ';
        submisionAggregateQueryStr += 'COUNT(Id) submisionCount FROM Submission__c Where Opportunity__c = \''+opportunityId+'\'';
        
        return submisionAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getSubmissionFieldSum(String pSubmisionAggregateQueryStr)
    {
        if(opportunityId <> null && opportunityId <> '') 
        {
            List<SObject> submisionSumQueryResult = new List<SObject>();
            submisionSumQueryResult = Database.query(pSubmisionAggregateQueryStr);
        
            for(String fieldName :submisionFieldSumSet) 
            {
                if(submisionSumQueryResult[0].get(fieldName) != null)
                {
                    submisionFieldToSumMap.put(fieldName, (Decimal)submisionSumQueryResult[0].get(fieldName)); 
                }
            }
            submisionRecordCount = (Integer)submisionSumQueryResult[0].get('submisionCount');
       
            return submisionFieldToSumMap;
         }
         submisionRecordCount = 0;
         return null;
    }
    
    // method to get payables from DB
    public List<Submission__c> getSubmissionFromDB(String pOpportunityId, Integer pSubmisionBlockSize, Integer pSubmisionOffsetSize, Set<String> pSubmisionFieldsApiSet,
                                                   String pSubmisionSortExpression, String pSubmisionSortDirection) 
    {
        //payLst.clear();
        if(pOpportunityId <> null && pOpportunityId <> '') 
        {
            String submisionQueryStr = '';
            submisionFieldsString = MCAUtility.getStringfromSet(pSubmisionFieldsApiSet, null);
            submisionQueryStr = 'Select ' +submisionFieldsString+ 
                            ' From Submission__c Where Opportunity__c =:pOpportunityId ORDER BY '+pSubmisionSortExpression+' '+pSubmisionSortDirection+' NULLS LAST LIMIT '
                            +pSubmisionBlockSize+' Offset ' +pSubmisionOffsetSize;
            return database.query(submisionQueryStr);
        }
        return new List<Submission__c>();
    }
    
    // method to get the wrapper list
    public List<SubmissionWrapper> getsubmisionWrapperLst() 
    {
         if(submisionFirstRun)
        {            
            submisionWrapperLst = new List<SubmissionWrapper>();
        }
        if(submisionLst<> null && submisionLst.size() > 0 ) 
        {
            if(submisionFirstRun)
            {            
                //submisionWrapperLst = new List<SubmissionWrapper>();
                for (Integer i = 0; i < submisionLst.size(); i++) 
                {
                    submisionWrapperLst.add(new SubmissionWrapper(submisionLst[i], i, submisionEditAllFlag));
                }
                submisionFirstRun = false;
           
            }
        }
           // submisionFieldToSumMap = getSubmissionFieldSum(submisionAggregateQueryStr);

        return submisionWrapperLst;
    }
    
    // method to build a map from a list from DB
    public Map<Id, Submission__c> getSubmissionMapFromList(List<Submission__c> pSubmisionLst) 
    {
        submisionFromDbMap.clear();
        for(Submission__c submisionInstance :pSubmisionLst) 
        {
            submisionFromDbMap.put(submisionInstance.Id, submisionInstance);
        }
        return submisionFromDbMap;
    }
    
    // method to create new payables
    public void newSubmission() 
    {
        globalMap = GRIDOnloadStaticVariable.getGlobalMap();
        customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
        Schema.DescribeSObjectResult subDescbResult = globalMap.get(customMetaDataSettingMap.get('Submissions').Object_API_Name__c).getDescribe();
        submisionIsNewBtnPress = true;
        if(!submisionEditAll)
        {
            saveSubmissions();
        }
        else 
        {
            submisionSingleErrorOnSave = false;
        }
        submisionIsNewBtnPress = false;
        
        if(!submisionSingleErrorOnSave)
        {
            
            // to add new record only on first page
            if(submisionOffsetsize <> 0) 
            {
                submisionOffsetsize = 0;
                beginningSubmissions();
            }
            Submission__c submisionNew = new Submission__c();
            DefaultValueHelper.populateValues(submisionNew, submisionFieldsetList, subDescbResult);
            submisionNew.Opportunity__c = opportunityId;
            /*need to add at 0th index if list size > 0 else simple add will work*/
            if(submisionWrapperLst.size() > 0 && submisionLst.size() > 0)
            {
                submisionWrapperLst.add(0,new SubmissionWrapper(submisionNew, null, true));
                submisionLst.add(0,submisionNew);
                
            }else{
                submisionWrapperLst.add(new SubmissionWrapper(submisionNew, null, true));
                submisionLst.add(submisionNew);
            }

            // reindexing
            for(Integer i=0; i<submisionWrapperLst.size(); i++)
            {
                submisionWrapperLst[i].submisionIndex = i;
            }
        }
    }
    
    // method to delete payables
    public void deleteSubmission()
    {
        if(submisionWrapperLst[submisionIndexToRemove].submision.Id != null) 
         {
            try
            {
                delete submisionWrapperLst[submisionIndexToRemove].submision;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
         
         submisionLst.remove(submisionIndexToRemove);
         submisionWrapperLst.remove(submisionIndexToRemove);
         
          //re-indexing
             for(Integer i=0;i<submisionWrapperLst.size();i++)
             {
               submisionWrapperLst[i].submisionIndex = i;
             }
       
        if(submisionWrapperLst.size() <= 0)
        {
            refreshSubmissions();
        }
        submisionFieldToSumMap = getSubmissionFieldSum(submisionAggregateQueryStr);
    }
    
    // method to save payable
    public void saveSubmissions()
    {
        String submisionMsgStr = '';
        String submisionSuccessMsgStr ='';
        submisionSingleErrorOnSave = false;
        Boolean submisionIsUpdated = false;
        submisionEditAll = false;
        List<Submission__c> submisionListToUpdate = new List<Submission__c>();
        Map<Integer, Integer> submisionErrorToWraperIndexMap = new map<Integer, Integer>();
        
        List<Submission__c> submisionTempLst = getSubmissionFromDB(opportunityId, submisionBlockSize, submisionOffsetsize, submisionFieldsApiSet, submisionSortExpression, submisionSortDirection);
        submisionFromDBMap = getSubmissionMapFromList(submisionTempLst);
        
        for(SubmissionWrapper submisionWraperInstance :submisionWrapperLst) 
        {
            Submission__c submisionDBObj = submisionFromDBMap.get(submisionWraperInstance.submision.Id);
            if(submisionDBObj != null)
            {
                submisionIsUpdated = false;
                for(String submisionFieldInstance :submisionFieldsApiSet)
                {

                    if(!submisionFieldInstance.contains('.Name')) 
                    {
                        submisionIsUpdated  = submisionIsUpdated ||(submisionWraperInstance.submision.get(submisionFieldInstance) != submisionDBObj.get(submisionFieldInstance));
                    }
                }
            }
            else
            {
                   if(!submisionIsNewBtnPress) 
                   {
                     submisionIsUpdated = true;
                   }
            }

            if(submisionIsUpdated) 
            {
                submisionListToUpdate.add(submisionWraperInstance.submision);
                submisionErrorToWraperIndexMap.put(submisionListToUpdate.size()-1, submisionWraperInstance.submisionIndex);
            }
            if(!submisionIsNewBtnPress) 
            {
                submisionWraperInstance.submisionEdit = submisionEditAllFlag;
            }
        }
        
        try
        {
            if(submisionListToUpdate != null && submisionListToUpdate.size() >0)
            {
               List<Database.upsertResult> results = Database.upsert(submisionListToUpdate, false);
               for (Integer i =0; i < results.size(); i++) 
                {
                    if (!results[i].isSuccess())
                    {
                        for (Database.Error err : results[i].getErrors())
                        {
                             String recordError = err.getMessage();
                             /*if(recordError.contains('insufficient access rights on'))
                             {
                                 recordError = 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.';
                             }
                             else
                             {
                             
                                  submisionWrapperLst[submisionErrorToWraperIndexMap.get(i)].submisionEdit = true; 
                                  
                             }*/
                             if(!recordError.contains('insufficient access rights on'))
                             {
                                 submisionWrapperLst[submisionErrorToWraperIndexMap.get(i)].submisionEdit = submisionEditAllFlag; 
                             }
                             submisionSingleErrorOnSave = true;
                             submisionMsgStr = submisionMsgStr + 'Error Record '+(submisionErrorToWraperIndexMap.get(i)+1)+' : '+ recordError + '<br />'; 
                            
                        }
                    }
                    else  if(results[i].isSuccess())
                    {
                         submisionSuccessMsgStr = submisionSuccessMsgStr+ 'Success Record '+(submisionErrorToWraperIndexMap.get(i)+1)+' : '+ 'saved successfully!' + '<br />';
                         submisionWrapperLst[submisionErrorToWraperIndexMap.get(i)].submisionEdit = submisionEditAllFlag;
                    }
                }
                if(submisionSingleErrorOnSave == false && !submisionIsNewBtnPress)
                {
                  submisionLst = getSubmissionFromDB(opportunityId, submisionBlockSize, submisionOffsetsize, submisionFieldsApiSet, submisionSortExpression, submisionSortDirection);
                  submisionFieldToSumMap = getSubmissionFieldSum(submisionAggregateQueryStr);
                  submisionFirstRun = true;
                }
                if(String.isNotBlank(submisionMsgStr) || String.isNotBlank(submisionSuccessMsgStr)) 
                {
                    if(submisionPageNavigated == true)
                    {
                        //submisionPageNavigated = false;
                        submisionSuccessMsgStr = 'Last changes made by you were saved successfully!';
                    }
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,submisionMsgStr +'<br/>'+ submisionSuccessMsgStr));
                    
                }
            }
            submisionPageNavigated = false;
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             submisionFirstRun = false;
        }
        
    }
    
    // method to edit all commissions
    public void editAllSubmissions()
    {
        submisionFirstRun = false;
        submisionEditAll = true;
        for(Integer i=0; i< submisionWrapperLst.size(); i++) 
        {
            submisionWrapperLst[i].submisionEdit = true;
        }
    }
    
    // method to refresh
    public void refreshSubmissions() 
    {
        submisionLst = getSubmissionFromDB(opportunityId, submisionBlockSize, submisionOffsetsize, submisionFieldsApiSet, submisionSortExpression, submisionSortDirection);
        submisionFieldToSumMap = getSubmissionFieldSum(submisionAggregateQueryStr);
        submisionFirstRun = true;
    }
    
    //method for the first page of list to be displayed
    public void beginningSubmissions() 
    {
        submisionPageNavigated = true;
        saveSubmissions();
        if(!submisionSingleErrorOnSave) 
        {
            submisionOffsetsize = 0;
            submisionLst = getSubmissionFromDB(opportunityId, submisionBlockSize, submisionOffsetsize, submisionFieldsApiSet, submisionSortExpression, submisionSortDirection);
            submisionFirstRun = true;
        }
    }
    
    //method for previous page of list to be displayed
    public void previousSubmissions() 
    {
        submisionPageNavigated = true;
        saveSubmissions();
        if(!submisionSingleErrorOnSave && submisionBlockSize <= submisionOffsetsize)
        {
            submisionOffsetsize = submisionOffsetsize - submisionBlockSize;
            submisionLst = getSubmissionFromDB(opportunityId, submisionBlockSize, submisionOffsetsize, submisionFieldsApiSet, submisionSortExpression, submisionSortDirection);
            submisionFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void nextSubmissions() 
    {
        submisionPageNavigated = true;
        saveSubmissions();
        if(!submisionSingleErrorOnSave && submisionOffsetsize <= submisionRecordCount) 
        {
            
            submisionOffsetsize = submisionOffsetsize + submisionBlockSize;
            submisionLst = getSubmissionFromDB(opportunityId, submisionBlockSize, submisionOffsetsize, submisionFieldsApiSet, submisionSortExpression, submisionSortDirection);
            submisionFirstRun = true;
        }
    }
    
    //method for last page of list to be displayed
    public void endSubmissions() 
    {
        submisionPageNavigated = true;
        saveSubmissions();
        if(!submisionSingleErrorOnSave && math.mod(submisionRecordCount , submisionBlockSize) == 0){
            submisionOffsetsize = submisionBlockSize * ((submisionRecordCount/submisionBlockSize)-1);
        } else if (!submisionSingleErrorOnSave && math.mod(submisionRecordCount , submisionBlockSize) != 0){
            submisionOffsetsize = submisionBlockSize * ((submisionRecordCount/submisionBlockSize));
        }
            submisionLst = getSubmissionFromDB(opportunityId, submisionBlockSize, submisionOffsetsize, submisionFieldsApiSet, submisionSortExpression, submisionSortDirection);
            submisionFirstRun = true;
    }
    
    //method to sort list of subimssions
    public void sortSubmissions()
    {
            string submisionReferenceFieldName = '';
            submisionFieldType = Apexpages.currentPage().getParameters().get('submisionTypeParam');
            if(submisionFieldType.equalsIgnoreCase('REFERENCE'))
            {
                if(submisionSortExpression.contains('__c'))
                {
                    submisionReferenceFieldName += submisionSortExpression.substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    submisionReferenceFieldName += submisionSortExpression.substringBefore('Id')+'.Name';
                }
                submisionSortExpression = string.valueOf(submisionReferenceFieldName);
            }
            refreshSubmissions();
    }
       
    // wrapper for payables
    public class SubmissionWrapper
    {
        public Submission__c submision                                                   {get;set;}
        public Integer submisionIndex                                                    {get;set;}
        public Boolean submisionEdit                                                     {get;set;}
        public SubmissionWrapper(Submission__c submisionInstance, Integer pSubmisionIndex, Boolean pSubmisionEdit) 
        {
            submision = SubmisionInstance;
            submisionIndex = pSubmisionIndex;
            submisionEdit = pSubmisionEdit;
        }
    }

}