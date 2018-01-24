/**
 *  Verison             Author                      Date(dd/mm/yyyy)        Description
 *  1.0                 Ajinkya H.                  03/02/2016              Initial Draft
 *  1.1                 Ajinkya H.                  19/04/2017              Changes for FO-1720
 */
public with sharing class EmailConfig {

    public String toRecipient;
    public String additionalToRecipient;
    public String ccRecipient;
    public String frmAddress;
    public String errorMsg;
    public String fromAddressErrCheck;
    public Boolean isConfirmMsg = false;

    /**
    * Return error message if custom setting data is not configured properly or no org wide address
    * set in Custom setting
    */
    public String fetchOrgWideEmail(FO_Email_Settings__c recipientCfg) {
        String fromAddressCheck, //fromAddressErrCheck ='',
        cstmStngFromAddress = (recipientCfg.From_Address__c).toLowerCase();
        
        // Check if custom setting has From address set to user
        if(cstmStngFromAddress == 'User') {
            frmAddress = 'User';
            return '';
        }
        
        Map<String, String> orgWideEmail = new Map<String, String>();
        List<OrgWideEmailAddress> fetchOrgWideEmailAddressData = [SELECT Address
                                                                       , DisplayName
                                                                    FROM OrgWideEmailAddress];
        
        for(OrgWideEmailAddress orgWideData : fetchOrgWideEmailAddressData) {
            orgWideEmail.put(orgWideData.Address, orgWideData.DisplayName);
        }
        
        if(orgWideEmail.containsKey(cstmStngFromAddress)) {
            fromAddressCheck = '\"'+orgWideEmail.get(cstmStngFromAddress)+'\"'
                +' <'+cstmStngFromAddress+'>';
            frmAddress = fromAddressCheck;
            return '';
        }
        if(orgWideEmail.get(cstmStngFromAddress) == null || 
            cstmStngFromAddress != 'User') {
            fromAddressErrCheck = 'The org wide email address is not setup for the selected user. '+
            ' Would you like to send the email using your email address?';
            isConfirmMsg = true;
            frmAddress = 'User';
        } else {
            frmAddress = fromAddressCheck;
        }
        return fromAddressErrCheck;
    }


    /**
     * To validate all error data while sending mails
     */
    public String validateData(FO_Email_Settings__c recipientCfg, Opportunity opportunity) {

        if(!recipientCfg.Merchant__c && !recipientCfg.ISO__c && !recipientCfg.ISO_Sales_Rep__c) {
            errorMsg = system.Label.GRIDEmail_Custom_Setting_Config_Msg;
            return errorMsg;
        }
        Schema.SObjectField field;
        Schema.DisplayType fldType;
        Map<String, Schema.SObjectField> schemaOppFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        if(schemaOppFieldMap.containsKey(recipientCfg.Reply_to_Address__c)) {
            field = schemaOppFieldMap.get(recipientCfg.Reply_to_Address__c);
            fldType = field.getDescribe().getType();
            if(fldType <> schema.DisplayType.STRING && fldType <> schema.DisplayType.EMAIL) {
                errorMsg = 'Custom Setting FO_Email_Default_Receipients Reply_To_Address'
                        +' should consist of Email or Text type of field.'
                        +' Please contact your administrator.';
                return errorMsg;
            }
        } else if(recipientCfg.Reply_to_Address__c != null ){
            errorMsg = 'Custom Setting FO_Email_Default_Receipients Reply-To-Address has not been configured correctly.'
                        +' Please contact your administrator.';
            return errorMsg;
        }

        if(schemaOppFieldMap.containsKey(recipientCfg.Sender_s_Name__c  )) {
            field = schemaOppFieldMap.get(recipientCfg.Sender_s_Name__c );
            fldType = field.getDescribe().getType();
            if(fldType <> schema.DisplayType.STRING ) {
                errorMsg = 'Custom Setting FO_Email_Default_Receipients Sender-s-Name'
                        +' should consist of Text type of field.'
                        +' Please contact your administrator.';
                return errorMsg;
            }
        } else if(recipientCfg.Sender_s_Name__c  != null ){
            errorMsg = 'Custom Setting FO_Email_Default_Receipients Sender-s-Name has not been configured correctly.'
                        +' Please contact your administrator.';
            return errorMsg;
        }
        
        fetchOrgWideEmail(recipientCfg);
        Integer expectedCount = 0;
        Integer errorCount = 0;

        // Map of custom setting field and Opportunity field
        Map<String, String> customOppFieldMap = new Map<String, String>{
            'Merchant__c' =>'Owner_1__c',
            'ISO__c' =>'ISO__c',
            'ISO_Sales_Rep__c'=>'ISO_Sales_Rep__c'
        };

        // Map of custom setting field and Opportunity Email field
        Map<String, String> customOppEmailMap = new Map<String, String>{
            'Merchant__c' =>'Owner_1__r.Email',
            'ISO__c' =>'ISO__r.Email__c',
            'ISO_Sales_Rep__c'=>'ISO_Sales_Rep__r.Email'
        };

        //Map<String,Boolean> fieldBooleanMap = new Map<String,Boolean>();
        Set<String> blankEmailFields = new Set<String>();
        Set<String> emailFields = new Set<String>();

        for(String fieldName : customOppFieldMap.keySet()) {
            if((Boolean)recipientCfg.get(fieldName)) {
                expectedCount +=1;
                if (String.isBlank(String.ValueOf(opportunity.get(customOppFieldMap.get(fieldName))))) {
                    if(fieldName.contains('Merchant')) {
                        blankEmailFields.add('Owner 1');
                    } else {
                        blankEmailFields.add(fieldName.substringBeforeLast('__').replace('_', ' '));
                    }
                    errorCount += 1;
                    //fieldBooleanMap.put(fieldName.substringBeforeLast('__'),false);
                } else if(String.isNotBlank(String.ValueOf(opportunity.get(customOppFieldMap.get(fieldName)))) &&
                    String.isBlank(String.ValueOf(opportunity.getSobject(customOppEmailMap.get(fieldName).substringBeforeLast('.')).
                        get(customOppEmailMap.get(fieldName).substringAfterLast('.'))))){
                    if(fieldName.contains('Merchant')) {
                        blankEmailFields.add('Owner 1');
                    } else {
                        blankEmailFields.add(fieldName.substringBeforeLast('__').replace('_', ' '));
                    }
                    errorCount += 1;
                } else {
                    if(fieldName.contains('Merchant')) {
                        emailFields.add('Owner 1');
                    } else {
                        emailFields.add(fieldName.substringBeforeLast('__').replace('_', ' '));
                    }
                }
            }
        }
        if(expectedCount == errorCount) {
            isConfirmMsg = false;
            errorMsg = 'Email of '
                + String.ValueOf(blankEmailFields).removeStart('{').removeEnd('}')
                +' has not been set. Please go back and correct.';
        } else if((expectedCount-1) == errorCount) {
            if(expectedCount == 2) {
                isConfirmMsg = true;
                errorMsg = 'Email of '
                + String.ValueOf(blankEmailFields).removeStart('{').removeEnd('}')
                +' has not been set. Would you like to send an email to the '
                + String.ValueOf(emailFields).removeStart('{').removeEnd('}')
                + ' only?';
          } else if(errorCount != 0){
                isConfirmMsg = true;
                errorMsg = 'Email of '
                + String.ValueOf(blankEmailFields).removeStart('{').removeEnd('}')
                +' has not been set. Would you like to send an email to the '
                + String.ValueOf(emailFields).removeStart('{').removeEnd('}')
                + '?';
            }
        } else if(expectedCount == 3 && (expectedCount-2) == errorCount) {
            isConfirmMsg = true;
            errorMsg = 'Email of '
            + String.ValueOf(blankEmailFields).removeStart('{').removeEnd('}')
            +' has not been set. Would you like to send an email to the '
            + String.ValueOf(emailFields).removeStart('{').removeEnd('}')
            + '?';
        }

        if(String.isBlank(errorMsg)) {
            errorMsg = system.Label.GRIDConfirm_Message_For_Email_Stips_And_Offers;
            isConfirmMsg = true;
        }
        return errorMsg;
    }

    /**
     * Method to populate Email configuration object with sender and recipient
     */
    public String populateData(FO_Email_Settings__c recipientCfg, Opportunity opportunity) {
        if(!recipientCfg.Merchant__c && !recipientCfg.ISO__c && !recipientCfg.ISO_Sales_Rep__c) {
            return null;
        }
        Set<String> mailReceipientList = new Set<String>();
        // To store Email of merchant, ISO and ISO Sales Rep
        String merchantEmail = opportunity.Owner_1__r.Email;
        String isoEmail = opportunity.ISO__r.Email__c;
        String isoSalesRepEmail = opportunity.ISO_Sales_Rep__r.Email;
        
        // To Store Id of Merchant, ISO, ISO Sales Rep
        String merchantID = opportunity.Owner_1__c;
        String isoID = opportunity.ISO__c;
        String isoSalesRepID = opportunity.ISO_Sales_Rep__c;
        String replyTo, sender, cstmStngFromAddress;
        if(recipientCfg.Reply_to_Address__c != null) {
            replyTo = (recipientCfg.Reply_to_Address__c).toLowerCase();
        }
        if(recipientCfg.Sender_s_Name__c != null) {
            sender = (recipientCfg.Sender_s_Name__c).toLowerCase();
        }
        if(recipientCfg.From_Address__c != null) {
            cstmStngFromAddress = (recipientCfg.From_Address__c).toLowerCase();
        }
        
        String replyToAddress, senderName;
        Map<String, Schema.SObjectField> schemaOppFieldMap = Schema.SObjectType.Opportunity.fields.getMap();

        if(schemaOppFieldMap.containsKey(replyTo) || schemaOppFieldMap.containsKey('mcaapp__'+replyTo)) {
            replyToAddress = Opportunity.get(replyTo) != null ?
                            (String)Opportunity.get(replyTo) : '';
        }

        if(schemaOppFieldMap.containsKey(sender) || schemaOppFieldMap.containsKey('mcaapp__'+sender)) {
            senderName = Opportunity.get(sender) != null ?
                        (String)Opportunity.get(sender) : '';
        }

        if(recipientCfg.Merchant__c && (recipientCfg.ISO__c || recipientCfg.ISO_Sales_Rep__c)) {
            // If the Merchant and the ISO and/or ISO Sales Rep are checked,
            // make the Merchant the To: recipient and the ISO and/or ISO Sales Rep the CC: recipient
            this.toRecipient = (merchantEmail!= null && opportunity.Owner_1__c!= null)
                                    ? (String)opportunity.Owner_1__c : '';
            this.additionalToRecipient = recipientCfg.ISO__c && String.isNotBlank(isoEmail) &&
            (recipientCfg.ISO_Sales_Rep__c || recipientCfg.Merchant__c) ? isoEmail : '';

            this.ccRecipient = recipientCfg.ISO__c && String.isNotBlank(isoEmail) &&
            (!recipientCfg.ISO_Sales_Rep__c &&  !recipientCfg.Merchant__c) ? isoEmail : '';

            if(recipientCfg.ISO_Sales_Rep__c && String.isNotBlank(isoSalesRepEmail) ) {
                this.ccRecipient += this.ccRecipient
                    + (String.isBlank(this.ccRecipient) ? isoSalesRepEmail : ', '+isoSalesRepEmail);
            }
            if(recipientCfg.ISO_Sales_Rep__c && String.isNotBlank(isoSalesRepEmail) &&
            merchantEmail == null && isoEmail == null) {
                this.additionalToRecipient += this.additionalToRecipient
                    + (String.isBlank(this.additionalToRecipient) ? isoSalesRepEmail : ', '+isoSalesRepEmail);
                this.ccRecipient = '';
            }
        }
        else if(!recipientCfg.Merchant__c && recipientCfg.ISO__c && recipientCfg.ISO_Sales_Rep__c) {
            // If the ISO and ISO Sales Rep are checked,
            // make the ISO the To: receipient and ISO Sales Rep CC: recipient
            this.additionalToRecipient = isoEmail;
            this.ccRecipient = isoSalesRepEmail;
        }
        else if(recipientCfg.Merchant__c && !recipientCfg.ISO__c && !recipientCfg.ISO_Sales_Rep__c) {
            this.toRecipient = opportunity.Owner_1__c;
        }
        else if(!recipientCfg.Merchant__c && recipientCfg.ISO__c && !recipientCfg.ISO_Sales_Rep__c) {
            this.additionalToRecipient = isoEmail;
        }
        else if(!recipientCfg.Merchant__c && !recipientCfg.ISO__c && recipientCfg.ISO_Sales_Rep__c) {
            this.toRecipient = opportunity.ISO_Sales_Rep__c;
        }

        String templateId;
        if(recipientCfg.Name == 'Email Offers') {
            templateId = system.Label.GRIDEmailOfferTemplateId;
        } else if(recipientCfg.Name == 'Email Stips') {
            templateId = system.Label.GRIDEmailStipsTemplateId;
        }

        String message = '';
        Savepoint sp = Database.setSavepoint();
        try {
            sendEmail(toRecipient, additionalToRecipient, ccRecipient,
                        opportunity.Id, templateId, replyToAddress, 
                        senderName);

            // Collect all receipient names
            if(recipientCfg.Merchant__c && String.isNotBlank(merchantID)
                && String.isNotBlank(merchantEmail))
                mailReceipientList.add(merchantEmail);
            if(recipientCfg.ISO__c && String.isNotBlank(isoID)
                && String.isNotBlank(isoEmail))
                mailReceipientList.add(isoEmail);
            if(recipientCfg.ISO_Sales_Rep__c && String.isNotBlank(isosalesrepID)
                && String.isNotBlank(isoSalesRepEmail))
                mailReceipientList.add(isoSalesRepEmail);
            message = JSON.serialize(mailReceipientList);
        } catch(Exception ex) {
            message = ex.getMessage();
            Database.rollback(sp);
        }
        return message;
    }

    /**
     * Send email using given parameters
     *
     * @param toRecipient             Id of the record to be set as target object on email
     * @param additionalToRecipient   Email address for to field of email
     * @param ccRecipient             Email address for cc field of email
     * @param oppId                   Id of Opportunity to be set for WhatId
     * @param templateId              Template's Id
     */
    private void sendEmail(String toRecipient, String additionalToRecipient, String ccRecipient,
                            Id oppId, String templateId, String replyToAddress, String senderName) {
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();

        if(String.isNotBlank(additionalToRecipient)) {
            emailMessage.setToAddresses(new List<String>{additionalToRecipient});
        }
        if(String.isNotBlank(ccRecipient)) {
            emailMessage.setCcAddresses(new List<String>{ccRecipient});
        }
        if(String.isNotBlank(replyToAddress)) {
            emailMessage.setReplyTo(replyToAddress);
        }
        if(String.isNotBlank(senderName)) {
            emailMessage.setSenderDisplayName(senderName);
        }
        
        emailMessage.saveAsActivity = false;
        if(String.isNotBlank(toRecipient)) {
            emailMessage.setTargetObjectId(toRecipient);
        } else  {
            emailMessage.setTargetObjectId(UserInfo.getUserId());
            emailMessage.setTreatTargetObjectAsRecipient(false);
         }
        emailMessage.setSaveAsActivity(true);
        emailMessage.setTemplateId(templateId);
        emailMessage.setWhatId(oppId);
        Messaging.sendEmail(
            new List<Messaging.SingleEmailMessage>{ emailMessage }
            
        );
    }
}