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
    /*
    public List<Messaging.SingleEmailMessage> createSendMailRecord(List<Messaging.EmailFileAttachment> listAttachment, List<Opportunity> listOpportunity,
                                        String emailSubject, String emailBCC, String emailBody, 
                                        Map<Id, Account> mapOFAccIDAndAccName, map<Id, User> userMap) {
    
        // Used to store all the email record
        List<Messaging.SingleEmailMessage> listMails = new List<Messaging.SingleEmailMessage>();
        Messaging.Singleemailmessage message;
        List<String> BCCAddress = new List<String>();
        this.emailSubject = emailSubject.replace('{Account Name}', '');
       
        
        BCCAddress = emailBCC.split(',');
        this.emailBody = emailBody;
        this.emailSubject = emailSubject.replace('{Account Name}', '');
        String emailBodyWithHTML = '';
        // Process the opp for creation of email record
        for(Opportunity objOpp :listOpportunity) {
            message = new Messaging.Singleemailmessage();
            message.setSaveAsActivity(true);

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
                message.setSubject(this.emailSubject+' '+setSubject(objOpp.Id,mapOFAccIDAndAccName));
                emailBodyWithHTML = setBody(objOpp,this.emailBody,(userMap.get(objOpp.OwnerId)).Name,
                                                  (userMap.get(objOpp.OwnerId)).CompanyName);
                
                message.setHtmlBody(emailBodyWithHTML);
                message.setWhatId(objOpp.Id);
                listMails.add(message);
           }//End if
        }//End For
        return listMails;
    }//End createSendMailRecord
    */
    
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
    
    /*// Create task 
    public List<MovingRenewalController.OpportunityTaskWrapper> createTask(List<Opportunity> listOpportunity, 
                            List<MovingRenewalController.OpportunityTaskWrapper> pOppTaskWrapperList) {
        
        MovingRenewalController.OpportunityTaskWrapper oppTaskwrapperObj;
        List<Opportunity> listOfRenewedOpportunities = new List<Opportunity>();      
        Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();
        for(Opportunity objOpp :listOpportunity)
        {
            if(!idToOpportunityMap.containsKey(objOpp.Id))
            {
                idToOpportunityMap.put(objOpp.Id, objOpp);
                system.debug('Name '+objOpp.Name);
                system.debug('Owner Name '+objOpp.Owner_1__r.Name);
                system.debug('Email '+objOpp.Owner_1__r.Email);
            }
        }
        
        listOfRenewedOpportunities = [SELECT id,
                                             Owner_1__r.Name,
                                             Owner_1__r.Email,
                                             Name,
                                             (SELECT id,
                                                     Status,
                                                     Description,
                                                     Subject,
                                                     OwnerId,
                                                     WhatId,
                                                     Owner.Name
                                              FROM Tasks
                                              Order By CreatedDate DESC
                                              Limit 1)
                                       FROM Opportunity
                                       WHERE id IN : idToOpportunityMap.keySet()];
                                
        for(Opportunity opportunityInstance : listOfRenewedOpportunities)
        {
            for(Task taskInstance : opportunityInstance.Tasks)
            {
                oppTaskwrapperObj = new MovingRenewalController.OpportunityTaskWrapper(opportunityInstance, taskInstance);
                pOppTaskWrapperList.add(oppTaskwrapperObj);
            }
        }
        return pOppTaskWrapperList;
    }//End createTask()*/
    
    //.....................END Fo-1389
   /* public String setSubject(Id oppId,Map<Id, Account> mapOFAccIDAndAccName){
        String subject = '';
        if(mapOFAccIDAndAccName.containsKey(oppId) 
                    && mapOFAccIDAndAccName.get(oppId) != null)
                        subject = mapOFAccIDAndAccName.get(oppId).name;
        return subject;
    }*/
   /* 
    public String setBody(Opportunity objOpp, String emailBody, String userName, String companyName){
        String emailBodyWithHTML;
        // create html body
        if(objOpp.Owner_1__c != null && (objOpp.Owner_1__r.FirstName != null ||
                                                 objOpp.Owner_1__r.FirstName != '')){
            // add user details
            emailBodyWithHTML = messageBodyContent(objOpp.Owner_1__r.FirstName,emailBody,
                                          userName,companyName);
            
            emailBodyWithHTML = emailBodyWithHTML.replace('{Owner First Name}', '');
            emailBodyWithHTML = emailBodyWithHTML.replace('{Opportunity Owner} {Opportunity.Owner.Company}', 
                                                                                       '');
        } else {
            emailBodyWithHTML = messageBodyContent('',emailBody,'','');
        }
        emailBodyWithHTML = emailBodyWithHTML.replace('null', '');
        return emailBodyWithHTML;
    }
    */
    /*
    // Create task 
    public List<Task> createTask(List<Opportunity> listOpportunity,Map<Id, Account> mapOFAccIDAndAccName, 
                                    map<Id, User> userMap, String emailSubject, String emailBody) {
        Task task;
        List<Task> listTask = new List<Task>();
        emailSubject = emailSubject.replace('{Account Name}', '');
       
        for(Opportunity objOpp :listOpportunity){
            task = new Task();
            task.Status = 'Completed';
            task.Subject = emailSubject+' '+setSubject(objOpp.Id,mapOFAccIDAndAccName);
            task.Description = taskDescription(objOpp,emailBody,(userMap.get(objOpp.OwnerId)).Name,
                                                  (userMap.get(objOpp.OwnerId)).CompanyName);
            
            task.OwnerId = objOpp.OwnerId;
            task.WhatId = objOpp.Id;
            listTask.add(task);
        }
        return listTask;
    }//End createTask()
    *//*
    public String taskDescription (Opportunity objOpp, String pstrBody, String pOwnername, 
                                                                            String pOwnerCompany) {
         String messageBody = '';
         if(objOpp.Owner_1__c != null && (objOpp.Owner_1__r.FirstName != null ||
            objOpp.Owner_1__r.FirstName != '')){
             List<String> lststrBody = pstrBody.split(',',2);
             List<String> lststrBodyDetails;
             if(lststrBody.size() > 0)
                lststrBodyDetails = lststrBody[1].split('Thanks,',2);
             if(objOpp.Owner_1__r.FirstName != '' && lststrBody.size() > 0 && lststrBodyDetails.size()>0)
                messageBody = lststrBody[0] +' '+ objOpp.Owner_1__r.FirstName + lststrBodyDetails[0]+ 'Thanks,'+
                                  lststrBodyDetails[1] +pOwnername+' '+pOwnerCompany;
             else
                messageBody = pstrBody;
             messageBody = messageBody.replace('{Owner First Name}', '');
             messageBody = messageBody.replace('{Opportunity Owner} {Opportunity.Owner.Company}','');
             messageBody = messageBody.replace('null', '');
         }
         return messageBody;
    }*/
    /*
    //It is used to set send email body
    public String messageBodyContent(String contactName, String pstrBody, String pOwnername, 
                                                                            String pOwnerCompany) {
        
        List<Document> docuLst = new List<Document>();
        String messageBody = '';
        String query = 'Select SystemModstamp, Name, Id From Document where Name = \''
                                                              +Label.RenewalManagementLogoName
                                                              +'\' Limit 1';
        docuLst = Database.query(query);
        if(pstrBody != null && pstrBody != '') {
            if(!docuLst.IsEmpty()) {
                String strOrgId = UserInfo.getOrganizationId();
                String orgInst = URL.getSalesforceBaseUrl().getHost();
                String strDocUrl = URL.getSalesforceBaseUrl().getProtocol() + '://' + orgInst + 
                                   '/servlet/servlet.ImageServer?id=' + docuLst[0].Id + 
                                   '&oid=' + strOrgId;

                // to append the contact name in an email body
                List<String> lststrBody = pstrBody.split(',',2);
                List<String> lststrBodyDetails;
                if(lststrBody.size() > 0)
                    lststrBodyDetails = lststrBody[1].split('Thanks,',2);
                if(contactName != '' && lststrBody.size() > 0 && lststrBodyDetails.size()>0)
                    messageBody = '<html><body><div align="center"><img src="'+strDocUrl+
                              '" alt="Company Logo"></img></div>'+lststrBody[0] +' '+ contactName +
                              ',<br/><br/>'+  lststrBodyDetails[0]+ '<br/><br/>'+'Thanks,<br/>'+
                              lststrBodyDetails[1] +pOwnername+' '+pOwnerCompany+'</body></html>';
                else
                    messageBody = '<html><body><div align="center"><img src="'+strDocUrl+
                                     '" alt="Company Logo"></img></div>'+pstrBody+'</body></html>';
                 
                return messageBody;
            } else{
                messageBody =  pstrBody; 
                messageBody = messageBody.replaceAll('<[^>]+>',' \r\n');
                return messageBody;
            }// End Else - If
            
        }//Emd If 
        return messageBody;
    } // End messageBodyContent()*/
    
}//End Class