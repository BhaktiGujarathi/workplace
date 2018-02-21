global class PreHandoverProcess implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
      String buildingName = 'Building';
      String query = 'Select Snag_Status__c, RERA_Audit_Flag__c, RecordTypeId, RecordType.DeveloperName, Communications_to_be_Sent__c, Completion__c, As_Built_Drawings_Uploaded__c, Location_ID__c, Communications_Added__c, Approved_By_Authority__c From Location__c where Completion__c < 100 And RecordType.DeveloperName =:buildingName';
                    system.debug('!!!!!!!!!!query'+query);
      return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Location__c> scope){
        system.debug('!!!!!!!!!!scope'+scope);
        Set<Id> setLocationId = new Set<Id>();
        set<Id> setBookingUnitId = new Set<Id>();
        map<Id, Set<String>> mapLocationIdTask = new map<Id, Set<String>>();
        list<Location__c> lstLocation = new list<Location__c>();
        list<Location__c> lstLocationToUpdate = new list<Location__c>();
        map<Id, List<Booking_Unit__c>> mapLocationBookingUnits = new map<Id, List<Booking_Unit__c>>();
        for (Location__c objLocation : scope){
            HandoverServices.buildingCompletion objBuilding = HandoverServices.getAreaCompletion(objLocation.Location_ID__c);
            if (objBuilding.URL != null) {
                objLocation.Completion__c = Decimal.valueOf(objBuilding.URL);
            }
            lstLocation.add(objLocation);
        }
        
        if (lstLocation != null && lstLocation.size() > 0) {
            update lstLocation;
        }
        
        for (Location__c objNewLocation : lstLocation){
            if (objNewLocation.Completion__c >= 80 && objNewLocation.Completion__c < 100){
                setLocationId.add(objNewLocation.id);
                lstLocationToUpdate.add(objNewLocation);
            }
            
        }
        if (setLocationId != null && setLocationId.size() > 0) {
            
            for (Inventory__c objInventory : [Select Id, Building_Location__c ,
                                                (Select Id, DSR_Flag__c, Dispute_Flag__c, Default__c, Offers_Available__c, 
                                                        Document_Received__c, Deposit_Received__c, Mortgage__c, Booking_Undergoing_Termination__c, 
                                                        Dispute__c, Litigation__c 
                                                 From Booking_Units__r)
                                              From Inventory__c 
                                              Where Building_Location__c IN: setLocationId]) {
                    if (mapLocationBookingUnits.containsKey(objInventory.Building_Location__c)){
                        List<Booking_Unit__c> lstBookingUnit = mapLocationBookingUnits.get(objInventory.Building_Location__c);
                        lstBookingUnit.addAll(objInventory.Booking_Units__r);
                        mapLocationBookingUnits.put(objInventory.Building_Location__c, lstBookingUnit);
                    } else {
                        mapLocationBookingUnits.put(objInventory.Building_Location__c, objInventory.Booking_Units__r);
                    }
                    for (Booking_Unit__c objBU : objInventory.Booking_Units__r) {
                        setBookingUnitId.add(objBU.Id);
                    }
                system.debug('!!!!!!!mapLocationBookingUnits'+mapLocationBookingUnits);                             
            }
            /*map<Id, set<Id>>mapBuildingInventories = new map<Id, Set<Id>>();
            for (Inventory__c objInventory : [Select Id, Building_Location__c From Inventory__c Where Building_Location__c IN: setLocationId])
            {
                if (mapBuildingInventories.containsKey(objInventory.WhatId)) {
                    Set<String> setSubject = mapLocationIdTask.get(objTask.WhatId);
                    setSubject.add(objTask.Subject);
                    mapLocationIdTask.put(objTask.WhatId, setSubject);
                } else {
                    mapLocationIdTask.put(objTask.WhatId, new set<String> {objTask.Subject});
                }
            }*/
                    
            for (Task objTask : [Select Id, Subject, Status, WhatId From Task 
                                    Where WhatId IN: setLocationId OR WhatId IN: setBookingUnitId]) {
                if (mapLocationIdTask.containsKey(objTask.WhatId)) {
                    Set<String> setSubject = mapLocationIdTask.get(objTask.WhatId);
                    setSubject.add(objTask.Subject);
                    mapLocationIdTask.put(objTask.WhatId, setSubject);
                } else {
                    mapLocationIdTask.put(objTask.WhatId, new set<String> {objTask.Subject});
                }
            }
            system.debug('!!!!!!!mapLocationIdTask'+mapLocationIdTask);
        }
        
        list<Task> lstTask = new list<Task>();
        list<Booking_Unit__c> lstBookingUnits = new list<Booking_Unit__c>();
        for (Location__c objLocation : lstLocationToUpdate) {
            set<String> setTaskSubjects = mapLocationIdTask.get(objLocation.id);
            if (objLocation.As_Built_Drawings_Uploaded__c == false) {
                system.debug('!!!!!!!!setTaskSubjects'+setTaskSubjects);
                if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Please provide As Built Drawings'))){
                    Task objTask = new Task();
                    objTask.Subject = 'Please provide As Built Drawings';
                    objTask.Status = 'Not Started';
                    objTask.Priority = 'Medium';
                    objTask.ownerId = '0050Y000001SC4L';
                    objTask.WhatId = objLocation.id;
                    objTask.Process_Name__c = 'Handover';
                    lstTask.add(objTask);
                }
            }
            if (objLocation.RERA_Audit_Flag__c != 'Complete') {
                system.debug('####setTaskSubjects'+setTaskSubjects);
                if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Please complete RERA Audit'))){
                    Task objTask = new Task();
                    objTask.Subject = 'Please complete RERA Audit';
                    objTask.Status = 'Not Started';
                    objTask.Priority = 'Medium';
                    objTask.ownerId = '0050Y000001T9My';
                    objTask.WhatId = objLocation.id;
                    objTask.Process_Name__c = 'Handover';
                    lstTask.add(objTask);
                }
            }
            if (objLocation.Approved_By_Authority__c == false) {
                system.debug('$$$$setTaskSubjects'+setTaskSubjects);
                if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Get Approval From Authority'))){
                    Task objTask = new Task();
                    objTask.Subject = 'Get Approval From Authority';
                    objTask.Status = 'Not Started';
                    objTask.Priority = 'Medium';
                    objTask.ownerId = '0050Y000001T9My';
                    objTask.WhatId = objLocation.id;
                    objTask.Process_Name__c = 'Handover';
                    lstTask.add(objTask);
                    
                    //objProperty.Send_For_Approval__c = true;
                    //lstProperty.add(objProperty);
                }
            }
            if (objLocation.Snag_Status__c != 'Completed') {
                if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Start with Snagging'))){
                    Task objTask = new Task();
                    objTask.Subject = 'Start with Snagging';
                    objTask.Status = 'Not Started';
                    objTask.Priority = 'Medium';
                    objTask.ownerId = '0050Y000001T9My';
                    objTask.WhatId = objLocation.id;
                    objTask.Process_Name__c = 'Handover';
                    lstTask.add(objTask);
                }
            }
            if(objLocation.As_Built_Drawings_Uploaded__c == true && objLocation.RERA_Audit_Flag__c == 'Complete'
                && objLocation.Approved_By_Authority__c == true && objLocation.Snag_Status__c == 'Completed') {
                    system.debug('!!!!!!!!inside review and upload');
                    if (setTaskSubjects == null || (setTaskSubjects != null && !setTaskSubjects.contains('Review and upload communications'))){
                        Task objTask = new Task();
                        objTask.Subject = 'Review and upload communications';
                        objTask.Status = 'Not Started';
                        objTask.Priority = 'Medium';
                        objTask.ownerId = '0050Y000001T9My';
                        objTask.WhatId = objLocation.id;
                        objTask.Process_Name__c = 'Handover';
                        lstTask.add(objTask);
                    }
                }
                /*system.debug('!!!!!!!!!!objLocation.Communications_Added__c'+objLocation.Communications_Added__c);
                if (objLocation.Communications_Added__c == true) {
                    system.debug('!!!!!!!!communications added'+mapLocationBookingUnits.get(objLocation.Id));
                    if (mapLocationBookingUnits != null && mapLocationBookingUnits.containsKey(objLocation.Id) 
                        && mapLocationBookingUnits.get(objLocation.Id) != null) {
                            for (Booking_Unit__c objBU : mapLocationBookingUnits.get(objLocation.Id)) {
                                objBU.Dispute_Flag__c = 'No';
                                objBU.Default__c = false;
                                objBU.Document_Received__c = true;
                                objBU.Deposit_Received__c = true;
                                objBU.Mortgage__c = false;
                                objBU.Booking_Undergoing_Termination__c = false;
                                objBU.Dispute__c = false;
                                objBU.Litigation__c = false;
                                objBU.Offers_Available__c = objLocation.Communications_to_be_Sent__c;
                                lstBookingUnits.add(objBU);
                                
                                set<String> setSubjects = mapLocationIdTask.get(objBU.id);
                                if (setSubjects == null || (setSubjects != null && !setSubjects.contains('Call Customer for Offer'))){
                                    Task objTask = new Task();
                                    objTask.Subject = 'Call Customer for Offer';
                                    objTask.Status = 'Not Started';
                                    objTask.Priority = 'Medium';
                                    objTask.ownerId = '0050Y000001SBsP';
                                    objTask.WhatId = objBU.id;
                                    objTask.Process_Name__c = 'Handover';
                                    lstTask.add(objTask);
                                }
                            }
                        }                   
                }*/
        }
        if (lstTask != null && lstTask.size() > 0) {
            insert lstTask;
        }
        
        if (lstBookingUnits != null && lstBookingUnits.size() > 0){
            update lstBookingUnits;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        Database.executeBatch(new BookingUnitUpdateBatch(),50);        
   }
    
}