public class UpdatePromotionOnBookingUnit{

    @InvocableMethod public static void updateBU(List<Property__c> objlistProperty){
        system.debug('!!!!objlistProperty'+objlistProperty);
        set<Id> setPropertyId = new set<Id>();
        set<Id> setInventoryId = new set<Id>();
        list<Booking_Unit__c> lstBookingUnit = new list<Booking_Unit__c>();
        for (Property__c objProprty : objlistProperty) {
            setPropertyId.add(objProprty.id);
        }
        
        for (Inventory__c objInventory : [Select Id, Property__c From Inventory__c Where Property__c IN: setPropertyId]) {
            setInventoryId.add(objInventory.Id);
            //system.debug('!!!!!!!!!mapPropertyInventoryId.values()'+mapPropertyInventoryId.values());
        }
        
        for (Booking_Unit__c objBookingUnit : [Select Id, Related_Promotion__c, Inventory__c FROM Booking_Unit__c Where Inventory__c IN: setInventoryId]) {
            objBookingUnit.Related_Promotion__c = 'a1R7E000000ckmNUAQ';
            lstBookingUnit.add(objBookingUnit);
        }
        
        if (lstBookingUnit.size() > 0) {
            update lstBookingUnit;
        }
    }

}