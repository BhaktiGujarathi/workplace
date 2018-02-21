public class CaseTriggerHandler {
    public static void handleAfterInsert(List<Case> triggerNew){
        CaseServices.UpdateGeoCodes(triggerNew, null);
    }
    
    public static void handleAfterUpdate(List<Case> triggerNew,  Map<id, Case> triggerOldMap){
        CaseServices.UpdateGeoCodes(triggerNew, triggerOldMap);
    }

}