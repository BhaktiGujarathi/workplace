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
    public Set<Integer> setInvalidRow;
    public Boolean isValidation;
    Map<Integer, Integer> mapOfIndex;
    
    public MCATasksTabController() {
        mapIDANDTask = new Map<Id, Task>();
        setInvalidRow = new Set<Integer>();
        isFirst = true;
        editAll = false;
        mapOfIndex = new Map<Integer, Integer>();
        isValidation = false;
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        Id profileId=userinfo.getProfileId();
        taskPermission=[Select Id,PermissionsEditTask from Profile where Id=:profileId].PermissionsEditTask;
        refresh();
    }

     public Container[] getContainers() {
        tasks = new Task[] {};
        
        tasks.addAll(newTasks);
        if(isFirst && !editAll && !isValidation && setInvalidRow.size() <= 0) {
            tasks.addAll(taskList());
        } else {
            for (Container containerVal: containers) {
                if(containerVal.index != indexToRemove)
                    tasks.add(containerVal.task);
            }
        }
        indexToRemove = -1;
        taskCount = tasks.size();
        containers = new Container[] {};
        for (Integer i = 0; i < tasks.size(); i++) {
            
            if(setInvalidRow.contains(i - newTasks.size()))
                containers.add(new Container(tasks[i], i, true));
            else
                containers.add(new Container(tasks[i], i, false));
        }
        newTasks = new List<Task>();
        return containers;
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
        String msgStr = '';
        setInvalidRow.clear();
        try{
            //update listToUpdate;
            List<Database.saveResult> results = Database.update(listToUpdate, false);
            for (Integer i =0 ;i < results.size();i++) {
              if (!results[i].isSuccess()){
                  for (Database.Error err : results[i].getErrors()){
                      system.debug('err --->'+err);
                      msgStr = msgStr + 'Error: ' + err.getMessage() + ' For record with serial number : ' +(mapOfIndex.get(i) + 1) + '<br />';
                      
                      setInvalidRow.add(mapOfIndex.get(i));
                  }
              }
           }
           if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
        }
        catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }
    
    public void checkoldAndNewVal() {
        listToUpdate = new List<Task>();
        Task taskValue = new Task();
        mapOfIndex.clear();
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
                        mapOfIndex.put(listToUpdate.size() - 1, containerVal.index);
                        isUpdated = true;
                    }
                }
            }
        }
    }
    public void afterSave() {
        editAll = false;
        isFirst=true;
        recordToDelete = null;
        newTasks = new Task[] {};
    }
    public void refresh() {
        afterSave();
        setInvalidRow.clear();
    }

    public void saveAllTasks() {
        String msgStr = '';
        setInvalidRow.clear();
        isValidation = false;
        try{
          // upsert tasks;
          List<Database.upsertResult> results = Database.upsert(tasks, false);
           for (Integer i =0;i < results.size(); i++) {
              if (!results[i].isSuccess()){
                  for (Database.Error err : results[i].getErrors()){
                      msgStr = msgStr + 'Error: ' + err.getMessage() + ' For record with serial number : ' +(containers[i].index +1) + '<br />'; 
                      setInvalidRow.add(i);
                  }
              }
           }
           if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
        }
        catch(Exception e){
            isValidation = true;
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
        afterSave();
    }

    public void editAll() {
        editAll = true;
    }

    public void deleteTask() {
        saveMessage();
        if (recordToDelete != null) {
            Task record = [SELECT Id FROM Task WHERE Id = :recordToDelete];
            try {
                delete record;
            }catch (Exception ex){
                indexToRemove = -1;
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }
        }
    }
    public void removeTask() {
        saveMessage();
    }

    public class Container {

        public Task task {get;set;}
        public Integer index {get;set;}
        public Boolean isedited {get;set;}
        public Container(Task instance, Integer index, Boolean isedited) {
            task = instance;
            this.index = index;
            this.isedited = isedited;
        }
    } 

    public class LoggedInUserId {
        public String user_id {get; set;}
        public  LoggedInUserId(ApexPages.StandardController controller){
            user_id = UserInfo.getUserId();
        }
    }
  
}