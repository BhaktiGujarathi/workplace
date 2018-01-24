trigger OpportunityTrigger on Opportunity(before insert, before update, after insert, after update) 
{
    
    if(trigger.isBefore)
    {     
          if(trigger.isInsert)
          {
           OpportunityISOTriggerHandler.ISOFieldPopulateAndValidateOnBefore();
          }
          
          if(trigger.isUpdate)
          {
             if(OpportunityISOCheckRecursive.runOnceForBefore()) 
              OpportunityISOTriggerHandler.ISOFieldPopulateAndValidateOnBefore();
          }
    }
    
    if(trigger.isAfter)
    {
          if(trigger.isInsert)
          {
           OpportunityISOTriggerHandler.ISOFieldPopulateAndValidateOnAfter();
          }
          
        if(trigger.isUpdate)
          {
             if(OpportunityISOCheckRecursive.runOnceForAfter())  
             OpportunityISOTriggerHandler.ISOFieldPopulateAndValidateOnAfter();
          }
    }
}