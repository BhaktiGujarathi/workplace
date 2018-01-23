global without sharing class UpdateCancelledAppointmentService {
	
    WebService static Boolean triggerAppointmentCancellation(Id eventId) {
        
        List<Event> appointmentsToCancelList = new List<Event>();
        List<Event> appointmentsToUpdate = new List<Event>();
        appointmentsToCancelList = [SELECT id,
                                           Subject,
                                           Appointment_Status__c
                                      FROM Event
                                     WHERE Id =:eventId];
        for(Event eventObj : appointmentsToCancelList) {
            eventObj.Subject = 'Appointment Cancelled'; 
            eventObj.Appointment_Status__c = 'Cancelled';
            appointmentsToUpdate.add(eventObj);
        }
        
        if(!appointmentsToUpdate.isEmpty()) {
            update appointmentsToUpdate;
            return true;
        }
        return false;
    }

}