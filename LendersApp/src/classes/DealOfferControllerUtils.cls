public with sharing class DealOfferControllerUtils {

    //Email
    public String header {get;set;}
    public String footer {get;set;}
    public String subject {get;set;}
    public String to {get;set;}
    public String cc {get;set;}
    public String bcc {get;set;}

    //Fields
    public String recipientName {get;set;}
    public String emailCCAddress {get;set;}
    public String emailBCCAddress {get;set;}
    public String emailSubject {get;set;}
    public String ownerName {get;set;}
    public String Owner1Email {get;set;}
    public String isoSalesRepEmail {get;set;}
    public String owner2Email {get;set;}

    //Utility
    Offer_Email_Detail__c emailDetail {get;set;}
    Opportunity opp {get;set;}
    Map<String, String> keywords = new Map<String, String>();


	public DealOfferControllerUtils(Offer_Email_Detail__c emailDetail, Opportunity opp) {

		system.debug('333333333333' + emailDetail);
        this.emailDetail = emailDetail;
        this.opp = opp;
        loadKeywordsValues();
        replaceKeywords();
    }



    private void loadKeywordsValues() {

        if (opp != null) {

            //Opportunity o = [SELECT Id, Owner.Name, McaApp__Owner_1__c, McaApp__Owner_1__r.Email FROM Opportunity WHERE Id = :opp.Id];
            //Get Owner Name
            ownerName = opp.Owner.Name;
            
            //Get Recipient's Name
            if (opp.McaApp__Sales_Rep__c != null && opp.McaApp__Sales_Rep__r.FirstName != null) {

                recipientName = opp.McaApp__Sales_Rep__r.FirstName;
            }

            if (opp.McaApp__Owner_1__c != null && opp.McaApp__Owner_1__r.Email != null && opp.McaApp__Owner_1__r.Email.trim() != '') {

                Owner1Email = opp.McaApp__Owner_1__r.Email;
            }

            if (opp.McaApp__Sales_Rep__c != null && opp.McaApp__Sales_Rep__r.Email != null) {

                isoSalesRepEmail = opp.McaApp__Sales_Rep__r.Email;
            }

            if (opp.McaApp__Owner_2__c != null && opp.McaApp__Owner_2__r.Email != null) {

                owner2Email = opp.McaApp__Owner_2__r.Email;
            }
            //Get Opp Link
            String oppLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;
            keywords.put('[OWNER1EMail]', (Owner1Email != null ? Owner1Email :''));
            keywords.put('[OWNER2EMail]', (Owner2Email != null ? Owner2Email :''));
            keywords.put('[OWNERNAME]', ownerName);
            keywords.put('[RECIPIENTNAME]', (recipientName != null ? recipientName : '[RECIPIENTNAME]'));
            keywords.put('[ISOSalesRepEmail]', (isoSalesRepEmail != null ? isoSalesRepEmail : ''));
            keywords.put('[OPPORTUNITYNAME]', opp.Name);
            keywords.put('[OPPORTUNITYDETAIL]', oppLink);
            keywords.put('[UnderwriterName]',opp.Underwriter__r.Name);
            keywords.put('[UnderwriterEmail]',opp.Underwriter__r.Email);
            system.debug('2222222222' + keywords);
            //keywords.put('[OPPORTUNITYDETAIL]', '<a href=' + '"' + oppLink + '" >Opportunity</a>'); In case they want it linkable
        }
    }



    private void replaceKeywords() {

        if ( emailDetail.Header__c != null ) {

            header = emailDetail.Header__c;    
        }
        else {

            header = '';
        }

        if ( emailDetail.Footer__c != null ) {

            footer = emailDetail.Footer__c;
        }
        else {

            footer = '';
        }
        
        if ( emailDetail.Subject__c != null ) {

            subject = emailDetail.Subject__c;
        }
        else {

            subject = '';
        }

        if ( emailDetail.To__c != null ) {

            to = emailDetail.To__c;
        }
        else {

            to = '';
        }

        if ( emailDetail.CC__c != null ) {

            cc = emailDetail.CC__c;
        }
        else {

            cc = '';
        }

        if ( emailDetail.BCC__c != null ) {

            bcc = emailDetail.BCC__c;
        }
        else {
        
            bcc = '';
        }
        
        if (to == '' && !to.contains('[ISOSalesRepEmail]'))

            to = '[ISOSalesRepEmail]';
        
            for (String kw : keywords.keySet() ) {

                to = to.replace(kw, keywords.get(kw));
                header = header.replace(kw, keywords.get(kw));
                footer = footer.replace(kw, keywords.get(kw));
                subject = subject.replace(kw, keywords.get(kw));
                cc = cc.replace(kw, keywords.get(kw));
                bcc = bcc.replace(kw, keywords.get(kw));
            }

        system.debug('4444444444444' + emailDetail);
    }
}