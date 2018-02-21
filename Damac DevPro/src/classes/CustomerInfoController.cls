public with sharing class CustomerInfoController {

    public Account accountObj                               {get; set;}
    public list<Booking_Unit__c> lstBKGUnit                 {get; set;}
    public Double dblTotalrevenue                           {get; set;}
    public Double dblPendingAmount                          {get; set;}
    public DateTime dtNextPaymentDate                       {get; set;}
    public list<PortfolioWrapper>lstPortWrapper             {get; set;} 
    public String strRecordId {
        get;
        set {
            strRecordId = value;
            system.debug('test'+strRecordId);
            fetchAccount();
        }
    }

    public CustomerInfoController(){
        string StrRecordId1 = Apexpages.currentPage().getparameters().get('Id');
        accountObj =  new Account();
        dblTotalrevenue = 0.0;
        lstPortWrapper = new list<PortfolioWrapper>();
    }
    
    public void fetchAccount(){
        system.debug('StrRecordId'+StrRecordId);
        lstBKGUnit = new list<Booking_Unit__c>();
        lstPortWrapper = new list<PortfolioWrapper>();
        //dtNextPaymentDate = new DateTime();
        dblPendingAmount = 0.0;
        dblTotalrevenue = 0.0;
        if(StrRecordId!= null){
            accountObj = [SELECT id,
                                 Name,
                                 PersonEmail,
                                 Phone,
                                 shippingState,
                                 shippingCountry,
                                 (Select Id,
                                         CurrencyIsoCode, 
                                         Account__c, 
                                         Account__r.name,
                                         Booking_Units_DP_Overdue_Count__c, 
                                         International_Booking_Units_Count__c, 
                                         Total_Units_Booked__c, 
                                         Total_Booking_Amount__c, 
                                         No_Of_Booking_Units__c, 
                                         Total_Token_Amount_AED__c 
                                    From Bookings__r) 
                            FROM Account
                           WHERE id =: StrRecordId limit 7];
            system.debug('------'+accountObj.Bookings__r);
            system.debug('------'+accountObj);
            for(Booking__c objBooking : accountObj.Bookings__r){
                //lstbooking.add(objBooking);
               // system.debug('------'+lstbooking);
                dblTotalrevenue += objBooking.Total_Booking_Amount__c; 
            }
        }
        if(StrRecordId!= null){
		       lstBKGUnit = [Select Booking_Unit_Type__c,
						         Area__c,
						         Name,
						         Token_Amount_val__c,
						         CreatedDate,
						         Token_Paid__c,
						         Status__c,
						         Booking__r.Total_Units_Booked__c,
						         Booking__r.Status_Text__c,
						         Booking__r.DP_Overdue__c,
						         Booking__r.DP_Due_Date__c,
						         Booking__r.No_Of_Units__c,
						         Booking__r.Status__c,
						         Booking__r.Completed_Date__c,
						         Booking__r.Account__c,
						         Booking__r.CreatedDate,
						         Booking__r.CurrencyIsoCode,
						         Booking__c,
						         Inventory__c,
						         Inventory__r.Property__c,
						         Inventory__r.Property__r.Name,
						         Booking__r.Total_Token_Amount_AED__c,
						         Booking__r.Total_Booking_Amount__c,
						         (Select Id,
                                         Payment_Amount__c, 
                                         Payment_Date__c, 
                                         Booking_Unit__c 
                                    From Payment_Terms_del__r
                                   order by Payment_Date__c desc)
						    From Booking_Unit__c
						   where Booking__r.Account__c =:StrRecordId limit 7]; 
        }
        system.debug('lstBKGUnit'+lstBKGUnit);
        for(Booking_Unit__c objBkgUnit: lstBKGUnit){
           PortfolioWrapper objWrapper = new PortfolioWrapper();
           for(Payment_Terms__c objPT : objBkgUnit.Payment_Terms_del__r){
              if(objPT.Payment_Date__c!= null
                    && objPT.Payment_Date__c >= date.today()){
                    objWrapper.dateNextpaymentdate = objPT.Payment_Date__c; 
                    objWrapper.dblNextpaymentAmount = objPT.Payment_Amount__c;
               }
           }
           if(objBkgUnit.Inventory__c != null
           && objBkgUnit.Inventory__r.Property__c != null){
                objWrapper.strPropoertyName = objBkgUnit.Inventory__r.Property__r.Name;
           }
           objWrapper.strUnitType = objBkgUnit.Booking_Unit_Type__c;
           objWrapper.dateBookingDate = objBkgUnit.CreatedDate;
           objWrapper.dblBookingprice = objBkgUnit.Token_Amount_val__c;
           objWrapper.dblArea = objBkgUnit.Area__c;
           if(objBkgUnit.Token_Paid__c == true){
                objWrapper.dblAmountpaid = objBkgUnit.Token_Amount_val__c;
           }
           objWrapper.strStatus = objBkgUnit.Status__c;
           lstPortWrapper.add(objWrapper);
           system.debug('objWrapper---------'+objWrapper);
          // objWrapper.dateCompletiondate = ;
          // objWrapper.dblNextpaymentAmount = ;
        }
        for(PortfolioWrapper objPortFolio : lstPortWrapper){
            datetime objDT;
            system.debug('objPortFolio'+objPortFolio);
            if(objPortFolio.dateNextpaymentdate != null)
                objDT = objPortFolio.dateNextpaymentdate;
                system.debug('objDT'+objDT);
                if(objDT >= date.today() && dtNextPaymentDate!= null){
                    if(dtNextPaymentDate >= objDT){
                        dtNextPaymentDate = objDT;
                    } 	
                }else{
                    dtNextPaymentDate = objDT;
                }
            }{
        }
    }
    
    public class PortfolioWrapper{
        public string strPropoertyName              {get;set;}
        public String strUnitType                   {get;set;}
        public datetime dateBookingDate             {get;set;}
        public double dblBookingprice               {get;set;}
        public double dblArea                       {get;set;}
        public double dblAmountpaid                 {get;set;}
        public string strStatus                     {get;set;}
        public Date dateCompletiondate              {get;set;}
        public Date dateNextpaymentdate             {get;set;}
        public string dblNextpaymentAmount          {get;set;}
        
        public void PortfolioWrapper(){
            strPropoertyName='';
            strUnitType = '';
            dblArea=0.0;
            dblAmountpaid =0.0;
            strStatus='';
            dblNextpaymentAmount='';
        }
    }
}