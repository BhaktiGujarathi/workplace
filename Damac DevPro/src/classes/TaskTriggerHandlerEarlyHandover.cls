public with sharing class TaskTriggerHandlerEarlyHandover {
	
	 public void taskForExternalUser(list<Task> listTask) {
        Integer counterVal;
        set<Id> setTaskCaseId = new set<Id>();
        set<Id> setTaskForCallout1 = new set<Id>();
        set<Id> setTaskForCallout2 = new set<Id>();
        set<String> setTaskForUser = new set<String>();
        system.debug('Inside handler*****');
        if(Label.UsersOutsideSalesforce != null) {
            setTaskForUser.addAll(Label.UsersOutsideSalesforce.split(','));
            system.debug('setTaskForUser==='+setTaskForUser);
            counterVal = 1;
            for(Task taskInst: listTask){
                if(taskInst.Process_Name__c != null
                && taskInst.Assigned_User__c != null
                && taskInst.WhatId != null
                && taskInst.Process_Name__c.equalsIgnoreCase('Early Handover')
                && setTaskForUser.contains(taskInst.Assigned_User__c)
                && String.valueOf(taskInst.WhatId).startsWith('500')){
                    if(counterVal <= 100) {
                        setTaskForCallout1.add(taskInst.Id);
                    }
                    else {
                        setTaskForCallout2.add(taskInst.Id);
                    }
                    setTaskCaseId.add(taskInst.WhatId);
                    counterVal++;
                }
            }
            system.debug('setTaskCaseId==='+setTaskCaseId);
            system.debug('setTaskForCallout1==='+setTaskForCallout1);
            system.debug('setTaskForCallout2==='+setTaskForCallout2);
            if(!setTaskForCallout1.isEmpty() && !setTaskCaseId.isEmpty()) {
                createTaskOnIPMS(setTaskForCallout1, setTaskCaseId);
            }
            if(!setTaskForCallout2.isEmpty() && !setTaskCaseId.isEmpty()) {
                createTaskOnIPMS(setTaskForCallout2, setTaskCaseId);
            }
        }
    }

    /*
    public map<Id, Case> getCaseDetails(set<Id> setTaskCaseId) {
        map<Id, Case> mapCaseDetails = new map<Id, Case>([select Id, Status, Buyer__r.Party_ID__c,
                            Booking_Unit__r.Registration_ID__c, CaseNumber, Relationship_with_Seller__c,
                            Case_Type__c, Buyer_Type__c, Booking_Unit__r.Unit_Details__c,
                            Booking_Unit__r.Inventory__r.Property_City__c, Buyer__r.First_Name__c,
                            Booking_Unit__r.Inventory__r.Property_Status__c, Buyer__r.Last_Name__c,
                            Booking_Unit__r.Inventory__r.Property_Country__c, Buyer__r.Nationality__c,
                            Booking_Unit__r.Inventory__r.Property__r.DIFC__c, Buyer__r.Passport_Number__c,
                            Buyer__r.Passport_Expiry_Date__c, Buyer__r.IPMS_Buyer_ID__c, Seller__r.Party_ID__c,
                            Seller__r.FirstName, Seller__r.LastName, Seller__r.Nationality__pc
                            from Case where Id IN: setTaskCaseId]);
        return mapCaseDetails;
    }
    */

    @future(callout=true)
    public static void createTaskOnIPMS(set<Id> setTaskForCallout, set<Id> setTaskCaseId) {
        system.debug('Task cfreation called********************');
        map<Id, Case> mapCaseDetails = new map<Id, Case>([select Id, Status, Buyer__r.Party_ID__c,
                            Booking_Unit__r.Registration_ID__c, CaseNumber, Relationship_with_Seller__c,
                            Case_Type__c, Buyer_Type__c, Booking_Unit__r.Unit_Details__c, Booking_Unit__r.Unit__c,
                            Booking_Unit__r.Inventory__r.Property_City__c, Buyer__r.First_Name__c,
                            Booking_Unit__r.Inventory__r.Property_Status__c, Buyer__r.Last_Name__c,
                            Booking_Unit__r.Inventory__r.Property_Country__c, Buyer__r.Nationality__c,
                            Booking_Unit__r.Inventory__r.Property__r.DIFC__c, Buyer__r.Passport_Number__c,
                            Buyer__r.Passport_Expiry_Date__c, Buyer__r.IPMS_Buyer_ID__c, Seller__r.Party_ID__c,
                            Seller__r.FirstName, Seller__r.LastName, Seller__r.Nationality__pc, Account.Party_ID__c
                            from Case where Id IN: setTaskCaseId]);
        //return mapCaseDetails;
        
        list<Task> lsTaskToUpdate = new list<Task>();
        for(Task objTask : [Select t.WhoId
                                 , t.WhatId
                                 , t.Type
                                 , t.Status
                                 , t.OwnerId
                                 , t.Id
                                 , t.Subject
                                 , t.CreatedDate
                                 , t.Description
                                 , t.Assigned_User__c
                                 , t.ActivityDate
                                 , t.Owner.Name
                                 , t.Task_Error_Details__c
                                 , t.Pushed_to_IPMS__c
                                 From Task t
                                 where t.Id IN : setTaskForCallout]){
            TaskCreationUtility.TaskBean objBean = new TaskCreationUtility.TaskBean();
            objBean.p_REQUEST_NUMBER = String.valueOf(System.currentTimeMillis());
            objBean.p_REQUEST_NAME = 'CREATE_SR';
            objBean.p_SOURCE_SYSTEM = 'SFDC';
            objBean.PARAM_ID = mapCaseDetails.get(objTask.WhatId).CaseNumber;
            objBean.ATTRIBUTE1 = 'TASK';
            objBean.ATTRIBUTE2 = 'Assignment';
            objBean.ATTRIBUTE3 = mapCaseDetails.get(objTask.WhatId).Status;
            objBean.ATTRIBUTE4 = objTask.Owner.Name;
            objBean.ATTRIBUTE5 = mapCaseDetails.get(objTask.WhatId).Account.Party_ID__c;
            objBean.ATTRIBUTE6 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Registration_ID__c;
            objBean.ATTRIBUTE7 = String.valueOf(objTask.CreatedDate.format('dd-MMM-yyyy')); // format this as DD-MON- YYYY
            objBean.ATTRIBUTE8 = objTask.Id;
            Datetime dt = objTask.ActivityDate;
            objBean.ATTRIBUTE9 = String.valueOf(dt.format('dd-MMM-yyyy'));
            objBean.ATTRIBUTE10 = objTask.Subject;
            objBean.ATTRIBUTE11 = objTask.WhatId;
            objBean.ATTRIBUTE12 = objTask.Status;
            objBean.ATTRIBUTE13 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Unit__c;
            objBean.ATTRIBUTE14 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__c;
            objBean.ATTRIBUTE15 = objTask.Assigned_User__c;
            objBean.ATTRIBUTE16 = objTask.Type;
            objBean.ATTRIBUTE17 = objTask.Description;
            objBean.ATTRIBUTE18 = '';
            objBean.ATTRIBUTE19 = '';
            objBean.ATTRIBUTE20 = '';
            objBean.ATTRIBUTE21 = '';
            objBean.ATTRIBUTE22 = '';
            objBean.ATTRIBUTE23 = '';
            objBean.ATTRIBUTE24 = '';
            objBean.ATTRIBUTE25 = '';
            objBean.ATTRIBUTE26 = '';
            objBean.ATTRIBUTE27 = '';
            objBean.ATTRIBUTE28 = '';
            objBean.ATTRIBUTE29 = '';
            objBean.ATTRIBUTE30 = '';
            objBean.ATTRIBUTE31 = '';
            objBean.ATTRIBUTE32 = '';
            objBean.ATTRIBUTE33 = '';
            objBean.ATTRIBUTE34 = '';
            objBean.ATTRIBUTE35 = '';
            objBean.ATTRIBUTE36 = '';
            objBean.ATTRIBUTE37 = '';
            objBean.ATTRIBUTE38 = '';
            objBean.ATTRIBUTE39 = '';
            objBean.ATTRIBUTE40 = '';
            objBean.ATTRIBUTE41 = '';
            objBean.ATTRIBUTE42 = '';
            objBean.ATTRIBUTE43 = '';
            objBean.ATTRIBUTE44 = '';
            objBean.ATTRIBUTE45 = '';
            objBean.ATTRIBUTE46 = '';
            objBean.ATTRIBUTE47 = '';
            objBean.ATTRIBUTE48 = '';
            objBean.ATTRIBUTE49 = '';
            objBean.ATTRIBUTE50 = '';
            
            TaskCreationService.TaskHttpSoap11Endpoint objClass = new TaskCreationService.TaskHttpSoap11Endpoint();
            String response = objClass.SRDataToIPMS(objBean);
            system.debug('resp*****'+response);
            if(response.EqualsIgnoreCase('E')){
                objTask.Pushed_to_IPMS__c = false;
            }else{
                objTask.Pushed_to_IPMS__c = true;
            }
            
            lsTaskToUpdate.add(objTask);
        } // end of for loop
        if(!lsTaskToUpdate.isEmpty()){
            update lsTaskToUpdate;
        }
    } // end of method
    
}