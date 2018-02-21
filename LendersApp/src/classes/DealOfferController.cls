public with sharing class DealOfferController{
    public Opportunity opp {get;set;}
    public List<OfferCustom> lstOffer {get;set;}
    public List<McaApp__Offer__c> lstExistingOffer {get;set;}
    public List<McaApp__Bank_Account__c> lstBankStatements {get;set;}
    public List<McaApp__Credit_Card__c> lstCreditCard{get; set;}
    public List<McaApp__Stips__c> lstStips{get; set;}
    public String currentTab {get;set;}
    public boolean showOffer {get;set;}
    public List<OfferCustom> lstSelectedOffer {get;set;}
    transient public Messaging.SingleEmailMessage emailOffer {get;set;}
    public String emailToAddress {get;set;}
    public String emailFromAddress {get;set;}
    public String emailCCAddress {get;set;}
    public String emailBCCAddress {get;set;}
    public String emailBody {get;set;}
    public String emailSubject {get;set;}
    public List<StipMasterWrap> lstStipMaster {get;set;}
    public StipMaster__c objNewStip {get;set;}
    public boolean displayPopup {get; set;}
    public List<McaApp__Stips__c> lstStipToInsert {get;set;}
    public List<StipCustom> lstExistingStip {get;set;}
    public List<StipMasterWrap> defaultStips { get; set; }
    public String oppId {get;set;}
    public Set<Id> setChosenOfferIds {get;set;}
    public boolean setOverrideFilter {get;set;}
    public List<StipMasterWrap> stipsAutoIncluded {get; set;}
    public AttachmentWrapper[] wrappers {get; set;}
    public Boolean showDialog {get;set;}
    public Boolean showTermDays { get; set; }
    public Decimal numberOfBusinessDays { get; set; }


    public DealOfferController(ApexPages.StandardController controller) {

        oppId = ApexPages.currentpage().getParameters().get('id');
        objNewStip = new StipMaster__c ();
        opp = new Opportunity();
        setOverrideFilter = false;
        showDialog = false;
        showTermDays = false;
        numberOfBusinessDays = 21;

        lstOffer = new List<OfferCustom>();
        lstExistingOffer = new List<McaApp__Offer__c>();
        lstStipToInsert  = new List<McaApp__Stips__c>();
        lstBankStatements = new List<McaApp__Bank_Account__c>();
        lstCreditCard = new List<McaApp__Credit_Card__c>();
        lstStips = new List<McaApp__Stips__c>();
        lstExistingStip = new List<StipCustom>();
        stipsAutoIncluded = new List<StipMasterWrap>();
        currentTab = 'default';
        emailFromAddress = '';
        emailToAddress = '';
        emailCCAddress = '';
        emailBCCAddress = '';
        emailBody = '';
        showOffer = false;
        lstStipMaster = new List<StipMasterWrap>();
        defaultStips = new List<StipMasterWrap>();
        lstSelectedOffer = new List<OfferCustom>();
        emailSubject = 'Offer Notification';
        setChosenOfferIds = new Set<Id>();

        ////Get the current deal details

        List<Opportunity> lstOpp =  [SELECT Id,
                                            McaApp__Amount_Requested__c,
                                            Account.Name,
                                            McaApp__ISO__c,
                                            CreatedById,
                                            Deal_Rating__c,
                                            McaApp__Gross_monthly_Sales__c,
                                            McaApp__Term_Requested__c,
                                            Account.McaApp__NumberofLocations__c,
                                            Account.McaApp__NSFs_Avg__c,
                                            McaApp__Use_of_Proceeds__c,
                                            TaxLiens__c,
                                            McaApp__Owner_1__r.Name,
                                            Account.McaApp__NDBs_Avg__c,
                                            McaApp__Balance__c,
                                            McaApp__Average_Daily_Balance__c,
                                            McaApp__Holdback_Percentage__c,
                                            Hybrid_Daily_Pmt__c,
                                            McaApp__Sales_Rep__r.Email,
                                            AdjustedMonthlyGrossSales__c,
                                            Max_Monthly_PMT__c,
                                            McaApp__Sales_Rep__r.FirstName,
                                            Min_Factor_per_Month__c,
                                            Factor_per_Year__c,
                                            AdjustedMonthlyCCSales__c,
                                            Account.McaApp__Years_in_Business__c,
                                            McaApp__Sales_Rep__c,
                                            McaApp__Funded_Notes__c,
                                            McaApp__Credit_Card_Sales__c,
                                            McaApp__Credit_Score__c,
                                            ProgramType__c,
                                            Terms_to_Offer__c,
                                            Max_Gross__c,
                                            Open_Positions__c,
                                            McaApp__Funding_Amount__c,
                                            McaApp__Owner_2__c,
                                            McaApp__Owner_2__r.Email,
                                            Max_Holdback__c,
                                            Name,
                                            McaApp__Owner_1__c,
                                            McaApp__Owner_1__r.Email,
                                            Owner.Name,
                                            Funding_Amount_Override__c,
                                            Underwriter__c,
                                            Underwriter__r.Name,
                                            Underwriter__r.Email,
                                            Underwriting_Notes__c
                                            FROM Opportunity
                                            WHERE Id = :oppId];




        lstExistingOffer =  [SELECT McaApp__Deal_Type__c,
                                    Name,
                                    McaApp__Opportunity__c,
                                    McaApp__Term_Months__c,
                                    Term_Days__c,
                                    McaApp__Amount__c,
                                    Percentage_of_Gross__c,
                                    Factor_per_Month__c,
                                    Deal_Length__c,
                                    Monthly_PB_Amount__c,
                                    Daily_PB_Amount__c,
                                    McaApp__Holdback__c,
                                    McaApp__Payment_Amt__c,
                                    McaApp__PMT_Schedule__c,
                                    McaApp__Rate__c,
                                    Payback__c
                                    FROM McaApp__Offer__c
                                    WHERE McaApp__Opportunity__c = :oppId
                                    ORDER BY Name];

        if ( lstOpp != null && lstOpp.size() > 0 ) {

            opp = lstOpp[0];

            //Get custom setting values
            DealDefaultFieldValue__c objSetting = DealDefaultFieldValue__c.getOrgDefaults();

            //Default from custom settings
            if ( objSetting != null ) {

                if ( opp.Max_Gross__c == null || opp.Max_Gross__c < 0 ) {

                    opp.Max_Gross__c = objSetting.Max_Gross__c ;
                }

                opp.Min_Factor_per_Month__c = objSetting.Min_Factor_per_Month__c;

                if ( opp.Max_Holdback__c == null || opp.Max_Holdback__c < 0 ) {

                    opp.Max_Holdback__c = objSetting.Max_Holdback__c;
                }

                showTermDays = objSetting.Set_Terms_as_Days__c;

                if (objSetting.Number_of_Business_Days__c != null) {
                    numberOfBusinessDays = objSetting.Number_of_Business_Days__c;
                }
            }
        }

        // Populate Bank Statements on Deal Summary & Select Offers screen - Shraddha
        lstBankStatements = [SELECT Id,
                                    McaApp__Month__c,
                                    McaApp__Year__c,
                                    McaApp__Deposits__c,
                                    McaApp__Average_Daily_Balance__c,
                                    McaApp__Number_of_NSFs__c,
                                    McaApp__Number_of_Negative_Days__c,
                                    McaApp__Bank_Account_Number__c
                                    FROM McaApp__Bank_Account__c
                                    WHERE McaApp__Opportunity__c = :oppId];

        // Populate Credit Card Sales on Deal Summary & Select Offers screen -Shraddha
        lstCreditCard = [SELECT Id,
                                McaApp__Month__c,
                                McaApp__Year__c,
                                McaApp__Total_Net_Processed_All__c,
                                McaApp__Number_of_Transactions_All__c,
                                McaApp__Processor_Name__c,
                                McaApp__MID_Account_Number__c
                                FROM McaApp__Credit_Card__c
                                WHERE McaApp__Opportunity__c = :oppId];

        // Populate Stips on Deal Summary & Select Offers screen -Shraddha
        lstStips =  [SELECT Id,
                            McaApp__Recv_d__c,
                            Name,
                            McaApp__Type__c,
                            McaApp__Status__c,
                            McaApp__Requested_by__c,
                            McaApp__Date_Requested__c,
                            McaApp__Requirement__c,
                            McaApp__Submission__c,
                            Notes__c,
                            StipMaster__c,
                            Interview__c,
                            Completed__c,
                            McaApp__Opportunity__c
                            FROM McaApp__Stips__c
                            WHERE McaApp__Opportunity__c = :oppId];

        //Populate Stips List
        currentTab = 'default';

       //wrappers = getAttachments();
    }

    public List<selectoption> getOrgWideEmailAddress() {

        List<SelectOption> lstEmailIds = new List<SelectOption>();

        // Use Organization Wide Address
        for ( OrgWideEmailAddress owa : [SELECT Id, Address FROM OrgWideEmailAddress] ) {

           lstEmailIds.add( new SelectOption( owa.Id, owa.address ) );
        }

       return lstEmailIds;
    }

    public Pagereference addToChosenOffers() {

        //remove from lstOffer list
        System.debug( '>>> lstOffer.size() : ' + lstOffer.size() );

        for ( Integer i = 0; i < lstOffer.size(); i++ ) {

           if ( lstOffer[i].selected ) {

               lstSelectedOffer.add(lstOffer[i]);
               setChosenOfferIds.add(lstOffer[i].programId);
               lstOffer.remove(i);
               i--;

           }

        }

        currentTab = 'step1';

        System.debug( '>>> addToChosenOffers lstSelectedOffer.size() : ' + lstSelectedOffer.size() );
        return null;
    }

    public Pagereference removeFromChosenOffers() {

        //remove from lstOffer list
        for ( Integer i = 0; i < lstSelectedOffer.size(); i++ ) {

           if ( lstSelectedOffer[i].selected ) {

               lstOffer.add(lstSelectedOffer[i]);
               setChosenOfferIds.remove(lstSelectedOffer[i].programId);
               lstSelectedOffer.remove(i);
               i--;
           }
        }

        System.debug( '>>> lstOffer lstSelectedOffer.size() : ' + lstOffer.size() );
        System.debug( '>>> removeFromChosenOffers lstSelectedOffer.size() : ' + lstSelectedOffer.size() );
        currentTab = 'step1';
        return null;
    }

    //Move to Step 1
    public Pagereference goToStep1() {

        //getOffers();
        currentTab = 'step1';
        return null;
    }

    //Move to Step 2
    public Pagereference goToStep2() {

        Set<Id> neverIncludeStipId = new Set<Id>();
        Set<Id> setCurrentStipId = new Set<Id>();

        for ( StipMaster__c objStip : [SELECT Id, Name, Type__c, Notes__c, Owner.Name, Include_in_Offers__c FROM StipMaster__c WHERE Include_in_Offers__c = 'Never include' LIMIT 1000] ) {

            neverIncludeStipId.add( objStip.Id );
        }

        //Get all Stip master ids from which the existing stips were created
        //for (McaApp__Stips__c uw : [SELECT Id, StipMaster__c, Name, Notes__c, Interview__c, Completed__c, McaApp__Opportunity__c, McaApp__Status__c
        //                            FROM McaApp__Stips__c WHERE McaApp__Opportunity__c = :opp.Id AND Completed__c = false]) {
        for ( McaApp__Stips__c uw : lstStips) {

            if ( uw.Completed__c == false ) {

                setCurrentStipId.add( uw.StipMaster__c );
                System.debug( '>>>setCurrentStipId.add : ' + setCurrentStipId );

                //add to existing stip list
                if ( !neverIncludeStipId.contains( uw.StipMaster__c ) ) {

                    lstExistingStip.add(new StipCustom( uw ));
                }


            }

        }

        //get all Stip list from Stip master

        defaultStips.clear();

        for ( StipMaster__c objStip :   [SELECT Id, Name, Type__c, Notes__c, Owner.Name,
                                                Include_in_Offers__c FROM StipMaster__c WHERE Id NOT IN :setCurrentStipId
                                                AND Id NOT IN :neverIncludeStipId LIMIT 1000] ) {

            System.debug( '>>> objStip : ' + objStip.Include_in_Offers__c);

            if (objStip.Include_in_Offers__c == 'Always include in offers') {

                StipMasterWrap sm = new StipMasterWrap(objStip);
                sm.selected = true;
                defaultStips.add(sm);
            }
            else {

                lstStipMaster.add(new StipMasterWrap(objStip));
            }
        }

        System.debug( '>>> defaultStips.size() : ' + defaultStips.size() );



        //Map<Id, McaApp__Stips__c> mastersNotReceived = new Map<Id, McaApp__Stips__c>();

        //for (McaApp__Stips__c stipNotReceived : [SELECT Id, StipMaster__c, McaApp__Opportunity__c FROM McaApp__Stips__c WHERE McaApp__Opportunity__c = :opp.Id AND McaApp__Recv_d__c = false]) {
        //    mastersNotReceived.put(stipNotReceived.StipMaster__c, stipNotReceived);
        //}



        //NOT IN CURRENT
        for ( StipMaster__c master : [SELECT Id, Name, Type__c, Notes__c, Owner.Name, Include_in_Offers__c
                                        FROM StipMaster__c WHERE Id NOT IN :setCurrentStipId LIMIT 1000] ) {

            for ( StipMasterWrap sm : lstStipMaster ) {

                if (master.Include_in_Offers__c == 'Always include in offers' && master.Id == sm.objStip.Id) {

                    sm.selected = true;
                }
                if (master.Include_in_Offers__c == 'Include in offers when not already received' && setCurrentStipId.contains(master.Id)) {

                    sm.selected = true;
                }
            }

        }

        //IN CURRENT STIPS
        system.debug('>>> setCurrentStipId :'+setCurrentStipId);
        system.debug('>>>  lstExistingStip : '+lstExistingStip);
        for (StipMaster__c master : [SELECT Id, Name, Type__c, Notes__c, Owner.Name, Include_in_Offers__c
                                        FROM StipMaster__c WHERE Id IN :setCurrentStipId LIMIT 1000]) {


            for (StipCustom sc : lstExistingStip) {
                if (sc.objStip.StipMaster__c == master.Id) {
                    if (master.Include_in_Offers__c == 'Always include in offers' ) {
                        sc.selected = true;
                    }
                    if (master.Include_in_Offers__c == 'Include in offers when not already received' && setCurrentStipId.contains(master.Id)) {
                        sc.selected = true;
                    }
                }
            }
        }


        //for (StipMaster__c master : [SELECT Id, Name, Type__c, Notes__c, Owner.Name, Include_in_Offers__c
        //                                FROM StipMaster__c LIMIT 1000]) {
        //    //MASTER HAS INCLUDE WHEN NOT RECEIVED.

        //    for (StipMasterWrap sm : lstStipMaster) {
        //        system.assert(mastersNotReceived.containsKey(master.Id));
        //        if (master.Include_in_Offers__c == 'Include in offers when not already received' && mastersNotReceived.containsKey(master.Id) && master.Id == sm.objStip.Id) {
        //            sm.selected = true;

        //            system.assert(false, ' '+ sm.selected + ' '  );
        //        }

        //    }
        //}

        system.debug('>>> lstSelectedOffer.size() : ' + lstSelectedOffer.size());
        //If no offer is selected
        if (lstSelectedOffer.size() <= 0 && currentTab != 'default') {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select at least one Offer.'));
            return null;

        }

        currentTab = 'step2';
        return null;

    }


    public void updateDeal() {

        update opp;

        if (opp.Account != Null) {

            update opp.Account;
        }
    }


    //Move to Step 3
    public Pagereference goToStep3() {

        currentTab = 'step3';
        updateDeal();
        return null;

    }

    //Move to Step 4
    public pagereference goToStep4(){

        currentTab = 'step4';



        String recipientName = '';

        if (opp.McaApp__Sales_Rep__c != null && opp.McaApp__Sales_Rep__r.FirstName != null) {
            recipientName = opp.McaApp__Sales_Rep__r.FirstName;
        }

        /*if (opp.McaApp__Sales_Rep__r.Email != null && opp.McaApp__Sales_Rep__r.Email.trim() != '') {

            emailToAddress = opp.McaApp__Sales_Rep__r.Email;
        }
        if (opp.McaApp__Owner_1__c != null && opp.McaApp__Owner_1__r.Email!=null && opp.McaApp__Owner_1__r.Email.trim() != '') {

            emailToAddress += opp.McaApp__Owner_1__r.Email;
        }*/

        Offer_Email_Detail__c[] emailDetail = [SELECT Id, Header__c, To__c, Footer__c, CC__c, BCC__c, Subject__c FROM Offer_Email_Detail__c WHERE Active__c = true];
        String header = '';
        String footer = '';
        system.debug('>>> emailDetail : '+emailDetail);

        if (!emailDetail.isEmpty()) {
            //emailCCAddress = emailDetail[0].CC__c;
            //emailBCCAddress = emailDetail[0].BCC__c;

            DealOfferControllerUtils emailUtility = new DealOfferControllerUtils(emailDetail[0], opp);
            system.debug('444444444' + emailUtility);
            header = emailUtility.header;
            footer = emailUtility.footer;
            emailSubject = emailUtility.subject;
            
            if (emailUtility.to != null) {

                emailToAddress = emailUtility.to;
            }
            if (emailUtility.cc != null) {

                emailCCAddress = emailUtility.cc;
            }
            if (emailUtility.bcc != null) {

                emailBCCAddress = emailUtility.bcc;
            }
        }
        emailToAddress = emailToAddress.startsWith(';') == true ? emailToAddress.replace(';','') : emailToAddress;

        emailBody = header;


        emailBody = emailBody +
         '<br/><br/> <apex:outputLabel> <br/> <font size="3"><b>Offers:</b></font></apex:outputLabel> <br/>' +
         '<table width="100%" border="0">'
         + '<tr>'
            +'<th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('McaApp__Deal_Type__c').getDescribe().getLabel();

        if (showTermDays) {

            emailBody += '</th><th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('Term_Days__c').getDescribe().getLabel();
        }
        else {
            
            emailBody += '</th><th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('McaApp__Term_Months__c').getDescribe().getLabel();
        }



         emailBody += ''
            +'</th> <th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('McaApp__Amount__c').getDescribe().getLabel()
            +'</th> <th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('Payback__c').getDescribe().getLabel()
            +'</th> <th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('McaApp__Rate__c').getDescribe().getLabel()
            +'</th> <th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('McaApp__Holdback__c').getDescribe().getLabel()
            +'</th> <th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('Daily_ACH__c').getDescribe().getLabel();
        
        if (!showTermDays) {

            emailBody += ''
                +'</th> <th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('Daily_PB_Amount__c').getDescribe().getLabel()
                +'</th> <th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('Monthly_PB_Amount__c').getDescribe().getLabel()
                +'</th> <th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('Deal_Length__c').getDescribe().getLabel()
                +'</th> <th style="background-color:#DBDBDB;">' + Schema.getGlobalDescribe().get('McaApp__Offer__c').getDescribe().fields.getMap().get('Factor_per_Month__c').getDescribe().getLabel();
        }

        emailBody += ''    
            +'</tr>';

        system.debug('>>> lstSelectedOffer : '+lstSelectedOffer);

            for (OfferCustom o : lstSelectedOffer) {

               //Remove Holdback value if ACH
               if (o.objOffer.McaApp__Deal_Type__c == 'ACH') {

                   o.objOffer.McaApp__Holdback__c = null;
               }

               //Remove Daily ACH if MCA
               if (o.objOffer.McaApp__Deal_Type__c == 'MCA') {

                   o.objOffer.Daily_ACH__c = null;
               }

               emailBody = emailBody +
                '<tr>'+
                '<td width="4%">' + (o.objOffer.McaApp__Deal_Type__c != null ? '' + o.objOffer.McaApp__Deal_Type__c : '');

                if (showTermDays) {

                    emailBody += '</td> <td width="4%">' + (o.objOffer.McaApp__Term_Months__c != null ? '' + o.objOffer.Term_Days__c : '');
                }
                else {

                    emailBody += '</td> <td width="4%">' + (o.objOffer.McaApp__Term_Months__c != null ? '' + o.objOffer.McaApp__Term_Months__c : '');
                }

                emailBody += ''
                + '</td> <td width="13%" style="text-align:right">' + (o.objOffer.McaApp__Amount__c != null ? '$' + doFormatting(o.objOffer.McaApp__Amount__c, 2, ',', '.') : '')
                + '</td> <td width="13%" style="text-align:right">' + (o.objOffer.Payback__c != null ? '$' + doFormatting(o.objOffer.Payback__c, 2, ',', '.') : '')
                + '</td> <td width="4%">' + (o.objOffer.McaApp__Rate__c != null ? '' + o.objOffer.McaApp__Rate__c : '')
                + '</td> <td width="14%">' + (o.objOffer.McaApp__Holdback__c != null ? '' + o.objOffer.McaApp__Holdback__c + '%' : '')            
                + '</td> <td width="14%" style="text-align:right">' + (o.objOffer.Daily_ACH__c != null ? '$' + doFormatting(o.objOffer.Daily_ACH__c, 2, ',', '.') : '');
                
                if (!showTermDays) {

                    emailBody += ''
                        + '</td> <td width="10%" style="text-align:right">' + (o.objOffer.Daily_PB_Amount__c != null ? '$' + doFormatting(o.objOffer.Daily_PB_Amount__c, 2, ',', '.') : '')
                        + '</td> <td width="10%" style="text-align:right">' + (o.objOffer.Monthly_PB_Amount__c != null ? '$' + doFormatting(o.objOffer.Monthly_PB_Amount__c, 2, ',', '.') : '')
                        + '</td> <td width="10%">' + (o.objOffer.Deal_Length__c != null ? '' + o.objOffer.Deal_Length__c : '')
                        + '</td> <td width="4%">' + (o.objOffer.Factor_per_Month__c != null ? '' + o.objOffer.Factor_per_Month__c : '');
                }

                emailBody += ''
                    + '</td></tr>';
            }

        emailBody = emailBody + '</table> <br/><br/>';



        //Prepare stips table if stips records exist
        if (lstStipToInsert.size() > 0) {

            emailBody = emailBody +'<apex:outputLabel><font size="3"><b> Stips: </b></font></apex:outputLabel><br/>'
            + '<table width="50%"><tr>'
            + '<th style="background-color:#DBDBDB;"> Name</th>  <th style="background-color:#DBDBDB;">Notes</th> <th style="background-color:#DBDBDB;">Status</th> </tr>';

            for (McaApp__Stips__c s : lstStipToInsert) {

                emailBody = emailBody +
                           '<tr> <td width="30%">' + ((s.Name != null) ? s.Name : '')
                           + '</td> <td width="30%">' + ((s.Notes__c != null) ? s.Notes__c : '')
                           + '</td> <td width="35%">' + ((s.McaApp__Status__c != null) ? s.McaApp__Status__c : '')
                           + '</tr>';
            }

            emailBody = emailBody + '</table><br/>';


        }

        emailBody += footer;

        /* ----- Built "emailBody" to show all Tables in the Text Area  ---- */
        return null;
    }
    // on click of Save & Close button on 4th screen
    public pagereference saveSelectedOfferAndStip() {

         List<McaApp__Offer__c> lstToBeInserted = new List<McaApp__Offer__c>();

        for ( OfferCustom o : lstSelectedOffer) {

            System.debug('\n\n\n' + o.objOffer.Name);
            lstToBeInserted.add(o.objOffer);

        }

        //insert Offers
        if ( lstToBeInserted.size() > 0) {

            upsert lstToBeInserted;

        }

        system.debug('7777777777777777777' + lstStipToInsert);
        //Insert Stips

        if ( lstStipToInsert != null && lstStipToInsert.size() > 0) {

            upsert lstStipToInsert;

        }

        return new pagereference('/' + opp.id);
    }

    //Stip new save & close
    public void stipSaveAndClose() {

        objNewStip.OwnerId = UserInfo.getUserId();
        insert objNewStip;

        StipMasterWrap s = new StipMasterWrap(objNewStip);
        s.selected = true;
        lstStipMaster.add(s);
        currentTab = 'step2';
        displayPopup = false;
        //return null;
    }

    //New stip Cancel
    public void stipCancelNew() {

        displayPopup = false;
        currentTab = 'step2';
    }

    public Pagereference stipDone() {

        lstStipToInsert = new List<McaApp__Stips__c>();
        system.debug('>>> defaultStips : '+defaultStips.size());
        
        for (StipMasterWrap wrap : defaultStips) {

            if (wrap.selected) {

                McaApp__Stips__c objNewStip = new McaApp__Stips__c();

                objNewStip.Name = wrap.objStip.Name;
                objNewStip.McaApp__Status__c = 'Pending';
                objNewStip.McaApp__Opportunity__c = opp.Id;
                objNewStip.Notes__c = wrap.objStip.Notes__c;
                objNewStip.StipMaster__c = wrap.objStip.id;

                lstStipToInsert.add(objNewStip);
            }
        }

        for (StipMasterWrap wrap : lstStipMaster) {

            if (wrap.selected) {

                McaApp__Stips__c objNewStip = new McaApp__Stips__c();

                objNewStip.Name = wrap.objStip.Name;
                objNewStip.McaApp__Status__c='Pending';
                objNewStip.McaApp__Opportunity__c = opp.Id;
                objNewStip.Notes__c = wrap.objStip.Notes__c;
                objNewStip.StipMaster__c = wrap.objStip.id;

                lstStipToInsert.add(objNewStip);
            }
        }



        //add from existing if selected
        for (StipCustom wrap : lstExistingStip) {

            if (wrap.selected) {
                lstStipToInsert.add(wrap.objStip);
            }

        }

        currentTab = 'step3';
        return null;
    }

    //Add new stip
    public void newStip() {

        currentTab = 'step2';
        objNewStip = new StipMaster__c ();
        displayPopup = true;
    }

    //Save Offers and move to Next Step
    public Pagereference saveOffersStips() {

        //move to next step
        goToStep4();
        return null;
    }

    //Add Custom Offer
    public Pagereference addOffer() {


        McaApp__Offer__c[] offer = [SELECT Id, McaApp__Opportunity__c, McaApp__Submission__c FROM McaApp__Offer__c WHERE McaApp__Opportunity__c = :opp.Id];

        McaApp__Submission__c[] submission = [SELECT Id, McaApp__Opportunity__c FROM McaApp__Submission__c WHERE McaApp__Opportunity__c = :opp.Id];
        

        if (submission.isEmpty()) {

            DealDefaultFieldValue__c customSetting = DealDefaultFieldValue__c.getOrgDefaults();
            McaApp__Submission__c auxSubmission = new McaApp__Submission__c();
            auxSubmission.McaApp__Opportunity__c = opp.Id;
            auxSubmission.McaApp__Funder__c = customSetting.Account_Id__c;
            auxSubmission.McaApp__Program__c = customSetting.Bank_Program_Id__c;

            insert auxSubmission;
            submission.add(auxSubmission);
        }

        ProgramMaster__c[] prog = [SELECT Id, Name, Upfront_Fee_Percentage__c, Min_Offer_Amount__c, Master_Type__c FROM ProgramMaster__c WHERE Program_Type__c = :opp.ProgramType__c];

        String programName = '';
        
        if (!prog.isEmpty()) {

            programName = prog[0].Name;
        }


        OfferCustom newOffer = new OfferCustom(
                new McaApp__Offer__c(
                    McaApp__Opportunity__c = opp.id,
                    McaApp__Submission__c = submission[0].Id
            ), false, true, null, true);

        newOffer.programMasterName = programName;
        newOffer.isNew = True;
        newOffer.selected = true;

        System.debug('********' + currentTab);

        if (currentTab == 'step1') {

            lstOffer.add(newOffer);
        }
        else if (currentTab == 'step3') {

            lstSelectedOffer.add(newOffer);
        }
        return null;
    }


    public void getOffers() {

        Set<Integer> setTerms;
        Set<String> setTypes = new Set<String>();
        lstOffer = new List<OfferCustom>();
        showOffer = true;

        //split terms and create set for query
        if (opp.Terms_to_Offer__c != null) {

            setTerms = new Set<Integer>();
            
            for (String i : opp.Terms_to_Offer__c.split(';')) {

                setTerms.add(Integer.valueOf(i.trim()));
            }

        }

        //split deal types  and create set for query
        if (opp.ProgramType__c != null) {

            for (String i : opp.ProgramType__c.split(';')) {

                setTypes.add(i.trim());
            }

        }

        McaApp__Submission__c[] submission = [SELECT Id, McaApp__Opportunity__c FROM McaApp__Submission__c WHERE McaApp__Opportunity__c = :opp.Id];

        if (submission.isEmpty()) {

            DealDefaultFieldValue__c customSetting = DealDefaultFieldValue__c.getOrgDefaults();
            McaApp__Submission__c auxSubmission = new McaApp__Submission__c();
            auxSubmission.McaApp__Opportunity__c = opp.Id;
            auxSubmission.McaApp__Funder__c = customSetting.Account_Id__c;
            auxSubmission.McaApp__Program__c = customSetting.Bank_Program_Id__c;

            insert auxSubmission;
            submission.add(auxSubmission);
        }

        //List for amount requested offers
        List<OfferCustom> lstAmtReqOffer = new List<OfferCustom>();
        List<ProgramMaster__c> lstProgramMaster = new List<ProgramMaster__c>();

        String query = 'SELECT Id, Name, DealScore__c, Term__c, Term_Days__c, Program_Type__c, BuyRateNew__c, Upfront_Fee_Percentage__c,'+
                            'Upfront_Fees__c, Min_Credit_Score__c, Master_Type__c, Min_Monthly_Gross_Sales__c, Min_Time_in_business__c,'+
                            'Max_Gross__c, Max_Open_Positions__c, Min_Offer_Amount__c FROM ProgramMaster__c WHERE Active__c = true ';

        query += (setTypes!=NULL && setTypes.size()>0)?' AND (Program_Type__c IN : setTypes OR Program_Type__c=NULL)':'';
        query += (setTerms!=NULL && setTerms.size()>0)?' AND (Term__c IN : setTerms OR Term__c=NULL)':'';
        //query += opp.McaApp__Funding_Amount__c != NULL?' AND Min_Offer_Amount__c<='+opp.McaApp__Funding_Amount__c:'';
        query += opp.Deal_Rating__c!=NULL?' AND DealScore__c INCLUDES (\''+opp.Deal_Rating__c +'\')':'';
        system.debug('22222222222'+setOverrideFilter+'222'+opp.Account.McaApp__Years_in_Business__c);

        if (!setOverrideFilter) {

            query += opp.Open_Positions__c != NULL ? ' AND ( Max_Open_Positions__c>=' + opp.Open_Positions__c + ' OR Max_Open_Positions__c=NULL)' : '';
            query += opp.McaApp__Credit_Score__c != NULL ? ' AND (Min_Credit_Score__c<=' + opp.McaApp__Credit_Score__c + ' OR Min_Credit_Score__c=NULL)' : '';
            query += opp.McaApp__Gross_monthly_Sales__c != NULL ? ' AND (Min_Monthly_Gross_Sales__c<=' + opp.McaApp__Gross_monthly_Sales__c + ' OR Min_Monthly_Gross_Sales__c=NULL)' : '';
            query += opp.Account.McaApp__Years_in_Business__c != NULL ? ' AND (Min_Time_in_business__c<=' + opp.Account.McaApp__Years_in_Business__c + ' OR Min_Time_in_business__c=NULL)' : '';
        }

        query += ' AND Id NOT IN : setChosenOfferIds order by name';
        system.debug('11111111111111' + query);
        lstProgramMaster = database.query(query);


        /*if(!setOverrideFilter)
            lstProgramMaster = [SELECT Id, Name, DealScore__c, Term__c, Program_Type__c, BuyRateNew__c, Upfront_Fee_Percentage__c, Upfront_Fees__c, Min_Credit_Score__c, Min_Monthly_Gross_Sales__c, Min_Time_in_business__c, Max_Gross__c FROM ProgramMaster__c WHERE Active__c = true AND Program_Type__c IN :setTypes AND Term__c IN :setTerms AND DealScore__c INCLUDES (:opp.Deal_Rating__c)
                                           AND (Min_Credit_Score__c=NULL OR Min_Credit_Score__c <=: opp.McaApp__Credit_Score__c) AND (Min_Monthly_Gross_Sales__c=NULL OR Min_Monthly_Gross_Sales__c <=: opp.McaApp__Gross_monthly_Sales__c)
                                           AND (Min_Time_in_business__c=NULL OR Min_Time_in_business__c <=: opp.Account.McaApp__Years_in_Business__c)
                                           AND Id NOT IN :setChosenOfferIds order by name];
        else
            lstProgramMaster = [SELECT Id, Name, DealScore__c, Term__c, Program_Type__c, BuyRateNew__c, Upfront_Fee_Percentage__c, Upfront_Fees__c, Min_Credit_Score__c, Min_Monthly_Gross_Sales__c, Min_Time_in_business__c, Max_Gross__c FROM ProgramMaster__c WHERE Active__c = true AND Program_Type__c IN :setTypes AND Term__c IN :setTerms AND DealScore__c INCLUDES (:opp.Deal_Rating__c)
                                           AND Id NOT IN :setChosenOfferIds order by name];
        */


        //GET PROGRAM MASTERS WITH CRITERIA ENABLED

        ProgramMaster__c[] programsToEvaluate = [SELECT Id, Name, DealScore__c, Term__c, Term_Days__c, Program_Type__c, BuyRateNew__c, Upfront_Fee_Percentage__c,
                                            Upfront_Fees__c, Min_Credit_Score__c, Min_Monthly_Gross_Sales__c, Master_Type__c, Min_Time_in_business__c,
                                            Max_Gross__c, Max_Open_Positions__c, Min_Offer_Amount__c FROM ProgramMaster__c WHERE Use_Custom_Criteria__c = true];

        Program_Master_Criteria__c[] criterias = [SELECT Id, Name, Field_Name__c, Field_Value__c, Operator__c, Program_Master__c FROM Program_Master_Criteria__c WHERE Program_Master__c IN :programsToEvaluate];

        Set<String> fields = new Set<String>();

        CompareUtils comparator = new CompareUtils();

        String oppQuery = 'SELECT Id ';

        for (Program_Master_Criteria__c criteria : criterias) {

            fields.add(criteria.Field_Name__c);
        }

        for (String field : fields) {

            oppQuery += ', ' + field;
        }

        oppQuery += ' FROM Opportunity WHERE Id = :oppId';

        try {

            Opportunity oppValue = (Opportunity)Database.query(oppQuery);
            Set<Id> noRepeat = setChosenOfferIds;
            
            for (ProgramMaster__c objProgram : lstProgramMaster) {

                noRepeat.add(objProgram.Id);
            }

            for (ProgramMaster__c program : programsToEvaluate) {

                for (Program_Master_Criteria__c criteria : criterias) {

                    if ((program.Id == criteria.Program_Master__c) && (!noRepeat.contains(program.Id))) {

                        if (comparator.compare(oppValue, criteria.Field_Name__c, criteria.Operator__c, criteria.Field_Value__c) ) {

                            //system.assert(false, '');
                            //if (program.Program_Type__c == null) {
                                //program.Program_Type__c = 'ACH';
                            //}

                            lstProgramMaster.add(program);
                            noRepeat.add(program.Id);
                        }
                    }
                }
            }

            setChosenOfferIds.clear();
            noRepeat.clear();
        }
        catch(Exception e) {

             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'One or more criterias contain fields that don\'t exist. Please check spelling.'));
        }




        //Get all program master records with type = Deal type & terms include deal terms
        for (ProgramMaster__c objProgram : lstProgramMaster) {

            McaApp__Offer__c objOffer = new McaApp__Offer__c(McaApp__Term_Months__c = objProgram.Term__c, McaApp__Rate__c = objProgram.BuyRateNew__c,
                                            McaApp__Deal_Type__c = objProgram.Program_Type__c, Orig_Fee_Percentage__c = objProgram.Upfront_Fee_Percentage__c,
                                            Orig_Fee__c = objProgram.Upfront_Fees__c,
                                            McaApp__Opportunity__c = opp.Id, McaApp__Submission__c = submission[0].Id);

            if (showTermDays) {
                objOffer.Term_Days__c = Integer.valueOf(objProgram.Term_Days__c);
            }

            system.debug('@@@@objOffer.McaApp__Amount__c@@@@@@'+objOffer.McaApp__Amount__c);

            if (objProgram.Max_Gross__c != null) {

                objOffer.Max_Gross__c = objProgram.Max_Gross__c;
                lstOffer.add(new OfferCustom(objOffer, false, false, objProgram));
                system.debug('@@@@ if @@@@@@' + objOffer.McaApp__Amount__c);
            }
            else{

                objOffer.Max_Gross__c = opp.Max_Gross__c;
                lstOffer.add(new OfferCustom(objOffer, false, true, objProgram));
                system.debug('@@@@ else @@@@@@' + objOffer.McaApp__Amount__c);
            }
        }

        system.debug('@@@@@@@@@@' + lstOffer);
        system.debug('@@@@@@@@@@' + lstOffer.size());

        //Add amount requested offers.
        if (lstAmtReqOffer.size() > 0) {

            lstOffer.addAll(lstAmtReqOffer);
        }

        currentTab='step1';


    }

    //back to default page
    public Pagereference backToDefaultPage() {

        currentTab = 'default';
        return null;

    }

    //back to step1 page
    public Pagereference backTostep1() {

        currentTab = 'step1';
        return null;

    }

    //back to step2 page
    public Pagereference backTostep2() {

        currentTab = 'step2';
        return null;

    }

    //back to step3 page
    public Pagereference backTostep3() {

        currentTab = 'step3';
        return null;

    }

    //Offer selection wrapper class
    public class OfferCustom {

        public McaApp__Offer__c objOffer {get;set;}
        public boolean selected {get;set;}
        public Decimal factorPerMonth {get;set;}
        public boolean isNew {get;set;}
        public Id programId {get;set;}
        public boolean amtRequested {get;set;}
        public String programMasterName { get; set; }
        public Boolean populateMaxGross { get; set; }
        public Boolean calculateMaxGross {get; set; }
        public Boolean newOffer {get; set; }
        public Decimal progMinAmount {get;set;}
        public ProgramMaster__c programMaster {get; set;}

        public OfferCustom(McaApp__Offer__c offer, boolean flag, Boolean calculate, ProgramMaster__c programMaster, Boolean newOffer) {
        
            objOffer = offer;
            selected = false;
            amtRequested = flag;
            this.calculateMaxGross = calculate;
            this.newOffer = newOffer;
            
            if (programMaster != null && !newOffer) {

                programId = programMaster.Id;
                objOffer.Program_Master__c = programMaster.Id;
                this.programMasterName = programMaster.Name;
                this.programMaster = programMaster;
                objOffer.Orig_Fee_Percentage__c = programMaster.Upfront_Fee_Percentage__c;
                progMinAmount = programMaster.Min_Offer_Amount__c;    
            }
        }

        public OfferCustom(McaApp__Offer__c offer, boolean flag, Boolean calculate, ProgramMaster__c programMaster) {

            this(offer, flag, calculate, programMaster, false);           
        }
    }



    //Save all after review
    public Pagereference sendEmail() {

        System.debug('\n\n\n +' + wrappers + '\n\n');

        if ( emailToAddress == null || emailToAddress == '') {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please enter to email address.'));
            return null;

        }

        if ( emailSubject == null || emailSubject == '') {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please enter email subject.'));
            return null;

        }


        List<McaApp__Offer__c> lstToBeInserted = new List<McaApp__Offer__c>();

        for ( OfferCustom o : lstSelectedOffer) {

            System.debug('\n\n\n'+o.objOffer.Name);
            lstToBeInserted.add(o.objOffer);

        }

        //insert Offers
        if ( lstToBeInserted.size() > 0) {

            upsert lstToBeInserted;

        }
        system.debug('!!!!!!!!!!!'+lstStipToInsert);
        //Insert Stips
        if ( lstStipToInsert != null && lstStipToInsert.size() > 0) {

            upsert lstStipToInsert;

        }

        //Update Deal
        update opp;

        //Construct & send email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.saveAsActivity = false;
        message.setOrgWideEmailAddressId(emailFromAddress);
        
        system.debug('>>> emailCCAddress : ' + emailCCAddress);
        
        if ( emailCCAddress != null && emailCCAddress != '' ) {

            List<String> lstCCAddress = new List<String>();

            //split by comma or semi colon if multiple emails
            string qt = emailCCAddress.contains(',') ? ',' : (emailCCAddress.contains(';')) ? ';' : '';

            if ( qt != '' ) {

                for ( string addr : emailCCAddress.split(qt) ) {

                    lstCCAddress.add(addr.trim());
                }

            }
            //if only single email entered
            else {

                lstCCAddress.add(emailCCAddress.trim());
            }

            message.setCcAddresses(lstCCAddress);
        }

        if ( emailBCCAddress != null && emailBCCAddress != '' ) {
            List<String> lstBCCAddress = new List<String>();

            //split by comma or semi colon if multiple emails
            string qt = emailBCCAddress.contains(',') ? ',' : (emailBCCAddress.contains(';')) ? ';' : '';

            if ( qt != '' ) {

                for (string addr : emailBCCAddress.split(qt) ) {

                    lstBCCAddress.add(addr.trim());

                }

            }

            //if only single email entered
            else {

                lstBCCAddress.add(emailBCCAddress.trim());

            }

            message.setBccAddresses(lstBCCAddress);
        }

        message.setSubject(emailSubject);
        message.setHtmlBody(emailBody);

        //send email if to address is populated
        if ( emailToAddress != null && emailToAddress != '' ) {

            List<String> lstToAddress = new List<String>();

            //split by comma or semi colon if multiple emails
            String qt = emailToAddress.contains(',') ? ',' : (emailToAddress.contains(';')) ? ';' : '';

            if ( qt != '' ) {

                for ( string addr : emailToAddress.split(qt) ) {

                    lstToAddress.add(addr.trim());

                }

            }

            //if only single email entered
            else {

                lstToAddress.add(emailToAddress.trim());

            }

            system.debug('1111111111111' + lstToAddress);
            message.setToAddresses(lstToAddress);

            Messaging.SendEmailResult[] mailResults = new Messaging.SendEmailResult[]{};

            try {

                mailResults = Messaging.sendEmail( new Messaging.SingleEmailMessage[]{message} );

            }
            //Error message if email fails
            catch ( Exception e ) {

                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error,'Please enter valid email addresses.') );
                return null;

            }

            //Success message if email sent successfully
            if ( mailResults.size() > 0 && mailResults.get(0).isSuccess() ) {

                //create activity after email sent successfully
                Task objTask = new Task( Subject = emailSubject, ActivityDate = Date.today(), OwnerId = UserInfo.getuserid(),
                                        whatid = opp.id, Description = emailBody, Status = 'Completed');
                insert objTask;

                //Set Offer status to sent
                for ( McaApp__Offer__c o : lstToBeInserted ) {

                    o.McaApp__Send__c = true;
                }

                //update Offers
                if ( lstToBeInserted.size() > 0 ) {

                    update lstToBeInserted;

                }
            }
        }

        //if invalid to email address
        else {

            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error,'Please enter valid email addresses.') );

        }

        return new pagereference('/' + opp.id);
    }

    //Wrapper Class for Stips
    public class StipMasterWrap {

        public StipMaster__c objStip {get;set;}
        public boolean selected {get;set;}

        public StipMasterWrap(StipMaster__c stip) {

            objStip = stip;
            selected = false;
        }

    }

    //Wrapper Class for selecting existing Stips
    public class StipCustom{

        public McaApp__Stips__c objStip {get;set;}
        public boolean selected {get;set;}

        public StipCustom(McaApp__Stips__c stip) {

            objStip = stip;
            selected = false;
        }

    }

    //Mthod- Format Currency field values ex 100,000,000
    public static String doFormatting(Decimal val, Integer dec, String tSep, String dSep) {

        String s, tmp;
        Integer i = 4 + dec;

        // If the number of decimals is zero (0)... prevents the first 1000s seperator from being set at the 4th.
        if ( dec == 0 ) {

            i--;
        }

        s = val.setScale(dec).toPlainString().replace(tSep, dSep);

        while ( s.length() > i ) {

            tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
            s = tmp;
            i += 4;
        }

        // If the number is negative and has a number non-decimal digits divisible by 3, it prevents putting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
        if ( s.substring(0,1) == '-' ) {

            if ( s.substring(1,2) == tSep ) {

                s = '-' + s.substring(2);
            }

        }

        return s;
    }


    public AttachmentWrapper[] getAttachments() {

        AttachmentWrapper[] attachs = new AttachmentWrapper[] {};

        Attachment[] attachments = [SELECT  Id,
                                            Name,
                                            ContentType,
                                            BodyLength,
                                                Body
                                            FROM Attachment
                                            WHERE ParentId = :oppId];

        //for (Attachment attachment :attachments) {

        //    attachs.add(new AttachmentWrapper(attachment));
        //}

        return attachs;
    }



    public Attachment attachment {
        
        get {

            if (attachment == null) {

                attachment = new Attachment();
            }

            return attachment;
        }
        
        set;
    }

  public PageReference upload() {

    attachment.OwnerId = UserInfo.getUserId();
    attachment.ParentId = oppId;
    attachment.IsPrivate = true;

    try {

        insert attachment;

    }
    catch (DMLException e) {

        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;

    }
    finally {

        attachment = new Attachment();
    }

    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
    return null;
  }

}