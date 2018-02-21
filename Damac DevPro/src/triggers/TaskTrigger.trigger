/**************************************************************************************************
* Name               : TasTrigger                                                                 *
* Description        : This is a trigger on task object.                                          *
* Created Date       : 12/01/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      12/01/2017      Initial Draft                                     *
* 1.2         NSI - Sivasankar  30/03/2017      Adding the events of Trigger                      *
**************************************************************************************************/
trigger TaskTrigger on Task (before insert, after insert,before update, after update,before delete,after delete) {
    TriggerFactoryCls.createHandler(Task.sObjectType);


    /*if( Trigger.isUpdate && Trigger.isBefore){
      for( Task t : Trigger.new){
          if( t.Subject == 'Verify COCD Fee' && t.status == 'Closed' && ( String.isEmpty( t.Description ) || String.isEmpty( t.COCD_Fee_Invoice_Number__c ) ) ){
            t.addError( 'Cannot close task without adding Comments and COCD Fee Invoice Number' );
          }
      }
    }*/

    if(Trigger.isInsert && Trigger.isAfter) {
        system.debug('after insert*****************');
        TaskTriggerHandlerAssignment taskObj = new TaskTriggerHandlerAssignment();
        taskObj.checkTaskAssignedUser(trigger.new);
    }


    if(Trigger.isAfter && Trigger.isUpdate){

      //DO NOT NEED THIS LOGIC ANYMORE
      /*Set<String> taskIds = new Set<String>();
      Set<String> caseIds = new Set<String>();
      Map<Id,Task> mapCaseIdTask = new Map<Id,Task>();
      for(Task t : Trigger.new){
        if( t.Subject == 'Verify COCD Fee' && t.status == 'Closed'){
            taskIds.add(t.Id);
            caseIds.add(t.WhatId);
            mapCaseIdTask.put(t.WhatId,t);
        }
      }

      if(!taskIds.isEmpty()){

        // Query OQOOD_Admin_Fee__c and OQOOD_Units__c for all case records
        List<Case> listCase = [select Id,OQOOD_Admin_Fee__c,OQOOD_Units__c from Case where Id IN :caseIds];
        if(listCase != null && listCase.size() >0){
            List<COCDFinalUpdate.RuleEngineResponse> ruleEngineResponseList = new List<COCDFinalUpdate.RuleEngineResponse>();
            for(Case caseRecord : listCase){
                if(caseRecord.OQOOD_Admin_Fee__c != null && caseRecord.OQOOD_Admin_Fee__c != '' && caseRecord.OQOOD_Units__c != null && caseRecord.OQOOD_Units__c != ''){

                    // creating list of wrapper for regId and admin fee pair
                    List<String> adminfees = caseRecord.OQOOD_Admin_Fee__c.split(',');
                    List<String> regIds = caseRecord.OQOOD_Units__c.split(',');
                    For(Integer i = 0; i < adminfees.size() ; i++){
                        if(adminfees[i] != '' && adminfees[i] != '0' && regIds[i] != null && regIds[i] != ''){
                            COCDFinalUpdate.RuleEngineResponse ruleEngineResponse = new COCDFinalUpdate.RuleEngineResponse();
                            ruleEngineResponse.regId = regIds[i];
                            ruleEngineResponse.adminFee = adminfees[i];
                            Task taskRecord = mapCaseIdTask.get(caseRecord.Id);
                            ruleEngineResponse.UniqueTransactionNumber = taskRecord.COCD_Fee_Invoice_Number__c;
                            ruleEngineResponse.description = taskRecord.Description;
                            ruleEngineResponseList.add(ruleEngineResponse);
                        }
                    }
                    system.debug('###ruleEngineResponseList :'+ruleEngineResponseList);
                    Integer count = 0;
                    List<COCDFinalUpdate.RuleEngineResponse> ruleEngineResponseFinalList = new List<COCDFinalUpdate.RuleEngineResponse>();
                    For(COCDFinalUpdate.RuleEngineResponse ruleEngine : ruleEngineResponseList){
                        count++;
                        if(count >= 100){
                            system.debug('###calling :'+ruleEngineResponseFinalList);
                            COCDFinalUpdate.createDebitCreditMemoInIPMS(JSON.serialize(ruleEngineResponseFinalList));
                            ruleEngineResponseFinalList = new List<COCDFinalUpdate.RuleEngineResponse>();
                            count = 1;
                        }
                        ruleEngineResponseFinalList.add(ruleEngine);
                    }

                    if(ruleEngineResponseFinalList != null && ruleEngineResponseFinalList.size() > 0){
                        system.debug('###calling :'+ruleEngineResponseFinalList);
                        COCDFinalUpdate.createDebitCreditMemoInIPMS(JSON.serialize(ruleEngineResponseFinalList));
                        ruleEngineResponseFinalList = new List<COCDFinalUpdate.RuleEngineResponse>();
                    }

                }
            }
        }
        //COCDFinalUpdate.createDebitCreditMemoInIPMS( taskIds, caseIds );
      }
      */
    }
     Set<Id> TaskId  = new Set<Id>();
     Set<Id> TaskIdUpdate  = new Set<Id>();
     if(Trigger.new != null ){
      for(Task t : Trigger.new){
      if(t.Subject == 'Verify Payment Received') {
       TaskId.add(t.Id);
       }
       if(t.Subject == 'Inform Customer on Approval' && t.Status == 'Completed'){
       TaskIdUpdate.add(t.Id);
       }
       }

     }
       if(!TaskId.isEmpty()){
       if((Trigger.isAfter && Trigger.Isinsert)){
       //if(COCDControllerInterface.IsOnce == True){ // commented on 12/10/2017 by eternus
       //COCDControllerInterface.COCDWebService(TaskId);
          // }
         }
       }

         if(!TaskIdUpdate  .isEmpty()){
       if((Trigger.isAfter && Trigger.isUpdate)){
       //if(COCDControllerInterface.IsOnce == True){ // commented on 12/10/2017 by eternus
       //COCDControllerInterface.COCDWebServiceUpdate(TaskIdUpdate);
         //  }
         }
       }

       if(Trigger.isInsert && Trigger.isBefore){
           //if (!CustomerCommunityUtils.isPortalUser(UserInfo.getUserId())) {
               CreAllocationHandler.updateTaskWhoid(Trigger.new);
           //}
       }

       if(Trigger.isupdate && Trigger.isBefore){
			 CreAllocationHandler.deletetaskAccountSharing(Trigger.newMap,Trigger.oldMap);
       }


}// End of trigger