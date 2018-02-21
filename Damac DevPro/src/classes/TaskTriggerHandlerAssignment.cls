public without sharing class TaskTriggerHandlerAssignment {
    public void checkTaskAssignedUser(list<Task> listTask) {
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
                && taskInst.Process_Name__c.equalsIgnoreCase('Assignment')
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
                            Case_Type__c, Buyer_Type__c, Booking_Unit__r.Unit_Details__c,
                            Booking_Unit__r.Inventory__r.Property_City__c, Buyer__r.First_Name__c,
                            Booking_Unit__r.Inventory__r.Property_Status__c, Buyer__r.Last_Name__c,
                            Booking_Unit__r.Inventory__r.Property_Country__c, Buyer__r.Nationality__c,
                            Booking_Unit__r.Inventory__r.Property__r.DIFC__c, Buyer__r.Passport_Number__c,
                            Buyer__r.Passport_Expiry_Date__c, Buyer__r.IPMS_Buyer_ID__c, Seller__r.Party_ID__c,
                            Seller__r.FirstName, Seller__r.LastName, Seller__r.Nationality__pc,
                            AccountId, Account.Party_ID__c
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

            list<TaskCreationWSDLplsql.APPSXXDC_PROCESS_SERX1794747X1X5> listObjBeans = 
            new list<TaskCreationWSDLplsql.APPSXXDC_PROCESS_SERX1794747X1X5>();
            
            TaskCreationWSDLplsql.APPSXXDC_PROCESS_SERX1794747X1X5 objHeaderBean = 
            new TaskCreationWSDLplsql.APPSXXDC_PROCESS_SERX1794747X1X5();
            String reqNo = string.valueOf(System.currentTimeMillis());
            objHeaderBean.PARAM_ID = mapCaseDetails.get(objTask.WhatId).CaseNumber;
            system.debug('param id*****'+mapCaseDetails.get(objTask.WhatId).CaseNumber);
            objHeaderBean.ATTRIBUTE1 = 'HEADER';
            objHeaderBean.ATTRIBUTE2 = 'Assignment';
            objHeaderBean.ATTRIBUTE3 = objTask.Status;
            system.debug('objTask.Status*****'+objTask.Status);
            objHeaderBean.ATTRIBUTE4 = 'CRM';
            objHeaderBean.ATTRIBUTE5 = mapCaseDetails.get(objTask.WhatId).Buyer__r.Party_ID__c;
            system.debug('party*****'+mapCaseDetails.get(objTask.WhatId).Buyer__r.Party_ID__c);
            objHeaderBean.ATTRIBUTE6 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Registration_ID__c;
            system.debug('regid*****'+mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Registration_ID__c);
            objHeaderBean.ATTRIBUTE7 = String.valueOf(objTask.CreatedDate.format('dd-MMM-yyyy').toUpperCase()); // format this as DD-MON- YYYY
            system.debug('date*****'+String.valueOf(objTask.CreatedDate.format('dd-MMM-yyyy').toUpperCase()));
            objHeaderBean.ATTRIBUTE8 = '';
            objHeaderBean.ATTRIBUTE9 = '';
            objHeaderBean.ATTRIBUTE10 = '';//set new Buyer Id here instead of objTask.WhatId;
            objHeaderBean.ATTRIBUTE11 = '';
            objHeaderBean.ATTRIBUTE12 = '';
            objHeaderBean.ATTRIBUTE13 = '';
            objHeaderBean.ATTRIBUTE14 = '';
            objHeaderBean.ATTRIBUTE15 = '';
            objHeaderBean.ATTRIBUTE16 = '';
            objHeaderBean.ATTRIBUTE17 = '';
            objHeaderBean.ATTRIBUTE18 = '';
            objHeaderBean.ATTRIBUTE19 = '';
            objHeaderBean.ATTRIBUTE20 = '';
            objHeaderBean.ATTRIBUTE21 = '';
            objHeaderBean.ATTRIBUTE22 = '';
            objHeaderBean.ATTRIBUTE23 = '';
            objHeaderBean.ATTRIBUTE24 = '';
            objHeaderBean.ATTRIBUTE25 = '';
            objHeaderBean.ATTRIBUTE26 = '';
            objHeaderBean.ATTRIBUTE27 = '';
            objHeaderBean.ATTRIBUTE28 = '';
            objHeaderBean.ATTRIBUTE29 = '';
            objHeaderBean.ATTRIBUTE30 = '';
            objHeaderBean.ATTRIBUTE31 = '';
            objHeaderBean.ATTRIBUTE32 = '';
            objHeaderBean.ATTRIBUTE33 = '';
            objHeaderBean.ATTRIBUTE34 = '';
            objHeaderBean.ATTRIBUTE35 = '';
            objHeaderBean.ATTRIBUTE36 = '';
            objHeaderBean.ATTRIBUTE37 = '';
            objHeaderBean.ATTRIBUTE38 = '';
            objHeaderBean.ATTRIBUTE39 = '';
            //objHeaderBean.ATTRIBUTE40 = '';
            objHeaderBean.ATTRIBUTE41 = '';
            objHeaderBean.ATTRIBUTE42 = '';
            objHeaderBean.ATTRIBUTE43 = '';
            objHeaderBean.ATTRIBUTE44 = '';
            objHeaderBean.ATTRIBUTE45 = '';
            objHeaderBean.ATTRIBUTE46 = '';
            objHeaderBean.ATTRIBUTE47 = '';
            objHeaderBean.ATTRIBUTE48 = '';
            objHeaderBean.ATTRIBUTE49 = '';
            objHeaderBean.ATTRIBUTE50 = '';
            listObjBeans.add(objHeaderBean);
            
            // create TASK bean
            TaskCreationWSDLplsql.APPSXXDC_PROCESS_SERX1794747X1X5 objTaskBean = new TaskCreationWSDLplsql.APPSXXDC_PROCESS_SERX1794747X1X5();
            objTaskBean.PARAM_ID = mapCaseDetails.get(objTask.WhatId).CaseNumber;
            objTaskBean.ATTRIBUTE1 = 'TASK';
            objTaskBean.ATTRIBUTE2 = objTask.Subject;
            system.debug('subject*****'+objTask.Subject);
            objTaskBean.ATTRIBUTE3 = objTask.Status;
            system.debug('subject*****'+objTask.Status);
            objTaskBean.ATTRIBUTE4 = 'FINANCEMANAGER';
            objTaskBean.ATTRIBUTE5 = '';
            objTaskBean.ATTRIBUTE6 = '';
            objTaskBean.ATTRIBUTE7 = String.valueOf(objTask.CreatedDate.format('dd-MMM-yyyy').toUpperCase()); // format this as DD-MON- YYYY
            system.debug('created date*****'+String.valueOf(objTask.CreatedDate.format('dd-MMM-yyyy').toUpperCase()));
            objTaskBean.ATTRIBUTE8 = objTask.Id;
            system.debug('task id*****'+objTask.Id);
            Datetime dt = objTask.ActivityDate;
            objTaskBean.ATTRIBUTE9 = String.valueOf(dt.format('dd-MMM-yyyy').toUpperCase());
            system.debug('due date*****'+String.valueOf(dt.format('dd-MMM-yyyy').toUpperCase()));
            objTaskBean.ATTRIBUTE10 = '';
            objTaskBean.ATTRIBUTE11 = objTask.Assigned_User__c;
            objTaskBean.ATTRIBUTE12 = objTask.Subject;
            objTaskBean.ATTRIBUTE13 = objTask.Status;
            objTaskBean.ATTRIBUTE14 = objTask.Type;
            objTaskBean.ATTRIBUTE15 = objTask.Description;
            objTaskBean.ATTRIBUTE16 = objTask.WhatId;
            objTaskBean.ATTRIBUTE17 = mapCaseDetails.get(objTask.WhatId).Relationship_with_Seller__c;
            objTaskBean.ATTRIBUTE18 = mapCaseDetails.get(objTask.WhatId).Case_Type__c;
            objTaskBean.ATTRIBUTE19 = mapCaseDetails.get(objTask.WhatId).Buyer_Type__c;
            objTaskBean.ATTRIBUTE20 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Unit_Details__c;
            objTaskBean.ATTRIBUTE21 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Inventory__r.Property_City__c;
            objTaskBean.ATTRIBUTE22 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Inventory__r.Property_Status__c;
            objTaskBean.ATTRIBUTE23 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Inventory__r.Property_Country__c;
            objTaskBean.ATTRIBUTE24 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Inventory__r.Property__r.DIFC__c == true ? 'Yes' : 'No';
            objTaskBean.ATTRIBUTE25 = mapCaseDetails.get(objTask.WhatId).Buyer__r.First_Name__c;
            objTaskBean.ATTRIBUTE26 = mapCaseDetails.get(objTask.WhatId).Buyer__r.Last_Name__c;
            objTaskBean.ATTRIBUTE27 = mapCaseDetails.get(objTask.WhatId).Buyer__r.Nationality__c;
            objTaskBean.ATTRIBUTE28 = mapCaseDetails.get(objTask.WhatId).Buyer__r.Passport_Number__c;
            objTaskBean.ATTRIBUTE29 = mapCaseDetails.get(objTask.WhatId).Buyer__r.Passport_Expiry_Date__c;
            objTaskBean.ATTRIBUTE30 = mapCaseDetails.get(objTask.WhatId).Buyer__r.IPMS_Buyer_ID__c;
            objTaskBean.ATTRIBUTE31 = mapCaseDetails.get(objTask.WhatId).Seller__r.FirstName;
            objTaskBean.ATTRIBUTE32 = mapCaseDetails.get(objTask.WhatId).Seller__r.LastName;
            objTaskBean.ATTRIBUTE33 = mapCaseDetails.get(objTask.WhatId).Seller__r.Nationality__pc;
            objTaskBean.ATTRIBUTE34 = mapCaseDetails.get(objTask.WhatId).Seller__r.Party_ID__c;
            objTaskBean.ATTRIBUTE35 = '';
            objTaskBean.ATTRIBUTE36 = '';
            objTaskBean.ATTRIBUTE37 = '';
            objTaskBean.ATTRIBUTE38 = '';
            objTaskBean.ATTRIBUTE39 = '';
            objTaskBean.ATTRIBUTE41 = '';
            objTaskBean.ATTRIBUTE42 = '';
            objTaskBean.ATTRIBUTE43 = '';
            objTaskBean.ATTRIBUTE44 = '';
            objTaskBean.ATTRIBUTE45 = '';
            objTaskBean.ATTRIBUTE46 = '';
            objTaskBean.ATTRIBUTE47 = '';
            objTaskBean.ATTRIBUTE48 = '';
            objTaskBean.ATTRIBUTE49 = '';
            objTaskBean.ATTRIBUTE50 = '';
            listObjBeans.add(objTaskBean);
            
            // create UNIT bean
            TaskCreationWSDLplsql.APPSXXDC_PROCESS_SERX1794747X1X5 objUnitBean = new TaskCreationWSDLplsql.APPSXXDC_PROCESS_SERX1794747X1X5();
            objUnitBean.PARAM_ID = mapCaseDetails.get(objTask.WhatId).CaseNumber;
            objUnitBean.ATTRIBUTE1 = 'UNITS';
            objUnitBean.ATTRIBUTE2 = 'Assignment';
            objUnitBean.ATTRIBUTE3 = '';
            objUnitBean.ATTRIBUTE4 = '';
            objUnitBean.ATTRIBUTE5 = '';
            objUnitBean.ATTRIBUTE6 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Registration_ID__c;
            system.debug('reg*****'+mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Registration_ID__c);
            objUnitBean.ATTRIBUTE7 = '';
            objUnitBean.ATTRIBUTE8 = '';
            objUnitBean.ATTRIBUTE9 = '';
            objUnitBean.ATTRIBUTE10 = '';
            objUnitBean.ATTRIBUTE11 = '';
            objUnitBean.ATTRIBUTE12 = '';
            objUnitBean.ATTRIBUTE13 = '';
            objUnitBean.ATTRIBUTE14 = '';
            objUnitBean.ATTRIBUTE15 = '';
            objUnitBean.ATTRIBUTE16 = '';
            objUnitBean.ATTRIBUTE17 = '';
            objUnitBean.ATTRIBUTE18 = '';
            objUnitBean.ATTRIBUTE19 = '';
            objUnitBean.ATTRIBUTE20 = '';
            objUnitBean.ATTRIBUTE21 = '';
            objUnitBean.ATTRIBUTE22 = '';
            objUnitBean.ATTRIBUTE23 = '';
            objUnitBean.ATTRIBUTE24 = '';
            objUnitBean.ATTRIBUTE25 = '';
            objUnitBean.ATTRIBUTE26 = '';
            objUnitBean.ATTRIBUTE27 = '';
            objUnitBean.ATTRIBUTE28 = '';
            objUnitBean.ATTRIBUTE29 = '';
            objUnitBean.ATTRIBUTE30 = '';
            objUnitBean.ATTRIBUTE31 = '';
            objUnitBean.ATTRIBUTE32 = '';
            objUnitBean.ATTRIBUTE33 = '';
            objUnitBean.ATTRIBUTE34 = '';
            objUnitBean.ATTRIBUTE35 = '';
            objUnitBean.ATTRIBUTE36 = '';
            objUnitBean.ATTRIBUTE37 = '';
            objUnitBean.ATTRIBUTE38 = '';
            objUnitBean.ATTRIBUTE39 = '';
            objUnitBean.ATTRIBUTE41 = '';
            objUnitBean.ATTRIBUTE42 = '';
            objUnitBean.ATTRIBUTE43 = '';
            objUnitBean.ATTRIBUTE44 = '';
            objUnitBean.ATTRIBUTE45 = '';
            objUnitBean.ATTRIBUTE46 = '';
            objUnitBean.ATTRIBUTE47 = '';
            objUnitBean.ATTRIBUTE48 = '';
            objUnitBean.ATTRIBUTE49 = '';
            objUnitBean.ATTRIBUTE50 = '';
            listObjBeans.add(objUnitBean);
            
            TaskCreationWSDL.TaskHttpSoap11Endpoint objClass = new TaskCreationWSDL.TaskHttpSoap11Endpoint();
            String response = objClass.SRDataToIPMSMultiple('0001', 'CREATE_SR', 'SFDC', listObjBeans);
            system.debug('resp*****'+response);
            innerClass IC = (innerClass)JSON.deserialize(response, innerClass.class);
            system.debug('IC*****'+IC);
            if(IC.status.EqualsIgnoreCase('E')){
                objTask.Pushed_to_IPMS__c = false;
                objTask.Task_Error_Details__c = IC.status;
            }else{
                objTask.Pushed_to_IPMS__c = true;
            }
            
            lsTaskToUpdate.add(objTask);
        } // end of for loop
        if(!lsTaskToUpdate.isEmpty()){
            update lsTaskToUpdate;
        }
    } // end of method
    
    public class innerClass{
        public string message;
        public string status;
        
        public innerClass(){
            
        }
    }
} // end of class