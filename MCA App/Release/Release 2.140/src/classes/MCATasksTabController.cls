public with sharing class MCATasksTabController{

    public Task[] tasks;
    public Container[] containers;
    public Task[] newTasks          {get;set;}
    public Boolean editAll          {get;set;}
    public Boolean taskPermission   {get;set;}
    public Id recordToDelete        {get;set;}
    public Integer indexToRemove    {get;set;}

    private Id opportunityId;
    public Integer taskCount {get; set;}
    public Boolean isFirst;
    public Boolean isUpdated;
    public Map<Id, Task> mapIDANDTask;
    public List<Task> listToUpdate;
    public Boolean isValidation;
    
    public MCATasksTabController() {
        mapIDANDTask = new Map<Id, Task>();
        isFirst = true;
        editAll = false;
        isValidation = false;
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        Id profileId=userinfo.getProfileId();
        taskPermission=[Select Id,PermissionsEditTask from Profile where Id=:profileId].PermissionsEditTask;
        refresh();
    }

     public Container[] getContainers() {
        tasks = new Task[] {};
        
        tasks.addAll(newTasks);
        if(isFirst && !editAll && !isValidation) {
            tasks.addAll(taskList());
        } else {
            system.debug('11111111111111111111'+containers);
            for (Container containerVal: containers) {
                if(containerVal.index != indexToRemove)
                    tasks.add(containerVal.task);
            }
        }
        indexToRemove = -1;
        taskCount = tasks.size();
        containers = new Container[] {};
        for (Integer i = 0; i < tasks.size(); i++) {
            containers.add(new Container(tasks[i], i));
        }
        newTasks = new List<Task>();
        return containers;
    }
    
    public void setContainers(Container[] containers) {
        system.debug('Setter values ---------> '+containers);
    }
    //It is used query all the present task for the opportunity
    public List<Task> taskList() {
        isFirst = false;
        mapIDANDTask.clear();
        mapIDANDTask = new Map<ID, Task>([SELECT
                    Subject,
                    ActivityDate,
                    Priority,
                    Status,
                    Description,
                    OwnerId
                From Task
                WHERE WhatId = :opportunityId]);
        return mapIDANDTask.values();
    }
    
    public void save(){}
    public void newTask() {
        String userId = UserInfo.getUserId();
        saveMessage();
        newTasks.add(new Task(WhatId = opportunityId,Status='Not Started',Priority='Normal', OwnerId = UserInfo.getUserId()));
    }
    public void saveMessage(){
        isUpdated = false;
        checkoldAndNewVal();
        if(editAll !=true && isUpdated == true){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
            updateInlineEditedValue();
        }
    }
    
    public void updateInlineEditedValue() {
        try{
            update listToUpdate;
        }
        catch(Exception e){
            system.debug('***Enter In Exception****');
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }
    
    public void checkoldAndNewVal() {
        listToUpdate = new List<Task>();
        Task taskValue = new Task();
        List<Task> taskListValues = taskList();
        for (Container containerVal: containers) {
            if(containerVal.task.id != null){
               taskValue = mapIDANDTask.get(containerVal.task.id);
               if(taskValue != null) {
                    if(containerVal.task.Subject !=taskValue.Subject
                    || containerVal.task.ActivityDate !=taskValue.ActivityDate
                    || containerVal.task.Priority !=taskValue.Priority
                    || containerVal.task.Status !=taskValue.Status
                    || containerVal.task.Description !=taskValue.Description
                    || containerVal.task.OwnerId !=taskValue.OwnerId ) {
                        listToUpdate.add(containerVal.task);
                        isUpdated = true;
                    }
                }
            }
        }
    }
    public void refresh() {
        editAll = false;
        isFirst=true;
        recordToDelete = null;
        newTasks = new Task[] {};
    }

    public void saveAllTasks() {
        isValidation = false;
        try{
            upsert tasks;
        }
        catch(Exception e){
            isValidation = true;
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
        refresh();
    }

    public void editAll() {
        editAll = true;
    }

    public void deleteTask() {
        system.debug('delete-------->'+recordToDelete);
        saveMessage();
        if (recordToDelete != null) {
            Task record = [SELECT Id FROM Task WHERE Id = :recordToDelete];
            delete record;
        }
    }
    public void removeTask() {
        saveMessage();
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
        public  LoggedInUserId(ApexPages.StandardController controller){
            user_id = UserInfo.getUserId();
        }
    }
  
}