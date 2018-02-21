/**************************************************************************************************
* Name               : DamacHomeController                                               
* Description        : An apex page controller for                                              
* Created Date       : NSI - Diana                                                                        
* Created By         : 17/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          17/Jan/2017                                                               
**************************************************************************************************/
public without sharing class DamacHomeController {
/**************************************************************************************************
            Variables used in the class
**************************************************************************************************/
    public boolean isAdminAccount{set;get;}
    
    private Contact contactInfo;
    
    private static Map<Integer, String> monthsMap = new Map<Integer, String>{
      1=>'Jan',
      2=>'Feb',
      3=>'Mar',
      4=>'Apr',
      5=>'May',
      6=>'Jun',
      7=>'Jul',
      8=>'Aug',
      9=>'Sep',
      10=>'Oct',
      11=>'Nov',
      12=>'Dec'
    };
        
    private static Map<String,String> colorMap = new Map<String,String>{
            'SILVER'=>'#A7A9AC',
                'GOLD'=>'#DEB815',
                'PLATINUM'=>'#BAB7B8'
                };
    
   
    public String dpDocsOK{set;get;} 
    public String rejected{set;get;} 
    public String awaitingDPDocsOK{set;get;} 
    public List<MonthlySales> monthlySalesList{set;get;}
    public Integer monthlySalesListSize{set;get;}
    public List<Integer> salesYaxis{set;get;}
    private Id accountId;
    private Date currentDate;
    private Date twoMonthsBackDate;
    
    public String unpaidDue{set;get;}
    public String paid{set;get;}
    public List<MonthlyBrokerage> monthlyBrokerageList{set;get;} 
    public Integer monthlyBrokerageListSize{set;get;}
    public List<Integer> brokerageXAxis{set;get;}
    
    public String overdueDPDocs{set;get;}
    public string overdueDPOnly{set;get;}
    public String overdueDocsOnly{set;get;}
    public String zeroto7days {set;get;}
    public String sevento15days{set;get;}
    public String fifteento30days{set;get;}
    public String morethanThirty{set;get;}
    public List<DPDocsOverdue> dpDocsOverDueList{set;get;}
    public Integer dpDocsOverDueListSize{set;get;} 
    public List<Integer> dpDocsYAxis{set;get;}
    
    private Date sevenDaysBackDate{set;get;}
    private Date eightDaysBackDate{set;get;}
    private Date fifteenDaysBackDate{set;get;}
    private Date sixteenDaysBackDate{set;get;}
    private Date thirtyDaysBackDate{set;get;}
    private Date moreThanThrityDays{set;get;}
   
    public Decimal currentQuarterSalesVal{set;get;}
    public String currentQuarterName{set;get;}
    
    public String annualTierName{set;get;}
    public Decimal annualSalesVal{set;get;}
    
    public List<gaugeData> quarterSalesData{set;get;}
    public List<gaugeData> annualSalesData{set;get;}
    
    public String quarterSalesTierColor{set;get;}
    public String annualSalesTierColor{set;get;}
    public Boolean isEligibleForTierProgram{set;get;}


/**************************************************************************************************
    Method:         DamacHomeController
    Description:    Constructor executing model of the class 
**************************************************************************************************/
  
  public DamacHomeController() {
      
        currentDate = System.now().date();
      
        dpDocsOK  = 'DP/DOCs OK';
        rejected  = 'Rejected';
        awaitingDPDocsOK  = 'Awaiting DP/DOCs';  
        
        Date firstDateOfCurrentMonth = Date.newInstance(currentDate.year(), currentDate.month(), 1);
        twoMonthsBackDate = firstDateOfCurrentMonth.addMonths(-2);
       
        contactInfo = UtilityQueryManager.getContactInformation();
         //accountId = UtilityQueryManager.getAccountId();
         if(null != contactInfo){

          for(Account currentUserAccount:[SELECT Eligible_For_Tier_Program__c FROM Account where Id=:contactInfo.AccountID]){
            isEligibleForTierProgram = currentUserAccount.Eligible_For_Tier_Program__c;
          }
          accountId = contactInfo.AccountID;
        }
        
        isAdminAccount = ((contactInfo.Authorised_Signatory__c || 
                 contactInfo.Portal_Administrator__c || contactInfo.Owner__c) == true)?true:false;

        monthlySalesList = new List<MonthlySales>();
        monthlyBrokerageList = new List<MonthlyBrokerage>();
        brokerageXAxis = new List<Integer>();
        monthlySalesListSize = 0;
        monthlyBrokerageListSize = 0;
        dpDocsOverDueListSize = 0;
        
        zeroto7days = '0-7 Days';
        sevento15days = '7-15 Days';
        fifteento30days = '15-30 Days';
        morethanThirty = '>30 Days';
        
        dpDocsOverDueList = new List<DPDocsOverdue>();
        
        getMonthlySales();
        currentQuarterSalesVal = 0;
        annualSalesVal = 0;
        
        unpaidDue = 'Unpaid Due';
        paid = 'Paid';
        
        quarterSalesData = new List<gaugeData>();
        annualSalesData = new List<gaugeData>();
        dpDocsYAxis = new List<Integer>();
        if(isAdminAccount){
           getMonthlyBrokerage();
           getDPDocsOverdue();
           getTierSalesReport();
        }
        
       
       
  }
  
  private void getMonthlyBrokerage(){
      Map<String,Map<String,Decimal>> mapMonthlyBrokerage = new Map<String,Map<String,Decimal>>();
      Decimal commissionAmount = null;

      system.debug('***twoMonthsBackDate '+twoMonthsBackDate);
      system.debug('***accountId '+accountId);

      for(Agent_Commission__c thisCommission:[SELECT Agency__c,Amount__c,Registration_Date__c,Check_Date__c
                                              FROM Agent_Commission__c
                                              WHERE Agency__c = :accountID
                                              AND Registration_Date__c != null
                                              AND Registration_Date__c>= :twoMonthsBackDate
                                              AND Registration_Date__c <= :currentDate
                                              AND Internal_Verification__c = 'Y'
                                              ORDER BY Registration_Date__c ASC]){
        String monthYear = convertMonthNumberToString(thisCommission.Registration_Date__c.Month())+' - '+thisCommission.Registration_Date__c.Year();
        system.debug('***monthYear'+monthYear);
        system.debug('***thisCommission'+thisCommission);
        String currentCommissionStatus = '';

        if(thisCommission.Check_Date__c != NULL){
          currentCommissionStatus = paid;
        }
        else{
          currentCommissionStatus = unpaidDue;
        }
        system.debug('***currentCommissionStatus '+currentCommissionStatus);

        Map<String,Decimal> monthYearCommissionValMatch = new Map<String,Decimal>();
        if(null != currentCommissionStatus && currentCommissionStatus != ''){
            if(mapMonthlyBrokerage.containsKey(monthYear)){
              monthYearCommissionValMatch = mapMonthlyBrokerage.get(monthYear);
            }else{
  
              mapMonthlyBrokerage.put(monthYear,monthYearCommissionValMatch);
            }
            if(monthYearCommissionValMatch.containsKey(currentCommissionStatus)){
                commissionAmount = monthYearCommissionValMatch.get(currentCommissionStatus)+(thisCommission.Amount__c);
                monthYearCommissionValMatch.put(currentCommissionStatus,commissionAmount);
             }
             else{
               commissionAmount = (thisCommission.Amount__c);
                monthYearCommissionValMatch.put(currentCommissionStatus,commissionAmount);
             }
             mapMonthlyBrokerage.put(monthYear,monthYearCommissionValMatch);
        }

      }

      for(String monthYearKey:mapMonthlyBrokerage.keySet()){
         Map<String,Decimal> statusCommissionMap = mapMonthlyBrokerage.get(monthYearKey);
         MonthlyBrokerage monthlyBrokerageWrapper = new MonthlyBrokerage();
         monthlyBrokerageWrapper.monthYear = monthYearKey;

         for(String statusKey:statusCommissionMap.keySet()){
            monthlyBrokerageWrapper.paidVal = (statusKey == paid)?(convertThousandToDecimal(statusCommissionMap.get(statusKey))) : monthlyBrokerageWrapper.paidVal;
            monthlyBrokerageWrapper.unpaidDueVal = (statusKey == unpaidDue)?(convertThousandToDecimal(statusCommissionMap.get(statusKey))) : monthlyBrokerageWrapper.unpaidDueVal;
         }
         monthlyBrokerageList.add(monthlyBrokerageWrapper);
         
      }
      monthlyBrokerageListSize = monthlyBrokerageList.size(); 
      if(monthlyBrokerageList.size() == 0 ){
          String monthYear = convertMonthNumberToString(currentDate.Month())+' - '+ currentDate.Year();
          
          MonthlyBrokerage monthlyBrokerageWrapper = new MonthlyBrokerage();
          monthlyBrokerageWrapper.monthYear = '';
          monthlyBrokerageWrapper.paidVal = 0;
          monthlyBrokerageWrapper.unpaidDueVal = 0;
          monthlyBrokerageList.add(monthlyBrokerageWrapper);
      }
   createBrokerageXAxis();
  }
  
  private void createBrokerageXAxis(){

    Decimal maxAmount = 100;

    for(AggregateResult thisCommission:[SELECT sum(Amount__c) maxAmount
                                        FROM Agent_Commission__c 
                                        WHERE Agency__c=:accountID
                                        AND Registration_Date__c>= :twoMonthsBackDate 
                                        AND Internal_Verification__c='Y' 
                                        AND Registration_Date__c <= :currentDate
                                        GROUP BY CALENDAR_MONTH(Registration_Date__c) 
                                        order by sum(Amount__c) DESC LIMIT 1]){
      
      if(null != thisCommission.get('maxAmount'))
        maxAmount = (Decimal)thisCommission.get('maxAmount');
    }

    Integer maxRange = 100;
    if(maxAmount<50000){
       maxRange  = 50;
    }
    else if(maxAmount>50000 && maxAmount<100000){
     maxRange = 100;
    }
    else if(maxAmount>100000 && maxAmount<150000){
     maxRange =150;
    }
    else{
     Integer noOfZeroes= String.valueOf((Integer)Math.ceil(maxAmount/1000)).length()-1;
     Integer multiply = (Integer)Math.pow(10,noOfZeroes);
     maxRange =(Integer.valueOf(String.valueOf(maxAmount).Substring(0,1))+1)*(multiply);
    }

    for(Integer i=0;i<maxRange;i++){
     brokerageXAxis.add(maxRange/10+i*maxRange/10); 
     if(maxRange == maxRange/10+i*maxRange/10){
       break;
     }
    }
  }

  private void getMonthlySales(){
      Map<String,Map<String,Decimal>> mapMonthlySales = new Map<String,Map<String,Decimal>>();
      Decimal salesAmount = null;
      salesYaxis = new List<Integer>();
      
      system.debug('***twoMonthsBackDate '+twoMonthsBackDate);
      system.debug('***accountId '+accountId);
      
      for(Booking__c thisBooking:[SELECT Total_Booking_Amount__c,Status__c,Deal_SR__r.Registration_Date__c,
                                  Deal_SR__r.DP_ok__c,Deal_SR__r.Doc_ok__c,Rejected__c
                                  from Booking__c 
                                  WHERE Deal_SR__r.Agency__c=: accountId 
                                  AND Deal_SR__r.Registration_Date__c != null
                                  AND Deal_SR__r.Registration_Date__c>= :twoMonthsBackDate
                                  AND Deal_SR__r.Registration_Date__c <= :System.now().Date()
                                  ORDER BY Deal_SR__r.Registration_Date__c ASC]){
         
          String monthYear = convertMonthNumberToString(thisBooking.Deal_SR__r.Registration_Date__c.Month())+' - '+ thisBooking.Deal_SR__r.Registration_Date__c.Year();
          
          String currentBookingStatus = '';
          
          system.debug('***monthYear'+monthYear);
         
          //status is AR or TO --> Booked but rejected
          if(thisBooking.Rejected__c){
            
             currentBookingStatus = rejected;
          }
          //DP_ok__c is true and Doc_ok__c is true --> DP/Docs OK
          else if(thisBooking.Deal_SR__r.DP_ok__c && thisBooking.Deal_SR__r.Doc_ok__c){
              
              currentBookingStatus = dpDocsOK;
          }
          // If anyone is pending among DP_ok__c OR Doc_ok__c --> Booked but awaiting DP/Docs OK
          else if(!thisBooking.Deal_SR__r.DP_ok__c || !thisBooking.Deal_SR__r.Doc_ok__c){
              currentBookingStatus = awaitingDPDocsOK;
          }
          
          system.debug('***status '+currentBookingStatus);
         
          Map<String,Decimal> monthYearSalesValMatch = new Map<String,Decimal>();

          if(null != currentBookingStatus && currentBookingStatus != ''){
              if(mapMonthlySales.containsKey(monthYear)){
                monthYearSalesValMatch = mapMonthlySales.get(monthYear);
              }else{
    
                mapMonthlySales.put(monthYear,monthYearSalesValMatch);
              }
              if(monthYearSalesValMatch.containsKey(currentBookingStatus)){
                  salesAmount = monthYearSalesValMatch.get(currentBookingStatus)+convertMillionToDecimal(thisBooking.Total_Booking_Amount__c);
                  monthYearSalesValMatch.put(currentBookingStatus,salesAmount);
               }
               else{
                 salesAmount = convertMillionToDecimal(thisBooking.Total_Booking_Amount__c);
                 monthYearSalesValMatch.put(currentBookingStatus,salesAmount);
               }
               mapMonthlySales.put(monthYear,monthYearSalesValMatch);
          }
      }

        system.debug('***mapMonthlySales'+mapMonthlySales);
      List<Decimal> totalSales = new List<Decimal>();
      for(String monthYearKey:mapMonthlySales.keySet()){
         Map<String,Decimal> statusSalesMap = mapMonthlySales.get(monthYearKey);
         MonthlySales monthlySalesWrapper = new monthlySales();
         monthlySalesWrapper.monthYear = monthYearKey;
         
         //initialize values 
         for(String statusKey:statusSalesMap.keySet()){
            monthlySalesWrapper.rejectedSalesVal = (statusKey == rejected)?statusSalesMap.get(statusKey): monthlySalesWrapper.rejectedSalesVal;
            monthlySalesWrapper.dpDocsVal = (statusKey == dpDocsOK)?statusSalesMap.get(statusKey): monthlySalesWrapper.dpDocsVal;
            monthlySalesWrapper.awaitingDPDocVal = (statusKey == awaitingDPDocsOK)?statusSalesMap.get(statusKey): monthlySalesWrapper.awaitingDPDocVal; 
         }
         totalSales.add(monthlySalesWrapper.rejectedSalesVal+ monthlySalesWrapper.dpDocsVal+monthlySalesWrapper.awaitingDPDocVal);
         monthlySalesList.add(monthlySalesWrapper);
         
      }

      system.debug('**list'+totalSales);
      system.debug('***monthlySales'+monthlySalesList);
      system.debug('***monthlySalesListSize '+monthlySalesListSize);
      monthlySalesListSize = monthlySalesList.size(); 
      if(monthlySalesList.size() == 0 ){
          String monthYear = convertMonthNumberToString(currentDate.Month())+' - '+ currentDate.Year();
          
          MonthlySales monthlySalesWrapper = new monthlySales();
          monthlySalesWrapper.monthYear = '';
          monthlySalesWrapper.rejectedSalesVal = 0;
          monthlySalesWrapper.dpDocsVal = 0;
          monthlySalesWrapper.awaitingDPDocVal = 0;
          monthlySalesList.add(monthlySalesWrapper);
      }

      if(totalSales.size()>0){
        totalSales.sort();
        createMonthlySalesYAxis(totalSales[totalSales.size()-1]);
      }
      else{
         createMonthlySalesYAxis(20); //dafault value of the graph setting it to 20
      }
  }

  private void createMonthlySalesYAxis(Decimal maxVal){
    Integer maxRange = 50;
    
    if(maxVal<50)
     maxRange = 50;
    else if( maxVal>50 && maxVal<100)
      maxRange = 100;
    else if(maxVal>100 && maxVal<200)
     maxRange = 200;
    else if(maxVal>200 && maxVal<500)
     maxRange = 500;
    else{
      maxRange = Integer.valueOf(Math.ceil(maxVal/100)*100);
    }

    for(Integer i=0;i<maxRange;i++){
     salesYaxis.add(maxRange/10+i*maxRange/10); 
      if(maxRange == maxRange/10+i*maxRange/10){
       break;
      }
    }
  }
  
  private void getDPDocsOverdue(){
      
      //Date 0-7 days back from current date

      sevenDaysBackDate = currentDate.addDays(-6);
      
      System.debug('sevenDaysBackDate'+sevenDaysBackDate);
      
      //Date 7-15 days back from currentDate
       eightDaysBackDate = currentDate.addDays(-7);
      fifteenDaysBackDate = currentDate.addDays(-14);
      System.debug('eightDaysBackDate'+eightDaysBackDate);
      System.debug('fifteenDaysBackDate'+fifteenDaysBackDate);
          
      //Date 15-30days back from currentDate
      sixteenDaysBackDate = currentDate.addDays(-15);
      thirtyDaysBackDate = currentDate.addDays(-29);
      System.debug('sixteenDaysBackDate'+sixteenDaysBackDate);
      System.debug('thirtyDaysBackDate'+thirtyDaysBackDate);
      
      moreThanThrityDays = currentDate.addDays(-30);
      
      
      addDPDocsOverDueList(zeroto7days,' Deal_SR__r.Registration_Date__c <= :currentDate AND  Deal_SR__r.Registration_Date__c >=: sevenDaysBackDate');

      addDPDocsOverDueList(sevento15days,' Deal_SR__r.Registration_Date__c <= :eightDaysBackDate AND  Deal_SR__r.Registration_Date__c >=: fifteenDaysBackDate');
                                  
      addDPDocsOverDueList(fifteento30days,' Deal_SR__r.Registration_Date__c <= :sixteenDaysBackDate AND  Deal_SR__r.Registration_Date__c >=: thirtyDaysBackDate');
    
      addDPDocsOverDueList(morethanThirty,' Deal_SR__r.Registration_Date__c<=: moreThanThrityDays');
                                  
      System.debug('**dpDocsOverDueList'+dpDocsOverDueList);
      dpDocsOverDueListSize = dpDocsOverDueList.size();

       List<Integer> totalBookings = new List<Integer>();
       //iterate over the final list and check the max value of no of bookings to create y axis
       for(DPDocsOverdue dpDocsOverdue:dpDocsOverDueList){
          totalBookings.add(dpDocsOverdue.noOfDPDOCSOverdueDays);
          totalBookings.add(dpDocsOverdue.noOfDPOverdueDays);
          totalBookings.add(dpDocsOverdue.noOfDocsOverdueDays);
       }

       if(totalBookings.size()>0){
          totalBookings.sort();
          Integer maxVal = totalBookings[totalBookings.size()-1];
          system.debug(maxVal);
          createDPDocsYAxis(maxVal);
       }
       else{
         createDPDocsYAxis(5);
       }
  }

  public void createDPDocsYAxis(Integer maxVal){
    Integer maxRange = 20;
    
    if(maxVal<10)
     maxRange = 10;
    else if(maxVal>10 && maxVal<20)
     maxRange = 20;
    else if( maxVal>20 && maxVal<50)
      maxRange = 50;
    else if(maxVal>50 && maxVal<100)
     maxRange = 100;
    else if(maxVal>100 && maxVal<200)
     maxRange = 200;
    else{
      maxRange = Integer.valueOf(Math.ceil(Decimal.valueOf(maxVal)/10)*10);
    }

    
    for(Integer i=0;i<maxRange;i++){
     dpDocsYAxis.add(maxRange/10+i*maxRange/10); 
      if(maxRange == maxRange/10+i*maxRange/10){
       break;
      }
    }
  }
  
  private void addDPDocsOverDueList(String weekDaysString,String condition){
      
       Integer docsOkOverdue = 0;
       Integer DPOkOverdue = 0;
       Integer DPDocsOverdue = 0;
       
       String query = 'SELECT count(Id) idVal,Deal_SR__r.Doc_ok__c doc ,Deal_SR__r.DP_ok__c dp'+ 
                                  ' FROM Booking__c  where Deal_SR__r.Agency__c=: accountId AND ';
       query += condition;
       
      
       query += ' AND Rejected__c = false Group By Deal_SR__r.Doc_ok__c,Deal_SR__r.DP_ok__c,Deal_SR__r.Registration_Date__c'; 
       
       system.debug('***query'+query);
      
       for(AggregateResult agrResult:Database.query(query)){
                                      
             if((Boolean)agrResult.get('doc') == false && (Boolean)agrResult.get('dp')==true){
                 docsOkOverdue += (Integer)agrResult.get('idVal');
             }
             
             if((Boolean)agrResult.get('dp')==false && (Boolean)agrResult.get('doc') == true){
                 DPOkOverdue += (Integer)agrResult.get('idVal');
             }
             
             if((Boolean)agrResult.get('dp')==false && (Boolean)agrResult.get('doc')==false){
                 DPDocsOverdue += (Integer)agrResult.get('idVal');
             } 
             system.debug('<<agrResult>>'+agrResult);
       }
       system.debug(DPOkOverdue+''+docsOkOverdue+''+DPDocsOverdue);
       dpDocsOverDueList.add(new DPDocsOverdue(weekDaysString,DPOkOverdue,docsOkOverdue,DPDocsOverdue));
  }
  
  private void getTierSalesReport(){
      String currentQuarter = getQuarter();
      currentQuarterName = 'Quarterly Tier : '+currentQuarter +' '+ currentDate.year();
      annualTierName = 'Annual Tier : Jan-Dec '+currentDate.year();
      for(Account thisAccount:[Select Quarter_1_Sales__c, Quarter_2_Sales__c,
                                Quarter_3_Sales__c,Quarter_4_Sales__c,Agency_Tier_Q1__c,
                               Agency_Tier_Q2__c,Agency_Tier_Q3__c,Agency_Tier_Q4__c,
                               Agency_Tier__c
                                FROM Account 
                                WHERE Id =: accountId
                                LIMIT 1]){
                                    
         if(thisAccount.Quarter_1_Sales__c ==  null)
           thisAccount.Quarter_1_Sales__c = 0;
           
         if(thisAccount.Quarter_2_Sales__c ==  null)
           thisAccount.Quarter_2_Sales__c = 0;
           
         if(thisAccount.Quarter_3_Sales__c ==  null)
           thisAccount.Quarter_3_Sales__c = 0;
           
          if(thisAccount.Quarter_4_Sales__c ==  null)
           thisAccount.Quarter_4_Sales__c = 0;
          
         currentQuarterSalesVal = (currentQuarter== 'Jan-March')?thisAccount.Quarter_1_Sales__c:
                                  (currentQuarter == 'Apr-Jun')?thisAccount.Quarter_2_Sales__c:
                                  (currentQuarter == 'Jul-Sep')?thisAccount.Quarter_3_Sales__c:thisAccount.Quarter_4_Sales__c;
         
         quarterSalesTierColor = (currentQuarter== 'Jan-March')?thisAccount.Agency_Tier_Q1__c:
                                  (currentQuarter == 'Apr-Jun')?thisAccount.Agency_Tier_Q2__c:
                                  (currentQuarter == 'Jul-Sep')?thisAccount.Agency_Tier_Q3__c:thisAccount.Agency_Tier_Q4__c;
         
         currentQuarterSalesVal = convertMillionToDecimal(currentQuarterSalesVal);
         
         if(null != quarterSalesTierColor)
            quarterSalesTierColor = colorMap.get(quarterSalesTierColor);  
                                    
         annualSalesVal = thisAccount.Quarter_1_Sales__c+thisAccount.Quarter_2_Sales__c+thisAccount.Quarter_3_Sales__c+thisAccount.Quarter_4_Sales__c;
         annualSalesVal = convertMillionToDecimal(annualSalesVal);
         
         if(null != thisAccount.Agency_Tier__c)
            annualSalesTierColor = colorMap.get(thisAccount.Agency_Tier__c);
      }
      
      quarterSalesData.add(new gaugeData(currentQuarterSalesVal));
      annualSalesData.add(new gaugeData(annualSalesVal));    
  }
  
  private String convertMonthNumberToString(Integer monthNumber){
      return monthsMap.get(monthNumber);
  }

  private Decimal convertMillionToDecimal(Decimal amount){
     if(null != amount && amount != 0){
        return (amount/(1000000));
     }

     return 0;
  }
    
  
  
  private Decimal convertThousandToDecimal(Decimal amount){
     if(null != amount && amount != 0){
        return (amount/(1000));
     }

     return 0;
  }
  
  private String getQuarter(){
        Integer month = currentDate.Month();
        
        return ( (month >= 1 && month <= 3) ? 'Jan-March' :
               (month >= 4 && month <= 6) ? 'Apr-Jun' :
               (month >= 6 && month <= 8) ? 'Jul-Sep' :'Oct-Dec');

  }
  
  public class MonthlySales{
      public String monthYear{get;set;}
      public Decimal rejectedSalesVal {set;get;}
      public Decimal dpDocsVal{set;get;}
      public Decimal awaitingDPDocVal{set;get;}
      
      public MonthlySales(){
          monthYear = '';
          rejectedSalesVal = 0;
          dpDocsVal = 0;
          awaitingDPDocVal = 0;
      }
      
  }
  
  public class MonthlyBrokerage{
      public String monthYear{set;get;}
      public Decimal unpaidDueVal{set;get;}
      public Decimal paidVal{set;get;}
      
      public MonthlyBrokerage(){
          monthYear = '';
          unpaidDueVal = 0;
          paidVal = 0;
      }
  }
  
  public class DPDocsOverdue{
      public String weekDays{set;get;}
      public Integer noOfDPOverdueDays{set;get;}
      public Integer noOfDocsOverdueDays{set;get;}
      public Integer noOfDPDOCSOverdueDays{set;get;}
      
      public DPDocsOverdue(String weekDays,Integer noOfDPOverdueDays,Integer noOfDocsOverdueDays,Integer noOfDPDOCSOverdueDays){
          this.weekDays = weekDays;
          this.noOfDPOverdueDays = noOfDPOverdueDays;
          this.noOfDocsOverdueDays = noOfDocsOverdueDays;
          this.noOfDPDOCSOverdueDays = noOfDPDOCSOverdueDays;
      }
  }
    
    public class gaugeData{
        public Decimal salesVal{set;get;}
        public String name{set;get;}
        public gaugeData(Decimal salesVal){
            this.salesVal = salesVal;
            name = 'Sales Report'; 
        }
    }
  
 
}