public with sharing class GenerateOfficialQuote {
	public GenerateOfficialQuote(ApexPages.StandardController controller) {

	}
	Boolean isLockedFlag = False ;
	Id pRecordId;
	Pay_Agreement_Worksheet__c objPAW = new Pay_Agreement_Worksheet__c();

	public PageReference generateOfficialQuoteMethod() {
		Boolean generateQuoteButton = false;
		PageReference pageRef;
		pRecordId = ApexPages.CurrentPage().getparameters().get('id');
		isLockedFlag = RecordLockUtility.checkIsLocked(pRecordId);
		objPAW = [SELECT Opportunity__c,Status__c
				 FROM Pay_Agreement_Worksheet__c
				 WHERE Id =: pRecordId];

		if(isLockedFlag == false) {
			Id oppID = objPAW.Opportunity__c;
			String redirect1;
			// if(oppID != null && oppID !='') {
			// 	Id agreementID = objPAW.Opportunity__c;
			// 	redirect1 = BenefitsVOBStatus.VOBStatusCheck(agreementID);
			// }
			String st = objPAW.Status__c;
			if(st == 'Open') {
				if(redirect1 != null) {
					if(redirect1 == 'VOBApproved') {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You cannot add additional Pay Agreement Worksheet or Estimate of Treatment Costs when the related Opportunity Status is VOB Approved'));
					}
					else {
						Id agreementID = objPAW.id;
						String redirect = GenerateQuoteCont.createQuote(agreementID,generateQuoteButton);
						String iD = String.ValueOf(redirect);
						if(redirect != null) {
							if(redirect =='error') {
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Can not create new record as the Opportunity stage is set to Determination Complete'));
							}
						else if(redirect =='PendingAdmission') {
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You already have an existing Estimate Of Treatment Cost'));
						}
						else {
							pageRef= new PageReference('/'+iD);
							pageRef.setRedirect(true);
							return pageRef;
						}
					}
				}
			}
			else{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Opportunity does not exis'));
			}
		}
		else{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This action is not allowed as status is closed/Cancelled'));
		}
	}
	else {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Record is locked'));
	}
	return null;
}
}