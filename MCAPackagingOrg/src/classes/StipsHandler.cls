/* 
 *  Apex Stips Handler Class
 * 
 *  Version           Author                 Date                 Description 
 *  1.1               Yogesh Mahajan         24-02-2016           Added method for Before Delete on
                                                                  line no.22
 */

public with sharing class StipsHandler {
    
    public void onAfterInsert(list<Stips__c> stipsList){
        
        //For all the inserted stips pass trigger in
        //StoreChildToParentHelper objHandler = new StoreChildToParentHelper();
        //objHandler.copyField(stipsList);
         if( [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'StipRollUpTrigger'].IsActivate__c){
                list<RollupService.fieldDefinition> fieldDefinitions_OpenStips = 
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','McaApp__Open_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_OpenStips ,stipsList,'McaApp__Stips__c','McaApp__Opportunity__c','Opportunity',' AND (McaApp__Status__c != \'Completed\' AND McaApp__Status__c != \'Cancelled\')');
        
                list<RollupService.fieldDefinition> fieldDefinitions_ClosedStips = 
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','McaApp__Closed_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_ClosedStips ,stipsList,'McaApp__Stips__c','McaApp__Opportunity__c','Opportunity',' AND (McaApp__Status__c = \'Completed\' OR McaApp__Status__c = \'Cancelled\')');
         }
    } 
    
    public void onAfterUpdate(list<Stips__c> stipsList){
        if( [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'StipRollUpTrigger'].IsActivate__c){
                list<RollupService.fieldDefinition> fieldDefinitions_OpenStips = 
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','McaApp__Open_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_OpenStips ,stipsList,'McaApp__Stips__c','McaApp__Opportunity__c','Opportunity',' AND (McaApp__Status__c != \'Completed\' AND McaApp__Status__c != \'Cancelled\')');
        
                list<RollupService.fieldDefinition> fieldDefinitions_ClosedStips = 
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','McaApp__Closed_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_ClosedStips ,stipsList,'McaApp__Stips__c','McaApp__Opportunity__c','Opportunity',' AND (McaApp__Status__c = \'Completed\' OR McaApp__Status__c = \'Cancelled\')');
         }
    }
    
    public void onAfterUndelete(list<Stips__c> stipsList){
        if( [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'StipRollUpTrigger'].IsActivate__c){
                list<RollupService.fieldDefinition> fieldDefinitions_OpenStips = 
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','McaApp__Open_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_OpenStips ,stipsList,'McaApp__Stips__c','McaApp__Opportunity__c','Opportunity',' AND (McaApp__Status__c != \'Completed\' AND McaApp__Status__c != \'Cancelled\')');
        
                list<RollupService.fieldDefinition> fieldDefinitions_ClosedStips = 
                    new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','McaApp__Closed_Stip_Count__c')
                };
                RollupService.rollUpTrigger(fieldDefinitions_ClosedStips ,stipsList,'McaApp__Stips__c','McaApp__Opportunity__c','Opportunity',' AND (McaApp__Status__c = \'Completed\' OR McaApp__Status__c = \'Cancelled\')');
         }
    }
    
    public void onAfterDelete(list<Stips__c> stipsList) {
        if([select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'StipRollUpTrigger'].IsActivate__c){
            list<RollupService.fieldDefinition> fieldDefinitions_OpenStips = 
                new list<RollupService.fieldDefinition> {
                    new RollupService.fieldDefinition('COUNT','Id','McaApp__Open_Stip_Count__c')
            };
            RollupService.rollUpTrigger(fieldDefinitions_OpenStips ,stipsList,'McaApp__Stips__c','McaApp__Opportunity__c','Opportunity',' AND (McaApp__Status__c != \'Completed\' AND McaApp__Status__c != \'Cancelled\')');
        
            list<RollupService.fieldDefinition> fieldDefinitions_ClosedStips = 
                new list<RollupService.fieldDefinition> {
                new RollupService.fieldDefinition('COUNT','Id','McaApp__Closed_Stip_Count__c')
            };
            RollupService.rollUpTrigger(fieldDefinitions_ClosedStips ,stipsList,'McaApp__Stips__c','McaApp__Opportunity__c','Opportunity',' AND (McaApp__Status__c = \'Completed\' OR McaApp__Status__c = \'Cancelled\')');
        }
    }
    
    public void onBeforeDelete() {
        new AttachmentService().deleteStipAttachmentAndAttachment(trigger.oldMap.keySet());
    }
}