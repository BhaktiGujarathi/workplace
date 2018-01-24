public class CommissionRuleEntryHandler {
    
    public void onBeforeInsert() {
        new CommissionRuleEntryService().validateRuleEntry((List<MCACE__Commission_Rule_Entry__c>) trigger.new);
    }

    public void onBeforeUpdate() {
        new CommissionRuleEntryService().validateRuleEntry((List<MCACE__Commission_Rule_Entry__c>) trigger.new);
    }
}