public class CreatePaymentTerm{

    @InvocableMethod public static void CreatePT(List<Service_Request__c> objlistSR){
        map<Id, Id> mapBookingUnitPP = new map<Id, Id>();
        set<Id> setBookingUnitId = new set<Id>();
        list<Payment_Terms__c> lstPaymentTerm = new list<Payment_Terms__c>();
        for (Service_Request__c objSR : objlistSR) {
            setBookingUnitId.add(objSR.Booking_Unit__c);
        }
        
        
        for (Payment_Plan__c objPP : [Select Id, Booking_Unit__c From Payment_Plan__c Where Booking_Unit__c IN: setBookingUnitId]) {
            mapBookingUnitPP.put(objPP.Booking_Unit__c , objPP.Id);
        }
        
        
        for (Service_Request__c objSR : objlistSR) {
            Payment_Terms__c objPaymentTerm = new Payment_Terms__c();
            objPaymentTerm.Booking_Unit__c = objSR.Booking_Unit__c;
            objPaymentTerm.Payment_Plan__c = mapBookingUnitPP.get(objSR.Booking_Unit__c);
            lstPaymentTerm.add(objPaymentTerm );
        }
        
        if (lstPaymentTerm.size() > 0) {
            insert lstPaymentTerm;
        }
    }
}