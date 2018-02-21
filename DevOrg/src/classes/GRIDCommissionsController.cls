public with sharing class GRIDCommissionsController {

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
    
    public static Map<String, Schema.SObjectType> globalMap;

    public List<Schema.FieldSetMember> payFieldsetList                                  {get; set;}
    public Set<string> payFieldSumSet                                                   {get; set;}
    public Map<String, Decimal> payFieldToSumMap                                        {get; set;}
    public Integer payRecordCount                                                       {get; set;}
    public Integer payBlockSize                                                         {get; set;}
    public Integer payOffsetsize                                                        {get; set;}
    public Integer payIndexToRemove                                                     {get; set;}
    
    public List<Receivable__c> recLst;
    public Map<Id, Receivable__c> recFromDbMap;
    public List<ReceivableWrapper> recWrapperLst;
    public String recAggregateQueryStr = '';
    public String recFieldsString = '';
    public Set<String> recFieldsApiSet;
    public Boolean recFirstRun;
    public Boolean recIsNewBtnPress;
    public Boolean recSingleErrorOnSave;
    
    public List<Schema.FieldSetMember> recFieldsetList                                  {get; set;}
    public Set<string> recFieldSumSet                                                   {get; set;}
    public Map<String, Decimal> recFieldToSumMap                                        {get; set;}
    public Integer recRecordCount                                                       {get; set;}
    public Integer recBlockSize                                                         {get; set;}
    public Integer recOffsetsize                                                        {get; set;}
    public Integer recIndexToRemove                                                     {get; set;}
    
    public Integer rectempval {get; set;} 
    public Integer paytempval {get; set;} 
    // constructor
    public GRIDCommissionsController() 
    {
        if(GRIDOnloadStaticVariable.flipComm())
        {
            opportunityId = Apexpages.currentPage().getParameters().get('id');
        
            payBlockSize = (Integer)GRIDTabSetting__c.getValues('Payables').PageSize__c;
            payOffsetsize = 0;
        
            payLst = new List<Payable__c>();
            payFromDbMap = new Map<Id, Payable__c>();
            payWrapperLst = new List<PayableWrapper>();
            payFieldToSumMap = new Map<String, Decimal>();
            payFieldSumSet = new Set<String>();
            payFieldsApiSet = new Set<String>();
            payFieldsetList = new List<Schema.FieldSetMember>();
            payIsNewBtnPress = false;
            
            recBlockSize = (Integer)GRIDTabSetting__c.getValues('Receivables').PageSize__c;
            recOffsetsize = 0;
        
            recLst = new List<Receivable__c>();
            recFromDbMap = new Map<Id, Receivable__c>();
            recWrapperLst = new List<ReceivableWrapper>();
            recFieldToSumMap = new Map<String, Decimal>();
            recFieldSumSet = new Set<String>();
            recFieldsApiSet = new Set<String>();
            recFieldsetList = new List<Schema.FieldSetMember>();
            recIsNewBtnPress = false;
            
            //   globalMap = Schema.getGlobalDescribe();
               
                globalMap = GRIDOnloadStaticVariable.getGlobalMap();
            Schema.DescribeSObjectResult payDescbResult = globalMap.get('Payable__c').getDescribe();
            payFieldsetList = payDescbResult.FieldSets.getMap().get('GridPayableFieldSet').getFields();
            
            Schema.DescribeSObjectResult recDescbResult = globalMap.get('Receivable__c').getDescribe();
            recFieldsetList = recDescbResult.FieldSets.getMap().get('GridReceivableFieldSet').getFields();
        
            payAggregateQueryStr = buildPayAggregateQuery(payFieldsetList);
            payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet);
            payFirstRun = true;
            
            recAggregateQueryStr = buildRecAggregateQuery(recFieldsetList);
            recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet);
            recFirstRun = true;
        }
    }
    /*................Payables.........................*/
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
            payFieldsApiSet.add(fieldInstance.getfieldPath());
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
    public List<Payable__c> getPayableFromDB(Id pOpportunityId, Integer pPayBlockSize, Integer pPayOffsetSize, Set<String> pPayFieldsApiSet) 
    {
        payLst.clear();
        String payQueryStr = '';
        payFieldsString = DEWUtility.getStringfromSet(pPayFieldsApiSet, null);
        payQueryStr = 'Select ' +payFieldsString+ 
                        ' From Payable__c Where Opportunity__c =:pOpportunityId ORDER BY CreatedDate DESC LIMIT '
                        +pPayBlockSize+' Offset ' +pPayOffsetSize;
        payLst = database.query(payQueryStr);

        return payLst;
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
            payFirstRun = false;
        }
        
        payFieldToSumMap = getPayFieldSum(payAggregateQueryStr);

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
    }
    
    // method to cave payable
    public void savePayables()
    {
        String payMsgStr = '';
        paySingleErrorOnSave = false;
        Boolean payIsUpdated = false;
        List<Payable__c> payListToUpdate = new List<Payable__c>();
        Map<Integer, Integer> payErrorToWraperIndexMap = new map<Integer, Integer>();
        
        List<Payable__c> payTempLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet);
        payFromDBMap = getpayMapFromList(payTempLst);
        
        for(PayableWrapper payWraperInstance :payWrapperLst) 
        {
            Payable__c payDBObj = payFromDBMap.get(payWraperInstance.pay.Id);
            if(payDBObj != null)
            {
                payIsUpdated = false;
                for(String payFieldInstance :payFieldsApiSet)
                {
                        payIsUpdated  = payIsUpdated ||(payWraperInstance.pay.get(payFieldInstance) != payDBObj.get(payFieldInstance));
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
                              payMsgStr = payMsgStr + 'Error:'+(payErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!payMsgStr.contains('insufficient access rights on object id'))
                        {
                            payWrapperLst[payErrorToWraperIndexMap.get(i)].payEdit = true; 
                            //note on insuffivient privilage
                            paySingleErrorOnSave = true;
                        }
                    }
                    else
                    {
                         payWrapperLst[i].payEdit = false;
                    }
                }
                if(paySingleErrorOnSave == false && !payIsNewBtnPress)
                {
                  payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet);
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
        //paySingleErrorOnSave = false;
        //recSingleErrorOnSave = false;
    }
    
    //method for the first page of list to be displayed
    public void beginningPayable() 
    {
        payOffsetsize = 0;
        payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet);
        payFirstRun = true;
    }
    
    //method for previous page of list to be displayed
    public void previousPayable() 
    {
        if (payBlockSize <= payOffsetsize)
        {
            payOffsetsize = payOffsetsize - payBlockSize;
            payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet);
            payFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void nextPayable() 
    {    savePayables();
       
        if (payOffsetsize <= payRecordCount) 
        {
            payOffsetsize = payOffsetsize + payBlockSize;
            payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet);
            payFirstRun = true;
        }
    }
    
    //method for last page of list to be displayed
    public void endPayable() 
    {
        if(math.mod(payRecordCount , payBlockSize) == 0){
            payOffsetsize = payBlockSize * ((payRecordCount/payBlockSize)-1);
        } else if (math.mod(payRecordCount , payBlockSize) != 0){
            payOffsetsize = payBlockSize * ((payRecordCount/payBlockSize));
        }
        //payOffsetsize = payRecordCount-MAth.mod(payRecordCount,payBlockSize);
            payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet);
            payFirstRun = true;
    }
    /*........................End of Payables........................*/
    
    /*.......common methods...............*/
    // method to edit all commissions
    public void editAllCommissions()
    {
        payFirstRun = false;
        for(Integer i=0; i< payWrapperLst.size(); i++) 
        {
            payWrapperLst[i].payEdit = true;
        }
        
        recFirstRun = false;
        for(Integer i=0; i< recWrapperLst.size(); i++) 
        {
            recWrapperLst[i].recEdit = true;
        }
    }
    
    // method to refresh
    public void refreshCommissions() 
    {
        payLst = getPayableFromDB(opportunityId, payBlockSize, payOffsetsize, payFieldsApiSet);
        payFirstRun = true;
        
        recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet);
        recFirstRun = true;
    }
    
    /*..............End of common methods*/
    /*..............Receivables......................*/
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
            recFieldsApiSet.add(fieldInstance.getfieldPath());
            recFieldToSumMap.put(fieldInstance.getFieldPath(), 100);
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
    public List<Receivable__c> getReceivableFromDB(Id pOpportunityId, Integer pRecBlockSize, Integer pRecOffsetSize, Set<String> pRecFieldsApiSet) 
    {
        recLst.clear();
        String recQueryStr = '';
        recFieldsString = DEWUtility.getStringfromSet(pRecFieldsApiSet, null);
        recQueryStr = 'Select ' +recFieldsString+ 
                        ' From Receivable__c Where Opportunity__c =:pOpportunityId ORDER BY CreatedDate DESC LIMIT '
                        +pRecBlockSize+' Offset ' +pRecOffsetSize;
        recLst = database.query(recQueryStr);

        return recLst;
    }
    
    // method to get the receivable wrapper list
    public List<ReceivableWrapper> getRecWrapperLst() 
    {
        if(recFirstRun)
        {
            recWrapperLst = new List<ReceivableWrapper>();
            for (Integer i = 0; i < recLst.size(); i++) 
            {
                recWrapperLst.add(new ReceivableWrapper(recLst[i], i, false));
            }
            recFirstRun = false;
        }
        
        recFieldToSumMap = getRecFieldSum(recAggregateQueryStr);

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
        return recFromDbMap;
    }
    
    // method to create new receivables
    public void newRec()
    {
        recIsNewBtnPress = true;
        saveReceivables();
        recIsNewBtnPress = false;
        
        if(!recSingleErrorOnSave)
        {
            Receivable__c recNew = new Receivable__c(Due_Date__c = system.today(),
                                                    Opportunity__c = opportunityId);
           // recWrapperLst.add(0, new ReceivableWrapper(recNew, null, true));
           // recLst.add(0, recNew);
            
             /*need to add at 0th index if list size > 0 else simple add will work*/
               if(recWrapperLst.size() > 0 && recLst.size() > 0)
               {
                 recWrapperLst.add(0,new ReceivableWrapper(recNew, null, true));
                 recLst.add(0,recNew );
               }
               else
               {
                 recWrapperLst.add(new ReceivableWrapper(recNew, null, true));
                 recLst.add(recNew );
               
               } 
            
            
            
            
            
            // reindexing
            for(Integer i=0; i<recWrapperLst.size(); i++)
            {
                recWrapperLst[i].recIndex = i;
            }
        }
    }
    
    // method to delete receviables
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
         
        // refreshCommissions();
    }
    
    // method to save receivables
    public void saveReceivables() 
    {
        String recMsgStr = '';
        recSingleErrorOnSave = false;
        Boolean recIsUpdated = false;
        List<Receivable__c> recListToUpdate = new List<Receivable__c>();
        Map<Integer, Integer> recErrorToWraperIndexMap = new Map<Integer, Integer>();
        
        List<Receivable__c> recTempLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet);
        recFromDBMap = getRecMapFromList(recTempLst);
        
        for(ReceivableWrapper recWraperInstance :recWrapperLst) 
        {
            Receivable__c recDBObj = recFromDBMap.get(recWraperInstance.rec.Id);
            if(recDBObj != null)
            {
                recIsUpdated = false;
                for(String recFieldInstance :recFieldsApiSet)
                {
                        recIsUpdated  = recIsUpdated ||(recWraperInstance.rec.get(recFieldInstance) != recDBObj.get(recFieldInstance));
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
                              recMsgStr = recMsgStr + 'Error:'+(recErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!recMsgStr.contains('insufficient access rights on object id'))
                        {
                            recWrapperLst[recErrorToWraperIndexMap.get(i)].recEdit = true; 
                            //note on insuffivient privilage
                            recSingleErrorOnSave = true;
                        }
                    }
                    else
                    {
                         recWrapperLst[i].recEdit = false;
                    }
                }
                if(recSingleErrorOnSave == false && !recIsNewBtnPress)
                {
                  recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet);
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
        recOffsetsize = 0;
        recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet);
        recFirstRun = true;
    }
    
    //method for previous page of list to be displayed
    public void previousReceivable() 
    {
        if (recBlockSize <= recOffsetsize)
        {
            recOffsetsize = recOffsetsize - recBlockSize;
            recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet);
            recFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void nextReceivable() 
    {    saveReceivables();
       
        if (recOffsetsize <= recRecordCount) 
        {
            recOffsetsize = recOffsetsize + recBlockSize;
            recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet);
            recFirstRun = true;
        }
    }
    
    //method for last page of list to be displayed
    public void endReceivable() 
    {
        if(math.mod(recRecordCount , recBlockSize) == 0){
            recOffsetsize = recBlockSize * ((recRecordCount/recBlockSize)-1);
        } else if (math.mod(recRecordCount , recBlockSize) != 0){
            recOffsetsize = recBlockSize * ((recRecordCount/recBlockSize));
        }
        //recOffsetsize = recRecordCount-MAth.mod(recRecordCount,recBlockSize);
        recLst = getReceivableFromDB(opportunityId, recBlockSize, recOffsetsize, recFieldsApiSet);
        recFirstRun = true;
    }
    /*.................End Of Receivables..................*/
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
    
    // wrapper for payables
    public class ReceivableWrapper
    {
        public Receivable__c rec                                                         {get;set;}
        public Integer recIndex                                                          {get;set;}
        public Boolean recEdit                                                           {get;set;}
        public ReceivableWrapper(Receivable__c recInstance, Integer pRecIndex, Boolean pRecEdit) {
            rec = recInstance;
            recIndex = pRecIndex;
            recEdit = pRecEdit;
        }
    }
}