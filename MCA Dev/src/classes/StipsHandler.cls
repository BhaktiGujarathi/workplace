/*
 *  Apex Stips Handler Class
 *
 *  Version           Author                 Date                 Description
 *  1.1               Yogesh Mahajan         24-02-2016           Added method for Before Delete on
                                                                  line no.22
 */

public class StipsHandler {

    public void onAfterInsert(list<Stips__c> stipsList){

        //For all the inserted stips pass trigger in
        //StoreChildToParentHelper objHandler = new StoreChildToParentHelper();
        //objHandler.copyField(stipsList);
         if( [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'StipRollUpTrigger'].IsActivate__c){
                list<RollupService.fieldDefinition> fieldDefinitions_OpenStips =
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','Open_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_OpenStips ,stipsList,'Stips__c','Opportunity__c','Opportunity',' AND (Status__c != \'Completed\' AND Status__c != \'Cancelled\')');

                list<RollupService.fieldDefinition> fieldDefinitions_ClosedStips =
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','Closed_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_ClosedStips ,stipsList,'Stips__c','Opportunity__c','Opportunity',' AND Status__c = \'Completed\'');
         }
    }

    public void onAfterUpdate(list<Stips__c> stipsList){
        if( [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'StipRollUpTrigger'].IsActivate__c){
                list<RollupService.fieldDefinition> fieldDefinitions_OpenStips =
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','Open_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_OpenStips ,stipsList,'Stips__c','Opportunity__c','Opportunity',' AND (Status__c != \'Completed\' AND Status__c != \'Cancelled\')');

                list<RollupService.fieldDefinition> fieldDefinitions_ClosedStips =
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','Closed_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_ClosedStips ,stipsList,'Stips__c','Opportunity__c','Opportunity',' AND Status__c = \'Completed\'');
         }
    }

    public void onAfterUndelete(list<Stips__c> stipsList){
        if( [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'StipRollUpTrigger'].IsActivate__c){
                list<RollupService.fieldDefinition> fieldDefinitions_OpenStips =
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','Open_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_OpenStips ,stipsList,'Stips__c','Opportunity__c','Opportunity',' AND (Status__c != \'Completed\' AND Status__c != \'Cancelled\')');

                list<RollupService.fieldDefinition> fieldDefinitions_ClosedStips =
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','Closed_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_ClosedStips ,stipsList,'Stips__c','Opportunity__c','Opportunity',' AND Status__c = \'Completed\'');
         }
    }

    public void onAfterDelete(list<Stips__c> stipsList) {
        if([select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'StipRollUpTrigger'].IsActivate__c){
            list<RollupService.fieldDefinition> fieldDefinitions_OpenStips =
                new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','Open_Stip_Count__c')
            };
            RollupService.rollUpTrigger(fieldDefinitions_OpenStips ,stipsList,'Stips__c','Opportunity__c','Opportunity',' AND (Status__c != \'Completed\' AND Status__c != \'Cancelled\')');

            list<RollupService.fieldDefinition> fieldDefinitions_ClosedStips =
                new list<RollupService.fieldDefinition> {
                new RollupService.fieldDefinition('COUNT','Id','Closed_Stip_Count__c')
            };
            RollupService.rollUpTrigger(fieldDefinitions_ClosedStips ,stipsList,'Stips__c','Opportunity__c','Opportunity',' AND Status__c = \'Completed\'');
        }
    }

    public void onBeforeDelete() {
        //new AttachmentService().deleteStipAttachmentAndAttachment(trigger.oldMap.keySet());
    }
}