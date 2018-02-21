public with sharing class GRIDSubmissionController {

    public Id OpportunityId;
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
    
    public static Map<String, Schema.SObjectType> globalMap;

    public List<Schema.FieldSetMember> submisionFieldsetList                            {get; set;}
    public Set<string> submisionFieldSumSet                                             {get; set;}
    public Map<String, Decimal> submisionFieldToSumMap                                  {get; set;}
    public Integer submisionRecordCount                                                 {get; set;}
    public Integer submisionBlockSize                                                   {get; set;}
    public Integer submisionOffsetsize                                                  {get; set;}
    public Integer submisionIndexToRemove                                               {get; set;}
    public string submisionSortDirection                                                {get; set;}
    public String submisionSortExpression                                               {get; set;}
    
    public GRIDSubmissionController() 
    {
        if(GRIDOnloadStaticVariable.flipSubmission())
        {
            opportunityId = Apexpages.currentPage().getParameters().get('id');
        
            submisionBlockSize = (Integer)GRIDTabSetting__c.getValues('Submission').PageSize__c;
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
        
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            Schema.DescribeSObjectResult submisionDescbResult = globalMap.get('Submission__c').getDescribe();
            submisionFieldsetList = submisionDescbResult.FieldSets.getMap().get(GRIDTabSetting__c.getValues('Submission').Fieldset_Name__c).getFields();
        
            submisionAggregateQueryStr = buildSubmissionAggregateQuery(submisionFieldsetList);
            submisionFieldsApiSet = buildSetFromFieldListSubmission(submisionFieldsetList);
            submisionLst = getSubmissionFromDB(opportunityId, submisionBlockSize, submisionOffsetsize, submisionFieldsApiSet, submisionSortExpression, submisionSortDirection);
            submisionFirstRun = true;
        }
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListSubmission(List<Schema.FieldSetMember> pSubmisionFieldsetList)
    {
        String submisionReferenceField;
        for(Schema.FieldSetMember fieldInstance :pSubmisionFieldsetList)
        {
            submisionReferenceField = '';
            submisionFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
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
        
        for(Schema.FieldSetMember fieldInstance :pSubmisionFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency') 
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double'))
            {
                submisionAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                submisionFieldSumSet.add(fieldInstance.getFieldPath());
                
            }
            //submisionFieldsApiSet.add(fieldInstance.getfieldPath());
            submisionFieldToSumMap.put(fieldInstance.getFieldPath(), 100);
        }
        
        submisionAggregateQueryStr += 'COUNT(Id) submisionCount FROM Submission__c Where Opportunity__c = \''+opportunityId+'\'';
        
        return submisionAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getSubmissionFieldSum(String pSubmisionAggregateQueryStr)
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
    
    // method to get payables from DB
    public List<Submission__c> getSubmissionFromDB(Id pOpportunityId, Integer pSubmisionBlockSize, Integer pSubmisionOffsetSize, Set<String> pSubmisionFieldsApiSet,
                                                   String pSubmisionSortExpression, String pSubmisionSortDirection) 
    {
        //payLst.clear();
        String submisionQueryStr = '';
        submisionFieldsString = DEWUtility.getStringfromSet(pSubmisionFieldsApiSet, null);
        submisionQueryStr = 'Select ' +submisionFieldsString+ 
                        ' From Submission__c Where Opportunity__c =:pOpportunityId ORDER BY '+pSubmisionSortExpression+' '+pSubmisionSortDirection+' NULLS LAST LIMIT '
                        +pSubmisionBlockSize+' Offset ' +pSubmisionOffsetSize;
        //payLst = database.query(payQueryStr);

        return database.query(submisionQueryStr);
    }
    
    // method to get the wrapper list
    public List<SubmissionWrapper> getsubmisionWrapperLst() 
    {
        if(submisionFirstRun)
        {
            submisionWrapperLst = new List<SubmissionWrapper>();
            for (Integer i = 0; i < submisionLst.size(); i++) 
            {
                submisionWrapperLst.add(new SubmissionWrapper(submisionLst[i], i, false));
            }
            submisionFirstRun = false;
        }
        
        submisionFieldToSumMap = getSubmissionFieldSum(submisionAggregateQueryStr);

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
        submisionIsNewBtnPress = true;
        saveSubmissions();
        submisionIsNewBtnPress = false;
        
        if(!submisionSingleErrorOnSave)
        {
            // to add new record only on first page
            if(submisionOffsetsize <> 0) 
            {
                submisionOffsetsize = 0;
                beginningSubmissions();
            }
            
            Submission__c submisionNew = new Submission__c(Opportunity__c = opportunityId);
            
             /*need to add at 0th index if list size > 0 else simple add will work*/
               if(submisionWrapperLst.size() > 0 && submisionLst.size() > 0)
               {
                 submisionWrapperLst.add(0,new SubmissionWrapper(submisionNew, null, true));
                 submisionLst.add(0,submisionNew);
               }
               else
               {
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
        // refreshCommissions();
    }
    
    // method to cave payable
    public void saveSubmissions()
    {
        String submisionMsgStr = '';
        submisionSingleErrorOnSave = false;
        Boolean submisionIsUpdated = false;
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
                    system.debug('>>> submisionFieldInstance : '+submisionFieldInstance);
                    if(!submisionFieldInstance.contains('__r.Name')) 
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
                submisionWraperInstance.submisionEdit = false;
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
                              //+1 is added for Display on VF page only  
                              submisionMsgStr = submisionMsgStr + 'Error Record '+(submisionErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!submisionMsgStr.contains('insufficient access rights on object id'))
                        {
                            submisionWrapperLst[submisionErrorToWraperIndexMap.get(i)].submisionEdit = true; 
                            //note on insuffivient privilage
                            submisionSingleErrorOnSave = true;
                        }
                    }
                    else
                    {
                         submisionWrapperLst[submisionErrorToWraperIndexMap.get(i)].submisionEdit = false;
                    }
                }
                if(submisionSingleErrorOnSave == false && !submisionIsNewBtnPress)
                {
                  submisionLst = getSubmissionFromDB(opportunityId, submisionBlockSize, submisionOffsetsize, submisionFieldsApiSet, submisionSortExpression, submisionSortDirection);
                  submisionFieldToSumMap = getSubmissionFieldSum(submisionAggregateQueryStr);
                  submisionFirstRun = true;
                }
                if(String.isNotBlank(submisionMsgStr)) 
                {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,submisionMsgStr));
                }
            }
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
        for(Integer i=0; i< submisionWrapperLst.size(); i++) 
        {
            submisionWrapperLst[i].submisionEdit = true;
        }
    }
    
    // method to refresh
    public void refreshSubmissions() 
    {
        submisionLst = getSubmissionFromDB(opportunityId, submisionBlockSize, submisionOffsetsize, submisionFieldsApiSet, submisionSortExpression, submisionSortDirection);
        submisionFirstRun = true;
    }
    
    //method for the first page of list to be displayed
    public void beginningSubmissions() 
    {
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
        public SubmissionWrapper(Submission__c submisionInstance, Integer pSubmisionIndex, Boolean pSubmisionEdit) {
            submision = SubmisionInstance;
            submisionIndex = pSubmisionIndex;
            submisionEdit = pSubmisionEdit;
        }
    }

}