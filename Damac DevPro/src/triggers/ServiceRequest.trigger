trigger ServiceRequest on Service_Request__c (before Insert , after update) {

 ServiceRequestTriggerHandler obj =  new ServiceRequestTriggerHandler();

   if(Trigger.isBefore){
   
      if(Trigger.isInsert){
      
       obj.BeforeInsert(Trigger.new);
      }
       
   }
   
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            system.debug('Update event found.');
            //TestApexApproval.sendForApproval(trigger.new);
            List<Service_Request__c>  SRList  =  new  List<Service_Request__c>();
            for(Service_Request__c  Sr :  Trigger.new){
                if(Sr.Status__c == 'Closed'){
                    SRList.add(Sr);
                }
            }
            if(!SRList.isEmpty()){
                SRstatusUpdate.SrStatus(Trigger.newMap , Trigger.OldMap);
            }
        }
    }

}