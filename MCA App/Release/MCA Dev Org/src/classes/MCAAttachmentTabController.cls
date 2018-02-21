global with sharing class MCAAttachmentTabController {
    
     public Attachment[] attachments;
     public Container[] containers;
     public Id opportunityId;
     public Opportunity opportunity{get;set;}
     public Boolean editAll {get;set;}
     public Id recordToDelete {get;set;}
     
     public MCAAttachmentTabController(){
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        opportunity = [select Id, Name, AccountId from Opportunity where Id =: opportunityId];
        refresh();
     }
     
     public Container[] getContainers() {

        attachments = new Attachment[] {};
        containers = new Container[] {};
        //tasks.addAll(newTasks);
        attachments.addAll([Select a.ParentId,
                                 a.Name,
                                 a.IsPrivate,
                                 a.Id,
                                 a.Description,
                                 a.ContentType,
                                 a.BodyLength,
                                 a.CreatedDate,
                                 a.SystemModstamp
                                 From Attachment a
                        WHERE a.ParentId = :opportunityId
                        order by a.CreatedDate Desc]);
                    
        for (Integer i = 0; i < attachments.size(); i++) {
            //attachments[i].BodyLength=(attachments[i].BodyLength)/1024;
          containers.add(new Container(attachments[i], i));
        }
        system.debug('@@@'+containers+attachments.size());
        return containers;
      }
  
      public void deleteAttachment() {
          if (recordToDelete != null) {
            Attachment record = [SELECT Id FROM Attachment WHERE Id = :recordToDelete];
          delete record;
        }
      }
      
      public void saveAllAttachments() {
        upsert attachments;
        refresh();
      }
      
      public void refresh() {
        editAll = false;
        recordToDelete = null;
        //newTasks = new Task[] {};
      }
      
      public void editAll() {
        editAll = true;
      }
      
     public void CollectData() {
        String s1 = ApexPages.currentPage().getParameters().get('data');
        system.debug('### S1'+s1);
        transient Blob b = EncodingUtil.base64Decode(s1.substringAfter('base64,'));
        Attachment a = new Attachment();  
        a.Body= b;
        a.ParentId = ApexPages.currentPage().getParameters().get('id');
        a.Name= ApexPages.currentPage().getParameters().get('name');
        insert a;
        //getAllAttachment ();  
    }
    public class Container {
        public Attachment attachment {get;set;}
        public Integer index {get;set;}
        public Decimal sizeKB{get;set;}
    
        public Container(Attachment instance, Integer index) {
          attachment = instance;
          this.index = index;
          this.sizeKB=((decimal.valueof(attachment.BodyLength))/1024).setScale(2);
         system.debug(sizeKB+'_----------------');
        }
      } 
}