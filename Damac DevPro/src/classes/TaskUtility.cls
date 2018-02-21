public with sharing class TaskUtility {
    
    public static Task getTask(sObject objGeneric, String strSubject, String strAssignedUser, String strProcessName,
        Date dtDueDate) {
        Task objTask = new Task();
        objTask.OwnerId = (Id)objGeneric.get('OwnerId');
        objTask.WhatId = objGeneric.Id;
        objTask.Subject = strSubject;
        objTask.ActivityDate = dtDueDate;
        objTask.Assigned_User__c = strAssignedUser;
        objTask.Process_Name__c = strProcessName;
        objTask.Priority = 'High';
        objTask.Status = 'Not Started';
        return objTask;
    }
}