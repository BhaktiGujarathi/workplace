/***********************************************************************************************************************************
* Name               : TaskUpdateWebService  Using Rest                                                       *
* Description        : WebService for TaskUpdateWebService                                *
* Created Date       : 18/07/2017                                                                                      *
* Created By         : Naresh                                                                                             *
* ---------------------------------------------------------------------------------------------------------------------*
* VERSION     AUTHOR               DATE            COMMENTS                                                               *
* 1.0         Naresh          17/07/2017      Initial Draft.                                                         *
* 
  *
**************************************************************************************************************************************/
@RestResource(urlMapping='/TaskUpdate/*')
global class TaskUpdate{
 
 
 global class TaskReturn{
  String TaskId ;
  String Status ;
  String Subject ;
 }

@HttpPost
global static TaskReturn  TaskUpdate(String TaskId , String Status){
TaskReturn newtask  = new TaskReturn();
 Task task = [select id , Status, Subject from Task where Id =: TaskId ];
 task.Status = Status ;
 task.Subject = 'Update Task By Rest WebService';
 
 update task ;

 newtask.TaskId = task.Id ;
 newtask.Status = task.Status ;
 newtask.Subject = task.Subject ;
 return newtask ;


}




}