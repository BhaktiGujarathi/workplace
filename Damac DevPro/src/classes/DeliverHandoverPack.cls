public with sharing class DeliverHandoverPack{
    
    public DeliverHandoverPack(ApexPages.standardController controller){
      
        
    }//End constructor
    
    public pagereference init(){
        list<Case> lstCase = new list <Case>();
            string strPageID = ApexPages.currentPage().getParameters().get('id');
            string strBookingUnit;
            for(Case objCase : [Select ID,
                                                   Handover_Sent_Date__c,
                                                   Handover_Notice_Sent__c,
                                                   Handover_Status__c,
                                                   Booking_Unit__c
                                              from Case
                                             where ID =: strPageID ]){
                 objCase.Handover_Sent_Date__c = Date.Today();
                 objCase.Handover_Notice_Sent__c = True;
                 //objCase.Handover_Status__c = 'Handover Pack Sent';
                 lstCase.add(objCase);
                 strBookingUnit = objCase.Booking_Unit__c;
             }
        update lstCase;
        
        list<Booking_Unit__c> lstBU = new list<Booking_Unit__c>();
        for (Booking_Unit__c objBU : [Select Id, SR_Handover_Status__c From Booking_Unit__c Where Id =:strBookingUnit ]) {
            objBU.SR_Handover_Status__c = 'Handover Pack Sent';
            lstBU.add(objBU);
        }
        update lstBU;       
        
        set<ID> setSRAttachment = new set<ID>();
        for(SR_Attachments__c objSRAtt : [select ID, Case__c from SR_Attachments__c where Case__c =: strPageID ]){
          setSRAttachment.add(objSRAtt.ID);
        }
       List<Attachment> lstAttachment = new list<Attachment>();
       List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
       for (Attachment attachItr : [SELECT id, Name, Body FROM Attachment WHERE parentId IN : setSRAttachment])
        {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(attachItr.Name);
            efa.setBody(attachItr.Body);
            fileAttachments.add(efa);
            lstAttachment.add(attachItr);
        }
        
        /*Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Handover Pack');
        email.setPlainTextBody('Hello, PFA of Handover pack');
        String[] toAddresses = new string[]{'yogeshsharma2391@gmail.com', 'lochank58@gmail.com'};
        
        email.setToAddresses(toAddresses);
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('AuthorizeReturn.pdf');
        //efa.setBody(PDFBody);
         
        email.setFileAttachments(fileAttachments);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});*/
        
       
       
       pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+strPageID);
       newpg.setRedirect(true);
       return newpg;
    }
    
        
}