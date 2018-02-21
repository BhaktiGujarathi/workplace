public with sharing class GenerateOfferAcceptanceLetterController 
{

  public Id caseId;
  public Case objCase {get;set;}
  public String strURL {get;set;}

  public List<SR_Booking_Unit__c> lstSRBookingUnit;
  public List<AOPTServiceRequestControllerLDS.SelectedNewPaymentTermsByCRE> lstSelectedNewPaymentTermsByCRE;

  public Boolean blnIsOfferLetterGenerated {get;set;}

  public Attachment objAttahment = new Attachment();
  public SR_Attachments__c spaAttachment = new SR_Attachments__c();

  //constructor
  public GenerateOfferAcceptanceLetterController(ApexPages.StandardController controller) 
  {
    lstSRBookingUnit= new List<SR_Booking_Unit__c>();
    lstSelectedNewPaymentTermsByCRE = new List<AOPTServiceRequestControllerLDS.SelectedNewPaymentTermsByCRE>();
    caseId = ApexPages.currentPage().getParameters().get('id');
    //generateOfferAcceptanceLetter();
    blnIsOfferLetterGenerated = false;
  }

  public PageReference generateOfferAcceptanceLetter()
    {
        if(String.isNotBlank(caseId))
        {
            //try
            //{
                objCase = [ select Id,Account.Name,Account.Address_Line_1__c,Account.Address_Line_2__c
                            ,Account.Address_Line_3__c,Account.Country__c
                            ,Account.City__c,Account.State__c,Account.Zip_Postal_Code__c
                            ,Approval_Status__c,Status,NewPaymentTermJSON__c
                            from Case where Id =: caseId];

                List<SR_Attachments__c> lstSRAttachmentCase = [Select id from SR_Attachments__c where Case__c = :caseId and Type__c = 'Offer & Acceptance Letter'];

                if((lstSRAttachmentCase != null && lstSRAttachmentCase.size() > 0))
                {
                    blnIsOfferLetterGenerated = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error :Offer & Acceptance Letter Already generated for this SR. You cannot generate it again. Please delete old one and generate it again'));
                    return null;
                }
                if(objCase != null)
                {
                    if(String.isNotBlank( objCase.NewPaymentTermJSON__c ))
                    {
                        lstSelectedNewPaymentTermsByCRE = (List<AOPTServiceRequestControllerLDS.SelectedNewPaymentTermsByCRE>)JSON.deserialize(objCase.NewPaymentTermJSON__c,List<AOPTServiceRequestControllerLDS.SelectedNewPaymentTermsByCRE>.class);
                    }
                    
                    lstSRBookingUnit = [Select Property_Name__c,Unit__c,Agreement_Date__c from SR_Booking_Unit__c where Case__c =:caseId];
                
                    // make callout to IPMS for generating offer & acceptance letter
                    
                    AOPTDocumentGenerationUtilComXsd.AttributeArrForAll[] attribute2 = new AOPTDocumentGenerationUtilComXsd.AttributeArrForAll[lstSelectedNewPaymentTermsByCRE.size()];
                    for(Integer j=0;j < lstSelectedNewPaymentTermsByCRE.size(); j++)
                    {
                        AOPTDocumentGenerationUtilComXsd.AttributeArrForAll objAttr2 = new AOPTDocumentGenerationUtilComXsd.AttributeArrForAll();
                        objAttr2.attribute1 = lstSelectedNewPaymentTermsByCRE[j].installment;
                        objAttr2.attribute2 = lstSelectedNewPaymentTermsByCRE[j].mileStoneEvent;
                        objAttr2.attribute3 = lstSelectedNewPaymentTermsByCRE[j].paymentDate;
                        objAttr2.attribute4 = lstSelectedNewPaymentTermsByCRE[j].percentValue;
                        objAttr2.attribute5 = '';
                        objAttr2.attribute6 = '';
                        objAttr2.attribute7 = '';
                        objAttr2.attribute8 = '';
                        objAttr2.attribute9 = '';
                        objAttr2.attribute10 = '';
                        objAttr2.attribute11 = '';
                        objAttr2.attribute12 = '';
                        objAttr2.attribute13 = '';
                        objAttr2.attribute14 = '';
                        objAttr2.attribute15 = '';
                        objAttr2.attribute16 = '';
                        objAttr2.attribute17 = '';
                        objAttr2.attribute18 = '';
                        objAttr2.attribute19 = '';
                        objAttr2.attribute20 = '';

                        attribute2[j] = objAttr2;
                    }

                    AOPTDocumentGenerationUtilComXsd.AttributeArr1 [] paymentTermsAttr = new AOPTDocumentGenerationUtilComXsd.AttributeArr1[lstSRBookingUnit.size()];
                    for(Integer i=0;i < lstSRBookingUnit.size(); i++)
                    {
                        AOPTDocumentGenerationUtilComXsd.AttributeArr1 objPaymentAttr = new AOPTDocumentGenerationUtilComXsd.AttributeArr1();
                        objPaymentAttr.attribute1 = lstSRBookingUnit[i].Unit__c;
                        objPaymentAttr.attribute2 = attribute2;
                        paymentTermsAttr[i] = objPaymentAttr;
                    }


                    AOPTDocumentGenerationXsd.DocGenDTO objDocAttribute = new AOPTDocumentGenerationXsd.DocGenDTO();
                    objDocAttribute.Attribute1 = String.valueOf(Date.today());
                    objDocAttribute.Attribute2 = objCase.Account.Name;
                    objDocAttribute.Attribute3 = 'Executive Heights, Barsha Heights, Dubai, UAE';
                    objDocAttribute.Attribute4 = 'P.O.Box: 2195, Phone: 971.4.3731000';
                    objDocAttribute.Attribute5 = 'Subject: Payment Plan Revision';
                    objDocAttribute.Attribute6 = lstSRBookingUnit[0].Property_Name__c;
                    objDocAttribute.Attribute7 = String.valueOf(Date.today());
                    objDocAttribute.Attribute8 = objCase.Account.Name;
                    objDocAttribute.Attribute9 = '';
                    objDocAttribute.Attribute10 = '';
                    objDocAttribute.Attribute11 = '';
                    objDocAttribute.Attribute12 = '';
                    objDocAttribute.Attribute13 = '';
                    objDocAttribute.Attribute14 = '';
                    objDocAttribute.Attribute15 = '';
                    objDocAttribute.Attribute16 = '';
                    objDocAttribute.Attribute17 = '';
                    objDocAttribute.Attribute18 = '';
                    objDocAttribute.Attribute19 = '';
                    objDocAttribute.Attribute20 = '';
                    objDocAttribute.Attribute21 = '';
                    objDocAttribute.Attribute22 = '';
                    objDocAttribute.Attribute22 = '';
                    objDocAttribute.Attribute23 = '';
                    objDocAttribute.Attribute24 = '';
                    objDocAttribute.Attribute25 = '';
                    objDocAttribute.Attribute26 = '';
                    objDocAttribute.Attribute27 = '';
                    objDocAttribute.Attribute28 = '';
                    objDocAttribute.Attribute29 = '';
                    objDocAttribute.Attribute30 = '';
                    objDocAttribute.Attribute31 = '';
                    objDocAttribute.Attribute32 = '';
                    objDocAttribute.Attribute33 = '';
                    objDocAttribute.Attribute34 = '';
                    objDocAttribute.Attribute35 = '';
                    objDocAttribute.Attribute36 = '';
                    objDocAttribute.Attribute37 = '';
                    objDocAttribute.Attribute38 = '';
                    objDocAttribute.Attribute39 = '';
                    objDocAttribute.Attribute40 = '';
                    objDocAttribute.Attribute41 = '';
                    objDocAttribute.Attribute42 = '';
                    objDocAttribute.Attribute43 = '';
                    objDocAttribute.Attribute44 = '';
                    objDocAttribute.Attribute45 = '';
                    objDocAttribute.Attribute46 = '';
                    objDocAttribute.Attribute47 = '';
                    objDocAttribute.Attribute48 = '';
                    objDocAttribute.Attribute49 = '';
                    objDocAttribute.Attribute50 = '';
                    objDocAttribute.Attribute51 = '';
                    objDocAttribute.Attribute52 = '';
                    objDocAttribute.Attribute53 = '';
                    objDocAttribute.Attribute54 = '';
                    objDocAttribute.Attribute55 = '';
                    objDocAttribute.Attribute56 = '';
                    objDocAttribute.Attribute57 = '';
                    objDocAttribute.Attribute58 = '';
                    objDocAttribute.Attribute59 = '';
                    objDocAttribute.Attribute60 = '';
                    objDocAttribute.Attribute61 = '';
                    objDocAttribute.Attribute62 = '';
                    objDocAttribute.Attribute63 = '';
                    objDocAttribute.Attribute64 = '';
                    objDocAttribute.Attribute65 = '';
                    objDocAttribute.Attribute66 = '';
                    objDocAttribute.Attribute67 = '';
                    objDocAttribute.Attribute68 = '';
                    objDocAttribute.Attribute69 = '';
                    objDocAttribute.Attribute70 = '';
                    objDocAttribute.Attribute71 = '';
                    objDocAttribute.Attribute72 = '';
                    objDocAttribute.Attribute73 = '';
                    objDocAttribute.Attribute74 = '';
                    objDocAttribute.Attribute75 = '';
                    objDocAttribute.Attribute76 = '';
                    objDocAttribute.Attribute77 = '';
                    objDocAttribute.Attribute78 = '';
                    objDocAttribute.Attribute79 = '';
                    objDocAttribute.Attribute80 = '';
                    objDocAttribute.Attribute81 = '';
                    objDocAttribute.Attribute82 = '';
                    objDocAttribute.Attribute83 = '';
                    objDocAttribute.Attribute84 = '';
                    objDocAttribute.Attribute85 = '';
                    objDocAttribute.Attribute86 = '';
                    objDocAttribute.Attribute87 = '';
                    objDocAttribute.Attribute88 = '';
                    objDocAttribute.Attribute89 = '';
                    objDocAttribute.Attribute90 = '';
                    objDocAttribute.Attribute91 = '';
                    objDocAttribute.Attribute92 = '';
                    objDocAttribute.Attribute93 = '';
                    objDocAttribute.Attribute94 = '';
                    objDocAttribute.Attribute95 = '';
                    objDocAttribute.Attribute96 = '';
                    objDocAttribute.Attribute97 = '';
                    objDocAttribute.Attribute99 = '';
                    objDocAttribute.Attribute100 = '';


                    objDocAttribute.ATTRIBUTEARR1 = paymentTermsAttr;

                    
                    system.debug('objDocAttribute '+objDocAttribute.ATTRIBUTEARR1);

                   strURL =  AOPTMQService.generateOfferAccetanceLetter(objDocAttribute);
                   system.debug('strResponse URL '+strURL);
                   insertRecords();
                }
            //}
            //catch(Exception exp)
            //{
            //    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error generating document :'+exp.getMessage()));
            //}
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Case ID not present for generating Offer & Acceptance Letter'));
        }
        return null;
    }

    public PageReference insertRecords()
    {
        try
        {   
            if( objCase.Status != null  && objCase.Status != 'Submitted' &&  objCase.Status != 'Approved' )
            {   
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error :You cannot generate Offer & Acceptance Letter now as SR is not submitted.'));
                return null;
            }

            if( objCase.Approval_Status__c != null && objCase.Approval_Status__c != 'Approved')
            {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error :You cannot generate Offer & Acceptance Letter now as approval is pending.'));
               return null; 
            }
                
            spaAttachment.Name = 'Offer & Acceptance Letter';
            spaAttachment.isValid__c = false;
            spaAttachment.Type__c = 'Offer & Acceptance Letter';
            spaAttachment.IsRequired__c = true;
            spaAttachment.Case__c = caseId;
            spaAttachment.Attachment_URL__c = strURL;
            insert spaAttachment;

            /*PageReference pdfPage = Page.GenerateOfferAcceptancePage;
            Blob pdfContent = pdfPage.getContentAsPDF();

            objAttahment.Name = spaAttachment.name +'.pdf';
            objAttahment.Body = pdfContent ;
            objAttahment.ContentType = 'application/pdf';
            objAttahment.ParentId = spaAttachment.id;
            insert objAttahment;
            */
            objCase.Offer_Acceptance_Letter_Generated__c = true;
            update objCase;

            // send email to customer with offer letter
            sendEmailFunction(objCase.Id);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Offer & Acceptance Letter Generated & email sent to customer.'));
            PageReference  pg = new PageReference ('/'+caseId);
            pg.setRedirect(true);
            return pg;
        }
        catch(Exception exp)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error inserting document :'+exp.getMessage()));
            return null;
        }
    }

    private void sendEmailFunction(Id caseId)
    {
        system.debug('method called');
        
        system.debug('caseId '+caseId);
        Case getEmail = [SELECT Id, Account.PersonEmail  FROM Case WHERE id=:caseId];
        if(getEmail.Account.PersonEmail  != null) 
        {
            String toaddress = getEmail.Account.PersonEmail ;
            try 
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {toaddress};
                String[] ccAddresses = new String[] {'hardikmehta9720@gmail.com'};
                mail.setToAddresses(toAddresses);
                mail.setCcAddresses(ccAddresses);
                mail.setReplyTo(toaddress);
                mail.setSenderDisplayName('Name');
                mail.setSubject('Offer & Acceptance Letter');
                mail.setBccSender(false);
                mail.setUseSignature(true);
                //mail.setPlainTextBody('Please find the attached Offer & Acceptance Letter for your AOPT SR. <br /> '+strURL);
                mail.setHtmlBody('Please find the attached Offer & Acceptance Letter for your AOPT SR. <br /> '+strURL);

                /*SR_Attachments__c objSRAttachment = [Select Id from SR_Attachments__c where Case__c =:caseId and Type__c='Offer & Acceptance Letter'];
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :objSRAttachment.Id])
                {
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(a.Name);
                    efa.setBody(a.Body);
                    fileAttachments.add(efa);
                    //mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                }
                if(fileAttachments != null && fileAttachments.size() > 0)
                {
                    mail.setFileAttachments(fileAttachments);
                }
                */
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                system.debug('email sent success');
            }catch(Exception e)
            {
                system.debug('Email not sent '+e.getMessage());
            }
        }
        else
        {
            system.debug('account email is empty');
        }
    }


}