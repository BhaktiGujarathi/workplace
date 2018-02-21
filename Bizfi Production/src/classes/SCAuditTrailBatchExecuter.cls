public class SCAuditTrailBatchExecuter
{
   
    public void auditTrailExecute(List<SObject> scope,Map<ID,Sales_Rep_Report_Card__c> mapOfSalesRep,Map<String,SCTimeframe_Metric__c> mapOfCustSetTimeFrame)
    {
        
        Sales_Rep_Report_Card__c resultSC;
        for(Audit_Trail__c audtrail:(List<Audit_Trail__c>)scope)
        {
                 // checking calculation based on current owner 
                 if(audtrail.current_owner__c != null && audtrail.current_owner__r.Generate_Sales_Rep_Scorecard__c && audtrail.current_owner__r.isActive)
                 {
                 
                       if(mapOfSalesRep.containsKey(audtrail.current_owner__c))
                       {
                             Sales_Rep_Report_Card__c existSC = mapOfSalesRep.get(audtrail.current_owner__c);
                             if(existSC != null)
                             {
                               resultSC = new SCCalculateTimeLineHelper().calculateBasedOnTimeLine(existSC,audtrail,mapOfCustSetTimeFrame);
                             }
                       }
                       else
                       {
                               Sales_Rep_Report_Card__c tempSC = new SCResetToZero().resetToZero(mapOfCustSetTimeFrame);
                               tempSC.Sales_Rep__c = audtrail.current_owner__c;
                               tempSC.Sales_Rep_ID__c = audtrail.current_owner__r.id;
                               resultSC = new SCCalculateTimeLineHelper().calculateBasedOnTimeLine(tempSC,audtrail,mapOfCustSetTimeFrame);
                       }
                   
                       if(resultSC != null)
                       {
                              mapOfSalesRep.put(audtrail.current_owner__c,resultSC);
                            
                       }
                    
                 
                 }   
          
                 
                 
                 // checking calculation based on New owner 
                 if(audtrail.New_owner__c != null && audtrail.New_owner__r.Generate_Sales_Rep_Scorecard__c && audtrail.New_owner__r.isActive)
                 {
                 
                       if(mapOfSalesRep.containsKey(audtrail.New_owner__c))
                       {
                             Sales_Rep_Report_Card__c existSC = mapOfSalesRep.get(audtrail.New_owner__c);
                             if(existSC != null)
                             {
                               resultSC = new SCCalculateTimeLineHelper().calculateBasedOnTimeLine(existSC,audtrail,mapOfCustSetTimeFrame);
                             }
                       }
                       else
                       {
                               Sales_Rep_Report_Card__c tempSC = new SCResetToZero().resetToZero(mapOfCustSetTimeFrame);
                               tempSC.Sales_Rep__c = audtrail.New_owner__c;
                               tempSC.Sales_Rep_ID__c = audtrail.New_owner__r.id;
                               resultSC = new SCCalculateTimeLineHelper().calculateBasedOnTimeLine(tempSC,audtrail,mapOfCustSetTimeFrame);
                       }
                   
                       if(resultSC != null)
                       {
                              mapOfSalesRep.put(audtrail.New_owner__c,resultSC);
                            
                       }
                    
                 
                 }  
          
          
          
          
         
        }
        
         
    
    }
    
    
}