public with sharing class HandoverChecklistHandler {
	
	@InvocableMethod (label='' description='')
	public static void handoverChecklist(List<Id> listBUId) {
		
		list<Booking_Unit__c> lstBookingUnits = new list<Booking_Unit__c>();
		set<Id> SetLocationId = new set<Id>();
		map<Id, Set<String>> mapLocationIdTask = new map<Id, Set<String>>();
		for (Booking_Unit__c objBU : [Select Id, Inventory__c, Inventory__r.Building_Location__c, 
										Inventory__r.Building_Location__r.Approved_By_Authority__c, 
										Inventory__r.Building_Location__r.BCC_Generated__c,
										Inventory__r.Building_Location__r.Units_Available_for_Handover__c,
										Inventory__r.Building_Location__r.Provided_Access_to_Building__c,
										Inventory__r.Building_Location__r.Snag_Status__c,
										Inventory__r.Building_Location__r.Civil_Defence_Available__c,
										Inventory__r.Building_Location__r.Utilities_Available__c,
										Handover_Readiness_Checklist__c
									From Booking_Unit__c Where Id IN:listBUId]){
			if (objBU.Inventory__c != null && objBU.Inventory__r.Building_Location__c != null)
				SetLocationId.add(objBU.Inventory__r.Building_Location__c);
				lstBookingUnits.add(objBU);
		}
		
		if (SetLocationId != null && SetLocationId.size() > 0) {
			for (Task objTask : [Select Id, Subject, Status, WhatId From Task 
									Where WhatId IN: SetLocationId]) {
				if (mapLocationIdTask.containsKey(objTask.WhatId)) {
					Set<String> setSubject = mapLocationIdTask.get(objTask.WhatId);
					setSubject.add(objTask.Subject);
					mapLocationIdTask.put(objTask.WhatId, setSubject);
				} else {
					mapLocationIdTask.put(objTask.WhatId, new set<String> {objTask.Subject});
				}
			}
		}
		
		list<Task> lstTask = new list<Task>();
		list<Booking_Unit__c> lstBUs = new list<Booking_Unit__c>();
		for (Booking_Unit__c objBU : lstBookingUnits){
			
			set<String> setTaskSubjects = mapLocationIdTask.get(objBU.Inventory__r.Building_Location__c);
			
			if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Check for Handover Readiness on Building'))){
				Task objTask = new Task();
					objTask.Subject = 'Check for Handover Readiness on Building';
					objTask.Status = 'Not Started';
					objTask.Priority = 'Medium';
					objTask.ownerId = '0050Y000001SC4L';
					objTask.WhatId = objBU.Inventory__r.Building_Location__c;
					objTask.Process_Name__c = 'Handover';
					lstTask.add(objTask);
			}
			if (objBU.Inventory__r.Building_Location__r.Approved_By_Authority__c == false) {
				if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Get Approval From Authority'))){
					Task objTask = new Task();
					objTask.Subject = 'Get Approval From Authority';
					objTask.Status = 'Not Started';
					objTask.Priority = 'Medium';
					objTask.ownerId = '0050Y000001SC4L';
					objTask.WhatId = objBU.Inventory__r.Building_Location__c;
					objTask.Process_Name__c = 'Handover';
					lstTask.add(objTask);
				}
			}
			
			if (objBU.Inventory__r.Building_Location__r.BCC_Generated__c == false) {
				if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Genearte BCC'))){
					Task objTask = new Task();
					objTask.Subject = 'Genearte BCC';
					objTask.Status = 'Not Started';
					objTask.Priority = 'Medium';
					objTask.ownerId = '0050Y000001SC4L';
					objTask.WhatId = objBU.Inventory__r.Building_Location__c;
					objTask.Process_Name__c = 'Handover';
					lstTask.add(objTask);
				}
			}
			
			if (objBU.Inventory__r.Building_Location__r.Units_Available_for_Handover__c == false) {
				if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Take a Confirmation of Units Available'))){
					Task objTask = new Task();
					objTask.Subject = 'Take a Confirmation of Units Available';
					objTask.Status = 'Not Started';
					objTask.Priority = 'Medium';
					objTask.ownerId = '0050Y000001SC4L';
					objTask.WhatId = objBU.Inventory__r.Building_Location__c;
					objTask.Process_Name__c = 'Handover';
					lstTask.add(objTask);
				}
			}
			
			if (objBU.Inventory__r.Building_Location__r.Provided_Access_to_Building__c == false) {
				if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Please get Access to Building'))){
					Task objTask = new Task();
					objTask.Subject = 'Please get Access to Building';
					objTask.Status = 'Not Started';
					objTask.Priority = 'Medium';
					objTask.ownerId = '0050Y000001SC4L';
					objTask.WhatId = objBU.Inventory__r.Building_Location__c;
					objTask.Process_Name__c = 'Handover';
					lstTask.add(objTask);
				}
			}
			
			if (objBU.Inventory__r.Building_Location__r.Snag_Status__c != 'Completed') {
				if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Please Resolve the Snags'))){
					Task objTask = new Task();
					objTask.Subject = 'Please Resolve the Snags';
					objTask.Status = 'Not Started';
					objTask.Priority = 'Medium';
					objTask.ownerId = '0050Y000001SC4L';
					objTask.WhatId = objBU.Inventory__r.Building_Location__c;
					objTask.Process_Name__c = 'Handover';
					lstTask.add(objTask);
				}
			}
			
			if (objBU.Inventory__r.Building_Location__r.Civil_Defence_Available__c == false) {
				if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Get Civil Defence for Property'))){
					Task objTask = new Task();
					objTask.Subject = 'Get Civil Defence for Property';
					objTask.Status = 'Not Started';
					objTask.Priority = 'Medium';
					objTask.ownerId = '0050Y000001SC4L';
					objTask.WhatId = objBU.Inventory__r.Building_Location__c;
					objTask.Process_Name__c = 'Handover';
					lstTask.add(objTask);
				}
			}
			
			if (objBU.Inventory__r.Building_Location__r.Utilities_Available__c == false) {
				if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Get Utilities for Property'))){
					Task objTask = new Task();
					objTask.Subject = 'Get Utilities for Property';
					objTask.Status = 'Not Started';
					objTask.Priority = 'Medium';
					objTask.ownerId = '0050Y000001SC4L';
					objTask.WhatId = objBU.Inventory__r.Building_Location__c;
					objTask.Process_Name__c = 'Handover';
					lstTask.add(objTask);
				}
			}
			
			if (objBU.Inventory__r.Building_Location__r.Approved_By_Authority__c == true && objBU.Inventory__r.Building_Location__r.BCC_Generated__c == true
				&& objBU.Inventory__r.Building_Location__r.Units_Available_for_Handover__c == true && 
				objBU.Inventory__r.Building_Location__r.Provided_Access_to_Building__c == true && objBU.Inventory__r.Building_Location__r.Snag_Status__c == 'Completed'
				&& objBU.Inventory__r.Building_Location__r.Civil_Defence_Available__c == true && objBU.Inventory__r.Building_Location__r.Utilities_Available__c == true){
					objBU.Handover_Readiness_Checklist__c = true;
					lstBUs.add(objBU);
				}
			if (lstTask != null && lstTask.size() > 0) {
				insert lstTask;
			}
			
			if (lstBUs != null && lstBUs.size() > 0) {
				update lstBUs;
			}
		}
		
	}
    
}