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
*   2.0               Ajinkya Hingne         22-06-2017           Removed reference for Stip Attachment object
 */
public with sharing class AttachmentService {

    public AttachmentService() {}

    /**
     * Remove the attachment Id from Stip Object record
     */
/*    public void updateStips(Set<Id> attachmentIDs) {
        Set<String> attachmentIdSet = new Set<String>();
        for(String attachId : attachmentIDs) {
            attachmentIdSet.add('%'+attachId.right(5)+'%');
        }
        //list to delete stip Attachment
        List<Stips__c> stips =[Select Id
                                    , Name
                                    , Attachments_IDs__c
                                 FROM Stips__c];
        for(Stips__c stip : stips) {
            for(String attachmntId : attachmentIDs) {
                String strToRemoveAttchId,strToRemoveIndexAttchId;
                if(stip.Attachments_IDs__c != null ) {
                    if(attachmntId.containsAny(stip.Attachments_IDs__c)) {
                        //If Id Found at start of the Stips attachment field
                        if(stip.Attachments_IDs__c.startsWith(attachmntId)) {
                            if(stip.Attachments_IDs__c.contains(',')) {
                                strToRemoveAttchId = stip.Attachments_IDs__c.remove(attachmntId+',');
                            } else {
                                strToRemoveAttchId = '';
                                strToRemoveIndexAttchId= '';
                            }
                        } else {
                            strToRemoveAttchId = stip.Attachments_IDs__c.remove(','+attachmntId);
                        }
                        stip.Attachments_IDs__c = strToRemoveAttchId;
                    }
                }
            }
        }
        //update List of Stip Attachment 
        update stips;
    }
*/
    //If attachment is deleted then remove Id from Field Selected Attachmnet from Submission
    public void updateSubmission(set<Id> setAttachmentIds) {
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
                                               Where (Funder__r.RecordTypeId IN :lstRecordType OR
                                                     Funder__r.RecordTypeId = null)
                                               limit 5000];
        
        //Itterate over Submission and Attachment Ids to compair Ids and Remove From Submission field
        for(Submission__c objSub :lstSubmission) {
            for(String objStr :setAttachmentIds) {
                String strToRemoveAttchId;
                if(objSub.Selected_Attachment_Id__c != null ) {
                    if(objStr.containsAny(objSub.Selected_Attachment_Id__c)) {
                        //If Id Found at start of the submission field
                        if(objSub.Selected_Attachment_Id__c.startsWith(objStr)) {
                            if(objSub.Selected_Attachment_Id__c.contains(',')) { 
                                strToRemoveAttchId = objSub.Selected_Attachment_Id__c.remove(objStr+',');
                            } else {
                                strToRemoveAttchId = '';
                            }
                        } else {
                            strToRemoveAttchId = objSub.Selected_Attachment_Id__c.remove(','+objStr);
                        }
                        objSub.Selected_Attachment_Id__c = strToRemoveAttchId;
                        setSubmissionToUpdate.add(objSub);
                    }
                }
            }
        }
        List<Submission__c> lstSubmissionToUpdate = new List<Submission__c>();
        lstSubmissionToUpdate.addAll(setSubmissionToUpdate);
        try {
            if(!lstSubmissionToUpdate.isEmpty()) {
                update lstSubmissionToUpdate;
            }
        } catch(Exception ex) {
            System.debug('---Catch Error--->'+ex.getmessage());
        }
        
    }
}