/***********************************************************************************************************************************
* Name               : TaskProcessCreation                                                                       *
* Description        : Controller class for Creating New Task for CRM Process.                                 *
* Created Date       : 02/07/2017                                                                                      *
* Created By         : Naresh                                                                                             *
* ---------------------------------------------------------------------------------------------------------------------*
* VERSION     AUTHOR               DATE            COMMENTS                                                               *
* 1.0         Naresh       02/07/2017      Initial Draft.                                                         *
* 
  *
**************************************************************************************************************************************/
public class TaskProcessCreation{
    public static Set<Id> SRId=new  Set<Id>();
    public static List<Service_Request__c> SRList=new  List<Service_Request__c>();
    public Static List<Task> TaskList =  new List<Task>();
    public Static Integer TaskCountOpen ;
     public Static Integer TaskCount ;
       
    
    public static void TaskCreation(Map<Id ,Task> NewTask ,Map<Id ,Task> OldTask){
        CRM_SR_Matrix__c CrmMatrix =  new CRM_SR_Matrix__c(); 
         OQOOD_FLG__c  OQOODList =  new OQOOD_FLG__c ();
         Task task1=new  Task();
        try{
            for(Task T: NewTask.values()){
              SRId.add(T.WhatId);
            }
            System.debug('Task What Id---------- '+SRId);  
                  
            
            if(!SRId.isEmpty()){
            SRList=[SELECT id,SR_Type__c ,OwnerId ,(Select WhatId, Subject, IsTask, ActivityType From ActivityHistories),(Select Id from OpenActivities),  Account__c ,Status__c,Account__r.Party_ID__c  FROM Service_Request__c WHERE Id=:SRId];
            }
            
            System.debug('SRList##############-----------  '+SRList);
            if(!SRList.isEmpty()){
                for(Service_Request__c C : SRList){
                    TaskCountOpen  = C.OpenActivities.size();
                    TaskCount = C.ActivityHistories.size() + 1 ;
                }
                
           
             OQOODList = [ Select id , 
                           Assignment_Feed_Paid__c , 
                           OQOOD_Reg_Flag__c ,
                           Party_ID__c ,
                           Registration_ID__c ,
                           Account__c
                           from OQOOD_FLG__c    where Account__c =: SRList[0].Account__c  AND Party_ID__c =:SRList[0].Account__r.Party_ID__c Order By CreatedDate DESC Limit 1 ];
                           
              
              

            System.debug('OQOODListOQOODList::::::::::: '+OQOODList);
             TaskCount = OQOODList.OQOOD_Reg_Flag__c ==  false ? TaskCount+1 : TaskCount ;
            System.debug('Task Count @ TaskProcessCreation------------------------------  '+TaskCount); 
            
            if(TaskCount < 4 ){
            CrmMatrix  = [Select Id , SR_Type__c,TASK_SEQUENCE__c ,LAST_STEP__c , EBIZ_FLG__c ,TASK_NAME__c ,TASK_OWNER__c from CRM_SR_Matrix__c where SR_Type__c =: SRList[0].SR_Type__c AND TASK_SEQUENCE__c =: TaskCount];
     
            
            
           
            System.debug('CrmMatrix-----------  '+CrmMatrix);
     
     
           if(CrmMatrix.EBIZ_FLG__c ==  false && TaskCount == 3 ){
             System.debug('CrmMatrix--EBIZ_FLG__c False---------  '+CrmMatrix);  
                
                task1.Subject=CrmMatrix.TASK_NAME__c;
                task1.Priority='High';
                task1.WhatId=SRList[0].Id ;
                task1.Status='Not Started';
                task1.OwnerId = SRList[0].OwnerId ;
                task1.ActivityDate=Date.Today()+15;
                insert task1 ;
              }
    
        if(CrmMatrix.EBIZ_FLG__c ==  true &&  TaskCount == 2){
               
            User userID  = [select id , Name , Profile.Name  from user where Profile.Name Like 'Finance Team%' and IsActive = true and Name = 'Finance User' limit 1];
              
                System.debug('CrmMatrix--EBIZ_FLG__c True---------  '+CrmMatrix);             
               
                Task task2=new  Task();
                task2.Subject=CrmMatrix.TASK_NAME__c;
                task2.Priority='IPMS High';
                task2.WhatId=SRList[0].Id ;
                task2.Status='Not Started';
                task2.OwnerId = userID.Id ;
                task2.ActivityDate=Date.Today()+15;
                insert task2 ;
          }
          
          
          }
           Task TasComplete = [select id  , Status from Task Where WhatId =: SRList[0].Id    AND Subject= 'Inform Customer on Approval' AND Status = 'Completed' limit 1]; 
           
           System.debug('Test------------------------------------ '+TasComplete );
          
          if(TasComplete != null){
             SRList[0].Status__c = 'Closed';
          }
          update SRList[0] ;
          
          
      }  }
    
       catch(Exception Ex){
            System.debug('Error @Line Number------------ '+Ex.getLineNumber());
            System.debug('ErrorgetMessage Number------------ '+Ex.getMessage());
            Log__c logs=new  Log__c();
            logs.Type__c='Task insert is Failed';
            logs.Description__c = 'Class -TaskProcessCreation @Line'+Ex.getLineNumber() +' '+'Error Message : '+Ex.getMessage();
            Insert logs;
        }
    }
    
}