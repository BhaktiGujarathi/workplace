public class TaskAttachmentReparentingController {

    public static final String MORTGAGE_CLOSED_STATUS = 'Closed';
    public static final String MORTGAGE_CLOSED_SUBJECT = 'Obtain Proposal from Bank';
    @InvocableMethod
    public static void HandleAttachmentReparenting (List<Task> taskList) {

      List<String> caseIds = new List<String>();
      List<Task> rejectedTaskList = new List<Task>();
      for(Task t :  taskList){
        if(t.Status == MORTGAGE_CLOSED_STATUS && t.Subject == MORTGAGE_CLOSED_SUBJECT && t.Mortgage_Offered__c == false){
          rejectedTaskList.add(t);
        }
        if(!String.isBlank(t.WhatId)){
          caseIds.add(t.WhatId);
        }
      }

      if(!rejectedTaskList.isEmpty()){
        unflagBookingUnit(rejectedTaskList, caseIds);
        sendRejectionsNotificationToCustomer(rejectedTaskList, caseIds);
      }

      reparentAttachments(taskList);
    }

    public static void reparentAttachments(List<Task> taskList){
      List<SR_Attachments__c> caseAttachmentList = new List<SR_Attachments__c>();
      Map<String, Task> taskId_TaskDetailsMap = new Map<String, Task>();
      List<String> taskIds = new List<String>();

      for(Task taskObj : taskList){
        taskId_TaskDetailsMap.put(taskObj.Id, taskObj);
        taskIds.add(taskObj.Id);
      }

      List<Attachment> attachmentList = [ SELECT Body, Name, ParentId, ContentType FROM Attachment WHERE ParentId IN : taskIds];
      integer index = 0;
      Map<String, Integer> attachmentId_IndexMap = new Map<String, Integer>();

      for( Attachment attachmentObj : attachmentList ){
          SR_Attachments__c caseAttachmentObj = new SR_Attachments__c(Case__c = taskId_TaskDetailsMap.get(attachmentObj.ParentId).WhatId,
                                                                      Name = attachmentObj.Name, Type__c = attachmentObj.ContentType,
                                                                      Attachment__c = attachmentObj.Id );
          caseAttachmentList.add(caseAttachmentObj);
          attachmentId_IndexMap.put( attachmentObj.Id, index);
          index++;
      }

      if(!caseAttachmentList.isEmpty()){
        try{
          insert caseAttachmentList;

          for( Attachment attachmentObj : attachmentList ){
            attachmentObj.ParentId = caseAttachmentList[attachmentId_IndexMap.get(attachmentObj.Id)].Id;
          }

          try{
            update attachmentList;
          } catch(Exception e){
            System.debug(e);
          }

        } catch(Exception e){
          System.debug(e);
        }
      }
    }

    public static void unflagBookingUnit(List<Task> taskList, List<String> caseIds){

      List<Booking_Unit__c> bookingUnitList = new List<Booking_Unit__c>();
      for(Case sr : [ SELECT Booking_Unit__c, Booking_Unit__r.Mortgage_Applied__c, Id FROM Case WHERE Id IN :caseIds ] ){
        Booking_Unit__c bookinhUnitObj = new Booking_Unit__c(Id=sr.Booking_Unit__c,Mortgage_Applied__c=false);
        bookingUnitList.add(bookinhUnitObj);
      }
      try{
        update bookingUnitList;
      } catch( Exception e){

      }
    }

    public static void sendRejectionsNotificationToCustomer(List<Task> taskList, List<String> caseIds){
      List<String> toAddresses = new List<String>();
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

      for(Case sr : [ SELECT Contact_Email_Id__c, CaseNumber, Account.FirstName, Account.LastName FROM Case WHERE Id IN :caseIds ] ){
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          mail.setSubject('MOrtgage Request Rejected - '+sr.CaseNumber );
          mail.setToAddresses(new String[]{ sr.Contact_Email_Id__c });
          String mailBody = 'Hi '+ sr.Account.FirstName + ' ' + Account.LastName + ',<br/>';

          mailBody += '<p>We are sorry to inform that you are not eligible for Mortgage.<br/><br/>';
          mailBody += 'Thank you,<br/>DAMAC Team.';
          mail.setHtmlBody( mailBody );


          mails.add(mail);
      }
      Messaging.sendEmail(mails);
    }
}