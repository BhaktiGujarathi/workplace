public with sharing class CustomTaskList{

    public Wrapper wrapperObj {get; set;}
    public CustomTaskList(ApexPages.standardController controller){
        getTaskList(controller.getRecord().id);
    }
    
    public class Wrapper{
        public List<Task> taskList {get; set;}
        public List<String> fieldList {get; set;}
        public Wrapper(){
            taskList = new List<Task>();
            fieldList = new List<String>();
        }
    }
    
    public Wrapper getTaskList(Id inquiryId){
        String userId = UserInfo.getUserId();
        String profileName = '';
        wrapperObj = new Wrapper();
        String query = 'Select ';
        for(Schema.FieldSetMember f : SObjectType.Task.FieldSets.CustomTaskList.getFields()){
            wrapperObj.fieldList.add(f.getFieldPath());
            query += f.getFieldPath() + ', ';
        }
        for(Profile p : [SELECT Id, Name FROM Profile WHERE Id=:UserInfo.getProfileId() LIMIT 1]){
        	profileName = p.Name;
        }
        if(profileName.equalsIgnoreCase('property consultant')){
        	query += 'Id from Task where WhatId =:inquiryId AND OwnerId=:userId';
        }else{
        	query += 'Id from Task where WhatId =:inquiryId';
        }
        wrapperObj.taskList = Database.query(query);
        system.debug(wrapperObj);
        system.debug(wrapperObj.fieldList);
        return wrapperObj;
    }
}