Public Class SCFinish
{

public void finishSCCalculation(Database.BatchableContext BC,Map<ID,Sales_Rep_Report_Card__c> mapOfSalesRep)
{

 String RecErrorDetails='Record error details.';
 Integer count = 0;
 Map<ID, User> mapIDUser = new Map<ID, User>([SELECT Id, name FROM User where id IN : mapOfSalesRep.keyset()]);
        
  if(mapOfSalesRep != null && mapOfSalesRep.size() > 0)
  {
          
        if(mapIDUser != null && mapIDUser.size() > 0)
        {
                
                for(Sales_Rep_Report_Card__c scInstance:mapOfSalesRep.values())
                {
                    
                    scInstance.name = mapIDUser.get(scInstance.Sales_Rep_ID__c).name;
                    scInstance.ownerId = scInstance.Sales_Rep_ID__c;
                }
                
                
                //post commit activity
                Database.UpsertResult[] srList = database.upsert(mapOfSalesRep.values(),Sales_Rep_Report_Card__c.Fields.Sales_Rep_ID__c, false); 
                 
                // Iterate through each returned result
                for (Database.UpsertResult sr : srList) 
                {
                            // Operation failed, so get all errors                
                            if (!sr.isSuccess())
                            {
                              for(Database.Error err : sr.getErrors()) 
                                {
                                    RecErrorDetails = RecErrorDetails +'<br>SalesRepID:'+mapOfSalesRep.values()[count].Sales_Rep__c+'   Error Status:'+err.getStatusCode()+'  Error Message:'+err.getMessage();
                                   
                                }
                            
                            }
                            
                           count ++;
                 }
                     
                     
                     
                  AsyncApexJob a = [SELECT Id, 
                                           Status, 
                                           NumberOfErrors, 
                                           JobItemsProcessed,
                                           TotalJobItems,
                                           CreatedBy.Email
                                           FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                                           
                                           
                       // Send an email to the Apex job's submitter notifying of job completion.
                       String[] toAddresses = new String[] {system.label.SCBatchNotifierEmail};
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       mail.setToAddresses(toAddresses);
                       mail.setSubject('Apex Sharing Recalculation ' + a.Status +' on '+system.now().format('MM/dd/yyyy hh:mm:ss a', 'US/Eastern'));
                       mail.setHtmlBody
                       ('The batch Apex job processed ' + a.TotalJobItems +
                       ' batches with '+ a.NumberOfErrors + ' failures.<br>'+RecErrorDetails);
                       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                  
                
        }
          
  
  
  }   
        

}





}