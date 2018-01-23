/**
 * Class FeedItemHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class FeedItemHandler implements TriggerInterface {
    public Map<String, FeedItem> mapFeed;
    public Map<String, FeedAttachment> mapAttachment;
    public Map<string,string> oppNameId;
    public Map<string,string> oppIdName;
    public Map<string,string> grpNameId;
    public Map<string,string> grpIdName;
    public String oppkeyPrefix= '';
    public String grpkeyPrefix= '';
    // Constructor
    public FeedItemHandler(){
        mapFeed = new Map<String, FeedItem>();
        oppNameId = new Map <string,string>();
        oppIdName = new Map <string,string>();
        grpNameId = new Map <string,string>();
        grpIdName = new Map <string,string>();
       mapAttachment = new Map<String , FeedAttachment>();
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){        
        
    }
 
    public void bulkAfter(){
        set<Id> FeedIDSET = new set<Id>();
        Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
            oppkeyPrefix = r.getKeyPrefix();
        Schema.DescribeSObjectResult r1 = CollaborationGroup.sObjectType.getDescribe();
            grpkeyPrefix = r1.getKeyPrefix();
        
        for(FeedItem feed: (List<FeedItem>)trigger.new){
            FeedIDSET.add(feed.parentId);
        }
        for(CollaborationGroup grp: [select id, name from CollaborationGroup where id in: FeedIDSET]){
            grpNameId.put(grp.name,grp.Id);
            grpIdName.put(grp.Id,grp.name);
        }
        string oppname;
        for(Opportunity opp: [select id, name from Opportunity where id in: FeedIDSET]){
            oppname= '';
            if(opp.name.length() > 40){
                oppname = opp.name.substring(0,40);
            }else{
                oppname = opp.name;
            }
            oppNameId.put(oppname,opp.Id);
            oppIdName.put(opp.Id,oppname);
        }
        for(FeedAttachment attchment :[Select id, RecordId, Type,FeedEntityId from FeedAttachment where FeedEntityId in : trigger.newMap.keySet()]){
            mapAttachment.put(attchment.FeedEntityId, new FeedAttachment(RecordId = attchment.RecordId, Type= attchment.Type));
        }
    }
 
    public void beforeInsert(SObject so){        
       
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
                   
    }
 
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){
       
    }
 
    public void afterInsert(SObject so){ 
        FeedItem feed =(FeedItem)so;
        
        if(String.valueOf(feed.parentId).startsWith(oppkeyPrefix)){
            FeedItem feeditem= new FeedItem();
            if(oppIdName.Keyset().contains(feed.parentId)){
                 if(grpNameId.keyset().contains(oppIdName.get(feed.parentId))){
                    feeditem.parentId= grpNameId.get(oppIdName.get(feed.parentId));
                    if(feed.type == 'TextPost'){
                         feeditem.body = feed.body;
                         feeditem.IsRichText=true;
                         feeditem.type = feed.type;
                        mapFeed.put(feed.parentId, feeditem );
                    }
                    if(feed.type == 'ContentPost'){
                        feeditem.body = String.isNotBlank(feed.body) ? String.ValueOf(feed.body) : '&nbsp;';
                        feeditem.IsRichText=true;
                        feeditem.type = feed.type; 
                        mapFeed.put(feed.parentId, feeditem );
                    }
                 }
                
            }
                
            
        }
        if(String.valueOf(feed.parentId).startsWith(grpkeyPrefix)){
            FeedItem feeditem= new FeedItem();
            if(grpIdName.Keyset().contains(feed.parentId)){
                if(oppNameId.keyset().contains(grpIdName.get(feed.parentId))){
                    feeditem.parentId= oppNameId.get(grpIdName.get(feed.parentId));
                    if(feed.type == 'TextPost'){
                         feeditem.body = feed.body;
                         feeditem.IsRichText=true;
                         feeditem.type = feed.type;
                          mapFeed.put(feed.parentId, feeditem );
                    }
                    if(feed.type == 'ContentPost'){
                        feeditem.body = String.isNotBlank(feed.body) ? String.ValueOf(feed.body) : '&nbsp;';
                        feeditem.IsRichText=true;
                        feeditem.type = feed.type; 
                        mapFeed.put(feed.parentId, feeditem );
                    }
                }   
            }       
        }
        
    }
    public void afterUpdate(SObject oldSo, SObject so){
                   
    }

    public void afterDelete(SObject so){
        
    }
 
    public void afterUndelete(SObject so){
        
    }
 
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally(){
        
        if(mapFeed.size()>0 ){
            insert mapFeed.values();
            
         System.debug('mapFeed>>>'+ mapFeed.values());  
            
            /* for attachment*/
            System.debug('mapAttachment>>>'+ mapAttachment.size());
            if(mapAttachment.size()>0){
                for(String feedID: mapAttachment.keySet()){
                    System.debug('test>>>>');
                    mapAttachment.get(feedID).FeedEntityId = mapFeed.get(mapAttachment.get(feedID).FeedEntityId).id;
                }
                insert mapAttachment.values();
            }
            
        }
                
    }
}