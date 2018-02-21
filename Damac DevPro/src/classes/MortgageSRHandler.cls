public class MortgageSRHandler {
    @InvocableMethod
    public static void MortgageSR(List<Case> lstSR){
        system.debug('lstSR in HandleOCR ' +lstSR);
        sendNotificationToMA(lstSR);
    }

    public static void sendNotificationToMA(List<Case> lstSR){

        List<String> toAddresses = new List<String>();
        Set<String> accountIds = new Set<String>();
        Set<String> bookingUnitIds = new Set<String>();
        Set<String> PCIds = new Set<String>();

        for( Case sr : lstSR){
            accountIds.add(sr.AccountId);
            bookingUnitIds.add(sr.Booking_Unit__c);
            PCIds.add(sr.OwnerId);
        }

        Map<Id, Account> AccountId_AccountMap = new Map<Id, Account>([SELECT Id, Address_Line_1__c, Address_Line_2__c,
                                                                      Address_Line_3__c, Address_Line_4__c, City__pc,
                                                                      State__c, Country__pc, Zip_Postal_Code__c,
                                                                      PersonMobilePhone, Phone, PersonEmail
                                                                      FROM Account WHERE Id IN: accountIds]);

        //this map will hold the unit details
        Map<Id, Booking_Unit__c> BookingUnitId_BookingUnitMap = new Map<Id, Booking_Unit__c>([SELECT Id, Property_Name_Inventory__c,
        																					Unit_Location__c, Unit_Selling_Price__c,
        																					(Select Id,Effective_From__c,Effective_To__c,
        																					Payment_Term__c, Name FROM Payment_Plans__r),
        																					Inventory__r.Unit_Location__r.Status__c
        																					FROM Booking_Unit__c WHERE Id IN: bookingUnitIds ]);

        //this map will hold the property consultant details
        Map<Id, User> UserId_UserDetailMap = new Map<Id, User>([SELECT Id, Name, Email, Phone, MobilePhone, Address
        														FROM User where Id IN : PCIds]);

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Case sr : lstSR ){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('New Mortgage Request: '+sr.CaseNumber );
            //mail.setToAddresses(new String[]{UserId_UserDetailMap.get(sr.OwnerId).Email});
            mail.setToAddresses(new String[]{'amit.joshi@eternussolutions.com'});
            String mailBody = 'Hi,<br/>';

            mailBody += '<p>There is a new Mortgage request. Please see below the details:<br/><br/>';
            mailBody += '<span style="font-weight:bold;">Unit Details:</span><br/>';
            mailBody += 'Project Name : '+BookingUnitId_BookingUnitMap.get(sr.Booking_Unit__c).Property_Name_Inventory__c+'<br/>';
            mailBody += 'Unit Number  : '+BookingUnitId_BookingUnitMap.get(sr.Booking_Unit__c).Unit_Location__c+'<br/>';
            mailBody += 'Unit Price   : '+BookingUnitId_BookingUnitMap.get(sr.Booking_Unit__c).Unit_Selling_Price__c+'<br/>';
            mailBody += 'Payment Plan : '+ (( BookingUnitId_BookingUnitMap.get(sr.Booking_Unit__c).Payment_Plans__r.size() > 0 ) ? BookingUnitId_BookingUnitMap.get(sr.Booking_Unit__c).Payment_Plans__r[0].Name : 'None')+'<br/>';
            mailBody += 'Status       : '+BookingUnitId_BookingUnitMap.get(sr.Booking_Unit__c).Inventory__r.Unit_Location__r.Status__c+'<br/><br/>';

            mailBody += '<span style="font-weight:bold;">Customer Details:</span><br/>';
            mailBody += 'Address:<br/>';
            mailBody += AccountId_AccountMap.get(sr.AccountId).Address_Line_1__c+',';
            mailBody += AccountId_AccountMap.get(sr.AccountId).Address_Line_2__c+',<br/>';
            mailBody += AccountId_AccountMap.get(sr.AccountId).Address_Line_3__c+',';
            mailBody += AccountId_AccountMap.get(sr.AccountId).Address_Line_4__c+',<br/>';
            mailBody += AccountId_AccountMap.get(sr.AccountId).City__pc+',';
            mailBody += AccountId_AccountMap.get(sr.AccountId).State__c+'<br/>';
            mailBody += AccountId_AccountMap.get(sr.AccountId).Zip_Postal_Code__c+',';
            mailBody += AccountId_AccountMap.get(sr.AccountId).Country__pc+'<br/>';
            mailBody += 'Mobile: '+AccountId_AccountMap.get(sr.AccountId).PersonMobilePhone+'<br/>';
            mailBody += 'Phone : '+AccountId_AccountMap.get(sr.AccountId).Phone+'<br/>';
            mailBody += 'Email : '+AccountId_AccountMap.get(sr.AccountId).PersonEmail+'<br/><br/>';

            mailBody += '<span style="font-weight:bold;">Property Consultant Details:</span><br/>';
            mailBody += 'Name: '+UserId_UserDetailMap.get(sr.OwnerId).Name+'<br/>';
            mailBody += 'Phone : '+UserId_UserDetailMap.get(sr.OwnerId).Phone+'<br/>';
            mailBody += 'Mobile: '+UserId_UserDetailMap.get(sr.OwnerId).MobilePhone+'<br/>';
            mailBody += 'Email : '+UserId_UserDetailMap.get(sr.OwnerId).Email+'<br/>';
            mailBody += 'Address: '+UserId_UserDetailMap.get(sr.OwnerId).Address+'</p>';
            mailBody += 'Thank you,<br/>DAMAC Team.';
            mail.setHtmlBody( mailBody );


            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
}