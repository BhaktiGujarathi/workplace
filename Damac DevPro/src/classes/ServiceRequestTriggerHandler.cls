/***********************************************************************************************************************************
* Name:              : ServiceRequestTriggerHandler*
* Description        : Trigger Handler Class for ServiceRequestTrigger         *
* Created Date       : 21/07/2017*
* Created By         : Naresh          *
* ---------------------------------------------------------------------------------------------------------------------*
* VERSION     AUTHORDATE            COMMENTS          *
* 1.0         Naresh       02/07/2017      Initial Draft.          *
* 
  *
**************************************************************************************************************************************/
public class ServiceRequestTriggerHandler{



  public void BeforeInsert(List<Service_Request__c> NewSR){
  
   ServiceRequestRecords.SrInsert(NewSR);
  }

}