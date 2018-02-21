public with sharing class SendErrorMail {
	public static final String emailAddForErrorLog = Label.Email_Address_For_Error_Log;
    public static final String subjectForErrorLog = 'Error Log (CMBIO)';
	public static void sendErrorLog(String errorMessage) {

	        List<Messaging.SingleEmailMessage> listMails = new List<Messaging.SingleEmailMessage>();
	        // Create a new Email
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

	        // Set list of people who should get the email
	        List<String> sendTo = new List<String>();
	        sendTo.add(emailAddForErrorLog);
	        mail.setToAddresses(sendTo);

	        mail.setSubject(subjectForErrorLog);
	        mail.setHtmlBody(errorMessage);
	        listMails.add(mail);

	        Messaging.sendEmail(listMails);

	    }//End sendErrorLog
}