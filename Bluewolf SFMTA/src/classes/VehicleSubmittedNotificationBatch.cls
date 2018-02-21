global class VehicleSubmittedNotificationBatch implements Database.Batchable<sObject>, Database.Stateful{

	global List<Vehicle__c> vehiclesToSendEmail;
	global String emailIsSendOrNot;

	global VehicleSubmittedNotificationBatch(){
		vehiclesToSendEmail = new List<Vehicle__c>();
	}

	/* * * * * * * * * * * * *
	*  Method Name:  start
	*  Purpose:      This method fetch the vehicles which are submitted today
	*  Param:        Database.BatchableContext
	* * * * * * * * * * * * */
	global Database.QueryLocator start( Database.BatchableContext BC ) {
		String query = 'SELECT Id,Name FROM Vehicle__c WHERE Status__c = \'Submitted - Pending Approval\' ';
			   query+= 'AND CreatedDate = TODAY';
		return Database.getQueryLocator(query);
	}

	/* * * * * * * * * * * * *
	*  Method Name:  execute
	*  Purpose:      This method collects all vehicles which are submitted today
	*  Param:        Database.BatchableContext , List<Vehicle__c>
	* * * * * * * * * * * * */
   	global void execute( Database.BatchableContext BC, List<Vehicle__c> scope ) {
		for ( Vehicle__c objVehicle : scope ) {
			vehiclesToSendEmail.add(objVehicle);
	    }
	}
	/* * * * * * * * * * * * *
	*  Method Name:  finish
	*  Purpose:      This method notify the public group members for vehcile submitted today
	*  Param:        Database.BatchableContext
	* * * * * * * * * * * * */
	global void finish( Database.BatchableContext BC ) {
		String vehiclesName = '';

	    for ( Vehicle__c objVehicle : vehiclesToSendEmail ) {
			vehiclesName += objVehicle.Name + ', ';
		}
		vehiclesName += vehiclesName.removeEnd(', ');
		String bodyOfEmail = 'Hi Team ,<br/> Below are all vehicle that got submitted today : <br/>' + vehiclesName;
		emailIsSendOrNot =  VehicleNotificationService.sendEmail( bodyOfEmail );
	}
}