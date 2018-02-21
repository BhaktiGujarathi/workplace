/*
   Use : Common class for Token and customer refund processes
   Created By : Swapnil Gholap
*/


public class WrapperBookingUnit {
    public Decimal decAreaVariation_SqFt{get;set;}
    public String strTypeVariation {get;set;}
    public Decimal decOtherCharges {get;set;}
    public Decimal decPaidPercent {get;set;}
    public Decimal decPDCcoveragePercent {get;set;}
    public Integer intNoOfTimesCusDefaulted {get;set;}
    public Boolean blnRecoveryFlag {get;set;}
    public Boolean blnPriorAOPT {get;set;}
    public Decimal decTotalOutstanding {get;set;}
    public Decimal decDefaultAmt {get;set;}
    public Decimal decPenaltyOverdues{get;set;}
    public Decimal decPenaltyWaivers{get;set;}
    public Decimal decConstructionStatusPercent {get;set;}

    public Integer intNumber {get;set;}
    public UnitDetailsService.BookinUnitDetailsWrapper objIPMSDetailsWrapper { get; set; }
    public String strUnit {get;set;}
    public String strProject {get; set;}
    public String strProjectCity {get; set;}
    public String strBedroomType {get; set;}
    public String strUnitType {get; set;}
    public String strPermittedUse {get; set;}
    public String strReady_OffPlan {get; set;}
    public String strRentalPool {get; set;}
    public String strDispute { get; set; }
    public Boolean blnDispute {get; set;}
    public Boolean blnEnforcement {get; set;}
    public Boolean blnLitigation {get; set;}
    public Boolean blnMortage {get; set;}
    public Boolean blnCourtCase {get; set;}
    public Boolean blnFTLsent {get; set;}
    public Boolean blnEHO {get; set;}
    public String strHO {get; set;}
    public String  strHandoverFlag {get; set;}
    public Boolean blnRentalPool { get; set; }
    public Boolean blnOQOODReg { get; set; }
    public String strPCC {get; set;}
    public Boolean blnPCC {get; set;}
    public Boolean blnHO {get; set;}
    public String strOQOODregistered {get; set;}
    public Boolean blnOQOODregistered {get; set;}
    public String strAgreementStatus {get; set;}
    public String strUnderTermination {get; set;}
    public Integer intArea {get;set;}
    public Decimal decPrice {get;set;}
    public Integer intNoOfBookingDay {get;set;}
    public Integer intNoOfDefaulted {get;set;}
    public Integer intPenaltyAmount {get; set;}
    public String str_URC_SPA {get;set;}
    public Boolean bln_URC_SPA {get;set;}
    public String strDefault {get;set;}
    public Integer intOverdue {get;set;}
    public Integer intRERAstatus {get;set;}
    public Decimal decRERAstatus {get;set;}
    public String strDealStatus {get;set;}
    public String strIDavailable {get;set;}
    public Integer intBCC { get; set; }
    public Integer intPrevWaivers { get; set; }
    public Integer intTotalWaiver { get; set; }
    public String strPC_AgentName {get; set;}
    public Integer intConversationStatus {get; set;}
    public String strDocsStatus {get; set;}
    public Decimal intPricePerSqFt {get; set;}
    public Boolean blnDOCOK {get;set;}
    public Boolean blnDPOK {get;set;}
    public Decimal decPaidPercentage {get; set;}
    public Decimal decDefaultPercentage {get; set;}
    public Integer intTotalPenaltyCustomer {get; set;}
    public Integer intTotalPenaltyUnit {get; set;}
    public String strOriginalACD {get; set;}
    public String strCurrentACD {get; set;}
    public Booking_Unit__c objBookingUnit {get;set;}
    public String strRegID {get;set;}
    public String strConstructionStatus {get;set;}
    public Decimal Penalty_OverDues {get;set;}
    public Integer intPenaltyOverdue {get;set;}
    public Decimal decPenaltyWaiver {get;set;}
    public Decimal decDuesServiceCharges {get;set;}
    public Decimal decLatePaymentFees {get;set;}
    public String strPromotionScheme {get;set;}
    public String strInvoicesRaised {get;set;}
    public Decimal decAmountPaid {get;set;}
    public String strDealTeam {get;set;}
    public String strBookingType {get;set;}
    public String strPaymentPlan {get;set;}
    public String strStatementofAccount {get;set;}
    public String strUnitPlan {get;set;}
    public String strFloorPlan {get;set;}
    public String strFJOPDArea {get;set;}
    public Decimal decBuiltUpPrice {get;set;}
    public Decimal decPlotPrice {get;set;}
    public Date dateBookingDate {get;set;}
    public Date dateAgreementDate {get;set;}
    public boolean blnRegistrationFeePaid {get;set;}
    public String strPRCStatus {get;set;}
    public String strPenalties {get;set;}
    public String strPriorAOPT {get;set;}

}