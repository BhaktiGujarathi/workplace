global with sharing class GRIDPayablesController 
{
    public String OpportunityId;
    public List<Payable__c> payLst;
    public Map<Id, Payable__c> payFromDbMap;
    public List<PayableWrapper> payWrapperLst;
    public String payAggregateQueryStr = '';
    public String payFieldsString = '';
    public Set<String> payFieldsApiSet;
    public Boolean payFirstRun;
    public Boolean payIsNewBtnPress;
    public Boolean paySingleErrorOnSave;
    public String payFieldType;
    public Boolean payEditAll;
    
    public static Map<String, Schema.SObjectType> globalMap;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;

    public List<Schema.FieldSetMember> payFieldsetList                                  {get; set;}
    public Set<string> payFieldSumSet                                                   {get; set;}
    public Map<String, Decimal> payFieldToSumMap                                        {get; set;}
    public Integer payRecordCount                                                       {get; set;}
    public Integer payBlockSize                                                         {get; set;}
    public Integer payOffsetsize                                                        {get; set;}
    public Integer payIndexToRemove                                                     {get; set;}
    public string paySortDirection                                                      {get; set;}
    public String paySortExpression                                                     {get; set;}
    public String paySortExprFieldApi                                                   {get; set;}
    public Boolean payIsRefrenceField                                                   {get; set;}
    public String payRefrenceFieldLabel                                                 {get; set;}
    public boolean payIsDisable                                                         {get; set;}
    // Editall Attribute
    public Boolean payEditAllFlag                                                       {get; set;}
    // boolean to handle save success message on navigation
    public Boolean payPageNavigated;
    
    public GRIDPayablesController() 
    {
        if(GRIDOnloadStaticVariable.flipPayable())
        {
            payIsDisable = false;
            opportunityId = Apexpages.currentPage().getParameters().get('id');
            if(opportunityId == null || opportunityId == '') {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, 'Opportunity does not exist'));
                payIsDisable = true;
            }
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
            
            //payBlockSize = (Integer)GRIDTabSetting__c.getValues('Payable').PageSize__c;
            payBlockSize = (Integer)customMetaDataSettingMap.get('Payables').PageSize__c;
            payOffsetsize = 0;
    
            payLst = new List<Payable__c>();
            payFromDbMap = new Map<Id, Payable__c>();
            payWrapperLst = new List<PayableWrapper>();
            payFieldToSumMap = new Map<String, Decimal>();
            payFieldSumSet = new Set<String>();
            payFieldsApiSet = new Set<String>();
            payFieldsetList = new List<Schema.FieldSetMember>();
            payIsNewBtnPress = false;
            paySortDirection = 'DESC';
            paySortExpression = 'CreatedDate';
            payFieldType = '';
            payEditAll = false;
            payPageNavigated = false;
        
            
            Schema.DescribeSObjectResult payDescbResult = globalMap.get(customMetaDataSettingMap.get('Payables').Object_API_Name__c).getDescribe();
            //payFieldsetList = payDescbResult.FieldSets.getMap().get(GRIDTabSetting__c.getValues('Payable').Fieldset_Name__c).getFields();
            payFieldsetList = payDescbResult.FieldSets.getMap().get(customMetaDataSettingMap.get('Payables').Fieldset_Name__c).getFields();
            
            GRIDUtility.ReferenceFieldWrapper refWrap = new GRIDUtility.ReferenceFieldWrapper(payFieldsetList, ' ', false);
            refWrap = GRIDUtility.isReferenceFieldPresent(refWrap);
            payIsRefrenceField = refWrap.isReferenceField;
            payRefrenceFieldLabel = refWrap.refrenceFieldLabel;
            
            if(!payIsRefrenceField)
            {
                payAggregateQueryStr = buildPayAggregateQuery(payFieldsetList);
                payFieldToSumMap = getPayFieldSum(payAggregateQueryStr);
                payFieldsApiSet = buildSetFromFieldListPayable(payFieldsetList);
                if(opportunityId != null && opportunityId != '')
                    payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet, paySortExpression, paySortDirection);
                payFirstRun = true;
            }
        }
    }
    /*
    public String getPaySortExpression()
    {
    
        return paySortExpression;                                                     
    }*/
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListPayable(List<Schema.FieldSetMember> pPayFieldsetList)
    {
        String payReferenceField;
        for(Schema.FieldSetMember fieldInstance :pPayFieldsetList)
        {
            
            payFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                payReferenceField = '';
                if(fieldInstance.getfieldPath().contains('__c'))
                {
                    payReferenceField += fieldInstance.getfieldPath().substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    payReferenceField += fieldInstance.getfieldPath().substringBefore('Id')+'.Name';
                }
                payFieldsApiSet.add(payReferenceField);
            }
        }
        
        return payFieldsApiSet;
    }
    
    // method to build dynamic query for SUM and COUNT
    public String buildPayAggregateQuery(List<Schema.FieldSetMember> pPayFieldsetList)
    {
        payAggregateQueryStr = 'SELECT ';
        
        for(Schema.FieldSetMember fieldInstance :pPayFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency') 
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double')
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Integer'))
            {
                payAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                payFieldSumSet.add(fieldInstance.getFieldPath());
                
            }
            //payFieldsApiSet.add(fieldInstance.getfieldPath());
            payFieldToSumMap.put(fieldInstance.getFieldPath(), -999.999);
        }
        
        payAggregateQueryStr += 'COUNT(Id) payCount FROM Payable__c Where Opportunity__c = \''+opportunityId+'\'';
        
        return payAggregateQueryStr;
    }

    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getPayFieldSum(String pPayAggregateQueryStr)
    {
        if(opportunityId <> null && opportunityId <> '')
        {
            List<SObject> paySumQueryResult = new List<SObject>();
            paySumQueryResult = Database.query(pPayAggregateQueryStr);
        
            for(String fieldName :payFieldSumSet) 
            {
                payFieldToSumMap.put(fieldName,0);
                if(paySumQueryResult[0].get(fieldName) != null)
                {
                
                    payFieldToSumMap.put(fieldName, (Decimal)paySumQueryResult[0].get(fieldName)); 
                }
            }
            payRecordCount = (Integer)paySumQueryResult[0].get('payCount');
            return payFieldToSumMap;
        }
            payRecordCount = 0;
            return null;
    }
    
    // method to get payables from DB
    /*
    public List<Payable__c> getPayableFromDB(Id pOpportunityId, Integer pPayBlockSize, Integer pPayOffsetSize, Set<String> pPayFieldsApiSet,
                                             String pPaySortExpression, String pPaySortDirection) */
    public List<Payable__c> getPayableFromDB(String pOpportunityId, Integer pPayBlockSize, Integer pPayOffsetSize, Set<String> pPayFieldsApiSet,
                                             String pPaySortExpression, String pPaySortDirection) 
    {
        if(pOpportunityId <> null && pOpportunityId <> '') 
        {
            String payQueryStr = '';
            payFieldsString = MCAUtility.getStringfromSet(pPayFieldsApiSet, null);
            payQueryStr = 'Select Opportunity__c,' +payFieldsString+ 
                        ' From Payable__c Where Opportunity__c =:pOpportunityId ORDER BY '+pPaySortExpression+' '+pPaySortDirection+' NULLS LAST LIMIT '
                        +pPayBlockSize+' Offset ' +pPayOffsetSize;

            return database.query(payQueryStr);
        }
        return new List<Payable__c>();
    }
    
    // method to get the wrapper list
    public List<PayableWrapper> getPayWrapperLst() 
    {
        if(payFirstRun)
        {
            payWrapperLst = new List<PayableWrapper>();
        }
        if(payLst<> null && payLst.size() > 0 )
        {
            if(payFirstRun)
            {
                //payWrapperLst = new List<PayableWrapper>();
                for (Integer i = 0; i < payLst.size(); i++) 
                {
                    payWrapperLst.add(new PayableWrapper(payLst[i], i, payEditAllFlag));
                }
                // moved inside if condition for getting aggregate results only if firstrun is true
                //payFieldToSumMap = getPayFieldSum(payAggregateQueryStr);
                payFirstRun = false;
            }
        }
        return payWrapperLst;
    }
    
    // method to build a map from a list from DB
    public Map<Id, Payable__c> getpayMapFromList(List<Payable__c> pPayLst) 
    {
        payFromDbMap.clear();
        for(Payable__c payInstance :pPayLst) 
        {
            payFromDbMap.put(payInstance.Id, payInstance);
        }
        return payFromDbMap;
    }
    
    // method to create new payables
    public void newPay() 
    {
        payIsNewBtnPress = true;
        if(!payEditAll)
        {
            savePayables();
        }
        else
        {
            paySingleErrorOnSave = false;
        }
        payIsNewBtnPress = false;
        
        if(!paySingleErrorOnSave)
        {
            // to add new record only on first page
            if(payOffsetsize <> 0) 
            {
                payOffsetsize = 0;
                beginningPayable();
            }

            Payable__c payNew = new Payable__c(Opportunity__c = opportunityId,
                                               Status__c = pickListDefaultValuePayables(),
                                               OwnerId = UserInfo.getUserId());
            //payWrapperLst.add(0, new PayableWrapper(payNew, null, true));
           // payLst.add(0, payNew);
            
            
             /*need to add at 0th index if list size > 0 else simple add will work*/
               if(payWrapperLst.size() > 0 && payLst.size() > 0)
               {
                 payWrapperLst.add(0,new PayableWrapper(payNew, null, true));
                 payLst.add(0,payNew);
               }
               else
               {
                 payWrapperLst.add(new PayableWrapper(payNew, null, true));
                 payLst.add(payNew);
               }
            
            // reindexing
            for(Integer i=0; i<payWrapperLst.size(); i++)
            {
                payWrapperLst[i].payIndex = i;
            }
        }
    }
    
    // method to delete payables
    public void deletePay()
    {
        if(payWrapperLst[payIndexToRemove].pay.Id != null) 
         {
            try
            {
                delete payWrapperLst[payIndexToRemove].pay;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
         
         payLst.remove(payIndexToRemove);
         payWrapperLst.remove(payIndexToRemove);
         
          //re-indexing
             for(Integer i=0;i<payWrapperLst.size();i++)
             {
               payWrapperLst[i].payIndex = i;
             }
        // refreshCommissions();
        
        if(payWrapperLst.size() <= 0) 
        {
            refreshPayables();
        }
        payFieldToSumMap = getPayFieldSum(payAggregateQueryStr);
    }
    
    // method to cave payable
    public void savePayables()
    {
        String payMsgStr = '';
        String paySuccessMsgStr ='';
        paySingleErrorOnSave = false;
        Boolean payIsUpdated = false;
        payEditAll = false;
        List<Payable__c> payListToUpdate = new List<Payable__c>();
        Map<Integer, Integer> payErrorToWraperIndexMap = new map<Integer, Integer>();
        
        List<Payable__c> payTempLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet, paySortExpression, paySortDirection);
        payFromDBMap = getpayMapFromList(payTempLst);
        
        for(PayableWrapper payWraperInstance :payWrapperLst) 
        {
            Payable__c payDBObj = payFromDBMap.get(payWraperInstance.pay.Id);
            if(payDBObj != null)
            {
                payIsUpdated = false;
                for(String payFieldInstance :payFieldsApiSet)
                {
                    if(!payFieldInstance.contains('.Name'))
                    {
                        payIsUpdated  = payIsUpdated ||(payWraperInstance.pay.get(payFieldInstance) != payDBObj.get(payFieldInstance));
                    }
                }
            }
            else
            {
                   if(!payIsNewBtnPress) 
                   {
                     payIsUpdated = true;
                   }
            }

            if(payIsUpdated) 
            {
                payListToUpdate.add(payWraperInstance.pay);
                payErrorToWraperIndexMap.put(payListToUpdate.size()-1, payWraperInstance.payIndex);
            }
            
            payWraperInstance.payEdit = payEditAllFlag;
        }
        
        try
        {
            if(payListToUpdate != null && payListToUpdate.size() >0)
            {
                List<Database.upsertResult> results = Database.upsert(payListToUpdate, false);
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
                                 payWrapperLst[payErrorToWraperIndexMap.get(i)].payEdit = true; 
                                 
                             }*/
                             
                             if(!recordError.contains('insufficient access rights on'))
                             {
                                 payWrapperLst[payErrorToWraperIndexMap.get(i)].payEdit = true; 
                             }
                             paySingleErrorOnSave = true;
                             payMsgStr = payMsgStr + 'Error Record '+(payErrorToWraperIndexMap.get(i)+1)+' : '+ recordError + '<br />'; 
                            
                        }
                    }
                    else if(results[i].isSuccess())
                    {
                         paySuccessMsgStr = paySuccessMsgStr+ 'Success Record '+(payErrorToWraperIndexMap.get(i)+1)+' : '+ 'saved successfully!' + '<br />';
                         payWrapperLst[payErrorToWraperIndexMap.get(i)].payEdit = payEditAllFlag;
                    }
                }
                if(paySingleErrorOnSave == false && !payIsNewBtnPress)
                {
                  payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet, paySortExpression, paySortDirection);
                  payFieldToSumMap = getPayFieldSum(payAggregateQueryStr);
                  payFirstRun = true;
                }
                if(String.isNotBlank(payMsgStr) || String.isNotBlank(paySuccessMsgStr)) 
                {
                    if(payPageNavigated)
                    {
                        payPageNavigated = false;
                        paySuccessMsgStr = 'Last changes made by you were saved successfully!';
                    }   
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,payMsgStr +'<br/>'+ paySuccessMsgStr));
                }
            }
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             payFirstRun = false;
        }
    }
    
    //method for the first page of list to be displayed
    public void beginningPayable() 
    {
        payPageNavigated = true;
        savePayables();
        if(!paySingleErrorOnSave) 
        {
            payOffsetsize = 0;
            payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet, paySortExpression, paySortDirection);
            payFirstRun = true;
        }
    }
    
    //method for previous page of list to be displayed
    public void previousPayable() 
    {
        payPageNavigated = true;
        savePayables();
        if(!paySingleErrorOnSave && payBlockSize <= payOffsetsize)
        {
            payOffsetsize = payOffsetsize - payBlockSize;
            payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet, paySortExpression, paySortDirection);
            payFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void nextPayable() 
    {  
       payPageNavigated = true;
       savePayables();
       if(!paySingleErrorOnSave && payOffsetsize <= payRecordCount) 
       {
           payOffsetsize = payOffsetsize + payBlockSize;
           payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet, paySortExpression, paySortDirection);
           payFirstRun = true;
       }
    }
    
    //method for last page of list to be displayed
    public void endPayable() 
    {
        payPageNavigated = true;
        savePayables();
        if(!paySingleErrorOnSave && math.mod(payRecordCount , payBlockSize) == 0){
            payOffsetsize = payBlockSize * ((payRecordCount/payBlockSize)-1);
        } else if (!paySingleErrorOnSave && math.mod(payRecordCount , payBlockSize) != 0){
            payOffsetsize = payBlockSize * ((payRecordCount/payBlockSize));
        }
        
            payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet, paySortExpression, paySortDirection);
            payFirstRun = true;
    }
    
    //method to sort list of Payables
    public void sortPayables()
    {
            string payReferenceFieldName = '';
            payFieldType = Apexpages.currentPage().getParameters().get('payTypeParam');
            if(payFieldType.equalsIgnoreCase('REFERENCE'))
            {
                if(paySortExpression.contains('__c'))
                {
                    payReferenceFieldName += paySortExpression.substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    payReferenceFieldName += paySortExpression.substringBefore('Id')+'.Name';
                }
                paySortExpression = string.valueOf(payReferenceFieldName);
            }
            
            refreshPayables();
           
    }
    
    // method to edit all commissions
    public void editAllPayables()
    {
        payFirstRun = false;
        payEditAll = true;
        for(Integer i=0; i< payWrapperLst.size(); i++) 
        {
            payWrapperLst[i].payEdit = true;
        }

    }
    
    // method to refresh
    public void refreshPayables() 
    {
        payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet, paySortExpression, paySortDirection);
        payFieldToSumMap = getPayFieldSum(payAggregateQueryStr);
        payFirstRun = true;
    }
    
    //method to get picklist default value
    public String pickListDefaultValuePayables()
    {        
        String payDefaultPicklistVal;
        Schema.DescribeFieldResult payPicklistValues = Payable__c.Status__c.getDescribe();
        List <Schema.PicklistEntry> paylistPickListVal = payPicklistValues.getPicklistValues();        
        for (Schema.PicklistEntry payPickValue: paylistPickListVal) {
            if (payPickValue.isDefaultValue()) 
            {
                payDefaultPicklistVal= payPickValue.getValue();
            }    
        }   
        return payDefaultPicklistVal;
    }
    
    
    // wrapper for payables
    public class PayableWrapper
    {
        public Payable__c pay                                                            {get;set;}
        public Integer payIndex                                                          {get;set;}
        public Boolean payEdit                                                           {get;set;}
        public PayableWrapper(Payable__c payInstance, Integer pPayIndex, Boolean pPayEdit) 
        {
            pay = payInstance;
            payIndex = pPayIndex;
            payEdit = pPayEdit;
        }
    }
}