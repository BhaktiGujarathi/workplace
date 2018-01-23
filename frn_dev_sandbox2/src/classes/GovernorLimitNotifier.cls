//@TODO rename class to GovernorLimitNotifier
public Class GovernorLimitNotifier {
    
    //Developer should be able to set flag for which is expects the limits to be checked
    
    public Map<String,Boolean> monitorLimitsFlags;
    public Map<String,Integer> currentLimitCount;
    public Map<String,Integer> totalLimitsCount;
    public Map<String,Integer> limitCheckThreshold;
    
    public wrapperLimitClass GovernorLimitNotifier(){
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries()); 
        System.debug('Total Number of async calls allowed in this apex code context: ' +  Limits.getLimitAsyncCalls());   
        wrapperLimitClass wc = new wrapperLimitClass();
        wc.soqlLimit = Limits.getLimitQueries();
        wc.asyncLimit = Limits.getLimitAsyncCalls();
        
        Profile sysAdmProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        string profileId = sysAdmProfile.Id;
        User sysAdm = [SELECT id, Email FROM User WHERE ProfileId =: profileId];
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
               
        String[] toAddresses = new String[] {sysAdm.Email};
        mail.setToAddresses(toAddresses);         
        mail.setSubject('Current Apex Limits');
        String body = 'Hi ' + sysAdm.FirstName + ', ';
        body += 'Following are the details about currently used apex limits';
        body += '1. SOQL Limit:' + wc.soqlLimit + ', ';
        body += '2. Async Limit:' + wc.asyncLimit;
        mail.setHtmlBody(body);        
        mails.add(mail);
        Messaging.sendEmail(mails);
        
        return wc;     
    }
    
    public class wrapperLimitClass{
        Integer soqlLimit;
        Integer asyncLimit;
    }       
}