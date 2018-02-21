/*
* Name : Pavithra Gajendra
* Date : 02/13/2017
* Purpose : Test class for Inventory Trigger Handler
* Company : NSI
* 
*/
@isTest
private class LocationTrgHandlerTest {
    static Location__c buildingLocation ; 
    static Location__c floorLocation ;
    static Location__c unitLocation ;
    
    /**
    *  Scenario 1 : Create location records to assign record type based on the location Type 
    **/
    @isTest static void createLocations() {
		Test.startTest();
	    buildingLocation = InitialiseTestData.getLocationDetails('1234','Building');
	    insert buildingLocation ;
	    floorLocation = InitialiseTestData.getLocationDetails('2345','Floor');
	    floorLocation.Building_Number__c = buildingLocation.Id ;
	    insert floorLocation ;
	    unitLocation = InitialiseTestData.getLocationDetails('3456','Unit');
	    unitLocation.Floor_Number__c = floorLocation.Id ;
	    insert unitLocation ;
		Test.stopTest();
	}
	

}