public with sharing class EmailUtils {

    public static final String NO_REPLY_ADDRESS = 'no-reply@frn.com';

    /**
     * Create a single email that is to be sent to the current user.
     * Set to have the no-reply email address
     * Set it to be UTF-8 so it can handle non-latin characters.
     *
     * @return - The email to be sent out 
     */
    public static Messaging.SingleEmailMessage createSingleEmailForCurrentUser() {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSaveAsActivity(false);
        mail.setReplyTo(EmailUtils.NO_REPLY_ADDRESS);
        mail.setCharset('UTF-8');
        return mail;
    }

    /**
     * Create a single email that is to be sent to specified user
     * Set to have the no-reply email address
     * Set it to be UTF-8 so it can handle non-latin characters.
     *
     * @param userId - User Id of a user to which mail should be sent
     *
     * @return - The email to be sent out
     */
    public static Messaging.SingleEmailMessage createSingleEmailForUser(Id userId) {

        // Create email content
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(userId);
        mail.setSaveAsActivity(false);
        mail.setReplyTo(EmailUtils.NO_REPLY_ADDRESS);
        mail.setCharset('UTF-8');
        return mail;
    }
}