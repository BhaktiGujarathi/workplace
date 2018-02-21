trigger trgUpdateActivities on Opportunity (before update) {
    if(DRBPrevention.preventTrigger==false){
        for(Opportunity o: trigger.new){
            if(o.Stagename != null && o.Stagename != trigger.oldmap.get(o.id).Stagename )
                o.Activities_in_Current_Stage__c =0;
            if(o.Last_Activity_Date_Time__c==null || o.Last_Activity_User__c==null )
                o.Last_Closed_Task__c=null;
                               
        }
   }
}