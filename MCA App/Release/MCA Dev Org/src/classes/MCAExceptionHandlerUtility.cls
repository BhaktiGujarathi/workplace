public with sharing class MCAExceptionHandlerUtility {
     
    public Static String getErrorMessage(Exception pException) {
        String messageString;

        if(pException.getTypeName().contains('System.DmlException')) 
        {
            messageString = pException.getDMLMessage(0);
           // messageString = pException.getCause().getMessage();
        }
        else if(pException.getTypeName().contains('NullPointerException'))
        {
            messageString = pException.getMessage();
        }
        else if(pException.getTypeName().contains('ListException')) 
        {
            messageString = pException.getMessage();
        }
        else 
        {
            messageString = pException.getMessage();
            
             
        }
        return messageString;
    }
}