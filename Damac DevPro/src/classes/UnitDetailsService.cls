public with sharing class UnitDetailsService {
    public static UnitDetailsService.BookinUnitDetailsWrapper getBookingUnitDetails( String strRegId ) {
        UnitDetailsService.BookinUnitDetailsWrapper objDetailsWrapper ;
        if( String.isNotBlank( strRegId ) ) {
            unitDetailsController.UnitDetailsHttpSoap11Endpoint objTemp = new unitDetailsController.UnitDetailsHttpSoap11Endpoint();
            String strResponse ;
            try {
            	strResponse = objTemp.getUnitDetailValues( strRegId + '_REGISTRATION' ); //.removeStart('[').removeEnd(']') ;
            }
            catch( Exception e ) {
            	system.debug(' Exception occured while fetching unit details ==  '+e.getMessage() );
            }
            system.debug('response for unit details..'+ strResponse );
            if( String.isNotBlank( strResponse ) ) {
                strResponse = strResponse.removeStart('[').removeEnd(']');
                if( String.isNotBlank( strResponse ) ) {
	                Map<String, Object> objUnitDetails = (Map<String, Object>)JSON.deserializeUntyped( strResponse.replace('\\','').removeStart('"').removeEnd('"') );
	                objDetailsWrapper = new UnitDetailsService.BookinUnitDetailsWrapper();
	                
	                //Assign values to the wrapper object.
	                objDetailsWrapper.strRegId = String.valueOf( objUnitDetails.get('ATTRIBUTE1') );
	                objDetailsWrapper.strStatusFlag = String.valueOf( objUnitDetails.get('ATTRIBUTE3') );
	                objDetailsWrapper.strBulk = String.valueOf( objUnitDetails.get('ATTRIBUTE4') );
	                objDetailsWrapper.strAreaVariation = String.valueOf( objUnitDetails.get('ATTRIBUTE5') );
	                objDetailsWrapper.strTypeOfVariation = String.valueOf( objUnitDetails.get('ATTRIBUTE6') );
	                objDetailsWrapper.strRecoveryFlag = String.valueOf( objUnitDetails.get('ATTRIBUTE7') );
	                objDetailsWrapper.strAmountPaid = String.valueOf( objUnitDetails.get('ATTRIBUTE8') );
	                objDetailsWrapper.strAmountCollected = String.valueOf( objUnitDetails.get('ATTRIBUTE9') );
	                objDetailsWrapper.strAmountRemaining = String.valueOf( objUnitDetails.get('ATTRIBUTE10') );
	                objDetailsWrapper.strAmountOverdue = String.valueOf( objUnitDetails.get('ATTRIBUTE11') );
	                objDetailsWrapper.strDefault = String.valueOf( objUnitDetails.get('ATTRIBUTE12') );
	                objDetailsWrapper.strHOFlag = String.valueOf( objUnitDetails.get('ATTRIBUTE13') );
	                objDetailsWrapper.strEHOFlag = String.valueOf( objUnitDetails.get('ATTRIBUTE14') );
	                objDetailsWrapper.strPOA = String.valueOf( objUnitDetails.get('ATTRIBUTE15') );
	                objDetailsWrapper.strUnderTermination = String.valueOf( objUnitDetails.get('ATTRIBUTE16') );
	                objDetailsWrapper.strRentalPool = String.valueOf( objUnitDetails.get('ATTRIBUTE17') );
	                objDetailsWrapper.strPortfolioValue = String.valueOf( objUnitDetails.get('ATTRIBUTE18') );
	                objDetailsWrapper.strPDCCoverage = String.valueOf( objUnitDetails.get('ATTRIBUTE19') );
	                objDetailsWrapper.strReraConstructionStatus = String.valueOf( objUnitDetails.get('ATTRIBUTE20') );
	                objDetailsWrapper.strTotalParingWithCustomer = String.valueOf( objUnitDetails.get('ATTRIBUTE21') );
	                objDetailsWrapper.strSPASigned = String.valueOf( objUnitDetails.get('ATTRIBUTE22') );
	                objDetailsWrapper.strPenaltyCharged = String.valueOf( objUnitDetails.get('ATTRIBUTE23') );
	                objDetailsWrapper.strPenaltyWaived = String.valueOf( objUnitDetails.get('ATTRIBUTE24') );
	                objDetailsWrapper.strPenaltyRemaining = String.valueOf( objUnitDetails.get('ATTRIBUTE25') );
	                objDetailsWrapper.strCustomerClassification = String.valueOf( objUnitDetails.get('ATTRIBUTE26') );
	                objDetailsWrapper.strBCCAvailable = String.valueOf( objUnitDetails.get('ATTRIBUTE27') );
	                objDetailsWrapper.strFTLSent = String.valueOf( objUnitDetails.get('ATTRIBUTE28') );
	                objDetailsWrapper.strReady_Offplan = String.valueOf( objUnitDetails.get('ATTRIBUTE29') );
	                objDetailsWrapper.strPCC = String.valueOf( objUnitDetails.get('ATTRIBUTE30') );
	                objDetailsWrapper.strCourtOrderforDecCase = String.valueOf( objUnitDetails.get('ATTRIBUTE31') );
	                objDetailsWrapper.strNOCIssuanceInLast15Days = String.valueOf( objUnitDetails.get('ATTRIBUTE32') );
	                objDetailsWrapper.strDelayExpectedFromOriginalACD = String.valueOf( objUnitDetails.get('ATTRIBUTE33') );
	                objDetailsWrapper.strServiceChargePaid = String.valueOf( objUnitDetails.get('ATTRIBUTE34') );
	                objDetailsWrapper.strOtherCharge = String.valueOf( objUnitDetails.get('ATTRIBUTE35') );
	                objDetailsWrapper.strRegistrationDate = String.valueOf( objUnitDetails.get('ATTRIBUTE39') );
	                objDetailsWrapper.strUnitNumber = String.valueOf( objUnitDetails.get('ATTRIBUTE40') );
	                objDetailsWrapper.strInvoicesRaised = String.valueOf( objUnitDetails.get('ATTRIBUTE41') );
	                objDetailsWrapper.strPenalties = String.valueOf( objUnitDetails.get('ATTRIBUTE42') );
	                objDetailsWrapper.strOverdue = String.valueOf( objUnitDetails.get('ATTRIBUTE43') );
	                objDetailsWrapper.strBuiltUpPrice = String.valueOf( objUnitDetails.get('ATTRIBUTE44') );
	                objDetailsWrapper.strDispute = String.valueOf( objUnitDetails.get('ATTRIBUTE45') );
	                objDetailsWrapper.strEnforcement = String.valueOf( objUnitDetails.get('ATTRIBUTE46') );
	                objDetailsWrapper.strLitigation = String.valueOf( objUnitDetails.get('ATTRIBUTE47') );
	                objDetailsWrapper.strCounterCase = String.valueOf( objUnitDetails.get('ATTRIBUTE48') );
	                objDetailsWrapper.strRegistrationFeePaid = String.valueOf( objUnitDetails.get('ATTRIBUTE49') );
	                objDetailsWrapper.strPRCStatus = String.valueOf( objUnitDetails.get('ATTRIBUTE50') );
	                objDetailsWrapper.strAgreementStatus = String.valueOf( objUnitDetails.get('ATTRIBUTE51') );
	                objDetailsWrapper.strCurrentConstructionStatus = String.valueOf( objUnitDetails.get('ATTRIBUTE52') );
	                objDetailsWrapper.strCurrentRERAConstructionStatusOfBuilding = String.valueOf( objUnitDetails.get('ATTRIBUTE53') );
	                objDetailsWrapper.strOriginalACD = String.valueOf( objUnitDetails.get('ATTRIBUTE54') );
	                objDetailsWrapper.strCurrentACD = String.valueOf( objUnitDetails.get('ATTRIBUTE55') );
	                objDetailsWrapper.strAreaVariation_sqft  = String.valueOf( objUnitDetails.get('ATTRIBUTE56') );
	                objDetailsWrapper.strAreaVariation_AED = String.valueOf( objUnitDetails.get('ATTRIBUTE57') );
	                objDetailsWrapper.strOtherCharges = String.valueOf( objUnitDetails.get('ATTRIBUTE58') );
	                objDetailsWrapper.strPaidPercent = String.valueOf( objUnitDetails.get('ATTRIBUTE59') );
	                objDetailsWrapper.strPercentOverdue = String.valueOf( objUnitDetails.get('ATTRIBUTE60') );
	                objDetailsWrapper.strPercentPDCCoverage = String.valueOf( objUnitDetails.get('ATTRIBUTE61') );
	                objDetailsWrapper.strNoOfTimesCustomerDefaultedOnInstalments = String.valueOf( objUnitDetails.get('ATTRIBUTE62') );
	                objDetailsWrapper.strARPCC = String.valueOf( objUnitDetails.get('ATTRIBUTE63') );
	                objDetailsWrapper.strARPartialPCC = String.valueOf( objUnitDetails.get('ATTRIBUTE64') );
	                objDetailsWrapper.strFMPCC = String.valueOf( objUnitDetails.get('ATTRIBUTE65') );
	                objDetailsWrapper.strTotalOutstanding = String.valueOf( objUnitDetails.get('ATTRIBUTE66') );
	                objDetailsWrapper.strPenalty_Overdues  = String.valueOf( objUnitDetails.get('ATTRIBUTE67') );
	                objDetailsWrapper.strPenaltyWaivers_PortfolioLevel = String.valueOf( objUnitDetails.get('ATTRIBUTE68') );
	                objDetailsWrapper.strNoOfExistingParkingWithUnit = String.valueOf( objUnitDetails.get('ATTRIBUTE69') );
	                objDetailsWrapper.strBayNoOfExistingParkingWithUnit = String.valueOf( objUnitDetails.get('ATTRIBUTE70') );
	                objDetailsWrapper.strTypeOfExistingParkingWithUnit = String.valueOf( objUnitDetails.get('ATTRIBUTE71') );
	                objDetailsWrapper.strOverdues_DuesTowardsServiceCharges = String.valueOf( objUnitDetails.get('ATTRIBUTE72') );
	                objDetailsWrapper.strPenalties_LatePaymentFeeOnServiceCharges = String.valueOf( objUnitDetails.get('ATTRIBUTE73') );
	                objDetailsWrapper.strDateOfLastPDC = String.valueOf( objUnitDetails.get('ATTRIBUTE74') );
	                objDetailsWrapper.strBTP = String.valueOf( objUnitDetails.get('ATTRIBUTE75') );
	                objDetailsWrapper.strBTP_sqft = String.valueOf( objUnitDetails.get('ATTRIBUTE76') );
	                objDetailsWrapper.strMinPercentForEHO = String.valueOf( objUnitDetails.get('ATTRIBUTE77') );
	                objDetailsWrapper.strAmountOutstandingToCustomer = String.valueOf( objUnitDetails.get('ATTRIBUTE78') );
                }
            }
        }
        system.debug(objDetailsWrapper);
        return objDetailsWrapper ;
    }
    
    public class BookinUnitDetailsWrapper {
        public String strRegId {get;set;}
        public String strStatusFlag {get;set;}
        public String strBulk {get;set;}
        public String strAreaVariation  {get;set;}
        public String strTypeOfVariation {get;set;}
        public String strRecoveryFlag {get;set;}
        public String strAmountPaid {get;set;}
        public String strAmountCollected {get;set;}
        public String strAmountRemaining {get;set;}
        public String strAmountOverdue {get;set;}
        public String strDefault {get;set;}
        public String strHOFlag  {get;set;}
        public String strEHOFlag  {get;set;}
        public String strPOA {get;set;}
        public String strUnderTermination {get;set;}
        public String strRentalPool {get;set;}
        public String strPortfolioValue {get;set;}
        public String strPDCCoverage {get;set;}
        public String strReraConstructionStatus {get;set;}
        public String strTotalParingWithCustomer {get;set;}
        public String strSPASigned {get;set;}
        public String strPenaltyCharged {get;set;}
        public String strPenaltyWaived {get;set;}
        public String strPenaltyRemaining {get;set;}
        public String strCustomerClassification {get;set;}
        public String strBCCAvailable {get;set;}
        public String strFTLSent {get;set;}
        public String strReady_Offplan {get;set;}
        public String strPCC {get;set;}
        public String strCourtOrderforDecCase {get;set;}
        public String strNOCIssuanceInLast15Days {get;set;}
        public String strDelayExpectedFromOriginalACD {get;set;}
        public String strServiceChargePaid {get;set;}
        public String strOtherCharge {get;set;}
        public String strRegistrationDate {get;set;}
        public String strUnitNumber {get;set;}
        public String strInvoicesRaised {get;set;}
        public String strPenalties {get;set;}
        public String strOverdue {get;set;}
        public String strBuiltUpPrice {get;set;}
        public String strDispute {get;set;}
        public String strEnforcement {get;set;}
        public String strLitigation {get;set;}
        public String strCounterCase {get;set;}
        public String strRegistrationFeePaid {get;set;}
        public String strPRCStatus {get;set;}
        public String strAgreementStatus {get;set;}
        public String strCurrentConstructionStatus {get;set;}
        public String strCurrentRERAConstructionStatusOfBuilding {get;set;}
        public String strOriginalACD {get;set;}
        public String strCurrentACD {get;set;}
        public String strAreaVariation_sqft  {get;set;}
        public String strAreaVariation_AED {get;set;}
        public String strOtherCharges {get;set;}
        public String strPaidPercent {get;set;}
        public String strPercentOverdue {get;set;}
        public String strPercentPDCCoverage {get;set;}
        public String strNoOfTimesCustomerDefaultedOnInstalments {get;set;}
        public String strARPCC {get;set;}
        public String strARPartialPCC {get;set;}
        public String strFMPCC {get;set;}
        public String strTotalOutstanding {get;set;}
        public String strPenalty_Overdues  {get;set;}
        public String strPenaltyWaivers_PortfolioLevel {get;set;}
        public String strNoOfExistingParkingWithUnit {get;set;}
        public String strBayNoOfExistingParkingWithUnit {get;set;}
        public String strTypeOfExistingParkingWithUnit {get;set;}
        public String strOverdues_DuesTowardsServiceCharges {get;set;}
        public String strPenalties_LatePaymentFeeOnServiceCharges {get;set;}
        public String strDateOfLastPDC {get;set;}
        public String strBTP {get;set;}
        public String strBTP_sqft {get;set;}
        public String strMinPercentForEHO {get;set;}
        public String strAmountOutstandingToCustomer {get;set;}
        /*public String str;
        public String str;*/
        
    }
}