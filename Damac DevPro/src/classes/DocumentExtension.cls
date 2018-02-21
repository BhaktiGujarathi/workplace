public without sharing class DocumentExtension {
    public Id caseId;
    public Case objCase {get;set;} 
    
    public DocumentExtension(ApexPages.StandardController controller) {
        caseId = ApexPages.currentPage().getParameters().get('id');
    }

    public pageReference redirectToCase() {
        pageReference st = loaVerification();
        PageReference  pg = new PageReference ('/'+caseId);
        pg.setRedirect(true);
        return pg;
    }
    
    public pagereference loaVerification() {
        String docUrl;
        Case caseObject = [select Id, createdDate, Seller__r.Name, Seller__r.FirstName, Seller__r.LastName, 
                        Seller__r.MiddleName,Seller__r.Nationality__c, Seller__r.Passport_Number__c, Seller__r.CR_Number__c,
                        Seller__r.CR_Registration_Place__c, Seller__r.CR_Registration_Expiry_Date__c, 
                        Seller__r.Address_Line_1__c, Seller__r.Address_Line_2__c, Seller__r.Address_Line_3__c, 
                        Seller__r.Address_Line_4__c, Seller__r.City__c, Seller__r.Zip_Postal_Code__c, 
                        Seller__r.Country__c, Seller__r.Telephone__c, Seller__r.Fax__c, 
                        Seller__r.Mobile__c, Seller__r.Email__c, Booking_Unit__r.Name, 
                        Booking_Unit__r.Inventory__r.Property_Name_2__c,Booking_Unit__r.Inventory__r.Unit__c,
                        Booking_Unit__r.Agreement_Date__c, Buyer__r.First_Name__c, Buyer__r.Last_Name__c,
                        Buyer__r.Nationality__c, Buyer__r.Passport_Number__c, Buyer__r.CR_Number__c, 
                        Buyer__r.CR_Registration_Place__c, Buyer__r.CR_Registration_Expiry_Date__c,
                        Buyer__r.Address_Line_1__c, Buyer__r.Address_Line_2__c, Buyer__r.Address_Line_3__c, 
                        Buyer__r.Address_Line_4__c, Buyer__r.City__c, Buyer__r.Country__c, Buyer__r.Email__c, 
                        Booking_Unit__r.Inventory__r.Property_Country__c, Security_Cheque_Amount__c, 
                        Bounced_Cheque_Date_of_Expiry__c, Booking_Unit__r.Inventory__r.Bedroom_Type__c, 
                        Booking_Unit__r.Inventory__r.Property_Status__c, Booking_Unit__r.Inventory__r.Property_City__c,
                        Booking_Unit__r.Inventory__r.Parking__c, Booking_Unit__r.Inventory__r.Building_Name__c,
                        Booking_Unit__r.Inventory__r.Master_Community_EN__c, Booking_Unit__r.Inventory__r.Master_Developer_EN__c,
                        Booking_Unit__r.Inventory__r.Area_Sqft_2__c,
                        Payment_Verified__c, Document_Verified__c 
                        from Case where Id =: caseId];
        system.debug('caseObject=='+caseObject);
        system.debug('city=='+caseObject.Booking_Unit__r.Inventory__r.Property_City__c);
        system.debug('status=='+caseObject.Booking_Unit__r.Inventory__r.Property_Status__c);
        system.debug('bedtype=='+caseObject.Booking_Unit__r.Inventory__r.Bedroom_Type__c);
        //if(caseObject.Payment_Verified__c && caseObject.Document_Verified__c) {
            if(String.isNotBlank(caseObject.Booking_Unit__r.Inventory__r.Property_City__c) 
            && caseObject.Booking_Unit__r.Inventory__r.Property_City__c.equalsIgnorecase('Dubai') 
            && String.isNotBlank(caseObject.Booking_Unit__r.Inventory__r.Property_Status__c)
            && caseObject.Booking_Unit__r.Inventory__r.Property_Status__c.equalsIgnorecase('Ready')
            && String.isNotBlank(caseObject.Booking_Unit__r.Inventory__r.Bedroom_Type__c) 
            && !caseObject.Booking_Unit__r.Inventory__r.Bedroom_Type__c.equalsIgnorecase('Plot')) {
                docUrl = getDocUrlForLOACompletedDubai(caseObject);
            }
            else if( String.isNotBlank(caseObject.Booking_Unit__r.Inventory__r.Property_Status__c) 
            && caseObject.Booking_Unit__r.Inventory__r.Property_Status__c.equalsIgnorecase('Off Plan')
            && String.isNotBlank(caseObject.Booking_Unit__r.Inventory__r.Bedroom_Type__c)  
            && !caseObject.Booking_Unit__r.Inventory__r.Bedroom_Type__c.equalsIgnorecase('Plot')) {
                docUrl = getDocUrlForLOAOffPlan(caseObject);
            }
            else if(String.isNotBlank(caseObject.Booking_Unit__r.Inventory__r.Property_City__c) 
            && caseObject.Booking_Unit__r.Inventory__r.Property_City__c.equalsIgnorecase('Abu Dhabi')
            && String.isNotBlank(caseObject.Booking_Unit__r.Inventory__r.Property_Status__c)
            && caseObject.Booking_Unit__r.Inventory__r.Property_Status__c.equalsIgnorecase('Ready')) {
                docUrl = getDocUrlForLOAAbuDhabi(caseObject);
            }
            else if( String.isNotBlank(caseObject.Booking_Unit__r.Inventory__r.Property_City__c) 
            && caseObject.Booking_Unit__r.Inventory__r.Property_City__c.equalsIgnorecase('Dubai')
            && String.isNotBlank(caseObject.Booking_Unit__r.Inventory__r.Bedroom_Type__c)
            && caseObject.Booking_Unit__r.Inventory__r.Bedroom_Type__c.equalsIgnorecase('Plot')) {
                docUrl = getDocUrlForLOADubaiAkoya(caseObject);
            }
            else if( String.isNotBlank(caseObject.Booking_Unit__r.Inventory__r.Property_City__c)
            && caseObject.Booking_Unit__r.Inventory__r.Property_City__c.equalsIgnorecase('Qatar')
            && String.isNotBlank(caseObject.Booking_Unit__r.Inventory__r.Property_Status__c) 
            && caseObject.Booking_Unit__r.Inventory__r.Property_Status__c.equalsIgnorecase('Ready')) {
                docUrl = getDocUrlForLOAQatar(caseObject);
            }
            system.debug('docUrl=='+docUrl);
            /*SR_Attachments__c loaAttachment = new SR_Attachments__c();
            loaAttachment.Name = 'LOA Document';
            loaAttachment.isValid__c = false;
            loaAttachment.IsRequired__c = true;
            loaAttachment.Case__c = caseId;
            if(String.isNotBlank(docUrl)) {
                loaAttachment.Attachment_URL__c = docUrl;
            }
            insert loaAttachment;*/
        //}
        system.debug('docUrl**************'+docUrl);
        PageReference  pg = new PageReference (docUrl);
        pg.setRedirect(true);
        return pg;
    }

    public String getDocUrlForLOACompletedDubai(Case caseObject) {
        docgenerationDtoComXsd.DocGenDTO objDocGenDTO = new docgenerationDtoComXsd.DocGenDTO();
            objDocGenDTO.ATTRIBUTE1 = caseObject.createdDate.format('dd-MMM-yyyy');
            objDocGenDTO.ATTRIBUTE2 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE3 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE4 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE5 = caseObject.Seller__r.Nationality__c != null ? caseObject.Seller__r.Nationality__c : '' ;
            objDocGenDTO.ATTRIBUTE6 = caseObject.Seller__r.Passport_Number__c != null ? caseObject.Seller__r.Passport_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE7 = ''; //joint seller first name
            objDocGenDTO.ATTRIBUTE8 = ''; //joint seller middle name
            objDocGenDTO.ATTRIBUTE9 = ''; //joint seller last name
            objDocGenDTO.ATTRIBUTE10 = ''; //joint seller Nationality
            objDocGenDTO.ATTRIBUTE11 = ''; //joint seller passport number
            objDocGenDTO.ATTRIBUTE12 = caseObject.Seller__r.CR_Number__c != null ? caseObject.Seller__r.CR_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE13 = caseObject.Seller__r.CR_Registration_Place__c != null ? caseObject.Seller__r.CR_Registration_Place__c : '';
            objDocGenDTO.ATTRIBUTE14 = caseObject.Seller__r.CR_Registration_Expiry_Date__c != null ? String.valueOf(caseObject.Seller__r.CR_Registration_Expiry_Date__c) : ''; //registration date
            objDocGenDTO.ATTRIBUTE15 = caseObject.Seller__r.Address_Line_1__c != null ? caseObject.Seller__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE16 = caseObject.Seller__r.Address_Line_2__c != null ? caseObject.Seller__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE17 = caseObject.Seller__r.Address_Line_3__c != null ? caseObject.Seller__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE18 = caseObject.Seller__r.Address_Line_4__c != null ? caseObject.Seller__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE19 = caseObject.Seller__r.City__c != null ? caseObject.Seller__r.City__c : '';
            objDocGenDTO.ATTRIBUTE20 = caseObject.Seller__r.Zip_Postal_Code__c != null ? caseObject.Seller__r.Zip_Postal_Code__c : '';
            objDocGenDTO.ATTRIBUTE21 = caseObject.Seller__r.Country__c != null ? caseObject.Seller__r.Country__c : '';
            objDocGenDTO.ATTRIBUTE22 = caseObject.Seller__r.Telephone__c != null ? caseObject.Seller__r.Telephone__c : '';
            objDocGenDTO.ATTRIBUTE23 = caseObject.Seller__r.Fax__c != null ? caseObject.Seller__r.Fax__c : '';
            objDocGenDTO.ATTRIBUTE24 = caseObject.Seller__r.Mobile__c != null ? caseObject.Seller__r.Mobile__c : '';
            objDocGenDTO.ATTRIBUTE25 = caseObject.Seller__r.Email__c != null ? caseObject.Seller__r.Email__c : '';
            objDocGenDTO.ATTRIBUTE26 = caseObject.Booking_Unit__r.Name != null ? caseObject.Booking_Unit__r.Name : '';
            objDocGenDTO.ATTRIBUTE27 = caseObject.Booking_Unit__r.Inventory__r.Property_Name_2__c != null ? caseObject.Booking_Unit__r.Inventory__r.Property_Name_2__c : '';
            objDocGenDTO.ATTRIBUTE28 = caseObject.Booking_Unit__r.Inventory__r.Unit__c != null ? caseObject.Booking_Unit__r.Inventory__r.Unit__c : '';
            objDocGenDTO.ATTRIBUTE29 = caseObject.Booking_Unit__r.Agreement_Date__c != null ? String.valueOf(caseObject.Booking_Unit__r.Agreement_Date__c) : '';
            objDocGenDTO.ATTRIBUTE30 = caseObject.Buyer__r.First_Name__c != null ? caseObject.Buyer__r.First_Name__c : '';
            objDocGenDTO.ATTRIBUTE31 = ''; //buyer middle name
            objDocGenDTO.ATTRIBUTE32 = caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE33 = caseObject.Buyer__r.Nationality__c != null ? caseObject.Buyer__r.Nationality__c : '';
            objDocGenDTO.ATTRIBUTE34 = caseObject.Buyer__r.Passport_Number__c != null ? caseObject.Buyer__r.Passport_Number__c : '';
            objDocGenDTO.ATTRIBUTE35 = ''; //joint buyer first name
            objDocGenDTO.ATTRIBUTE36 = ''; //joint buyer middle name
            objDocGenDTO.ATTRIBUTE37 = ''; //joint buyer last name
            objDocGenDTO.ATTRIBUTE38 = ''; //joint buyer Nationality
            objDocGenDTO.ATTRIBUTE39 = ''; //joint buyer Passport number
            objDocGenDTO.ATTRIBUTE40 = caseObject.Buyer__r.CR_Number__c != null ? caseObject.Buyer__r.CR_Number__c : '';
            objDocGenDTO.ATTRIBUTE41 = caseObject.Buyer__r.CR_Registration_Place__c != null ? caseObject.Buyer__r.CR_Registration_Place__c : '';
            objDocGenDTO.ATTRIBUTE42 = caseObject.Buyer__r.CR_Registration_Expiry_Date__c != null ? String.valueOf(caseObject.Buyer__r.CR_Registration_Expiry_Date__c) : '';
            objDocGenDTO.ATTRIBUTE43 = caseObject.Buyer__r.Address_Line_1__c != null ? caseObject.Buyer__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE44 = caseObject.Buyer__r.Address_Line_2__c != null ? caseObject.Buyer__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE45 = caseObject.Buyer__r.Address_Line_3__c != null ? caseObject.Buyer__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE46 = caseObject.Buyer__r.Address_Line_4__c != null ? caseObject.Buyer__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE47 = caseObject.Buyer__r.City__c != null ? caseObject.Buyer__r.City__c : '';
            objDocGenDTO.ATTRIBUTE48 = ''; //buyer zip
            objDocGenDTO.ATTRIBUTE49 = caseObject.Buyer__r.Country__c != null ? caseObject.Buyer__r.Country__c : '';
            objDocGenDTO.ATTRIBUTE50 = ''; //buyer Telephone
            objDocGenDTO.ATTRIBUTE51 = ''; //buyer Fax
            objDocGenDTO.ATTRIBUTE52 = ''; //buyer mobile
            objDocGenDTO.ATTRIBUTE53 = caseObject.Buyer__r.Email__c != null ? caseObject.Buyer__r.Email__c : '';
            objDocGenDTO.ATTRIBUTE54 = caseObject.Seller__r.Name != null ? caseObject.Seller__r.Name : '';
            objDocGenDTO.ATTRIBUTE55 = caseObject.Buyer__r.First_Name__c != null && caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.First_Name__c+' '+caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE56 = ''; //joint assigner
            objDocGenDTO.ATTRIBUTE57 = ''; //joint assignee
            objDocGenDTO.ATTRIBUTE58 = caseObject.Booking_Unit__r.Inventory__r.Property_Country__c != null ? caseObject.Booking_Unit__r.Inventory__r.Property_Country__c : '';
            objDocGenDTO.ATTRIBUTE59 = caseObject.Bounced_Cheque_Date_of_Expiry__c != null ? String.valueOf(caseObject.Bounced_Cheque_Date_of_Expiry__c) : '';
            objDocGenDTO.ATTRIBUTE60 = ''; //confirm with kanu
            objDocGenDTO.ATTRIBUTE61 = caseObject.Security_Cheque_Amount__c != null ? String.valueOf(caseObject.Security_Cheque_Amount__c) : '';
            objDocGenDTO.ATTRIBUTE62 = ''; //retain amount
            objDocGenDTO.ATTRIBUTE63 = caseObject.Seller__r.Name != null ? caseObject.Seller__r.Name : '';
            objDocGenDTO.ATTRIBUTE64 = caseObject.Buyer__r.First_Name__c != null && caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.First_Name__c+' '+caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE65 = ''; //joint assigner
            objDocGenDTO.ATTRIBUTE66 = ''; //joint assignee
            objDocGenDTO.ATTRIBUTE67 = ''; //joint assigner
            objDocGenDTO.ATTRIBUTE68 = ''; //joint assignee
            system.debug('objDocGenDTO=='+objDocGenDTO);
            
            documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint docGen = new documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint();
            docGen.timeout_x = 120000;
            String docUrl = docGen.DocGeneration('Assignment_LOA_Completed_Project', objDocGenDTO);
            return docUrl;
    }

    public String getDocUrlForLOAOffPlan(Case caseObject) {
        docgenerationDtoComXsd.DocGenDTO objDocGenDTO = new docgenerationDtoComXsd.DocGenDTO();
            objDocGenDTO.ATTRIBUTE1 = caseObject.createdDate.format('dd-MMM-yyyy');
            objDocGenDTO.ATTRIBUTE2 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE3 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE4 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE5 = caseObject.Seller__r.Nationality__c != null ? caseObject.Seller__r.Nationality__c : '' ;
            objDocGenDTO.ATTRIBUTE6 = caseObject.Seller__r.Passport_Number__c != null ? caseObject.Seller__r.Passport_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE7 = ''; //joint seller first name
            objDocGenDTO.ATTRIBUTE8 = ''; //joint seller middle name
            objDocGenDTO.ATTRIBUTE9 = ''; //joint seller last name
            objDocGenDTO.ATTRIBUTE10 = ''; //joint seller Nationality
            objDocGenDTO.ATTRIBUTE11 = ''; //joint seller passport number
            objDocGenDTO.ATTRIBUTE12 = caseObject.Seller__r.CR_Registration_Place__c != null ? caseObject.Seller__r.CR_Registration_Place__c : '';
            objDocGenDTO.ATTRIBUTE13 = caseObject.Seller__r.CR_Number__c != null ? caseObject.Seller__r.CR_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE14 = caseObject.Seller__r.CR_Registration_Expiry_Date__c != null ? String.valueOf(caseObject.Seller__r.CR_Registration_Expiry_Date__c) : ''; //registration date
            objDocGenDTO.ATTRIBUTE15 = caseObject.Seller__r.Address_Line_1__c != null ? caseObject.Seller__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE16 = caseObject.Seller__r.Address_Line_2__c != null ? caseObject.Seller__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE17 = caseObject.Seller__r.Address_Line_3__c != null ? caseObject.Seller__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE18 = caseObject.Seller__r.Address_Line_4__c != null ? caseObject.Seller__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE19 = ''; //seller Area
            objDocGenDTO.ATTRIBUTE20 = ''; //seller POBox
            objDocGenDTO.ATTRIBUTE21 = caseObject.Seller__r.City__c != null ? caseObject.Seller__r.City__c : '';
            objDocGenDTO.ATTRIBUTE22 = caseObject.Seller__r.Zip_Postal_Code__c != null ? caseObject.Seller__r.Zip_Postal_Code__c : '';
            objDocGenDTO.ATTRIBUTE23 = caseObject.Seller__r.Country__c != null ? caseObject.Seller__r.Country__c : '';
            objDocGenDTO.ATTRIBUTE24 = caseObject.Seller__r.Mobile__c != null ? caseObject.Seller__r.Mobile__c : '';
            objDocGenDTO.ATTRIBUTE25 = caseObject.Seller__r.Fax__c != null ? caseObject.Seller__r.Fax__c : '';
            objDocGenDTO.ATTRIBUTE26 = caseObject.Seller__r.Email__c != null ? caseObject.Seller__r.Email__c : '';
            objDocGenDTO.ATTRIBUTE27 = caseObject.Buyer__r.First_Name__c != null ? caseObject.Buyer__r.First_Name__c : '';
            objDocGenDTO.ATTRIBUTE28 = ''; //buyer middle name
            objDocGenDTO.ATTRIBUTE29 = caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE30 = caseObject.Buyer__r.Nationality__c != null ? caseObject.Buyer__r.Nationality__c : '';
            objDocGenDTO.ATTRIBUTE31 = caseObject.Buyer__r.Passport_Number__c != null ? caseObject.Buyer__r.Passport_Number__c : '';
            objDocGenDTO.ATTRIBUTE32 = ''; //joint buyer first name
            objDocGenDTO.ATTRIBUTE33 = ''; //joint buyer middle name
            objDocGenDTO.ATTRIBUTE34 = ''; //joint buyer last name
            objDocGenDTO.ATTRIBUTE35 = ''; //joint buyer Nationality
            objDocGenDTO.ATTRIBUTE36 = ''; //joint buyer Passport number
            objDocGenDTO.ATTRIBUTE37 = caseObject.Buyer__r.CR_Registration_Place__c != null ? caseObject.Buyer__r.CR_Registration_Place__c : '';
            objDocGenDTO.ATTRIBUTE38 = caseObject.Buyer__r.CR_Number__c != null ? caseObject.Buyer__r.CR_Number__c : '';
            objDocGenDTO.ATTRIBUTE39 = caseObject.Buyer__r.CR_Registration_Expiry_Date__c != null ? String.valueOf(caseObject.Buyer__r.CR_Registration_Expiry_Date__c) : '';
            objDocGenDTO.ATTRIBUTE40 = caseObject.Buyer__r.Address_Line_1__c != null ? caseObject.Buyer__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE41 = caseObject.Buyer__r.Address_Line_2__c != null ? caseObject.Buyer__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE42 = caseObject.Buyer__r.Address_Line_3__c != null ? caseObject.Buyer__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE43 = caseObject.Buyer__r.Address_Line_4__c != null ? caseObject.Buyer__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE44 = ''; //Buyer Area
            objDocGenDTO.ATTRIBUTE45 = ''; //Buyer POBox
            objDocGenDTO.ATTRIBUTE46 = caseObject.Buyer__r.City__c != null ? caseObject.Buyer__r.City__c : '';
            objDocGenDTO.ATTRIBUTE47 = ''; //buyer zip
            objDocGenDTO.ATTRIBUTE48 = caseObject.Buyer__r.Country__c != null ? caseObject.Buyer__r.Country__c : '';
            objDocGenDTO.ATTRIBUTE49 = ''; //buyer mobile
            objDocGenDTO.ATTRIBUTE50 = ''; //buyer Fax
            objDocGenDTO.ATTRIBUTE51 = caseObject.Buyer__r.Email__c != null ? caseObject.Buyer__r.Email__c : '';
            objDocGenDTO.ATTRIBUTE52 = caseObject.Booking_Unit__r.Name != null ? caseObject.Booking_Unit__r.Name : '';
            objDocGenDTO.ATTRIBUTE53 = caseObject.Booking_Unit__r.Inventory__r.Parking__c != null ? caseObject.Booking_Unit__r.Inventory__r.Parking__c : '';
            objDocGenDTO.ATTRIBUTE54 = caseObject.Booking_Unit__r.Inventory__r.Building_Name__c != null ? caseObject.Booking_Unit__r.Inventory__r.Building_Name__c : '';
            objDocGenDTO.ATTRIBUTE55 = caseObject.Booking_Unit__r.Inventory__r.Master_Community_EN__c != null ? caseObject.Booking_Unit__r.Inventory__r.Master_Community_EN__c : '';
            objDocGenDTO.ATTRIBUTE56 = caseObject.Booking_Unit__r.Inventory__r.Property_Country__c != null ? caseObject.Booking_Unit__r.Inventory__r.Property_Country__c : '';
            objDocGenDTO.ATTRIBUTE57 = caseObject.Booking_Unit__r.Agreement_Date__c != null ? String.valueOf(caseObject.Booking_Unit__r.Agreement_Date__c) : '';
            objDocGenDTO.ATTRIBUTE58 = caseObject.Booking_Unit__r.Inventory__r.Master_Developer_EN__c != null ? caseObject.Booking_Unit__r.Inventory__r.Master_Developer_EN__c : '';
            objDocGenDTO.ATTRIBUTE59 = ''; //Total Purchase Price
            objDocGenDTO.ATTRIBUTE60 = ''; //Paid Purchase Price
            objDocGenDTO.ATTRIBUTE61 = ''; //Balance Purchase Price
            objDocGenDTO.ATTRIBUTE62 = ''; //Administration Fee
            objDocGenDTO.ATTRIBUTE63 = caseObject.Seller__r.Name != null ? caseObject.Seller__r.Name : '';
            objDocGenDTO.ATTRIBUTE64 = caseObject.Buyer__r.First_Name__c != null && caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.First_Name__c+' '+caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE65 = ''; //joint assigner
            objDocGenDTO.ATTRIBUTE66 = ''; //joint assignee

            system.debug('objDocGenDTO=='+objDocGenDTO);
            
            documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint docGen = new documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint();
            docGen.timeout_x = 120000;
            String docUrl = docGen.DocGeneration('AssignmentLOA_offplanunits', objDocGenDTO);
            return docUrl;
    }

    public String getDocUrlForLOAAbuDhabi(Case caseObject) {
        docgenerationDtoComXsd.DocGenDTO objDocGenDTO = new docgenerationDtoComXsd.DocGenDTO();
            objDocGenDTO.ATTRIBUTE1 = caseObject.createdDate.format('dd-MMM-yyyy');
            objDocGenDTO.ATTRIBUTE2 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE3 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE4 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE5 = caseObject.Seller__r.Address_Line_1__c != null ? caseObject.Seller__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE6 = caseObject.Seller__r.Address_Line_2__c != null ? caseObject.Seller__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE7 = caseObject.Seller__r.Address_Line_3__c != null ? caseObject.Seller__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE8 = caseObject.Seller__r.Address_Line_4__c != null ? caseObject.Seller__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE9 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE10 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE11 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE12 = caseObject.Seller__r.Nationality__c != null ? caseObject.Seller__r.Nationality__c : '' ;
            objDocGenDTO.ATTRIBUTE13 = caseObject.Seller__r.Passport_Number__c != null ? caseObject.Seller__r.Passport_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE14 = ''; //joint seller first name
            objDocGenDTO.ATTRIBUTE15 = ''; //joint seller middle name
            objDocGenDTO.ATTRIBUTE16 = ''; //joint seller last name
            objDocGenDTO.ATTRIBUTE17 = ''; //joint seller Nationality
            objDocGenDTO.ATTRIBUTE18 = ''; //joint seller passport number
            objDocGenDTO.ATTRIBUTE19 = caseObject.Seller__r.CR_Number__c != null ? caseObject.Seller__r.CR_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE20 = caseObject.Seller__r.CR_Registration_Place__c != null ? caseObject.Seller__r.CR_Registration_Place__c : '';
            objDocGenDTO.ATTRIBUTE21 = caseObject.Seller__r.CR_Registration_Expiry_Date__c != null ? String.valueOf(caseObject.Seller__r.CR_Registration_Expiry_Date__c) : ''; //registration date
            objDocGenDTO.ATTRIBUTE22 = caseObject.Seller__r.Address_Line_1__c != null ? caseObject.Seller__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE23 = caseObject.Seller__r.Address_Line_2__c != null ? caseObject.Seller__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE24 = caseObject.Seller__r.Address_Line_3__c != null ? caseObject.Seller__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE25 = caseObject.Seller__r.Address_Line_4__c != null ? caseObject.Seller__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE26 = caseObject.Seller__r.City__c != null ? caseObject.Seller__r.City__c : '';
            objDocGenDTO.ATTRIBUTE27 = caseObject.Seller__r.Zip_Postal_Code__c != null ? caseObject.Seller__r.Zip_Postal_Code__c : '';
            objDocGenDTO.ATTRIBUTE28 = caseObject.Seller__r.Country__c != null ? caseObject.Seller__r.Country__c : '';
            objDocGenDTO.ATTRIBUTE29 = caseObject.Seller__r.Telephone__c != null ? caseObject.Seller__r.Telephone__c : '';
            objDocGenDTO.ATTRIBUTE30 = caseObject.Seller__r.Fax__c != null ? caseObject.Seller__r.Fax__c : '';
            objDocGenDTO.ATTRIBUTE31 = caseObject.Seller__r.Mobile__c != null ? caseObject.Seller__r.Mobile__c : '';
            objDocGenDTO.ATTRIBUTE32 = caseObject.Seller__r.Email__c != null ? caseObject.Seller__r.Email__c : '';
            objDocGenDTO.ATTRIBUTE33 = caseObject.Booking_Unit__r.Name != null ? caseObject.Booking_Unit__r.Name : '';
            objDocGenDTO.ATTRIBUTE34 = caseObject.Booking_Unit__r.Inventory__r.Area_Sqft_2__c != null ? String.valueOf(caseObject.Booking_Unit__r.Inventory__r.Area_Sqft_2__c) : '';
            objDocGenDTO.ATTRIBUTE35 = caseObject.Booking_Unit__r.Inventory__r.Property_Name_2__c != null ? caseObject.Booking_Unit__r.Inventory__r.Property_Name_2__c : '';
            objDocGenDTO.ATTRIBUTE36 = ''; //confirm with kanu
            objDocGenDTO.ATTRIBUTE37 = caseObject.Booking_Unit__r.Agreement_Date__c != null ? String.valueOf(caseObject.Booking_Unit__r.Agreement_Date__c) : '';
            objDocGenDTO.ATTRIBUTE38 = caseObject.Buyer__r.First_Name__c != null ? caseObject.Buyer__r.First_Name__c : '';
            objDocGenDTO.ATTRIBUTE39 = ''; //buyer middle name
            objDocGenDTO.ATTRIBUTE40 = caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE41 = caseObject.Buyer__r.Nationality__c != null ? caseObject.Buyer__r.Nationality__c : '';
            objDocGenDTO.ATTRIBUTE42 = caseObject.Buyer__r.Passport_Number__c != null ? caseObject.Buyer__r.Passport_Number__c : '';
            objDocGenDTO.ATTRIBUTE43 = ''; //joint buyer first name
            objDocGenDTO.ATTRIBUTE44 = ''; //joint buyer middle name
            objDocGenDTO.ATTRIBUTE45 = ''; //joint buyer last name
            objDocGenDTO.ATTRIBUTE46 = ''; //joint buyer Nationality
            objDocGenDTO.ATTRIBUTE47 = ''; //joint buyer Passport number
            objDocGenDTO.ATTRIBUTE48 = caseObject.Buyer__r.CR_Number__c != null ? caseObject.Buyer__r.CR_Number__c : '';
            objDocGenDTO.ATTRIBUTE49 = caseObject.Buyer__r.CR_Registration_Place__c != null ? caseObject.Buyer__r.CR_Registration_Place__c : '';
            objDocGenDTO.ATTRIBUTE50 = caseObject.Buyer__r.CR_Registration_Expiry_Date__c != null ? String.valueOf(caseObject.Buyer__r.CR_Registration_Expiry_Date__c) : '';
            objDocGenDTO.ATTRIBUTE51 = caseObject.Buyer__r.Address_Line_1__c != null ? caseObject.Buyer__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE52 = caseObject.Buyer__r.Address_Line_2__c != null ? caseObject.Buyer__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE53 = caseObject.Buyer__r.Address_Line_3__c != null ? caseObject.Buyer__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE54 = caseObject.Buyer__r.Address_Line_4__c != null ? caseObject.Buyer__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE55 = caseObject.Buyer__r.City__c != null ? caseObject.Buyer__r.City__c : '';
            objDocGenDTO.ATTRIBUTE56 = ''; //buyer zip
            objDocGenDTO.ATTRIBUTE57 = caseObject.Buyer__r.Country__c != null ? caseObject.Buyer__r.Country__c : '';
            objDocGenDTO.ATTRIBUTE58 = ''; //buyer Telephone
            objDocGenDTO.ATTRIBUTE59 = ''; //buyer Fax
            objDocGenDTO.ATTRIBUTE60 = ''; //buyer mobile
            objDocGenDTO.ATTRIBUTE61 = caseObject.Buyer__r.Email__c != null ? caseObject.Buyer__r.Email__c : '';
            objDocGenDTO.ATTRIBUTE62 = caseObject.Seller__r.Name != null ? caseObject.Seller__r.Name : '';
            objDocGenDTO.ATTRIBUTE63 = caseObject.Buyer__r.First_Name__c != null && caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.First_Name__c+' '+caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE64 = ''; //Joint Lesee
            objDocGenDTO.ATTRIBUTE65 = ''; //New Joint Lesee

            system.debug('objDocGenDTO=='+objDocGenDTO);

            documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint docGen = new documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint();
            docGen.timeout_x = 120000;
            String docUrl = docGen.DocGeneration('AssignmentLOA_Completed_AbuDhabi', objDocGenDTO);
            return docUrl;
    }

    public String getDocUrlForLOADubaiAkoya(Case caseObject) {
        docgenerationDtoComXsd.DocGenDTO objDocGenDTO = new docgenerationDtoComXsd.DocGenDTO();
            objDocGenDTO.ATTRIBUTE1 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE2 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE3 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE4 = caseObject.Seller__r.Nationality__c != null ? caseObject.Seller__r.Nationality__c : '' ;
            objDocGenDTO.ATTRIBUTE5 = caseObject.Seller__r.Passport_Number__c != null ? caseObject.Seller__r.Passport_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE6 = ''; //joint seller first name
            objDocGenDTO.ATTRIBUTE7 = ''; //joint seller middle name
            objDocGenDTO.ATTRIBUTE8 = ''; //joint seller last name
            objDocGenDTO.ATTRIBUTE9 = ''; //joint seller Nationality
            objDocGenDTO.ATTRIBUTE10 = ''; //joint seller passport number
            objDocGenDTO.ATTRIBUTE11 = caseObject.Seller__r.CR_Registration_Place__c != null ? caseObject.Seller__r.CR_Registration_Place__c : '';
            objDocGenDTO.ATTRIBUTE12 = caseObject.Seller__r.CR_Number__c != null ? caseObject.Seller__r.CR_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE13 = caseObject.Seller__r.CR_Registration_Expiry_Date__c != null ? String.valueOf(caseObject.Seller__r.CR_Registration_Expiry_Date__c) : ''; //registration date
            objDocGenDTO.ATTRIBUTE14 = caseObject.Seller__r.Address_Line_1__c != null ? caseObject.Seller__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE15 = caseObject.Seller__r.Address_Line_2__c != null ? caseObject.Seller__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE16 = caseObject.Seller__r.Address_Line_3__c != null ? caseObject.Seller__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE17 = caseObject.Seller__r.Address_Line_4__c != null ? caseObject.Seller__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE18 = ''; //seller Area
            objDocGenDTO.ATTRIBUTE19 = ''; //seller POBox
            objDocGenDTO.ATTRIBUTE20 = caseObject.Seller__r.City__c != null ? caseObject.Seller__r.City__c : '';
            objDocGenDTO.ATTRIBUTE21 = caseObject.Seller__r.Zip_Postal_Code__c != null ? caseObject.Seller__r.Zip_Postal_Code__c : '';
            objDocGenDTO.ATTRIBUTE22 = caseObject.Seller__r.Country__c != null ? caseObject.Seller__r.Country__c : '';
            objDocGenDTO.ATTRIBUTE23 = caseObject.Seller__r.Mobile__c != null ? caseObject.Seller__r.Mobile__c : '';
            objDocGenDTO.ATTRIBUTE24 = caseObject.Seller__r.Fax__c != null ? caseObject.Seller__r.Fax__c : '';
            objDocGenDTO.ATTRIBUTE25 = caseObject.Seller__r.Email__c != null ? caseObject.Seller__r.Email__c : '';
            objDocGenDTO.ATTRIBUTE26 = caseObject.Buyer__r.First_Name__c != null ? caseObject.Buyer__r.First_Name__c : '';
            objDocGenDTO.ATTRIBUTE27 = ''; //buyer middle name
            objDocGenDTO.ATTRIBUTE28 = caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE29 = caseObject.Buyer__r.Nationality__c != null ? caseObject.Buyer__r.Nationality__c : '';
            objDocGenDTO.ATTRIBUTE30 = caseObject.Buyer__r.Passport_Number__c != null ? caseObject.Buyer__r.Passport_Number__c : '';
            objDocGenDTO.ATTRIBUTE31 = ''; //joint buyer first name
            objDocGenDTO.ATTRIBUTE32 = ''; //joint buyer middle name
            objDocGenDTO.ATTRIBUTE33 = ''; //joint buyer last name
            objDocGenDTO.ATTRIBUTE34 = ''; //joint buyer Nationality
            objDocGenDTO.ATTRIBUTE35 = ''; //joint buyer Passport number
            objDocGenDTO.ATTRIBUTE36 = caseObject.Buyer__r.CR_Registration_Place__c != null ? caseObject.Buyer__r.CR_Registration_Place__c : '';
            objDocGenDTO.ATTRIBUTE37 = caseObject.Buyer__r.CR_Number__c != null ? caseObject.Buyer__r.CR_Number__c : '';
            objDocGenDTO.ATTRIBUTE38 = caseObject.Buyer__r.CR_Registration_Expiry_Date__c != null ? String.valueOf(caseObject.Buyer__r.CR_Registration_Expiry_Date__c) : '';
            objDocGenDTO.ATTRIBUTE39 = caseObject.Buyer__r.Address_Line_1__c != null ? caseObject.Buyer__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE40 = caseObject.Buyer__r.Address_Line_2__c != null ? caseObject.Buyer__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE41 = caseObject.Buyer__r.Address_Line_3__c != null ? caseObject.Buyer__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE42 = caseObject.Buyer__r.Address_Line_4__c != null ? caseObject.Buyer__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE43 = ''; //seller Area
            objDocGenDTO.ATTRIBUTE44 = ''; //seller POBox
            objDocGenDTO.ATTRIBUTE45 = caseObject.Buyer__r.City__c != null ? caseObject.Buyer__r.City__c : '';
            objDocGenDTO.ATTRIBUTE46 = ''; //buyer zip
            objDocGenDTO.ATTRIBUTE47 = caseObject.Buyer__r.Country__c != null ? caseObject.Buyer__r.Country__c : '';
            objDocGenDTO.ATTRIBUTE48 = ''; //buyer mobile
            objDocGenDTO.ATTRIBUTE49 = ''; //buyer Fax
            objDocGenDTO.ATTRIBUTE50 = caseObject.Buyer__r.Email__c != null ? caseObject.Buyer__r.Email__c : '';
            objDocGenDTO.ATTRIBUTE51 = caseObject.Booking_Unit__r.Name != null ? caseObject.Booking_Unit__r.Name : '';
            objDocGenDTO.ATTRIBUTE52 = caseObject.Booking_Unit__r.Inventory__r.Area_Sqft_2__c != null ? String.valueOf(caseObject.Booking_Unit__r.Inventory__r.Area_Sqft_2__c) : '';
            objDocGenDTO.ATTRIBUTE53 = caseObject.Booking_Unit__r.Inventory__r.Building_Name__c != null ? caseObject.Booking_Unit__r.Inventory__r.Building_Name__c : '';
            objDocGenDTO.ATTRIBUTE54 = 'Akoya by Damac';
            objDocGenDTO.ATTRIBUTE55 = caseObject.Booking_Unit__r.Inventory__r.Property_Country__c != null ? caseObject.Booking_Unit__r.Inventory__r.Property_Country__c : '';
            objDocGenDTO.ATTRIBUTE56 = caseObject.Booking_Unit__r.Agreement_Date__c != null ? String.valueOf(caseObject.Booking_Unit__r.Agreement_Date__c) : '';
            objDocGenDTO.ATTRIBUTE57 = caseObject.Booking_Unit__r.Inventory__r.Master_Developer_EN__c != null ? caseObject.Booking_Unit__r.Inventory__r.Master_Developer_EN__c : '';
            objDocGenDTO.ATTRIBUTE58 = caseObject.Seller__r.Name != null ? caseObject.Seller__r.Name : '';
            objDocGenDTO.ATTRIBUTE59 = caseObject.Buyer__r.First_Name__c != null && caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.First_Name__c+' '+caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE60 = ''; //Joint Assignor
            objDocGenDTO.ATTRIBUTE61 = ''; //Joint Assignee
            objDocGenDTO.ATTRIBUTE62 = ''; //Total Purchase Price
            objDocGenDTO.ATTRIBUTE63 = ''; //Paid Purchase Price
            objDocGenDTO.ATTRIBUTE64 = ''; //Balance Purchase Price
            objDocGenDTO.ATTRIBUTE65 = ''; //Administration Fee
            
            system.debug('objDocGenDTO=='+objDocGenDTO);

            documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint docGen = new documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint();
            docGen.timeout_x = 120000;
            String docUrl = docGen.DocGeneration('AssignmentLOA_PSDA_AKOYA', objDocGenDTO);
            return docUrl;
    }

    public String getDocUrlForLOAQatar(Case caseObject) {
        docgenerationDtoComXsd.DocGenDTO objDocGenDTO = new docgenerationDtoComXsd.DocGenDTO();
            objDocGenDTO.ATTRIBUTE1 = caseObject.createdDate.format('dd-MMM-yyyy');
            objDocGenDTO.ATTRIBUTE2 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE3 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE4 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE5 = caseObject.Seller__r.Address_Line_1__c != null ? caseObject.Seller__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE6 = caseObject.Seller__r.Address_Line_2__c != null ? caseObject.Seller__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE7 = caseObject.Seller__r.Address_Line_3__c != null ? caseObject.Seller__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE8 = caseObject.Seller__r.Address_Line_4__c != null ? caseObject.Seller__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE9 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE10 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE11 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE12 = caseObject.Seller__r.Nationality__c != null ? caseObject.Seller__r.Nationality__c : '' ;
            objDocGenDTO.ATTRIBUTE13 = caseObject.Seller__r.Passport_Number__c != null ? caseObject.Seller__r.Passport_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE14 = ''; //joint seller first name
            objDocGenDTO.ATTRIBUTE15 = ''; //joint seller middle name
            objDocGenDTO.ATTRIBUTE16 = ''; //joint seller last name
            objDocGenDTO.ATTRIBUTE17 = ''; //joint seller Nationality
            objDocGenDTO.ATTRIBUTE18 = ''; //joint seller passport number
            objDocGenDTO.ATTRIBUTE19 = caseObject.Seller__r.CR_Number__c != null ? caseObject.Seller__r.CR_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE20 = caseObject.Seller__r.CR_Registration_Place__c != null ? caseObject.Seller__r.CR_Registration_Place__c : '';
            objDocGenDTO.ATTRIBUTE21 = caseObject.Buyer__r.CR_Registration_Expiry_Date__c != null ? String.valueOf(caseObject.Buyer__r.CR_Registration_Expiry_Date__c) : '';
            objDocGenDTO.ATTRIBUTE22 = caseObject.Seller__r.Address_Line_1__c != null ? caseObject.Seller__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE23 = caseObject.Seller__r.Address_Line_2__c != null ? caseObject.Seller__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE24 = caseObject.Seller__r.Address_Line_3__c != null ? caseObject.Seller__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE25 = caseObject.Seller__r.Address_Line_4__c != null ? caseObject.Seller__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE26 = caseObject.Seller__r.City__c != null ? caseObject.Seller__r.City__c : '';
            objDocGenDTO.ATTRIBUTE27 = caseObject.Seller__r.Zip_Postal_Code__c != null ? caseObject.Seller__r.Zip_Postal_Code__c : '';
            objDocGenDTO.ATTRIBUTE28 = caseObject.Seller__r.Country__c != null ? caseObject.Seller__r.Country__c : '';
            objDocGenDTO.ATTRIBUTE29 = caseObject.Seller__r.Telephone__c != null ? caseObject.Seller__r.Telephone__c : '';
            objDocGenDTO.ATTRIBUTE30 = caseObject.Seller__r.Fax__c != null ? caseObject.Seller__r.Fax__c : '';
            objDocGenDTO.ATTRIBUTE31 = caseObject.Seller__r.Mobile__c != null ? caseObject.Seller__r.Mobile__c : '';
            objDocGenDTO.ATTRIBUTE32 = caseObject.Seller__r.Email__c != null ? caseObject.Seller__r.Email__c : '';
            objDocGenDTO.ATTRIBUTE33 = caseObject.Booking_Unit__r.Name != null ? caseObject.Booking_Unit__r.Name : '';
            objDocGenDTO.ATTRIBUTE34 = caseObject.Booking_Unit__r.Inventory__r.Property_Name_2__c != null ? caseObject.Booking_Unit__r.Inventory__r.Property_Name_2__c : '';
            objDocGenDTO.ATTRIBUTE35 = caseObject.Booking_Unit__r.Inventory__r.Building_Name__c != null ? caseObject.Booking_Unit__r.Inventory__r.Building_Name__c : '';
            objDocGenDTO.ATTRIBUTE36 = caseObject.Booking_Unit__r.Agreement_Date__c != null ? String.valueOf(caseObject.Booking_Unit__r.Agreement_Date__c) : '';
            objDocGenDTO.ATTRIBUTE37 = caseObject.Buyer__r.First_Name__c != null ? caseObject.Buyer__r.First_Name__c : '';
            objDocGenDTO.ATTRIBUTE38 = ''; //buyer middle name
            objDocGenDTO.ATTRIBUTE39 = caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE40 = caseObject.Buyer__r.Nationality__c != null ? caseObject.Buyer__r.Nationality__c : '';
            objDocGenDTO.ATTRIBUTE41 = caseObject.Buyer__r.Passport_Number__c != null ? caseObject.Buyer__r.Passport_Number__c : '';
            objDocGenDTO.ATTRIBUTE42 = ''; //joint buyer first name
            objDocGenDTO.ATTRIBUTE43 = ''; //joint buyer middle name
            objDocGenDTO.ATTRIBUTE44 = ''; //joint buyer last name
            objDocGenDTO.ATTRIBUTE45 = ''; //joint buyer Nationality
            objDocGenDTO.ATTRIBUTE46 = ''; //joint buyer Passport number
            objDocGenDTO.ATTRIBUTE47 = caseObject.Buyer__r.CR_Number__c != null ? caseObject.Buyer__r.CR_Number__c : '';
            objDocGenDTO.ATTRIBUTE48 = caseObject.Buyer__r.CR_Registration_Place__c != null ? caseObject.Buyer__r.CR_Registration_Place__c : '';
            objDocGenDTO.ATTRIBUTE49 = caseObject.Buyer__r.CR_Registration_Expiry_Date__c != null ? String.valueOf(caseObject.Buyer__r.CR_Registration_Expiry_Date__c) : '';
            objDocGenDTO.ATTRIBUTE50 = caseObject.Buyer__r.Address_Line_1__c != null ? caseObject.Buyer__r.Address_Line_1__c : '';
            objDocGenDTO.ATTRIBUTE51 = caseObject.Buyer__r.Address_Line_2__c != null ? caseObject.Buyer__r.Address_Line_2__c : '';
            objDocGenDTO.ATTRIBUTE52 = caseObject.Buyer__r.Address_Line_3__c != null ? caseObject.Buyer__r.Address_Line_3__c : '';
            objDocGenDTO.ATTRIBUTE53 = caseObject.Buyer__r.Address_Line_4__c != null ? caseObject.Buyer__r.Address_Line_4__c : '';
            objDocGenDTO.ATTRIBUTE54 = caseObject.Buyer__r.City__c != null ? caseObject.Buyer__r.City__c : '';
            objDocGenDTO.ATTRIBUTE55 = ''; //buyer zip
            objDocGenDTO.ATTRIBUTE56 = caseObject.Buyer__r.Country__c != null ? caseObject.Buyer__r.Country__c : '';
            objDocGenDTO.ATTRIBUTE57 = ''; //buyer Telephone
            objDocGenDTO.ATTRIBUTE58 = ''; //buyer Fax
            objDocGenDTO.ATTRIBUTE59 = ''; //buyer Mobile
            objDocGenDTO.ATTRIBUTE60 = caseObject.Buyer__r.Email__c != null ? caseObject.Buyer__r.Email__c : '';
            objDocGenDTO.ATTRIBUTE61 = caseObject.Seller__r.Name != null ? caseObject.Seller__r.Name : '';
            objDocGenDTO.ATTRIBUTE62 = caseObject.Buyer__r.First_Name__c != null && caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.First_Name__c+' '+caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE63 = ''; //Joint Lessee
            objDocGenDTO.ATTRIBUTE64 = ''; //New Joint Lessee
            
            system.debug('objDocGenDTO=='+objDocGenDTO);

            documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint docGen = new documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint();
            docGen.timeout_x = 120000;
            String docUrl = docGen.DocGeneration('AssignmentLOA_Qatar', objDocGenDTO);
            return docUrl;
    }

    public pageReference spaVerification() {
        Case caseObject = [select Id, Payment_Verified__c, Document_Verified__c from Case where Id =: caseId];
        if(caseObject.Payment_Verified__c && caseObject.Document_Verified__c) {
            SR_Attachments__c spaAttachment = new SR_Attachments__c();
            spaAttachment.Name = 'Standard SPA Document';
            spaAttachment.isValid__c = false;
            spaAttachment.IsRequired__c = true;
            spaAttachment.Case__c = caseId;
            insert spaAttachment;
        }
      
        PageReference  pg = new PageReference ('/'+caseId);
        pg.setRedirect(true);
        return pg;
    }

    public pageReference leaseVerification() {
        Case caseObject = [select Id, Payment_Verified__c, Document_Verified__c from Case where Id =: caseId];
        if(caseObject.Payment_Verified__c && caseObject.Document_Verified__c) {
            SR_Attachments__c spaAttachment = new SR_Attachments__c();
            spaAttachment.Name = 'Standard Lease Agreement Document';
            spaAttachment.isValid__c = false;
            spaAttachment.IsRequired__c = true;
            spaAttachment.Case__c = caseId;
            insert spaAttachment;
        }

        PageReference  pg = new PageReference ('/'+caseId);
        pg.setRedirect(true);
        return pg;
    }

    public pageReference generateConfirmationLetter() {
        Case caseObject = [select Id, Payment_Verified__c, Document_Verified__c, Document_Sent__c from Case where Id =: caseId];
        if(caseObject.Payment_Verified__c && caseObject.Document_Verified__c) {
            SR_Attachments__c confirmationAttachment = new SR_Attachments__c();
            confirmationAttachment.Name = 'Confirmation Letter';
            confirmationAttachment.isValid__c = true;
            confirmationAttachment.IsRequired__c = true;
            confirmationAttachment.Case__c = caseId;
            insert confirmationAttachment;

            caseObject.Document_Sent__c = true;
            update caseObject;
        }

        PageReference  pg = new PageReference ('/'+caseId);
        pg.setRedirect(true);
        return pg;
    }

    public pageReference generateReceipt() {
        Case caseObject = [select Id, Payment_Verified__c, Document_Verified__c, Document_Sent__c from Case where Id =: caseId];
        if(caseObject.Payment_Verified__c && caseObject.Document_Verified__c) {
            SR_Attachments__c receiptAttachment = new SR_Attachments__c();
            receiptAttachment.Name = 'Receipt Document';
            receiptAttachment.isValid__c = true;
            receiptAttachment.IsRequired__c = true;
            receiptAttachment.Case__c = caseId;
            insert receiptAttachment;

            caseObject.Document_Sent__c = true;
            update caseObject;
        }

        PageReference  pg = new PageReference ('/'+caseId);
        pg.setRedirect(true);
        return pg;
    }

    @InvocableMethod
    public static void generateNocDoc(List<ID> ids) {
        Id nocCaseId = ids[0];
        calloutForNoc(nocCaseId);
    }

    @future(callout=true)
    public static void calloutForNoc(Id nocCaseId) {
        String docUrl;
        Case caseObject = [select Id, createdDate, Seller__r.Name, Seller__r.FirstName, Seller__r.LastName, 
                        Seller__r.MiddleName,Seller__r.Nationality__c, Seller__r.Passport_Number__c, Seller__r.CR_Number__c,
                        Seller__r.CR_Registration_Place__c, Seller__r.CR_Registration_Expiry_Date__c, 
                        Seller__r.Address_Line_1__c, Seller__r.Address_Line_2__c, Seller__r.Address_Line_3__c, 
                        Seller__r.Address_Line_4__c, Seller__r.City__c, Seller__r.Zip_Postal_Code__c, 
                        Seller__r.Country__c, Seller__r.Telephone__c, Seller__r.Fax__c, 
                        Seller__r.Mobile__c, Seller__r.Email__c, Booking_Unit__r.Name, 
                        Booking_Unit__r.Inventory__r.Property_Name_2__c,Booking_Unit__r.Inventory__r.Unit__c,
                        Booking_Unit__r.Agreement_Date__c, Buyer__r.First_Name__c, Buyer__r.Last_Name__c,
                        Buyer__r.Nationality__c, Buyer__r.Passport_Number__c, Buyer__r.CR_Number__c, 
                        Buyer__r.CR_Registration_Place__c, Buyer__r.CR_Registration_Expiry_Date__c,
                        Buyer__r.Address_Line_1__c, Buyer__r.Address_Line_2__c, Buyer__r.Address_Line_3__c, 
                        Buyer__r.Address_Line_4__c, Buyer__r.City__c, Buyer__r.Country__c, Buyer__r.Email__c, 
                        Booking_Unit__r.Inventory__r.Property_Country__c, Security_Cheque_Amount__c, 
                        Bounced_Cheque_Date_of_Expiry__c, Booking_Unit__r.Inventory__r.Bedroom_Type__c, 
                        Booking_Unit__r.Inventory__r.Property_Status__c, Booking_Unit__r.Inventory__r.Property_City__c,
                        Booking_Unit__r.Inventory__r.Parking__c, Booking_Unit__r.Inventory__r.Building_Name__c,
                        Booking_Unit__r.Inventory__r.Master_Community_EN__c, Booking_Unit__r.Inventory__r.Master_Developer_EN__c,
                        Booking_Unit__r.Inventory__r.Area_Sqft_2__c, Booking_Unit__r.Inventory__r.Plot_Number__c,
                        Booking_Unit__r.No_of_parking__c, Seller__r.IsPersonAccount,
                        Payment_Verified__c, Document_Verified__c 
                        from Case where Id =: nocCaseId];

        if(caseObject.Seller__r.IsPersonAccount 
            && caseObject.Booking_Unit__r.Inventory__r.Property_City__c.equalsIgnorecase('Dubai')
            && caseObject.Booking_Unit__r.Inventory__r.Property_Status__c.equalsIgnorecase('Ready')) {

            docgenerationDtoComXsd.DocGenDTO objDocGenDTO = new docgenerationDtoComXsd.DocGenDTO();
            objDocGenDTO.ATTRIBUTE1 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE2 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE3 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE4 = caseObject.Booking_Unit__r.Inventory__r.Property_City__c != null ? caseObject.Booking_Unit__r.Inventory__r.Property_City__c : '' ;
            objDocGenDTO.ATTRIBUTE5 = caseObject.Booking_Unit__r.Inventory__r.Plot_Number__c != null ? caseObject.Booking_Unit__r.Inventory__r.Plot_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE6 = caseObject.Booking_Unit__r.Name != null ? caseObject.Booking_Unit__r.Name : '';
            objDocGenDTO.ATTRIBUTE7 = caseObject.Booking_Unit__r.Inventory__r.Building_Name__c != null ? caseObject.Booking_Unit__r.Inventory__r.Building_Name__c : '';
            objDocGenDTO.ATTRIBUTE8 = caseObject.Booking_Unit__r.No_of_parking__c != null ? String.valueOf(caseObject.Booking_Unit__r.No_of_parking__c) : '';
            objDocGenDTO.ATTRIBUTE9 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE10 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE11 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE12 = caseObject.Seller__r.Nationality__c != null ? caseObject.Seller__r.Nationality__c : '' ;
            objDocGenDTO.ATTRIBUTE13 = caseObject.Seller__r.Passport_Number__c != null ? caseObject.Seller__r.Passport_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE14 = ''; //joint seller first name
            objDocGenDTO.ATTRIBUTE15 = ''; //joint seller middle name
            objDocGenDTO.ATTRIBUTE16 = ''; //joint seller last name
            objDocGenDTO.ATTRIBUTE17 = ''; //joint seller Nationality
            objDocGenDTO.ATTRIBUTE18 = ''; //joint seller passport number
            objDocGenDTO.ATTRIBUTE19 = caseObject.Buyer__r.First_Name__c != null ? caseObject.Buyer__r.First_Name__c : '';
            objDocGenDTO.ATTRIBUTE20 = ''; //buyer middle name
            objDocGenDTO.ATTRIBUTE21 = caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE22 = caseObject.Buyer__r.Nationality__c != null ? caseObject.Buyer__r.Nationality__c : '';
            objDocGenDTO.ATTRIBUTE23 = caseObject.Buyer__r.Passport_Number__c != null ? caseObject.Buyer__r.Passport_Number__c : '';
            objDocGenDTO.ATTRIBUTE24 = ''; //joint buyer first name
            objDocGenDTO.ATTRIBUTE25 = ''; //joint buyer middle name
            objDocGenDTO.ATTRIBUTE26 = ''; //joint buyer last name
            objDocGenDTO.ATTRIBUTE27 = ''; //joint buyer Nationality
            objDocGenDTO.ATTRIBUTE28 = ''; //joint buyer Passport number
    
            system.debug('objDocGenDTO=='+objDocGenDTO);
            
            documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint docGen = new documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint();
            docGen.timeout_x = 120000;
            docUrl = docGen.DocGeneration('AssignmentNOC_Completed', objDocGenDTO);
            system.debug('docUrl==='+docUrl);
        }
        else if(!caseObject.Seller__r.IsPersonAccount 
            && caseObject.Booking_Unit__r.Inventory__r.Property_City__c.equalsIgnorecase('Dubai')
            && caseObject.Booking_Unit__r.Inventory__r.Property_Status__c.equalsIgnorecase('Ready')) {

            docgenerationDtoComXsd.DocGenDTO objDocGenDTO = new docgenerationDtoComXsd.DocGenDTO();
            objDocGenDTO.ATTRIBUTE1 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE2 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE3 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE4 = caseObject.Booking_Unit__r.Inventory__r.Property_City__c != null ? caseObject.Booking_Unit__r.Inventory__r.Property_City__c : '' ;
            objDocGenDTO.ATTRIBUTE5 = caseObject.Booking_Unit__r.Inventory__r.Plot_Number__c != null ? caseObject.Booking_Unit__r.Inventory__r.Plot_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE6 = caseObject.Booking_Unit__r.Name != null ? caseObject.Booking_Unit__r.Name : '';
            objDocGenDTO.ATTRIBUTE7 = caseObject.Booking_Unit__r.Inventory__r.Building_Name__c != null ? caseObject.Booking_Unit__r.Inventory__r.Building_Name__c : '';
            objDocGenDTO.ATTRIBUTE8 = caseObject.Booking_Unit__r.No_of_parking__c != null ? String.valueOf(caseObject.Booking_Unit__r.No_of_parking__c) : '';
            objDocGenDTO.ATTRIBUTE9 = caseObject.Booking_Unit__r.Inventory__r.Area_Sqft_2__c != null ? String.valueOf(caseObject.Booking_Unit__r.Inventory__r.Area_Sqft_2__c) : '';
            objDocGenDTO.ATTRIBUTE10 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE11 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE12 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE13 = caseObject.Buyer__r.CR_Number__c != null ? caseObject.Buyer__r.CR_Number__c : '';
            objDocGenDTO.ATTRIBUTE14 = caseObject.Buyer__r.First_Name__c != null && caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.First_Name__c+' '+caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE15 = caseObject.Buyer__r.Nationality__c != null ? caseObject.Buyer__r.Nationality__c : '';
            objDocGenDTO.ATTRIBUTE16 = caseObject.Buyer__r.Passport_Number__c != null ? caseObject.Buyer__r.Passport_Number__c : '';
            objDocGenDTO.ATTRIBUTE17 = ''; //joint buyer name
            objDocGenDTO.ATTRIBUTE18 = ''; //joint buyer Nationality
            objDocGenDTO.ATTRIBUTE19 = ''; //joint buyer Passport number
            
            system.debug('objDocGenDTO=='+objDocGenDTO);
            documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint docGen = new documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint();
            docGen.timeout_x = 120000;
            docUrl = docGen.DocGeneration('AssignmentNOC_Organization', objDocGenDTO);
            system.debug('docUrl==='+docUrl);
        }
        else if(caseObject.Booking_Unit__r.Inventory__r.Property_City__c.equalsIgnorecase('Dubai')
            && caseObject.Booking_Unit__r.Inventory__r.Property_Status__c.equalsIgnorecase('Off Plan')) {

            docgenerationDtoComXsd.DocGenDTO objDocGenDTO = new docgenerationDtoComXsd.DocGenDTO();
            objDocGenDTO.ATTRIBUTE1 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE2 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE3 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE4 = caseObject.Booking_Unit__r.Inventory__r.Property_City__c != null ? caseObject.Booking_Unit__r.Inventory__r.Property_City__c : '' ;
            objDocGenDTO.ATTRIBUTE5 = caseObject.Booking_Unit__r.Inventory__r.Plot_Number__c != null ? caseObject.Booking_Unit__r.Inventory__r.Plot_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE6 = caseObject.Booking_Unit__r.Name != null ? caseObject.Booking_Unit__r.Name : '';
            objDocGenDTO.ATTRIBUTE7 = caseObject.Booking_Unit__r.Inventory__r.Building_Name__c != null ? caseObject.Booking_Unit__r.Inventory__r.Building_Name__c : '';
            objDocGenDTO.ATTRIBUTE8 = caseObject.Booking_Unit__r.No_of_parking__c != null ? String.valueOf(caseObject.Booking_Unit__r.No_of_parking__c) : '';
            objDocGenDTO.ATTRIBUTE9 = ''; //Purchase Price
            objDocGenDTO.ATTRIBUTE10 = caseObject.Seller__r.FirstName != null ? caseObject.Seller__r.FirstName : '' ;
            objDocGenDTO.ATTRIBUTE11 = caseObject.Seller__r.MiddleName != null ? caseObject.Seller__r.MiddleName : '' ;
            objDocGenDTO.ATTRIBUTE12 = caseObject.Seller__r.LastName != null ? caseObject.Seller__r.LastName : '' ;
            objDocGenDTO.ATTRIBUTE13 = caseObject.Seller__r.Nationality__c != null ? caseObject.Seller__r.Nationality__c : '' ;
            objDocGenDTO.ATTRIBUTE14 = caseObject.Seller__r.Passport_Number__c != null ? caseObject.Seller__r.Passport_Number__c : '' ;
            objDocGenDTO.ATTRIBUTE15 = ''; //joint seller first name
            objDocGenDTO.ATTRIBUTE16 = ''; //joint seller middle name
            objDocGenDTO.ATTRIBUTE17 = ''; //joint seller last name
            objDocGenDTO.ATTRIBUTE18 = ''; //joint seller Nationality
            objDocGenDTO.ATTRIBUTE19 = ''; //joint seller passport number
            objDocGenDTO.ATTRIBUTE20 = caseObject.Buyer__r.First_Name__c != null ? caseObject.Buyer__r.First_Name__c : '';
            objDocGenDTO.ATTRIBUTE21 = ''; //buyer middle name
            objDocGenDTO.ATTRIBUTE22 = caseObject.Buyer__r.Last_Name__c != null ? caseObject.Buyer__r.Last_Name__c : '';
            objDocGenDTO.ATTRIBUTE23 = caseObject.Buyer__r.Nationality__c != null ? caseObject.Buyer__r.Nationality__c : '';
            objDocGenDTO.ATTRIBUTE24 = caseObject.Buyer__r.Passport_Number__c != null ? caseObject.Buyer__r.Passport_Number__c : '';
            objDocGenDTO.ATTRIBUTE25 = ''; //joint buyer first name
            objDocGenDTO.ATTRIBUTE26 = ''; //joint buyer middle name
            objDocGenDTO.ATTRIBUTE27 = ''; //joint buyer last name
            objDocGenDTO.ATTRIBUTE28 = ''; //joint buyer Nationality
            objDocGenDTO.ATTRIBUTE29 = ''; //joint buyer Passport number
    
            system.debug('objDocGenDTO=='+objDocGenDTO);
            
            documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint docGen = new documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint();
            docGen.timeout_x = 120000;
            docUrl = docGen.DocGeneration('AssignmentNOC_Offplan', objDocGenDTO);
            system.debug('docUrl==='+docUrl);
        }
        SR_Attachments__c caseAttachment = new SR_Attachments__c();
        caseAttachment.Name = 'NOC Document';
        caseAttachment.IsRequired__c = true;
        caseAttachment.isValid__c = true;
        caseAttachment.Case__c = nocCaseId;
        caseAttachment.Attachment_URL__c = docUrl;
        insert caseAttachment;
        
        system.debug('caseAttachment==='+caseAttachment);
        
    }
}