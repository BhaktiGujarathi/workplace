public with sharing class MCATasksTabController{

  public Task[] tasks;
  
  public Container[] containers;

  public Task[] newTasks {get; set;}

  public Boolean editAll {get;set;}
  public Boolean taskPermission {get;set;}
  public Id recordToDelete {get;set;}
  public Integer indexToRemove {get;set;}

  private Id opportunityId;
  public Integer taskCount {get; set;}

  public MCATasksTabController() {
  	

    opportunityId = Apexpages.currentPage().getParameters().get('id');
    Id profileId=userinfo.getProfileId();
	taskPermission=[Select Id,PermissionsEditTask from Profile where Id=:profileId].PermissionsEditTask;
	system.debug('taskPermission'+taskPermission);

    refresh();
  }

  public Container[] getContainers() {

    tasks = new Task[] {};
    containers = new Container[] {};

    tasks.addAll(newTasks);

    tasks.addAll([SELECT
                      Subject,
                      ActivityDate,
                      Priority,
                      Status,
                      Description,
                      OwnerId
                      From Task
                    WHERE WhatId = :opportunityId]);
	taskCount = tasks.size();
    for (Integer i = 0; i < tasks.size(); i++) {
      containers.add(new Container(tasks[i], i));
    }

    return containers;
  }
  public void save(){}
  public void newTask() {
  	
    String userId = UserInfo.getUserId();
    newTasks.add(new Task(WhatId = opportunityId,Status='Not Started',Priority='Normal', OwnerId = UserInfo.getUserId()));
  }
  
  public void refresh() {

    editAll = false;
    recordToDelete = null;
    newTasks = new Task[] {};
  }

  public void saveAllTasks() {
    system.debug('****tasks***'+tasks);  
    upsert tasks;

    refresh();
  }

  public void editAll() {

    editAll = true;
  }

  public void deleteTask() {

    if (recordToDelete != null) {
      Task record = [SELECT Id FROM Task WHERE Id = :recordToDelete];
      delete record;
    }
  }

  public void removeTask() {

    if (indexToRemove != null) {

      Container c = null;

      for (Container element :containers) {

        if (element.index == indexToRemove) {
          c = element;
        }
      }
      newTasks.remove(c.index);
    }

  }

  public class Container {

    public Task task {get;set;}
    public Integer index {get;set;}

    public Container(Task instance, Integer index) {
      task = instance;
      this.index = index;
    }

  } 
  
  public class LoggedInUserId {

  public String user_id {get; set;}
  public  LoggedInUserId(ApexPages.StandardController controller)
  {
          user_id = UserInfo.getUserId();
          

  }

}
  
}