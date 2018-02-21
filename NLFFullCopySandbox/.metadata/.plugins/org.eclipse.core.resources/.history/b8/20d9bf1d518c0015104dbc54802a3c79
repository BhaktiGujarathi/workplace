public Class SCCalculateScoreCardBasedOnTypeAndStage
{


public Sales_Rep_Report_Card__c calculateBasedOnTypeAndStage(Sales_Rep_Report_Card__c scoreCard,
                                                             Audit_Trail__c audtrail,
                                                             String timeLine,
                                                             Map<String,SCTimeframe_Metric__c> mapOfCustSetTimeFrame)
{
          
       
        // On Opportunity ststus change.
        if(audtrail.object__c == 'Opportunity' && mapOfCustSetTimeFrame != Null && timeLine != Null)
        {
           
                   if( audtrail.Type__c != null && audtrail.Type__c == 'Status / Stage' )
                   {
                     if(audtrail.New_Status_Stage_value__c != Null)
                     {
                       
                         return  populateScorCardFieldsBasedOnTypeAndStage(scoreCard,
                                                                           audtrail,
                                                                           timeLine,
                                                                           mapOfCustSetTimeFrame,
                                                                           audtrail.New_Status_Stage_value__c);
                       
                     } 
                   }
                   
                   
                   
                   
                   if(audtrail.Type__c != null && audtrail.Type__c == 'Organic Sub')
                   {  
                          
                       return  populateScorCardFieldsBasedOnTypeAndStage(scoreCard,
                                                                          audtrail,
                                                                          timeLine,
                                                                          mapOfCustSetTimeFrame,
                                                                          audtrail.Type__c);
                      
                   }
                   
                   
                   
                 
           
        
        }
        
        
        //logic for lead count on lead creation and owner change
        if( audtrail.object__c == 'Lead' && mapOfCustSetTimeFrame != Null && timeLine != Null)
        {
            
            if(audtrail.Type__c != null && (audtrail.Type__c == 'Create' || audtrail.Type__c == 'Owner')) 
            {
                
                    return  populateScorCardFieldsBasedOnTypeAndStage(scoreCard,
                                                                      audtrail,
                                                                      timeLine,
                                                                      mapOfCustSetTimeFrame,
                                                                      'Lead');
                
            
            }
            
            
            
            
        
        }
        
        
        //For outbound calls
        if(audtrail.Type__c != NULL && audtrail.Type__c == 'Outbound Call' && audtrail.object__c == 'Task' && mapOfCustSetTimeFrame != Null && timeLine != Null ) 
        {
                       return  populateScorCardFieldsBasedOnTypeAndStage(scoreCard,
                                                                         audtrail,
                                                                         timeLine,
                                                                         mapOfCustSetTimeFrame,
                                                                         audtrail.Type__c);
                       
        }
        
         
        return scoreCard;
    }
    
   
   
   
   
   
    
    public Sales_Rep_Report_Card__c populateScorCardFieldsBasedOnTypeAndStage(Sales_Rep_Report_Card__c scoreCard,
                                                                 Audit_Trail__c audtrail,
                                                                 String timeLine,
                                                                 Map<String,SCTimeframe_Metric__c> mapOfCustSetTimeFrame,
                                                                 String valueOfStageOrType)
    {
                    SCTimeframe_Metric__c scInstance = SCTimeframe_Metric__c.getInstance(valueOfStageOrType);
                    if(scInstance != null)
                    {
                       
                           String scField = (String)scInstance.get(timeLine);
                           if(!String.isBlank(scField))
                           {
                           
                             
                              
                             if(((Decimal)scoreCard.get(scField)) == 0)
                              {
                                  scoreCard.put(scField,1);
                              
                              }
                              else
                              {
                                  scoreCard.put(scField,(Decimal)scoreCard.get(scField)+1);
                              }
                             
                              
                           }
                           
                     }
        
        return scoreCard;
    }
        


}