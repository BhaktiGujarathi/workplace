/**************************************************************************************************
* Name               : AttachmentTriggerHandler                                                   *
* Description        : This is helper class for trigger on Attachment object.                     *
* Created Date       : NSI                                                                        *
* Created By         : 24/04/2017                                                                 *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR        DATE        COMMENTS                                                  *
* 1.0         NSI - Vineet  24/04/2017  Initial Draft.                                            *
**************************************************************************************************/
public class AttachmentTriggerHandler extends Describe_Sobject_Access implements TriggerFactoryInterface{
    
    @Testvisible private Set<String> allowedExtensionSet = new Set<String>{'doc', 'docx', 'pdf', 'png', 'jpg', 'jpeg'};
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before insert.                       *
    * @Params      : List<sObject>                                                               *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeInsertTrigger(List<sObject> newRecordsList){
        DAMAC_Constants.skip_AttacmentTrigger = true;
        checkAttachmentType((List<Attachment>) newRecordsList); 
    }
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed before udpate.                       *
    * @Params      : Map<Id, sObject>, Map<Id, sObject>                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){
        preventUsersToEditDeleteAttachment((List<Attachment>) mapNewRecords.values());
        checkAttachmentType((List<Attachment>) mapNewRecords.values()); 
    }
    
    /*********************************************************************************************
    * @Description : Method to contain logic to be executed after insert.                        *
    * @Params      : Map<Id, sObject>                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords){
        updateAnnouncementRequests((List<Attachment>) mapNewRecords.values());  
    }
    
    /*********************************************************************************************
    * @Description : Method to check the attachment type.                                        *
    *                - Only DOC, DOCX, PDF, PNG, JPEG, JPG format allowed.                       * 
    * @Params      : List<Attachment>                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @Testvisible private void checkAttachmentType(List<Attachment> newAttachmentList){
        try{
            for(Attachment thisAttachment : newAttachmentList){
                system.debug('#### thisAttachment = '+thisAttachment);
                // system.debug('----thisAttachment.Name--'+thisAttachment.Name+'----'+thisAttachment.Name.subString(thisAttachment.Name.length()-3));
                //if(thisAttachment.Body != null && thisAttachment.Name != null &&  
                 //  thisAttachment.Name.containsIgnoreCase('.') && !allowedExtensionSet.contains(thisAttachment.Name.subStringAfter('.').toLowerCase()))
                   if(thisAttachment.Body != null 
                   && thisAttachment.Name != null 
                   && thisAttachment.Name.containsIgnoreCase('.') 
                   && !allowedExtensionSet.contains(thisAttachment.Name.subString(thisAttachment.Name.length()-3))){
                    
                    
                    thisAttachment.addError('Please enter a valid file format. Only DOC, DOCX, PDF, PNG, JPEG, JPG format allowed.');
                }
            }
        }catch(Exception ex){
            system.debug('#### Exception at line = '+ex.getLineNumber()+' , exception message = '+ex.getMessage());
        }
    }
    
    /*********************************************************************************************
    * @Description : Method to update announcement headers.                                      *
    * @Params      : List<Attachment>                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    @Testvisible private void updateAnnouncementRequests(List<Attachment> newAttachmentList){
        String reqPrefix = Announcement_Request__c.sobjecttype.getDescribe().getKeyPrefix();
        List<Announcement_Request__c> updateAnnouncementRequestList = new List<Announcement_Request__c>();
        for(Attachment attObj: newAttachmentList){
            if(string.valueof(attObj.parentId).startswith(reqPrefix)){
                if(!attObj.Name.contains('Announcement')){
                    Announcement_Request__c ar = new Announcement_Request__c(Id = attObj.parentId, Header_Logo__c='<img src="'+System.Label.AnnouncementURL+'/servlet/servlet.FileDownload?file='+attObj.Id+'"></img>');
                    updateAnnouncementRequestList.add(ar);
                }
                if(attObj.Name.contains('Announcement')){
                    Announcement_Request__c ar = new Announcement_Request__c(Id = attObj.parentId, Announcement_URL__c=System.Label.AnnouncementURL+'/servlet/servlet.FileDownload?file='+attObj.Id);
                    updateAnnouncementRequestList.add(ar);
                }
            }
        }
        if(!updateAnnouncementRequestList.isEmpty()){
            update updateAnnouncementRequestList;
        }
    }
    
    // TOBE Implemented
    public void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){}
    public void executeAfterInsertUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords){}
    public void executeBeforeInsertUpdateTrigger(List<sObject> newRecordsList, Map<Id,sObject> oldRecordsMap){}
    public void executeBeforeDeleteTrigger(Map<Id,sObject> oldRecordsMap){
        preventUsersToEditDeleteAttachment((List<Attachment>) oldRecordsMap.values());
    }
    public void executeAfterDeleteTrigger(Map<Id,sObject> oldRecordsMap){}
    
    /*********************************************************************************************
    * @Description : Method to restrict the users from editing and deleting.                     *
    * @Params      : List<Attachment>                                                            *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void preventUsersToEditDeleteAttachment(List<Attachment> lstAttachments){
        System.debug('attachment triggers fired');
        if(!DAMAC_Constants.skip_AttacmentTrigger){
            sObjectName = 'att';
            getAccess();
            for(Attachment attach : lstAttachments){
                if(trigger.isUpdate && !canEditRecord)
                    attach.addError('You are not allowed to edit the attachment.');
                if(trigger.isDelete && !canDeleteRecord)
                    attach.addError('You are not allowed to delete the attachment.');
            }
        }
    }
}// End of class.