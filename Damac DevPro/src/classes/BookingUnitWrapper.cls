/* 
   Use : Common class for Token and customer refund processes
   Created By : Swapnil Gholap
*/
public Class BookingUnitWrapper {
        public Id bookingUnitId {get; set;}
        public Boolean blnIsSelected {get; set;}
        public String strPropertyName {get; set;}
        public String strUnitName {get; set;}
        public Decimal decUnitValue {get; set;}
        public String strPropertyStatus {get; set;}
        public String strACD {get; set;}
        public String regId {get; set;}      
        public Decimal decToken {get; set;} 
        public Boolean blnIsBulkDeal {get; set;}
        public String strUnitStatus {get; set;}
        public Boolean blnIsOlderThan3Months {get; set;}
        public Boolean blnIsURCSigned {get; set;}
        public String strPaymentMethod {get; set;}
        public Boolean blnMortgage {get;set;}
        public Decimal decExcessAmt_RefundLiability {get;set;}
        
        public BookingUnitWrapper() {
            blnIsSelected = false;
            blnIsBulkDeal = false;
        }
    }