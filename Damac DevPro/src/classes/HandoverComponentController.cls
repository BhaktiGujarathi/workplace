public with sharing class HandoverComponentController {
	
	public list<SelectOption> lstUnits {get;set;}
	public string strSelectedUnit {get;set;}
	public Power_of_Attorney__c objPOA {get;set;}
	public string strOverdues {get;set;}
    public string strPenalties {get;set;}
    public string strInstallFee {get;set;}
    public string strOtherDues {get;set;}
    public string strServiceChrg {get;set;}
    public string strTotalAmt {get;set;}
    public string strProjectBenefName {get;set;}
    public string strProjectBenefBank {get;set;}
    public string strProjectBenefAccNo {get;set;}
    public string strProjectBenefIBAN {get;set;}
    public string strProjectBenefBranch {get;set;}
    public string strProjectBenefSwift {get;set;}
    public string strServiceBenefName {get;set;}
    public string strServiceBenefBank {get;set;}
    public string strServiceBenefAccNo {get;set;}
    public string strServiceBenefIBAN {get;set;}
    public string strServiceBenefBranch {get;set;}
    public string strServiceBenefSwift {get;set;}
	 
	public HandoverComponentController(){
		objPOA = new Power_of_Attorney__c();
        init();
	}//End Constructor
    
	public void init(){
		lstUnits = new list<SelectOption>();
		strOverdues = 'XX';
        strPenalties = 'XX';
        strInstallFee = 'XX';
        strOtherDues = 'XX';
        strTotalAmt = 'XX';
        strServiceChrg = 'XX';
        strProjectBenefName = 'XX';
        strProjectBenefBank = 'XX';
        strProjectBenefAccNo = 'XX';
        strProjectBenefIBAN = 'XX';
        strProjectBenefBranch = 'XX';
        strProjectBenefSwift = 'XX';
        strServiceBenefName = 'XX';
        strServiceBenefBank = 'XX';
        strServiceBenefAccNo = 'XX';
        strServiceBenefIBAN = 'XX';
        strServiceBenefBranch = 'XX';
        strServiceBenefSwift = 'XX';
		lstUnits.add(new selectOption('--None--', '--None--'));
        for(Booking_Unit__c objBU : [Select Id,
                                            Name,
                                            Booking__c 
                                     from Booking_Unit__c
                                    where Booking__r.Account__c = '0017E00000cWKII']){
            lstUnits.add(new selectOption(objBU.Id, objBU.Name));
        }//End for 
        
	}
	
	 public Pagereference autoPopulateBUDetails(){
        system.debug('=strSelectedUnit=='+strSelectedUnit);
        for(Booking_Unit__c objBU : [select ID,
                                            Handover_Complete__c
                                       from Booking_Unit__c
                                      where ID =: strSelectedUnit]){
              
            strOverdues = '10';
            strPenalties = '20';
            strInstallFee = '200';
            strOtherDues = '30';
            strServiceChrg = '100';
            strTotalAmt = '360';
            strProjectBenefName = 'DAMAC';
        	strProjectBenefBank = 'Abu Dhabi Islamic Bank';
        	strProjectBenefAccNo = '1267893460';
        	strProjectBenefIBAN = 'AD001';
        	strProjectBenefBranch = 'Abu Dhabi';
        	strProjectBenefSwift = 'DUIBAEAD';
        	strServiceBenefName = 'DAMAC Services';
        	strServiceBenefBank = 'Abu Dhabi Islamic Bank';
        	strServiceBenefAccNo = '5487912658';
        	strServiceBenefIBAN = 'AD001';
        	strServiceBenefBranch = 'Abu Dhabi';
        	strServiceBenefSwift = 'DUIBAEAD';
         }//End for
         return null;
    }//end autoPopulateBUDetails
}