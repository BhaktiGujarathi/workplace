public with sharing class CustomEventList{

    public Wrapper wrapperObj {get; set;}
    public CustomEventList(ApexPages.standardController controller){
        getEventList(controller.getRecord().id);
    }
    
    public class Wrapper{
        public List<Event> eventList {get; set;}
        public List<String> fieldList {get; set;}
        public Wrapper(){
            eventList = new List<Event>();
            fieldList = new List<String>();
        }
    }
    
    public Wrapper getEventList(Id inquiryId){
        String userId = UserInfo.getUserId();
        String profileName  = '';
        wrapperObj = new Wrapper();
        String query = 'Select ';
        for(Schema.FieldSetMember f : SObjectType.Event.FieldSets.CustomEventList.getFields()){
            wrapperObj.fieldList.add(f.getFieldPath());
            query += f.getFieldPath() + ', ';
        }
        for(Profile p : [SELECT Id, Name FROM Profile WHERE Id=:UserInfo.getProfileId() LIMIT 1]){
        	profileName = p.Name;
        }
        if(profileName.equalsIgnoreCase('property consultant')){
        	query += 'Id from Event where WhatId =:inquiryId AND OwnerId=:userId';
        }else{
        	query += 'Id from Event where WhatId =:inquiryId';
        }
        wrapperObj.eventList = Database.query(query);
        system.debug(wrapperObj);
        system.debug(wrapperObj.fieldList);
        return wrapperObj;
    }
}