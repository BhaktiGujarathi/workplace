/***********************************************************************************************************************************
* Name:              : SRMatrixController*
* Description        :          *
* Created Date       : 21/07/2017*
* Created By         : Naresh          *
* ---------------------------------------------------------------------------------------------------------------------*
* VERSION     AUTHORDATE            COMMENTS          *
* 1.0         Naresh       02/07/2017      Initial Draft.          *
* 
  *
**************************************************************************************************************************************/

public class SRMatrixController{
public String currentRecordId {get;set;}
public Integer TaskCount ;
public Integer TaskCountActivity ;

 
    public SRMatrixController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
       
    }
    
      public PageReference caseEscalation() {
      
      
      Service_Request__c SRList = [select id , Status__c ,SR_Type__c, (Select Id from OpenActivities),(Select Id From ActivityHistories),OwnerId from Service_Request__c Where Id =:currentRecordId];
      TaskCount = SRList.OpenActivities.size();
      TaskCountActivity =  SRList.ActivityHistories.size();
      System.debug('Task-----------------------  '+TaskCount);
      CRM_SR_Matrix__c CrmMatrix  = [Select Id ,LAST_STEP__c , SR_Type__c, TASK_NAME__c ,TASK_OWNER__c from CRM_SR_Matrix__c where SR_Type__c =: SRList.SR_Type__c  AND TASK_SEQUENCE__c = 1 limit  1];
        
        if(TaskCount == 0 && TaskCountActivity == 0   &&CrmMatrix.LAST_STEP__c == false){
                Task task=new  Task();
                task.Subject=CrmMatrix.TASK_NAME__c ;
                task.Priority='High';
                task.WhatId=currentRecordId ;
                task.Status='Not Started';
                task.OwnerId = SRList.OwnerId;
                task.ActivityDate=Date.Today()+15;
                insert task ;
                
               SRList.Status__c  = 'Submitted' ;
               
               update SRList ;
                
        }
      PageReference pageRef = new PageReference('/'+currentRecordId);
      pageRef.setRedirect(true);
      return pageRef; 
     
    }
}