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
 */
public with sharing class AttachmentService {
    
    public AttachmentService() {}
    
    //delete stips Attachment Record when attachment is deleted
    public void deleteStipAttachment(Set<Id> listAttachmentIds) {
        
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
        if(!listStipAttachToDelete.isEmpty()) {
            delete listStipAttachToDelete;
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
        if(!listAttachmentToDelete.isEmpty()) {
            delete listAttachmentToDelete;
        }
    }
    
    //Delete Stip Attachments when Stips is Deleted
    public void deleteStipAttachmentAndAttachment(Set<Id> setStipsId) {
        List<Stips_Attachment__c> listStipAttachToDelete =[Select Id
                                                                , Name
                                                                , Attachment_ID__c
                                                                , Stips__c
                                                             FROM Stips_Attachment__c
                                                            WHERE Stips__c IN :setStipsId
        ];
        
        //Delete List Of Stips Attachment
        if(!listStipAttachToDelete.isEmpty()) {
            delete listStipAttachToDelete;
        }
    }
}