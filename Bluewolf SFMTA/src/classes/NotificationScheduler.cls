global class NotificationScheduler implements Schedulable {
   global void execute( SchedulableContext sc ) {
      VehicleSubmittedNotificationBatch objVehicleSubmittedBatch = new VehicleSubmittedNotificationBatch(); 
      database.executebatch( objVehicleSubmittedBatch );
   }
}