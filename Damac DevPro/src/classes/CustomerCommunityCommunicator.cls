global class CustomerCommunityCommunicator{
   webservice static String sendInvitationEmail(Id[] accIds) {
       list<Messaging.SingleEmailMessage> allmails = new list<Messaging.SingleEmailMessage>();       
       
       //Select email template for user language from custom settings.
       Customer_Community_Language_Settings__c listCustom = [Select language__c , 
                                                                    Community_Invitation_Email__c 
                                                             from Customer_Community_Language_Settings__c 
                                                             where Language__c = :UserInfo.getLanguage()];
       
       //select template html body from email template
       EmailTemplate emailObj = [Select id, HtmlValue from EmailTemplate where id = :listCustom.Community_Invitation_Email__c];     
       
       //send email to selected account ids
       for(Account acc: [Select Name,Email__c from Account where Id IN :accIds]){       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       list<string> toAddresses = new list<string>();  
       //set selected accounts' email address as recepient
       toAddresses.add(acc.Email__c);
           if(!toAddresses.isEmpty()){            
               mail.setToAddresses(toAddresses);                   
               system.debug(toAddresses);
               
               //set email body as template html body
               mail.setHtmlBody(emailObj.HtmlValue);  
               
               //set whatId to set Merge Fields' values
               mail.setWhatId(acc.id);             
               mail.setTreatBodiesAsTemplate(true);
               allmails.add(mail);                
           }
           system.debug('>>> mail : '+mail);
       }
       system.debug('>>> mail.size : '+allmails.size());
       // send email to selected accounts.
       //Messaging.sendEmail(allmails); 
       return 'success';
   }
}