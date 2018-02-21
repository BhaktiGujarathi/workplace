/*-------------------------------------------------------------------------------------------------
Description: Controller for FundTransferComponent

    ============================================================================================================================
        Version | Date(DD-MM-YYYY) | Comments
    ----------------------------------------------------------------------------------------------------------------------------
        1.0     | 11-10-2017       | Draft for Fund Transfer functionality
   =============================================================================================================================
*/

//Note: All the currency values are in User Currency Context
public with sharing class FundTransferComponentController {
	private Id accountId;
	public String userCurrencyISOCode {get;set;}
	private List<Booking_Unit__c> lstBookingUnit;
	public TransferWrapper wrapObj {get; set;}
	public Map<Id, Booking_Unit__c> mapBookingUnit;
	public Map<String, String> mapUnitNames;
	public String selectedUnitToShow {get;set;}
	public Boolean displayUnitDetails{get;set;}
	public static Booking_Unit__c selectedUnitToDisplay {get;set;}
	public Map<Id, Booking_Unit__c> mapTarget_BookingUnit {get;set;}
	public Map<String, String> mapTargetBookingUnit;

	public FundTransferComponentController() {
		userCurrencyISOCode = UserInfo.getDefaultCurrency();
		accountId = ApexPages.currentPage().getParameters().get('accID');
		mapBookingUnit = new Map<Id, Booking_Unit__c>();
		mapTarget_BookingUnit = new Map<Id, Booking_Unit__c>();
		mapTargetBookingUnit = new Map<String, String>();
		mapUnitNames = new Map<String, String>();
		displayUnitDetails = false;
		selectedUnitToDisplay = new Booking_Unit__c();
		System.debug('===accountId==' + accountId);
		lstBookingUnit = new List<Booking_Unit__c>();
		wrapObj = new TransferWrapper();
		selectedUnitToShow = '--None--';//Set default

		wrapObj.lst_POAOptions.add(new SelectOption('--None--', '--None--'));
		wrapObj.lst_POAOptions.add(new SelectOption('Yes', 'Yes'));
		wrapObj.lst_POAOptions.add(new SelectOption('No', 'No'));


		//Populating picklist to show details about selected unit
		wrapObj.lstUnitDetails.add(new SelectOption('Unit Details', 'Unit Details'));
        wrapObj.lstUnitDetails.add(new SelectOption('Flags', 'Flags'));
        wrapObj.lstUnitDetails.add(new SelectOption('Unit Status', 'Unit Status'));
        wrapObj.lstUnitDetails.add(new SelectOption('Open SRs', 'Open SRs'));

		//Temporary static data
		wrapObj.decAmountCollectedAsEOI = 0;
		wrapObj.strEOIRefNumber = 'REF 420';
		wrapObj.decTotalFundAlloted = 0;
		init();
	}

	public void submitFundTransfer() {

	}

	public void saveAsDraft() {
		//Get Record type Id for Case Fund Transfer record type
		Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fund Transfer').getRecordTypeId();
		Case objCase = new Case();
		objCase.RecordTypeId = caseRecTypeId;
		objCase.AccountId = accountId;
		insert objCase;
		SR_Attachments__c objSRAtt = new SR_Attachments__c();
		objSRAtt.Type__c = 'Power Of Attorney';
		objSRAtt.Case__c = objCase.Id;
		insert objSRAtt;

		// objCase.POA_Relationship_with_Seller__c
	}

	private void init() {

		if(accountId !=null) {
			lstBookingUnit = [Select Id, Registration_ID__c, Name, Inventory__r.Unit__c,
                          Inventory__r.Property__r.Name,Inventory__r.Property_Name_2__c,
                          Inventory__r.IPMS_Bedrooms__c,Inventory__r.Selling_Price__c,/*convertCurrency*/Selling_Price__c,
                          Inventory__r.Price_Per_Sqft__c,Inventory__r.Property_Status__c,
                          Inventory__r.Anticipated_Completion_Date__c,
                          Inventory__r.Property__c,Inventory__r.Property_City__c,
                          Inventory__r.Unit_Type__c,Permitted_Use__c,Inventory__r.Area_Sqft_2__c,
                          Inventory__r.Construction_Status__c,Revised_Price_Area_Variation__c,
                          Rebate_Given__c,Rental_Pool_Agreement__c,RERA_Project__c,Booking_Location__c,
                          Dispute_Flag__c,Handover_Flag__c,PCC_Generate__c,
                          Early_Handover__c, Unit_Details__c,Special_Price__c,Inventory__r.Bedroom_Type__c,
						  Rental_Pool__c, OQOOD_Reg_Flag__c,PCC_Release__c,Agent_Name__c
                          From Booking_Unit__c
                          Where Booking__r.Account__c =: accountId];
		}
		if(! lstBookingUnit.isEmpty()) {
			wrapObj.lstSourceUnits = new List<SelectOption>();
			for(Booking_Unit__c objBU: lstBookingUnit) {
				wrapObj.lstSourceUnits.add(new SelectOption(objBU.Id, objBU.Unit_Details__c));
                mapBookingUnit.put(objBU.Id, objBU);
				mapUnitNames.put(objBU.Id, objBU.Unit_Details__c);
            }
			// getBookingUnits();
		}

		//Getting Target Customer Details
		wrapObj.lstCustomers.add(new SelectOption('--None--', '--None--'));
		for(Account objAcc : [select Id,Name from Account where Id IN (select Account__c from Booking__c) LIMIT 5]) {
			wrapObj.lstCustomers.add(new SelectOption(objAcc.Id, objAcc.Name));
		}
	}

	public void getCustomerRelatedUnits() {
		System.debug('=wrapObj.selectedCustomers===' + wrapObj.selectedCustomers);
		wrapObj.lstTargetUnits = new List<SelectOption>();
		wrapObj.lstTargetBookingUnit = new List<Booking_Unit__c>();
		if(wrapObj.selectedCustomers.size() > 1) {//Including None value
			wrapObj.lstTargetBookingUnit = [Select Id, Registration_ID__c, Name, Inventory__r.Unit__c,/*convertCurrency*/Selling_Price__c,
			                          Inventory__r.Property__r.Name,Inventory__r.Property_Name_2__c,
			                          Inventory__r.IPMS_Bedrooms__c,Inventory__r.Selling_Price__c,
			                          Inventory__r.Price_Per_Sqft__c,Inventory__r.Property_Status__c,
			                          Inventory__r.Anticipated_Completion_Date__c,
			                          Inventory__r.Property__c,Inventory__r.Property_City__c,
			                          Inventory__r.Unit_Type__c,Permitted_Use__c,Inventory__r.Area_Sqft_2__c,
			                          Inventory__r.Construction_Status__c,Revised_Price_Area_Variation__c,
			                          Rebate_Given__c,Rental_Pool_Agreement__c,RERA_Project__c,Booking_Location__c,
			                          Dispute_Flag__c,Handover_Flag__c,PCC_Generate__c,
			                          Early_Handover__c, Unit_Details__c,Special_Price__c,Inventory__r.Bedroom_Type__c,
									  Rental_Pool__c, OQOOD_Reg_Flag__c,PCC_Release__c,Agent_Name__c,Booking__r.Account__c,
									  Booking__r.Account__r.Name
			                          From Booking_Unit__c
			                          Where Booking__r.Account__c IN : wrapObj.selectedCustomers];

		}
		System.debug('=wrapObj.lstTargetBookingUnit===' + wrapObj.lstTargetBookingUnit);
		if(! wrapObj.lstTargetBookingUnit.isEmpty()) {
			for(Booking_Unit__c objBU : wrapObj.lstTargetBookingUnit) {
				wrapObj.lstTargetUnits.add(new SelectOption(objBU.Unit_Details__c + ',' + objBU.Booking__r.Account__r.Name + ',' + objBU.Id
				, objBU.Unit_Details__c));
				mapTargetBookingUnit.put(objBU.Id, objBU.Unit_Details__c);
				mapTarget_BookingUnit.put(objBU.Id, objBU);
			}
		}
	}

	public void getTargetUnitsSelected() {
		System.debug('===wrapObj.lstSelectedTargetUnits===' + wrapObj.lstSelectedTargetUnits);
		wrapObj.lstFunAllocation = new List<FundAllocation>();
		wrapObj.lstSelectedTargetUnitsOption = new list<SelectOption>();
		wrapObj.strTargetSelectedUnitDetail = 'Unit Details';
		wrapObj.lstFunAllocation = new List<FundAllocation>();
		wrapObj.lstSelectedTargetUnitsOption.add(new SelectOption('--None--', '--None--'));
		map<String, List<String>> mapCustomer_BUs = new map<String, List<String>>();
		for(String str: wrapObj.lstSelectedTargetUnits) {
			List<String> strTemp = str.split(',');
			if(mapCustomer_BUs.containsKey(strTemp[1])) {
				mapCustomer_BUs.get(strTemp[1]).add(strTemp[0]);
			}
			else {
				mapCustomer_BUs.put(strTemp[1],new String[] {strTemp[0]});
			}
			if(mapTargetBookingUnit.containsKey(strTemp[2])) {
				wrapObj.lstSelectedTargetUnitsOption.add(new SelectOption(str, mapTargetBookingUnit.get(strTemp[2])));
			}

		}
		System.debug('===wrapObj.lstSelectedTargetUnitsOption===' + wrapObj.lstSelectedTargetUnitsOption);
		//Populating Fund Allocation section for Customer
		for(String str: mapCustomer_BUs.keySet()) {
			System.debug('===mapCustomer_BUs.get(str)===' + mapCustomer_BUs.get(str));
			for(String unitName: mapCustomer_BUs.get(str)) {
				wrapObj.lstFunAllocation.add(new FundAllocation(str, unitName));
			}
		}
	}


	public void getUnitDetails() {
		System.debug('=====' + wrapObj.lstSelectedSourceUnits);
		if(wrapObj.lstSelectedSourceUnits.size() > 0) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please select source unit details'));
		}

		displayUnitDetails = wrapObj.lstSelectedSourceUnits.size() > 0 ? true : false;
		wrapObj.lstSelectedBookingUnit = new List<Booking_Unit__c>();
		wrapObj.decAmountCollected_Available = 0.0;
		wrapObj.lstSelectedUnits = new list<SelectOption>();
		wrapObj.lstSelectedUnits.add(new SelectOption('--None--', '--None--'));
		for(Id bookingId :wrapObj.lstSelectedSourceUnits) {
			wrapObj.lstSelectedBookingUnit.add(mapBookingUnit.get(bookingId));
			wrapObj.decAmountCollected_Available += mapBookingUnit.get(bookingId).Selling_Price__c;
			wrapObj.lstSelectedUnits.add(new SelectOption(bookingId, mapBookingUnit.get(bookingId).Unit_Details__c));
		}
		wrapObj.strSelectedUnitDetail = 'Unit Details';
		System.debug('=mapBookingUnit====' + mapBookingUnit);
		System.debug('===lstSelectedSourceUnits==' + wrapObj.lstSelectedSourceUnits);
		wrapObj.decAvailableLimit = wrapObj.decAmountCollected_Available;

		// getDetailsForSelectedUnit();
	}

	public void getDetailsForSelectedUnit() {
		System.debug('=selectedUnitToShow====' + selectedUnitToShow);
		System.debug('wrapObj.strSelectedUnitDetail====' + wrapObj.strSelectedUnitDetail);
		if(selectedUnitToShow != '--None-- ') {
			Booking_Unit__c objBU = mapBookingUnit.get(selectedUnitToShow);
			System.debug('=objBU====' + objBU);
			wrapObj.objCurrentWBU = new WrapperBookingUnit();
			//Fields for Unit Dertais  section
			wrapObj.objCurrentWBU.strAgreementStatus = 'Test Status';//Will come from IPMS
			wrapObj.objCurrentWBU.blnOQOODregistered = objBU.OQOOD_Reg_Flag__c;
			wrapObj.objCurrentWBU.strUnderTermination = 'Test Data';//Will come from IPMS
			wrapObj.objCurrentWBU.blnFTLsent = false;//Will come from IPMS
			wrapObj.objCurrentWBU.strProject = objBU.Inventory__r.Property__r.Name;
			wrapObj.objCurrentWBU.strProjectCity = objBU.Inventory__r.Property_City__c;
			wrapObj.objCurrentWBU.strBedroomType = objBU.Inventory__r.Bedroom_Type__c;
			wrapObj.objCurrentWBU.strUnitType = objBU.Inventory__r.Unit_Type__c;
			wrapObj.objCurrentWBU.strPermittedUse = objBU.Permitted_Use__c;
			wrapObj.objCurrentWBU.strReady_OffPlan = objBU.Inventory__r.Property_Status__c;
			wrapObj.objCurrentWBU.strRentalPool = objBU.Rental_Pool__c ? 'YES' : 'NO';
			//Fields for Flag section
			wrapObj.objCurrentWBU.blnDispute = false;
			wrapObj.objCurrentWBU.blnEnforcement = false;
			wrapObj.objCurrentWBU.blnLitigation = false;
			wrapObj.objCurrentWBU.blnMortage = false;
			wrapObj.objCurrentWBU.blnCourtCase = false;
			//Fields for Unit Status section
			wrapObj.objCurrentWBU.blnEHO = objBU.Early_Handover__c;
			wrapObj.objCurrentWBU.strHO = objBU.Handover_Flag__c;
			wrapObj.objCurrentWBU.blnPCC = objBU.PCC_Release__c;

			//Details for Additional Information section
			wrapObj.objCurrentWBU.intPenaltyAmount = 0;//Total Penalties Amount for Unit - IPMS
			wrapObj.objCurrentWBU.strPC_AgentName = objBU.Agent_Name__c;
			wrapObj.objCurrentWBU.strDocsStatus = 'OK';
			wrapObj.objCurrentWBU.intConversationStatus = 2;//Can be ignored - confirmed by business
			wrapObj.objCurrentWBU.intOverdue = 2400;//Total Overdue - IPMS
			wrapObj.objCurrentWBU.intRERAstatus = 40;//Will come from IPMS
			wrapObj.objCurrentWBU.strOriginalACD = 'Sample Data';//Will come from IPMS
			wrapObj.objCurrentWBU.strCurrentACD = 'Sample Data';//Will come from IPMS
			wrapObj.objCurrentWBU.strConstructionStatus = 'Sample Data';//Will come from IPMS
			wrapObj.objCurrentWBU.decConstructionStatusPercent = 0;//Will come from IPMS
			wrapObj.objCurrentWBU.decAreaVariation_SqFt = 12;//Will come from IPMS
			wrapObj.objCurrentWBU.strTypeVariation = 'Sample Data';//Will come from IPMS
			wrapObj.objCurrentWBU.decOtherCharges = 40;//Will come from IPMS
			wrapObj.objCurrentWBU.decPaidPercent = 40;//Will come from IPMS
			wrapObj.objCurrentWBU.decPDCcoveragePercent = 40;//Will come from IPMS
			wrapObj.objCurrentWBU.intNoOfTimesCusDefaulted = 40;//Will come from IPMS
			wrapObj.objCurrentWBU.blnRecoveryFlag = false;//Will come from IPMS
			wrapObj.objCurrentWBU.blnPriorAOPT = true;//Will come from Salesforce
			wrapObj.objCurrentWBU.decTotalOutstanding = 40;//Will come from IPMS
			wrapObj.objCurrentWBU.decDefaultAmt = 40;//Will come from IPMS
			wrapObj.objCurrentWBU.decPenaltyOverdues = 40;//Will come from IPMS
			wrapObj.objCurrentWBU.decPenaltyWaivers = 40;//Will come from IPMS
		}
	}

	public void getDetailsForTargetUnit() {
		System.debug('=wrapObj.strTargetUnitDetail====' + wrapObj.strTargetUnitDetail);

		if(wrapObj.strTargetUnitDetail != '--None--') {
			//Split the selected target unit to get Booking unit Id
			String objBUId = wrapObj.strTargetUnitDetail.split(',')[2];
			System.debug('wrapObj.strSelectedUnitDetail====' + wrapObj.strSelectedUnitDetail);
			wrapObj.strTargetSelectedUnitDetail = 'Unit Details';
			Booking_Unit__c objBU = mapTarget_BookingUnit.get(objBUId);
			System.debug('=objBU====' + objBU);
			wrapObj.objTargetUnitWBU = new WrapperBookingUnit();
			//Fields for Unit Dertais  section
			wrapObj.objTargetUnitWBU.strAgreementStatus = 'Test Status';//Will come from IPMS
			wrapObj.objTargetUnitWBU.blnOQOODregistered = objBU.OQOOD_Reg_Flag__c;
			wrapObj.objTargetUnitWBU.strUnderTermination = 'Test Data';//Will come from IPMS
			wrapObj.objTargetUnitWBU.blnFTLsent = false;//Will come from IPMS
			wrapObj.objTargetUnitWBU.strProject = objBU.Inventory__r.Property__r.Name;
			wrapObj.objTargetUnitWBU.strProjectCity = objBU.Inventory__r.Property_City__c;
			wrapObj.objTargetUnitWBU.strBedroomType = objBU.Inventory__r.Bedroom_Type__c;
			wrapObj.objTargetUnitWBU.strUnitType = objBU.Inventory__r.Unit_Type__c;
			wrapObj.objTargetUnitWBU.strPermittedUse = objBU.Permitted_Use__c;
			wrapObj.objTargetUnitWBU.strReady_OffPlan = objBU.Inventory__r.Property_Status__c;
			wrapObj.objTargetUnitWBU.strRentalPool = objBU.Rental_Pool__c ? 'YES' : 'NO';
			//Fields for Flag section
			wrapObj.objTargetUnitWBU.blnDispute = false;
			wrapObj.objTargetUnitWBU.blnEnforcement = false;
			wrapObj.objTargetUnitWBU.blnLitigation = false;
			wrapObj.objTargetUnitWBU.blnMortage = false;
			wrapObj.objTargetUnitWBU.blnCourtCase = false;
			//Fields for Unit Status section
			wrapObj.objTargetUnitWBU.blnEHO = objBU.Early_Handover__c;
			wrapObj.objTargetUnitWBU.strHO = objBU.Handover_Flag__c;
			wrapObj.objTargetUnitWBU.blnPCC = objBU.PCC_Release__c;

			//Details for Additional Information section
			wrapObj.objTargetUnitWBU.intPenaltyAmount = 0;//Total Penalties Amount for Unit - IPMS
			wrapObj.objTargetUnitWBU.strPC_AgentName = objBU.Agent_Name__c;
			wrapObj.objTargetUnitWBU.strDocsStatus = 'OK';
			wrapObj.objTargetUnitWBU.intConversationStatus = 2;//Can be ignored - confirmed by business
			wrapObj.objTargetUnitWBU.intOverdue = 2400;//Total Overdue - IPMS
			wrapObj.objTargetUnitWBU.intRERAstatus = 40;//Will come from IPMS
			wrapObj.objTargetUnitWBU.strOriginalACD = 'Sample Data';//Will come from IPMS
			wrapObj.objTargetUnitWBU.strCurrentACD = 'Sample Data';//Will come from IPMS
			wrapObj.objTargetUnitWBU.strConstructionStatus = 'Sample Data';//Will come from IPMS
			wrapObj.objTargetUnitWBU.decConstructionStatusPercent = 0;//Will come from IPMS
			wrapObj.objTargetUnitWBU.decAreaVariation_SqFt = 12;//Will come from IPMS
			wrapObj.objTargetUnitWBU.strTypeVariation = 'Sample Data';//Will come from IPMS
			wrapObj.objTargetUnitWBU.decOtherCharges = 40;//Will come from IPMS
			wrapObj.objTargetUnitWBU.decPaidPercent = 40;//Will come from IPMS
			wrapObj.objTargetUnitWBU.decPDCcoveragePercent = 40;//Will come from IPMS
			wrapObj.objTargetUnitWBU.intNoOfTimesCusDefaulted = 40;//Will come from IPMS
			wrapObj.objTargetUnitWBU.blnRecoveryFlag = false;//Will come from IPMS
			wrapObj.objTargetUnitWBU.blnPriorAOPT = true;//Will come from Salesforce
			wrapObj.objTargetUnitWBU.decTotalOutstanding = 40;//Will come from IPMS
			wrapObj.objTargetUnitWBU.decDefaultAmt = 40;//Will come from IPMS
			wrapObj.objTargetUnitWBU.decPenaltyOverdues = 40;//Will come from IPMS
			wrapObj.objTargetUnitWBU.decPenaltyWaivers = 40;//Will come from IPMS
		}
	}

	public class TransferWrapper {
		//POA Variables
		public String strPOA_Name {get; set;}
		public String strPOA_Purpose {get; set;}
		public String strPOA_ExpiryDate {get; set;}
		public String strPOA_IssuedBy {get; set;}
		public List<SelectOption> lst_POAOptions {get; set;}
		public String strSelected_POAOption {get; set;}
		public Decimal decTotalFundAlloted {get;set;}
		public Decimal decAvailableLimit {get;set;}

        public List<SelectOption> lstSourceUnits {get; set;}
		public Decimal decAmountCollectedAsEOI {get; set;}
		public Decimal decAmountCollected_Available {get; set;}
        public List<SelectOption> lstTargetUnits {get; set;}
		public List<SelectOption> lstSelectedTargetUnitsOption {get; set;}//Selected target Units
		public List<Booking_Unit__c> lstSelectedBookingUnit {get;set;}
        public List<String> lstSelectedSourceUnits {get; set;}
		public List<SelectOption> lstSelectedUnits {get; set;}
		public List<SelectOption> lstCustomers {get; set;}//To display Customers
		public List<String> selectedCustomers {get;set;}
		public List<Booking_Unit__c> lstTargetBookingUnit {get;set;}//Units from target customers
		public List<String> lstSelectedTargetUnits {get;set;}
		public String strTargetUnitDetail {get; set;}
		public String strTargetSelectedUnitDetail {get; set;}
        public String strSelectedTargetUnit {get; set;}
		public String strEOIRefNumber {get; set;}//Used for EOI Reference Number
        public Decimal decSourceUnitAmount {get; set;}
        public Decimal decTargetUnitAmount {get; set;}
        public List<SelectOption> lstUnitDetails {get; set;}// Options to display which details to be displayed
        public String strSelectedUnitDetail {get; set;}//Used to hold selected unit to display more details
        public Boolean isShowUnitDetails {get; set;}
        public String strCurrentUnit {get; set;}
        public List<SelectOption> lstAllocations {get; set;}
        public String strSelectedAllocation {get; set;}
        public String strCreditNote {get; set;}
        public Decimal decEOIAmount {get; set;}
        public WrapperBookingUnit objSourceUnitWBU {get; set;}
        public WrapperBookingUnit objTargetUnitWBU {get; set;}
        public WrapperBookingUnit objCurrentWBU {get; set;}
		public list<FundAllocation> lstFunAllocation {get; set;}

		public TransferWrapper() {
			lstSelectedTargetUnitsOption = new List<SelectOption>();
			lstTargetUnits = new List<SelectOption>();
			lstSelectedSourceUnits = new list<String>();
			lstSelectedBookingUnit = new List<Booking_Unit__c>();
			lstTargetBookingUnit = new List<Booking_Unit__c>();
			lstSelectedUnits = new List<SelectOption>();
			lstUnitDetails  = new List<SelectOption>();
			objCurrentWBU = new WrapperBookingUnit();
			lstCustomers  = new List<SelectOption>();
			lstSelectedTargetUnits = new list<String>();
			lstFunAllocation = new list<FundAllocation>();
			selectedCustomers = new List<String>();
			lst_POAOptions = new List<SelectOption>();
		}

    }

	//Wrapper class Fund Allocation
	public class FundAllocation {
		public Decimal fundAllocated{get;set;}
		public String customerName {get;set;}
		public String unitName {get;set;}
		public FundAllocation(String customerName, String unitName) {
			this.unitName = unitName;
			this.customerName = customerName;
		}
	}

}