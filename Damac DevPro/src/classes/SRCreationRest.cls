@RestResource(UrlMapping = '/SrCaretion/*')
global class SRCreationRest{

   
   global class InvetoryList{
   
   String PropertName ;
   String PropertCity;
   String BuildingName ;
   String ProprtyID  ;
   String BuildingID ;
   String ErrorMessage ;
   }

   

   @HttpPost
   global static InvetoryList InventoryList(String UnitId , String DeliveryMethod){
   
   InvetoryList obj = new InvetoryList();
  
   if(!String.isBlank(UnitId)){
    
if(!String.isBlank(DeliveryMethod)){    
   Inventory__c Inventory  = [Select Id ,
                      Property_Name_2__c,
                      Property_City__c,
                      Building_Name__c,
                      Inventory_ID__c,
                      Property_ID__c,
                      Building_ID__c from Inventory__c where Unit__c =:UnitId ];
                      
                                            

   obj.PropertName  = Inventory .Property_Name_2__c;
   obj.PropertCity= Inventory .Property_City__c;
   obj.BuildingName = Inventory .Building_Name__c;
   obj.ProprtyID  = Inventory .Property_ID__c;
   obj.BuildingID = Inventory .Building_ID__c ;
   
}
else{

obj.ErrorMessage = 'Please Select a valid SPA Method to proceed.';  
    
}
   
   }
   
   else{
       
       obj.ErrorMessage = 'Please Select an inventory.';
       
   }

   
    return  obj;
   }

}