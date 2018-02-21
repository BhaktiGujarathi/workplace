public with sharing class VerifyCustomer{
    
  
    
    public VerifyCustomer(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        list<Booking_Unit__c> lstBU = new list<Booking_Unit__c>();
        string strPageID = ApexPages.currentPage().getParameters().get('id');
        
        for(Booking_Unit__c objBookingUnit : [select ID,
                                                     Customer_Status__c
                                                from Booking_Unit__c 
                                               where ID =: strPageID ]){
                  objBookingUnit.Customer_Status__c = 'No Fault';
                  lstBU.add(objBookingUnit);
                                           
          }//End for
        
        update lstBU;
       
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
        
    }//End init
}