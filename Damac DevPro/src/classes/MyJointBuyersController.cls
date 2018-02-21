public with sharing class MyJointBuyersController {

     public Id personAccountId{get; set{
            personAccountId = value;  
            wrapperListMethod();
        }}
    public List<wrapper> wrapperList {get; set;} 

    public MyJointBuyersController(){
        wrapperList = new list<wrapper>();
    }
    
    public void wrapperListMethod() {
        if(personAccountId!= null){
            
            List<Booking_Unit__c> bookingUnitList = [SELECT Inventory__r.Unit_Location__r.Unit_Name__c,
                                                            Inventory__r.Property_Name_2__c,
                                                            Unit_Details__c, Selling_Price__c,
                                                            Booking__c
                                                       FROM Booking_Unit__c
                                                      WHERE Booking__r.Account__c =: personAccountId];
            
            if(!bookingUnitList.isEmpty()){
              Set<String> bookingIds = new Set<String>();
              Map<String, Booking_Unit__c> booking_bookingUnit = new Map<String, Booking_Unit__c>();
              for(Booking_Unit__c bookingUnitObj : bookingUnitList){
                bookingIds.add(bookingUnitObj.Booking__c);
                booking_bookingUnit.put(bookingUnitObj .Booking__c, bookingUnitObj);
              }
              List<Joint_Buyer__c> lstJointBuyer = [SELECT Account__c,
                                                           Account__r.Name,
                                                           Booking__c
                                                      FROM Joint_Buyer__c
                                                     WHERE Booking__c IN :bookingIds
                                                       AND Account__c != :personAccountId];
              for( Joint_Buyer__c jointBuyerObj : lstJointBuyer ){
                Wrapper wrapperObj = new Wrapper();
                wrapperObj.accId = jointBuyerObj.Account__c;
                wrapperObj.accName = jointBuyerObj.Account__r.Name;
                wrapperObj.projName = booking_bookingUnit.get(jointBuyerObj.Booking__c).Inventory__r.Property_Name_2__c;
                wrapperObj.amount = String.valueOf(booking_bookingUnit.get(jointBuyerObj.Booking__c).Selling_Price__c);
                wrapperObj.unitName = booking_bookingUnit.get(jointBuyerObj.Booking__c).Inventory__r.Unit_Location__r.Unit_Name__c;
                wrapperList.add(wrapperObj);
              }
        }
        }
        //return wrapperList;
    }
    
    public class Wrapper{
        public string accId{get; set;}
        public string accName{get; set;}
        public string projName{get; set;}
        public string amount{get; set;}
        public string unitName{get; set;}
    }
}