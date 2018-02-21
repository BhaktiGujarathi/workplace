/***********************************************************************************************************************************
* Name               : TaskUpdateWebService                                                         *
* Description        : WebService for TaskUpdateWebService                                *
* Created Date       : 18/07/2017                                                                                      *
* Created By         : Naresh                                                                                             *
* ---------------------------------------------------------------------------------------------------------------------*
* VERSION     AUTHOR               DATE            COMMENTS                                                               *
* 1.0         Naresh          17/07/2017      Initial Draft.                                                         *
* 
  *
**************************************************************************************************************************************/
global class TaskUpdateWebService{
global static Task task{get;set;}

webservice static Task TaskUpdate(String TaskId , String Status, String taskComments){
 task  = new Task();
 task  = [Select Id ,Priority , Status  from Task Where  Id =: TaskId limit 1];
  task.Status = Status ;  
  update task ;  
  return task ;
 
}


}