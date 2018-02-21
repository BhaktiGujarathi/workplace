public with sharing class NOCVisaController {

    private map < Id, Booking_Unit__c > mapAllBookingUnits;
    public list<Case> lstOpenCases { get; set; }
    public list<Case> lstClosedCases { get; set; }    
    public Id accountId {
        get;
        set;
    }
    public Id bookingUnitId {
        get;
        set;
    }
    public Booking_Unit__c selectedUnit {
        get;
        set;
    }
    public WrapperBookingUnit bookingUnitWrapper {
        get;
        set;
    }
    public Case caseRecord {
        get;
        set;
    }
    public Boolean renderUnitDetails {
        get;
        set;
    }
    public Boolean renderOtherDetails {
        get;
        set;
    }
    public string poaDateOfExpiry {
        get;
        set;
    }
    public string userNationality {
        get;
        set;
    }
    public Boolean isSaveAsDraft {
        get;
        set;
    }
    public Boolean isPOAPresent {
        get;
        set;
    }
    public Integer numberOfBuyer {
        get;
        set;
    }
    public Boolean buyerMultiselect {
        get;
        set;
    }
    public List < String > buyerNameList {
        get;
        set;
    }

    public AttachmenWrapper poaAttachmentWrapper {
        get;
        set;
    }
    public AttachmenWrapper crfAttachmentWrapper {
        get;
        set;
    }
    public AttachmenWrapper titleDeedAttachmentWrapper {
        get;
        set;
    }
    public AttachmenWrapper passportAttachmentWrapper {
        get;
        set;
    }
    public AttachmenWrapper additionalAttachmentWrapper {
        get;
        set;
    }
    public List < AttachmenWrapper > listAttachmentWrapper {
        get;
        set;
    }
    public Map < Id, AttachmenWrapper > mapIdAttachmentWrapper {
        get;
        set;
    }
    public List < SR_Attachments__c > listNOCforVisa {
        get;
        set;
    }

    public Id deleteAttRecId {
        get;
        set;
    }
    public transient String strDisplayMessage {
        get;
        set;
    }
    public String soaUrl {
        get;
        set;
    }
    public static final set < String > setGCCCountries = new set < String > {
        'Kuwait',
        'Qatar', 
        'Bahrain',
        'Oman'
    };
    public static final set < String > setUAEKSACountry = new set < String > {
        'Saudi Arabia',
        'United Arab Emirates'
    };

    public NOCVisaController() {
        lstOpenCases = new list<Case>();
        lstClosedCases = new list<Case>();        
        renderUnitDetails = false;
        renderOtherDetails = false;
        isSaveAsDraft = false;
        isPOAPresent = false;
        poaDateOfExpiry = '';
        numberOfBuyer = 1;
        buyerMultiselect = false;
        bookingUnitWrapper = new WrapperBookingUnit();
        poaAttachmentWrapper = new AttachmenWrapper();
        crfAttachmentWrapper = new AttachmenWrapper(); 
        titleDeedAttachmentWrapper = new AttachmenWrapper();
        passportAttachmentWrapper = new AttachmenWrapper();
        additionalAttachmentWrapper = new AttachmenWrapper();
        listAttachmentWrapper = new List < AttachmenWrapper > ();
        mapIdAttachmentWrapper = new Map < Id, AttachmenWrapper > ();
        buyerNameList = new List < String > ();
        listNOCforVisa = new List < SR_Attachments__c > ();
        caseRecord = new Case();
        caseRecord.RecordTypeId = getRecordTypeId('NOC_For_Visa', 'Case');

        // added for now **************
        userNationality = '';
    }


    public list < SelectOption > getBookingUnitList() {
        List < Account > listAccount = [Select Nationality__c from Account where Id =: accountId];
        if (listAccount != null && listAccount.size() > 0 && listAccount[0].Nationality__c != null) {
            userNationality = getCountryGroupOfCustomer(listAccount[0].Nationality__c);
        } else{
            userNationality = 'Other';
        }
        mapAllBookingUnits = getAllRelatedBookingUnits(accountId);
        if (mapAllBookingUnits != null && !mapAllBookingUnits.isEmpty()) {
            list < SelectOption > lstBookingUnits = new list < SelectOption > ();
            lstBookingUnits.add(new SelectOption('', '--NONE--'));
            for (Booking_Unit__c objUnit: mapAllBookingUnits.values()) {
                lstBookingUnits.add(new SelectOption(objUnit.Id, objUnit.Unit_Details__c));
            }
            return lstBookingUnits;
        }
        return null;
    }

    public list < SelectOption > getBuyerList() {

        List < Joint_Buyer__c > listBuyer = [Select Id, Account__r.Name from Joint_Buyer__c where Booking__c =: selectedUnit.Booking__c];
        if (listBuyer != null && !listBuyer.isEmpty()) {
            list < SelectOption > lstBuyer = new list < SelectOption > ();
            for (Joint_Buyer__c buyer: listBuyer) {
                lstBuyer.add(new SelectOption(buyer.Account__r.Name, buyer.Account__r.Name));
            }
            return lstBuyer;
        }
        return null;
    }

    public void next() {
        if (renderUnitDetails) {
            renderOtherDetails = true;
        }
    }

    public void getBookinUnitDetails() {

        caseRecord = new Case();
        poaAttachmentWrapper = new AttachmenWrapper();
        crfAttachmentWrapper = new AttachmenWrapper();
        titleDeedAttachmentWrapper = new AttachmenWrapper();
        passportAttachmentWrapper = new AttachmenWrapper();
        additionalAttachmentWrapper = new AttachmenWrapper();
        listAttachmentWrapper = new List < AttachmenWrapper > ();

        if (bookingUnitId != null) {

            for( Case objCase : PenaltyWaiverUtility.getAllRelatedCases( bookingUnitId ) ) { 
                if( String.isNotBlank( objCase.Status ) && objCase.Status.equalsIgnoreCase( 'Closed' ) ) {
                    lstClosedCases.add( objCase );
                }
                else {
                    lstOpenCases.add( objCase );
                }
            }
            
            selectedUnit = mapAllBookingUnits.get(bookingUnitId);

            numberOfBuyer = Math.abs(Integer.valueOf(selectedUnit.Unit_Selling_Price_AED__c) / 1000000);
            if (numberOfBuyer > 1) {
                buyerMultiselect = true;
            }
            if (selectedUnit != null) {
                //bookingUnitWrapper = PenaltyWaiverService.getBookingUnitDetails(selectedUnit);
                try {
                    bookingUnitWrapper = PenaltyWaiverService.getBookingUnitDetails(selectedUnit);
                } catch (Exception e) {
                    strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + e.getMessage();
                }                   
                renderUnitDetails = true;
                renderOtherDetails = true;
            }
            caseRecord = getExistingOpenCase(bookingUnitId, accountId);
            if (caseRecord.Id != null) {
                isSaveAsDraft = true;
                isPOAPresent = caseRecord.IsPOA__c;
                populateCaseAttachments(caseRecord.Id);
                populateBuyerList();
                loadNOC();

                if (caseRecord.POA_Expiry_Date__c != null) {
                    Datetime dt = Datetime.newInstance(caseRecord.POA_Expiry_Date__c.year(), caseRecord.POA_Expiry_Date__c.month(), caseRecord.POA_Expiry_Date__c.day());
                    poaDateOfExpiry = dt.format('MM/dd/yyyy');
                }
            }
        }
    }

    public void changePOACheckbox() {
        isPOAPresent = false;
        if (caseRecord.IsPOA__c) {
            isPOAPresent = true;
        }
        poaDateOfExpiry = '';
        caseRecord.POA_Name__c = '';
        caseRecord.POA_Relationship_with_Buyer__c = '';
        caseRecord.POA_Expiry_Date__c = null;
        caseRecord.POA_Issued_By__c = '';
        caseRecord.Purpose_of_POA__c = '';
        poaAttachmentWrapper = new AttachmenWrapper();
    }

    public void submitCase() {
        try {
            verifyBuyer();
            populateBuyerList();
            if (!isSaveAsDraft) {
                populateCaseData();
                Boolean isNewCase = caseRecord.Id == null ? true : false;
                caseRecord.Status = 'Submitted';
                upsert caseRecord;
                uploadAttachments();

                if (isNewCase) {
                    SR_Booking_Unit__c objJunction = new SR_Booking_Unit__c();
                    objJunction.Booking_Unit__c = bookingUnitId;
                    objJunction.Case__c = caseRecord.Id;
                    insert objJunction;
                }
            } else {
                caseRecord.Status = 'Submitted';
                upsert caseRecord;
            }
            strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK + 'NOC Visa request has been raised.';
        } catch (Exception e) {
            strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + e.getMessage();
        }
    }

    public void verifyBuyer() {
        if (caseRecord.Buyer_For_NOC__c != null && caseRecord.Buyer_For_NOC__c != '') {
            String buyer = caseRecord.Buyer_For_NOC__c;
            buyer = buyer.replace('[,', '');
            buyer = buyer.replace('[', '');
            buyer = buyer.replace(',]', '');
            buyer = buyer.replace(']', '');
            caseRecord.Buyer_For_NOC__c = buyer;
        }
    }

    public void populateBuyerList() {
        if (caseRecord.Buyer_For_NOC__c != null && caseRecord.Buyer_For_NOC__c != '') {
            String buyer = caseRecord.Buyer_For_NOC__c;
            buyerNameList = buyer.split(',');
        }

    }

    public void saveAsDraft() {
        System.debug('bookingUnitId >>> ' + bookingUnitId);
        populateCaseData();
        verifyBuyer();
        Boolean isNewCase = caseRecord.Id == null ? true : false;
        upsert caseRecord;
        uploadAttachments();

        if (isNewCase) {
            SR_Booking_Unit__c objJunction = new SR_Booking_Unit__c();
            objJunction.Booking_Unit__c = bookingUnitId;
            objJunction.Case__c = caseRecord.Id;
            insert objJunction;
        }

        strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK + 'Information saved successfully. ';//Case Name : ' + caseRecord.Id;
        //strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK + 'NOC for VISA has been generated.';
    }

    public void loadNOC() {
        listNOCforVisa = new list < SR_Attachments__c > ();
        List < SR_Attachments__c > listCaseAttach = [SELECT Id, Case__c, Description__c, Name, View__c, Attachment__c, Type__c, IsValid__c
            FROM SR_Attachments__c
            WHERE Case__c =: caseRecord.Id and Type__c = 'NOC For VISA'
            ORDER BY CreatedDate DESC
        ];
        if (listCaseAttach != null && listCaseAttach.size() > 0) {
            for (SR_Attachments__c srAttachment: listCaseAttach) {
                listNOCforVisa.add(srAttachment);
            }
        }
    }

    public void generateNOC() {
        caseRecord.Is_NOC_For_Visa_Generated__c = true;
        update caseRecord;
        listNOCforVisa = new List < SR_Attachments__c > ();
        List < Attachment > listAttachment = new List < Attachment > ();
        For(String buyerName: buyerNameList) {
            SR_Attachments__c srAttach = createCaseAttachment('NOC For VISA', buyerName + ' NOC');
            srAttach.Description__c = buyerName;
            listNOCforVisa.add(srAttach);

            PageReference nocVisaPage = Page.NOCForVisa;
            Blob pdfBlob = nocVisaPage.getContent();

            Attachment attach = new Attachment();
            attach.body = pdfBlob;
            String finalName = buyerName.replaceAll(' ', '_');
            attach.Name = finalName + '_NOC.doc';
            listAttachment.add(attach);
        }
        insert listNOCforVisa;
        Integer counter = 0;
        for (Attachment attach: listAttachment) {
            attach.parentId = listNOCforVisa[counter].Id;
            counter++;
        }
        insert listAttachment;

        counter = 0;
        for (Attachment attach: listAttachment) {
            listNOCforVisa[counter].Attachment__c = attach.Id;
            counter++;
        }
        update listNOCforVisa;
    }

    public PageReference closeCase() {
        caseRecord.Status = 'Closed';
        update caseRecord;

        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void uploadAttachments() {
        list < Attachment > listAttachment = new List < Attachment > ();
        List < SR_Attachments__c > listCaseAttachment = new List < SR_Attachments__c > ();

        // Inserting POA attachments
        if (String.isNotBlank(poaAttachmentWrapper.attachmentBody) && String.isNotBlank(poaAttachmentWrapper.attachmentName)) {
            SR_Attachments__c srAttach = createCaseAttachment('Power of Attorney', poaAttachmentWrapper.attachmentName);
            poaAttachmentWrapper.srAttachment = srAttach;
            listCaseAttachment.add(srAttach);
            listAttachment.add(uploadAttachment(poaAttachmentWrapper.attachmentName, extractBody(poaAttachmentWrapper.attachmentBody)));
            poaAttachmentWrapper.isPresent = true;
            caseRecord.Is_POA_Uploaded__c = true;
        }

        // Inserting CRF attachments
        if (String.isNotBlank(crfAttachmentWrapper.attachmentBody) && String.isNotBlank(crfAttachmentWrapper.attachmentName)) {
            SR_Attachments__c srAttach = createCaseAttachment('Customer Request Form', crfAttachmentWrapper.attachmentName);
            crfAttachmentWrapper.srAttachment = srAttach;
            listCaseAttachment.add(srAttach);
            listAttachment.add(uploadAttachment(crfAttachmentWrapper.attachmentName, extractBody(crfAttachmentWrapper.attachmentBody)));
            crfAttachmentWrapper.isPresent = true;
            caseRecord.Is_CRF_Uploaded__c = true;
        }

        // Inserting title deed attachments
        if (String.isNotBlank(titleDeedAttachmentWrapper.attachmentBody) && String.isNotBlank(titleDeedAttachmentWrapper.attachmentName)) {
            SR_Attachments__c srAttach = createCaseAttachment('Title Deed', titleDeedAttachmentWrapper.attachmentName);
            titleDeedAttachmentWrapper.srAttachment = srAttach;
            listCaseAttachment.add(srAttach);
            listAttachment.add(uploadAttachment(titleDeedAttachmentWrapper.attachmentName, extractBody(titleDeedAttachmentWrapper.attachmentBody)));
            titleDeedAttachmentWrapper.isPresent = true;
            listAttachmentWrapper.add(titleDeedAttachmentWrapper);
        }

        // Inserting passport attachments
        if (String.isNotBlank(passportAttachmentWrapper.attachmentBody) && String.isNotBlank(passportAttachmentWrapper.attachmentName)) {
            SR_Attachments__c srAttach = createCaseAttachment('Passport', passportAttachmentWrapper.attachmentName);
            passportAttachmentWrapper.srAttachment = srAttach;
            listCaseAttachment.add(srAttach);
            listAttachment.add(uploadAttachment(passportAttachmentWrapper.attachmentName, extractBody(passportAttachmentWrapper.attachmentBody)));
            passportAttachmentWrapper.isPresent = true;
            listAttachmentWrapper.add(passportAttachmentWrapper);
        }

        // Inserting additional attachments
        if (String.isNotBlank(additionalAttachmentWrapper.attachmentBody) && String.isNotBlank(additionalAttachmentWrapper.attachmentName)) {
            String attachmentType = '';
            if (userNationality.equals('UAE/KSA')) {
                attachmentType = 'Emirates ID';
            } else if (userNationality.equals('GCC')) {
                attachmentType = 'GCC ID';
            } else {
                attachmentType = 'Entry Visa Stamp';
            }
            SR_Attachments__c srAttach = createCaseAttachment(attachmentType, additionalAttachmentWrapper.attachmentName);
            additionalAttachmentWrapper.srAttachment = srAttach;
            listCaseAttachment.add(srAttach);
            listAttachment.add(uploadAttachment(additionalAttachmentWrapper.attachmentName, extractBody(additionalAttachmentWrapper.attachmentBody)));
            additionalAttachmentWrapper.isPresent = true;
            listAttachmentWrapper.add(additionalAttachmentWrapper);
        }

        if (listCaseAttachment.size() > 0) { 
            insert listCaseAttachment;
            Integer counter = 0;
            for (SR_Attachments__c caseAttachment: listCaseAttachment) {
                listAttachment[counter].parentId = caseAttachment.id;
                counter++;
            }
            insert listAttachment;

            counter = 0;
            for (SR_Attachments__c caseAttachment: listCaseAttachment) {
                caseAttachment.Attachment__c = listAttachment[counter].id;
                counter++;
            }
            update listCaseAttachment;

            populateMapValues(poaAttachmentWrapper);
            populateMapValues(crfAttachmentWrapper);
            populateMapValues(titleDeedAttachmentWrapper);
            populateMapValues(passportAttachmentWrapper);
            populateMapValues(additionalAttachmentWrapper);

            nullifyAttachment(poaAttachmentWrapper);
            nullifyAttachment(crfAttachmentWrapper);
            nullifyAttachment(titleDeedAttachmentWrapper);
            nullifyAttachment(passportAttachmentWrapper);
            nullifyAttachment(additionalAttachmentWrapper);
        }

    }

    public SR_Attachments__c createCaseAttachment(String attachType, String name) {
        SR_Attachments__c objCustAttach = new SR_Attachments__c();
        objCustAttach.Case__c = caseRecord.Id;
        objCustAttach.Type__c = attachType;
        objCustAttach.Name = name;
        if (attachType != 'Power of Attorney') {
            objCustAttach.isValid__c = true;
        }
        return objCustAttach;
    }

    public void nullifyAttachment(AttachmenWrapper attachmentWrapper) {
        attachmentWrapper.attachmentBody = '';
        attachmentWrapper.attachmentName = '';
    }

    public void populateMapValues(AttachmenWrapper attachWrap) {
        if (attachWrap.isPresent) {
            mapIdAttachmentWrapper.put(attachWrap.srAttachment.Id, attachWrap);
        }
    }

    public void deleteAttachment() {
        AttachmenWrapper attachWrapper = mapIdAttachmentWrapper != null && mapIdAttachmentWrapper.containsKey(deleteAttRecId) ? mapIdAttachmentWrapper.get(deleteAttRecId) : null;
        if (attachWrapper != null) {

            try {
                strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK + ' Document for ' + attachWrapper.srAttachment.Type__c + ' deleted successfully.';
                delete attachWrapper.srAttachment;
                deleteAttRecId = null;

                populateCaseAttachments(caseRecord.Id);
            } catch (Exception e) {
                strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + ' Exception generated while deleting the attachment ' + e.getMessage();
            }
        }
    }

    private void populateCaseData() {
        caseRecord.AccountId = accountId;
        system.debug('bookingUnitId : '+bookingUnitId);
        system.debug('caseRecord.IsPOA__c : '+caseRecord.IsPOA__c);

        caseRecord.Booking_Unit__c = bookingUnitId;
        caseRecord.RecordTypeId = getRecordTypeId('NOC_For_Visa', 'Case');
        caseRecord.Status = 'New';
        if (!caseRecord.IsPOA__c) {
            poaDateOfExpiry = '';
            caseRecord.POA_Name__c = '';
            caseRecord.POA_Relationship_with_Buyer__c = '';
            caseRecord.POA_Expiry_Date__c = null;
            caseRecord.POA_Issued_By__c = '';
            caseRecord.Purpose_of_POA__c = '';
            nullifyAttachment(poaAttachmentWrapper);
        }
        if (poaDateOfExpiry != null && poaDateOfExpiry != '') {
            caseRecord.POA_Expiry_Date__c = Date.parse(poaDateOfExpiry);
        }
    }

    public void insertStatementOfAccount() {
        try {
            // insert SOA

            String strRegId = bookingUnitWrapper.strRegID;
            system.debug('strRegId : '+strRegId);
            GenerateSOAController.soaResponse strResponse = GenerateSOAController.getSOADocument(strRegId);
            system.debug('SOA generated status '+strResponse.status);
            system.debug('SOA generated url'+strResponse.url);
            if(String.isBlank(strResponse.url) || 
               strResponse.url == null ) {
                strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK + ' SOA was not found'; 
            }else {
                soaUrl = strResponse.url;
            }
            //strDisplayMessage = PenaltyWaiverUtility.SPAN_TICK + ' Statement of account generated successfully.';
        } catch (Exception e) {
            strDisplayMessage = PenaltyWaiverUtility.SPAN_CROSS + e.getMessage();
        }
    }

    private static String getCountryGroupOfCustomer(String strNationality) {
        if (setGCCCountries.contains(strNationality)) {
            return 'GCC';
        } else if (strNationality != null) {
            return 'UAE/KSA';
        }
        return 'Other';
    }

    public static map < Id, Booking_Unit__c > getAllRelatedBookingUnits(Id accountId) {
        return new map < Id, Booking_Unit__c > ([SELECT Id, Name, Registration_ID__c,Property_Name__c,Property_Name_Inventory__c
                                                 , Inventory__r.Unit_Plan__c , Inventory__r.Floor_Plan__c,JOPD_Area__c
                                                 , DP_OK__c, Doc_OK__c ,Early_Handover__c,Handover_Flag__c,PCC_Release__c
                                                 , Dispute_Flag__c, OQOOD_Reg_Flag__c, Bedroom_Type__c,Plot_Price__c 
                                                 , Permitted_Use__c, PCC_Generate__c, Token_Amount_val__c , Agreement_Date__c
                                                 , Rental_Pool_Agreement__c, Token_Amount__c, Requested_Token_Amount__c
                                                 , Booking__c, Booking__r.Account__c, Booking_Unit_No__c, Unit_Details__c
                                                 , Booking__r.CreatedDate , Mortgage__c
                                                 , Booking_Unit_Type__c, Unit_Location__c, Building_Name__c, Penalty_Amount__c
                                                 , CreatedDate, Unit_Selling_Price_AED__c,Booking_Type__c
                                                 , Inventory__c , Inventory__r.Property_City__c , Inventory__r.Bedroom_Type__c
                                                 , Inventory__r.Unit_Type__c , Inventory__r.Property_Status__c,Unit_Selling_Price__c,Inventory_Area__c
                                                FROM Booking_Unit__c
                                                WHERE Booking__r.Account__c =: accountId
                                                AND Unit_Selling_Price_AED__c > 1000000
                                                AND Title_Deed__c = true
        ]);
    }

    public static Case getExistingOpenCase(Id bookingUnitId, Id accountId) {
        list < SR_Booking_Unit__c > lstexistingOpenCases = [SELECT Id, Booking_Unit__c, Case__c, Excess_Amount_Refund_Liability_AED__c, Is_Bulk_Deal__c, SR__c, Unit_Status__c
            FROM SR_Booking_Unit__c
            WHERE Booking_Unit__c =: bookingUnitId
            AND Case__r.AccountId =: accountId
            AND Case__r.Approval_Status__c != 'Approved'
            AND Case__r.RecordTypeId =: getRecordTypeId('NOC_For_Visa', 'Case')
            ORDER BY CreatedDate DESC
        ];
        if (lstexistingOpenCases != null && !lstexistingOpenCases.isEmpty()) {
            return getCaseDetails(lstexistingOpenCases[0].Case__c);
        }
        return new Case();
    }

    public void populateCaseAttachments(Id caseId) {
        List < SR_Attachments__c > listCaseAttach = [SELECT Id, Case__c, Name, View__c, Attachment__c, Type__c, IsValid__c
            FROM SR_Attachments__c
            WHERE Case__c =: caseId
            ORDER BY CreatedDate DESC
        ];
        poaAttachmentWrapper = new AttachmenWrapper();
        crfAttachmentWrapper = new AttachmenWrapper();
        titleDeedAttachmentWrapper = new AttachmenWrapper();
        passportAttachmentWrapper = new AttachmenWrapper();
        additionalAttachmentWrapper = new AttachmenWrapper();
        listAttachmentWrapper = new List < AttachmenWrapper > ();
        if (listCaseAttach != null && listCaseAttach.size() > 0) {

            for (SR_Attachments__c srAttachment: listCaseAttach) {
                if (srAttachment.Type__c != null && srAttachment.Type__c.equalsIgnoreCase('Power of Attorney')) {
                    poaAttachmentWrapper = new AttachmenWrapper(srAttachment);
                    populateMapValues(poaAttachmentWrapper);
                }

                if (srAttachment.Type__c != null && srAttachment.Type__c.equalsIgnoreCase('Customer Request Form')) {
                    crfAttachmentWrapper = new AttachmenWrapper(srAttachment);
                    populateMapValues(crfAttachmentWrapper);
                }

                if (srAttachment.Type__c != null && srAttachment.Type__c.equalsIgnoreCase('Title Deed')) {
                    titleDeedAttachmentWrapper = new AttachmenWrapper(srAttachment);
                    listAttachmentWrapper.add(titleDeedAttachmentWrapper);
                    populateMapValues(titleDeedAttachmentWrapper);
                }

                if (srAttachment.Type__c != null && srAttachment.Type__c.equalsIgnoreCase('Passport')) {
                    passportAttachmentWrapper = new AttachmenWrapper(srAttachment);
                    listAttachmentWrapper.add(passportAttachmentWrapper);
                    populateMapValues(passportAttachmentWrapper);
                }

                if (srAttachment.Type__c != null && (srAttachment.Type__c.equalsIgnoreCase('Emirates ID') || srAttachment.Type__c.equalsIgnoreCase('GCC ID') || srAttachment.Type__c.equalsIgnoreCase('Entry Visa Stamp'))) {
                    additionalAttachmentWrapper = new AttachmenWrapper(srAttachment);
                    listAttachmentWrapper.add(additionalAttachmentWrapper);
                    populateMapValues(additionalAttachmentWrapper);
                }
            }
        }
    }

    public static Case getCaseDetails(Id caseId) {
        list < Case > lstCase = [SELECT Id, Amount_to_be_waived__c, Percent_to_be_waived__c
                                        , Status, Penalty_Category__c, IsPOA__c, Mode_of_Collection__c
                                        , POA_Name__c, Additional_Details__c, POA_Relationship_with_Buyer__c,Purpose_of_POA__c
                                        , POA_Expiry_Date__c, POA_Issued_By__c, Is_CRF_Uploaded__c, Origin, Buyer_For_NOC__c, Is_NOC_For_Visa_Generated__c
            FROM Case
            WHERE Id =: caseId and Status != 'Closed'
        ];
        if (lstCase != null && !lstCase.isEmpty()) {
            return lstCase[0];
        }
        return new Case();
    }

    public static Id getRecordTypeId(String strDeveloperName, String strObjectName) {
        list < RecordType > lstRecordType = [Select Id, Name, DeveloperName, SobjectType
            From RecordType
            Where DeveloperName =: strDeveloperName
            AND SobjectType =: strObjectName
            AND IsActive = true
        ];
        if (lstRecordType != null && lstRecordType.isEmpty() == false) {
            return lstRecordType[0].Id;
        }
        return null;
    }

    public Attachment uploadAttachment(String strfileName, Blob objBody) {
        Attachment objAttach = new Attachment();
        objAttach.Body = objBody;
        objAttach.Name = strfileName;
        return objAttach;
    }

    private Blob extractBody(String strBody) {
        If(strBody != null && strBody != ''){
            strBody = EncodingUtil.base64Decode(strBody).toString();
            return EncodingUtil.base64Decode(strBody.substring(strBody.lastIndexOf(',') + 1));
        }
        return EncodingUtil.base64Decode('');
    }

    public class AttachmenWrapper {

        public SR_Attachments__c srAttachment {
            get;
            set;
        }
        public Boolean isPresent {
            get;
            set;
        }
        public String attachmentBody {
            get;
            set;
        }
        public String attachmentName {
            get;
            set;
        }

        public AttachmenWrapper() {
            srAttachment = new SR_Attachments__c();
            attachmentBody = '';
            attachmentName = '';
            isPresent = false;
        }

        public AttachmenWrapper(SR_Attachments__c srAttach) {
            srAttachment = srAttach;
            attachmentBody = '';
            attachmentName = '';
            isPresent = true;
        }
    }
}