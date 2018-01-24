global with sharing class MCAExceptionHandlerUtility {
     
    global Static String getErrorMessage(Exception pException) {
        String messageString;
        if(pException.getTypeName().contains('System.DmlException')) 
        {  
            if(pException.getDMLMessage(0).contains('INSUFFICIENT_ACCESS'))
            {
                messageString = 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.';
            }
            else if(pException.getMessage().contains('STORAGE_LIMIT_EXCEEDED'))
            {
                messageString = 'Please contact your administrator as the Storage Limit of organisation has exceeded.';
            }
            else
            {
                messageString = pException.getDMLMessage(0);
            }
          
        }
        else if(pException.getTypeName().contains('NullPointerException'))
        { 
            messageString = pException.getMessage();
        }
        else if(pException.getTypeName().contains('ListException')) 
        { 
            messageString = pException.getMessage();
        }
        else if(pException.getTypeName().contains('System.LimitException')){
            if(pException.getMessage().contains('EMAIL_LIMIT_EXCEEDED'))
            {
                messageString = system.label.Submission_EmailLimitExceeded;
            }
            else
                messageString = pException.getMessage();
        }
        else if(pException.getTypeName().contains('System.EmailException'))
        {
            if(pException.getMessage().contains('NO_MASS_MAIL_PERMISSION'))
            {
                messageString = system.label.Submission_MassEmailPermission;
            }
            else if(pException.getMessage().contains('EMAIL_LIMIT_EXCEEDED'))
            {
                messageString = system.label.Submission_EmailLimitExceeded;
            }
            else
                messageString = pException.getMessage();
        }
        else 
        { 
            messageString = pException.getMessage(); 
        }        
        return messageString;
    }
}