public with sharing class ComplaintProcessEscalationHandler {

	@InvocableMethod
	public static void HandleEscalationProcess (List<Case> lstSR) {
		List<Case> escalateToDirCase = new List<Case>();
		List<Case> escalateToSVPCase = new List<Case>();
		for(Case caseObj: lstSR){
			if( caseObj.Customer_Connected_Through_CTI__c == false && caseObj.Status == 'CRE Notified' ){
				escalateToDirCase.add(caseObj);
			} else if( caseObj.Customer_Connected_Through_CTI__c == false && caseObj.Status == 'Escalated to Director' ){
				escalateToSVPCase.add(caseObj);
			}
		}

		if(!escalateToDirCase.isEmpty()){
			sendNotificationToDirector(escalateToDirCase);
		}

		if(!escalateToSVPCase.isEmpty()){
			sendNotificationToSVP(escalateToSVPCase);
		}
	}

	public static void sendNotificationToDirector(List<Case> lstSR){

			List<String> toAddresses = new List<String>();

			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			for(Case sr : lstSR ){
					Messaging.SingleEmailMessage mailToDirector = new Messaging.SingleEmailMessage();

					mailToDirector.setSubject('Alert!! Case has not been closed for 24 hours: '+sr.CaseNumber );
					mailToDirector.setToAddresses(new String[]{'snehil.karn@eternussolutions.com'});
					String mailBodyDir = 'Hi,<br/>';
					mailBodyDir += '<p>There is a Complaint request that has not been solved for the last 24 hours. This is an escalation email. Please review.</p>';
					mailBodyDir += 'Thank you,<br/>DAMAC Team.';
					mailToDirector.setHtmlBody( mailBodyDir );
					mails.add(mailToDirector);
			}
			Messaging.sendEmail(mails);
	}

	public static void sendNotificationToSVP(List<Case> lstSR){

			List<String> toAddresses = new List<String>();

			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			for(Case sr : lstSR ){
					Messaging.SingleEmailMessage mailToSVP = new Messaging.SingleEmailMessage();

					mailToSVP.setSubject('Alert!! Case has not been closed for 48 hours: '+sr.CaseNumber );
					mailToSVP.setToAddresses(new String[]{'snehil.karn@eternussolutions.com'});
					String mailBodySvp = 'Hi,<br/>';
					mailBodySvp += '<p>There is a Complaint request that has not been solved for the last 24 hours. This is an escalation email. Please review.</p>';
					mailBodySvp += 'Thank you,<br/>DAMAC Team.';
					mailToSVP.setHtmlBody( mailBodySvp );
					mails.add(mailToSVP);
			}
			Messaging.sendEmail(mails);
	}
}