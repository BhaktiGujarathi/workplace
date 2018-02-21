/***********************************************************************************************************************************
* Name               : TaskProcessHandler                                                         *
* Description        : Handler Class for All Task Creation Through Process in CRM Project                                *
* Created Date       : 17/07/2017                                                                                      *
* Created By         : Naresh                                                                                             *
* ---------------------------------------------------------------------------------------------------------------------*
* VERSION     AUTHOR               DATE            COMMENTS                                                               *
* 1.0         Naresh       02/07/2017      Initial Draft.                                                         *
* 
  *
**************************************************************************************************************************************/

public class TaskProcessHandler{


public void AfterUpdate(Map<Id ,Task> NewTask ,Map<Id ,Task> OldTask){

  Set<Id> TaskId = new Set<Id>();
 List<Task> TaskSompletedList=  new List<Task>();
  for(Task t :  NewTask.values()){
     if(t.Status.equalsignorecase('Completed'))
      
           TaskSompletedList.add(t);
           TaskId.add(t.id);
    }
   
    if(!TaskSompletedList.isEmpty()){
        TaskProcessCreation.TaskCreation(NewTask ,OldTask );
       }
   
   if(!TaskId.isEmpty()){
   // TaskCreationIPMS.TaskInsert(TaskId);
     TaskCreationIPMS.TaskCreationIPMSUpdate(TaskId);
   }
   
  
}
// if(t.Subject != OldTask.get(t.Id).Subject )

}