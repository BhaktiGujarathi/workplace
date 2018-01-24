trigger TaskTriggers on Task (after insert,after update) 
{

    if(Trigger.IsAfter)
    {
       if(Trigger.IsUpdate)
       {
           TaskHandlers.onAfterUpdate();
       } 
       
       if(Trigger.IsInsert)
       {
           TaskHandlers.onAfterInsert();
       }
    
    }

}