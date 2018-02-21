trigger LeadTrigger on Lead(before insert, before update, after insert, after update) { 
    
    if(trigger.isBefore)
    {
          if(trigger.isInsert)
          {
               LeadISOTriggerHandler.ISOFieldPopulateAndValidateOnBefore();
          }
          
          if(trigger.isUpdate)
          {
               LeadISOTriggerHandler.ISOFieldPopulateAndValidateOnBefore();
          }
    }    
    
    if(trigger.isAfter)
    {      
          if(trigger.isInsert)
          {
             LeadISOTriggerHandler.ISOFieldPopulateAndValidateOnAfter();
          }
          
          if(trigger.isUpdate)
          {
             LeadISOTriggerHandler.ISOFieldPopulateAndValidateOnAfter();
          }
    }
}