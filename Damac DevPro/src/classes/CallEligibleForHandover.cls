public with sharing class CallEligibleForHandover {
    public static EligibleForHandoverResponse CallEligibleForHandoverName() {
        EligibleForHandover.EligibleForHandoverNoticeRuleHttpSoap11Endpoint objEligibleForHandover = new EligibleForHandover.EligibleForHandoverNoticeRuleHttpSoap11Endpoint ();
        objEligibleForHandover.timeout_x = 120000 ;
        string strHand =  objEligibleForHandover.EligibleForHandoverNotice('41397','Handover','Dubai','Dubai','76175','4567','Yes','2BHK','','Serviced Apartment','Individual','','','No');
        system.debug('strHand '+strHand );
        EligibleForHandoverResponse objEligibleForHandoverResponse = new EligibleForHandoverResponse();
        objEligibleForHandoverResponse = (EligibleForHandoverResponse)JSON.deserialize(strHand, CallEligibleForHandover.EligibleForHandoverResponse.class);
        system.debug('objEligibleForHandoverResponse'+objEligibleForHandoverResponse);
        return objEligibleForHandoverResponse;
    }
    
    public class EligibleForHandoverResponse {
        public String RegistrationId {get;set;}
        public String ProcessName {get;set;}
        public String SubProcessName {get;set;}
        public String ProjectCity {get;set;}
        public String Project {get;set;}
        public String BuildingCode {get;set;}
        public String PermittedUse {get;set;}
        public String BedroomType {get;set;}
        public String ApplicableUnits {get;set;}
        public String UnitType {get;set;}
        public String CustomerType {get;set;}
        public String ModeofRequest {get;set;}
        public String AggrementStatus {get;set;}
        public String UnderAssignment {get;set;}     
    }
}