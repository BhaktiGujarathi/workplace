/*
    Revision History:
 *   
 * Version         Author              Date(DD-MM-YYYY)      Description
 * 1.0             Shraddha P.           16-03-2016          Initial Draft
 */ 
trigger SubmissionTrigger on Submission__c (after insert, after update, after delete, after undelete) {
if(trigger.isAfter && [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'SubmissionRollUpTrigger'].IsActivate__c) {
    //if record is Inserted,Updated or Undeleted fire the following trigger condition
    if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete){
        system.debug('*** TRIGGER FIRED ****');
        list<RollupService.fieldDefinition> fieldDefinitions = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('COUNT','Id','Number_of_Submission__c')
        };
        RollupService.rollUpTrigger(fieldDefinitions,trigger.new,'Submission__c','Opportunity__c','Opportunity','');
    }

    //if record is Deleted fire the following trigger condition
    if(trigger.isDelete){
        system.debug('*** TRIGGER FIRED ****');
        list<RollupService.fieldDefinition> fieldDefinitions = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('COUNT','Id','Number_of_Submission__c')
        };
        RollupService.rollUpTrigger(fieldDefinitions,trigger.old,'Submission__c','Opportunity__c','Opportunity','');
    }
}
}