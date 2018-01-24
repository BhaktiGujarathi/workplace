/*
Created by:Srikanth Pinnamaneni
*/
trigger CommissionAgreementTrigger on Commission_Agreement__c (before insert,before update) {




    if(Trigger.isInsert ){
       CommissionAgreementTriggerHandler.updateAgreementsOnInsert(trigger.new);
    }
    
    if(Trigger.isUpdate){
        CommissionAgreementTriggerHandler.addErrorOnUpdate(trigger.new);
    
    }



}