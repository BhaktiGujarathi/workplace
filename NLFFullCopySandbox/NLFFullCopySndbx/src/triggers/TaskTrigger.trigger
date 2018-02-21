trigger TaskTrigger on Task (after insert) 
{

      if(trigger.isAfter)
      {
      
        if(trigger.isInsert)
        {
        
           new ATAfterInsertTaskHandler().afterInsertOfCallTask();
        
        }
      
      }
   
}