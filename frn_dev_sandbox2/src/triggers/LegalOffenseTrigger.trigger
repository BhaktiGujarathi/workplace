trigger LegalOffenseTrigger on Legal_Offense__c (before insert, before update, after insert,after update)
{
    TriggerFactory.createAndExecuteHandler(LegalOffenseHandler.class); 

}