public class UpdateBookingUnit{

    @InvocableMethod public static void updateBU(List<Property__c> objlistProperty){
        
        set<Id> setPropertyId = new set<Id>();
        set<Id> setInventoryId = new set<Id>();
        list<Booking_Unit__c> lstBookingUnit = new list<Booking_Unit__c>();
        for (Property__c objProprty : objlistProperty) {
            setPropertyId.add(objProprty.id);
        }
        
        for (Inventory__c objInventory : [Select Id, Property__c From Inventory__c Where Property__c IN: setPropertyId]) {
            setInventoryId.add(objInventory.Id);
        }
        
        for (Booking_Unit__c objBookingUnit : [Select Id, Related_Promotion__c, Inventory__c FROM Booking_Unit__c Where Inventory__c IN: setInventoryId]) {
            objBookingUnit.Handover_Flag__c = 'Ready For Handover';
            objBookingUnit.Handover_Date__c = Date.Today() + 30;
            lstBookingUnit.add(objBookingUnit);
        }
        
        if (lstBookingUnit.size() > 0) {
            update lstBookingUnit;
        }
    }


}