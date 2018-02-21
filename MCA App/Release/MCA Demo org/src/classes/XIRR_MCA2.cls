public class XIRR_MCA2{
    public decimal XIRR;
    private decimal fundingAMt;
    private decimal balance;
    private Date startDate;
    private decimal days;
    private decimal dailyPayBack;
    private decimal testing;
    private boolean isNull = false;
    public XIRR_MCA2(Decimal monthlyTerm, decimal fundingAmt,decimal processFee, Decimal CommissionAmt, Decimal paybackAmt){
        if (monthlyTerm !=null && fundingAmt!= null && paybackAmt!= null)
        {
            if (processFee == null)
                processFee = 0;
            if (CommissionAmt == null)
                CommissionAmt = 0;
            decimal NumberOfDays = (monthlyTerm * 30)/4;
            decimal toRound = NumberOfDays;
            days = toRound.setScale(0, RoundingMode.HALF_UP); // Use to calculate Date Map
            fundingAmt = fundingAmt;
    
            dailyPayBack = paybackAmt/NumberOfDays;
            //toRound = dailyPayBack;
            //dailyPayBack = toRound.setScale(0, RoundingMode.HALF_UP); // Daily Payback Ammount for Map
    
            balance = fundingAmt+CommissionAmt-processFee; // Total Returning Amount
            
            testing =  paybackAmt;
        }
        else
            isNull = true;
    }
    
    
    
    public void cal(){
        if (isNull != true)
        {
            Map<Integer,Double>  costMap = new Map<Integer,Double>();
            Map<Integer, Integer> dateMap = new Map<Integer,Integer>();
            
            costMap.put(0,-(balance));
            dateMap.put(0,1);
            date calculateDate = date.newinstance(2013, 1, 1);
            Integer temp =0;
            
            decimal totalAmount=0.00;
            for(Integer i=1;i<=days;i++){
                temp += 4;
                dateMap.put(i,temp);
                
                if(i==days){
                    System.debug(totalAmount);
                    dailyPayBack = testing - totalAmount;
                    costMap.put(i,dailyPayBack);
                }else
                    costMap.put(i,dailyPayBack);
                    
                    totalAmount = totalAmount+dailyPayBack;
            }
    
            XIRR = XIRR_3.cal(dateMap,costMap);
        } //isNull != true
    } 
}