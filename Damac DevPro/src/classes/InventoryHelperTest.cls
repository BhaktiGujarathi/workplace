@istest
public class InventoryHelperTest{



    static testmethod void  InventoryHelper_methods(){
        
       
        Test.startTest();
        
        
        Inv_Fld_Mapping__c fldmap = new Inv_Fld_Mapping__c();
        
        fldmap.name = '01';
        fldmap.Is_Property__c = true;
        fldmap.Is_Number_Conversion_Req__c = true;
        fldmap.Field_API_Name__c = 'Property_ID__c';
        fldmap.Inv_Field_API_Name__c = 'Property_ID__c';
        //fldmap
        insert fldmap;        
        
        Property__c  propertyDetail = InitialiseTestData.getPropertyDetails(7650);
        insert propertyDetail ; 
        
        Inventory__c inventory = InitialiseTestData.getInventoryDetails('3456','1234','2345',9086,7650); 
        insert inventory ; 
        
        inventory.Status__c = 'Released';
        update inventory ; 
        
        try{
        InventoryHelper.createRec(null);
        }catch(exception ex){
            
        }
        Test.stopTest();
        
    
        
    
    
    }



}