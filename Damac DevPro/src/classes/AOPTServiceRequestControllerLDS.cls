/* Class Functionality : It is used to handle processing of AOPT SR
* Revision History: 
* Version     Author                Date             Description.
* 1.1         Eternus Solutions     17/08/2017       Initial Draft
*/
public with sharing class AOPTServiceRequestControllerLDS 
{ 

  //String properties
  public String strSelectedProject { get;set; }
  public String strBookingUnit { get;set; }
  public String strNewPaymentPlan { get;set; }
  public String strUnitDetailType { get;set; }
  public String strAOPTEligibilityErrors { get;set; }
  public String strIsPOA { get;set; }
  public String dtDateOfExpiry { get;set; }
  public String strIssuedBy { get;set; }
  public String strTypeOfDoc { get;set; }
  public String strCaseID { get;set; }
  public String strAccID { get;set; }
  public String RemoveSelected { get;set; }
  public String strPaymentPlanType { get;set; }
  public String strCaseStatusSubmitted { get;set; }
  public String strSelectedBookingUnit {get;set;}
  public String strApprovingAuthority;

  public transient String strCRFAttachmentBody { get; set; }
  public transient String strCRFAttachmentName { get; set; }
  public transient String strPOAAttachmentBody { get; set; }
  public transient String strPOAAttachmentName { get; set; }
  public transient String strOfferAttachmentBody { get; set; }
  public transient String strOfferAttachmentName { get; set; }
  public transient String strPDCAttachmentBody { get; set; }
  public transient String strPDCAttachmentName { get; set; }
  

  //Integer properties
  public Integer rowToRemove {get;set;}
  public Integer percentValueTotalCurPP {get;set;}
  public Integer percentValueTotalNewPP1 {get;set;}
  public Integer rowToFetchArabic {get;set;}
  
  //Object properties
  public Booking__c objBooking {get;set;}
  public Account objAccount {get;set;}
  public Booking_Unit__c objBookingUnitToDisplay {get;set;}
  public WrapperBookingUnit objWrapperBookingUnit {get;set;}
  public UnitDetailsService.BookinUnitDetailsWrapper objBUDetailWrapper {get;set;}
  public Case objCase {get;set;}

  //Boolean properties
  public Boolean blnShowSelectedUnits {get;set;}
  public Boolean blnShowCurrentPP {get;set;}
  public Boolean blnShowNewCurrentPP {get;set;}
  public Boolean blnIsAOPTEligible {get;set;}
  public Boolean blnIsAOPTNotEligible {get;set;}
  public Boolean blnShowCRF {get;set;}
  public Boolean blnShowPOA {get;set;}
  public Boolean blnShowCRFPOASection {get;set;}
  public Boolean blnAOPTExists {get;set;}
  public Boolean blnFlagPresent {get;set;}
  public Boolean blnCRFValid {get;set;}
  public Boolean blnPOAValid {get;set;}
  public Boolean blnEnableViewCRFBtn {get;set;}
  public Boolean blnEnableDownloadCRFBtn {get;set;}
  public Boolean blnOfferAccepted {get;set;}

  //List properties
  public List<SelectOption> lstProjectSelectOption {get;set;}
  public List<SelectOption> lstBookingUnitSelectOption {get;set;}
  public List<SelectOption> lstAllBookingUnitsSelectOption {get;set;}
  public List<Payment_Terms__c> lstPaymentTerms {get;set;}
  public List<NewPaymentTermsWrapper> lstNewPaymentTermsDisplay {get;set;}
  public List<BookingUnitWrapper> lstBookingUnitWrapper {get;set;}
  public List<Case> lstOpenSRs {get;set;}
  public List<Case> lstClosedSRs {get;set;}
  public List<SelectOption> mileStoneEventPT {get;set;}// used to store the ME retrieved from EP
  public List<SR_Attachments__c> lstSRCREattachments {get;set;}
  public List<SR_Attachments__c> lstSPOAattachments {get;set;}
  public List<SR_Attachments__c> lstSPDCattachments {get;set;}
  public List<SOAWrapper> lstSOAWrapper {get;set;}
  
  

  //Map properties
  Map<Id,List<Booking_Unit__c>> mapProjectIdToBookingUnit  = new Map<Id,List<Booking_Unit__c>>();
  Map<String,List<NewPaymentTermsWrapper>> mapNewPaymentTermsWrapper = new Map<String,list<NewPaymentTermsWrapper>>();
  Map<Id,UnitDetailsService.BookinUnitDetailsWrapper> mapBuIDToBUDetails = new Map<Id,UnitDetailsService.BookinUnitDetailsWrapper>();

  // it is used to store the Milestone(Normal,Arabic) fetched from IPMS.
  public Map<String,String> mapMileStoneEvents {get;set;}

  //Constructor
  public AOPTServiceRequestControllerLDS()
  {
    strCaseID = ApexPages.currentPage().getParameters().get('caseID');

    strAccID = ApexPages.currentPage().getParameters().get('AccountId');

    system.debug('strCaseID '+strCaseID);
    system.debug('strAccID '+strAccID);
    
    init();
    system.debug('blnCRFValid '+blnCRFValid);
  }

  // init method used to setup test data and other initialization params
  private void init()
  { 
    
    blnShowSelectedUnits = false;
    blnShowCurrentPP = false;
    blnShowNewCurrentPP = false;
    blnIsAOPTEligible = false;
    blnIsAOPTNotEligible = false;
    blnShowCRF = false;
    blnShowPOA = false;
    blnShowCRFPOASection = false;
    blnAOPTExists = false;
    blnFlagPresent = false;
    blnEnableViewCRFBtn = false;
    blnEnableDownloadCRFBtn = false;
    blnOfferAccepted = false;

    if(String.isNotBlank(strCaseID) && String.isNotBlank(strAccID))
    {
      objCase = new Case();
      //enable view CRF and Download CRF button 
      blnEnableDownloadCRFBtn = true;

      //fetch case details 
      objCase = [ SELECT 
                        Id
                        ,AOPT_IsPDC_Provided__c
                        ,Case_Summary__c
                        ,Status
                        ,Approval_Status__c
                        ,POA_Expiry_Date__c
                        ,IsPOA__c,POA_Issued_By__c
                        ,POA_Name__c
                        ,POA_Relationship_with_Buyer__c
                        ,Offer_Acceptance_Letter_Generated__c,Purpose_of_POA__c 
                  FROM Case WHERE ID =:strCaseID
                ];
      if(objCase.POA_Expiry_Date__c != null)
      {
        dtDateOfExpiry = objCase.POA_Expiry_Date__c.format();
      }
      
      system.debug('in Constructor after objCase query');
      if( objCase.Approval_Status__c !=null && objCase.Approval_Status__c.equalsIgnoreCase('Approved')
          && (objCase.Status.equalsIgnoreCase('Submitted') || objCase.Status.equalsIgnoreCase('Approved')) 
          && objCase.Offer_Acceptance_Letter_Generated__c)
      {
        blnOfferAccepted = true;
      }

      if( objCase.IsPOA__c )
      {
        strIsPOA = 'Yes';
      }
      else
      {
        strIsPOA = 'No';
      }
      //getCustomerPortfolio();
      getProjectsForCustomer();
      getBookingUnitsRelatedToProject();
      checkValidity();
      aoptValidate();
      getAttachments();
    }
    else
    {

      blnShowCRF = true;
      getProjectsForCustomer();
    }
  }

  // method used to retrieve attachments for CRF,POA,PDC,etc
  public void getAttachments()
  {
    lstSRCREattachments = new List<SR_Attachments__c>();
    lstSPOAattachments = new List<SR_Attachments__c>();
    lstSPDCattachments = new List<SR_Attachments__c>();

    lstSRCREattachments = [SELECT id
                                  ,Name,IsValid__c
                                  ,Type__c,Attachment__c 
                          FROM SR_Attachments__c 
                          WHERE Case__c =: strCaseID AND (Type__c ='CRF Form')
                          ];

    lstSPOAattachments = [SELECT id,Name
                          ,IsValid__c,Type__c
                          ,Attachment__c 
                          FROM SR_Attachments__c 
                          WHERE Case__c =: strCaseID AND (Type__c = 'Power Of Attorney')
                          ];

    lstSPDCattachments = [SELECT id,name,
                          IsValid__c,Type__c
                          ,Attachment__c 
                          FROM SR_Attachments__c 
                          WHERE Case__c =: strCaseID AND (Type__c = 'PDC')
                          ];
    
    system.debug('lstSPOAattachments '+lstSPOAattachments.size());
    if(lstSRCREattachments.size() > 0)
    {
      for(SR_Attachments__c objSRAttachment : lstSRCREattachments)
      {
        if( objSRAttachment.Type__c != null && objSRAttachment.Type__c.equalsIgnoreCase('CRF Form') )
            //&& objSRAttachment.isValid__c)
        {
          blnCRFValid = true;
          blnShowCRF = true;
          blnEnableViewCRFBtn = true;
        }
      }
    }
    
    if(lstSPOAattachments.size() > 0)
    {
      for(SR_Attachments__c objSRAttachment : lstSPOAattachments)
      {
        if( objSRAttachment.Type__c != null && objSRAttachment.Type__c.equalsIgnoreCase('Power Of Attorney') )
            //&& objSRAttachment.isValid__c)
        {
          blnPOAValid = true;
          blnShowPOA = true;
        }
      }
    }
  }

  // method used to retrieve customer portfolio details
 /* public void getCustomerPortfolio()
  {
    objAccount = [ SELECT Id,Name,Title__c
                  ,PersonTitle,PersonMobilePhone
                  ,PersonEmail,FirstName,LastName
                  ,MiddleName,Party_ID__c,Nationality__pc
                  ,Party_Type__c,Passport_Number__c,CR_Number__c,Address
                  FROM Account WHERE ID = : strAccID ];
  }
  */
  // method used to get Project for Customer
  public void getProjectsForCustomer()
  { 
    lstProjectSelectOption = new List<SelectOption>();
    lstProjectSelectOption.add(new selectOption('None','--None--'));
    if(String.isNotBlank(strCaseID) && String.isNotBlank(strAccID) && objCase.Status.equalsIgnoreCase('Submitted'))
    {
      SR_Booking_Unit__c objSRBookingUnit = [ SELECT Id,Name,Property_Name__c  
                                              FROM SR_Booking_Unit__c 
                                              WHERE Case__c =:strCaseID LIMIT 1
                                            ];

      lstProjectSelectOption.add(new selectOption(objSRBookingUnit.Property_Name__c, objSRBookingUnit.Property_Name__c));
      strSelectedProject = objSRBookingUnit.Property_Name__c;
    }
    else if( objCase == null || (String.isNotBlank(objCase.Status) && objCase.Status.equalsIgnoreCase('New')) )
    {
      for(Booking_Unit__c objBookingUnit : [ SELECT Id,Name,Registration_ID__c,Inventory__r.Unit__c
                                             ,Inventory__r.Property_Name_2__c
                                             ,Inventory__r.IPMS_Bedrooms__c,Inventory__r.Selling_Price__c
                                             ,Inventory__r.Price_Per_Sqft__c,Inventory__r.Property_Status__c
                                             ,Inventory__r.Anticipated_Completion_Date__c
                                             ,Inventory__r.Property__r.Name
                                             ,Inventory__r.Property__c,Unit_Details__c
                                             FROM Booking_Unit__c 
                                             WHERE Booking__r.Account__c =: strAccID
                                    ])
      {
        lstProjectSelectOption.add(new selectOption(objBookingUnit.Inventory__r.Property__c, objBookingUnit.Inventory__r.Property__r.Name));
        //strSelectedProject = objBookingUnit.Inventory__r.Property__c;
        if(mapProjectIdToBookingUnit.containsKey(objBookingUnit.Inventory__r.Property__c) && mapProjectIdToBookingUnit.get(objBookingUnit.Inventory__r.Property__c) != null)
        {
          List<Booking_Unit__c> lstBookingUnit = mapProjectIdToBookingUnit.get(objBookingUnit.Inventory__r.Property__c);
          lstBookingUnit.add(objBookingUnit);
          mapProjectIdToBookingUnit.put( objBookingUnit.Inventory__r.Property__c,lstBookingUnit);
        }
        else
        {
          mapProjectIdToBookingUnit.put(objBookingUnit.Inventory__r.Property__c,new List<Booking_Unit__c>{objBookingUnit});
        }
      }
        if(lstProjectSelectOption != null && lstProjectSelectOption.size() > 0)
        {
          Set<SelectOption> myset = new Set<SelectOption>();
          myset.addAll(lstProjectSelectOption);
          lstProjectSelectOption.clear();
          lstProjectSelectOption.addAll(myset);
          strSelectedProject = lstProjectSelectOption.get(1).getValue();

          getBookingUnitsRelatedToProject();
        }
    }
  }

  // method used to get all Booking Units related to specific Project
  public PageReference getBookingUnitsRelatedToProject()
  {
    system.debug('strSelectedProject '+strSelectedProject);
    system.debug('mapProjectIdToBookingUnit '+mapProjectIdToBookingUnit);

    lstBookingUnitSelectOption = new List<SelectOption>();
    lstAllBookingUnitsSelectOption = new List<SelectOption>();
    lstBookingUnitWrapper = new List<BookingUnitWrapper>();

    if(String.isNotBlank(strCaseID) && String.isNotBlank(strAccID) && objCase.Status.equalsIgnoreCase('Submitted'))
    {
      Set<Id> bookingUnitIDSet = new Set<Id>();
      for(SR_Booking_Unit__c objSRBookingUnit : [ SELECT Id,Name
                                                  ,Booking_Unit__c,Booking_Unit__r.Unit_Details__c
                                                  ,Booking_Unit__r.Name,Booking_Unit__r.Inventory__r.Unit__c 
                                                  FROM SR_Booking_Unit__c WHERE Case__c =: strCaseID
                                                  ])
      {
          lstBookingUnitSelectOption.add(new selectOption(objSRBookingUnit.Booking_Unit__c, objSRBookingUnit.Booking_Unit__r.Name +'-'+objSRBookingUnit.Booking_Unit__r.Inventory__r.Unit__c+'-'+objSRBookingUnit.Booking_Unit__r.Unit_Details__c));
          bookingUnitIDSet.add(objSRBookingUnit.Booking_Unit__c);
          
      }

      for(Booking_Unit__c objBookingUnit : [ SELECT Id,Inventory__r.Unit__c,Inventory__r.Property_Name_2__c
                                             ,Inventory__r.IPMS_Bedrooms__c,Inventory__r.Selling_Price__c
                                             ,Inventory__r.Price_Per_Sqft__c,Inventory__r.Property_Status__c
                                             ,Inventory__r.Anticipated_Completion_Date__c
                                             ,Inventory__r.Property__r.Name
                                             ,Inventory__r.Property__c,Name,Unit_Details__c 
                                             FROM Booking_Unit__c WHERE ID IN: bookingUnitIDSet
                                    ])
      {
        lstBookingUnitWrapper.add(new BookingUnitWrapper(objBookingUnit,true,'Yes'));
        lstAllBookingUnitsSelectOption.add(new selectOption(objBookingUnit.Id,objBookingUnit.Name+' - '+objBookingUnit.Inventory__r.Unit__c+'-'+objBookingUnit.Unit_Details__c));
      }
      strBookingUnit = (new list<Id>(bookingUnitIDSet) )[0];
      getCurrentPaymentTerm();
    }
    else if( objCase == null || objCase.Status.equalsIgnoreCase('New') )
    {
      blnShowSelectedUnits = false;
      blnShowCurrentPP = false;
      blnShowNewCurrentPP = false;
      if(!strSelectedProject.equalsIgnoreCase('None') && mapProjectIdToBookingUnit.containsKey(strSelectedProject) && mapProjectIdToBookingUnit.get(strSelectedProject) != null)
      {
        Set<Id> bookiungUnitIds = new Set<Id>();
        system.debug('strSelectedBookingUnit '+strSelectedBookingUnit);
        for(Booking_Unit__c objBookingUnit : mapProjectIdToBookingUnit.get(strSelectedProject))
        {
          lstBookingUnitSelectOption.add(new selectOption(objBookingUnit.Id,objBookingUnit.Name+' - '+ objBookingUnit.Inventory__r.Unit__c+'-'+objBookingUnit.Unit_Details__c));
          lstBookingUnitWrapper.add(new BookingUnitWrapper(objBookingUnit,false,'No'));
          bookiungUnitIds.add(objBookingUnit.Id);
          lstAllBookingUnitsSelectOption.add(new selectOption(objBookingUnit.Id,objBookingUnit.Name+' - '+objBookingUnit.Inventory__r.Unit__c+'-'+objBookingUnit.Unit_Details__c));
        }
        
        validateCurrentPaymentTerms(bookiungUnitIds,lstBookingUnitWrapper);
      }
    }
    system.debug('lstAllBookingUnitsSelectOption '+lstAllBookingUnitsSelectOption);
    return null;
  }

  // method used to check validity for selected Booking Units
  public PageReference checkValidity()
  { 
    //perform callout to IPMS to validate the selected BU have same payment plan or not
    system.debug('lstBookingUnitWrapper '+lstBookingUnitWrapper);
    blnShowSelectedUnits = true;
    blnAOPTExists = false;
    lstBookingUnitSelectOption = new List<SelectOption>();
    lstBookingUnitSelectOption.add(new selectOption('None','--None--'));
    Set<Id> bookiungUnitIds = new Set<Id>();

    if(lstBookingUnitWrapper != null && lstBookingUnitWrapper.size() > 0 )
    {
      
      for(BookingUnitWrapper objBookingUnitWrapper : lstBookingUnitWrapper)
      {
        if(objBookingUnitWrapper.blnIsChecked)
        {
            lstBookingUnitSelectOption.add(new selectOption(objBookingUnitWrapper.objBookingUnit.Id, objBookingUnitWrapper.objBookingUnit.Name+' - '+objBookingUnitWrapper.objBookingUnit.Inventory__r.Unit__c+'-'+objBookingUnitWrapper.objBookingUnit.Unit_Details__c));
            bookiungUnitIds.add(objBookingUnitWrapper.objBookingUnit.Id);
            
            UnitDetailsService.BookinUnitDetailsWrapper objBUDetailWrapper = new UnitDetailsService.BookinUnitDetailsWrapper();
            //fetch booking unit details from IPMS
            objBUDetailWrapper = UnitDetailsService.getBookingUnitDetails(objBookingUnitWrapper.objBookingUnit.Registration_ID__c);
            mapBuIDToBUDetails.put(objBookingUnitWrapper.objBookingUnit.Id,objBUDetailWrapper);
        }
      }
      system.debug('bookiungUnitIds '+bookiungUnitIds);
      if(bookiungUnitIds != null && bookiungUnitIds.size() > 0)
      {
        strBookingUnit = new List<Id> (bookiungUnitIds).get(0);
        strUnitDetailType = 'Unit Details';
        system.debug('strBookingUnit checkValidity'+strBookingUnit);
        /*Set<Id> unMatchedBUSet = validateCurrentPaymentTerms(bookiungUnitIds,null);
        if(unMatchedBUSet != null && unMatchedBUSet.size() > 0)
        {
          blnShowSelectedUnits = false;
          ApexPages.addmessage(
                                new ApexPages.message(
                                ApexPages.severity.ERROR,'Current Payment Terms are different for selected Booking Units.')
                              );
          return null;
        }
        else
        {
          //strBookingUnit = lstBookingUnitWrapper[0].objBookingUnit.Id;
          strBookingUnit = new List<Id> (bookiungUnitIds).get(0);
          strUnitDetailType = 'Unit Details';
          system.debug('strBookingUnit checkValidity'+strBookingUnit);
        }
        */
        //check if any flag is raised on any of booking units from selected ones
        for(ID buID : bookiungUnitIds)
        {
          if(mapBuIDToBUDetails.containsKey(buID) && mapBuIDToBUDetails.get(buID) != null)
          {
            UnitDetailsService.BookinUnitDetailsWrapper objBUDetailWrapper = mapBuIDToBUDetails.get(buID);
            
            String flagStatus;
            system.debug('objBUDetailWrapper.strDispute '+objBUDetailWrapper.strDispute);
            system.debug('objBUDetailWrapper.strEnforcement '+objBUDetailWrapper.strEnforcement);
            system.debug('objBUDetailWrapper.strLitigation '+objBUDetailWrapper.strLitigation);
            system.debug('objBUDetailWrapper.strCounterCase '+objBUDetailWrapper.strCounterCase);

            /*if( objBUDetailWrapper.strDispute != null && objBUDetailWrapper.strDispute )
            {
              flagStatus = 'Dispute Flag is present. <br/> ';
              blnFlagPresent = true;
            }
            if(objBUDetailWrapper.strEnforcement !=null && objBUDetailWrapper.strEnforcement )
            {
              flagStatus += 'Enforcement Flag is present <br/>';
              blnFlagPresent = true;
            }
            if( objBUDetailWrapper.strLitigation !=null && objBUDetailWrapper.strLitigation)
            {
              flagStatus += 'Litigation Flag is present <br/>';
              blnFlagPresent = true;
            }
            if(objBUDetailWrapper.strCounterCase !=null && objBUDetailWrapper.strCounterCase)
            {
              flagStatus += 'Court Case Flag is present.';
              blnFlagPresent = true;
            }
            system.debug('blnFlagPresent '+blnFlagPresent);
            system.debug('blnAOPTExists '+blnFlagPresent);
            if(String.isNotBlank(flagStatus) && blnFlagPresent)
            {
              break;
            }*/
          }
        }

        /*if(String.isNotBlank(flagStatus) && blnFlagPresent)
        { 
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'<br/>'+flagStatus));
          return null;
        }*/
      }
      else
      {
        blnShowSelectedUnits = false;
        ApexPages.addmessage(
                              new ApexPages.message(
                              ApexPages.severity.ERROR,'Please select atleast one Booking Unit.')
                            );
        return null;
      }

      if(String.isNotBlank(strCaseID))
      {
        for(SR_Booking_Unit__c objSRBU : [Select Id,Booking_Unit__c FROM SR_Booking_Unit__c WHERE Case__c =:strCaseID])
        {
          bookiungUnitIds.remove(objSRBU.Booking_Unit__c);
        }
      }

      // validation to be fired if case is being newly created or saved as draft
      if(String.isBlank(strCaseID) || (objCase == null || objCase.Status.equalsIgnoreCase('New')) )
      {
        system.debug('bookiungUnitIds '+bookiungUnitIds);
        List<Case> lstExistingCase = validateSRInitiaton(bookiungUnitIds);
        system.debug('lstExistingCase '+lstExistingCase);
        String strExistingCases = '';
        if(lstExistingCase.size() > 0)
        { 
          strExistingCases = 'AOPT SR cannot be initiated because below SR already exists on selected Booking Units <br/>';
          for(Case objCase : lstExistingCase)
          {
            strExistingCases += objCase.Booking_Unit__r.Name+' - '+objCase.RecordType.DeveloperName+'<br/>';
          }
          blnAOPTExists = true;
          ApexPages.addmessage(
                                new ApexPages.message(
                                ApexPages.severity.ERROR,strExistingCases)
                              );
        }
        if(String.isBlank(strExistingCases))
        {
          getBookingUnitDetails();
          //getCurrentPaymentTerm();
        }
      }
    }
    return null;
  }

  // this method is used to validate if the selected booking units have same payment terms or not
  private Set<Id> validateCurrentPaymentTerms(Set<Id> bookiungUnitIds,List<BookingUnitWrapper> lstBookingUnitWrapper)
  {

    system.debug('bookiungUnitIds '+bookiungUnitIds);
    Map<Id,Set<String>> bookingIdToPaymentTermsMap = new Map<Id,Set<String>>();
    Set<Id> matchedBUSet = new Set<Id>();
    Set<Id> unMatchedBUSet = new Set<Id>();
    
    for(Booking_Unit__c objBookingUnit : [ SELECT Id,Name
                                           ,(SELECT Id,Name,Milestone_Event__c,
                                           Installment__c,Description__c,Percent_Value__c
                                           FROM Payment_Terms_del__r where Status__c = 'Active' ORDER BY Name) 
                                           FROM Booking_Unit__c WHERE ID IN : bookiungUnitIds
                                          ])
    {
        
        system.debug('objPaymentTerm '+objBookingUnit);
        if(objBookingUnit.Payment_Terms_del__r != null && objBookingUnit.Payment_Terms_del__r.size() > 0)
        {
          Set<String> paymentTermSet = new Set<String>();
          for(Payment_Terms__c objPaymentTerm : objBookingUnit.Payment_Terms_del__r)
          {
            String strPaymentTermsValue = objPaymentTerm.Installment__c + objPaymentTerm.Description__c + objPaymentTerm.Milestone_Event__c + objPaymentTerm.Percent_Value__c;
            system.debug('strPaymentTermsValue ' + strPaymentTermsValue);
            paymentTermSet.add(strPaymentTermsValue);
            bookingIdToPaymentTermsMap.put(objBookingUnit.Id,paymentTermSet);
          }
        }
    }


    system.debug('bookingIdToPaymentTermsMap '+bookingIdToPaymentTermsMap);
    system.debug('strSelectedBookingUnit '+strSelectedBookingUnit);
    if(bookiungUnitIds.size() > 0 && bookingIdToPaymentTermsMap != null && bookingIdToPaymentTermsMap.size() > 0)
    {
      //String firstBUId = new List<Id> (bookiungUnitIds).get(0);
      String firstBUId;
      if(strSelectedBookingUnit!= null && String.isNotBlank(strSelectedBookingUnit))
      {
        firstBUId = strSelectedBookingUnit;
      }
      else
      {
        firstBUId = new List<Id> (bookiungUnitIds).get(0);
        strSelectedBookingUnit = firstBUId;
      }
      
      system.debug('firstBUId '+firstBUId);
      Set<String> firstBUPaymentTerms = bookingIdToPaymentTermsMap.get(firstBUId);
      system.debug('firstBUPaymentTerms '+firstBUPaymentTerms);
      for(Id bookingUnitID : bookingIdToPaymentTermsMap.keySet())
      {
        if(!firstBUId.equals(bookingUnitID))
        {
          for(String strPaymentTerms : bookingIdToPaymentTermsMap.get(bookingUnitID))
          {
            system.debug('strPaymentTerms '+strPaymentTerms);
            if(firstBUPaymentTerms!= null && !firstBUPaymentTerms.contains(strPaymentTerms))
            {
              //return true;
              system.debug('unmatch '+bookingUnitID);
              unMatchedBUSet.add(bookingUnitID);
              //matchedBUSet.add(bookingUnitID);
            }
          }
        }
      }
      matchedBUSet.add(firstBUId);
    }

    system.debug('unMatchedBUSet '+unMatchedBUSet);
    system.debug('matchedBUSet '+matchedBUSet);

    if((unMatchedBUSet != null && unMatchedBUSet.size() > 0) && (lstBookingUnitWrapper != null && lstBookingUnitWrapper.size() > 0))
    {
      for(BookingUnitWrapper objBookingUnitWrapper : lstBookingUnitWrapper)
      {
        if(!unMatchedBUSet.contains(objBookingUnitWrapper.objBookingUnit.Id))
        {
          objBookingUnitWrapper.strMatch = 'Yes';
        }
        // by default check the booking unit which is selected in the 'Select booking Unit' dropdown as
        // it is the base unit used to compare the payment terms for other units under same project
        if(objBookingUnitWrapper.objBookingUnit.Id ==  strSelectedBookingUnit)
        {
          objBookingUnitWrapper.blnIsChecked = true;
        }
      }
    }

    if((matchedBUSet != null && matchedBUSet.size() > 0) && (lstBookingUnitWrapper != null && lstBookingUnitWrapper.size() > 0))
    {
      for(BookingUnitWrapper objBookingUnitWrapper : lstBookingUnitWrapper)
      {
        if(matchedBUSet.contains(objBookingUnitWrapper.objBookingUnit.Id))
        {
          objBookingUnitWrapper.strMatch = 'Yes';
        }
        // by default check the booking unit which is selected in the 'Select booking Unit' dropdown as
        // it is the base unit used to compare the payment terms for other units under same project
        if(objBookingUnitWrapper.objBookingUnit.Id ==  strSelectedBookingUnit)
        {
          objBookingUnitWrapper.blnIsChecked = true;
        }
      }
    }
    
    system.debug('lstBookingUnitWrapper '+lstBookingUnitWrapper);

     // logic to compare the payment detals fetched from IPMS for all booking units under one project starts
     Set<Id> setUnmatchedPT =  validatePaymentTermsWithIPMSTerms(lstBookingUnitWrapper);
     system.debug('setUnmatchedPT '+setUnmatchedPT);
     if(setUnmatchedPT != null && setUnmatchedPT.size() > 0)
     {
      unMatchedBUSet.addAll(setUnmatchedPT);
     }
     system.debug('unMatchedBUSet '+unMatchedBUSet);
    return unMatchedBUSet;
    //return false;
  }


  private Set<Id> validatePaymentTermsWithIPMSTerms(List<BookingUnitWrapper> lstBookingUnitWrapper)
  {
    system.debug('lstBookingUnitWrapper '+lstBookingUnitWrapper);
    system.debug('strSelectedBookingUnit new '+strSelectedBookingUnit);
    Set<Id> matchedBUSet = new Set<Id>();
    Set<Id> unMatchedBUSet = new Set<Id>();
    
    Map<Id,Set<String>> bookingIdToPaymentTermsMap = new Map<Id,Set<String>>();

    if(String.isNotBlank(strSelectedBookingUnit) && lstBookingUnitWrapper != null && lstBookingUnitWrapper.size() > 0 )
    {
      for(BookingUnitWrapper objBUWrapper : lstBookingUnitWrapper)
      {
        if(objBUWrapper.strMatch == 'Yes')
        {
          system.debug('objBUWrapper BU Name '+objBUWrapper.objBookingUnit.Name);
          MileStonePaymentDetailsWrapper.MileStonePaymentDetails objMileStoneEvents = getNewPaymentTermsFromIPMS(objBUWrapper.objBookingUnit.Registration_ID__c);
          
          Set<String> paymentTermSet = new Set<String>();
          for(MileStonePaymentDetailsWrapper.REG_TERM_PYMNT_TABLE objPaymentTerm : objMileStoneEvents.REG_TERM_PYMNT_TABLE)
          {
            String strPaymentTermsValue = objPaymentTerm.INSTALLMENT + objPaymentTerm.DESCRIPTION + objPaymentTerm.MILESTONE_EVENT + objPaymentTerm.MILESTEON_PERCENT_VALUE + objPaymentTerm.PAID_AMOUNT;
            system.debug('strPaymentTermsValue new ' + strPaymentTermsValue);
            paymentTermSet.add(strPaymentTermsValue);
          }
          bookingIdToPaymentTermsMap.put(objBUWrapper.objBookingUnit.Id,paymentTermSet);
        }
      }

      system.debug(' lstBookingUnitWrapper after update '+lstBookingUnitWrapper);
      Set<String> firstBUPaymentTerms = bookingIdToPaymentTermsMap.get(strSelectedBookingUnit);
      system.debug('firstBUPaymentTerms new '+firstBUPaymentTerms);
      for(Id bookingUnitID : bookingIdToPaymentTermsMap.keySet())
      {
        system.debug('bookingUnitID '+bookingUnitID);
        system.debug('strSelectedBookingUnit '+strSelectedBookingUnit);
        if(!strSelectedBookingUnit.equals(bookingUnitID))
        {
          system.debug('bookingUnitID '+bookingUnitID);
          for(String strPaymentTerms : bookingIdToPaymentTermsMap.get(bookingUnitID))
          {
            system.debug('strPaymentTerms new '+strPaymentTerms);
            if(firstBUPaymentTerms!= null && !firstBUPaymentTerms.contains(strPaymentTerms))
            {

              //return true;
              //system.debug('unmatch '+bookingUnitID);
              unMatchedBUSet.add(bookingUnitID);
              break;
              //matchedBUSet.add(bookingUnitID);
            }
            else
            {
              matchedBUSet.add(bookingUnitID);
              break;
            }
          }
        }
        else
        {
          matchedBUSet.add(strSelectedBookingUnit);
        }
      }
      

      system.debug('unMatchedBUSet new '+unMatchedBUSet);
      system.debug('matchedBUSet new '+matchedBUSet);

      /*if((unMatchedBUSet != null && unMatchedBUSet.size() > 0) && (lstBookingUnitWrapper != null && lstBookingUnitWrapper.size() > 0))
      {
        for(BookingUnitWrapper objBookingUnitWrapper : lstBookingUnitWrapper)
        {
          if(!unMatchedBUSet.contains(objBookingUnitWrapper.objBookingUnit.Id) && objBookingUnitWrapper.strMatch == 'Yes')
          {
            objBookingUnitWrapper.strMatch = 'Yes';
          }
          // by default check the booking unit which is selected in the 'Select booking Unit' dropdown as
          // it is the base unit used to compare the payment terms for other units under same project
          if(objBookingUnitWrapper.objBookingUnit.Id ==  strSelectedBookingUnit)
          {
            objBookingUnitWrapper.blnIsChecked = true;
          }
        }
      }
      */

      if((matchedBUSet != null && matchedBUSet.size() > 0) && (lstBookingUnitWrapper != null && lstBookingUnitWrapper.size() > 0))
      {
        for(BookingUnitWrapper objBookingUnitWrapper : lstBookingUnitWrapper)
        {
          if(matchedBUSet.contains(objBookingUnitWrapper.objBookingUnit.Id))
          {
            system.debug('objBookingUnitWrapper.objBookingUnit.Id '+objBookingUnitWrapper.objBookingUnit.Id);
            objBookingUnitWrapper.strMatch = 'Yes';
          }
          else
          {
            objBookingUnitWrapper.strMatch = 'No';
          }
          // by default check the booking unit which is selected in the 'Select booking Unit' dropdown as
          // it is the base unit used to compare the payment terms for other units under same project
          if(objBookingUnitWrapper.objBookingUnit.Id ==  strSelectedBookingUnit)
          {
            objBookingUnitWrapper.blnIsChecked = true;
          }
        }
      }
      system.debug('lstBookingUnitWrapper final'+lstBookingUnitWrapper);
    }
    return unMatchedBUSet;
  }


  // this method is used to get all Details related to specific Booking Unit
  public PageReference getBookingUnitDetails()
  {
    if(!strBookingUnit.equalsIgnoreCase('None'))
    {
      Id bookingUnitID = strBookingUnit;
      objBookingUnitToDisplay = [ SELECT Id,Inventory__r.Unit__c,Inventory__r.Property_Name_2__c
                                        ,Inventory__r.IPMS_Bedrooms__c,Inventory__r.Selling_Price__c
                                        ,Inventory__r.Price_Per_Sqft__c,Inventory__r.Property_Status__c
                                        ,Inventory__r.Anticipated_Completion_Date__c,Inventory__r.Property__r.Name
                                        ,Inventory__r.Property__c,Name,Inventory__r.Property_City__c
                                        ,Inventory__r.Unit_Type__c,Permitted_Use__c,Inventory__r.Area_Sqft_2__c
                                        ,Inventory__r.Construction_Status__c,Revised_Price_Area_Variation__c
                                        ,Rebate_Given__c,Rental_Pool_Agreement__c,RERA_Project__c 
                                        ,Dispute_Flag__c,OQOOD_Reg_Flag__c,Handover_Flag__c,PCC_Generate__c
                                        ,Early_Handover__c,DP_Overdue__c,Penalty_Amount__c
                                        ,Inventory__r.Unit_Plan__c,Booking_Type__c,JOPD_Area__c
                                        ,Inventory__r.Floor_Plan__c,Plot_Price__c,CreatedDate,Agreement_Date__c
                                        ,DP_OK__c,Doc_OK__c,Mortgage__c,Title_Deed__c,Under_Assignment__c
                                        FROM Booking_Unit__c WHERE Id = :bookingUnitID
                                      ];
      lstOpenSRs = new List<Case>();
      lstClosedSRs = new List<Case>();

      // for fetching all Open SR which are NOT using Junction object for storing Booking Unit details
      lstOpenSRs = [ SELECT Id,SR_Type__c
                    ,RecordType.DeveloperName 
                    FROM Case WHERE Status != 'Closed' AND Booking_Unit__c =:bookingUnitID
                   ];
      //for fetching all OPEN SR which is using Junction object for storing Booking Unit details
      for(SR_Booking_Unit__c objSRBU : [ SELECT Id,Case__c,
                                         Case__r.SR_Type__c,Case__r.RecordType.DeveloperName 
                                         FROm SR_Booking_Unit__c WHERE Case__r.Status != 'Closed' 
                                         AND Booking_Unit__c  = : bookingUnitID AND Case__c != NULL
                                       ])
      {
        Case objOpenCase = new Case();
        objOpenCase.Id = objSRBU.Case__c;
        objOpenCase.SR_Type__c = objSRBU.Case__r.SR_Type__c;
        lstOpenSRs.add(objOpenCase);
      }

      // for fetching all Closed SR which are NOT using Junction object for storing Booking Unit details
      lstClosedSRs = [ SELECT Id,SR_Type__c
                      ,RecordType.DeveloperName 
                      FROM Case WHERE Status = 'Closed' 
                      AND Booking_Unit__c =:bookingUnitID
                     ];
      //for fetching all Closed SR which is using Junction object for storing Booking Unit details
      for(SR_Booking_Unit__c objSRBU : [ SELECT Id,Case__c
                                        ,Case__r.SR_Type__c,Case__r.RecordType.DeveloperName 
                                        FROM SR_Booking_Unit__c 
                                        WHERE Case__r.Status = 'Closed' AND Booking_Unit__c  = : bookingUnitID 
                                        AND Case__c != NULL
                                       ])
      {
        Case objCloseCase = new Case();
        objCloseCase.Id = objSRBU.Case__c;
        objCloseCase.SR_Type__c = objSRBU.Case__r.SR_Type__c;
        lstClosedSRs.add(objCloseCase);
      }

      system.debug('lstOpenSRs '+lstOpenSRs.size());
      system.debug('lstClosedSRs '+lstClosedSRs.size());

      objWrapperBookingUnit = new WrapperBookingUnit();
      objWrapperBookingUnit.decPrice = objBookingUnitToDisplay.Inventory__r.Selling_Price__c;
      objWrapperBookingUnit.intArea = objBookingUnitToDisplay.Inventory__r.Area_Sqft_2__c != null ? Integer.valueOf(objBookingUnitToDisplay.Inventory__r.Area_Sqft_2__c) : 0;
      objWrapperBookingUnit.strPromotionScheme = 'Damac Promotion Scheme';
      objWrapperBookingUnit.strDealTeam = 'Damac Deal Team';
      objWrapperBookingUnit.strBookingType = 'Test Booking Type';
      objWrapperBookingUnit.decPlotPrice = objBookingUnitToDisplay.Plot_Price__c;
      objWrapperBookingUnit.strPaymentPlan = [Select Name From Payment_Plan__c WHERE Booking_Unit__c =:bookingUnitID].Name;
      objWrapperBookingUnit.dateBookingDate = objBookingUnitToDisplay.CreatedDate.date();
      objWrapperBookingUnit.dateAgreementDate = objBookingUnitToDisplay.Agreement_Date__c;
      objWrapperBookingUnit.strUnitPlan = objBookingUnitToDisplay.Inventory__r.Unit_Plan__c;
      objWrapperBookingUnit.strFloorPlan = objBookingUnitToDisplay.Inventory__r.Floor_Plan__c;
      objWrapperBookingUnit.strFJOPDArea = objBookingUnitToDisplay.JOPD_Area__c;

      //check if prior AOPT was created for the selected BU
        objWrapperBookingUnit.strPriorAOPT = 'No';
        List<SR_Booking_Unit__c> lstCaseAOPT = [ SELECT 
                                                Id
                                                FROM
                                                SR_Booking_Unit__c
                                                WHERE
                                                Booking_Unit__c =:bookingUnitID 
                                                AND Case__c != null 
                                                AND (Case__r.Status = 'Closed' OR Case__r.Status = 'Rejected')
                                                LIMIT 1];
        
        if(lstCaseAOPT != null && lstCaseAOPT.size() > 0)
        {
          objWrapperBookingUnit.strPriorAOPT = 'Yes';
        }

      if(mapBuIDToBUDetails.containsKey(bookingUnitID) && mapBuIDToBUDetails.get(bookingUnitID) != null)
      {
        objBUDetailWrapper = mapBuIDToBUDetails.get(bookingUnitID);
      }

      if(Label.ShowFlagErrorAOPT.equalsIgnoreCase('true'))
      {
        objWrapperBookingUnit.blnDispute = true;//IPMS
        objWrapperBookingUnit.blnEnforcement = true;//IPMS
        objWrapperBookingUnit.blnLitigation = true;//IPMS
        objWrapperBookingUnit.blnCourtCase = true;//IPMS
        objWrapperBookingUnit.blnMortage = true;//SF
        objWrapperBookingUnit.blnDPOK = objBookingUnitToDisplay.DP_OK__c;//SF
        objWrapperBookingUnit.blnDOCOK = objBookingUnitToDisplay.Doc_OK__c;//SF
      }
      
      objWrapperBookingUnit.objBookingUnit = objBookingUnitToDisplay;

      String flagStatus;
      if( objWrapperBookingUnit.blnDispute != null && objWrapperBookingUnit.blnDispute )
      {
        flagStatus = 'Dispute Flag is present. <br/> ';
        blnFlagPresent = true;
      }
      if(objWrapperBookingUnit.blnEnforcement !=null && objWrapperBookingUnit.blnEnforcement )
      {
        flagStatus += 'Enforcement Flag is present <br/>';
        blnFlagPresent = true;
      }
      if( objWrapperBookingUnit.blnDispute !=null && objWrapperBookingUnit.blnDispute)
      {
        flagStatus += 'Litigation Flag is present <br/>';
        blnFlagPresent = true;
      }
      if(objWrapperBookingUnit.blnCourtCase !=null && objWrapperBookingUnit.blnCourtCase)
      {
        flagStatus += 'Court Case Flag is present.';
        blnFlagPresent = true;
      }
      system.debug('blnFlagPresent '+blnFlagPresent);
      system.debug('blnAOPTExists '+blnAOPTExists);

      if(String.isNotBlank(flagStatus))
      {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'<br/>'+flagStatus));
        return null;
      }
      else
      {
        //getCurrentPaymentTerm();
      }
    }
    else
    {
      objWrapperBookingUnit.objBookingUnit = null;
    }
    
    return null;
  }

  // this method is used to get all Current Payment Terms for selected Unit
  public PageReference getCurrentPaymentTerm()
  {
    // here we will perform the Callout to Rule Engine by passing the Booking Unit Details
    // to perform Litigation Flag check,RERA Detail Calculation,ACD Calculation.
    // if Response is success, then fetch the current payment plan and display on UI
    // if response is erorr, i.e validation fails for above mentioned points
    // then we will show that error message on UI and will not proceed further
    lstPaymentTerms = new List<Payment_Terms__c>();
    system.debug('strBookingUnit '+strBookingUnit);
    percentValueTotalCurPP = 0;
    blnShowCurrentPP = true;
    blnShowNewCurrentPP = true;
    system.debug('blnShowSelectedUnits '+blnShowSelectedUnits);
    system.debug('blnAOPTExists '+blnAOPTExists);
    system.debug('blnFlagPresent '+blnFlagPresent);
    system.debug('blnShowCurrentPP '+blnShowCurrentPP);
    String strBookingUnitRegId = [SELECT Id,Registration_ID__c FROM Booking_Unit__c WHERE Id =:strBookingUnit].Registration_ID__c;
    for(Payment_Terms__c objPaymentTerm : [ SELECT Id,Name,Payment_Plan__r.Name,Milestone_Event__c
                                            ,Installment__c,Description__c,Percent_Value__c
                                            ,Payment_Date__c,Milestone_Event_Arabic__c
                                            ,Payment_Plan__r.Payment_Term__c, Payment_Plan__r.Booking_Unit__r.Registration_ID__c 
                                            FROM Payment_Terms__c 
                                            WHERE Booking_Unit__c =:strBookingUnit 
                                            AND Status__c = 'Active' AND Payment_Plan__r.Status__c = 'Active' ORDER BY Name
                                          ])
    {
        system.debug('objPaymentTerm '+objPaymentTerm);
        lstPaymentTerms.add(objPaymentTerm);
        percentValueTotalCurPP = percentValueTotalCurPP + Integer.valueOf(objPaymentTerm.Percent_Value__c);
        strPaymentPlanType = objPaymentTerm.Payment_Plan__r.Payment_Term__c ;
    }
    system.debug('lstPaymentTerms '+lstPaymentTerms);
    strPaymentPlanType = PaymentPlanUtility.getPaymentPlanType(lstPaymentTerms);
    system.debug('strPaymentPlanType '+strPaymentPlanType);
    // if there is error for any flag for units then we will not show current and new payment plans
    blnShowCurrentPP = true;
    
    // retrieve ME from IPMS-EP
    system.debug('BU Reg ID '+strBookingUnitRegId);
    fetchMileStoneEventsFromIPMS(strBookingUnitRegId);

    //call method to fetch the new payment terns from IPMS through callout
    getNewPaymentTerms();
    return null;
  }

  // this method is used to get New payment terms
  public void getNewPaymentTerms() 
  {
    blnShowNewCurrentPP = true;
    // here we will perform callout to IPMS or Rule Engine to validate the booking units selected
    // by CRE for AOPT.
    List<NewPaymentTermsWrapper> lstNewPaymentTerms = new List<NewPaymentTermsWrapper>();
    lstNewPaymentTermsDisplay = new List<NewPaymentTermsWrapper>();
    
    system.debug('strBookingUnit '+strBookingUnit);
    String strBookingUnitRegId = [SELECT Id,Registration_ID__c FROM Booking_Unit__c WHERE Id =:strBookingUnit].Registration_ID__c;
    system.debug('strBookingUnitRegId '+strBookingUnitRegId);

    if(String.isNotBlank(strCaseID) && String.isNotBlank(strAccID))
    {
      List<SelectedNewPaymentTermsByCRE> lstSelectedNewPaymentTermsByCRE = new List<SelectedNewPaymentTermsByCRE>();
      
      String strNewPaymentPlanSelected = [ SELECT 
                                           NewPaymentTermJSON__c 
                                           FROM Case 
                                           WHERE Id =:strCaseID].NewPaymentTermJSON__c;

      system.debug('strNewPaymentPlanSelected '+strNewPaymentPlanSelected);
      
      if(String.isNotBlank(strNewPaymentPlanSelected))
      {
        lstSelectedNewPaymentTermsByCRE = (List<SelectedNewPaymentTermsByCRE>)JSON.deserialize(strNewPaymentPlanSelected,List<SelectedNewPaymentTermsByCRE>.class);
        for(SelectedNewPaymentTermsByCRE objSelectedNewPaymentTermsByCRE : lstSelectedNewPaymentTermsByCRE)
        {
           NewPaymentTermsWrapper objNewPPWrapper = new NewPaymentTermsWrapper();
           objNewPPWrapper.strInstallment = objSelectedNewPaymentTermsByCRE.installment ;
           objNewPPWrapper.isReceiptPresent = objSelectedNewPaymentTermsByCRE.isReceiptPresent;
           objNewPPWrapper.strDescription = objSelectedNewPaymentTermsByCRE.description;
           objNewPPWrapper.strMileStoneEvent = objSelectedNewPaymentTermsByCRE.mileStoneEvent;
           objNewPPWrapper.strMileStoneEventArabic = objSelectedNewPaymentTermsByCRE.mileStoneEventArabic;
           objNewPPWrapper.strMileStonePercentValue = objSelectedNewPaymentTermsByCRE.percentValue;
           objNewPPWrapper.dtDueDate = objSelectedNewPaymentTermsByCRE.paymentDate;
           objNewPPWrapper.name = objSelectedNewPaymentTermsByCRE.name;
           objNewPPWrapper.strLineID = objSelectedNewPaymentTermsByCRE.strLineID;
           objNewPPWrapper.strTermID = objSelectedNewPaymentTermsByCRE.strTermID;
           objNewPPWrapper.blnNewPaymentTerm = objSelectedNewPaymentTermsByCRE.blnNewTerm;
           objNewPPWrapper.strDueAmount = objSelectedNewPaymentTermsByCRE.strDueAmount;
           objNewPPWrapper.strInvoiceAmount = objSelectedNewPaymentTermsByCRE.strInvoiceAmount;
           objNewPPWrapper.strPaidAmount = objSelectedNewPaymentTermsByCRE.strPaidAmount;
           objNewPPWrapper.lstMileStoneEventPT = new List<SelectOption>(mileStoneEventPT);

           lstNewPaymentTerms.add(objNewPPWrapper);
        }

        lstNewPaymentTermsDisplay.addAll(lstNewPaymentTerms);
      }
    }
    else
    {
      MileStonePaymentDetailsWrapper.MileStonePaymentDetails objMileStoneEvents = getNewPaymentTermsFromIPMS(strBookingUnitRegId);
      system.debug('objMileStoneEvents '+objMileStoneEvents);
      for(MileStonePaymentDetailsWrapper.REG_TERM_PYMNT_TABLE objME : objMileStoneEvents.REG_TERM_PYMNT_TABLE)
      { 
        NewPaymentTermsWrapper objNewPaymentTermWrapper = new NewPaymentTermsWrapper();
        objNewPaymentTermWrapper.strRegId = objME.REGISTRATION_ID;
        objNewPaymentTermWrapper.dtDueDate = objME.DUE_DATE != null ? objME.DUE_DATE :'';
        objNewPaymentTermWrapper.strMileStonePercentValue = objME.MILESTEON_PERCENT_VALUE;
        objNewPaymentTermWrapper.strPaidAmount = objME.PAID_AMOUNT;
        objNewPaymentTermWrapper.strPaidPercentage = objME.PAID_PERCENTAGE;
        objNewPaymentTermWrapper.strDueAmount = objME.DUE_AMOUNT;
        objNewPaymentTermWrapper.strLineID = objME.LINE_ID;
        objNewPaymentTermWrapper.strMileStoneEventArabic = objME.MILESTONE_EVENT_AR;
        objNewPaymentTermWrapper.strDescription = objME.DESCRIPTION;
        objNewPaymentTermWrapper.strMileStoneEvent = objME.MILESTONE_EVENT;
        objNewPaymentTermWrapper.strInvoiceAmount = objME.INVOICE_AMOUNT;
        objNewPaymentTermWrapper.strInstallment = objME.INSTALLMENT;
        objNewPaymentTermWrapper.strTermID = objME.TERM_ID;
        objNewPaymentTermWrapper.lstMileStoneEventPT = new List<SelectOption>(mileStoneEventPT);

        if(objME.PAID_PERCENTAGE == '100')
        {
          objNewPaymentTermWrapper.isReceiptPresent = true;
          lstNewPaymentTerms.add(objNewPaymentTermWrapper);
        }
        else if(Decimal.valueOf(objME.PAID_PERCENTAGE) > 0 && Decimal.valueOf(objME.PAID_PERCENTAGE) < 100)
        {
          lstNewPaymentTerms.addAll(calculatePaymentsDone(objME));
        }
        else if(objME.PAID_PERCENTAGE == '0')
        {
          objNewPaymentTermWrapper.isReceiptPresent = false;
          lstNewPaymentTerms.add(objNewPaymentTermWrapper);
        }
        
      }
      lstNewPaymentTerms.sort();
      lstNewPaymentTermsDisplay.addAll(lstNewPaymentTerms);
      system.debug('lstNewPaymentTerms '+lstNewPaymentTerms);
      system.debug('lstNewPaymentTerms size'+lstNewPaymentTerms.size());
      system.debug('lstNewPaymentTermsDisplay size'+lstNewPaymentTermsDisplay.size());
    }

    if(lstNewPaymentTerms != null && lstNewPaymentTerms.size() > 0)
    {
      String strPlanType = PaymentPlanUtility.getPaymentPlanTypeFromWrapper(lstNewPaymentTerms);
      
      for(NewPaymentTermsWrapper objNewPPWrapper : lstNewPaymentTerms)
      {
        objNewPPWrapper.Name = strPlanType;
      }
      strNewPaymentPlan = strPlanType;
      //getNewPaymentTermsByName();
    }
    
  }

  //this method is used to get New PT by specific type(date based,%age based,etc)
 /* public PageReference getNewPaymentTermsByName()
  {
    percentValueTotalNewPP1 = 0;
    system.debug('strNewPaymentPlan '+strNewPaymentPlan);
    lstNewPaymentTermsDisplay = new List<NewPaymentTermsWrapper>();
    if(String.isNotBlank(strNewPaymentPlan) && !strNewPaymentPlan.equalsIgnoreCase('None'))
    {
      lstNewPaymentTermsDisplay.addAll(mapNewPaymentTermsWrapper.get(strNewPaymentPlan));
    }
    system.debug('lstNewPaymentTermsDisplay size '+lstNewPaymentTermsDisplay.size());
    return null;
  }
  */

  // this method is used to add new installment for new payment term
  public void addNewInstallment()
  {

    //system.debug('lstNewPaymentTermsDisplay before '+JSON.serialize(lstNewPaymentTermsDisplay));
    Integer counter = 1;

    for(integer i=0 ; i < lstNewPaymentTermsDisplay.size() ; i++)
    {
      if(i > 0)
      {
        lstNewPaymentTermsDisplay[i].strInstallment = 'I00'+i;
        if(i == 1)
        {
          lstNewPaymentTermsDisplay[i].strDescription = i+'ST INSTALLMENT';
        }
        else if(i == 2)
        {
          lstNewPaymentTermsDisplay[i].strDescription = i+'ND INSTALLMENT';
        }
        else if(i == 3)
        {
          lstNewPaymentTermsDisplay[i].strDescription = i+'RD INSTALLMENT';
        }
        else
        {
          lstNewPaymentTermsDisplay[i].strDescription = i+'TH INSTALLMENT';
        }
        counter ++;
      }
    }

    // creating new object of wrapper to add new Payment Term
    NewPaymentTermsWrapper objNewPaymentTermWrapper = new NewPaymentTermsWrapper();
    if(counter == 1)
    {
      objNewPaymentTermWrapper.strDescription = counter+'ST INSTALLMENT';
    }
    else if(counter == 2)
    {
      objNewPaymentTermWrapper.strDescription = counter+'ND INSTALLMENT';
    }
    else if(counter == 3)
    {
      objNewPaymentTermWrapper.strDescription = counter+'RD INSTALLMENT';
    }
    else
    {
      objNewPaymentTermWrapper.strDescription = counter+'TH INSTALLMENT';
    }

    objNewPaymentTermWrapper.name = 'Structure Based Payment Plan';
    objNewPaymentTermWrapper.strInstallment = 'I00'+counter;
    objNewPaymentTermWrapper.strMileStoneEvent = '';
    objNewPaymentTermWrapper.strMileStoneEventArabic = '';
    objNewPaymentTermWrapper.strMileStonePercentValue = '10';
    objNewPaymentTermWrapper.dtDueDate = '';
    objNewPaymentTermWrapper.isReceiptPresent = false;
    objNewPaymentTermWrapper.lstMileStoneEventPT = new List<SelectOption>(mileStoneEventPT);
    objNewPaymentTermWrapper.blnNewPaymentTerm = true;
    lstNewPaymentTermsDisplay.add(objNewPaymentTermWrapper);

    for(integer i=0 ; i < lstNewPaymentTermsDisplay.size() ; i++)
    {
      system.debug('lstNewPaymentTermsDisplay[i].strInstallment  '+lstNewPaymentTermsDisplay[i].strMileStoneEvent );
    }
  }

  //this method is used to remove the newly added new PT 
  public void removeInstallment()
  {
    system.debug('rowToRemove '+rowToRemove);
    lstNewPaymentTermsDisplay.remove(rowToRemove);
    for(integer i=0 ; i < lstNewPaymentTermsDisplay.size() ; i++)
    {
      if(i > 0)
      {
        lstNewPaymentTermsDisplay[i].strInstallment = 'I00'+i;
        if(i == 1)
        {
          lstNewPaymentTermsDisplay[i].strDescription = i+'ST INSTALLMENT';
        }
        else if(i == 2)
        {
          lstNewPaymentTermsDisplay[i].strDescription = i+'ND INSTALLMENT';
        }
        else if(i == 3)
        {
          lstNewPaymentTermsDisplay[i].strDescription = i+'RD INSTALLMENT';
        }
        else
        {
          lstNewPaymentTermsDisplay[i].strDescription = i+'TH INSTALLMENT';
        }
      }
    }
  }

  // this method is used to validate the AOPT process
  public void aoptValidate()
  {
      system.debug('aoptValidate method called '+strSelectedBookingUnit);
      // perform callout to Rule Engine to validate if selected units are eligible for AOPT or not
      // here we will pass the new payment terms selected by cre for validating in IPMS.
      // if that is eligible then we will show success message or will show error message based on 
      // response from IPMS
      if(String.isNotBlank(strSelectedBookingUnit))
      {
        //Booking_Unit__c objBU = [Select Id,Registration_ID__c FROM Booking_Unit__c WHERE Id =:strSelectedBookingUnit];

        Booking_Unit__c objBU = [ SELECT Id,Registration_ID__c,Inventory__r.Unit__c,Inventory__r.Property_Name_2__c
                                         ,Inventory__r.Building_Code__c,Inventory__r.Bedroom_Type__c
                                         ,Inventory__r.Project_Category__c,Nationality__c
                                         ,Inventory__r.Property__r.Name
                                         ,Inventory__r.Property__c,Name,Inventory__r.Property_City__c
                                         ,Inventory__r.Unit_Type__c,Permitted_Use__c
                                         FROM Booking_Unit__c WHERE Id = :strSelectedBookingUnit];

        String strPercentCompleted;
        String strDiffCurrACD;

        UnitDetailsService.BookinUnitDetailsWrapper objBUDetailWrapper = UnitDetailsService.getBookingUnitDetails(objBU.Registration_ID__c);

        //% in Completion Installment in proposed plan
        system.debug('lstNewPaymentTermsDisplay '+lstNewPaymentTermsDisplay.size());
        system.debug('lstNewPaymentTermsDisplay '+lstNewPaymentTermsDisplay);
        for(Integer i = lstNewPaymentTermsDisplay.size() ;i > = 0;i--)
        {
          system.debug('lstNewPaymentTermsDisplay[i] '+lstNewPaymentTermsDisplay[i].strMileStoneEvent);
          if( String.isNotBlank(lstNewPaymentTermsDisplay[i].strMileStoneEvent) )
          {
              String strME = lstNewPaymentTermsDisplay[i].strMileStoneEvent.toLowerCase();
              if(strME.contains('on completion'))
              {
                strPercentCompleted = lstNewPaymentTermsDisplay[i].strMileStonePercentValue;
                break;
              }
          }
        }

        //Difference between Current ACD and last non-completion installment in proposed plan
        for(Integer i = lstNewPaymentTermsDisplay.size() ;i > 0;i--)
        {
          if( String.isNotBlank(lstNewPaymentTermsDisplay[i].strMileStoneEvent) )
          {
              String strME = lstNewPaymentTermsDisplay[i].strMileStoneEvent.toLowerCase();
              if(!strME.contains('on completion'))
              {
                strDiffCurrACD = calculateDateDiff(objBUDetailWrapper.strCurrentACD,lstNewPaymentTermsDisplay[i].dtDueDate);
                break;
              }
          }
        }

        //check if prior AOPT was created for the selected BU
        String strPriorAOPT = 'No';
        SR_Booking_Unit__c objCaseAOPT = [ SELECT 
                                                Id
                                                FROM
                                                SR_Booking_Unit__c
                                                WHERE
                                                Booking_Unit__c =:strSelectedBookingUnit 
                                                AND Case__c != null 
                                                AND (Case__r.Status = 'Closed' OR Case__r.Status = 'Rejected')
                                                LIMIT 1];
        
        if(objCaseAOPT != null && objCaseAOPT.Id != null)
        {
          strPriorAOPT = 'Yes';
        }

        // payment proposed are equally distributed or not
        String strPaymentProposedEquDistrb = 'No';
        List<NewPaymentTermsWrapper> lstNewPaymentTermsDisplayClone = new List<NewPaymentTermsWrapper>();
        lstNewPaymentTermsDisplayClone = lstNewPaymentTermsDisplay;

        //remove the last index
        lstNewPaymentTermsDisplayClone.remove(lstNewPaymentTermsDisplayClone.size());

        if(lstNewPaymentTermsDisplayClone.size() >= 4)
        {
          Integer intDPIndex;
          Integer intOnCompleteIndex;
          for(Integer i=0;i < lstNewPaymentTermsDisplayClone.size();i++)
          {
            if(String.isNotBlank(lstNewPaymentTermsDisplayClone[i].strMileStoneEvent))
            {
               if(lstNewPaymentTermsDisplayClone[i].strMileStoneEvent.toLowerCase().contains('Immediate') )
               {
                intDPIndex = i;
                break;
               }
            }
          }

          lstNewPaymentTermsDisplayClone.remove(intDPIndex);
          String strFirstPercent = lstNewPaymentTermsDisplayClone[0].strMileStonePercentValue;
          for(NewPaymentTermsWrapper objWrapperPT : lstNewPaymentTermsDisplayClone)
          {
            if(objWrapperPT.strMileStonePercentValue.equalsIgnoreCase(strFirstPercent))
            {
              strPaymentProposedEquDistrb = 'Yes';
            }
            else
            {
              strPaymentProposedEquDistrb = 'No';
            }
          }
        }
        

        //original Payment plan type
        system.debug('strPaymentPlanType '+strPaymentPlanType);
        system.debug('strPercentCompleted '+strPercentCompleted);
        system.debug('strDiffCurrACD '+strDiffCurrACD);

        //Proposed Payment plan is extending beyond ACD (Yes/No)
        String strProposedPlanExtended = 'No';
        UnitDetailsService.BookinUnitDetailsWrapper objBUDetail = new UnitDetailsService.BookinUnitDetailsWrapper();
        //fetch booking unit details from IPMS
        objBUDetail = UnitDetailsService.getBookingUnitDetails(objBU.Registration_ID__c);
        system.debug('objBUDetail.strCurrentACD '+objBUDetail.strCurrentACD);
        if(String.isNotBlank(objBUDetail.strCurrentACD))
        {
          for(NewPaymentTermsWrapper objWrapperPT : lstNewPaymentTermsDisplayClone)
          {
            if(String.isNotBlank(objWrapperPT.strMileStoneEvent))
            {
              String strME = objWrapperPT.strMileStoneEvent.toLowerCase();
              if(strME.contains('on') || strME.contains('before'))
              {
                Boolean blnACDExtension = calculateACDExtentsion(objBUDetail.strCurrentACD,objWrapperPT.dtDueDate);

                if(blnACDExtension)
                {
                  strProposedPlanExtended = 'Yes';
                  break;
                }
              }
            }
          }
        }

        String strProposedPPType = PaymentPlanUtility.getPaymentPlanTypeFromWrapper(lstNewPaymentTermsDisplay);

        AOPTMQService.AOPTRuleResponse objAOPTRuleResponse = AOPTMQService.checkAOPTEligibility( objBU.Registration_ID__c,'AOPT',objBU.Inventory__r.Property_City__c
                                                             ,objBU.Inventory__r.Property__c,objBU.Inventory__r.Building_Code__c
                                                             ,objBU.Inventory__r.Bedroom_Type__c,objBU.Inventory__r.Project_Category__c
                                                             ,objBU.Permitted_Use__c,objBUDetail.strEHOFlag,objBUDetail.strHOFlag
                                                             ,objBU.Nationality__c,objBUDetail.strPortfolioValue,strProposedPPType
                                                             ,strPercentCompleted,strDiffCurrACD,'','',strPriorAOPT,strPaymentProposedEquDistrb
                                                             ,strProposedPlanExtended,strPaymentPlanType
                                                            );
        system.debug('objAOPTRuleResponse '+objAOPTRuleResponse);

        // currently assuming that AOPT is allowed
        if(objAOPTRuleResponse.strAllowed.equalsIgnoreCase('allowed'))
        {
          blnIsAOPTEligible = true;
          blnIsAOPTNotEligible = false;
          strApprovingAuthority = objAOPTRuleResponse.strAllowed;
        }
        else if(objAOPTRuleResponse.strAllowed.equalsIgnoreCase('No'))
        {
          blnIsAOPTEligible = false;
          blnIsAOPTNotEligible = true;
          strAOPTEligibilityErrors = objAOPTRuleResponse.strMessage;
        }
      }
  }

  private Boolean calculateACDExtentsion(String strDateCurACD,String strDateProposed)
  {
    Date objDateToFormat1 = Date.parse(strDateCurACD);
    String strFormatedDate = DateTime.newInstance(objDateToFormat1.year(),objDateToFormat1.month(),objDateToFormat1.day()).format('dd/MM/YYYY');
    objDateToFormat1 = Date.parse(strFormatedDate);
    system.debug('strFormatedDate '+strFormatedDate);

    Date objDateToFormat2 = Date.parse(strDateProposed);
    if(objDateToFormat1 < objDateToFormat2)
    {
      return true;
    }
    return false;
  }

  private String calculateDateDiff(String strDate1,String strDate2)
  {
    Date objDateToFormat1 = Date.parse(strDate1);
    String strFormatedDate = DateTime.newInstance(objDateToFormat1.year(),objDateToFormat1.month(),objDateToFormat1.day()).format('dd/MM/YYYY');
    objDateToFormat1 = Date.parse(strFormatedDate);
    system.debug('strFormatedDate '+strFormatedDate);

    Date objDateToFormat2 = Date.parse(strDate2);

    Integer days = objDateToFormat1.daysBetween(objDateToFormat2);
    return String.valueOf(days);
  }

  // this method is used create Case record for AOPT process
  public PageReference createSR()
  {
    system.debug('create sr called');
    List<SR_Booking_Unit__c> lstSRBookingUnit = new List<SR_Booking_Unit__c>();
    List<Attachment> lstAttachment = new List<Attachment>();
    List<SR_Attachments__c> lstCaseAttachment = new List<SR_Attachments__c>();
    List<SelectedNewPaymentTermsByCRE> lstNewPPSelectedByCRE = new List<SelectedNewPaymentTermsByCRE>();

    Map<Id,SR_Booking_Unit__c> mapSRBookingUnitExisting = new Map<Id,SR_Booking_Unit__c>();
    
    Set<Id> setSRBookingUnitToDelete = new Set<Id>();
    
    String strStatus;
    String strNewSelectedPaymentTerms;
    
    for(NewPaymentTermsWrapper objNewPPWrapper : lstNewPaymentTermsDisplay)
    {
      SelectedNewPaymentTermsByCRE objSelectedNewPaymentTermsByCRE = new SelectedNewPaymentTermsByCRE();
      objSelectedNewPaymentTermsByCRE.installment = objNewPPWrapper.strInstallment;
      objSelectedNewPaymentTermsByCRE.isReceiptPresent = objNewPPWrapper.isReceiptPresent;
      objSelectedNewPaymentTermsByCRE.description = objNewPPWrapper.strDescription;
      objSelectedNewPaymentTermsByCRE.mileStoneEvent = objNewPPWrapper.strMileStoneEvent;
      objSelectedNewPaymentTermsByCRE.mileStoneEventArabic = objNewPPWrapper.strMileStoneEventArabic;
      objSelectedNewPaymentTermsByCRE.percentValue = objNewPPWrapper.strMileStonePercentValue;
      objSelectedNewPaymentTermsByCRE.paymentDate = objNewPPWrapper.dtDueDate;
      objSelectedNewPaymentTermsByCRE.name = objNewPPWrapper.name;
      objSelectedNewPaymentTermsByCRE.blnNewTerm = objNewPPWrapper.blnNewPaymentTerm;
      objSelectedNewPaymentTermsByCRE.strLineID = objNewPPWrapper.strLineID;
      objSelectedNewPaymentTermsByCRE.strTermID = objNewPPWrapper.strTermID;
      objSelectedNewPaymentTermsByCRE.strPaidAmount = objNewPPWrapper.strPaidAmount;
      objSelectedNewPaymentTermsByCRE.strInvoiceAmount = objNewPPWrapper.strInvoiceAmount;
      objSelectedNewPaymentTermsByCRE.strDueAmount = objNewPPWrapper.strDueAmount;
      objSelectedNewPaymentTermsByCRE.name = strNewPaymentPlan;

      lstNewPPSelectedByCRE.add(objSelectedNewPaymentTermsByCRE);
    }
    strNewSelectedPaymentTerms = JSON.serialize(lstNewPPSelectedByCRE);
    system.debug('strNewSelectedPaymentTerms '+strNewSelectedPaymentTerms);

    if( objCase == null )
    {
      objCase = new Case();
    }

    try
    {
      Id aoptRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AOPT').getRecordTypeId();
      for(BookingUnitWrapper objBookingUnitWrapper : lstBookingUnitWrapper)
      {
        if(!objBookingUnitWrapper.blnIsChecked)
        {
          setSRBookingUnitToDelete.add(objBookingUnitWrapper.objBookingUnit.Id);
        }
      }

      // delete SR Booking unit record for those units which are de selected.
      if(setSRBookingUnitToDelete != null && setSRBookingUnitToDelete.size() > 0 )
      {
        delete [SELECT Id FROM SR_Booking_Unit__c WHERE Booking_Unit__c IN:setSRBookingUnitToDelete];
      }
    
      if(String.isNotBlank(strCaseID))
      {
        objCase.Id = strCaseID;
        for(SR_Booking_Unit__c objSRBookingUnitFetch : [ SELECT Id,Name,Case__c
                                                         ,Booking_Unit__c 
                                                         FROM SR_Booking_Unit__c 
                                                         WHERE Case__c =:strCaseID
                                                       ])
        {
          mapSRBookingUnitExisting.put(objSRBookingUnitFetch.Booking_Unit__c,objSRBookingUnitFetch);
        }
      }

      system.debug('strApprovingAuthority '+strApprovingAuthority);
      if(String.isNotBlank(strCaseStatusSubmitted) && strCaseStatusSubmitted.equalsIgnoreCase('Submitted'))
      {
        objCase.Status = 'Submitted';
        //objCase.Approving_Authorities__c = 'VP - Operations,General Manager';
        objCase.Approving_Authorities__c = strApprovingAuthority;
        objCase.Submit_for_Approval__c = true;
      }
      else
      {
        objCase.Status = 'New';
        objCase.Approving_Authorities__c = strApprovingAuthority;
      }

      objCase.RecordTypeID = aoptRecordTypeID;
      objCase.SR_Type__c = 'Amendment of Payment Terms';
      objCase.AccountID = strAccID;
      system.debug('dtDateOfExpiry '+dtDateOfExpiry);
      if(String.isNotBlank(dtDateOfExpiry))
      {
        objCase.POA_Expiry_Date__c = Date.parse(dtDateOfExpiry);
      }
      objCase.NewPaymentTermJSON__c= strNewSelectedPaymentTerms;
      objCase.Origin = 'Walk-In';
      objCase.Subject = 'AOPT SR';

      if( String.isNotBlank( strIsPOA ) && strIsPOA.equalsIgnoreCase( 'Yes' ))
      {
        objCase.IsPOA__c = true;
      }
      else
      {
        objCase.IsPOA__c = false;
      }
      
      upsert objCase;
      if(objCase.Id != null)
      { 
         // write code to insert attachment after case is created
         if(String.isNotBlank(strCRFAttachmentBody) && String.isNotBlank(strCRFAttachmentName)) {
              lstAttachment.add(getAttachment(extractName(strCRFAttachmentName), extractBody(strCRFAttachmentBody)));
              lstCaseAttachment.add(getCaseAttachment('CRF Form'));
          }
          
          if(strIsPOA != null && strIsPOA.equalsIgnoreCase('Yes')) {
              if(String.isNotBlank(strPOAAttachmentBody) && String.isNotBlank(strPOAAttachmentName)) {
                  lstAttachment.add(getAttachment(extractName(strPOAAttachmentName), extractBody(strPOAAttachmentBody)));
                  lstCaseAttachment.add(getCaseAttachment('Power Of Attorney'));
              }
          }

          if(String.isNotBlank(strPDCAttachmentBody) && String.isNotBlank(strPDCAttachmentName)) {
              lstAttachment.add(getAttachment(extractName(strPDCAttachmentName), extractBody(strPDCAttachmentBody)));
              lstCaseAttachment.add(getCaseAttachment('PDC'));
          }

          
          if(!lstAttachment.isEmpty()) 
          {
            insertAttachments(lstAttachment, lstCaseAttachment);
          }

          for(BookingUnitWrapper objBookingUnitWrapper : lstBookingUnitWrapper)
          {
            if(mapSRBookingUnitExisting != null && mapSRBookingUnitExisting.size() > 0)
            {
              if( !mapSRBookingUnitExisting.containsKey(objBookingUnitWrapper.objBookingUnit.Id) 
                  && objBookingUnitWrapper.blnIsChecked )
              {
                SR_Booking_Unit__c objSRBookingUnitNew = new SR_Booking_Unit__c();
                objSRBookingUnitNew.Id = objSRBookingUnitNew.Id;
                objSRBookingUnitNew.Case__c = objCase.Id;
                objSRBookingUnitNew.Booking_Unit__c = objBookingUnitWrapper.objBookingUnit.Id;
                lstSRBookingUnit.add(objSRBookingUnitNew);
              }
            }
            else if(objBookingUnitWrapper.blnIsChecked)
            {
              SR_Booking_Unit__c objSRBookingUnitInitial = new SR_Booking_Unit__c();
              objSRBookingUnitInitial.Id = objSRBookingUnitInitial.Id;
              objSRBookingUnitInitial.Case__c = objCase.Id;
              objSRBookingUnitInitial.Booking_Unit__c = objBookingUnitWrapper.objBookingUnit.Id;
              lstSRBookingUnit.add(objSRBookingUnitInitial);
            }
          }
          system.debug('lstSRBookingUnit '+lstSRBookingUnit);
          if(lstSRBookingUnit != null && lstSRBookingUnit.size() > 0)
          {
            upsert lstSRBookingUnit;

          }
          strCaseID = objCase.Id;
          Case objInsertedCase = [SELECT Id,CaseNumber FROM Case WHERE id =: strCaseID LIMIT 1];

          strStatus = 'SR record created successfully.'+' '+'SR No:'+objInsertedCase.CaseNumber;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Success : '+strStatus));
          if(String.isNotBlank(strCaseStatusSubmitted) && strCaseStatusSubmitted.equalsIgnoreCase('Submitted'))
          {
            return new Pagereference('/' + objCase.Id);
          }
          else
          {
            system.debug('save as draft clicked');
            Pagereference pg = Page.CREPortalHomeAOPT;
            pg.getParameters().put('AccountId',strAccID);
            pg.getParameters().put('caseID',objCase.Id);
            pg.setRedirect(true);
            return pg;
          }
      }
      else
      {
        strStatus += 'SR record not created. <br/>';
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error : '+strStatus));
        return null;
      }
    }
    catch(Exception exp)
    {
      system.debug('exception '+exp);
      system.debug('exception String'+exp.getStackTraceString());
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error '+exp));
      return null;
    }
    return null;
  }


  // this method is used to call the IPMS end point and generate SOA
  public void GenarateSOA()
  {
    lstSOAWrapper = new List<SOAWrapper>();
    system.debug('Generate SOA method called');
    // this method will call the IPMS and fetch the SOA from there
    // then it will map the SOA to the SR created
    try
    {
      if(lstBookingUnitWrapper != null && lstBookingUnitWrapper.size() > 0)
      {
        for(BookingUnitWrapper objBookingUnitWrapper : lstBookingUnitWrapper)
        {
          if(objBookingUnitWrapper.blnIsChecked)
          {
            if(String.isNotBlank(objBookingUnitWrapper.objBookingUnit.Registration_ID__c))
            {
              String strRegId = objBookingUnitWrapper.objBookingUnit.Registration_ID__c;
              GenerateSOAController.soaResponse strResponse = GenerateSOAController.getSOADocument(strRegId);
              system.debug('SOA generated status '+strResponse.status);
              system.debug('SOA generated url'+strResponse.url);
              SOAWrapper objSOAWrapper = new SOAWrapper();
              objSOAWrapper.strSOAURL = strResponse.url;
              objSOAWrapper.objBookingUnit = objBookingUnitWrapper.objBookingUnit;
              lstSOAWrapper.add(objSOAWrapper);
            }
          }
        }
      }
    }
    catch(Exception exp)
    {
      system.debug('exp SOA '+exp.getStackTraceString());
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,exp.getMessage()));
    }
  }

  /*public PageReference goToAttachmentPage()
  {
    List<SR_Booking_Unit__c> lstSRBookingUnit = new List<SR_Booking_Unit__c>();
    Map<Id,SR_Booking_Unit__c> mapSRBookingUnitExisting = new Map<Id,SR_Booking_Unit__c>();
    Set<Id> setSRBookingUnitToDelete = new Set<Id>();
    String strStatus;
    PageReference pgr = null;
    try
    {
      Id aoptRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AOPT').getRecordTypeId();
      for(BookingUnitWrapper objBookingUnitWrapper : lstBookingUnitWrapper)
      {
        if(!objBookingUnitWrapper.blnIsChecked)
        {
          setSRBookingUnitToDelete.add(objBookingUnitWrapper.objBookingUnit.Id);
        }
      }

      // delete SR Booking unit record for those units which are de selected.
      if(setSRBookingUnitToDelete != null && setSRBookingUnitToDelete.size() > 0 )
      {
        delete [select id from SR_Booking_Unit__c where Booking_Unit__c IN:setSRBookingUnitToDelete];
      }

    
      Case objCase = new Case();
      if(String.isNotBlank(strCaseID))
      {
        objCase.Id = strCaseID;
        for(SR_Booking_Unit__c objSRBookingUnitFetch : [select id,Name,Case__c,Booking_Unit__c from SR_Booking_Unit__c where case__c =:strCaseID])
        {
          mapSRBookingUnitExisting.put(objSRBookingUnitFetch.Booking_Unit__c,objSRBookingUnitFetch);
        }
      }

      objCase.RecordTypeID = aoptRecordTypeID;
      objCase.SR_Type__c = 'Amendment of Payment Terms';
      objCase.AccountID = strAccID;
      objCase.POA_Expiry_Date__c = dtDateOfExpiry;
      objCase.POA_Issued_By__c = strIssuedBy;
      objCase.POA_Name__c = strPOAName;
      objCase.POA_Relationship_with_Buyer__c = strPOARelationship;
      if( String.isNotBlank( strPDCRequired ) && strPDCRequired.equalsIgnoreCase( 'Yes' ))
      {
        objCase.AOPT_IsPDC_Provided__c = true;
      }
      else
      {
        objCase.AOPT_IsPDC_Provided__c = false;
      }
      
      upsert objCase;
      if(objCase.Id != null)
      {
        for(BookingUnitWrapper objBookingUnitWrapper : lstBookingUnitWrapper)
        {
          if(mapSRBookingUnitExisting != null && mapSRBookingUnitExisting.size() > 0)
          {
            if( !mapSRBookingUnitExisting.containsKey(objBookingUnitWrapper.objBookingUnit.Id) 
                && objBookingUnitWrapper.blnIsChecked )
            {
              SR_Booking_Unit__c objSRBookingUnitNew = new SR_Booking_Unit__c();
              objSRBookingUnitNew.Id = objSRBookingUnitNew.Id;
              objSRBookingUnitNew.Case__c = objCase.Id;
              objSRBookingUnitNew.Booking_Unit__c = objBookingUnitWrapper.objBookingUnit.Id;
              lstSRBookingUnit.add(objSRBookingUnitNew);
            }
          }
          else if(objBookingUnitWrapper.blnIsChecked)
          {
            SR_Booking_Unit__c objSRBookingUnitInitial = new SR_Booking_Unit__c();
            objSRBookingUnitInitial.Id = objSRBookingUnitInitial.Id;
            objSRBookingUnitInitial.Case__c = objCase.Id;
            objSRBookingUnitInitial.Booking_Unit__c = objBookingUnitWrapper.objBookingUnit.Id;
            lstSRBookingUnit.add(objSRBookingUnitInitial);
          }
        }
        system.debug('lstSRBookingUnit '+lstSRBookingUnit);
        if(lstSRBookingUnit != null && lstSRBookingUnit.size() > 0)
        {
          upsert lstSRBookingUnit;

        }
        strCaseID = objCase.Id;
        strStatus = 'SR record created successfully.';
        pgr = new pageReference('/apex/UploadAttachment?id='+strCaseID+'&accID='+strAccID+'&doc='+strTypeOfDoc+'&returnPage=AOPTServiceRequestNew');
      }
      else
      {
        strStatus += 'SR record not created. <br/>';
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Success : '+strStatus));
        return null;
      }
    }
    catch(Exception exp)
    {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error '+exp.getMessage()));
      return null;
    }
    
    system.debug('before pgr');
    return pgr;
  }
  */

  // this method is used to remove the attachment uploaded by CRE
  public Pagereference removeAttachment()
  {
    SR_Attachments__c Sr = [SELECT Id,Type__c FROM SR_Attachments__c WHERE Id=: RemoveSelected];
    try
    {
      delete Sr;
      getAttachments();
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Success : Attachment Deleted successfully.'));
      Pagereference pg = Page.CREPortalHomeAOPT;
      pg.getParameters().put('accID',strAccID);
      pg.getParameters().put('caseID',objCase.Id);
      pg.setRedirect(true);
      return pg;
    }
    catch(Exception exp)
    {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured in deleting PDC attachment '+exp.getMessage()));
    }
    return null;
  }

  // this method is used to upload signed Offer & Acceptance letter
  public Pagereference uploadOffer()
  {
     List<SR_Attachments__c> lstOfferAttachment = new List<SR_Attachments__c>();
     List<Attachment> lstAttachment = new List<Attachment>();
     try
     {
      // write code to insert attachment after case is created
       if(String.isNotBlank(strOfferAttachmentBody) && String.isNotBlank(strOfferAttachmentName)) {
            lstAttachment.add(getAttachment(extractName(strOfferAttachmentName), extractBody(strOfferAttachmentBody)));
            lstOfferAttachment.add(getCaseAttachment('Offer & Acceptance Letter'));
        }
        
        if(!lstAttachment.isEmpty()) 
        {
          insertAttachments(lstAttachment, lstOfferAttachment);
        }
        objCase.O_A_Signed_Copy_Uploaded__c = true;
        update objCase;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Success : Offer Uploaded successfully.'));
        return new Pagereference('/' + objCase.Id);
     }
     catch(Exception exp)
     {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error : '+exp.getMessage()));
     }
      return null;
  }

  // this method is used to view and download CRF form
  public Pagereference viewAndDownloadCRF()
  {
    String strURL = '/apex/CRF?Id='+strCaseID+'&recTypeName=Amendment Of Payment Terms';
    PageReference pr = new PageReference(strURL);
    pr.setRedirect(true);
    return pr;
  }

  //get the arabic value of ME event selected by CRE in AOPT process for new payment term
  public void fetchArabicValue()
  {
    system.debug('rowToFetchArabic '+rowToFetchArabic);

    system.debug('lstNewPaymentTermsDisplay[rowToRemove] '+lstNewPaymentTermsDisplay[rowToFetchArabic]);
    system.debug('lstNewPaymentTermsDisplay[rowToRemove] '+lstNewPaymentTermsDisplay[rowToFetchArabic].strMileStoneEvent);
    String strMileStoneEvent = lstNewPaymentTermsDisplay[rowToFetchArabic].strMileStoneEvent;

    if( String.isNotBlank(strMileStoneEvent) && mapMileStoneEvents.containsKey(strMileStoneEvent) )
    {
      lstNewPaymentTermsDisplay[rowToFetchArabic].strMileStoneEventArabic = mapMileStoneEvents.get(strMileStoneEvent);
    }
    system.debug('lstNewPaymentTermsDisplay after updating '+lstNewPaymentTermsDisplay[rowToFetchArabic]);
  }


  // all private methods section
  private Attachment getAttachment(String strName, Blob blbBody) 
  {
    Attachment objAttachment = new Attachment();
    objAttachment.Name = strName;
    objAttachment.Body = blbBody;
    return objAttachment;
  }
  
  private SR_Attachments__c getCaseAttachment(String strDocType) 
  {
    system.debug('objCase.Id '+objCase.Id);
    SR_Attachments__c objCaseAttachment = new SR_Attachments__c();
    objCaseAttachment.Case__c = objCase.Id;
    objCaseAttachment.Type__c = strDocType;
    return objCaseAttachment;
  }

  private String extractName( String strName ) 
  {
    return strName.substring( strName.lastIndexOf('\\')+1 ) ;
  }
  
  private Blob extractBody( String strBody ) 
  {
    strBody = EncodingUtil.base64Decode( strBody ).toString();
    return EncodingUtil.base64Decode( strBody.substring( strBody.lastIndexOf(',')+1 ) );
  }

  //Method to insert attachments and case attachments
  private void insertAttachments(List<Attachment> lstAttachment, List<SR_Attachments__c> lstCaseAttachment) {
      insert lstCaseAttachment;
      
      Integer intCounter = 0;
      for(SR_Attachments__c objCaseAttachment: lstCaseAttachment) {
          lstAttachment[intCounter].ParentId = objCaseAttachment.Id;
          intCounter++;
      }
      
      insert lstAttachment;
      
      intCounter = 0;
      for(Attachment objAttachment: lstAttachment) {
          lstCaseAttachment[intCounter].Name = objAttachment.Name;
          lstCaseAttachment[intCounter].Attachment__c = objAttachment.Id;
          intCounter++;
      }
      
      update lstCaseAttachment;
      
      strCRFAttachmentBody = null;
      strCRFAttachmentName = null;
      strPOAAttachmentBody = null;
      strPOAAttachmentName = null;
  }

  // this method is used to validate if AOPT SR is allowed to be created for selected Booking Units
  private list<Case> validateSRInitiaton(Set<Id> bookingUnitIDSet)
  {
    List<Case> lstExistingCase = new List<Case>();
    Set<String> setNotAllowedSRTypes = new Set<String>();
    
    setNotAllowedSRTypes.add('Parking');
    setNotAllowedSRTypes.add('AOPT');
    setNotAllowedSRTypes.add('Change of Details');
    setNotAllowedSRTypes.add('Promotion Package');
    setNotAllowedSRTypes.add('Handover');
    setNotAllowedSRTypes.add('Penalty Waiver');
    setNotAllowedSRTypes.add('Customer Refund');
    setNotAllowedSRTypes.add('Token Refund');
    setNotAllowedSRTypes.add('Rental Pool Agreement');
    setNotAllowedSRTypes.add('Rental Pool Termination');
    setNotAllowedSRTypes.add('Title Deed');
    setNotAllowedSRTypes.add('Cancel & Transfer');
    setNotAllowedSRTypes.add('Plot Handover');
    setNotAllowedSRTypes.add('Cheque Replacement SR');
    
    
    map<Id,Case> mapId_Case = new map<Id,Case>([SELECT c.Id
                                                     , c.Booking_Unit__c
                                                     , c.Booking_Unit__r.Name
                                                     , c.AccountId
                                                     , c.CaseNumber
                                                     , c.RecordType.DeveloperName
                                                     , c.RecordType.Name
                                                FROM Case c
                                                WHERE c.Booking_Unit__c IN: bookingUnitIDSet
                                                AND c.Status != 'Closed'
                                                AND c.Status != 'Rejected'
                                                AND c.RecordType.DeveloperName IN : setNotAllowedSRTypes
                                                ]);
    if(mapId_Case != null && !mapId_Case.isEmpty())
    {
        lstExistingCase.addAll(mapId_Case.values());
    }
    for(SR_Booking_Unit__c objSBU : [SELECT s.Id
                                          , s.Case__c
                                          , s.Case__r.Status
                                          , s.Case__r.CaseNumber
                                          , s.Case__r.RecordType.DeveloperName
                                          , s.Case__r.RecordType.Name
                                          , s.Booking_Unit__c 
                                          , s.Booking_Unit__r.Name 
                                     FROM SR_Booking_Unit__c s
                                     WHERE s.Booking_Unit__c IN: bookingUnitIDSet
                                     AND s.Case__r.Status != 'Closed'
                                     AND s.Case__r.Status != 'Rejected'
                                     AND s.Case__r.RecordType.DeveloperName = 'AOPT'])
    {
        if(!mapId_Case.containsKey(objSBU.Case__c))
        {
            Case objCase = objSBU.Case__r;
            objCase.Booking_Unit__r = objSBU.Booking_Unit__r;
            //objCase.Id = objSBU.Case__c;
            //objCase.CaseNumber = objSBU.Case__r.CaseNumber;
            lstExistingCase.add(objCase);
        }
    }
    return lstExistingCase;
  }

  // method used to retrieve the ME from IPMS - EP
  private void fetchMileStoneEventsFromIPMS(String strRegId)
  {
    mileStoneEventPT = new List<SelectOption>();
    mapMileStoneEvents = new Map<String,String>();
    MileStoneEventsWrapper.MileStoneEvents objMileStoneEvents = AOPTMQService.getMasterMilestone(strRegId);
    
    for(MileStoneEventsWrapper.MILESTONE_TAB_TYPE objME : objMileStoneEvents.MILESTONE_TAB_TYPE)
    {
      system.debug('objME'+objME.MILESTONE_EVENT);
      system.debug('objME arabic'+objME.ARABIC_MILESTONE_EVENT);
      mileStoneEventPT.add(new selectOption(objME.MILESTONE_EVENT, objME.MILESTONE_EVENT));
      mapMileStoneEvents.put(objME.MILESTONE_EVENT, objME.ARABIC_MILESTONE_EVENT);
    }
    system.debug('mileStoneEventPT '+mileStoneEventPT);
  }

  // this method is used to make callout to IPMS to fetch the new Payment terms
  private MileStonePaymentDetailsWrapper.MileStonePaymentDetails getNewPaymentTermsFromIPMS(String strRegId)
  {
    MileStonePaymentDetailsWrapper.MileStonePaymentDetails objMileStoneEvents 
                                              = AOPTMQService.getMilestonePaymentDetails(strRegId);
    return objMileStoneEvents;
  }

  private List<NewPaymentTermsWrapper> calculatePaymentsDone(MileStonePaymentDetailsWrapper.REG_TERM_PYMNT_TABLE objME)
  {
    List<NewPaymentTermsWrapper> lstNewPaymentTerms = new List<NewPaymentTermsWrapper>();

    if(!objME.PAID_PERCENTAGE.equalsIgnoreCase('100'))
    {
      Decimal decRemainingPaidPercent = 100 - Decimal.valueOf(objME.PAID_PERCENTAGE);
      Decimal decRemainingMileStonePercent 
                                = ((Decimal.valueOf(objME.MILESTEON_PERCENT_VALUE) * decRemainingPaidPercent) / 100);
      Decimal decMileStonePercentCompleted = Decimal.valueOf(objME.MILESTEON_PERCENT_VALUE) - decRemainingMileStonePercent;
      
      // create new PT for remaining ME percent
      /*NewPaymentTermsWrapper objNewPaymentTermWrapper = new NewPaymentTermsWrapper();
      objNewPaymentTermWrapper.strRegId = objME.REGISTRATION_ID;
      objNewPaymentTermWrapper.dtDueDate = objME.DUE_DATE != null ? objME.DUE_DATE :'';
      objNewPaymentTermWrapper.strMileStonePercentValue = String.valueOf(decRemainingMileStonePercent);
      objNewPaymentTermWrapper.strPaidAmount = objME.PAID_AMOUNT;
      objNewPaymentTermWrapper.strPaidPercentage = objME.PAID_PERCENTAGE;
      objNewPaymentTermWrapper.strDueAmount = objME.DUE_AMOUNT;
      //objNewPaymentTermWrapper.strLineID = objME.LINE_ID;
      objNewPaymentTermWrapper.strMileStoneEventArabic = objME.MILESTONE_EVENT_AR;
      objNewPaymentTermWrapper.strDescription = objME.DESCRIPTION;
      objNewPaymentTermWrapper.strMileStoneEvent = objME.MILESTONE_EVENT;
      objNewPaymentTermWrapper.strInvoiceAmount = objME.INVOICE_AMOUNT;
      objNewPaymentTermWrapper.strInstallment = objME.INSTALLMENT;
      //objNewPaymentTermWrapper.strTermID = objME.TERM_ID;
      objNewPaymentTermWrapper.isReceiptPresent = false;
      objNewPaymentTermWrapper.name = 'Structure Based Payment Plan';
      objNewPaymentTermWrapper.lstMileStoneEventPT = new List<SelectOption>(mileStoneEventPT);
      objNewPaymentTermWrapper.lstStructureBasedPercent = new List<SelectOption>(structureBasedPercent);
      lstNewPaymentTerms.add(objNewPaymentTermWrapper);
      */
      // create new PT for completed ME percent
      NewPaymentTermsWrapper objNewPaymentTermWrapperCompleted = new NewPaymentTermsWrapper();
      objNewPaymentTermWrapperCompleted.strRegId = objME.REGISTRATION_ID;
      objNewPaymentTermWrapperCompleted.dtDueDate = objME.DUE_DATE != null ? objME.DUE_DATE :'';
      objNewPaymentTermWrapperCompleted.strMileStonePercentValue = String.valueOf(decMileStonePercentCompleted);
      objNewPaymentTermWrapperCompleted.strPaidAmount = objME.PAID_AMOUNT;
      objNewPaymentTermWrapperCompleted.strPaidPercentage = objME.PAID_PERCENTAGE;
      objNewPaymentTermWrapperCompleted.strDueAmount = objME.DUE_AMOUNT;
      objNewPaymentTermWrapperCompleted.strLineID = objME.LINE_ID;
      objNewPaymentTermWrapperCompleted.strMileStoneEventArabic = objME.MILESTONE_EVENT_AR;
      objNewPaymentTermWrapperCompleted.strDescription = objME.DESCRIPTION;
      objNewPaymentTermWrapperCompleted.strMileStoneEvent = objME.MILESTONE_EVENT;
      objNewPaymentTermWrapperCompleted.strInvoiceAmount = objME.INVOICE_AMOUNT;
      objNewPaymentTermWrapperCompleted.strInstallment = objME.INSTALLMENT;
      objNewPaymentTermWrapperCompleted.strTermID = objME.TERM_ID;
      objNewPaymentTermWrapperCompleted.isReceiptPresent = true;
      objNewPaymentTermWrapperCompleted.name = 'Structure Based Payment Plan';
      objNewPaymentTermWrapperCompleted.lstMileStoneEventPT = new List<SelectOption>(mileStoneEventPT);
      objNewPaymentTermWrapperCompleted.blnNewPaymentTerm = false;
      lstNewPaymentTerms.add(objNewPaymentTermWrapperCompleted);
    }
    system.debug('calculatePaymentsDone lstNewPaymentTerms '+lstNewPaymentTerms);

    return lstNewPaymentTerms;
  }
  

  // wrapper class to display new Payment terms for payment plan fetched from IPMS
  public class NewPaymentTermsWrapper  implements Comparable 
  {
    public String strRegId {get;set;}
    public String dtDueDate {get;set;}
    public String strMileStonePercentValue {get;set;}
    public String strPaidAmount {get;set;}
    public String strPaidPercentage {get;set;}
    public String strDueAmount {get;set;}
    public String strLineID {get;set;}
    public String strMileStoneEventArabic {get;set;}
    public String strDescription {get;set;}
    public String strMileStoneEvent {get;set;}
    public String strInvoiceAmount {get;set;}
    public String strInstallment {get;set;}
    public String strTermID {get;set;}
    public Boolean isReceiptPresent {get;set;}
    public String name {get;set;}
    public List<SelectOption> lstMileStoneEventPT {get;set;}// store the ME fetched from IPMS - EP
    public Boolean blnNewPaymentTerm {get;set;}

    public Integer compareTo(Object ObjToCompare) 
    {
      if(String.isNotBlank(strLineID) && String.isNotBlank(((NewPaymentTermsWrapper)ObjToCompare).strLineID))
      {
        return strLineID.CompareTo(((NewPaymentTermsWrapper)ObjToCompare).strLineID);
      }
      return 0;
    }
  }

  // wrapper class to store teh selected New PT by CRE
  public class SelectedNewPaymentTermsByCRE
  {
    public String installment {get;set;}
    public Boolean isReceiptPresent {get;set;}
    public String description {get;set;}
    public String mileStoneEvent {get;set;}
    public String mileStoneEventArabic {get;set;}
    public String percentValue {get;set;}
    public String paymentDate {get;set;}
    public String name {get;set;}
    public Boolean blnNewTerm {get;set;}
    public String strLineID {get;set;}
    public String strTermID {get;set;}
    public String strPaymentDate {get;set;}
    public String strRegID {get;set;}
    public String strStatus {get;set;}
    public String strPaidAmount {get;set;}
    public String strInvoiceAmount {get;set;}
    public String strDueAmount {get;set;}

  }

  // Wrapper class to display Booking Unit related to Project
  public class BookingUnitWrapper
  {
    public Booking_Unit__c objBookingUnit {get;set;}
    public Boolean blnIsChecked {get;set;}
    public String  strMatch {get;set;}

    public BookingUnitWrapper( Booking_Unit__c objBookingUnit,Boolean blnIsChecked, String strMatch)
    {
      this.objBookingUnit = objBookingUnit;
      this.blnIsChecked = blnIsChecked;
      this.strMatch = strMatch;
    }
  }

  // wrappr class to store the URL of SOA document for each booking unit
  public class SOAWrapper
  {
    public String strSOAURL {get;set;}
    public Booking_Unit__c objBookingUnit {get;set;}
  }
}