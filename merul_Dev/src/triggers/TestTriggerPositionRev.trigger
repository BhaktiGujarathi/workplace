trigger TestTriggerPositionRev on Position__c (before update,after update,before insert,after insert,before delete,after delete)
{
List<Position__c> lp = new List<Position__c>();
   if(trigger.isInsert)
   {
   
      if(trigger.isBefore)
      {
          /*  system.debug('trigger.isBefore');
            system.debug('@@@@ trigger.new'+trigger.new);
            system.debug('@@@@ trigger.old'+trigger.old);
            system.debug('@@@@ trigger.newMap'+trigger.newMap);
            system.debug('@@@@ trigger.oldMap'+trigger.oldMap);
           */ 
            for(Position__c  p:trigger.new )
            {
               p.infydisdespune__Max_Pay__c = 300;
               system.debug('$$$$$$ in before insert context'+p.id);
               
               lp.add(p);
            
            
            }
            /*
            update lp; */
      
      }
      
      if(trigger.isAfter)
      {
            
      
      }
   
   }
   
   if(trigger.isUpdate)
   {
     
      
      if(trigger.isBefore)
      {
      
            
      
      }
      
      if(trigger.isAfter)
      {
      
            
      
      
        
      }
   
   
   }
   
   
   if(trigger.isDelete)
   {
   
       if(trigger.isBefore)
      {
      
           
      
      
      }
      
      if(trigger.isAfter)
      {
      
      
            system.debug('trigger.isBefore Delete');
            system.debug('@@@@ trigger.new'+trigger.new);
            system.debug('@@@@ trigger.old'+trigger.old);
            system.debug('@@@@ trigger.newMap'+trigger.newMap);
            system.debug('@@@@ trigger.oldMap'+trigger.oldMap);
            
            
           system.debug('#### trigger.old[0].id' +trigger.old[0].id); 
           lp=[select id from Position__c where id =: trigger.old[0].id];
           system.debug('#### lp' +lp.size()); 
           //lp[0].infydisdespune__Apex__c = true;
         
          //  update lp;
            
      
      }
      
   
   }


}