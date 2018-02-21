/* 
 *  Apex Test Class
 * 
 *  Version           Author                 Date                 Description 
 *  1.0               Yogesh Mahajan         23-02-2016           Initial Draft 
 */
 @isTest
public with sharing class AttachmentServiceTest {
    
    //test to delete stip attachment when attachment is deleted
    static testMethod void deleteStipAttachmentTest() {
        List<Opportunity> lstOpp = TestDataUtility.getOpportunityRecords(1);
        insert lstOpp;
        System.assertNotEquals(null, lstOpp[0].Id);
        
        List<Attachment> lstAttachment = new List<Attachment>();
        for(Attachment objAttach :TestDataUtility.getattachmentRecords(3)) {
            objAttach.ParentId = lstOpp[0].Id;
            lstAttachment.add(objAttach);
        }
        insert lstAttachment;
        System.assertNotEquals(null, lstAttachment[0].Id);
        
        Stips__c ObjStips = new Stips__c();
        ObjStips.Name = 'Test Stips';
        ObjStips.Opportunity__c = lstOpp[0].Id;
        insert ObjStips;
        System.assertNotEquals(null, ObjStips.Id);
        
        Stips_Attachment__c objStipAttachment = new Stips_Attachment__c();
        objStipAttachment.Stips__c = objStips.Id;
        objStipAttachment.Attachment_ID__c = lstAttachment[0].Id;
        insert objStipAttachment;
        System.assertNotEquals(null, objStipAttachment.Id);
        
        delete lstAttachment[0];
        List<Stips_Attachment__c> lstStipsAttach =[Select Id
                                                        , Attachment_ID__c
                                                     From Stips_Attachment__c 
                                                    Where Attachment_ID__c = :lstAttachment[0].Id];
                      
        //System.assertEquals('', lstStipsAttach);
    }
    
    //valid Test to delete Attachment when stip attachment is deleted
    static testMethod void deleteAttachmentValidTest() {
        List<Opportunity> lstOpp = TestDataUtility.getOpportunityRecords(1);
        insert lstOpp;
        System.assertNotEquals(null, lstOpp[0].Id);
        
        List<Attachment> lstAttachment = new List<Attachment>();
        for(Attachment objAttach :TestDataUtility.getattachmentRecords(3)) {
            objAttach.ParentId = lstOpp[0].Id;
            lstAttachment.add(objAttach);
        }
        insert lstAttachment;
        System.assertNotEquals(null, lstAttachment[0].Id);
        
        Stips__c ObjStips = new Stips__c();
        ObjStips.Name = 'Test Stips';
        ObjStips.Opportunity__c = lstOpp[0].Id;
        insert ObjStips;
        System.assertNotEquals(null, ObjStips.Id);
        
        Stips_Attachment__c objStipAttachment = new Stips_Attachment__c();
        objStipAttachment.Attachment_ID__c = lstAttachment[0].Id;
        objStipAttachment.Stips__c = objStips.Id;
        insert objStipAttachment;
        System.assertNotEquals(null, objStipAttachment.Id);
        
        delete objStipAttachment;
    }
    
    //Invalid Test to delete Attachment when stip attachment is deleted
    static testMethod void deleteAttachmentInValidTest() {
        List<Opportunity> lstOpp = TestDataUtility.getOpportunityRecords(1);
        insert lstOpp;
        System.assertNotEquals(null, lstOpp[0].Id);
        
        List<Attachment> lstAttachment = new List<Attachment>();
        for(Attachment objAttach :TestDataUtility.getattachmentRecords(3)) {
            objAttach.ParentId = lstOpp[0].Id;
            lstAttachment.add(objAttach);
        }
        insert lstAttachment;
        System.assertNotEquals(null, lstAttachment[0].Id);
        
        Stips__c ObjStips = new Stips__c();
        ObjStips.Name = 'Test Stips';
        ObjStips.Opportunity__c = lstOpp[0].Id;
        insert ObjStips;
        System.assertNotEquals(null, ObjStips.Id);
        
        Stips_Attachment__c objStipAttachment = new Stips_Attachment__c();
        objStipAttachment.Attachment_ID__c = lstAttachment[0].Id;
        objStipAttachment.Stips__c = ObjStips.Id;
        insert objStipAttachment;
        System.assertNotEquals(null, objStipAttachment.Id);
        
        delete objStipAttachment;
    }
    
    //Test to delete stip attachment and Related attachment when stip is deleted
    static testMethod void deleteStipAttachAndAttachmentTest() {
        List<Opportunity> lstOpp = TestDataUtility.getOpportunityRecords(1);
        insert lstOpp;
        System.assertNotEquals(null, lstOpp[0].Id);
        
        List<Attachment> lstAttachment = new List<Attachment>();
        for(Attachment objAttach :TestDataUtility.getattachmentRecords(3)) {
            objAttach.ParentId = lstOpp[0].Id;
            lstAttachment.add(objAttach);
        }
        insert lstAttachment;
        System.assertNotEquals(null, lstAttachment[0].Id);
        
        Stips__c ObjStips = new Stips__c();
        ObjStips.Name = 'Test Stips';
        ObjStips.Opportunity__c = lstOpp[0].Id;
        insert ObjStips;
        System.assertNotEquals(null, ObjStips.Id);
        
        Stips_Attachment__c objStipAttachment = new Stips_Attachment__c();
        objStipAttachment.Attachment_ID__c = lstAttachment[0].Id;
        objStipAttachment.Stips__c = ObjStips.Id;
        insert objStipAttachment;
        System.assertNotEquals(null, objStipAttachment.Id);
        
        delete lstAttachment;
    }
    
    //test to delete Stips Attachment when Stips is Deleted
    static testMethod void deleteStipsTest() {
        List<Opportunity> lstOpp = TestDataUtility.getOpportunityRecords(1);
        insert lstOpp;
        System.assertNotEquals(null, lstOpp[0].Id);
        
        Stips__c ObjStips = new Stips__c();
        ObjStips.Name = 'Test Stips';
        ObjStips.Opportunity__c = lstOpp[0].Id;
        insert ObjStips;
        System.assertNotEquals(null, ObjStips.Id);
        
        Stips_Attachment__c objStipAttachment = new Stips_Attachment__c();
        objStipAttachment.Stips__c = ObjStips.Id;
        insert objStipAttachment;
        System.assertNotEquals(null, objStipAttachment.Id);
        
        delete objStips;
    }
    //Test to delete stip attachment and Related attachment when stip is deleted
    static testMethod void updateSubmissionsFromAttachmentTest() {
        List<Opportunity> lstOpp = TestDataUtility.getOpportunityRecords(3);
        insert lstOpp;
        System.assertNotEquals(null, lstOpp[0].Id);
        
        List<Attachment> lstAttachment = new List<Attachment>();
        for(Attachment objAttach :TestDataUtility.getattachmentRecords(3)) {
            objAttach.ParentId = lstOpp[0].Id;
            lstAttachment.add(objAttach);
        }
        insert lstAttachment;
        System.assertNotEquals(null, lstAttachment[0].Id);
        
        List<Submission__c> lstSubmission = TestDataUtility.getSubmissionRecords(5, lstOpp[0].Id);
        lstSubmission[0].Selected_Attachment_Id__c = lstAttachment[0].Id+','+lstAttachment[1].Id+','+lstAttachment[2].Id;
        lstSubmission[1].Selected_Attachment_Id__c = lstAttachment[0].Id;
        lstSubmission[2].Selected_Attachment_Id__c = lstAttachment[1].Id+','+lstAttachment[1].Id+','+lstAttachment[0].Id;
        lstSubmission[3].Selected_Attachment_Id__c = lstAttachment[1].Id+','+lstAttachment[0].Id+','+lstAttachment[2].Id;
        /*for(Submission__c objSubmission :TestDataUtility.getSubmissionRecords(5, lstOpp[0].Id)) {
            objSubmission.Selected_Attachment_Id__c =  lstAttachment[0].Id+','+lstAttachment[1].Id+','+lstAttachment[2].Id;
            lstSubmission.add(objSubmission);
        }*/
        insert lstSubmission;
        delete lstAttachment[0];
        
        
    }
}