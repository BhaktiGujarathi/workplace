/* Description: Class used for creating task in IPMS when created in Salesforce
*/
public with sharing class IPMSTaskUtility {
    
    //Method called from process builder to create task in IPMS
    @InvocableMethod
    public static void createTaskInIPMS(List<Task> lstTask) {
        /*List<Task> lstTask = [Select Id, WhatId, Subject, Pushed_to_IPMS__c, 
            Description, Assigned_User__c, ActivityDate 
            From Task Where Id IN: lstId And WhatId != null 
            And Assigned_User__c != null And Subject != null];
            
        if(lstTask != null && !lstTask.isEmpty()) {
            if(String.valueOf(lstTask[0].WhatId).startsWith('500')) {
                List<Case> lstCase = [Select Id, RecordType.DeveloperName, Status, ];
            }
        }*/
        Set<Id> setCaseId = new Set<Id>();
        Set<Id> setTaskId = new Set<Id>();
        
        for(Task objTask: lstTask) {
            if(String.valueOf(objTask.WhatId).startsWith('500') && objTask.Subject != null &&
                objTask.Assigned_User__c != null && objTask.Status != 'Closed' && !objTask.Pushed_to_IPMS__c) {
                if(objTask.Subject.equals('POA Verification Required') || 
                    objTask.Subject.equals('NOC Verification Required') || 
                    objTask.Subject.equals('Update Refund Details in IPMS') || 
                    objTask.Subject.equals('Update AOPT Details in IPMS') || 
                    objTask.Subject.equals('Update Penalty Waiver Details in IPMS')) {
                    
                    setTaskId.add(objTask.Id);
                    setCaseId.add(objTask.WhatId);
                }
            }
        }
        
        if(!setTaskId.isEmpty() && !setCaseId.isEmpty()) {
            createTask(setTaskId, setCaseId);
        }
    }
    
    //Method to perform callout to IPMS to create task
    @future(callout=true)
    public static void createTask(Set<Id> setTaskId, Set<Id> setCaseId) {
        Map<Id, Case> mapCase = getCaseMap(setCaseId);
        Set<String> setCaseRT = new Set<String>();
        List<Task> lstTaskToUpdate = new List<Task>();
        setCaseRT.add('AOPT');
        setCaseRT.add('Customer_Refund');
        setCaseRT.add('Token_Refund');
        setCaseRT.add('Penalty_Waiver');
        
        for(Task objTask: getTasks(setTaskId)) {
            if(setCaseRT.contains(mapCase.get(objTask.WhatId).RecordType.DeveloperName)) {
                Case objCase = mapCase.get(objTask.WhatId);
                TaskCreationUtility.TaskBean objBean = new TaskCreationUtility.TaskBean();
                objBean = setCommonTaskFields(objBean, objTask, objCase);
                
                if(objTask.Subject.equals('POA Verification Required')) {
                    objBean.ATTRIBUTE2 = objCase.RecordType.Name;
                    objBean.ATTRIBUTE6 = getRegIds(objCase.SR_Booking_Units__r);
                    objBean.ATTRIBUTE17 = objCase.POA_Name__c;
                    DateTime dtExpDate = objCase.POA_Expiry_Date__c;
                    objBean.ATTRIBUTE18 = dtExpDate != null ? String.valueOf(dtExpDate.format('dd-MMM-yyyy')) : '';
                    objBean.ATTRIBUTE19 = objCase.Purpose_of_POA__c;
                    objBean.ATTRIBUTE20 = objCase.POA_Issued_By__c;
                    objBean.ATTRIBUTE21 = objTask.Document_URL__c;
                    
                    TaskCreationService.TaskHttpSoap11Endpoint objClass = new TaskCreationService.TaskHttpSoap11Endpoint();
                    String strResponse = objClass.SRDataToIPMS(objBean);
                    system.debug('strResponse*****'+strResponse);
                    if(strResponse.equalsIgnoreCase('S')) {
                        lstTaskToUpdate.add(new Task(Id = objTask.Id, Pushed_to_IPMS__c = true));
                    }
                }
                
                else if(objTask.Subject.equals('Update Refund Details in IPMS')) {
                    objBean.ATTRIBUTE2 = objCase.RecordType.Name;
                    objBean.ATTRIBUTE6 = getRegIds(objCase.SR_Booking_Units__r);
                    objBean.ATTRIBUTE17 = objCase.Amount_Approved__c != null ? String.valueOf(objCase.Amount_Approved__c) : '';
                    
                    TaskCreationService.TaskHttpSoap11Endpoint objClass = new TaskCreationService.TaskHttpSoap11Endpoint();
                    String strResponse = objClass.SRDataToIPMS(objBean);
                    system.debug('strResponse*****'+strResponse);
                    if(strResponse.equalsIgnoreCase('S')) {
                        lstTaskToUpdate.add(new Task(Id = objTask.Id, Pushed_to_IPMS__c = true));
                    }
                }
                
                else if(objTask.Subject.equals('Update AOPT Details in IPMS')) {
                    objBean.ATTRIBUTE2 = objCase.RecordType.Name;
                    objBean.ATTRIBUTE6 = getRegIds(objCase.SR_Booking_Units__r);
                    
                    TaskCreationService.TaskHttpSoap11Endpoint objClass = new TaskCreationService.TaskHttpSoap11Endpoint();
                    String strResponse = objClass.SRDataToIPMS(objBean);
                    system.debug('strResponse*****'+strResponse);
                    if(strResponse.equalsIgnoreCase('S')) {
                        lstTaskToUpdate.add(new Task(Id = objTask.Id, Pushed_to_IPMS__c = true));
                    }
                }
                
                else if(objTask.Subject.equals('Update Penalty Waiver Details in IPMS')) {
                    objBean.ATTRIBUTE2 = objCase.RecordType.Name;
                    objBean.ATTRIBUTE6 = getRegIds(objCase.SR_Booking_Units__r);
                    objBean.ATTRIBUTE17 = objCase.Approved_Amount__c != null ? String.valueOf(objCase.Approved_Amount__c) : '';
                    
                    TaskCreationService.TaskHttpSoap11Endpoint objClass = new TaskCreationService.TaskHttpSoap11Endpoint();
                    String strResponse = objClass.SRDataToIPMS(objBean);
                    system.debug('strResponse*****'+strResponse);
                    if(strResponse.equalsIgnoreCase('S')) {
                        lstTaskToUpdate.add(new Task(Id = objTask.Id, Pushed_to_IPMS__c = true));
                    }
                }
                
                else if(objTask.Subject.equals('NOC Verification Required')) {
                    objBean.ATTRIBUTE2 = objCase.RecordType.Name;
                    objBean.ATTRIBUTE6 = getRegIds(objCase.SR_Booking_Units__r);
                    objBean.ATTRIBUTE17 = objTask.Document_URL__c;
                    
                    TaskCreationService.TaskHttpSoap11Endpoint objClass = new TaskCreationService.TaskHttpSoap11Endpoint();
                    String strResponse = objClass.SRDataToIPMS(objBean);
                    system.debug('strResponse*****'+strResponse);
                    if(strResponse.equalsIgnoreCase('S')) {
                        lstTaskToUpdate.add(new Task(Id = objTask.Id, Pushed_to_IPMS__c = true));
                    }
                }
            }
        }
        
        if(!lstTaskToUpdate.isEmpty()) {
            update lstTaskToUpdate;
        }
    }
    
    //Method to get task details
    public static List<Task> getTasks( Set<Id> setTaskId ) {
        return new List<Task>( [ SELECT WhoId
                                      , WhatId
                                      , Type
                                      , Status
                                      , OwnerId
                                      , Id
                                      , Subject
                                      , CreatedDate
                                      , Description
                                      , Assigned_User__c
                                      , ActivityDate
                                      , Owner.Name
                                      , Document_URL__c
                                 FROM Task
                                 WHERE Id IN : setTaskId ] );
    }
    
    //Method to get case details
    public static Map<Id, Case> getCaseMap(Set<Id> setCaseId) {
        return new Map<Id, Case>([Select Id, CaseNumber, RecordType.DeveloperName, RecordType.Name, POA_Name__c, POA_Expiry_Date__c,
                                  Purpose_of_POA__c, POA_Issued_By__c, Amount_Approved__c, Booking_Unit__c,
                                  Booking_Unit__r.Registration_Id__c, Account.Party_ID__c, Approved_Amount__c,
                                  Actual_Approving_Percent__c, Status, 
                                  (Select Id, Booking_Unit__c, Booking_Unit__r.Registration_Id__c 
                                  From SR_Booking_Units__r Where Booking_Unit__c != null)
                                  From Case
                                  Where Id IN: setCaseId]);
    }
    
    //Method to set common fields on IPMS task object
    private static TaskCreationUtility.TaskBean setCommonTaskFields(TaskCreationUtility.TaskBean objBean, Task objTask, Case objCase) {
        objBean.p_REQUEST_NUMBER = String.valueOf(System.currentTimeMillis());
        objBean.p_REQUEST_NAME = 'CREATE_SR';
        objBean.p_SOURCE_SYSTEM = 'SFDC';
        objBean.PARAM_ID = objTask.WhatId;
        objBean.ATTRIBUTE1 = 'TASK';
        //objBean.ATTRIBUTE2 = 'Assignment';
        objBean.ATTRIBUTE3 = objCase.Status;
        objBean.ATTRIBUTE4 = objTask.Owner.Name;
        objBean.ATTRIBUTE5 = objCase.Account.Party_ID__c;
        //objBean.ATTRIBUTE6 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Registration_ID__c;
        objBean.ATTRIBUTE7 = String.valueOf(objTask.CreatedDate.format('dd-MMM-yyyy')); // format this as DD-MON- YYYY
        objBean.ATTRIBUTE8 = objTask.Id;
        Datetime dt = objTask.ActivityDate;
        objBean.ATTRIBUTE9 = String.valueOf(dt.format('dd-MMM-yyyy'));
        objBean.ATTRIBUTE10 = objTask.WhatId;
        objBean.ATTRIBUTE11 = objTask.Assigned_User__c;
        objBean.ATTRIBUTE12 = objTask.Subject;
        objBean.ATTRIBUTE13 = objTask.Status;
        objBean.ATTRIBUTE14 = objTask.Type;
        objBean.ATTRIBUTE15 = objTask.Description;
        objBean.ATTRIBUTE16 = objCase.CaseNumber;
        objBean.ATTRIBUTE17 = '';
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
            
        return objBean;
    }
    
    //Method to get the reg Ids by iterating over the booking units
    private static String getRegIds(List<SR_Booking_Unit__c> lstSRBU) {
        String strRegIds = '';
        if(lstSRBU != null && !lstSRBU.isEmpty()) {
            for(SR_Booking_Unit__c objSRBU: lstSRBU) {
                if(objSRBU.Booking_Unit__r.Registration_Id__c != null) {
                    strRegIds += objSRBU.Booking_Unit__r.Registration_Id__c + ',';
                }
            }
            strRegIds = strRegIds.removeEnd(',');
        }
        return strRegIds;
    }
}