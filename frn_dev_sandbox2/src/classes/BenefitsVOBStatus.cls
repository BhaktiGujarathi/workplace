global class BenefitsVOBStatus { 
    webservice static string VOBStatusCheck(String agreementID){
		
        if(agreementID != null){
   	    Opportunity OpportunityBS = [SELECT Id, Benefits_Status__c FROM Opportunity where id =:  agreementID];
        
		if(OpportunityBS != null){
			if(OpportunityBS.Benefits_Status__c != null && OpportunityBS.Benefits_Status__c == 'VOB Approved'){
				return 'VOBApproved';
			}else{
				return 'PendingAdmission';
			}
		}
		}
		return null; 
    } 
	
	webservice static string VOBStageCheck(String agreementID){
        if(agreementID != null){
		Pay_Agreement_Worksheet__c payAgreement = [SELECT Id, Opportunity__c, Insurance_Benefit__c,Insurance_Benefit__r.Patient_Insurance__r.Opportunity__r.StageName FROM Pay_Agreement_Worksheet__c where id =:  agreementID];
         
		if(payAgreement != null){
			if(payAgreement.Insurance_Benefit__r.Patient_Insurance__r.Opportunity__r.StageName != null && payAgreement.Insurance_Benefit__r.Patient_Insurance__r.Opportunity__r.StageName == 'VOB Approved'){
				return 'VOBApproved';
			}else{
				return 'PendingAdmission';
			}
		}
		
	}
	return null;
	}
	
}