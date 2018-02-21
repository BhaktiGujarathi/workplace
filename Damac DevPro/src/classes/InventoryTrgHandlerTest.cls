/*
* Name : Pavithra Gajendra
* Date : 02/12/2017
* Purpose : Test class for Inventory Trigger Handler
* Company : NSI
* 
*/
@isTest
private class InventoryTrgHandlerTest {
     static Location__c loc ; 
     static Inventory__c inventory ; 
     static Address__c addressDetail ; 
     static Property__c propertyDetail ; 
    
    @isTest static void createInventory() {
		Test.startTest();
	    loc = InitialiseTestData.getLocationDetails('1234','Building');
	    insert loc ;
	    loc = InitialiseTestData.getLocationDetails('2345','Floor');
	    insert loc ;
	    loc = InitialiseTestData.getLocationDetails('3456','Unit');
	    insert loc ;
	    addressDetail = InitialiseTestData.getAddressDetails(9086);
	    //insert addressDetail ; 
	    propertyDetail = InitialiseTestData.getPropertyDetails(7650);
	    insert propertyDetail ; 
	    inventory = InitialiseTestData.getInventoryDetails('3456','1234','2345',9086,7650); 
	    insert inventory ; 
	    inventory.Status__c = 'Released';
	    update inventory ; 
		Test.stopTest();
	}

}