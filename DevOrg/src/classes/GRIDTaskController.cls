public with sharing class GRIDTaskController{

    //declaration
    public List<Task> tasksLst;
    public List<TaskWrapper> taskWrapperLst;
    public Map<Id, Task> taskFromDbMap;
    public Set<String> taskFieldsApiSet;
    public String taskFieldsString = '';
    public String taskSumQueryStr='';
    public Set<String> taskfieldSumSet                  {get; set;}
    public Map<String, Decimal> taskFieldToSumMap       {get; set;}
    private Id opportunityId;
    
    public static Map<String, Schema.SObjectType> globalMap;
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    
    public List<Schema.FieldSetMember> taskFieldsetList {get; set;}
    public Boolean taskFirstRun;
    public Integer taskOffsetsize  {get; set;}
    public Integer taskBlockSize   {get; set;}
    public Integer taskRecordCount {get; set;}
    public Id recordToDelete        {get;set;}
    public Integer indexToRemove    {get;set;}
    public String taskSortExpression {get; set;}
    public string taskSortDirection   {get; set;}
    public String taskFieldType;
    public Boolean singleErrorOnSave;
    public Boolean isNewTaskBtnPress;
    public Boolean taskEditAll;
    
    //constructor
    public GRIDTaskController() 
    {
            if(GRIDOnloadStaticVariable.flipTask())
            {
                opportunityId = Apexpages.currentPage().getParameters().get('id');
                
                globalMap = GRIDOnloadStaticVariable.getGlobalMap();
                customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
                
                isNewTaskBtnPress = false;
                taskOffsetsize = 0;
                taskBlockSize = (Integer)customMetaDataSettingMap.get('Tasks').PageSize__c;
                taskRecordCount = 0;
                taskWrapperLst = new List<TaskWrapper>();
                tasksLst = new List<Task>();
                taskFromDbMap = new Map<Id, Task>();
                taskFieldsApiSet = new Set<String>();
                taskfieldSumSet = new Set<String>();
                taskFieldToSumMap = new Map<String, Decimal>();
                taskSortDirection = 'DESC';
                taskSortExpression = 'CreatedDate';
                taskFieldType = '';
                taskEditAll = false;

                Schema.DescribeSObjectResult descbResultTask = globalMap.get('Task').getDescribe();
                taskFieldsetList = descbResultTask.FieldSets.getMap().get(customMetaDataSettingMap.get('Tasks').Fieldset_Name__c).getFields();
                taskSumQueryStr = taskSumQuery(taskFieldsetList);
                system.debug('>>> taskFieldsetList : '+taskFieldsetList);
                taskFieldsApiSet = buildSetFromFieldListTask(taskFieldsetList);
                tasksLst = getTasksFromDB(opportunityId, taskBlockSize, taskOffsetsize, taskFieldsApiSet, taskSortExpression, taskSortDirection);
                taskFirstRun = true;
            
            }
    }
    
    // method to build a Set of FieldApi name From List of FieldSetMember
    public Set<String> buildSetFromFieldListTask(List<Schema.FieldSetMember> pTaskFieldsetList)
    {
        String taskReferenceField;
        for(Schema.FieldSetMember fieldInstance :pTaskFieldsetList)
        {
            taskReferenceField = '';
            taskFieldsApiSet.add(fieldInstance.getfieldPath());
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Reference'))
            {
                if(fieldInstance.getfieldPath().contains('__c'))
                {
                    taskReferenceField += fieldInstance.getfieldPath().substringBefore('__c')+'__r.Name';
                }
                else 
                {
                    taskReferenceField += fieldInstance.getfieldPath().substringBefore('Id')+'.Name';
                }
                taskFieldsApiSet.add(taskReferenceField);
            }
        }
        return taskFieldsApiSet;
    }
    
    //getter of wrapperList
    public List<TaskWrapper> gettaskWrapperLst() 
    {
        if(taskFirstRun)
        {
            taskWrapperLst = new List<TaskWrapper>();
            //taskWrapperLst.clear();
            for (Integer i = 0; i < tasksLst.size(); i++) 
            {
                taskWrapperLst.add(new TaskWrapper(tasksLst[i],i, false ));
            }
           taskFirstRun = false;
        }
        taskFieldToSumMap = taskGetfieldSum(taskSumQueryStr);
        return taskWrapperLst;
    }
    
    //It is used query all the present task for the opportunity
    public List<Task> getTasksFromDB(Id pOppId, Integer pTaskBlockSize, Integer pTaskOffsetsize, Set<String> pTaskFieldsApiSet,String pTaskSortExpression, String pTaskSortDirection) 
    {
        //tasksLst.clear();
        String taskQueryStr = '';
        taskFieldsString = DEWUtility.getStringfromSet(pTaskFieldsApiSet, null);
        taskQueryStr = 'Select ' +taskFieldsString+ 'From Task Where WhatId =:pOppId ORDER BY '+pTaskSortExpression+' '+pTaskSortDirection+' NULLS LAST LIMIT '
                        +pTaskBlockSize+' Offset ' +pTaskOffsetsize;
       // tasksLst = database.query(taskQueryStr);
        system.debug('>>>taskQueryStr : '+taskQueryStr);
        return database.query(taskQueryStr);
    }
    
    // method to delete task
    public void deleteTask() 
    {
         if(taskWrapperLst[indexToRemove].Task.Id != null) 
         {
            try
            {
                delete taskWrapperLst[indexToRemove].task;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
             tasksLst.remove(indexToRemove);
             taskWrapperLst.remove(indexToRemove);

            //re-indexing
             for(Integer i=0;i<taskWrapperLst.size();i++)
             {
               taskWrapperLst[i].index = i;
             
             }

            if(taskWrapperLst.size() <= 0)
            {
                refreshTasks();
            }
            taskFieldToSumMap = taskGetfieldSum(taskSumQueryStr);
    }
    
    // method be called on refresh button 
    public void refreshTasks() {
         tasksLst = getTasksFromDB(opportunityId, taskBlockSize, taskOffsetsize, taskFieldsApiSet, taskSortExpression, taskSortDirection);
         taskFirstRun = true;
    } 
    
    // method be called on new button
    public void newTask() 
    {
        isNewTaskBtnPress = true;
        if(!taskEditAll)
        {
            saveAllTasks();
        }
        else 
        {
            singleErrorOnSave = false;
        }
        isNewTaskBtnPress = false;
 
        if(!singleErrorOnSave)
        {
            // to add new task only on first page
            if(taskOffsetsize <> 0) 
            {
                taskOffsetsize = 0;
                beginning();
            }
     
            Task tempNewTask = new Task(WhatId = opportunityId,Priority='Low',Status='Not Started',OwnerId = UserInfo.getUserId());
            /*need to add at 0th index if list size > 0 else simple add will work*/
            if(taskWrapperLst.size() > 0 && tasksLst.size() > 0)
            {
                taskWrapperLst.add(0,new TaskWrapper(tempNewTask, null, true));
                tasksLst.add(0,tempNewTask);
            }
            else
            {
                taskWrapperLst.add(new TaskWrapper(tempNewTask, null, true));
                tasksLst.add(tempNewTask);
            }
            //re-indexing
            for(Integer i=0;i<taskWrapperLst.size();i++)
            {
                taskWrapperLst[i].index = i;
            }
            
        }
    }
        
    // method to be called on save button
    public void saveAllTasks()
    {
        String msgStr = '';
        singleErrorOnSave = false;
        Boolean isTaskUpdated = false;
        taskEditAll = false;
        List<Task> taskListToUpdate = new List<Task>();
        Map<Integer, Integer> taskErrorToWraperIndexMap = new map<Integer, Integer>();
       
        List<Task> tasksTempLst = getTasksFromDB(opportunityId, taskBlockSize, taskOffsetsize, taskFieldsApiSet, taskSortExpression, taskSortDirection);
        taskFromDBMap = getTaskMapFromList(tasksTempLst);
        
        for(TaskWrapper tskWraperInstance :taskWrapperLst) 
        {
            Task taskDBObj = taskFromDBMap.get(tskWraperInstance.task.Id);
            if(taskDBObj != null)
            {
                isTaskUpdated = false;
                for(String tskFieldInstance :taskFieldsApiSet)
                {

                    //********************** doubt
                    if(!tskFieldInstance.contains('.Name')) 
                    {
                        isTaskUpdated  = isTaskUpdated || (tskWraperInstance.task.get(tskFieldInstance) != taskDBObj.get(tskFieldInstance));
                    }
                }
            }
            else
            {
                   if(!isNewTaskBtnPress) 
                   {
                     isTaskUpdated = true;
                   }
            }

            if(isTaskUpdated) 
            {
                taskListToUpdate.add(tskWraperInstance.task);
                taskErrorToWraperIndexMap.put(taskListToUpdate.size()-1, tskWraperInstance.index);
            }
            
            tskWraperInstance.editIt = false;
        }
        
        try
        {
            if(taskListToUpdate != null && taskListToUpdate.size() >0)
            {
                List<Database.upsertResult> results = Database.upsert(taskListToUpdate, false);
                for (Integer i =0; i < results.size(); i++) 
                {
                    if (!results[i].isSuccess())
                    {
                        for (Database.Error err : results[i].getErrors())
                        {
                              //+1 is added for Display on VF page only  
                              msgStr = msgStr + 'Error Record '+(taskErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!msgStr.contains('insufficient access rights on object id'))
                        {
                            taskWrapperLst[taskErrorToWraperIndexMap.get(i)].editIt = true; 
                            //note on insuffivient privilage
                            singleErrorOnSave = true;
                        }
                    }
                    /*else
                    {
                         taskWrapperLst[taskErrorToWraperIndexMap.get(i)].editIt = false;
                    }*/
                }
                if(singleErrorOnSave == false && !isNewTaskBtnPress)
                {
                    tasksLst = getTasksFromDB(opportunityId, taskBlockSize, taskOffsetsize, taskFieldsApiSet, taskSortExpression, taskSortDirection);
                    taskFieldToSumMap = taskGetfieldSum(taskSumQueryStr);
                    taskFirstRun = true;
                }
                if(String.isNotBlank(msgStr)) 
                {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
                }
            }
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
             taskFirstRun = false;
        }
        
    }
    
     // method for editAll 
    public void editAllTasks()
    {
        taskFirstRun = false;
        taskEditAll = true;
        for(Integer i=0; i< taskWrapperLst.size(); i++) 
        {
            taskWrapperLst[i].editIt = true;
        }
    }

    // method to build a map from a list from DB
    public Map<Id, Task> getTaskMapFromList(List<Task> pTasksLst) 
    {
        taskFromDbMap.clear();
        for(Task taskInstance :pTasksLst) 
        {
            taskFromDbMap.put(taskInstance.Id, taskInstance);
        }
        return taskFromDbMap;
    }
    
    // method to build dynamic query for sum
    public String taskSumQuery(List<Schema.FieldSetMember> pTaskFieldsetList)
    {
        taskSumQueryStr = 'SELECT ';
        
        for(Schema.FieldSetMember fieldInstance :pTaskFieldsetList)
        {
            if(String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Currency') 
               || String.valueOf(fieldInstance.getType()).equalsIgnoreCase('Double'))
            {
                taskSumQueryStr += 'SUM('+fieldInstance.getFieldPath()+') '+fieldInstance.getFieldPath()+ ', ';
                taskfieldSumSet.add(fieldInstance.getFieldPath());
            }
            //taskFieldsApiSet.add(fieldInstance.getfieldPath());
            taskFieldToSumMap.put(fieldInstance.getFieldPath(), -999.999);
        }
        taskSumQueryStr += 'COUNT(Id) taskCount FROM Task Where WhatId = \''+opportunityId+'\'';
        return taskSumQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> taskGetfieldSum(String pTaskSumQueryStr)
    {
        List<SObject> taskSumQueryResult = new List<SObject>();
        taskSumQueryResult = Database.query(pTaskSumQueryStr);
        system.debug(taskSumQueryResult);
        for(String fieldName :taskfieldSumSet) 
        {
            if(taskSumQueryResult[0].get(fieldName) != null)
            {
                taskFieldToSumMap.put(fieldName, (Decimal)taskSumQueryResult[0].get(fieldName)); 
            }
        }
        taskRecordCount = (Integer)taskSumQueryResult[0].get('taskCount');
        return taskFieldToSumMap;
    }
    
    //wrapper class to hold task
     public class TaskWrapper 
     {
        public Task task {get;set;}
        public Integer index {get;set;}
        public Boolean editIt {get;set;}
        public TaskWrapper(Task instance, Integer pindex, Boolean pEditIt) 
        {
            task = instance;
            index = pindex;
            editIt = pEditIt;
        }
    }
    
    //method for the first page of list to be displayed
    public void beginning() 
    {
        saveAllTasks();
        if(!singleErrorOnSave)
        {
            taskOffsetsize = 0;
            tasksLst = getTasksFromDB(opportunityId, taskBlockSize, taskOffsetsize, taskFieldsApiSet, taskSortExpression, taskSortDirection);
            taskFirstRun = true;
        }
    }
    
    //method for previous page of list to be displayed
    public void previous() 
    {
        saveAllTasks();
        if(!singleErrorOnSave && taskBlockSize <= taskOffsetsize)
        {
            taskOffsetsize = taskOffsetsize - taskBlockSize;
            tasksLst = getTasksFromDB(opportunityId, taskBlockSize, taskOffsetsize, taskFieldsApiSet, taskSortExpression, taskSortDirection);
            taskFirstRun = true;
        } 
    } 
    
    //method for next page of list to be displayed
    public void next() 
    {
        saveAllTasks();
        if(!singleErrorOnSave && taskOffsetsize <= taskRecordCount) 
        {
            taskOffsetsize = taskOffsetsize + taskBlockSize;
            tasksLst = getTasksFromDB(opportunityId, taskBlockSize, taskOffsetsize, taskFieldsApiSet, taskSortExpression, taskSortDirection);
            taskFirstRun = true;
        }
    }
    
    //method for last page of list to be displayed
    public void end() 
    {
        saveAllTasks();
        if(!singleErrorOnSave && math.mod(taskRecordCount , taskBlockSize) == 0){
            taskOffsetsize = taskBlockSize * ((taskRecordCount/taskBlockSize)-1);
        } else if (!singleErrorOnSave && math.mod(taskRecordCount , taskBlockSize) != 0){
            taskOffsetsize = taskBlockSize * ((taskRecordCount/taskBlockSize));
        }
        //taskOffsetsize = taskRecordCount-MAth.mod(taskRecordCount,taskBlockSize);
        tasksLst = getTasksFromDB(opportunityId, taskBlockSize, taskOffsetsize, taskFieldsApiSet, taskSortExpression, taskSortDirection);
        taskFirstRun = true;
    }
    
    //method to sort list of task
    public void sortTask()
    {
            string taskReferenceFieldName = '';
            taskFieldType = Apexpages.currentPage().getParameters().get('taskTypeParam');
            if(taskFieldType.equalsIgnoreCase('REFERENCE'))
            {
                if(taskSortExpression.contains('__c'))
                {
                    taskReferenceFieldName += taskSortExpression.substringBefore('__c')+'__r.Name';
                    //taskSortExpression = string.valueOf(taskReferenceFieldName);
                }
                else
                 //if(taskSortExpression.endsWithIgnoreCase('Id'))
                {
                    taskReferenceFieldName += taskSortExpression.substringBefore('Id')+'.Name';
                    //taskSortExpression = string.valueOf(taskReferenceFieldName);
                }
                taskSortExpression = string.valueOf(taskReferenceFieldName);
            } 
            refreshTasks();
    }
    
}