public class MileStonePaymentDetailsWrapper  
{

  public class MileStonePaymentDetails 
  {
    public List<REG_TERM_PYMNT_TABLE> REG_TERM_PYMNT_TABLE;
    public String message;
    public String status;
  }

  public class REG_TERM_PYMNT_TABLE 
  {
    public String REGISTRATION_ID;
    public String DUE_DATE;
    public String MILESTEON_PERCENT_VALUE;
    public String PAID_AMOUNT;
    public String PAID_PERCENTAGE;
    public String DUE_AMOUNT;
    public String LINE_ID;
    public String MILESTONE_EVENT_AR;
    public String DESCRIPTION;
    public String MILESTONE_EVENT;
    public String INVOICE_AMOUNT;
    public String INSTALLMENT;
    public String TERM_ID;
  }

  public static MileStonePaymentDetails parse(String json) 
  {
    return (MileStonePaymentDetails) System.JSON.deserialize(json, MileStonePaymentDetails.class);
  }
}