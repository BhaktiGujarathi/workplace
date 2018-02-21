trigger CountActivitiesOnLeads on Task(after insert, after update, after delete) {
    Set <ID> leadIds = new Set<ID>();
     
    if(Trigger.isInsert){
        for(Task tsk: Trigger.new){
            string s = tsk.whoID;
            if( String.isNotBlank(s) && s.substring(0,3).equals('00Q') ) {
                leadIds.add(tsk.whoID); 
            }
        }
    }
          
    if(Trigger.isUpdate){
        for(Task tsk: Trigger.old){
            string s = tsk.whoID;
            if( String.isNotBlank(s) && s.substring(0,3).equals('00Q') ) {
                leadIds.add(tsk.whoID); 
            }
        }
        for(Task tsk: Trigger.new){
            string s = tsk.whoID;
          if( String.isNotBlank(s) && s.substring(0,3).equals('00Q') ) {
                leadIds.add(tsk.whoID); 
            }
        }
    }
    
    if(Trigger.isDelete){
        for(Task tsk: Trigger.old){
            string s = tsk.whoID;
           if( String.isNotBlank(s) && s.substring(0,3).equals('00Q') ) {
                leadIds.add(tsk.whoID); 
            }
        }
    }
     
    List<Lead> leadRec = [ Select Id, Name, Activity_Count__c From Lead Where Id IN: leadIds ];
    List<Task> tsk = [Select Id, whoID From Task Where whoID IN: leadIds]; 
    integer countTasks;
     
    for(Lead ld : leadRec){
        countTasks = 0;
        for(Task tk : tsk){
            if( ld.id == tk.whoID ){
                countTasks += 1;
            }
        }
        ld.Activity_Count__c = countTasks;
    }
    update leadRec;
}