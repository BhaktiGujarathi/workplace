public with sharing class ProceedWithHandoverController {
    
    public list<BookingUnitWrapper> lstBUWrapper {get;set;}
    public string strPageIDTemp;
    public ProceedWithHandoverController(ApexPages.standardController controller){
       
    }//End constructor
    
    public pagereference init(){
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        strPageIDTemp = strPageID;
        lstBUWrapper = new list<BookingUnitWrapper>();
        List<Booking_Unit__c> lstBookingUnit = new List<Booking_Unit__c>();
        for (Inventory__c objInventory : [Select Id, Building_Location__c ,
                                                (Select Id, Unit_Details__c, Name, Handover_Readiness_Checklist__c, 
                                                        JOPD_Area__c, Approved_By_HOD__c, Early_Handover__c,
                                                        Handover_Complete__c
                                                 From Booking_Units__r)
                                              From Inventory__c 
                                              Where Building_Location__c =: strPageID]) {
            lstBookingUnit.addAll(objInventory.Booking_Units__r);                           
        }
        
        for (Booking_Unit__c objBU : lstBookingUnit) {
            if (objBU.Handover_Readiness_Checklist__c == true && objBU.Handover_Complete__c == false
                && objBU.Early_Handover__c == false){
                BookingUnitWrapper buWrapper = new BookingUnitWrapper();
                buWrapper.isSelect = false;
                buWrapper.bookingUnit = objBU;               
                lstBUWrapper.add(buWrapper);
                system.debug('lstBUWrapper'+lstBUWrapper);                
            } 
        }
            if(lstBUWrapper.size()==0) {
                ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'No Records Found' );
                ApexPages.addmessage(msg);
                return null; 
            } else {
                return null;
        }
    }
    
    public Pagereference proceedWithHandover(){
        List<Booking_Unit__c> lstBU = new List<Booking_Unit__c>();
        for (BookingUnitWrapper objWrapper : lstBUWrapper) {
            if (objWrapper.isSelect == true){
                lstBU.add(objWrapper.bookingUnit);
            }
        }
        
        list<Booking_Unit__c> lstUpdateBU = new list<Booking_Unit__c>();
        for (Booking_Unit__c objBU : lstBU){
            objBU.Approved_By_HOD__c = true;
            lstUpdateBU.add(objBU);
        }
        
        if (lstUpdateBU != null && lstUpdateBU.size()> 0){
            update lstUpdateBU;
        }
        
        return null;
    }
    
    public class BookingUnitWrapper {
        public Boolean isSelect {get;set;}
        public Booking_Unit__c bookingUnit {get;set;}
    }
    
    public pagereference backMethod()
    {
      system.debug('location__c.Id'+location__c.Id);
      Pagereference pg =  new Pagereference('/'+strPageIDTemp); 
      pg.setRedirect(true);
      return pg;
    }
    
}