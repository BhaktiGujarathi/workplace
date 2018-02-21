public class CreateTasksForBookingUnit {

    public list<Booking_Unit__c> lstBookingUnits = new list<Booking_Unit__c>();
        
    public void createTasksForBookingUnits(){
        datetime dt = System.now()-1;
        lstBookingUnits = BookingUnitUpdateBatch.fetchAllBookingUnits();
        system.debug('lstBookingUnits for task creation'+lstBookingUnits);
        Map<Id, Set<String>> mapOfAccountIdWithTaskSubjects = new Map<Id, Set<String>>();
        List<Task> lstTaskToCreate = new List<Task>(); 

        for(Task objTask:[Select Id, Subject, WhatId 
                            FROM Task WHERE WhatId IN: lstBookingUnits]) 
        {   
            if(mapOfAccountIdWithTaskSubjects.containsKey(objTask.WhatId)) {
                set<String> setSubject = new Set<String>();
                setSubject = mapOfAccountIdWithTaskSubjects.get(objTask.WhatId);
                setSubject.add(objTask.Subject);
                mapOfAccountIdWithTaskSubjects.put(objTask.WhatId, setSubject);
            }
            else {
                set<String> setSubject = new Set<String>();
                setSubject.add(objTask.subject);
                mapOfAccountIdWithTaskSubjects.put(objTask.WhatId, setSubject);
                system.debug('mapOfAccountIdWithTaskSubjects'+mapOfAccountIdWithTaskSubjects);                                
            }
        }
        for (Id bookingUnitId :mapOfAccountIdWithTaskSubjects.keyset()) {
        system.debug('mapOfAccountIdWithTaskSubjects.get(bookingUnitId)'+mapOfAccountIdWithTaskSubjects.get(bookingUnitId));
            if(!mapOfAccountIdWithTaskSubjects.get(bookingUnitId).contains('Call Customer for Offer')) {                
                Task objNewTask = new Task();
                objNewTask.Subject = 'Call Customer for Offer';
                objNewTask.Status = 'Not Started';
                objNewTask.Priority = 'Medium';
                objNewTask.ownerId = '0050Y000001SBsP';
                objNewTask.WhatId = bookingUnitId;
                objNewTask.Process_Name__c = 'Handover';
                lstTaskToCreate.add(objNewTask);
            }
        }
        try {
            insert lstTaskToCreate;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        } 
        system.debug('task inseted');          
    }
}