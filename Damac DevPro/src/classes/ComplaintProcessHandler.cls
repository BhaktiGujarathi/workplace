public with sharing class ComplaintProcessHandler {

	@InvocableMethod
	public static void HandleProcess (List<Case> lstSR) {
			sendNotificationToMA(lstSR);
	}


	public static void sendNotificationToMA(List<Case> lstSR){

			List<String> toAddresses = new List<String>();
			//Set<String> accountIds = new Set<String>();
			//Set<String> bookingUnitIds = new Set<String>();
			Set<String> PCIds = new Set<String>();

			for( Case sr : lstSR){
					//accountIds.add(sr.AccountId);
					//bookingUnitIds.add(sr.Booking_Unit__c);
					PCIds.add(sr.OwnerId);
			}

			/*Map<Id, Account> AccountId_AccountMap = new Map<Id, Account>([SELECT Id, Address_Line_1__c, Address_Line_2__c,
																																		Address_Line_3__c, Address_Line_4__c, City__pc,
																																		State__c, Country__pc, Zip_Postal_Code__c,
																																		PersonMobilePhone, Phone, PersonEmail
																																		FROM Account WHERE Id IN: accountIds]);
			*/
			//this map will hold the unit details
			/*Map<Id, Booking_Unit__c> BookingUnitId_BookingUnitMap = new Map<Id, Booking_Unit__c>([SELECT Id, Property_Name_Inventory__c,
																								Unit_Location__c, Unit_Selling_Price__c,
																								(Select Id,Effective_From__c,Effective_To__c,
																								Payment_Term__c, Name FROM Payment_Plans__r),
																								Inventory__r.Unit_Location__r.Status__c
																								FROM Booking_Unit__c WHERE Id IN: bookingUnitIds ]);
			*/
			//this map will hold the property consultant details
			Map<Id, User> UserId_UserDetailMap = new Map<Id, User>([SELECT Id, Name, Email, Phone, MobilePhone, Address
																	FROM User where Id IN : PCIds]);

			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			for(Case sr : lstSR ){
					Messaging.SingleEmailMessage mailToDirector = new Messaging.SingleEmailMessage();

					mailToDirector.setSubject('New Complaint Case: '+sr.CaseNumber );
					//mail.setToAddresses(new String[]{UserId_UserDetailMap.get(sr.OwnerId).Email});
					mailToDirector.setToAddresses(new String[]{'snehil.karn@eternussolutions.com'});
					String mailBodyDir = 'Hi,<br/>';
					mailBodyDir += '<p>There is a new Complaint request raised.</p>';
					mailBodyDir += 'Thank you,<br/>DAMAC Team.';
					mailToDirector.setHtmlBody( mailBodyDir );
					mails.add(mailToDirector);

					Messaging.SingleEmailMessage mailToCustomer = new Messaging.SingleEmailMessage();
					mailToCustomer.setSubject('Your Complaint Logged: '+sr.CaseNumber );
					//mail.setToAddresses(new String[]{UserId_UserDetailMap.get(sr.OwnerId).Email});
					mailToCustomer.setToAddresses(new String[]{'snehil.karn@eternussolutions.com'});
					String mailBodyCust = 'Hi,<br/>';
					mailBodyCust += '<p>Your complaint has been registered and our representative is working on it.</p>';
					mailBodyCust += 'The Reference Number is: <b>'+sr.CaseNumber+'</b></p><br/><br/>';
					mailBodyCust += 'Thank you,<br/>DAMAC Team.';
					mailToCustomer.setHtmlBody( mailBodyCust );
					mails.add(mailToCustomer);
			}
			Messaging.sendEmail(mails);
	}
}