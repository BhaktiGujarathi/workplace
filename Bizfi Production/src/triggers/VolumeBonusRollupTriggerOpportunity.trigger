trigger VolumeBonusRollupTriggerOpportunity on Opportunity (after insert, after update, after delete, after undelete) {

    Opportunity[] opportunities;

    if (Trigger.new != null) {

        opportunities = Trigger.new;
    }
    else if (Trigger.old != null) {
        
        opportunities = Trigger.old;
    }


    if (opportunities != null) {
        
        Set<Id> accountIds = new Set<Id>();

        for (Opportunity opp : opportunities) {

            if (opp.McaApp__Bank_Name__c != null) {

                accountIds.add(opp.McaApp__Bank_Name__c);
            }
        }       


        if (!accountIds.isEmpty()) {

            Database.executeBatch(new VolumeBonusRollUpHandlerBatch(accountIds), 1);
        }
    }
}