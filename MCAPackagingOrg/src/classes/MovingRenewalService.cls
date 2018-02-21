/*
 *  Version           Author                 Date                 Description 
 *   1.0           Yogesh Mahajan           26/9/2014            Initial Draft 
 *   1.1           Ajinkya Hingne           22/9/2016            Activity should not created when mail is sent
 */
public with sharing class MovingRenewalService {
    
    public String emailSubject;
    //public String taskSubject;
    public String emailBody = '';
    public MovingRenewalService() 
    {
    }
    // Create send mail record  
    //.............FO-1389
    public List<Messaging.SingleEmailMessage> createSendMailRecord(List<Messaging.EmailFileAttachment> listAttachment, List<Opportunity> listOpportunity,
                                        String emailBCC, EmailTemplate objEmailTemplate) {
    
        // Used to store all the email record
        List<Messaging.SingleEmailMessage> listMails = new List<Messaging.SingleEmailMessage>();
        Messaging.Singleemailmessage message;
        List<String> BCCAddress = new List<String>();
        BCCAddress = emailBCC.split(',');
            
                // Process the opp for creation of email record
                for(Opportunity objOpp :listOpportunity) {
                    message = new Messaging.Singleemailmessage();
                    message.setSaveAsActivity(false);
    
                    //Add attchment
                    if(listAttachment != null && !listAttachment.IsEmpty())
                        message.setFileAttachments(listAttachment);
    
                   //add bcc address
                    if(BCCAddress.size() > 0)
                        message.setBccAddresses(BCCAddress);
                    //taskSubject = this.emailSubject+' '+(mapOFAccIDAndAccName.get(objOpp.Id)).name;
                   //Note :  Call task creation function(Plz check the old code) 
                   if(objOpp.Owner_1__c != null && objOpp.Owner_1__r.Email != null){
                        message.setToAddresses(new List<String>{objOpp.Owner_1__r.Email});
                        message.setTemplateID(objEmailTemplate.Id);
                        message.setTargetObjectId(objOpp.Owner_1__c);
                        message.setWhatId(objOpp.Id);
                        listMails.add(message);
                   }//End if
                }//End For
        return listMails;
    }//End createSendMailRecord
       
    //.....................END Fo-1389

}//End Class