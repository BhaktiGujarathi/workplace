/*
*
*Modified By -Ashwini S         Date: 09/21/2015            Description:To roll up project on Account
*
*/
trigger ProjectTrigger on HarvestProject__c (after insert, after update, after delete) {

    if(trigger.isafter && trigger.isInsert && checkRecursive.runOnceForAfter()){
        new HarvestProjectHandler().onAfterInsert();
//old code
        List<HarvestProject__c> toUpdate = new List<HarvestProject__c>();
            for (HarvestProject__c project : trigger.new) {
                HarvestProject__c p = new HarvestProject__c(
                Id = project.Id,
                ProjectCodeExternalId__c = project.ProjectCode__c
                );
                toUpdate.add(p);
            }   
            update toUpdate;
             
    }
    if(trigger.isafter && trigger.isUpdate && checkRecursive.runOnceForAfter()){
        new HarvestProjectHandler().onAfterUpdate();
    }

    if(trigger.isafter && trigger.isDelete && checkRecursive.runOnceForAfter()){
        new HarvestProjectHandler().onAfterDelete();
    }

}