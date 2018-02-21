public class EarlyHandoverProcessController{
    
    public list<SelectOption> lstUnits {get;set;}
    public string strSelectedUnit {get;set;}
    public list<SelectOption> lstPOA {get;set;}
    public string strSelectedPOA {get;set;}
    public Power_of_Attorney__c objPowerOfAttorney {get;set;}
    public EarlyHandoverProcessController(){
        init();    
    }
    
    public void init(){
        
        lstUnits = new list<SelectOption>();
        lstUnits.add(new selectOption('--None--', '--None--'));
        for(Booking_Unit__c objBU : [Select Id
                                            , Name
                                            , Booking__c 
                                     from Booking_Unit__c
                                     where Booking__r.Account__c = '0017E00000MexTF']){
            
            lstUnits.add(new selectOption(objBU.Id, objBU.Name));
        }
        
        lstPOA = new list<SelectOption>();
        system.debug('!!!!!!!!strSelectedUnit'+strSelectedUnit);
        lstPOA.add(new selectOption('--None--', '--None--'));
        for(Power_of_Attorney__c objPOA : [Select Id
                                            , Name
                                            , Account__c
                                            , Date_of_Expiry__c
                                            , Issued_By__c
                                            , Relationship_with_Owner__c
                                            , SR__c
                                            , Account__r.Name
                                            , Booking_Unit__c
                                     from Power_of_Attorney__c 
                                     where Booking_Unit__c = 'a0x7E000005d3Su']){
            lstPOA.add(new selectOption(objPOA.Id, objPOA.Account__r.Name));
            objPowerOfAttorney = new Power_of_Attorney__c ();
        }
    
    }
}