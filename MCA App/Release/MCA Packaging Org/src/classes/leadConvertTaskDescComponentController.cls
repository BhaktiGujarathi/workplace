/*
  This is the controller for the leadConvertTaskDescComponent

  * Revision History:
  *   
  * Version         Author                                   Date                                    Description
  * 1.0             Nachiket R. Deshpande                    24/12/2014                              Initial Draft

*/
public with sharing class leadConvertTaskDescComponentController extends ComponentControllerBase {
    
    // this is the task object for the component which will be used to hold the task description
    public Task taskID {get; set;}
    
    // this is the checkbox indicating whether to send an eail notification
    public Boolean sendNotificationEmail {get; set;}
    
    //Constructor that creates a new Task object
    public leadConvertTaskDescComponentController() {
        taskId = new Task();
    }
}