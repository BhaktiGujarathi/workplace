trigger TestTriggerPosition on Position__c (before update,after update,before insert,after insert,before delete,after delete) {
List<Position__c> lp = new List<Position__c>();
List<String> lpid = new List<String>();

if(trigger.isbefore)
{


   if(trigger.isinsert /*&& TriggerStaicVariableHelper.runOnce()*/)
    {
        
        
       /* system.debug('@@@@ trigger.new'+trigger.new);
        system.debug('@@@@ trigger.old'+trigger.old);
        system.debug('@@@@ trigger.newMap'+trigger.newMap);
        system.debug('@@@@ trigger.oldMap'+trigger.oldMap);*/
        
        for(Position__c  p:trigger.new )
        {
           p.infydisdespune__Apex__c = true;
           system.debug('$$$$$$ in before insert context'+p.id);
           
           lp.add(p);
        
        
        }
        
       // Position__c pcopy = new Position__c(name = 'copy before',Testrequired__c='copy',TestRequired2__c='copy');
       // insert pcopy;
     
    }
   
    
    if(trigger.isupdate /*&& TriggerStaicVariableHelper.runOnce()*/)
    {
      
       /* system.debug('@@@@ trigger.new'+trigger.new);
        system.debug('@@@@ trigger.old'+trigger.old);
        system.debug('@@@@ trigger.newMap'+trigger.newMap);
        system.debug('@@@@ trigger.oldMap'+trigger.oldMap); */
      
    
      // trigger.old present in befor update but read only
         
      /*for(Position__c  p:trigger.new)
       {
         p.name='pilot update';
       }
       */
         /*   for(Position__c  p:trigger.new)
            {
              
              
               system.debug('$$$$$$ in before update context'+p.id);
               //Id will be avaible in before update context
               lp.add(p);
               lpid.add(p.id);
            
            
            }*/
             //doing raw update for getting error
             /* update lp;*/
             // will get "DML statment cannot operate on trigger.new or trigger.old" error
              
              
              /*
               update [select id from position__c where id in : lpid];
               // it will fetch you the record but it will go in recursion update
               //error:  SELF_REFERENCE_FROM_TRIGGER, Object (id = a009000001b2vdt) is currently in trigger infydisdespune.TestTriggerPosition, therefore it cannot recursively update itself:
              
              */
         
            // update [select id from position__c where id ='a0090000017pA8I'];
         
    }
    
    
    if(trigger.isdelete)
    {
    
        system.debug('@@@@ trigger.new'+trigger.new);
        system.debug('@@@@ trigger.old'+trigger.old);
        system.debug('@@@@ trigger.newMap'+trigger.newMap);
        system.debug('@@@@ trigger.oldMap'+trigger.oldMap);
    
    }
    
    
    
    
}

  
  
  
  
  
  
  
if(trigger.isafter)
{


   if(trigger.isupdate && TriggerStaicVariableHelper.runOnce())
    {
        
       /*system.debug('@@@@ trigger.new'+trigger.new);
       system.debug('@@@@ trigger.old'+trigger.old);
       system.debug('@@@@ trigger.newMap'+trigger.newMap);
       system.debug('@@@@ trigger.oldMap'+trigger.oldMap);
      */
    
      // trigger.old present in befor update but read only
         
   /*  for(Position__c  p:trigger.new)
       {
         p.name='pilot update';
         lpid.add(p.id);
       }*/
        
        
        /*
        for(Position__c  p:trigger.new)
        {
        
           system.debug('$$$$$$ in after update context'+p.id);
           //Id will be avaible in after update context
           lpid.add(p.id);
          
          // lp.add(new Position__c(id=p.id,Testrequired__c=p.Testrequired__c,TestRequired2__c=p.TestRequired2__c));
        
        }*/
        
      // doing raw update for getting error
      //  update lp;
      // will get "DML statment cannot operate on trigger.new or trigger.old" error
       
      // update [select id from position__c where id in : lpid]; 
       
    }
    
    
    
    if(trigger.isinsert  /*&& TriggerStaicVariableHelper.runOnce()*/)
    {
    
       /* system.debug('@@@@ trigger.new'+trigger.new);
        system.debug('@@@@ trigger.old'+trigger.old);
        system.debug('@@@@ trigger.newMap'+trigger.newMap);
        system.debug('@@@@ trigger.oldMap'+trigger.oldMap);*/
        
        for(Position__c  p:trigger.new)
        {
        
           system.debug('$$$$$$ in after insert context'+p.id);
           //Id will be avaible in after insert context
           lp.add(p);
        
        
        }
        
       // Position__c pcopy = new Position__c(name = 'copy after',Testrequired__c='copy',TestRequired2__c='copy');
       // insert pcopy;
        /* this insert will recussively call the trigger , so we have used static method runOnce()*/
    
    }
    
    
    
    


}





}