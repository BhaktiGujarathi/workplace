public with sharing class KeyHandoverChecklist {
    
/*    public static KayHandover getKeyHandover(String regId, String subProcessName, String ProjectCity, String Project, String BuildingCode, 
        String PermittedUse, String BedroomType, String UnitType, String Nationality, String TypeOfCustomer, String POA){*/
    public static String getKeyHandover(String regId, String subProcessName, String ProjectCity, String Project, String BuildingCode, 
        String PermittedUse, String BedroomType, String UnitType, String Nationality, String TypeOfCustomer, String POA){
        DocumentationForKeyHandoverService.DoumentationForKeyHandoverRuleHttpSoap11Endpoint calloutObj = new DocumentationForKeyHandoverService.DoumentationForKeyHandoverRuleHttpSoap11Endpoint ();
        calloutObj.timeout_x = 120000;
        KayHandover resObj = new KayHandover();
    
        try{
          String response = calloutObj.DoumentationForKeyHandover( regId, 'Handover', subProcessName, ProjectCity, Project, BuildingCode, PermittedUse, BedroomType, '', UnitType, Nationality, TypeOfCustomer, POA);
          resObj = (KayHandover)JSON.deserialize(response, KeyHandoverChecklist.KayHandover.class);
          system.debug('keyhandover response === '+ resObj);
          return response;
        } catch (Exception e ){
          resObj.message = 'Exception';
        }
        
        //return resObj;
        return null;
    }
  
    public class KayHandover {
        public String allowed {get;set;}
        public String message {get;set;}
        public String mortgageNOCfromBank {get;set;}
        public String ifPoaTakingHandoverColatePoaPassportResidence {get;set;}
        public String corporateValidTradeLicence {get;set;}
        public String corporateArticleMemorandumOfAssociation {get;set;}
        public String corporateBoardResolution {get;set;}
        public String corporatePoa {get;set;}
        public String signedForm {get;set;}
        public String clearAndValidPassportCopyOfOwner {get;set;}
        public String clearAndValidPassportCopyOfJointOwner {get;set;}
        public String visaOrEntryStampWithUid {get;set;}
        public String copyofValidEmiratesId {get;set;}
        public String copyofValidGccId {get;set;}
        public String handoverChecklistAndLod {get;set;}
        public String keyReleaseForm {get;set;}
        public String checkOriginalSpaAndtakeCopyOfFirstFourPagesOfSpa {get;set;}
        public String areaVariationAddendum {get;set;}
        public String tempOne {get;set;}
        public String tempTwo {get;set;}
        public String tempThree {get;set;}
        public String handoverNoticeAllowed {get;set;}
        public String approvalQueueOne {get;set;}
        public String approvalQueueTwo {get;set;}
        public String approvalQueueThree {get;set;}
        public String eligibleforRentalPool {get;set;}
    }
    
}