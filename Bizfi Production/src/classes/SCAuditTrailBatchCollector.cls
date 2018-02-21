global class SCAuditTrailBatchCollector implements Database.Batchable<sObject>,Database.Stateful

{
    global final String query;
    global Map<ID,Sales_Rep_Report_Card__c> mapOfSalesRep = new Map<ID,Sales_Rep_Report_Card__c>();
    global Map<String,SCTimeframe_Metric__c> mapOfCustSetTimeFrame = new Map<String,SCTimeframe_Metric__c>();
    
    global SCAuditTrailBatchCollector(String queryString){
        
       //as Constructor parameter from scheduler*/
       //query = SCQuerySelector.querySelectorForAuditTrail();
        query = queryString;
        mapOfCustSetTimeFrame =  SCTimeframe_Metric__c.getAll();           
    }
 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        //Plan to send custom setting from here.
        SCAuditTrailBatchExecuter SCATExecuteExecutor = new SCAuditTrailBatchExecuter();
        SCATExecuteExecutor.auditTrailExecute(scope,mapOfSalesRep,mapOfCustSetTimeFrame);
        
    }
 
    global void finish(Database.BatchableContext BC)
    {
      /* List<Sales_Rep_Report_Card__c> existSC = new List<Sales_Rep_Report_Card__c>();
         List<Sales_Rep_Report_Card__c> updatedSC = new List<Sales_Rep_Report_Card__c>();
         
         
        if(mapOfSalesRep != NULL && mapOfSalesRep.size() > 0)
        {
            existSC = [SELECT id,Sales_Rep__c 
                                 FROM Sales_Rep_Report_Card__c
                                 WHERE Sales_Rep__c IN : mapOfSalesRep.keySet()];
            
            if(existSC != NULL && existSC.size() > 0)
            {
                  for(Sales_Rep_Report_Card__c existSalRepCard:existSC)
                  {
                      Sales_Rep_Report_Card__c tempSC; 
                      if(mapOfSalesRep.containsKey(existSalRepCard.Sales_Rep__c))
                      {
                      
                          tempSC = mapOfSalesRep.get(existSalRepCard.Sales_Rep__c);
                          tempSC.ID = existSalRepCard.ID;
                          updatedSC.add(tempSC);
                      
                      }
                      else
                      {
                           updatedSC.add(mapOfSalesRep.get(existSalRepCard.Sales_Rep__c)); 
                      
                      }
                      
                      
                  }  
            
            } 
            else
            {
                           updatedSC.addAll(mapOfSalesRep.values());
            
            }
            
        }
                                                           
          system.debug('@@@@@@@@ updatedSC'+updatedSC);
          upsert updatedSC;     
         */ 
          
        
       
       new SCFinish().finishSCCalculation(BC,mapOfSalesRep);
        
        
          
          
          
          
    }

}