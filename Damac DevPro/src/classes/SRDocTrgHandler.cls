/**************************************************************************************************
* Name               : SRDocTrgHandler                                                            *
* Description        : This is the trigger handler class for SRDoc object.                        *
* Created Date       : 30/03/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         Kaavya      30/03/2017    
* 2.0         Subhash     26/Apr/2017 - To Copy Attachment form SR to SR Doc                      *
**************************************************************************************************/
public class SRDocTrgHandler implements TriggerFactoryInterface  {
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before insert.                       *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeInsertTrigger(List<sObject> SRDocsList){
        try{
            for(sObject thisSObject : SRDocsList){
                 NSIBPM__SR_Doc__c thisSRDoc = ( NSIBPM__SR_Doc__c) thisSObject;
                 thisSRDoc.NSIBPM__Sys_RandomNo__c = Apex_Utilcls.getRandNo(4);
                 thisSRDoc.Sys_AphaNumeric_Random__c = Apex_Utilcls.getRandNo(6);
            }            
        }catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }
    
    
    public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){
          copyAttachements(mapNewRecords); // 2.0
    }
    
    // Method to cpoy the Attachement from SR to SR Doc matching with File Name on SR Attachement.
    public void copyAttachements(Map<Id, sObject> mapNewRecords){  
        try{     
            set<id> srIds = new set<id>();
            map<string,string> mapSrDocs = new map<string,string>();
            for(sObject objrec : mapNewRecords.values()){    
                NSIBPM__SR_Doc__c newrec = (NSIBPM__SR_Doc__c)objrec;
                srIds.add(newrec.NSIBPM__Service_Request__c);
                if(newrec.Name.containsignorecase('passport')){
                    mapSrDocs.put(newrec.Passport_Number__c,newrec.id);
                }
                if(newrec.name.containsignorecase('national')){
                    mapSrDocs.put(newrec.National_ID__c,newrec.id);
                }
            }
            
            // Get all Attachments of SRs in SR Docs
            list<attachment> srAttachments = new list<attachment>();
            srAttachments = [select id,Name,Body,Description from attachment where parentid IN: srIds LIMIT 50000];
            
            list<attachment> newAttachmentsToInsert = new list<attachment>();
            set<id> srDoctoUpdate = new set<id>();
            
            if(srAttachments.size()>0){
                for(attachment a:srAttachments){ // For each attachment matching with name create new attachment with SR doc as Parent
                    string fileKey = a.Name.substringBeforeLast('-');
                    system.debug('FILE KEY>>>>'+fileKey);
                    if(mapSrDocs.containskey(fileKey)){
                        attachment newAttach = new attachment();                        
                        newAttach.Description = a.Description;
                        newAttach.Name =a.Name;
                        newAttach.body = a.body;
                        newAttach.parentId = mapSrDocs.get(fileKey);
                        newAttachmentsToInsert.add(newAttach);
                        srDoctoUpdate.add(mapSrDocs.get(fileKey));
                    }    
                }
                insert newAttachmentsToInsert;
                // Update the status on the SR Doc to Uploaded.
                list<NSIBPM__SR_Doc__c> listSrDocToUpdate = new list<NSIBPM__SR_Doc__c>(); 
                listSrDocToUpdate = [select id,NSIBPM__Status__c from NSIBPM__SR_Doc__c where id in:srDoctoUpdate LIMIT 50000];
                for(NSIBPM__SR_Doc__c doc : listSrDocToUpdate){                     
                    doc.NSIBPM__Status__c = 'Uploaded';
                }
                system.debug('>>>>'+listSrDocToUpdate);
                update listSrDocToUpdate;
            }            
        }
        catch(exception ex){
            system.debug('#### Exception at line number = '+ex.getLineNumber()+' , Exception message = '+ex.getMessage());
        }
    }
    
     //kaavya - to rename the attachment Name.
     public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
        system.debug(mapNewRecords+'NEW>>>>>>>>>>>>');
        List<id>AttIds= new List<id>();
        Map<id,string> FileExtmap = new Map<id,string>();
        
        Map<Id,String>SRDocNamemap = new Map<Id,String>();
        Map<Id,String>SRDocPartyIDmap = new Map<Id,String>();
        for(Id thisKey : mapNewRecords.keySet()){
            NSIBPM__SR_Doc__c newSRDoc = (NSIBPM__SR_Doc__c)mapNewRecords.get(thisKey);
            NSIBPM__SR_Doc__c oldSRDoc = (NSIBPM__SR_Doc__c)mapOldRecords.get(thisKey);
            system.debug(thisKey+'thisKey >>>>');             
            if(newSRDoc.NSIBPM__Doc_ID__c !=null && newSRDoc.NSIBPM__Doc_ID__c != oldSRDoc.NSIBPM__Doc_ID__c){
                if(newSRDoc.Push_to_IPMS__c){
                    system.debug('IIIInside if====');
                    AttIds.add(newSRDoc.NSIBPM__Doc_ID__c);             
                    SRDocNamemap.put(newSRDoc.NSIBPM__Doc_ID__c,newSRDoc.name);
                    SRDocPartyIDmap.put(newSRDoc.NSIBPM__Doc_ID__c,newSRDoc.File_Name_Prefix__c);
                }
            }
        }
        if(AttIds.size()>0){
            List<Attachment> attlist=[select id,Name,ParentId,Description from Attachment where id in:AttIds];
            system.debug('Attlist===='+attlist);
            for(Attachment att :attlist ){
                att.name= string.valueof(SRDocPartyIDmap.get(att.id)+'-'+SRDocNamemap.get(att.id)+'.'+att.name.substringAfterLast('.')).deleteWhitespace();                
            }   
            system.debug('AttlistUU===='+attlist);
            update attlist;         
        }
    }
    
    
    // TOBE Implemented
    public void executeBeforeInsertUpdateTrigger(list<sObject> newAccountsList,map<Id,sObject> mapOldRecords){ }
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){ }    
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){ }
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){ }
    //public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){ }
    public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){ }
 }