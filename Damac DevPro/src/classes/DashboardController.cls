public with sharing class DashboardController {

    public Contact customerContact {get; set;}
    public Account customerAccount {get; set;}
    public Date myNextPaymentDate  {get;set;}          // Payment_Terms_del__r.Payment_Date__c
    public String strTotalInvestment {get; set;}      // Booking__c.Total_Booking_Amount__c
    public Decimal currentValue {get; set;}         //
    public Integer pendingPayments {get; set;}      // Case.Pending_Amount__c
    //public String strNextPaymentDate {get; set;}    //  CreatedDate for now
    public Integer pendingRequests {get; set;}      // Case count where NOT IsClosed

    private Decimal totalInvestment;
    private Date nextPaymentDate;

    public DashboardController() {
        totalInvestment = 0;
        pendingPayments = 0;
        pendingRequests = 0;
        List<User> lstUser =  [ SELECT  ContactId,
                                        Contact.AccountId
                                FROM    User
                                WHERE   Id = :UserInfo.getUserId()];
        if (!lstUser.isEmpty()) {
            Id customerAccountId = lstUser[0].ContactId == NULL || lstUser[0].Contact.AccountId == NULL
                                    ? '0017E00000dAXf9' : lstUser[0].Contact.AccountId; // Account Id hardcoded for now
            System.debug('customerAccountId = ' + customerAccountId);
            customerAccount = [ SELECT  Id,
                                        Name,
                                        FirstName,
                                        LastName,
                                        PersonEmail,
                                        (SELECT Id,
                                                Name,
                                                Total_Booking_Amount__c
                                        FROM    Bookings__r),
                                        (SELECT     Id,
                                                    CaseNumber,
                                                    Pending_Amount__c,
                                                    CreatedDate,
                                                    IsClosed
                                        FROM        Cases
                                        ORDER BY    CreatedDate)
                                FROM    Account
                                WHERE   Id = :customerAccountId];

            for (Booking__c booking : customerAccount.Bookings__r) {
                totalInvestment += (booking.Total_Booking_Amount__c == NULL ? 0 : booking.Total_Booking_Amount__c);
            }
            strTotalInvestment = getAmountInShortWords(totalInvestment);
            for (Case sr : customerAccount.Cases) {
                if (sr.Pending_Amount__c != NULL) {
                    pendingPayments++;
                    if (nextPaymentDate == NULL) {
                        nextPaymentDate = sr.CreatedDate.date();
                       // strNextPaymentDate = sr.CreatedDate.format('dd MMMM YYYY');
                    }
                }
                pendingRequests += (sr.IsClosed ? 0 : 1);
            }
            list<Booking_Unit__c> lstBookingUnit = [Select (Select Id,
                                                                   Payment_Amount__c, 
                                                                   Payment_Date__c, 
                                                                   Booking_Unit__c 
                                                              From Payment_Terms_del__r
                                                              order by Payment_Date__c desc),
                                                           (Select Id
                                                              From Payment_Plans__r)
                                                              ,Selling_Price__c
                                                      From Booking_Unit__c 
                                                     Where Booking__r.Account__c =: customerAccountId limit 7 ];
            system.debug('lstBookingUnit'+lstBookingUnit);
            for(Booking_Unit__c objBkgUnit : lstBookingUnit){
                for(Payment_Terms__c objPayment : objBkgUnit.Payment_Terms_del__r){
                    system.debug('objPayment.Payment_Date__c'+objPayment.Payment_Date__c);
                    if(objPayment.Payment_Date__c!= null
                    && objPayment.Payment_Date__c >= date.today()){
                    	system.debug('objPayment.Payment_Date__c'+objPayment.Payment_Date__c);
                        myNextPaymentDate = objPayment.Payment_Date__c; 
                    }
                }
            }
        }
    }

    public static String getAmountInShortWords(Decimal amount) {
        String strAmount = '0.00';
        List<String> lstDenomination = new List<String> {
            '', 'Thousand', 'Million', 'Billion', 'Trillion', 'Quadrillion', 'Quintillion', 'Sixtillion', 'Septillion'
        };
        Integer denominationIndex = 0;
        Decimal remainder = amount;
        strAmount = String.valueOf(amount.setScale(2)) + ' ' + lstDenomination[0];
        remainder = Math.mod((Integer) amount, 1000);
        while (remainder > 0) {
            strAmount = String.valueOf(amount.setScale(2)) + ' ' + lstDenomination[denominationIndex++];
            amount /= 1000;
            amount = amount.setScale(2);
            remainder = Math.mod((Integer) amount, 1000);
        }
        return strAmount;
    }

}