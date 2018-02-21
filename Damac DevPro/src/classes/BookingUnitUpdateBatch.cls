global class BookingUnitUpdateBatch implements Database.Batchable<sObject> {
    
    public Static List<Booking_Unit__c> fetchAllBookingUnits() {
        datetime dt = System.now()-1;
        list<Booking_Unit__c> lstBookingUnits = new list<Booking_Unit__c>();
        lstBookingUnits = [Select Id,Unit__c,Unit__r.Communications_to_be_Sent__c,Unit__r.Communications_Added__c,Unit__r.Communication_Added_Date__c from Booking_Unit__c where Unit__r.Communications_Added__c = true and Unit__r.Communication_Added_Date__c > :dt];        
        system.debug('lstBookingUnits '+lstBookingUnits);
        return lstBookingUnits;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        datetime dt = System.now()-1;
        return Database.getQueryLocator('Select Id,Unit__c,Unit__r.Communications_to_be_Sent__c,Unit__r.Communications_Added__c,Unit__r.Communication_Added_Date__c from Booking_Unit__c where Unit__r.Communications_Added__c = true and Unit__r.Communication_Added_Date__c > :dt');
    }
    
    global void execute(Database.BatchableContext BC, List<Booking_Unit__c> bookingUnitList) {
        
        list<Booking_Unit__c> lstBookingUnitsToUpdate = new list<Booking_Unit__c>();
        for(Booking_Unit__c bookingUnitRecord : bookingUnitList){
            bookingUnitRecord.Dispute_Flag__c = 'No';
            bookingUnitRecord.Default__c = false;
            bookingUnitRecord.Document_Received__c = true;
            bookingUnitRecord.Deposit_Received__c = true;
            bookingUnitRecord.Mortgage__c = false;
            bookingUnitRecord.Booking_Undergoing_Termination__c = false;
            bookingUnitRecord.Dispute__c = false;
            bookingUnitRecord.Litigation__c = false;
            bookingUnitRecord.Offers_Available__c = bookingUnitRecord.Unit__r.Communications_to_be_Sent__c;
            lstBookingUnitsToUpdate.add(bookingUnitRecord);
        }
        system.debug('lstBookingUnitsToUpdate'+lstBookingUnitsToUpdate);
        try {
            update lstBookingUnitsToUpdate;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }          
        system.debug('Updated');
        CreateTasksForBookingUnit objCreateTasksForBookingUnit = new CreateTasksForBookingUnit();
        objCreateTasksForBookingUnit.createTasksForBookingUnits();
        
    }
    
    global void finish(Database.BatchableContext BC) {
    
    }
}