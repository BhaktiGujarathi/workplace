global without sharing class CC_Create_LoopTask implements NSIBPM.LoopTaskCreateable{
    global string GenerateLoopTask(list<NSIBPM__Step__c> lstExistingSteps,map<string,Id> mapStepQueues,map<Id,string> mapStepTemplateQueues,map<Id,string> mapSRStepQueues,map<Id,string> mapSRTemplateQueues,map<id,id> mapSROwner,
    map<id,string> mapUserLicense,map<string,Id> mapStepRecType,list<NSIBPM__SR_Steps__c> lstSRSteps,NSIBPM__Action__c action,NSIBPM__Step__c stp){
        string strResult = 'Success';
        System.debug('mapStepQueues-----------'+mapStepQueues);
        System.debug('stp-----------'+stp);
        System.debug('stp-----------'+lstSRSteps);
        System.debug('stp-----------'+lstExistingSteps);
        NSIBPM__Step__c insStp = new NSIBPM__Step__c();
        string queueName='';
        string SROwnerId = null;
        integer maxLoopStepNo = 0;
        integer LoopStepNo;
        list<Messaging.SingleEmailMessage> insertMailList = new list<Messaging.SingleEmailMessage>();
        map<id, list<Messaging.SingleEmailMessage>> mailIdMap = new  map<id, list<Messaging.SingleEmailMessage>>();
        list<User> usrList = new list<User>();
        NSIBPM__SR_Steps__c CurrentSRStep = new NSIBPM__SR_Steps__c();
        for(NSIBPM__SR_Steps__c srstep:lstSRSteps){
            system.debug('+++>'+srstep.NSIBPM__Step_No__c +'  '+action.NSIBPM__Field_Value__c);
            if(string.valueOf(srstep.NSIBPM__Step_No__c)==action.NSIBPM__Field_Value__c){
                CurrentSRStep = srstep;
                break;
            }
        }
        list<EmailTemplate> ETLst = [select id, name from EmailTemplate where developername = 'Notify_Step'];
        usrList = [SELECT id,IsActive,ContactId,Contact.AccountId FROM User WHERE Contact.AccountId = :stp.NSIBPM__SR__r.NSIBPM__Customer__c AND IsActive=true and Contact.Email!=null];
        if(CurrentSRStep!=null && CurrentSRStep.id!=null){
            insStp.NSIBPM__SR__c = stp.NSIBPM__SR__c;
            insStp.NSIBPM__Step_Template__c = CurrentSRStep.NSIBPM__Step_Template__c;
            insStp.NSIBPM__Status__c = CurrentSRStep.NSIBPM__Start_Status__c;
            insStp.NSIBPM__SR_Step__c = CurrentSRStep.id; 
            for(NSIBPM__Step__c objstep : lstExistingSteps){
                //if(objstep.NSIBPM__Sys_Step_Loop_No__c!=null && objstep.NSIBPM__SR_Step__c == CurrentSRStep.id){
                if(objstep.NSIBPM__Sys_Step_Loop_No__c!=null){
                    LoopStepNo = integer.valueOf(objstep.NSIBPM__Sys_Step_Loop_No__c.substringAfter('_'));
                    if(maxLoopStepNo < LoopStepNo){
                        maxLoopStepNo = LoopStepNo;
                    } 
                }
            }
            if(CurrentSRStep.NSIBPM__Do_not_use_owner__c==false){
               if(string.valueOf(CurrentSRStep.OwnerId).startsWith('005')){
                     insStp.OwnerId = CurrentSRStep.OwnerId;
               }else{
                   if(mapSRStepQueues.containsKey(CurrentSRStep.OwnerId)){
                        queueName = mapSRStepQueues.get(CurrentSRStep.OwnerId);
                   }
                   if(queueName.contains('Client')){
                       insStp.NSIBPM__Step_Notes__c = stp.NSIBPM__Step_Notes__c;
                       insStp.OwnerId = mapStepQueues.get(queueName); 
                       if(stp.NSIBPM__SR__c!=null && stp.NSIBPM__SR__r.NSIBPM__Ultimate_SR_Menu_Text__c!=null && stp.NSIBPM__SR__r.NSIBPM__Ultimate_SR_Menu_Text__c!=''){  
                            //mailIdMap = mailListPrepareEmails(usrList,stp.NSIBPM__SR_Step__c,stp.SR__r.NSIBPM__Ultimate_SR_Menu_Text__c,ETLst,queueName);
                       }  
                   }else if(mapStepQueues.containsKey(queueName)){
                          insStp.OwnerId = mapStepQueues.get(queueName);
                   }
               } 
               
               //Modified by vikas
               //Making the Exception step approver as owner to the DSR step
               if(CurrentSRStep.NSIBPM__Step_No__c == 30.0 && string.valueOf(stp.OwnerId).startsWith('005')){
                   insStp.OwnerId = stp.OwnerId;
               }
                    
            }else if(CurrentSRStep.NSIBPM__SR_Template__c!=null && CurrentSRStep.NSIBPM__SR_Template__r.NSIBPM__Do_not_use_owner__c==false){
               if(string.valueOf(CurrentSRStep.NSIBPM__SR_Template__r.OwnerId).startsWith('005')){
                    insStp.OwnerId = CurrentSRStep.NSIBPM__SR_Template__r.OwnerId;
               }else{
                    if(mapSRTemplateQueues.containsKey(CurrentSRStep.OwnerId)){
                        queueName = mapSRTemplateQueues.get(CurrentSRStep.OwnerId);
                    }
                    if(queueName.contains('Client')){
                       insStp.NSIBPM__Step_Notes__c = stp.NSIBPM__Step_Notes__c;
                       insStp.OwnerId = mapStepQueues.get(queueName);  
                       if(stp.NSIBPM__SR__c!=null && stp.NSIBPM__SR__r.NSIBPM__Ultimate_SR_Menu_Text__c!=null && stp.NSIBPM__SR__r.NSIBPM__Ultimate_SR_Menu_Text__c!=''){   
                            //mailIdMap = mailListPrepareEmails(usrList,stp.NSIBPM__SR_Step__c,stp.SR__r.NSIBPM__Ultimate_SR_Menu_Text__c,ETLst,queueName); 
                       } 
                    }else 
                    if(mapStepQueues.containsKey(queueName)){
                        insStp.OwnerId = mapStepQueues.get(queueName);
                    }
               }     
            }else if(CurrentSRStep.NSIBPM__Step_Template__c!=null){
                if(string.valueOf(CurrentSRStep.NSIBPM__Step_Template__r.OwnerId).startsWith('005')){
                   insStp.OwnerId = CurrentSRStep.NSIBPM__Step_Template__r.OwnerId;
                }else{
                   if(mapStepTemplateQueues.containsKey(CurrentSRStep.OwnerId)){
                      queueName = mapStepTemplateQueues.get(CurrentSRStep.OwnerId);
                   }
                   if(queueName.contains('Client')){
                       insStp.NSIBPM__Step_Notes__c = stp.NSIBPM__Step_Notes__c;
                       insStp.OwnerId = mapStepQueues.get(queueName);   
                       if(stp.NSIBPM__SR__c!=null && stp.NSIBPM__SR__r.NSIBPM__Ultimate_SR_Menu_Text__c!=null && stp.NSIBPM__SR__r.NSIBPM__Ultimate_SR_Menu_Text__c!=''){  
                            //mailIdMap = mailListPrepareEmails(usrList,stp.NSIBPM__SR_Step__c,stp.SR__r.NSIBPM__Ultimate_SR_Menu_Text__c,ETLst,queueName);  
                       }        
                    }else
                    if(mapStepQueues.containsKey(queueName)){
                        insStp.OwnerId = mapStepQueues.get(queueName);
                    }
                }     
            }
            if(CurrentSRStep.NSIBPM__Step_RecordType_API_Name__c!=null){
                if(mapStepRecType.get(CurrentSRStep.NSIBPM__Step_RecordType_API_Name__c)!=null)
                    insStp.RecordTypeId = mapStepRecType.get(CurrentSRStep.NSIBPM__Step_RecordType_API_Name__c);
            }else{
                if(CurrentSRStep.NSIBPM__Step_Template__c!=null && CurrentSRStep.NSIBPM__Step_Template__r.NSIBPM__Step_RecordType_API_Name__c!=null && mapStepRecType.get(CurrentSRStep.NSIBPM__Step_Template__r.NSIBPM__Step_RecordType_API_Name__c)!=null){
                    insStp.RecordTypeId = mapStepRecType.get(CurrentSRStep.NSIBPM__Step_Template__r.NSIBPM__Step_RecordType_API_Name__c);
                }
            }
            insStp.NSIBPM__Start_Date__c = system.today();
            insStp.NSIBPM__Summary__c = CurrentSRStep.NSIBPM__Summary__c;
            insStp.NSIBPM__Step_Notes__c = stp.NSIBPM__Step_Notes__c;
            insStp.NSIBPM__Step_No__c = CurrentSRStep.NSIBPM__Step_No__c;
            
            // Keeping the same loop level for pending tasks
            if(CurrentSRStep.NSIBPM__Step_No__c != 70.0 && CurrentSRStep.NSIBPM__Step_No__c != 71.0 && CurrentSRStep.NSIBPM__Step_No__c != 72.0 && CurrentSRStep.NSIBPM__Step_No__c != 73.0 && CurrentSRStep.NSIBPM__Step_No__c != 74.0)
                maxLoopStepNo = maxLoopStepNo+1;
            
            // keeping the invoking steps as parent to the pending loop tasks
            if(CurrentSRStep.NSIBPM__Step_No__c == 70.0 || CurrentSRStep.NSIBPM__Step_No__c == 71.0 || CurrentSRStep.NSIBPM__Step_No__c == 72.0 || CurrentSRStep.NSIBPM__Step_No__c == 73.0 || CurrentSRStep.NSIBPM__Step_No__c == 74.0) 
                insStp.NSIBPM__Parent_Step__c = stp.Id;
                
            insStp.NSIBPM__Sys_Step_Loop_No__c = string.valueOf(insStp.NSIBPM__Step_No__c)+'_'+maxLoopStepNo;
            ID BHId = id.valueOf(Label.NSIBPM.Business_Hours_Id);
            if(CurrentSRStep.NSIBPM__Estimated_Hours__c!=null){
                Long sla = CurrentSRStep.NSIBPM__Estimated_Hours__c.longvalue();
                sla=sla*60*60*1000L;
                datetime CreatedTime = system.now();
                //datetime CreatedDate = system.today();
                insStp.NSIBPM__Due_Date__c=BusinessHours.add(BHId,CreatedTime,sla);
            }
            try{
                insert insStp;
                list<Messaging.SingleEmailMessage> mailList = new list<Messaging.SingleEmailMessage>();
                if(mailIdMap.containsKey(insStp.NSIBPM__SR_Step__c)){
                    mailList = mailIdMap.get(insStp.NSIBPM__SR_Step__c);
                    for(Messaging.SingleEmailMessage email: mailList){
                        email.setWhatId(insStp.Id);
                        insertMailList.add(email);
                    }       
                }
                if(insertMailList!=null && insertMailList.size() > 0){
                    Messaging.sendEmail(insertMailList);
                }
            }catch(Exception e){
                strResult = string.valueOf(e.getMessage());
                throw new NSIBPM.CommonCustomException(string.valueOf(e.getMessage()));
            }
        }
        return strResult;
    }
}