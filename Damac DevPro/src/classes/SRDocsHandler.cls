public class SRDocsHandler implements TriggerFactoryInterface{

//Before Trigger Methods
  public void executeBeforeInsertTrigger(list<sObject> lstNewRecords){}
  public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){}
  public void executeBeforeDeleteTrigger(Map<Id, sObject> mapOldRecords){}
  public void executeBeforeInsertUpdateTrigger(list<sObject> lstNewRecords, Map<Id,sObject> mapOldRecords){}
  
  //After Trigger Methods
  public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){
      copyAttachements(mapNewRecords);
  
  }
  
    public void copyAttachements(Map<Id, sObject> mapNewRecords){  
        try{     
            set<id> srIds = new set<id>();
            map<string,string> mapSrDocs = new map<string,string>();
            for(sObject objrec : mapNewRecords.values()){    
                NSIBPM__SR_Doc__c newrec = (NSIBPM__SR_Doc__c)objrec;
                srIds.add(newrec.NSIBPM__Service_Request__c);
                mapSrDocs.put(newrec.Name,newrec.id);
            }
            
            // Get all Attachments
            list<attachment> srAttachments = new list<attachment>();
            srAttachments = [select id,Name from attachment where parentid IN: srIds];
            
            list<attachment> newAttachmentsToInsert = new list<attachment>();
            set<id> srDoctoUpdate = new set<id>();
            system.debug('PARENT ATTACHMENTS-->'+srAttachments);
            if(srAttachments.size()>0){
                for(attachment a:srAttachments){
                string fileKey = a.Name.substringBeforeLast('.');
                system.debug('FILE KEY>>>>'+fileKey);
                    if(mapSrDocs.containskey(a.Name)){
                        attachment newAttach = new attachment();
                        newAttach = a.clone();
                        newAttach.parentId = mapSrDocs.get(a.Name);
                        newAttachmentsToInsert.add(newAttach);
                        srDoctoUpdate.add(mapSrDocs.get(a.Name));
                    }    
                }
                insert newAttachmentsToInsert;
                list<NSIBPM__SR_Doc__c> listSrDocToUpdate = new list<NSIBPM__SR_Doc__c>(); 
                for(id i : srDoctoUpdate){  
                    if(mapNewRecords.containskey(i)){
                        NSIBPM__SR_Doc__c newrec = (NSIBPM__SR_Doc__c)mapNewRecords.get(i);
                        newrec.NSIBPM__Status__c = 'Uploaded';
                        listSrDocToUpdate.add(newrec);
                    }
                }
                update listSrDocToUpdate;
            }            
        }
        catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }
    
  
  public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){}
  public void executeAfterDeleteTrigger(Map<Id, sObject> mapOldRecords){}
  public void executeAfterInsertUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){}
}