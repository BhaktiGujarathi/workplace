/*
    Revision History:
 *   
 * Version         Author              Date(DD-MM-YYYY)      Description
 * 1.0             Shraddha P.           16-03-2016          Initial Draft
 */ 
trigger MerchantPaymentTrigger on Merchant_Payment__c (after insert, after update, after delete, after undelete) {

if(trigger.isAfter && [select IsActivate__c from MCATriggerExecuter__mdt where DeveloperName = 'MerchantPaymentRollUpTrigger'].IsActivate__c ) {
    //if record is Inserted,Updated or Undeleted fire the following trigger condition
    if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete){        
        list<RollupService.fieldDefinition> fieldDefinitions = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM','McaApp__Payment_Amt__c','McaApp__Total_Merchant_Payment__c')
        };
        RollupService.rollUpTrigger(fieldDefinitions,trigger.new,'McaApp__Merchant_Payment__c','McaApp__Opportunity__c','Opportunity','');
    }

    //if record is Deleted fire the following trigger condition
    else if(trigger.isDelete){        
        list<RollupService.fieldDefinition> fieldDefinitions = 
        new list<RollupService.fieldDefinition> {
            new RollupService.fieldDefinition('SUM','McaApp__Payment_Amt__c','McaApp__Total_Merchant_Payment__c')
        };
        RollupService.rollUpTrigger(fieldDefinitions,trigger.old,'McaApp__Merchant_Payment__c','McaApp__Opportunity__c','Opportunity','');
    }

}

}