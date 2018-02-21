global class AOPTServiceRequestHandler 
{
    @InvocableMethod
    public static void applyNewPaymentTerms(List<Case> lstSR)
    {

        system.debug('method called');
        String caseId;
        if(lstSR != null && lstSR.size() > 0)
        {
            Case objCase = lstSR.get(0);
            caseId = objCase.Id;
        }
        
        if(String.isNotBlank(caseId))
        {
            makeCallout(caseId);
        }
    }

    // method to create new PT in IPMS and if it is successfull then create same in SF.
    // using future method as uncommited work pending error was coming
    @future(callout=true)
    private static void makeCallout(String strCaseID)
    {
        paymentPlanCreationXxdcAoptPkgWsP.APPSXXDC_AOPT_PKG_WSX1843128X6X5 [] lstPaymentTermInIPMS ;
        Case objCase = [SELECT Id, NewPaymentTermJSON__c,CaseNumber,Payment_Terms_Error__c  FROM Case WHERE ID =: strCaseID];
        if(objCase != null && String.isNotBlank(objCase.NewPaymentTermJSON__c))
        {
            List<AOPTServiceRequestControllerLDS.SelectedNewPaymentTermsByCRE>lstSelectedNewPaymentTermsByCRE 
            = (List<AOPTServiceRequestControllerLDS.SelectedNewPaymentTermsByCRE>)JSON.deserialize(objCase.NewPaymentTermJSON__c,List<AOPTServiceRequestControllerLDS.SelectedNewPaymentTermsByCRE>.class);

            lstPaymentTermInIPMS  = new paymentPlanCreationXxdcAoptPkgWsP.APPSXXDC_AOPT_PKG_WSX1843128X6X5[lstSelectedNewPaymentTermsByCRE.size()];
            
            Set<Id> bookingUnitIDSet = new Set<Id>();
            List<String> lstRegIds = new List<String>();

            Integer index = 0;
            for(SR_Booking_Unit__c objSRBU : [select Id,Booking_Unit__c,Registration_ID__c from SR_Booking_Unit__c where Case__c =: strCaseID])
            {   
                lstRegIds.add(objSRBU.Registration_ID__c);
                bookingUnitIDSet.add(objSRBU.Booking_Unit__c);

                for(AOPTServiceRequestControllerLDS.SelectedNewPaymentTermsByCRE objSelectedPT : lstSelectedNewPaymentTermsByCRE)
                {
                    paymentPlanCreationXxdcAoptPkgWsP.APPSXXDC_AOPT_PKG_WSX1843128X6X5 objIPMSPT = new paymentPlanCreationXxdcAoptPkgWsP.APPSXXDC_AOPT_PKG_WSX1843128X6X5();
                    
                    objIPMSPT.DESCRIPTION = objSelectedPT.description;
                    
                    if(objSelectedPT.blnNewTerm != null && objSelectedPT.blnNewTerm)
                    {
                        objIPMSPT.EXPECTED_DATE = formatDate((objSelectedPT.paymentDate));
                        objIPMSPT.LINE_ID = objSelectedPT.strLineID;
                        objIPMSPT.TERM_ID = objSelectedPT.strTermID;
                    }
                    else
                    {
                        objIPMSPT.EXPECTED_DATE = objSelectedPT.paymentDate;
                    }
                    objIPMSPT.INSTALLMENT = objSelectedPT.installment;
                    
                    objIPMSPT.MILESTONE_EVENT = objSelectedPT.mileStoneEvent;
                    objIPMSPT.PERCENT_VALUE = objSelectedPT.percentValue;
                    objIPMSPT.REGISTRATION_ID = objSelectedPT.strRegID;
                    
                    if(objSelectedPT.blnNewTerm != null && objSelectedPT.blnNewTerm)
                    {
                        objIPMSPT.TRANSFER_AR_INTER_FLAG = 'N';// for new PT pass value as N
                    }
                    else
                    {
                        objIPMSPT.TRANSFER_AR_INTER_FLAG = 'Y';// for existing PT pass value as Y
                    }
                    
                    lstPaymentTermInIPMS[ index ] = objIPMSPT;
                    index++;
                }
                
                
            }
            system.debug('lstPaymentTermInIPMS '+lstPaymentTermInIPMS);
            String strResponse = AOPTMQService.createPaymentPlanIPMS(lstRegIds.get(0),objCase.CaseNumber,'AMENDMENT_OF_PAYMENT_TERMS',lstPaymentTermInIPMS);
            system.debug('strResponse '+strResponse);
            if(String.isNotBlank(strResponse))
            {
                Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(strResponse);
                List<Payment_Plan__c> lstPaymentPlan = new List<Payment_Plan__c>();
                List<Payment_Terms__c> lstApplyNewPaymentTerms = new List<Payment_Terms__c>();

                if(mapResponse.get('message')!= null && mapResponse.get('status') != null)
                {
                    if(((String)mapResponse.get('status')).equalsIgnoreCase('S'))
                    {
                        for(Payment_Plan__c objPaymentPlan : [SELECT Id,Booking_Unit__c,Status__c FROM Payment_Plan__c WHERE Booking_Unit__c IN :bookingUnitIDSet AND Status__c = 'Active'])
                        {   
                            // add new Payment Plans for selected booking units in set bookingUnitIDSet
                            Payment_Plan__c objPaymentPlanCreate = new Payment_Plan__c();
                            objPaymentPlanCreate.Booking_Unit__c = objPaymentPlan.Booking_Unit__c;
                            objPaymentPlanCreate.Parent_Payment_Plan__c = objPaymentPlan.Id;
                            objPaymentPlanCreate.Status__c = 'Active';

                            lstPaymentPlan.add(objPaymentPlanCreate);

                            // update old Payment plan status to Inactive
                            Payment_Plan__c objPaymentPlanUpdate = new Payment_Plan__c(Id = objPaymentPlan.Id);
                            objPaymentPlanUpdate.Status__c = 'InActive';
                            lstPaymentPlan.add(objPaymentPlanUpdate);
                        }

                        if(lstPaymentPlan != null && lstPaymentPlan.size()>0)
                        {   
                            system.debug('lstPaymentPlan '+lstPaymentPlan);
                            try
                            {
                                upsert lstPaymentPlan;
                                system.debug('lstPaymentPlan upsert '+lstPaymentPlan);
                                for(Payment_Plan__c objInsertedPaymentPlan : lstPaymentPlan)
                                {
                                    for( paymentPlanCreationXxdcAoptPkgWsP.APPSXXDC_AOPT_PKG_WSX1843128X6X5 objSelectedNewPT : lstPaymentTermInIPMS )
                                    {
                                        Payment_Terms__c objNewPT = new Payment_Terms__c();
                                        objNewPT.Installment__c = objSelectedNewPT.INSTALLMENT;
                                        objNewPT.Description__c = objSelectedNewPT.DESCRIPTION ;
                                        objNewPT.Percent_Value__c = objSelectedNewPT.PERCENT_VALUE ;
                                        objNewPT.Milestone_Event__c = objSelectedNewPT.MILESTONE_EVENT ;
                                        objNewPT.Payment_Plan__c = objInsertedPaymentPlan.Id;
                                        lstApplyNewPaymentTerms.add(objNewPT);
                                    }
                                }

                                if(lstApplyNewPaymentTerms != null && lstApplyNewPaymentTerms.size() > 0)
                                {
                                    insert lstApplyNewPaymentTerms;
                                }
                                //sendEmail('Payment Plan & Terms Applied success');
                            }
                            catch(Exception exp)
                            {   
                                //sendEmail('Error '+exp.getStackTraceString());
                                throw exp;
                            }
                            //update objCase;
                        }
                    }
                    else
                    {   
                        system.debug('error in response');
                        //sendEmail('Callout Response '+strResponse);
                    }
                }
            }
        }
    }

    // method used to format date to dd-MMM-YYYY (11-Oct-2017)
    private static String formatDate(String dt)
    {   
        Date objDateToFormat = Date.parse(dt);
        String strFormatedDate = DateTime.newInstance(objDateToFormat.year(),objDateToFormat.month(),objDateToFormat.day()).format('d-MMM-YYYY');
        system.debug('strFormatedDate '+strFormatedDate);
        return strFormatedDate;
    }

    private static void sendEmail(String strBody)
    {   
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();  
      // Step 1: Create a new Email
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
      // Step 2: Set list of people who should get the email
      List<String> sendTo = new List<String>();
      sendTo.add('hardikmehta9720@gmail.com');
      mail.setToAddresses(sendTo);
    
      // Step 3: Set who the email is sent from
      mail.setSenderDisplayName('IPMS Payment Terms Status');

      // Step 4. Set email contents - you can use variables!
      mail.setSubject('IPMS Payment Terms Status');
      String body = strBody;
      mail.setPlainTextBody(body);
    
      // Step 5. Add your email to the master list
      mails.add(mail);
      // Step 6: Send all emails in the master list
      Messaging.sendEmail(mails);
    }

}