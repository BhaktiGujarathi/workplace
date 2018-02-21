public with sharing class GRIDPayablesController {
    
    public Id OpportunityId;
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
    
    public static Map<String, Schema.SObjectType> globalMap;

    public List<Schema.FieldSetMember> payFieldsetList                                  {get; set;}
    public Set<string> payFieldSumSet                                                   {get; set;}
    public Map<String, Decimal> payFieldToSumMap                                        {get; set;}
    public Integer payRecordCount                                                       {get; set;}
    public Integer payBlockSize                                                         {get; set;}
    public Integer payOffsetsize                                                        {get; set;}
    public Integer payIndexToRemove                                                     {get; set;}
    public string paySortDirection                                                      {get; set;}
    public String paySortExpression                                                     {get; set;}
    
    public GRIDPayablesController() 
    {
        if(GRIDOnloadStaticVariable.flipPayable())
        {
        
            opportunityId = Apexpages.currentPage().getParameters().get('id');
        
            payBlockSize = (Integer)GRIDTabSetting__c.getValues('Payable').PageSize__c;
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
        
            globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            Schema.DescribeSObjectResult payDescbResult = globalMap.get('Payable__c').getDescribe();
            payFieldsetList = payDescbResult.FieldSets.getMap().get(GRIDTabSetting__c.getValues('Payable').Fieldset_Name__c).getFields();
        
            payAggregateQueryStr = buildPayAggregateQuery(payFieldsetList);
            payFieldsApiSet = buildSetFromFieldListPayable(payFieldsetList);
            payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet, paySortExpression, paySortDirection);
            payFirstRun = true;
        }
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListPayable(List<Schema.FieldSetMember> pPayFieldsetList)
    {
        String payReferenceField;
        for(Schema.FieldSetMember fieldInstance :pPayFieldsetList)
        {
            payReferenceField = '';
            payFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
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
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double'))
            {
                payAggregateQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                payFieldSumSet.add(fieldInstance.getFieldPath());
                
            }
            //payFieldsApiSet.add(fieldInstance.getfieldPath());
            payFieldToSumMap.put(fieldInstance.getFieldPath(), 100);
        }
        
        payAggregateQueryStr += 'COUNT(Id) payCount FROM Payable__c Where Opportunity__c = \''+opportunityId+'\'';
        
        return payAggregateQueryStr;
    }

    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getPayFieldSum(String pPayAggregateQueryStr)
    {
        List<SObject> paySumQueryResult = new List<SObject>();
        paySumQueryResult = Database.query(pPayAggregateQueryStr);
        
        for(String fieldName :payFieldSumSet) 
        {
            if(paySumQueryResult[0].get(fieldName) != null)
            {
                
                payFieldToSumMap.put(fieldName, (Decimal)paySumQueryResult[0].get(fieldName)); 
            }
        }
        payRecordCount = (Integer)paySumQueryResult[0].get('payCount');
       
        return payFieldToSumMap;
    }
    
    // method to get payables from DB
    public List<Payable__c> getPayableFromDB(Id pOpportunityId, Integer pPayBlockSize, Integer pPayOffsetSize, Set<String> pPayFieldsApiSet,
                                             String pPaySortExpression, String pPaySortDirection) 
    {
        //payLst.clear();
        String payQueryStr = '';
        payFieldsString = DEWUtility.getStringfromSet(pPayFieldsApiSet, null);
        payQueryStr = 'Select ' +payFieldsString+ 
                        ' From Payable__c Where Opportunity__c =:pOpportunityId ORDER BY '+pPaySortExpression+' '+pPaySortDirection+' NULLS LAST LIMIT '
                        +pPayBlockSize+' Offset ' +pPayOffsetSize;

        return database.query(payQueryStr);
    }
    
    // method to get the wrapper list
    public List<PayableWrapper> getPayWrapperLst() 
    {
        if(payFirstRun)
        {
            payWrapperLst = new List<PayableWrapper>();
            for (Integer i = 0; i < payLst.size(); i++) 
            {
                payWrapperLst.add(new PayableWrapper(payLst[i], i, false));
            }
            // moved inside if condition for getting aggregate results only if firstrun is true
            payFieldToSumMap = getPayFieldSum(payAggregateQueryStr);
            payFirstRun = false;
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
        savePayables();
        payIsNewBtnPress = false;
        
        if(!paySingleErrorOnSave)
        {
            // to add new record only on first page
            if(payOffsetsize <> 0) 
            {
                payOffsetsize = 0;
                beginningPayable();
            }
            
            Payable__c payNew = new Payable__c(Due_Date__c = system.today(),
                                               Opportunity__c = opportunityId);
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
        payFieldToSumMap = getPayFieldSum(payAggregateQueryStr);
    }
    
    // method to cave payable
    public void savePayables()
    {
        String payMsgStr = '';
        paySingleErrorOnSave = false;
        Boolean payIsUpdated = false;
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
                    if(!payFieldInstance.contains('__r.Name'))
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
            
            payWraperInstance.payEdit = false;
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
                              //+1 is added for Display on VF page only  
                              payMsgStr = payMsgStr + 'Error Record '+(payErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!payMsgStr.contains('insufficient access rights on object id'))
                        {
                            payWrapperLst[payErrorToWraperIndexMap.get(i)].payEdit = true; 
                            //note on insuffivient privilage
                            paySingleErrorOnSave = true;
                        }
                    }
                   /* else
                    {
                         payWrapperLst[payErrorToWraperIndexMap.get(i)].payEdit = false;
                    }*/
                }
                if(paySingleErrorOnSave == false && !payIsNewBtnPress)
                {
                  payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet, paySortExpression, paySortDirection);
                  payFieldToSumMap = getPayFieldSum(payAggregateQueryStr);
                  payFirstRun = true;
                }
                if(String.isNotBlank(payMsgStr)) 
                {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,payMsgStr));
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
        savePayables();
        if(!paySingleErrorOnSave && math.mod(payRecordCount , payBlockSize) == 0){
            payOffsetsize = payBlockSize * ((payRecordCount/payBlockSize)-1);
        } else if (!paySingleErrorOnSave && math.mod(payRecordCount , payBlockSize) != 0){
            payOffsetsize = payBlockSize * ((payRecordCount/payBlockSize));
        }
        //payOffsetsize = payRecordCount-MAth.mod(payRecordCount,payBlockSize);
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
        for(Integer i=0; i< payWrapperLst.size(); i++) 
        {
            payWrapperLst[i].payEdit = true;
        }
    }
    
    // method to refresh
    public void refreshPayables() 
    {
        payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet, paySortExpression, paySortDirection);
        payFirstRun = true;
    }
    
    // wrapper for payables
    public class PayableWrapper
    {
        public Payable__c pay                                                            {get;set;}
        public Integer payIndex                                                          {get;set;}
        public Boolean payEdit                                                           {get;set;}
        public PayableWrapper(Payable__c payInstance, Integer pPayIndex, Boolean pPayEdit) {
            pay = payInstance;
            payIndex = pPayIndex;
            payEdit = pPayEdit;
        }
    }
}