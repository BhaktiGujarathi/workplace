public without sharing class CheckUnitEligableForHandover {
    
    public static CheckUnitEligableForHandover.EligibleForHandover checkEligibleForHandover(String regId, String projectCity, string project, 
    	string permittedUse, string bedroomType, string unitType, string customerType){
    	EligibleForHandover.EligibleForHandoverNoticeRuleHttpSoap11Endpoint objHandover = new EligibleForHandover.EligibleForHandoverNoticeRuleHttpSoap11Endpoint();
    	EligibleForHandover resObj = new EligibleForHandover();
    	
    	try {
    		String response = objHandover.EligibleForHandoverNotice(regId, 'Handover', projectCity, projectCity, project, '', permittedUse, bedroomType, '', unitType, customerType, '', '', 'NO');
    		resObj = (EligibleForHandover)JSON.deserialize(response, CheckUnitEligableForHandover.EligibleForHandover.class);
    		system.debug('!!!!!!resObj'+resObj);
    	}catch  (Exception e ){
    		
    	}
    	
    	return resObj;
    }
    
    public class EligibleForHandover {
    	public string allowed;
    	public string message;
    	public string mortgageNOCfromBank;
    	public string ifPoaTakingHandoverColatePoaPassportResidence;
    	public string corporateValidTradeLicence;
    	public string corporateArticleMemorandumOfAssociation;
    	public string corporateBoardResolution;
    	public string corporatePoa;
    	public string signedForm;
    	public string clearAndValidPassportCopyOfOwner;
    	public string clearAndValidPassportCopyOfJointOwner;
    	public string visaOrEntryStampWithUid;
    	public string copyofValidEmiratesId;
    	public string copyofValidGccId;
    	public string handoverChecklistAndLod;
    	public string keyReleaseForm;
    	public string checkOriginalSpaAndtakeCopyOfFirstFourPagesOfSpa;
    	public string areaVariationAddendum;
    	public string tempOne;
    	public string tempTwo;
    	public string tempThree;
    	public string handoverNoticeAllowed;
    	public string approvalQueueOne;
    	public string approvalQueueTwo;
    	public string approvalQueueThree;
    	public string eligibleforRentalPool;
    }
}