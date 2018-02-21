/* 
 *  Description - Handler for TaskTrigger
 *                Post chatter Feed after insert of Task.
 * 
 *  Date - 09-06-2014
 *  
 *  Created by - Neena T.
 *
 */
public with sharing class TaskHandler {
    
    //The method will post the information comment on Chatter Feed after insert of Task.
    public void onAfterInsertTask(Map<Id,Task> ptaskMap){
        List<String> stipsName = new List<String>();
        Set<Id> TaskOppId = new Set<Id>();
        String chatterFeed = '' ;
        string Subject = '';
        list<FeedItem> feedItemToUpdateLst = new list<FeedItem>();
        
        PostToChatterUtility postUtility = new PostToChatterUtility();
        
        for(Task task : ptaskMap.values()){
            TaskOppId.add(task.WhatId); 
        }
        
        for(Stips__c stips : [Select Name, Id From Stips__c where Opportunity__c IN: TaskOppId] ){
            stipsName.add(stips.Name);
        }
        chatterFeed = Userinfo.getName()+' '+system.label.Chatter_Feed_update_ChatterFeedPost ;
        for(String stips : stipsName){
            chatterFeed += ' '+stips+' , ';
        }
        chatterFeed = chatterFeed.removeEnd(' , ');
        for(Task task : ptaskMap.values()){
            Subject = task.Subject;
            if(Subject!=null && Subject.contains('Pending Items for')){
                FeedItem feeditem = postUtility.postToChatter(chatterFeed, task.WhatId);
                feedItemToUpdateLst.add(feeditem);
            }
        }
        if(feedItemToUpdateLst != null && feedItemToUpdateLst.size()>0){
            insert feedItemToUpdateLst;
            
        }
    }

}