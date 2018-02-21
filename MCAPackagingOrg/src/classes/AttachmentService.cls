/* 
 *  Apex Service class of trigger handler
 *  Revision History:service class which delete the Stip Attachment record when attachment is deleted
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Yogesh Mahajan         23-02-2016           Initial Draft
 *  1.1               Yogesh Mahajan         24-02-2016           To delete Attachment and 
                                                                  Stip Attachment when Stips deleted 
                                                                  and delete Attachment when 
                                                                  stip  attachment is deleted
 *  1.2               Yogesh Mahajan         29-03-2016           Added new method to update 
                                                                  submission
*   1.3               Yogesh Mahajan         14-04-2016           Check for funder Criteria
                                                                  while updating submission

 */
public with sharing class AttachmentService {
    
    public AttachmentService() {}
    
    //delete stips Attachment Record when attachment is deleted
    public void deleteStipAttachment(Set<Id> listAttachmentIds) {
        System.debug('>>>>listAttachmentIds>>>'+listAttachmentIds);
        
        //list to delete stip Attachment
        List<Stips_Attachment__c> listStipAttachToDelete =[Select Id
                                                                , Name
                                                                , Attachment_ID__c
                                                                , Stips__c
                                                             FROM Stips_Attachment__c
                                                            WHERE Attachment_ID__c IN :listAttachmentIds
                                                               OR Attachment_ID__c = null
        ];
        
        
        //Delete List of Stip Attachment 
        try {
            if(!listStipAttachToDelete.isEmpty()) {
                delete listStipAttachToDelete;
            }
        } catch(Exception ex) {
            System.debug('---Catch Error--->'+ex.getmessage());
        }
    }
    
    //Delete Attachment When Stip Attachment is Deleted
    public void deleteAttatchments(List<Stips_Attachment__c> listStipAttachment) {
        List<Stips_Attachment__c> listExistingStipAttach =[Select Id
                                                        , Name
                                                        , Attachment_ID__c
                                                        , Stips__c
                                                     FROM Stips_Attachment__c
                                                     ];
        
        //Set to hold id of existing attachment Ids
        Set<Id> setOfAttachId = new Set<Id>();
        for(Stips_Attachment__c objStipAttachment :listExistingStipAttach) {
            setOfAttachId.add(objStipAttachment.Attachment_ID__c);
        }
        
        //Set to hold id of attachment Ids to be delete
        Set<Id> setOfDeleteAttachId = new Set<Id>();
        for(Stips_Attachment__c objStipAttachment :listStipAttachment) {
            if(!setOfAttachId.contains(objStipAttachment.Attachment_ID__c)) {
                setOfDeleteAttachId.add(objStipAttachment.Attachment_ID__c);
            }
        }
        
        List<Attachment> listAttachmentToDelete = [Select ParentId
                                                        , Name
                                                        , Id
                                                        , Body
                                                     From Attachment
                                                     Where Id IN :setOfDeleteAttachId
        ];
        
        //Delete List Of Attachment
        try {
            if(!listAttachmentToDelete.isEmpty()) {
                delete listAttachmentToDelete;
            }
        } catch(Exception ex) {
            System.debug('---Catch Error--->'+ex.getmessage());
        }
    }
    
    //Delete Stip Attachments when Stips is Deleted
    public void deleteStipAttachmentAndAttachment(Set<Id> setStipsId) {
        List<Stips_Attachment__c> listStipAttachToDelete =[Select Id
                                                                , Name
                                                                , Attachment_ID__c
                                                                , Stips__c
                                                             From Stips_Attachment__c
                                                            Where Stips__c IN :setStipsId
        ];
        
        //Delete List Of Stips Attachment
        try {
            if(!listStipAttachToDelete.isEmpty()) {
                delete listStipAttachToDelete;
            }
        } catch(Exception ex) {
            System.debug('---Catch Error--->'+ex.getmessage());
        }
    }
    
    
    
    //If attachment is deleted then remove Id from Field Selected Attachmnet from Submission
    public void updateSubmission(set<Id> setAttachmentIds) {
        //set<String> setAttachmentIds = new set<String>();
        
        //To store Attachment Id into string and check length of Attachment Ids
        /*for(Id objAttchId :setAttacIds) {
            if(String.ValueOf(objAttchId).length() == 18) {
                String str = String.ValueOf(objAttchId).left(15);
                setAttachmentIds.add(str);
            } else {
                setAttachmentIds.add(objAttchId);
            }
        }*/
        
        List<RecordType> lstRecordType =[Select Name
                                              , Id
                                           From RecordType Where Name='Bank'];
        
        Set<Submission__c> setSubmissionToUpdate = new Set<Submission__c>();
        List<Submission__c> lstSubmission = [Select Id
                                                  , Name
                                                  , Funder__c
                                                  , Funder__r.RecordTypeId
                                                  , Selected_Attachment_Id__c
                                               From Submission__c 
                                               Where Funder__r.RecordTypeId IN :lstRecordType OR
                                                     Funder__r.RecordTypeId = null
                                               limit 5000];
        
        //Itterate over Submission and Attachment Ids to compair Ids and Remove From Submission field
        for(Submission__c objSub :lstSubmission) {
            for(String objStr :setAttachmentIds) {
                String strToRemoveAttchId;
                //if(objSub.Funder__r.RecordTypeId =='0129000000119EqAAI') {
                    if(objSub.Selected_Attachment_Id__c != null ) {
                        System.debug('---Into 1st if');
                        if(objStr.containsAny(objSub.Selected_Attachment_Id__c)) {
                            
                            //If Id Found at start of the submission field
                            if(objSub.Selected_Attachment_Id__c.startsWith(objStr)) {
                                if(objSub.Selected_Attachment_Id__c.contains(',')) 
                                    strToRemoveAttchId = objSub.Selected_Attachment_Id__c.remove(objStr+',');
                                else
                                strToRemoveAttchId = '';
                            } else {
                                strToRemoveAttchId = objSub.Selected_Attachment_Id__c.remove(','+objStr);
                            }
                        objSub.Selected_Attachment_Id__c = strToRemoveAttchId;
                        setSubmissionToUpdate.add(objSub);
                        }
                    }
                //}
            }
        }
        List<Submission__c> lstSubmissionToUpdate = new List<Submission__c>();
        lstSubmissionToUpdate.addAll(setSubmissionToUpdate);
        try {
            if(!lstSubmissionToUpdate.isEmpty()) {
                System.debug('---lstSubmissionToUpdate-->'+lstSubmissionToUpdate);
                update lstSubmissionToUpdate;
            }
        } catch(Exception ex) {
            System.debug('---Catch Error--->'+ex.getmessage());
        }
        
    }
}