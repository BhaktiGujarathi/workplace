//Trigger to Count the Number of Attachments on the Opportunity Object

trigger CountAttachments on Attachment (after insert, after update, after delete, after undelete) {
  Map<Id,List<Attachment>> parent = new Map<Id,List<Attachment>>();
  set<id> attids = new set<id>();
     
   if(Trigger.new<>null){
       for(Attachment c:Trigger.new){
           Opportunity l;
           if(c.ParentId != null)
               attids.add(c.parentid);
       }
           
   }else if(Trigger.old != null){
       for(Attachment c:Trigger.old){
           if(c.ParentId<>null)      
               attids.add(Trigger.oldMap.get(c.id).parentid);
       }
   }
   if(attids.size()>0){
       try{
           List<Attachment> a = new List<Attachment>();
           Map<id,Opportunity> oppmap = new Map<id,Opportunity>([select id,CountAttachment__c from Opportunity where id IN: attids]);
           a = [select id,parentid from Attachment where parentid IN:attids];
           
           for(Attachment at: a){
               List<Attachment> llist = new List<Attachment>();
               if(parent.get(at.parentid) == null){
                   llist = new List<Attachment>();
                   llist.add(at);
                   parent.put(at.parentid,llist);
               }else if(parent.get(at.parentid) != null){
                   llist = new List<Attachment>();
                   llist = parent.get(at.parentid);
                   llist.add(at);
                   parent.put(at.parentid,llist);
               }
           }
           
           for(Id i: attids){
               if(oppmap.get(i) != null && parent.get(i) != null){
                  oppmap.get(i).CountAttachment__c = parent.get(i).size(); 
               
               }else if(oppmap.get(i) != null && parent.get(i) == null){
                  oppmap.get(i).CountAttachment__c = 0; 
               }
           }
       
           update oppmap.values();
           System.Debug(oppmap.values());
       }catch(Exception e){}
    }
}