/*
   Created by :Srikanth Pinnamaneni
*/  

trigger AccountISOTrigger on Account (before insert , before update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        AcccountISOTriggerhandler.checkExsistingMethod(trigger.new);
    }

}