public with sharing class CocdPushTaskToIPMS {

	@InvocableMethod
	public static void PushTask(List<Task> taskList) {
		//List<Task> poaTaskList = new List<Task>();
		Set<String> poaTaskIdSet = new Set<String>();
		Set<String> cocdFeeTaskIdSet = new Set<String>();
		Set<String> poaCaseIdSet = new Set<String>();
		Set<String> cocdCaseIdSet = new Set<String>();
		for( Task taskObj : taskList ){

			if( taskObj.Status != 'Closed' && !taskObj.Pushed_to_IPMS__c ){
				if( taskObj.Subject == 'Verify COCD Fee' ){
					cocdFeeTaskIdSet.add(taskObj.id);
					cocdCaseIdSet.add(taskobj.WhatId);
				} else if ( taskObj.Subject == 'Verify POA Documents' ){
					poaTaskIdSet.add(taskObj.id);
					poaCaseIdSet.add(taskobj.WhatId);
				}
			}
		}

		//if( !cocdFeeTaskIdSet.isEmpty() && !cocdCaseIdSet.isEmpty() ){
		//	createCocdFeeTaskInIPMS( cocdFeeTaskIdSet , cocdCaseIdSet);
		//}

		//if( !poaTaskIdSet.isEmpty() && !poaCaseIdSet.isEmpty() ){
		//	createPoaTaskInIPMS( poaTaskIdSet , poaCaseIdSet );
		//}
	}


	@future(callout=true)
	public static void createCocdFeeTaskInIPMS( Set<String> cocdFeeTaskIdSet, Set<String> cocdCaseIdSet ){
		map<Id, Case> mapCaseDetails = getCaseMap( cocdCaseIdSet );
		List<Task> updatedTasksInIPMS = new List<Task>();

		for( Task objTask : getTasks( cocdFeeTaskIdSet ) ) {
    		    TaskCreationUtility.TaskBean objBean = new TaskCreationUtility.TaskBean();
                objBean.p_REQUEST_NUMBER = String.valueOf( System.currentTimeMillis() );
                objBean.p_REQUEST_NAME = 'CREATE_SR';
                objBean.p_SOURCE_SYSTEM = 'SFDC';
                objBean.PARAM_ID = objTask.WhatId;
                objBean.ATTRIBUTE1 = 'TASK';
			    objBean.ATTRIBUTE2 = 'Change of Details';
			    objBean.ATTRIBUTE3 = mapCaseDetails.get(objTask.WhatId).Status;
			    objBean.ATTRIBUTE4 = objTask.Owner.Name;
			    objBean.ATTRIBUTE5 = mapCaseDetails.get(objTask.WhatId).Account.Party_ID__c;
			  //objBean.ATTRIBUTE6 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Registration_ID__c;
			    objBean.ATTRIBUTE6 = '';
			    objBean.ATTRIBUTE7 = String.valueOf(objTask.CreatedDate.format('dd-MMM-yyyy')); // format this as DD-MON- YYYY
			    objBean.ATTRIBUTE8 = objTask.Id;
			    Datetime dt = objTask.ActivityDate;
			    objBean.ATTRIBUTE9 = String.valueOf(dt.format('dd-MMM-yyyy'));
			    objBean.ATTRIBUTE10 = objTask.Subject;
			    objBean.ATTRIBUTE11 = objTask.WhatId;
			    objBean.ATTRIBUTE12 = objTask.Status;
			    objBean.ATTRIBUTE13 = mapCaseDetails.get(objTask.WhatId).POA_Name__c;
			    objBean.ATTRIBUTE14 = String.valueOf( mapCaseDetails.get(objTask.WhatId).POA_Expiry_Date__c );
			    objBean.ATTRIBUTE15 = mapCaseDetails.get(objTask.WhatId).POA_Relation_With_Owner__c;
			    objBean.ATTRIBUTE16 = mapCaseDetails.get(objTask.WhatId).CaseNumber;
			    objBean.ATTRIBUTE17 = mapCaseDetails.get(objTask.WhatId).POA_Issued_By__c;
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
		        objBean.ATTRIBUTE49 = objTask.Description;
		        objBean.ATTRIBUTE50 = '';
			  
			    TaskCreationService.TaskHttpSoap11Endpoint objClass = new TaskCreationService.TaskHttpSoap11Endpoint();
			    objClass.timeout_x = 120000;
			    String response = objClass.SRDataToIPMS(objBean);
			    system.debug('resp*****'+response);
			    if( response.equalsIgnoreCase('s') ){
					updatedTasksInIPMS.add( new Task(Id=objTask.Id, Pushed_to_IPMS__c=true) );
			    }
    	}

    	if( !updatedTasksInIPMS.isEmpty() ){
    		update updatedTasksInIPMS;
    	}

	}

	@future(callout=true)
	public static void createPoaTaskInIPMS( Set<String> poaTaskIdSet , Set<String> poaCaseIdSet ){
		map<Id, Case> mapCaseDetails = getCaseMap( poaCaseIdSet );
		List<Task> updatedTasksInIPMS = new List<Task>();

		for( Task objTask : getTasks( poaTaskIdSet ) ) {
		    TaskCreationUtility.TaskBean objBean = new TaskCreationUtility.TaskBean();
            objBean.p_REQUEST_NUMBER = String.valueOf( System.currentTimeMillis() );
            objBean.p_REQUEST_NAME = 'CREATE_SR';
            objBean.p_SOURCE_SYSTEM = 'SFDC';
            objBean.PARAM_ID = objTask.WhatId;
            objBean.ATTRIBUTE1 = 'TASK';
		    objBean.ATTRIBUTE2 = 'Change of Details';
		    objBean.ATTRIBUTE3 = mapCaseDetails.get(objTask.WhatId).Status;
		    objBean.ATTRIBUTE4 = objTask.Owner.Name;
		    objBean.ATTRIBUTE5 = mapCaseDetails.get(objTask.WhatId).Account.Party_ID__c;
		  //objBean.ATTRIBUTE6 = mapCaseDetails.get(objTask.WhatId).Booking_Unit__r.Registration_ID__c;
		    objBean.ATTRIBUTE6 = '';
		    objBean.ATTRIBUTE7 = String.valueOf(objTask.CreatedDate.format('dd-MMM-yyyy')); // format this as DD-MON- YYYY
		    objBean.ATTRIBUTE8 = objTask.Id;
		    Datetime dt = objTask.ActivityDate;
		    objBean.ATTRIBUTE9 = String.valueOf(dt.format('dd-MMM-yyyy'));
		    objBean.ATTRIBUTE10 = objTask.Subject;
		    objBean.ATTRIBUTE11 = objTask.WhatId;
		    objBean.ATTRIBUTE12 = objTask.Status;
		    objBean.ATTRIBUTE13 = '';
		    objBean.ATTRIBUTE14 = '';
		    objBean.ATTRIBUTE15 = '';
		    objBean.ATTRIBUTE16 = mapCaseDetails.get(objTask.WhatId).CaseNumber;
		    objBean.ATTRIBUTE17 = '';
		    objBean.ATTRIBUTE18 = mapCaseDetails.get(objTask.WhatId).OQOOD_Fee_Applicable__c ? 'Yes' : 'No';
		    objBean.ATTRIBUTE19 = mapCaseDetails.get(objTask.WhatId).OQOOD_Fee_Payment_Mode__c;
		    objBean.ATTRIBUTE20 = String.valueOf( mapCaseDetails.get(objTask.WhatId).OQOOD_Fee__c );
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
	        objBean.ATTRIBUTE49 = objTask.Description;
	        objBean.ATTRIBUTE50 = '';
		  
		    TaskCreationService.TaskHttpSoap11Endpoint objClass = new TaskCreationService.TaskHttpSoap11Endpoint();
		    objClass.timeout_x = 120000;
		    String response = objClass.SRDataToIPMS(objBean);
		    system.debug('resp*****'+response);
		    
		    if( response.equalsIgnoreCase('s') ){
				updatedTasksInIPMS.add( new Task(Id=objTask.Id, Pushed_to_IPMS__c=true) );
		    }
		}

		if( !updatedTasksInIPMS.isEmpty() ){
    		update updatedTasksInIPMS;
    	}
	}


	public static map<Id, Case> getCaseMap( set<String> setCaseIds ) {
    	return new map<Id, Case>( [ SELECT Id
    									, Status
    									, Account.Party_ID__c
    									, POA_Name__c
    									, POA_Expiry_Date__c
    									, POA_Relation_With_Owner__c
    									, CaseNumber
    									, POA_Issued_By__c
    									, OQOOD_Fee_Applicable__c
    									, OQOOD_Fee_Payment_Mode__c
    									, OQOOD_Fee__c
                            		  FROM Case 
                            		 WHERE Id IN :setCaseIds ] );
    }

    public static list<Task> getTasks( set<String> setTaskIds ) {
    	return new list<Task>( [ SELECT WhoId
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
                                   FROM Task
                                  WHERE Id IN : setTaskIds ] );
    }

}