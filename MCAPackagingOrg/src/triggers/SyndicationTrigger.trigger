/*
    Revision History:
 *   
 * Version         Author              Date(DD-MM-YYYY)      Description
 * 1.0             Shraddha P.           16-03-2016          Initial Draft
 */ 
trigger SyndicationTrigger on Syndication__c (after insert, after update, after delete, after UnDelete) {
    if(Trigger.isAfter && [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'SyndicationRollUpTrigger'].IsActivate__c) {
    //if record is Inserted,Updated or Undeleted fire the following trigger condition
    if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete){
        list<RollupService.fieldDefinition> fieldDefinitions = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM','McaApp__Syndication_Amt__c ','McaApp__Total_Syndication_Amt__c')
        };
        RollupService.rollUpTrigger(fieldDefinitions,trigger.new,'McaApp__Syndication__c','McaApp__Opportunity__c','Opportunity','');
        
        list<RollupService.fieldDefinition> fieldDefinitions_syndicationfee = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM','McaApp__Servicing_Fee__c ','McaApp__Total_Syndications_Fee__c')
        };
        RollupService.rollUpTrigger(fieldDefinitions_syndicationfee,trigger.new,'McaApp__Syndication__c','McaApp__Opportunity__c','Opportunity','');
    }
    //if record is Deleted fire the following trigger condition
    if(trigger.isDelete){
        list<RollupService.fieldDefinition> fieldDefinitions = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM','McaApp__Syndication_Amt__c ','McaApp__Total_Syndication_Amt__c')
        };
        RollupService.rollUpTrigger(fieldDefinitions,trigger.old,'McaApp__Syndication__c','McaApp__Opportunity__c','Opportunity','');
        
        list<RollupService.fieldDefinition> fieldDefinitions_syndicationfee = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM','McaApp__Servicing_Fee__c ','McaApp__Total_Syndications_Fee__c')
        };
        RollupService.rollUpTrigger(fieldDefinitions_syndicationfee,trigger.old,'McaApp__Syndication__c','McaApp__Opportunity__c','Opportunity','');
    }
}
}