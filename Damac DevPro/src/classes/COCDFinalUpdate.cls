public with sharing class COCDFinalUpdate {

	@InvocableMethod
	public static void updateHandler(List<Case> lstSR) {
		Set<String> caseIds = new Set<String>();
		for(Case caseObj : lstSR){
			caseIds.add(caseObj.Id);
		}
system.debug('inside updateHandler');
		UpdateCustomerInIpms(caseIds);
	}

	@Future(callout=true)
	public static void UpdateCustomerInIpms(Set<String> caseIds){
system.debug('inside UpdateCustomerInIpms');
		List<Case> caseList = [SELECT Id, AccountId, Account.Party_ID__c, CaseNumber, City__c, Address__c, Address_Arabic_1__c, Address_2__c, Address_Arabic_2__c,
									Address_3__c, Address_Arabic_3__c, Address_4__c, Address_Arabic_4__c, City_Arabic__c, Country__c, Country_Arabic__c,
									Passport_Issue_Date__c, Passport_Issue_Place__c, Contact_Email__c, Mobile_Country_Code__c, Contact_Mobile__c,
									Changed_Nationality__c, Changed_Nationality_Arabic__c, New_CR__c, Postal_Code__c, Postal_Code_Arabic__c, State__c, Work_Phone_Country_Code__c,
									Work_Phone__c, Passport_Issue_Place_Arabic__c, Title__c, Title_Arabic__c, Customer_First_Name__c,
									Customer_First_Name_Arabic__c, Customer_Middle_Name__c, Customer_Middle_Name_Arabic__c,	Home_Phone_Country_Code__c,
									Customer_Last_Name__c, Customer_Last_Name_Arabic__c, State_Arabic__c, Home_Phone__c
								FROM Case WHERE Id IN :caseIds
								];
		Date d = caseList[0].Passport_Issue_Date__c;
		beanComXsd.COCDRequestMessage objCOCDRequestMessage = new beanComXsd.COCDRequestMessage();
		objCOCDRequestMessage.IPMSPartyID = ( caseList[0].Account.Party_ID__c != null ) ?  caseList[0].Account.Party_ID__c : '';
        objCOCDRequestMessage.SRNumber = ( caseList[0].CaseNumber != null ) ? caseList[0].CaseNumber : '';
        objCOCDRequestMessage.city = ( caseList[0].City__c != null ) ? caseList[0].City__c : '';
        objCOCDRequestMessage.p_ADDRESS1 = ( caseList[0].Address__c != null ) ? caseList[0].Address__c : '' ;
        objCOCDRequestMessage.p_ADDRESS1_AR = ( caseList[0].Address_Arabic_1__c != null ) ? caseList[0].Address_Arabic_1__c : '';
        objCOCDRequestMessage.p_ADDRESS2 = ( caseList[0].Address_2__c != null ) ? caseList[0].Address_2__c : '';
        objCOCDRequestMessage.p_ADDRESS2_AR = ( caseList[0].Address_Arabic_2__c != null ) ? caseList[0].Address_Arabic_2__c : '';
        objCOCDRequestMessage.p_ADDRESS3 = ( caseList[0].Address_3__c != null ) ? caseList[0].Address_3__c : '';
        objCOCDRequestMessage.p_ADDRESS3_AR = ( caseList[0].Address_Arabic_3__c != null ) ? caseList[0].Address_Arabic_3__c : '';
        objCOCDRequestMessage.p_ADDRESS4 = ( caseList[0].Address_4__c != null ) ? caseList[0].Address_4__c : '';
        objCOCDRequestMessage.p_ADDRESS4_AR = ( caseList[0].Address_Arabic_4__c != null ) ? caseList[0].Address_Arabic_4__c : '';
        objCOCDRequestMessage.p_CITY_AR = ( caseList[0].City_Arabic__c != null ) ? caseList[0].City_Arabic__c : '';
        objCOCDRequestMessage.p_COUNTRY = ( caseList[0].Country__c != null ) ? caseList[0].Country__c : '';
        objCOCDRequestMessage.p_COUNTRY_AR = ( !String.isBlank( caseList[0].Country_Arabic__c )  ) ? caseList[0].Country_Arabic__c : '';
        system.debug('d : ' + d);
        objCOCDRequestMessage.p_CR_REG_DATE = ( d != null ) ? DateTime.newInstance(d.year(),d.month(),d.day()).format('DD-MMM-YYYY') : ''; //caseList[0].Country_Arabic__c;
        system.debug('objCOCDRequestMessage.p_CR_REG_DATE : ' + objCOCDRequestMessage.p_CR_REG_DATE);
        objCOCDRequestMessage.p_CR_REG_PLACE = '';
        objCOCDRequestMessage.p_EMAIL_ADDRESS = ( !String.isBlank( caseList[0].Contact_Email__c )  ) ? caseList[0].Contact_Email__c : '';
        objCOCDRequestMessage.p_FAX_AREA_CODE = '';
        objCOCDRequestMessage.p_FAX_COUNTRY_CODE = '';
        objCOCDRequestMessage.p_FAX_NUMBER = '';
        objCOCDRequestMessage.p_MOBILE_AREA_CODE = '';
        objCOCDRequestMessage.p_MOBILE_COUNTRY_CODE = ( !String.isBlank( caseList[0].Mobile_Country_Code__c )  ) ? caseList[0].Mobile_Country_Code__c : '';
        objCOCDRequestMessage.p_MOBILE_NUMBER = ( !String.isBlank( caseList[0].Contact_Mobile__c )  ) ? caseList[0].Contact_Mobile__c : '';
        objCOCDRequestMessage.p_NATIONALITY = ( !String.isBlank( caseList[0].Changed_Nationality__c )  ) ? caseList[0].Changed_Nationality__c : '';        
        //objCOCDRequestMessage.p_PASSPORT_ISSUE_DATE = String.valueOf(caseList[0].Passport_Issue_Date__c);DateTime.newInstance(d.year(),d.month(),d.day()).format('d-MM-YYYY');
        objCOCDRequestMessage.p_PASSPORT_ISSUE_DATE = ( d != null ) ? DateTime.newInstance(d.year(),d.month(),d.day()).format('DD-MMM-YYYY') : '';
        objCOCDRequestMessage.p_PASSPORT_ISSUE_PLACE = ( !String.isBlank( caseList[0].Passport_Issue_Place__c )  ) ? caseList[0].Passport_Issue_Place__c : '';
        objCOCDRequestMessage.p_PASSPORT_NUMBER = ( !String.isBlank( caseList[0].New_CR__c )  ) ? caseList[0].New_CR__c : '';
        objCOCDRequestMessage.p_POSTAL_CODE = ( !String.isBlank( caseList[0].Postal_Code__c )  ) ? caseList[0].Postal_Code__c : '';
        objCOCDRequestMessage.p_POSTAL_CODE_AR = ( !String.isBlank( caseList[0].Postal_Code_Arabic__c )  ) ? caseList[0].Postal_Code_Arabic__c : '';
        objCOCDRequestMessage.p_REQUEST_NAME = 'COCD';
        objCOCDRequestMessage.p_REQUEST_NUMBER = ( !String.isBlank( String.valueof(DateTime.now().getTime()) )  ) ? String.valueof(DateTime.now().getTime()) : '';
        objCOCDRequestMessage.p_SOURCE_SYSTEM = 'SFDC';
        objCOCDRequestMessage.p_STATE = ( !String.isBlank( caseList[0].State__c )  ) ? caseList[0].State__c : '';
        objCOCDRequestMessage.p_WORK_AREA_CODE = '';
        objCOCDRequestMessage.p_WORK_COUNTRY_CODE = ( !String.isBlank( caseList[0].Work_Phone_Country_Code__c )  ) ? caseList[0].Work_Phone_Country_Code__c : '';
        objCOCDRequestMessage.p_WORK_NUMBER = ( !String.isBlank( caseList[0].Work_Phone__c )  ) ? caseList[0].Work_Phone__c : '';
        objCOCDRequestMessage.p_url = '';


		actionCom.COCDHttpSoap11Endpoint cocdCalloutObj = new actionCom.COCDHttpSoap11Endpoint();
		cocdCalloutObj.timeout_x = 120000;
		//actionCom.UpdateCOCDResponse_element response = new actionCom.UpdateCOCDResponse_element();
		String response = cocdCalloutObj.UpdateCOCD(objCOCDRequestMessage);
		system.debug('updateCOCD response ' + response);

//response = 'S';
		if(response.equalsIgnoreCase('s')){
			Account accObject = new Account();
			if( !String.isEmpty(caseList[0].AccountId) ){	accObject.Id = caseList[0].AccountId;	}
			if( !String.isEmpty(caseList[0].Country__c) ){	accObject.Country__c = caseList[0].Country__c;	}
			if( !String.isEmpty(caseList[0].Country_Arabic__c) ){	accObject.Country_Arabic__c = caseList[0].Country_Arabic__c;	 }
			if( !String.isEmpty(caseList[0].Address__c) ){		accObject.Address_Line_1__c = caseList[0].Address__c;	 }
			if( !String.isEmpty(caseList[0].Address_Arabic_1__c) ){ accObject.Address_Line_1_Arabic__c = caseList[0].Address_Arabic_1__c;	}
			if( !String.isEmpty(caseList[0].Address_2__c) ){ accObject.Address_Line_2__c = caseList[0].Address_2__c;	}
			if( !String.isEmpty(caseList[0].Address_Arabic_2__c) ){ accObject.Address_Line_2_Arabic__c = caseList[0].Address_Arabic_2__c;	}
			if( !String.isEmpty(caseList[0].Address_3__c) ){ accObject.Address_Line_3__c = caseList[0].Address_3__c;	}
			if( !String.isEmpty(caseList[0].Address_Arabic_3__c) ){ accObject.Address_Line_3_Arabic__c = caseList[0].Address_Arabic_3__c;	}
			if( !String.isEmpty(caseList[0].Address_4__c) ){ accObject.Address_Line_4__c = caseList[0].Address_4__c;	}
			if( !String.isEmpty(caseList[0].Address_Arabic_4__c) ){ 	accObject.Address_Line_4_Arabic__c = caseList[0].Address_Arabic_4__c; 	}
			if( !String.isEmpty(caseList[0].City__c) ){ accObject.City__c = caseList[0].City__c; 	}
			if( !String.isEmpty(caseList[0].City_Arabic__c) ){ accObject.City_Arabic__c = caseList[0].City_Arabic__c;	}
			if( !String.isEmpty(caseList[0].State__c) ){ accObject.State__c = caseList[0].State__c;	}
			if( !String.isEmpty(caseList[0].State_Arabic__c) ){ accObject.State_Arabic__c = caseList[0].State_Arabic__c;	}
			if( !String.isEmpty(caseList[0].Postal_Code__c) ){ accObject.Zip_Postal_Code__c = caseList[0].Postal_Code__c;	}
			if( !String.isEmpty(caseList[0].Postal_Code_Arabic__c) ){ accObject.Postal_Code_Arabic__c = caseList[0].Postal_Code_Arabic__c;	}
			if( !String.isEmpty(caseList[0].Contact_Email__c ) ){ accObject.Email__c = caseList[0].Contact_Email__c;	}
			if( !String.isEmpty(caseList[0].Mobile_Country_Code__c ) ){ accObject.Mobile_Country_Code__c = caseList[0].Mobile_Country_Code__c;	}
			if( !String.isEmpty(caseList[0].Contact_Mobile__c ) ){ accObject.Mobile__c = caseList[0].Contact_Mobile__c; }
			if( !String.isEmpty(caseList[0].Contact_Mobile__c ) ){ accObject.Mobile_Encrypt__c = caseList[0].Contact_Mobile__c; }
			if( !String.isEmpty(caseList[0].Home_Phone_Country_Code__c ) ){ accObject.Home_Phone_Country_Code__c = caseList[0].Home_Phone_Country_Code__c;	}
			if( !String.isEmpty(caseList[0].Home_Phone__c ) ){ 	accObject.Home_Phone__c = caseList[0].Home_Phone__c;	}
			if( !String.isEmpty(caseList[0].Work_Phone_Country_Code__c ) ){ accObject.Work_Phone_Country_Code__c = caseList[0].Work_Phone_Country_Code__c;	}
			if( !String.isEmpty(caseList[0].Work_Phone__c ) ){ accObject.Work_Phone__c = caseList[0].Work_Phone__c;	}		
			if( !String.isEmpty(caseList[0].New_CR__c ) ){ accObject.Passport_Number__c = caseList[0].New_CR__c;	}
			if( caseList[0].Passport_Issue_Date__c != null ){ accObject.Passport_Issue_Date__c = caseList[0].Passport_Issue_Date__c;	}
			if( !String.isEmpty(caseList[0].Passport_Issue_Place__c ) ){ accObject.Passport_Issue_Place__c = caseList[0].Passport_Issue_Place__c;	}
			if( !String.isEmpty(caseList[0].Passport_Issue_Place_Arabic__c ) ){ accObject.Passport_Issue_Place_Arabic__c = caseList[0].Passport_Issue_Place_Arabic__c;	}
			if( !String.isEmpty(caseList[0].Changed_Nationality__c ) ){ accObject.Nationality__c = caseList[0].Changed_Nationality__c;	}
			if( !String.isEmpty(caseList[0].Title__c ) ){ accObject.Title__c = caseList[0].Title__c; }
			if( !String.isEmpty(caseList[0].Title_Arabic__c ) ){ accObject.Title_Arabic__c = caseList[0].Title_Arabic__c; }
			if( !String.isEmpty(caseList[0].Customer_First_Name__c ) ){ accObject.First_Name__c = caseList[0].Customer_First_Name__c;	}
			if( !String.isEmpty(caseList[0].Customer_First_Name_Arabic__c ) ){	accObject.First_Name_Arabic__c = caseList[0].Customer_First_Name_Arabic__c;	}
			if( !String.isEmpty(caseList[0].Customer_Middle_Name__c ) ){ accObject.Middle_Name__c = caseList[0].Customer_Middle_Name__c;}
			if( !String.isEmpty(caseList[0].Customer_Middle_Name_Arabic__c ) ){ accObject.Middle_Name_Arabic__c = caseList[0].Customer_Middle_Name_Arabic__c;	}
			if( !String.isEmpty(caseList[0].Customer_Last_Name__c ) ){ accObject.Last_Name__c = caseList[0].Customer_Last_Name__c; 	}
			if( !String.isEmpty(caseList[0].Customer_Last_Name_Arabic__c ) ){ accObject.Last_Name_Arabic__c	= caseList[0].Customer_Last_Name_Arabic__c;	}

			update accObject;

			for(Case caseObj : caseList){
				caseObj.Status = 'Closed';
			}

			update caseList;
		} else {

			List<String> toAddresses = new List<String>();
	        toAddresses.add('amit.joshi@eternussolutions.com');
	        toAddresses.add('snehil.karn@eternussolutions.com');
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setToAddresses(toAddresses);

	        mail.setSubject('Issue in IPMS Response' );
	        String mailBody = 'Hi,<br/>';
	        mailBody += '<p>There was error in response from IPMS. Please check with admin</p><br/><br/>';
	        mailBody += 'Thanks you,<br/>DAMAC Team.';

	        mail.setHtmlBody( mailBody );
	        system.debug('mail' + mail);
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

		}

		

		
	}
	/*
	@Future(callout=true)
	public static void createDebitCreditMemoInIPMS( Set<String> taskIds, Set<String> caseIds ){
		List<Task> taskList = [SELECT Id, WhatId, Description, COCD_Fee_Invoice_Number__c FROM Task WHERE Id IN: taskIds];
		Map<Id, Case> caseId_CaseMap = new Map<Id, Case>([SELECT Id, Account.Party_ID__c, OQOOD_Fee__c FROM Case WHERE Id IN: caseIds]);
		

		for( Task t : taskList){
			COCDRuleEngine.COCDHttpSoap11Endpoint memoCalloutObj = new COCDRuleEngine.COCDHttpSoap11Endpoint();
			memoCalloutObj.timeout_x = 120000;
            String response = memoCalloutObj.CreateDebitCreditMemo(String.valueOf( Datetime.now().getTime()),'CREATE_DM_CM','SFDC', caseId_CaseMap.get(t.WhatId).Account.Party_ID__c , String.valueOf(caseId_CaseMap.get(t.WhatId).OQOOD_Fee__c),'','', t.COCD_Fee_Invoice_Number__c,t.Description);
		}
			

			
	}*/
	
	//@Future(callout=true)
	public static void createDebitCreditMemoInIPMS(String regId, String adminFee, String description ){
	    //system.debug('###wrapperBody :'+wrapperBody);
        //List<RuleEngineResponse> ruleEngineResponseList = (List<RuleEngineResponse>)JSON.deserialize(wrapperBody, List<COCDFinalUpdate.RuleEngineResponse>.class);
        //system.debug('###ruleEngineResponseList :'+ruleEngineResponseList);
		//for( RuleEngineResponse ruleEngineResponse : ruleEngineResponseList){
		    
			actionCom.COCDHttpSoap11Endpoint cocdHttpSoap11Endpoint = new actionCom.COCDHttpSoap11Endpoint();
			cocdHttpSoap11Endpoint.timeout_x = 120000;
            //String response = cocdHttpSoap11Endpoint.CreateDebitCreditMemo(String.valueOf( Datetime.now().getTime()),'CREATE_DM_CM','SFDC',ruleEngineResponse.regId,ruleEngineResponse.adminFee,'','', ruleEngineResponse.UniqueTransactionNumber,ruleEngineResponse.description);
            String response = cocdHttpSoap11Endpoint.CreateDebitCreditMemo(String.valueOf( Datetime.now().getTime()),'CREATE_DM_CM','SFDC', regId, adminFee,'','', String.valueOf( Datetime.now().getTime()), description);
            system.debug('###response :'+response);
		//}
			

			
	}

	public static List<RuleEngineResponse> callRuleEngine(String partyId, String sourceofRequest, String processName, String subProcesName,String customerType,String customerNationality){
	    
	    try{
    	    actionCom.COCDHttpSoap11Endpoint cocdHttpSoap11Endpoint = new actionCom.COCDHttpSoap11Endpoint();
            cocdHttpSoap11Endpoint.timeout_x = 120000;
            String response = COCDHttpSoap11Endpoint.COCDFinancials(partyId,sourceofRequest,processName,subProcesName,'Dubai','','','','','Offplan',customerType,customerNationality,'');

            response = response.replace('["', '[');
            response = response.replace('"]', ']');
            response = response.replace('\\', '');
system.debug( 'response = ' + response);
            List<RuleEngineResponse> ruleEngineResponse = (List<RuleEngineResponse>)JSON.deserialize(response, List<COCDFinalUpdate.RuleEngineResponse>.class);
            if(ruleEngineResponse != null && ruleEngineResponse.size() > 0){
                for(RuleEngineResponse ruleResponse : ruleEngineResponse){
                    if(ruleResponse.adminFee == null || ruleResponse.adminFee == 'null'){
                        ruleResponse.adminFee = '0';
                    }
                }
                return ruleEngineResponse;
            } else {
                ruleEngineResponse = new List<RuleEngineResponse>();
                return ruleEngineResponse;
            }
            return new List<RuleEngineResponse>();
	    }
	    catch(Exception e){
	        system.debug('Exception :'+e);
	        return new List<RuleEngineResponse>();
	    }
        return new List<RuleEngineResponse>();
        
	}
	
	public Class RuleEngineResponse{
	    public String regId {get;set;}
        public String adminFee {get;set;}
        public String UniqueTransactionNumber {get;set;}
        public String description {get;set;}
    }
    


    public static String getUndertakingChangeNameNationality( ChangeOfDetailController.lodauWrapper objWrap ){



        docgenerationDtoComXsd.DocGenDTO objDocGenDTO = new docgenerationDtoComXsd.DocGenDTO();

        objDocGenDTO.ATTRIBUTE1 = String.valueOf( datetime.now().format('dd-MMM-yyyy') );
        objDocGenDTO.ATTRIBUTE10 = objWrap.AddressLine4;
        objDocGenDTO.ATTRIBUTE100 = '';
        objDocGenDTO.ATTRIBUTE11 = objWrap.City;
        objDocGenDTO.ATTRIBUTE12 = objWrap.Country;
        objDocGenDTO.ATTRIBUTE13 = objWrap.HomePhone;
        objDocGenDTO.ATTRIBUTE14 = objWrap.Fax;
        objDocGenDTO.ATTRIBUTE15 = objWrap.Mobile;
        objDocGenDTO.ATTRIBUTE16 = objWrap.Email;
        objDocGenDTO.ATTRIBUTE17 = objWrap.MasterDeveloper;
        objDocGenDTO.ATTRIBUTE18 = objWrap.UnitName;
        objDocGenDTO.ATTRIBUTE19 = objWrap.PropertyName;
        objDocGenDTO.ATTRIBUTE2 = objWrap.FirstName;
        objDocGenDTO.ATTRIBUTE20 = objWrap.PropertyAddress;
        objDocGenDTO.ATTRIBUTE21 = objWrap.PropertyCity;
        objDocGenDTO.ATTRIBUTE22 = objWrap.SPADate;
        objDocGenDTO.ATTRIBUTE23 = objWrap.FirstName;
        objDocGenDTO.ATTRIBUTE24 = objWrap.MiddleName;
        objDocGenDTO.ATTRIBUTE25 = objWrap.LastName;
        objDocGenDTO.ATTRIBUTE26 = objWrap.ChangedFirstName;
        objDocGenDTO.ATTRIBUTE27 = objWrap.ChangedMiddleName;
        objDocGenDTO.ATTRIBUTE28 = objWrap.ChangedLastName;
        objDocGenDTO.ATTRIBUTE29 = objWrap.PassportNumber;
        objDocGenDTO.ATTRIBUTE3 = objWrap.MiddleName;
        objDocGenDTO.ATTRIBUTE30 = objWrap.FirstName;
        objDocGenDTO.ATTRIBUTE31 = objWrap.MiddleName;
        objDocGenDTO.ATTRIBUTE32 = objWrap.LastName;
        objDocGenDTO.ATTRIBUTE33 = objWrap.ChangedFirstName;
        objDocGenDTO.ATTRIBUTE34 = objWrap.ChangedMiddleName;
        objDocGenDTO.ATTRIBUTE35 = objWrap.ChangedLastName;
        objDocGenDTO.ATTRIBUTE36 = objWrap.ArrayOfUnitName;
        objDocGenDTO.ATTRIBUTE37 = objWrap.ArrayOfPropertyName;
        objDocGenDTO.ATTRIBUTE38 = objWrap.ArrayOfPropertyAddress;
        objDocGenDTO.ATTRIBUTE39 = objWrap.ArrayOfNationality;
        objDocGenDTO.ATTRIBUTE4 = objWrap.LastName;
        objDocGenDTO.ATTRIBUTE40 = '';
        objDocGenDTO.ATTRIBUTE41 = '';
        objDocGenDTO.ATTRIBUTE42 = '';
        objDocGenDTO.ATTRIBUTE43 = '';
        objDocGenDTO.ATTRIBUTE44 = '';
        objDocGenDTO.ATTRIBUTE45 = '';
        objDocGenDTO.ATTRIBUTE46 = '';
        objDocGenDTO.ATTRIBUTE47 = '';
        objDocGenDTO.ATTRIBUTE48 = '';
        objDocGenDTO.ATTRIBUTE49 = '';
        objDocGenDTO.ATTRIBUTE5 = '';
        objDocGenDTO.ATTRIBUTE50 = '';
        objDocGenDTO.ATTRIBUTE51 = '';
        objDocGenDTO.ATTRIBUTE52 = '';
        objDocGenDTO.ATTRIBUTE53 = '';
        objDocGenDTO.ATTRIBUTE54 = '';
        objDocGenDTO.ATTRIBUTE55 = '';
        objDocGenDTO.ATTRIBUTE56 = '';
        objDocGenDTO.ATTRIBUTE57 = '';
        objDocGenDTO.ATTRIBUTE58 = '';
        objDocGenDTO.ATTRIBUTE59 = '';
        objDocGenDTO.ATTRIBUTE6 = '';
        objDocGenDTO.ATTRIBUTE60 = '';
        objDocGenDTO.ATTRIBUTE61 = '';
        objDocGenDTO.ATTRIBUTE62 = '';
        objDocGenDTO.ATTRIBUTE63 = '';
        objDocGenDTO.ATTRIBUTE64 = '';
        objDocGenDTO.ATTRIBUTE65 = '';
        objDocGenDTO.ATTRIBUTE66 = '';
        objDocGenDTO.ATTRIBUTE67 = '';
        objDocGenDTO.ATTRIBUTE68 = '';
        objDocGenDTO.ATTRIBUTE69 = '';
        objDocGenDTO.ATTRIBUTE7 = '';
        objDocGenDTO.ATTRIBUTE70 = '';
        objDocGenDTO.ATTRIBUTE71 = '';
        objDocGenDTO.ATTRIBUTE72 = '';
        objDocGenDTO.ATTRIBUTE73 = '';
        objDocGenDTO.ATTRIBUTE74 = '';
        objDocGenDTO.ATTRIBUTE75 = '';
        objDocGenDTO.ATTRIBUTE76 = '';
        objDocGenDTO.ATTRIBUTE77 = '';
        objDocGenDTO.ATTRIBUTE78 = '';
        objDocGenDTO.ATTRIBUTE79 = '';
        objDocGenDTO.ATTRIBUTE8 = '';
        objDocGenDTO.ATTRIBUTE80 = '';
        objDocGenDTO.ATTRIBUTE81 = '';
        objDocGenDTO.ATTRIBUTE82 = '';
        objDocGenDTO.ATTRIBUTE83 = '';
        objDocGenDTO.ATTRIBUTE84 = '';
        objDocGenDTO.ATTRIBUTE85 = '';
        objDocGenDTO.ATTRIBUTE86 = '';
        objDocGenDTO.ATTRIBUTE87 = '';
        objDocGenDTO.ATTRIBUTE88 = '';
        objDocGenDTO.ATTRIBUTE89 = '';
        objDocGenDTO.ATTRIBUTE9 = '';
        objDocGenDTO.ATTRIBUTE90 = '';
        objDocGenDTO.ATTRIBUTE91 = '';
        objDocGenDTO.ATTRIBUTE92 = '';
        objDocGenDTO.ATTRIBUTE93 = '';
        objDocGenDTO.ATTRIBUTE94 = '';
        objDocGenDTO.ATTRIBUTE95 = '';
        objDocGenDTO.ATTRIBUTE96 = '';
        objDocGenDTO.ATTRIBUTE97 = '';
        objDocGenDTO.ATTRIBUTE98 = '';
        objDocGenDTO.ATTRIBUTE99 = '';

        //system.assert(false, 'objDocGenDTO '+ objDocGenDTO);
        //List<LodGenerationUtility.AttributeArrForAll>  lstLodGenerationUtility  = new List<LodGenerationUtility.AttributeArrForAll>();
        //LodGenerationUtility.AttributeArrForAll  objLodGenerationUtility  = new LodGenerationUtility.AttributeArrForAll();

        //objLodGenerationUtility.attribute1= '';
        //objLodGenerationUtility.attribute10= '';
        //objLodGenerationUtility.attribute11= '';
        //objLodGenerationUtility.attribute12= '';
        //objLodGenerationUtility.attribute13= '';
        //objLodGenerationUtility.attribute14= '';
        //objLodGenerationUtility.attribute15= '';
        //objLodGenerationUtility.attribute16= '';
        //objLodGenerationUtility.attribute17= '';
        //objLodGenerationUtility.attribute18= '';
        //objLodGenerationUtility.attribute19= '';
        //objLodGenerationUtility.attribute2= '';
        //objLodGenerationUtility.attribute20= '';
        //objLodGenerationUtility.attribute3= '';
        //objLodGenerationUtility.attribute4= '';
        //objLodGenerationUtility.attribute5= '';
        //objLodGenerationUtility.attribute6= '';
        //objLodGenerationUtility.attribute7= '';
        //objLodGenerationUtility.attribute8= '';
        //objLodGenerationUtility.attribute9= '';
        //lstLodGenerationUtility.add(objLodGenerationUtility);


        //List<LodGenerationUtility.AttributeArr1>   lstAttributeArr1  = new List<LodGenerationUtility.AttributeArr1>(); 
        //LodGenerationUtility.AttributeArr1   objAttributeArr1  = new LodGenerationUtility.AttributeArr1(); 
        //objAttributeArr1.attribute1 = '';
        //objAttributeArr1.attribute2 = lstLodGenerationUtility;
        //lstAttributeArr1.add(objAttributeArr1);

        //objDocGenDTO.ATTRIBUTEARR1 = lstAttributeArr1;




        documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint calloutObj = new documentGeneration.SFDCDocumentGenerationHttpSoap11Endpoint();
        calloutObj.timeout_x = 120000;

        String response = '';
        try{

                       
            response = calloutObj.DocGeneration( 'UndertakingChangeNameNationality', objDocGenDTO );
            system.debug('response : '+ response);

        } catch (Exception e ){
            response = 'https://www.google.com';
        }
        
        return response;
    }

}