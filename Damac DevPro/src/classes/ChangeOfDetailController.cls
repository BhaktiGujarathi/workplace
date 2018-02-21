public with sharing class ChangeOfDetailController {
	public Account accountDetails{get; set;}
	public Account buyerDetails{get; set;}
	public Account nncBuyerDetails{get; set;}
	public Account ppBuyerDetails{get; set;}
	public Case cocdSR{get; set;}
	public List<Booking_Unit__c> bookingUnitList{get; set;}
	public Booking_Unit__c bookingUnitDetails{get; set;}
    public UnitDetailsService.BookinUnitDetailsWrapper bookingUnitDetailsFromIPMS{get; set;}
	public List<Account> accountsList{get; set;}
	public List<Joint_Buyer__c> buyersList{get; set;}
	//public String acc{get; set;} //this will be used if accountId is coming from outside the component
	public String selectedAcc{get; set;} //this will be used if accountId is selected from component dropdown or if coming from outside the component
	public Boolean isPrimaryBuyerSelected{get; set;}//used to check which buyer is selected for name nationality change SR
	//public String selectedAccName{get; set;}
	public String selectedBuyer{get; set;} //this will be used if joint Buyer is selected from component dropdown
	public String selectedNNCBuyer{get; set;}
	public String selectedPPBuyer{get; set;} 
	public String passportIssueDate{get; set;}
	public String cocdFormURL{get; set;}
	public List<String> soaFormURLs{get; set;}
	public String lodauFormURL{get; set;}
	public String cocdFee{get; set;}
	public String strSelectedCategory {get;set;}
	public String COCDSRInitiationMessage {get;set;}
	public list<Case> lstExistingCase {get;set;}
	public List<SelectOption> lstCategories {get;set;}
	public transient String crfAttachmentBody { get; set; }
    public transient String crfAttachmentName { get; set; }
    public Boolean crfAttachmentUploaded = false;
    public transient String poaAttachmentBody { get; set; }
    public transient String poaAttachmentName { get; set; }
    public Boolean poaAttachmentUploaded = false;
    public transient String lodAttachmentBody { get; set; }
    public transient String lodAttachmentName { get; set; }
    public Boolean lodAttachmentUploaded = false;
    public transient String passportAttachmentBody { get; set; }
    public transient String passportAttachmentName { get; set; }
    public Boolean passportAttachmentUploaded = false;
    String regIds = '';
    String adminfees = '';
    String customerOriginalFName = '';
    String customerOriginalMName = '';
    String customerOriginalLName = '';
    //list<Attachment> lstAttachment;
    //list<SR_Attachments__c> lstSRAttachment;

	public ChangeOfDetailController() {
		//write logic to fetch account details dynamically from the account id provided from vf component.

		cocdSR = new Case(Status='Draft Request');
		bookingUnitList = new List<Booking_Unit__c>();
		buyersList = new List<Joint_Buyer__c>();
		accountDetails = new Account();
		buyerDetails = new Account();
		nncBuyerDetails = new Account();
		ppBuyerDetails = new Account();
		//lstAttachment = new list<Attachment>();
     	//lstSRAttachment = new list<SR_Attachments__c>();
        bookingUnitDetailsFromIPMS = new UnitDetailsService.BookinUnitDetailsWrapper();

		//accountsList = new List<Account>();
		//accountsList =  [SELECT Name, Id, IsPersonAccount FROM Account];
		System.debug('account list ======= '+accountDetails);
		cocdFee = '0';

		lstCategories = new list<SelectOption>();
        lstCategories.add(new selectOption('Unit Details', 'Unit Details'));
        lstCategories.add(new selectOption('Flags', 'Flags'));
        lstCategories.add(new selectOption('Unit Status', 'Unit Status'));
        lstCategories.add(new selectOption('Open SRs', 'Open SRs'));
		strSelectedCategory = 'Unit Details';
	}


	public void checkExistingSRExists(String strSelectedUnit){
        set<String> setAllowedSRTypes = new set<String>();
        setAllowedSRTypes.add('Passport_Detail_Update');
        setAllowedSRTypes.add('Name_Nationality_Change');
        setAllowedSRTypes.add('Change_of_Joint_Buyer');

        lstExistingCase = new list<Case>();
        map<Id,Case> mapId_Case = new map<Id,Case>([Select c.Id
                                                         , c.Booking_Unit__c
                                                         , c.AccountId
                                                         , c.CaseNumber
                                                         , c.RecordType.DeveloperName
                                                         , c.RecordType.Name
                                                    From Case c
                                                    where c.Booking_Unit__c =: strSelectedUnit
                                                    and c.Status != 'Closed'
                                                    and c.Status != 'Rejected'
                                                    and c.RecordType.DeveloperName NOT IN : setAllowedSRTypes]);
        if(mapId_Case != null && !mapId_Case.isEmpty()){
            lstExistingCase.addAll(mapId_Case.values());
        }
        for(SR_Booking_Unit__c objSBU : [Select s.Id
                                              , s.Case__c
                                              , s.Case__r.Status
                                              , s.Case__r.CaseNumber
                                              , s.Case__r.RecordType.DeveloperName
                                              , s.Case__r.RecordType.Name
                                              , s.Booking_Unit__c 
                                         From SR_Booking_Unit__c s
                                         where s.Booking_Unit__c =:strSelectedUnit
                                         and s.Case__r.Status != 'Closed'
                                         and s.Case__r.Status != 'Rejected'
                                         and s.Case__r.RecordType.DeveloperName = 'AOPT']){
            if(!mapId_Case.containsKey(objSBU.Case__c)){
                Case objCase = objSBU.Case__r;
                //objCase.Id = objSBU.Case__c;
                //objCase.CaseNumber = objSBU.Case__r.CaseNumber;
                lstExistingCase.add(objCase);
            }
        }

        Integer existingSRCount = [SELECT count() FROM Case 
        							where Booking_Unit__c =: strSelectedUnit 
        							AND Status != 'Closed' 
        							AND Status != 'Rejected' 
        							AND RecordType.DeveloperName IN : setAllowedSRTypes];
system.debug('existingSRCount    '+ existingSRCount);
		if( existingSRCount > 0 ){
			COCDSRInitiationMessage = 'A Service Request already exist For the selected unit. You cannot proceed further.';
		} else {
			COCDSRInitiationMessage = '';
		}
system.debug('COCDSRInitiationMessage    '+ COCDSRInitiationMessage);
        //return lstExistingCase;
    }

    public void createDebitCreditMemo(){
    	if( String.isBlank( regIds ) ){
    		//List<String> regIdList = regIds.split(',')
    		Integer index = 0;
    		List<String> adminfeeList = adminfees.split(',');
    		for( String regid : regIds.split(',') ){
    			if( Decimal.valueof( adminfeeList[index] ) != 0 )
					COCDFinalUpdate.createDebitCreditMemoInIPMS( regid, adminfeeList[index], 'COCD Fee' );
				index++;
    		}
    	}
    }

	//Final Case submit
	public void submitSR(){
		
		cocdSR.Status = 'Submitted';
		saveAsDraft();
		createDebitCreditMemo();
	}

	//To save the Case as draft
	public void saveAsDraft(){
		String recType = Apexpages.currentpage().getparameters().get('recTypeSelected');
		cocdSR.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recType).getRecordTypeId();
		if(recType.equalsIgnoreCase('Change of Details')){
			saveCOCDCase(recType);
		} else if(recType.equalsIgnoreCase('Change of Joint Buyer')){
			saveCOJBCase(recType);
		} else if(recType.equalsIgnoreCase('Name Nationality Change')){
			cocdSR.Type = 'Name Nationality Change SR';
			saveNNCCase();
		} else if(recType.equalsIgnoreCase('Passport Detail Update')){
			cocdSR.Type = 'Passport Detail Update SR';
			savePPDCase();
		}
		system.debug('cocdSR after insert===== '+cocdSR);
	}

	public void saveCOCDCase(String recType){

		cocdSR.Type = 'Change of Contact Details';
		cocdSR.AccountId = accountDetails.Id;
		cocdSR.Address__c = accountDetails.Address_Line_1__c;
		cocdSR.Address_Arabic_1__c = accountDetails.Address_Line_1_Arabic__c;
		cocdSR.Address_2__c = accountDetails.Address_Line_2__c;
		cocdSR.Address_Arabic_2__c = accountDetails.Address_Line_2_Arabic__c;
		cocdSR.Address_3__c = accountDetails.Address_Line_3__c;
		cocdSR.Address_Arabic_3__c = accountDetails.Address_Line_3_Arabic__c;
		cocdSR.Address_4__c = accountDetails.Address_Line_4__c;
		cocdSR.Address_Arabic_4__c = accountDetails.Address_Line_4_Arabic__c;
		cocdSR.City__c = accountDetails.City__c;
		cocdSR.City_Arabic__c = accountDetails.City_Arabic__c;
		cocdSR.State__c = accountDetails.State__c;
		cocdSR.State_Arabic__c = accountDetails.State_Arabic__c;
		cocdSR.Postal_Code__c = accountDetails.Zip_Postal_Code__c;
		cocdSR.Postal_Code_Arabic__c = accountDetails.Postal_Code_Arabic__c;
		cocdSR.Country__c = accountDetails.Country__c;
		cocdSR.Country_Arabic__c = accountDetails.Country_Arabic__c;		
		cocdSR.Contact_Email__c = accountDetails.Email__c;
		cocdSR.Mobile_Country_Code__c = accountDetails.Mobile_Country_Code__c;
		cocdSR.Contact_Mobile__c = accountDetails.Mobile__c;
		cocdSR.Home_Phone_Country_Code__c= accountDetails.Home_Phone_Country_Code__c;
		cocdSR.Home_Phone__c= accountDetails.Home_Phone__c;
		cocdSR.Work_Phone_Country_Code__c= accountDetails.Work_Phone_Country_Code__c;
		cocdSR.Work_Phone__c= accountDetails.Work_Phone__c;
		System.debug('cocdFee ----- '+ cocdFee);
		System.debug('Decimal valueOf cocdFee ----- '+ Decimal.valueOf( cocdFee ) );
		
		if( !String.isEmpty(cocdFee) && Decimal.valueOf(cocdFee)  != 0 ){
			system.debug('inside if ---------  ');
			cocdSR.OQOOD_Fee_Applicable__c = true;
			cocdSR.OQOOD_Fee__c = Decimal.valueOf(cocdFee);
			cocdSR.OQOOD_Units__c = regIds;
			cocdSR.OQOOD_Admin_Fee__c = adminfees;

		}
		system.debug('cocdSR before insert===== '+cocdSR);
		try{
			upsert cocdSR;

			if( !crfAttachmentUploaded && String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) ){
				uploadAttachment( extractName(crfAttachmentName), extractBody(crfAttachmentBody), cocdSR.Id, extractType(crfAttachmentName), 'Customer Signed CRF Form '+ System.today());
				crfAttachmentBody = null;
				crfAttachmentName = null;
				crfAttachmentUploaded = true;
			}

			if( !poaAttachmentUploaded && String.isNotBlank( poaAttachmentBody ) && String.isNotBlank( poaAttachmentName ) ){
				uploadAttachment( extractName(poaAttachmentName), extractBody(poaAttachmentBody), cocdSR.Id, extractType(poaAttachmentName), 'Customer POA Form '+ System.today());
				poaAttachmentBody = null;
				poaAttachmentName = null;
				poaAttachmentUploaded = true;

			}
		} catch(Exception e){

		}
		

		system.debug('inserted case Id '+cocdSR.Id);
	}

	public void saveCOJBCase(String recType){
system.debug('inside saveCOJBCase    ' + buyerDetails);
		cocdSR.Type = 'Change of Joint Buyer Details';
		cocdSR.AccountId = buyerDetails.Id;
		cocdSR.Address__c = buyerDetails.Address_Line_1__c;
		cocdSR.Address_2__c = buyerDetails.Address_Line_2__c;
		cocdSR.Address_3__c = buyerDetails.Address_Line_3__c;
		cocdSR.Address_4__c = buyerDetails.Address_Line_4__c;
		cocdSR.City__c = buyerDetails.City__c;
		cocdSR.State__c = buyerDetails.State__c;
		cocdSR.Country__c = buyerDetails.Country__c;
		cocdSR.Postal_Code__c = buyerDetails.Zip_Postal_Code__c;
		cocdSR.Contact_Email__c = buyerDetails.Email__c;
		cocdSR.Mobile_Country_Code__c = buyerDetails.Mobile_Country_Code__c;
		cocdSR.Contact_Mobile__c = buyerDetails.Mobile__c;
		cocdSR.Home_Phone_Country_Code__c= buyerDetails.Home_Phone_Country_Code__c;
		cocdSR.Home_Phone__c= buyerDetails.Home_Phone__c;
		cocdSR.Work_Phone_Country_Code__c= buyerDetails.Work_Phone_Country_Code__c;
		cocdSR.Work_Phone__c= buyerDetails.Work_Phone__c;
		cocdSR.OQOOD_Fee_Applicable__c = false;

		try{
			upsert cocdSR;

			if( !crfAttachmentUploaded && String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) ){
				uploadAttachment( extractName(crfAttachmentName), extractBody(crfAttachmentBody), cocdSR.Id, extractType(crfAttachmentName), 'Customer Signed CRF Form '+ System.today());
				crfAttachmentBody = null;
				crfAttachmentName = null;
				crfAttachmentUploaded = true;
			}

			if( !poaAttachmentUploaded &&  String.isNotBlank( poaAttachmentBody ) && String.isNotBlank( poaAttachmentName ) ){
				uploadAttachment( extractName(poaAttachmentName), extractBody(poaAttachmentBody), cocdSR.Id, extractType(poaAttachmentName), 'Customer POA Form '+ System.today());
				poaAttachmentBody = null;
				poaAttachmentName = null;
				poaAttachmentUploaded = true;
			}
		} catch(Exception e){
			System.debug('Exception in COJB ');
		}
	}


	public void saveNNCCase(){

		//cocdSR.AccountId = (isPrimaryBuyerSelected) ? accountDetails.Id : nncBuyerDetails.Id;
		//system.assert(false, nncBuyerDetails.Id);
		cocdSR.AccountId = nncBuyerDetails.Id;
		//cocdSR.New_CR__c = (isPrimaryBuyerSelected) ? accountDetails.Passport_Number__c : nncBuyerDetails.Passport_Number__c;
		cocdSR.New_CR__c = nncBuyerDetails.Passport_Number__c;
		//cocdSR.Passport_Issue_Date__c = (isPrimaryBuyerSelected) ? accountDetails.Passport_Issue_Date__c : nncBuyerDetails.Passport_Issue_Date__c;
		cocdSR.Passport_Issue_Date__c = nncBuyerDetails.Passport_Issue_Date__c;
		//cocdSR.Passport_Issue_Place__c = (isPrimaryBuyerSelected) ? accountDetails.Passport_Issue_Place__c : nncBuyerDetails.Passport_Issue_Place__c;
		cocdSR.Passport_Issue_Place__c = nncBuyerDetails.Passport_Issue_Place__c;
		//cocdSR.Passport_Issue_Place_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.Passport_Issue_Place_Arabic__c : nncBuyerDetails.Passport_Issue_Place_Arabic__c;
		cocdSR.Passport_Issue_Place_Arabic__c = nncBuyerDetails.Passport_Issue_Place_Arabic__c;
		//cocdSR.Changed_Nationality__c = (isPrimaryBuyerSelected) ? accountDetails.Nationality__c : nncBuyerDetails.Nationality__c;
		cocdSR.Changed_Nationality__c = nncBuyerDetails.Nationality__c;
		//cocdSR.Changed_Nationality_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.Nationality_Arabic__c : nncBuyerDetails.Nationality_Arabic__c;
		cocdSR.Changed_Nationality_Arabic__c = nncBuyerDetails.Nationality_Arabic__c;
		//cocdSR.Title__c = (isPrimaryBuyerSelected) ? accountDetails.Title__c : nncBuyerDetails.Title__c;
		cocdSR.Title__c = nncBuyerDetails.Title__c;
		//cocdSR.Title_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.Title_Arabic__c : nncBuyerDetails.Title_Arabic__c;
		cocdSR.Title_Arabic__c = nncBuyerDetails.Title_Arabic__c;
		//cocdSR.Customer_First_Name__c = (isPrimaryBuyerSelected) ? accountDetails.First_Name__c : nncBuyerDetails.First_Name__c;
		cocdSR.Customer_First_Name__c = nncBuyerDetails.First_Name__c;
		//cocdSR.Customer_First_Name_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.First_Name_Arabic__c : nncBuyerDetails.First_Name_Arabic__c;
		cocdSR.Customer_First_Name_Arabic__c = nncBuyerDetails.First_Name_Arabic__c;
		//cocdSR.Customer_Middle_Name__c = (isPrimaryBuyerSelected) ? accountDetails.Middle_Name__c : nncBuyerDetails.Middle_Name__c;
		cocdSR.Customer_Middle_Name__c = nncBuyerDetails.Middle_Name__c;
		//cocdSR.Customer_Middle_Name_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.Middle_Name_Arabic__c : nncBuyerDetails.Middle_Name_Arabic__c;
		cocdSR.Customer_Middle_Name_Arabic__c = nncBuyerDetails.Middle_Name_Arabic__c;
		//cocdSR.Customer_Last_Name__c = (isPrimaryBuyerSelected) ? accountDetails.Last_Name__c : nncBuyerDetails.Last_Name__c;
		cocdSR.Customer_Last_Name__c = nncBuyerDetails.Last_Name__c;
		//cocdSR.Customer_Last_Name_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.Last_Name_Arabic__c : nncBuyerDetails.Last_Name_Arabic__c;
		cocdSR.Customer_Last_Name_Arabic__c = nncBuyerDetails.Last_Name_Arabic__c;
		cocdSR.OQOOD_Fee_Applicable__c = false;


		try{
			upsert cocdSR;

			if( !crfAttachmentUploaded && String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) ){
				uploadAttachment( extractName(crfAttachmentName), extractBody(crfAttachmentBody), cocdSR.Id, extractType(crfAttachmentName), 'Customer Signed CRF Form '+ System.today());
				crfAttachmentBody = null;
				crfAttachmentName = null;
				crfAttachmentUploaded = true;
			}

			if( !poaAttachmentUploaded && String.isNotBlank( poaAttachmentBody ) && String.isNotBlank( poaAttachmentName ) ){
				uploadAttachment( extractName(poaAttachmentName), extractBody(poaAttachmentBody), cocdSR.Id, extractType(poaAttachmentName), 'Customer POA Form '+ System.today());
				poaAttachmentBody = null;
				poaAttachmentName = null;
				poaAttachmentUploaded = true;
			}

			if( !lodAttachmentUploaded && String.isNotBlank( lodAttachmentBody ) && String.isNotBlank( lodAttachmentName ) ){
				uploadAttachment( extractName(lodAttachmentName), extractBody(lodAttachmentBody), cocdSR.Id, extractType(lodAttachmentName), 'Customer LOD Form '+ System.today());
				lodAttachmentBody = null;
				lodAttachmentName = null;
				lodAttachmentUploaded = true;
			}

			if( !passportAttachmentUploaded && String.isNotBlank( passportAttachmentBody ) && String.isNotBlank( passportAttachmentName ) ){
				uploadAttachment( extractName(passportAttachmentName), extractBody(passportAttachmentBody), cocdSR.Id, extractType(passportAttachmentName), 'Customer Passport '+ System.today());
				passportAttachmentBody = null;
				passportAttachmentName = null;
				passportAttachmentUploaded = true;
			}
		} catch(Exception e){

		}
	}


	public void savePPDCase(){

		//cocdSR.AccountId = (isPrimaryBuyerSelected) ? accountDetails.Id : ppBuyerDetails.Id;
		cocdSR.AccountId = ppBuyerDetails.Id;
		//cocdSR.New_CR__c = (isPrimaryBuyerSelected) ? accountDetails.Passport_Number__c : ppBuyerDetails.Passport_Number__c;
		cocdSR.New_CR__c = ppBuyerDetails.Passport_Number__c;
		//cocdSR.Passport_Issue_Date__c = (isPrimaryBuyerSelected) ? accountDetails.Passport_Issue_Date__c : ppBuyerDetails.Passport_Issue_Date__c;
		cocdSR.Passport_Issue_Date__c = ppBuyerDetails.Passport_Issue_Date__c;
		//cocdSR.Passport_Issue_Place__c = (isPrimaryBuyerSelected) ? accountDetails.Passport_Issue_Place__c : ppBuyerDetails.Passport_Issue_Place__c;
		cocdSR.Passport_Issue_Place__c = ppBuyerDetails.Passport_Issue_Place__c;
		//cocdSR.Passport_Issue_Place_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.Passport_Issue_Place_Arabic__c : ppBuyerDetails.Passport_Issue_Place_Arabic__c;
		cocdSR.Passport_Issue_Place_Arabic__c = ppBuyerDetails.Passport_Issue_Place_Arabic__c;
		//cocdSR.Changed_Nationality__c = (isPrimaryBuyerSelected) ? accountDetails.Nationality__c : ppBuyerDetails.Nationality__c;
		cocdSR.Changed_Nationality__c = ppBuyerDetails.Nationality__c;
		//cocdSR.Changed_Nationality_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.Nationality_Arabic__c : ppBuyerDetails.Nationality_Arabic__c;
		cocdSR.Changed_Nationality_Arabic__c = ppBuyerDetails.Nationality_Arabic__c;
		//cocdSR.Title__c = (isPrimaryBuyerSelected) ? accountDetails.Title__c : ppBuyerDetails.Title__c;
		cocdSR.Title__c = ppBuyerDetails.Title__c;
		//cocdSR.Title_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.Title_Arabic__c : ppBuyerDetails.Title_Arabic__c;
		cocdSR.Title_Arabic__c = ppBuyerDetails.Title_Arabic__c;
		//cocdSR.Customer_First_Name__c = (isPrimaryBuyerSelected) ? accountDetails.First_Name__c : ppBuyerDetails.First_Name__c;
		cocdSR.Customer_First_Name__c = ppBuyerDetails.First_Name__c;
		//cocdSR.Customer_First_Name_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.First_Name_Arabic__c : ppBuyerDetails.First_Name_Arabic__c;
		cocdSR.Customer_First_Name_Arabic__c = ppBuyerDetails.First_Name_Arabic__c;
		//cocdSR.Customer_Middle_Name__c = (isPrimaryBuyerSelected) ? accountDetails.Middle_Name__c : ppBuyerDetails.Middle_Name__c;
		cocdSR.Customer_Middle_Name__c = ppBuyerDetails.Middle_Name__c;
		//cocdSR.Customer_Middle_Name_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.Middle_Name_Arabic__c : ppBuyerDetails.Middle_Name_Arabic__c;
		cocdSR.Customer_Middle_Name_Arabic__c = ppBuyerDetails.Middle_Name_Arabic__c;
		//cocdSR.Customer_Last_Name__c = (isPrimaryBuyerSelected) ? accountDetails.Last_Name__c : ppBuyerDetails.Last_Name__c;
		cocdSR.Customer_Last_Name__c = ppBuyerDetails.Last_Name__c;
		//cocdSR.Customer_Last_Name_Arabic__c = (isPrimaryBuyerSelected) ? accountDetails.Last_Name_Arabic__c : ppBuyerDetails.Last_Name_Arabic__c;
		cocdSR.Customer_Last_Name_Arabic__c = ppBuyerDetails.Last_Name_Arabic__c;
		cocdSR.OQOOD_Fee_Applicable__c = false;
	
		try{
			upsert cocdSR;

			if( !crfAttachmentUploaded && String.isNotBlank( crfAttachmentBody ) && String.isNotBlank( crfAttachmentName ) ){
				uploadAttachment( extractName(crfAttachmentName), extractBody(crfAttachmentBody), cocdSR.Id, extractType(crfAttachmentName), 'Customer Signed CRF Form '+ System.today());
				crfAttachmentBody = null;
				crfAttachmentName = null;
crfAttachmentUploaded = true;
			}

			if( !poaAttachmentUploaded && String.isNotBlank( poaAttachmentBody ) && String.isNotBlank( poaAttachmentName ) ){
				uploadAttachment( extractName(poaAttachmentName), extractBody(poaAttachmentBody), cocdSR.Id, extractType(poaAttachmentName), 'Customer POA Form '+ System.today());
				poaAttachmentBody = null;
				poaAttachmentName = null;
poaAttachmentUploaded = true;
			}

			if( !lodAttachmentUploaded && String.isNotBlank( lodAttachmentBody ) && String.isNotBlank( lodAttachmentName ) ){
				uploadAttachment( extractName(lodAttachmentName), extractBody(lodAttachmentBody), cocdSR.Id, extractType(lodAttachmentName), 'Customer LOD Form '+ System.today());
				lodAttachmentBody = null;
				lodAttachmentName = null;
lodAttachmentUploaded = true;
			}

			if( !passportAttachmentUploaded && String.isNotBlank( passportAttachmentBody ) && String.isNotBlank( passportAttachmentName ) ){
				uploadAttachment( extractName(passportAttachmentName), extractBody(passportAttachmentBody), cocdSR.Id, extractType(passportAttachmentName), 'Customer Passport '+ System.today());
				passportAttachmentBody = null;
				passportAttachmentName = null;
passportAttachmentUploaded = true;
			}
		} catch(Exception e){

		}
	}

	/*@RemoteAction
    public static void UploadFile(map<String, String> mapFileDetails, String strCaseID){
        system.debug('mapFileDetails  ==== '+mapFileDetails);
        //assuming new file id uploaded and a callout is made to OCR system, and OCR_verified__c is updated after successful scan
        //Case c = new Case(Id=strCaseID, OCR_verified__c=true);
        //update c;


        list<Attachment> lstAttachment = new list<Attachment>();
        list<SR_Attachments__c> lstSRAttachment = new list<SR_Attachments__c>();

        for(string strFileName : mapFileDetails.keyset()){
            SR_Attachments__c objSRAtt = new SR_Attachments__c ();
            objSRAtt.Name = strFileName;
            objSRAtt.Case__c = strCaseID;
            objSRAtt.type__c = 'PDF';
            lstSRAttachment.add(objSRAtt);
        }//end for
        system.debug('mapFileDetails.keyset()  ==== '+mapFileDetails.keyset());
        system.debug('lstSRAttachment ==== '+lstSRAttachment);
        if(lstSRAttachment!=null && lstSRAttachment.size()>0){
            try{
                insert lstSRAttachment;
            }catch(DMLException errorMessage){
                system.debug('-errorMessage--'+errorMessage);
            }//End try-catch
        }//End if

        for(SR_Attachments__c objSRAttachment : [select ID,
                                                 Name
                                                 from SR_Attachments__c
                                                 where Case__c =: strCaseID]){
                                                     Attachment objAttachmnt = new Attachment(parentId = objSRAttachment.ID,
                                                                                              name= objSRAttachment.Name,
                                                                                              body = Blob.valueOf(mapFileDetails.get(objSRAttachment.Name)),
                                                                                              ContentType='PDF');
                                                     lstAttachment.add(objAttachmnt);
                                                 }//end for

        if(lstAttachment!=null && lstAttachment.size()>0){
            try{
                insert lstAttachment;
            }catch(DMLException errorMessage){
                system.debug('-errorMessage--'+errorMessage);
            }//End try-catch
        }

        system.debug('lstSRAttachment ==== '+lstSRAttachment);
        system.debug('lstAttachment ===== '+lstAttachment);
    }
	*/

    public void getUpdatedCustomerInfo(){
        if(!String.isBlank(selectedAcc)){
            accountDetails = [SELECT Name, Id, IsPersonAccount, Party_ID__c, Party_Type__c, Country__c, Country_Arabic__c, Address_Line_1__c, Address_Line_1_Arabic__c, 
            					Address_Line_2__c, Address_Line_2_Arabic__c, Address_Line_3__c, Address_Line_3_Arabic__c, Address_Line_4__c, Address_Line_4_Arabic__c, 
            					City__c, City_Arabic__c, State__c,State_Arabic__c, Zip_Postal_Code__c, Postal_Code_Arabic__c, Email__c, Mobile_Country_Code__c, Mobile__c, 
            					Home_Phone_Country_Code__c, Home_Phone__c,Work_Phone_Country_Code__c,	Work_Phone__c,Passport_Number__c, Passport_Issue_Date__c, 
            					Passport_Issue_Place__c, Passport_Issue_Place_Arabic__c, Nationality__c, Nationality_Arabic__c, Title__c, Title_Arabic__c, First_Name__c, 
            					First_Name_Arabic__c, Middle_Name__c, Middle_Name_Arabic__c, Last_Name__c, Last_Name_Arabic__c, Nationality__pc
                			FROM Account WHERE Id =: selectedAcc];
			passportIssueDate = ( accountDetails.Passport_Issue_Date__c != null ) ? accountDetails.Passport_Issue_Date__c.format() : null;
            bookingUnitList = [SELECT Inventory__r.Unit_Location__r.Unit_Name__c,Unit_Details__c, Id, Booking__c FROM Booking_Unit__c WHERE Booking__r.Account__c =: selectedAcc AND Re_Assigned__c = false];
						System.debug('bookingUnitList ==== '+ bookingUnitList);
						if(!bookingUnitList.isEmpty()){
							Set<String> bookingIds = new Set<String>();
							for(Booking_Unit__c cu : bookingUnitList){
								bookingIds.add(cu.Booking__c);
							}
							buyersList = [SELECT Account__c, Account__r.Name, Id,Primary_Buyer__c FROM Joint_Buyer__c WHERE Booking__c IN :bookingIds AND Account__c != :selectedAcc];
							/*
							** If a joint buyer is a primary buyer in any other booking, his/her name is removed from the jointBuyer List
							*/
							Set<String> jointBuyersId = new Set<String>();
							for(Joint_Buyer__c bl : buyersList){
								if(!String.isBlank(bl.Account__c))
									jointBuyersId.add(bl.Account__c);
							}
							List<Joint_Buyer__c> jointBuyerWithPrimaryFlag = [SELECT Account__c, Id FROM Joint_Buyer__c WHERE Account__c IN :jointBuyersId AND Primary_Buyer__c =: true];
							if(!jointBuyerWithPrimaryFlag.isEmpty()){
								Map<String, Joint_Buyer__c> accountId_JointBuyerMap = new Map<String, Joint_Buyer__c>();
								for(Joint_Buyer__c jbp : jointBuyerWithPrimaryFlag){
									accountId_JointBuyerMap.put(jbp.Account__c, jbp);
								}
								Integer j = 0;
								while (j < buyersList.size()){
								  if(accountId_JointBuyerMap.get(buyersList.get(j).Account__c) != null){
								    buyersList.remove(j);
								  }else {
								    j++;
								  }
								}
							}
						}
        }
      
        System.debug(accountDetails);
        getCustomerCOCDFee(accountDetails);
    }
    
    public void getCustomerCOCDFee(Account accountDetails){
		Decimal totalFee = 0.00;
		List<String> regIdList = new List<String>();
		List<String> adminFeeList = new List<String>();
		system.debug('accountDetails '+ accountDetails);
		system.debug('accountDetails.Party_ID__c == '+ accountDetails.Party_ID__c);
		system.debug('accountDetails.Party_ID__c == '+ accountDetails.Party_Type__c);
		system.debug('accountDetails.Party_ID__c == '+ accountDetails.Nationality__pc);
		List<COCDFinalUpdate.RuleEngineResponse> response = COCDFinalUpdate.callRuleEngine(accountDetails.Party_ID__c, 'walkin', 'COD', 'Primary Contact', 'Corporate', accountDetails.Nationality__pc);
		System.debug('cocdFee response '+ response);
		System.debug('cocdFee !response.isEmpty() '+ !response.isEmpty());
		if( !response.isEmpty() ){
			for( COCDFinalUpdate.RuleEngineResponse r : response ){
				if( r.regId != null )
					regIdList.add(r.regId);
				adminFeeList.add(r.adminFee);
				String tempFee = r.adminFee.replaceAll('[^0-9]', '');
				totalFee += Decimal.valueOf(tempFee);
			}	
		}
		regIds = String.join(regIdList, ',');	
		adminfees = String.join(adminFeeList, ',');
		cocdFee = String.valueOf(totalFee);
system.debug('regIds  ==== '+ regIds);
system.debug('regIdList  ==== '+ regIdList);
system.debug('adminFeeList  ==== '+ adminFeeList);
    	System.debug('cocdFee return value '+ cocdFee);
		//return null;
    }
	public void getUpdatedBuyerInfo(){
        if(!String.isBlank(selectedBuyer)){
            buyerDetails = [SELECT Name, Id, IsPersonAccount, Party_ID__c, Country__c, Country_Arabic__c, Address_Line_1__c, Address_Line_1_Arabic__c, Address_Line_2__c, Address_Line_2_Arabic__c, Address_Line_3__c, Address_Line_3_Arabic__c, Address_Line_4__c, Address_Line_4_Arabic__c, City__c, City_Arabic__c, State__c,State_Arabic__c, Zip_Postal_Code__c, Postal_Code_Arabic__c, Email__c, Mobile_Country_Code__c, Mobile__c, Home_Phone_Country_Code__c, Home_Phone__c,Work_Phone_Country_Code__c,	Work_Phone__c,Passport_Number__c, Passport_Issue_Date__c, Passport_Issue_Place__c, Passport_Issue_Place_Arabic__c, Nationality__c, Nationality_Arabic__c, Title__c, Title_Arabic__c, First_Name__c, First_Name_Arabic__c, Middle_Name__c, Middle_Name_Arabic__c, Last_Name__c, Last_Name_Arabic__c
                FROM Account WHERE Id =: selectedBuyer];
            passportIssueDate = (buyerDetails.Passport_Issue_Date__c != null ) ? buyerDetails.Passport_Issue_Date__c.format() : null;
        }
        System.debug(buyerDetails);
    }

    public void getUpdatedNNCBuyerInfo(){

        if(!String.isBlank(selectedNNCBuyer)){
            nncBuyerDetails = [SELECT Name, Id, IsPersonAccount, Party_ID__c, Country__c, Country_Arabic__c, Address_Line_1__c, Address_Line_1_Arabic__c, Address_Line_2__c, Address_Line_2_Arabic__c, Address_Line_3__c, Address_Line_3_Arabic__c, Address_Line_4__c, Address_Line_4_Arabic__c, City__c, City_Arabic__c, State__c,State_Arabic__c, Zip_Postal_Code__c, Postal_Code_Arabic__c, Email__c, Mobile_Country_Code__c, Mobile__c, Home_Phone_Country_Code__c, Home_Phone__c,Work_Phone_Country_Code__c,	Work_Phone__c,Passport_Number__c, Passport_Issue_Date__c, Passport_Issue_Place__c, Passport_Issue_Place_Arabic__c, Nationality__c, Nationality_Arabic__c, Title__c, Title_Arabic__c, First_Name__c, First_Name_Arabic__c, Middle_Name__c, Middle_Name_Arabic__c, Last_Name__c, Last_Name_Arabic__c,Fax__c
                FROM Account WHERE Id =: selectedNNCBuyer];
            passportIssueDate = (nncBuyerDetails.Passport_Issue_Date__c != null ) ? nncBuyerDetails.Passport_Issue_Date__c.format() : null;
            
            customerOriginalFName = nncBuyerDetails.First_Name__c;
    		customerOriginalMName = nncBuyerDetails.Middle_Name__c;
    		customerOriginalLName = nncBuyerDetails.Last_Name__c;
        }
        System.debug(nncBuyerDetails);
    }

    public void getUpdatedPPBuyerInfo(){
        if(!String.isBlank(selectedPPBuyer)){
            ppBuyerDetails = [SELECT Name, Id, IsPersonAccount, Party_ID__c, Country__c, Country_Arabic__c, Address_Line_1__c, Address_Line_1_Arabic__c, Address_Line_2__c, Address_Line_2_Arabic__c, Address_Line_3__c, Address_Line_3_Arabic__c, Address_Line_4__c, Address_Line_4_Arabic__c, City__c, City_Arabic__c, State__c,State_Arabic__c, Zip_Postal_Code__c, Postal_Code_Arabic__c, Email__c, Mobile_Country_Code__c, Mobile__c, Home_Phone_Country_Code__c, Home_Phone__c,Work_Phone_Country_Code__c,	Work_Phone__c,Passport_Number__c, Passport_Issue_Date__c, Passport_Issue_Place__c, Passport_Issue_Place_Arabic__c, Nationality__c, Nationality_Arabic__c, Title__c, Title_Arabic__c, First_Name__c, First_Name_Arabic__c, Middle_Name__c, Middle_Name_Arabic__c, Last_Name__c, Last_Name_Arabic__c
                FROM Account WHERE Id =: selectedPPBuyer];
            passportIssueDate = (ppBuyerDetails.Passport_Issue_Date__c != null ) ? ppBuyerDetails.Passport_Issue_Date__c.format() : null;
        }
        System.debug(ppBuyerDetails);
    }


	public void getUpdatedUnitDetails(){
		String bookingUnitId = Apexpages.currentpage().getparameters().get('bookingUnitId');
	    if(!String.isBlank(bookingUnitId) && bookingUnitId != 'none'){
	        bookingUnitDetails = [SELECT Name,Id,Inventory__c, 
	        						Inventory__r.Property__r.Name,
	        						Inventory__r.Property_Status__c,
	        						Inventory__r.Property_City__c,
	        						Bedroom_Type__c,
	        						Unit_Type__c,
									Permitted_Use__c,
									Inventory__r.Building_Location__r.Status__c,
									Rental_Pool_Status__c,
									Area__c,
									Inventory__r.Master_Developer_EN__c, 
									Inventory__r.Building_Location__c, 
                                  Inventory_Area__c,
                                  Unit_Details__c,
                                  Unit_Selling_Price__c,
                                  Booking_Type__c,
                                  Plot_Price__c,
                                  DP_OK__c,
                                  Doc_OK__c,
                                  Booking__r.CreatedDate,
                                  Agreement_Date__c,
                                  Inventory__r.Unit_Plan__c,
                                  Inventory__r.Floor_Plan__c,
                                  JOPD_Area__c,
                                  Mortgage__c,
                                  PCC_Release__c,
									Selling_Price__c,
									Unit_s_Current_Status__c,
									OQOOD_Reg_Flag__c,
									Early_Handover__c,
									Handover_Complete__c,
									Unit_Selling_Price_AED__c,
                                    DP_Overdue__c,
                                  Registration_ID__c
                          		FROM Booking_Unit__c WHERE Id =: bookingUnitId];
	    }
        
        bookingUnitDetailsFromIPMS = UnitDetailsService.getBookingUnitDetails( bookingUnitDetails.Registration_ID__c );

	    checkExistingSRExists(bookingUnitId);
	    System.debug(bookingUnitDetails);
	}

	public void getCODURL(){

		String recTypeSelected = Apexpages.currentpage().getparameters().get('recTypeSelected');

		if( recTypeSelected == 'Change of Details' ){
			CocdUrlCallout(accountDetails);
		} else if( recTypeSelected == 'Change of Joint Buyer' ){
			CocdUrlCallout(buyerDetails);
		} else if( recTypeSelected == 'Name Nationality Change' ){
			CocdUrlCallout(nncBuyerDetails);
		} else if( recTypeSelected == 'Passport Detail Update' ){
			CocdUrlCallout(ppBuyerDetails);
		}
	}

	public void CocdUrlCallout(Account accObj){
		String P_REQUEST_NUMBER = String.valueOf( datetime.now().getTime() );
		String P_REQUEST_NAME = 'COCD_LETTER';
		String P_SOURCE_SYSTEM = 'SFDC';
		String IPMSPartyID = accObj.Party_ID__c;
		String Address1 = accObj.Address_Line_1__c;
		String Address2 = accObj.Address_Line_2__c;
		String Address3 = accObj.Address_Line_3__c;
		String Address4 = accObj.Address_Line_4__c;
		String city = accObj.City__c;
		String state = accObj.State__c;
		String postalCode = accObj.Zip_Postal_Code__c;
		String country = accObj.Country__c;
		String MobileCountryCode = accObj.Mobile_Country_Code__c;
		String MobileAreaCode = '';
		String MobileNumber = accObj.Mobile__c;
		String PhoneCountryCode = accObj.Home_Phone_Country_Code__c;
		String PhoneAreaCode = '';
		String PhoneNumber = accObj.Home_Phone__c;
		String FaxCountryCode = '';
		String FaxAreaCode = '';
		String FaxNumber = '';
		String EmailAddress = accObj.Email__c;
		String PassportIssueDate = String.valueOf(accObj.Passport_Issue_Date__c);
		String PassportNumnber = accObj.Passport_Number__c;

		actionCom.COCDHttpSoap11Endpoint cocdFormCalloutObj = new actionCom.COCDHttpSoap11Endpoint();
		cocdFormCalloutObj.timeout_x = 120000;
		//COCDRuleEngine.COCDHttpSoap11Endpoint cocdFormCalloutObj = new COCDRuleEngine.COCDHttpSoap11Endpoint();
		//cocdFormCalloutObj.timeout_x = 120000;
		cocdFormURL = cocdFormCalloutObj.generateCOCD(P_REQUEST_NUMBER, P_REQUEST_NAME, P_SOURCE_SYSTEM, IPMSPartyID, Address1, Address2, Address3,
			Address4, city, state, postalCode, country, MobileCountryCode, MobileAreaCode, MobileNumber, PhoneCountryCode, PhoneAreaCode, PhoneNumber, 
			FaxCountryCode, FaxAreaCode, FaxNumber, EmailAddress, PassportIssueDate, PassportNumnber);

		System.debug(cocdFormUrl);
	}


	/*public void getSOAURL(){
		system.debug('regIds ==== '+regIds);

	}*/
	 public void getLODAUURL() {

List<Booking_Unit__c> bookingUnitsForCustomerList = [SELECT Unit_Details__c,Inventory__r.Property__r.Name, Inventory__r.Building_Location__c FROM Booking_Unit__c WHERE Booking__r.Account__c = :nncBuyerDetails.Id];
List<String> unitsforCustomer = new List<String>();
List<String> propertyNameforCustomer = new List<String>();
List<String> propertyAddressforCustomer = new List<String>();
for(Booking_Unit__c buObj : bookingUnitsForCustomerList ){
	if( !String.isBlank( buObj.Unit_Details__c )  )
		unitsforCustomer.add( buObj.Unit_Details__c );

	if( !String.isBlank( buObj.Inventory__r.Property__r.Name ) )
		propertyNameforCustomer.add( buObj.Inventory__r.Property__r.Name );

	if( !String.isBlank( buObj.Inventory__r.Building_Location__c ) )
		propertyAddressforCustomer.add( buObj.Inventory__r.Building_Location__c );
}

	 	lodauWrapper wrapper = new lodauWrapper();
	 	wrapper.FirstName = ( !String.isBlank( customerOriginalFName )  ) ? customerOriginalFName : '';    		
		wrapper.MiddleName =  ( !String.isBlank( customerOriginalMName ) ) ? customerOriginalMName : '';
		wrapper.LastName  =  ( !String.isBlank( customerOriginalLName ) ) ? customerOriginalLName : '';
		wrapper.Nationality   =  ( !String.isBlank( nncBuyerDetails.Nationality__c ) ) ? nncBuyerDetails.Nationality__c : '';
		wrapper.PassportNumber = ( !String.isBlank( nncBuyerDetails.Passport_Number__c ) ) ? nncBuyerDetails.Passport_Number__c : '';
		wrapper.AddressLine1  =  ( !String.isBlank( nncBuyerDetails.Address_Line_1__c ) ) ? nncBuyerDetails.Address_Line_1__c : '';
		wrapper.AddressLine2  =  ( !String.isBlank( nncBuyerDetails.Address_Line_2__c ) ) ? nncBuyerDetails.Address_Line_2__c : '';
		wrapper.AddressLine3  =  ( !String.isBlank( nncBuyerDetails.Address_Line_3__c ) ) ? nncBuyerDetails.Address_Line_3__c : '';
		wrapper.AddressLine4 =  ( !String.isBlank( nncBuyerDetails.Address_Line_4__c ) ) ? nncBuyerDetails.Address_Line_4__c : '';
		wrapper.City =  ( !String.isBlank( nncBuyerDetails.City__c ) ) ? nncBuyerDetails.City__c : '';
		wrapper.Country = ( !String.isBlank( nncBuyerDetails.Country__c ) ) ?  nncBuyerDetails.Country__c : '';
		wrapper.HomePhone = ( !String.isBlank( nncBuyerDetails.Home_Phone__c ) ) ?  nncBuyerDetails.Home_Phone__c : '';
		wrapper.Fax  = ( !String.isBlank( nncBuyerDetails.Fax__c ) ) ? nncBuyerDetails.Fax__c : '';
		wrapper.Mobile = ( !String.isBlank( nncBuyerDetails.Mobile__c ) ) ?  nncBuyerDetails.Mobile__c : '';
		wrapper.Email =  ( !String.isBlank( nncBuyerDetails.Email__c ) ) ?  nncBuyerDetails.Email__c : '';


		wrapper.MasterDeveloper = ( !String.isBlank( bookingUnitDetails.Inventory__r.Master_Developer_EN__c ) ) ?  bookingUnitDetails.Inventory__r.Master_Developer_EN__c : '';
		wrapper.UnitName  = ( !String.isBlank( bookingUnitDetails.Unit_Details__c ) ) ?  bookingUnitDetails.Unit_Details__c : '';
		wrapper.PropertyName = ( !String.isBlank( bookingUnitDetails.Inventory__r.Property__r.Name ) ) ?  bookingUnitDetails.Inventory__r.Property__r.Name : '';
		wrapper.PropertyAddress = ( !String.isBlank( bookingUnitDetails.Inventory__r.Building_Location__c ) ) ?  bookingUnitDetails.Inventory__r.Building_Location__c : '';
		wrapper.PropertyCity = ( !String.isBlank( bookingUnitDetails.Inventory__r.Property_City__c ) ) ? bookingUnitDetails.Inventory__r.Property_City__c : '';
		wrapper.SPADate  = ( !String.isBlank( String.valueof( bookingUnitDetails.Agreement_Date__c ) ) ) ? String.valueof( bookingUnitDetails.Agreement_Date__c ) : '';

		wrapper.ChangedFirstName =  ( !String.isBlank( nncBuyerDetails.First_Name__c ) ) ?  nncBuyerDetails.First_Name__c : '';
		wrapper.ChangedMiddleName =  ( !String.isBlank( nncBuyerDetails.Middle_Name__c ) ) ?  nncBuyerDetails.Middle_Name__c : ''; 
		wrapper.ChangedLastName = ( !String.isBlank( nncBuyerDetails.Last_Name__c ) ) ?   nncBuyerDetails.Last_Name__c : ''; 
		
		wrapper.ArrayOfUnitName = String.join(unitsforCustomer, ',');
		wrapper.ArrayOfPropertyName =  String.join(propertyNameforCustomer, ',');
		wrapper.ArrayOfPropertyAddress =  String.join(propertyAddressforCustomer, ',');
		wrapper.ArrayOfNationality =  ( !String.isBlank( nncBuyerDetails.Nationality__c ) ) ?   nncBuyerDetails.Nationality__c : '';


		//COCDFinalUpdate.undertakingChangeNameNationality lodauLink = COCDFinalUpdate.getUndertakingChangeNameNationality( wrapper );
		//lodauFormURL = lodauLink.url;
        lodauFormURL = COCDFinalUpdate.getUndertakingChangeNameNationality( wrapper );
	 }


	 public void getSOAURL() {
	 	soaFormURLs = new List<String>();
		system.debug( 'regIds : ' + regIds );
	 	if( regIds != '' && regIds != null ){
	 		for( String regid : regIds.split(',') ){
	 			GenerateSOAController.soaResponse response = GenerateSOAController.getSOADocument(regid);
	 			soaFormURLs.add( response.url );
	 		}
	 	}
         
		system.debug( 'soaFormURLs : ' + soaFormURLs );
    }  

    public void uploadAttachment( String strfileName, Blob objBody, Id parentId, String strType, String strAttachmentName ) {
		SR_Attachments__c srAttchmentObj = new SR_Attachments__c(Case__c = parentId,Type__c = strType,Name=strAttachmentName);
		insert srAttchmentObj;

		Attachment objAttach = new Attachment();
		objAttach.Body = objBody;
		objAttach.Name = strType + strfileName;
		objAttach.ParentId = srAttchmentObj.Id;

		insert objAttach;

		srAttchmentObj.Attachment__c = objAttach.Id;
		update srAttchmentObj;
	}

	private String extractName( String strName ) {
		return strName.substring( strName.lastIndexOf('\\')+1 ) ;
	}

	private Blob extractBody( String strBody ) {
		strBody = EncodingUtil.base64Decode( strBody ).toString();
		return EncodingUtil.base64Decode( strBody.substring( strBody.lastIndexOf(',')+1 ) );
	}

	private String extractType( String strName ) {
		strName = strName.substring( strName.lastIndexOf('\\')+1 );
		return strName.substring( strName.lastIndexOf('.')+1 ) ;
	}

	public class lodauWrapper{
		public String FirstName {get; set;}
		public String MiddleName {get; set;}
		public String LastName  {get; set;}
		public String Nationality   {get; set;}
		public String PassportNumber {get; set;}
		public String AddressLine1  {get; set;}
		public String AddressLine2  {get; set;}
		public String AddressLine3  {get; set;}
		public String AddressLine4 {get; set;}
		public String City {get; set;}
		public String Country {get; set;}
		public String HomePhone {get; set;}
		public String Fax  {get; set;}
		public String Mobile {get; set;}
		public String Email {get; set;}
		public String MasterDeveloper {get; set;}
		public String UnitName  {get; set;}
		public String PropertyName {get; set;}
		public String PropertyAddress {get; set;}
		public String PropertyCity {get; set;}
		public String SPADate  {get; set;}
		public String ChangedFirstName {get; set;}
		public String ChangedMiddleName {get; set;}
		public String ChangedLastName {get; set;}
		public String ArrayOfUnitName {get; set;}
		public String ArrayOfPropertyName {get; set;}
		public String ArrayOfPropertyAddress {get; set;}
		public String ArrayOfNationality {get; set;}
	}
}