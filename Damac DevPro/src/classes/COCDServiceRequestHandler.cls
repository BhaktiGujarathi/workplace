public class COCDServiceRequestHandler {
    public static void NotifyUserForSR(List<Case> lstSR){
        List<String> toAddresses = new List<String>();
        for( Case sr : lstSR){
            toAddresses.add(sr.Contact_Email_Id__c);
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);

        mail.setSubject('Your COCD Service request is received' );
        String mailBody = 'Hi,<br/>';
        mailBody += '<p>Your request for details change has been received and is being processed.';
        mailBody += ' You will be notified once the process is complete.</p><br/><br/>';
        mailBody += 'Thanks you,<br/>DAMAC Team.';

        mail.setHtmlBody( mailBody );
        system.debug('mail' + mail);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }


    public static void ProcessHandler(List<Case> lstSR){
        List<Case> cocdSRs = new List<Case>();
        List<Case> cojbSRs = new List<Case>();
        List<Case> nncSRs = new List<Case>();
        List<Case> pduSRs = new List<Case>();
        for(Case sr : lstSR){
            if( sr.Type == 'Change of Contact Details') {
                cocdSRs.add(sr);
            } else if ( sr.Type == 'Change of Joint Buyer Details') {
                cojbSRs.add(sr);
            } else if ( sr.Type == 'Name Nationality Change SR') {
                nncSRs.add(sr);
            } else if ( sr.Type == 'Passport Detail Update SR') {
                pduSRs.add(sr);
            }
        }

        if(!cocdSRs.isEmpty()){
            COCDHandler(cocdSRs);
        }

        if(!cojbSRs.isEmpty()){
            COJBHandler(cojbSRs);
        }

        if(!nncSRs.isEmpty()){
            NameNationalityHandler(nncSRs);
        }

        if(!pduSRs.isEmpty()){
            PassportUpdateHandler(pduSRs);
        }
    }

    public static void COCDHandler( List<Case> cocdSRList ){
        system.debug('inside cocd handler');
        InsertTasksForLegal(cocdSRList);
        InsertTasksForFinance(cocdSRList);
        /*List<String> accIds = new List<String>();
        for( Case sr : cocdSRList ){
            if(sr.AccountId != null){
                accIds.add(sr.AccountId);
            }

            //sr.OCR_verified__c = true;
        }
        //update cocdSRList;

        if(!accIds.isEmpty()){
            List<OQOOD_FLG__c> oqoodList = [ SELECT Account__c, Id, OQOOD_Reg_Flag__c, COCD_Fee_Paid__c  FROM OQOOD_FLG__c WHERE Account__c IN: accIds AND OQOOD_Reg_Flag__c = true AND COCD_Fee_Paid__c = false];

            if(!oqoodList.isEmpty()){
                //callout oQooD payment

            }


        }*/
    }


    public static void COJBHandler( List<Case> cojbSRList ){
       // DocumentOCRCallout(cojbSRList);
       InsertTasksForLegal(cojbSRList);
    }


    public static void NameNationalityHandler( List<Case> nncSRList ){
      InsertTasksForLegal(nncSRList);
        //DocumentOCRCallout(nncSRList);
        /*system.debug('inside nnc handler');
        List<String> accIds = new List<String>();
        Map<String, Map<String, String>> accId_NewValuesMap = new Map<String, Map<String, String>>();
        for( Service_request__c sr : nncSRList ){
            if(sr.Account__c != null){
                accIds.add(sr.Account__c);
                Map<String, String> newNameNationalityMap = new Map<String, String>();
                if(sr.Changed_Nationality__c != null){
                    newNameNationalityMap.put('nationality', sr.Changed_Nationality__c);
                }
                if(sr.New_Contact_Value__c != null){
                    newNameNationalityMap.put('name', sr.New_Contact_Value__c);
                }
                accId_NewValuesMap.put(sr.Account__c, newNameNationalityMap);
            }
        }

        if(!accIds.isEmpty()){
            List<Account> accToUpdateList = new List<Account>();
            for( String acId : accIds ){
                Account a = new Account();
                a.Id = acId;
                if(accId_NewValuesMap.get(acId).get('name') != null){
                    a.Name = accId_NewValuesMap.get(acId).get('name');
                }
                if(accId_NewValuesMap.get(acId).get('nationality') != null){
                    a.Nationality__pc = accId_NewValuesMap.get(acId).get('nationality');
                }
                accToUpdateList.add(a);
            }
        }*/

    }

    public static void PassportUpdateHandler( List<Case> pduSRsList ){
      InsertTasksForLegal(pduSRsList);

    }

    public static void InsertTasksForLegal(List<Case> cocdSRList){
      List<Task> poaTasksForLegalList = new List<Task>();
      for(Case sr : cocdSRList){
        if(sr.IsPOA__c == true){
          Task task = new Task();
          task.WhatId = sr.id;
          task.OwnerId = sr.OwnerId;
          task.Subject = 'Verify POA Documents';
          task.Status = 'Not Started';
          poaTasksForLegalList.add(task);
        }
      }
System.debug('tasks to be inserted '+poaTasksForLegalList);
      if(!poaTasksForLegalList.isEmpty()){
        insert poaTasksForLegalList;
      }
    }

    public static void InsertTasksForFinance(List<Case> cocdSRList){
      List<Task> oqoodTasksForFinanceList = new List<Task>();
      for(Case sr : cocdSRList){
        if(sr.OQOOD_Fee_Applicable__c == true && (sr.OQOOD_Fee_Payment_Mode__c == 'Cheque' || sr.OQOOD_Fee_Payment_Mode__c == 'Online')){
          Task task = new Task();
          task.WhatId = sr.id;
          task.OwnerId = sr.OwnerId;
          task.Subject = 'Verify OQOOD Fee Payment';
          task.Status = 'Not Started';
          oqoodTasksForFinanceList.add(task);
        }
      }
System.debug('tasks to be inserted '+oqoodTasksForFinanceList);
      if(!oqoodTasksForFinanceList.isEmpty()){
        insert oqoodTasksForFinanceList;
      }
    }

    public static void DocumentOCRCallout(List<Case> lstSR){
        List<id> srIds = new List<id>();
        for( Case sr : lstSR){
            //srIds.add(sr.Id);
            sr.OCR_verified__c=true;
            sr.Document_Verified__c = true;
        }
        update lstSR;
        //OCRCallout.sendDocumentToOCR(srIds);
    }
}