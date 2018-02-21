trigger CommissionRuleEntryTrigger on MCACE__Commission_Rule_Entry__c (before insert, before update) {
    
    //CommissionRuleEntryHandler hanndlerInstance = new CommissionRuleEntryHandler();
    
    if(trigger.isBefore) 
    {
        if(trigger.isInsert)
        {
            new CommissionRuleEntryHandler().onBeforeInsert();
        }
        
        if(trigger.isUpdate)
        {
            
            new CommissionRuleEntryHandler().onBeforeUpdate();
        }
    }
    
    
}