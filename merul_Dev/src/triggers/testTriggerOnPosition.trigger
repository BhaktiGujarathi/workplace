trigger testTriggerOnPosition on infydisdespune__Position__c (before insert) {
    
    if(system.trigger.isBefore)
    {
      if(system.trigger.isInsert)
      {
         
         GerneralHandlerForTrigger.beforeInsertTrigger();
         
      
      }
    
    }

}