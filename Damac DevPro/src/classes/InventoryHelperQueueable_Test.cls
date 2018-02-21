/*
 * Test Class for InventoryHelper and InventoryQueueable.
 */
@isTest
private class InventoryHelperQueueable_Test {
    @testSetup static void setupData() {
        Inventory__c inv = new Inventory__c();
        inv.Property_Country__c = 'TestCountry';
        inv.Floor_ID__c = '123456F';
        inv.Property_ID__c = '324567';
        inv.Unit_Type__c = 'TestUnitType';
        inv.Building_ID__c = '324567B';
        inv.Building_Name__c = 'testBuildingName';
        inv.Property_Name__c = 'TestPropertyName';
        inv.Unit_ID__c = '23456U';
        insert inv;
        
        
        Inventory__c inv1 = new Inventory__c();
        inv1.Property_Country__c = 'TestCountry';
        inv1.Floor_ID__c = '123456F';
        inv1.Property_ID__c = '324567';
        inv1.Unit_Type__c = 'TestUnitType';
        inv1.Building_ID__c = '324567B';
        inv1.Building_Name__c = 'testBuildingName';
        inv1.Property_Name__c = 'TestPropertyName';
        inv1.Unit_ID__c = '23456U';
        insert inv1;
        
        List<Inv_Fld_Mapping__c> lstInv = new List<Inv_Fld_Mapping__c>();
        lstInv.add(new Inv_Fld_Mapping__c(Name='1',Field_API_Name__c='Property_ID__c',Inv_Field_API_Name__c='Property_ID__c',Is_Property__c = true,Is_Number_Conversion_Req__c = true));
        lstInv.add(new Inv_Fld_Mapping__c(Name='2',Field_API_Name__c='Currency_Of_Sale__c',Inv_Field_API_Name__c='Property_Country__c',Is_Property__c = true));
		lstInv.add(new Inv_Fld_Mapping__c(Name='3',Field_API_Name__c='Property_Name__c',Inv_Field_API_Name__c='Property_Name__c',Is_Property__c = true));
		lstInv.add(new Inv_Fld_Mapping__c(Name='4',Field_API_Name__c='Name',Inv_Field_API_Name__c='Property_Name__c',Is_Property__c = true));
		lstInv.add(new Inv_Fld_Mapping__c(Name='5',Field_API_Name__c='Location_ID__c',Inv_Field_API_Name__c='Building_ID__c',Is_Building__c = true));
		lstInv.add(new Inv_Fld_Mapping__c(Name='6',Field_API_Name__c='Building_Name__c',Inv_Field_API_Name__c='Building_Name__c',Is_Building__c = true));
		lstInv.add(new Inv_Fld_Mapping__c(Name='7',Field_API_Name__c='Location_ID__c',Inv_Field_API_Name__c='Floor_ID__c',Is_Floor__c = true));
		lstInv.add(new Inv_Fld_Mapping__c(Name='8',Field_API_Name__c='Location_ID__c',Inv_Field_API_Name__c='Unit_ID__c',Is_Unit__c = true));
		lstInv.add(new Inv_Fld_Mapping__c(Name='9',Field_API_Name__c='Unit_Type__c',Inv_Field_API_Name__c='Unit_Type__c',Is_Unit__c = true));
		insert lstInv;
            
            //Is_Building__c Is_Floor__c Is_Number_Conversion_Req__c Is_Property__c Is_Unit__c
               
    }
    
    @istest static void test_method1(){
        Test.startTest();
        List<Inventory__c> lstInv = [SELECT id,Unit_Location__c,Floor_Location__c,Property_Name__c,Property__c,Building_Location__c,Property_Country__c,Floor_ID__c,Property_ID__c,Unit_Type__c,Building_ID__c,Unit_ID__c,Building_Name__c from Inventory__c limit 1];
        InventoryHelper.createRec(lstinv);
		System.enqueueJob(new InventoryQueueable(lstinv));
        InventoryHelper.createRec(lstinv);
        System.enqueueJob(new InventoryQueueable(lstinv));
        Test.stopTest();
    }
    
    @istest static void test_method2(){
        Test.startTest();
        List<Inventory__c> lstInv = [SELECT id,Unit_Location__c,Floor_Location__c,Property_Name__c,Property__c,Building_Location__c,Property_Country__c,Floor_ID__c,Property_ID__c,Unit_Type__c,Building_ID__c,Unit_ID__c,Building_Name__c from Inventory__c];
        InventoryHelper.createRec(lstinv);
		System.enqueueJob(new InventoryQueueable(lstinv));
        InventoryHelper.createRec(lstinv);
        System.enqueueJob(new InventoryQueueable(lstinv));
        Test.stopTest();
    }
}