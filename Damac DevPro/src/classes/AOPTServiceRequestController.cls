/* Class Functionality : It is used to handle processing of AOPT SR
* Revision History: 
* Version     Author                Date             Description.
* 1.1         Eternus Solutions     10/08/2017       Initial Draft
*/
public with sharing class AOPTServiceRequestController 
{
  
  //String properties
  public String strSelectedProject {get;set;}
  public String strSelectedNewPP {get;set;}

  //Object properties
  public Booking__c objBooking {get;set;}
  public Account objAccount {get;set;}
  
  //Boolean properties
  public Boolean blnShowPortfolio {get;set;}
  public Boolean blnShowProjectSelection {get;set;}
  public Boolean blnShowNewPP {get;set;}
  
  //List properties
  public List<CustomerPortfolioDetails> lstCustomerPortfolio {get;set;}
  public List<SelectOption> lstProjectSelectOption {get;set;}
  public List<Booking_Unit__c> lstBookingUnitPerProject {get;set;}
  public List<BookingUnitWrapper> lstBookingUnitWrapper {get;set;}
  public List<NewPaymentTermsWrapper> lstNewPaymentTermsDisplay {get;set;}
  public List<SelectOption> lstNewPaymentTermSelectOption {get;set;}
  
  
  //Map properties
  Map<Id,List<Booking_Unit__c>> mapProjectIdToBookingUnit  = new Map<Id,List<Booking_Unit__c>>();
  public Map<String,List<Payment_Terms__c>> mapPaymentTermToPlan {get;set;}
  Map<String,List<NewPaymentTermsWrapper>> mapNewPaymentTermsWrapper = new Map<String,list<NewPaymentTermsWrapper>>();

  //Constructor
  public AOPTServiceRequestController() {
    objBooking = new Booking__c();
    blnShowPortfolio = false;
    blnShowProjectSelection = false;
    blnShowNewPP = false;
  }


  // method to get the Customer Portfolio Information
  public PageReference getCustomerPortfolio()
  {
    system.debug('objBooking Account'+objBooking.Account__c);
    lstCustomerPortfolio = new List<CustomerPortfolioDetails>();
    lstProjectSelectOption = new List<SelectOption>();

    

    lstProjectSelectOption.add(new selectOption('None','--None--'));

    for(Booking_Unit__c objBookingUnit : [ Select Id,Inventory__r.Unit__c,Inventory__r.Property_Name_2__c
                                      ,Inventory__r.IPMS_Bedrooms__c,Inventory__r.Selling_Price__c
                                      ,Inventory__r.Price_Per_Sqft__c,Inventory__r.Property_Status__c
                                      ,Inventory__r.Anticipated_Completion_Date__c,Inventory__r.Property__r.Name
                                      ,Inventory__r.Property__c
                                      FROM Booking_Unit__c where Booking__r.Account__c =: objBooking.Account__c
                                    ]) 
    {
      CustomerPortfolioDetails objCustomerPortfolio = new CustomerPortfolioDetails();
      objCustomerPortfolio.strUnitName = objBookingUnit.Inventory__r.Unit__c;
      objCustomerPortfolio.strProjectName = objBookingUnit.Inventory__r.Property_Name_2__c;
      objCustomerPortfolio.strNoOfBedRooms = objBookingUnit.Inventory__r.IPMS_Bedrooms__c;
      objCustomerPortfolio.strValue = String.valueOf(objBookingUnit.Inventory__r.Selling_Price__c);
      objCustomerPortfolio.strCurrentPricePerSqFts = String.valueOf(objBookingUnit.Inventory__r.Price_Per_Sqft__c);
      objCustomerPortfolio.strStatus = objBookingUnit.Inventory__r.Property_Status__c;
      objCustomerPortfolio.strAnticipatedDate = objBookingUnit.Inventory__r.Anticipated_Completion_Date__c;
      objCustomerPortfolio.strTotalOverDue = 'Empty';
      objCustomerPortfolio.strNextPayment = 'Empty';

      lstCustomerPortfolio.add(objCustomerPortfolio);

      lstProjectSelectOption.add(new selectOption(objBookingUnit.Inventory__r.Property__c, objBookingUnit.Inventory__r.Property__r.Name));

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
    
    Set<SelectOption> myset = new Set<SelectOption>();
    myset.addAll(lstProjectSelectOption);
    lstProjectSelectOption.clear();
    lstProjectSelectOption.addAll(myset);

    objAccount = [ select id,name,PersonTitle,PersonMobilePhone,PersonEmail,FirstName,LastName,MiddleName,Party_ID__c 
                  from Account where id =: objBooking.Account__c];

    blnShowPortfolio = true;
    blnShowProjectSelection = true;
    system.debug('lstCustomerPortfolio '+lstCustomerPortfolio);
    system.debug('showPortfolioshowPortfolio '+blnShowPortfolio);
    system.debug('lstProjectSelectOption '+lstProjectSelectOption);
    return null;
  }

  public PageReference getBookingUnitsRelatedToProject()
  {
    system.debug('strSelectedProject '+strSelectedProject);
    system.debug('mapProjectIdToBookingUnit '+mapProjectIdToBookingUnit);
    lstBookingUnitPerProject = new List<Booking_Unit__c>();

    lstBookingUnitWrapper = new List<BookingUnitWrapper>();

    if(mapProjectIdToBookingUnit.containsKey(strSelectedProject) && mapProjectIdToBookingUnit.get(strSelectedProject) != null)
    {
      lstBookingUnitPerProject = mapProjectIdToBookingUnit.get(strSelectedProject);
    }
    system.debug('lstBookingUnitPerProject '+lstBookingUnitPerProject);

    if(lstBookingUnitPerProject != null && lstBookingUnitPerProject.size() > 0)
    {
      for(Booking_Unit__c objBookingUnit : lstBookingUnitPerProject)
      {
        lstBookingUnitWrapper.add(new BookingUnitWrapper(objBookingUnit,false));
      }
    }

    return null;
  }

  public PageReference getCurrentPaymemtTerm()
  {
    system.debug('lstBookingUnitWrapper '+lstBookingUnitWrapper);

    // here we will perform the Callout to Rule Engine by passing the Booking Unit Details
    // to perform Litigation Flag check,RERA Detail Calculation,ACD Calculation.
    // if Response is success, then fetch the current payment plan and display on UI
    // if response is erorr, i.e validation fails for above mentioned points
    // then we will show that error message on UI and will not proceed further
    Set<Id> setBookingUnitIds = new Set<Id>();
    mapPaymentTermToPlan = new Map<String,List<Payment_Terms__c>>();
    for(BookingUnitWrapper objBookingWrapper : lstBookingUnitWrapper)
    {
      setBookingUnitIds.add(objBookingWrapper.objBookingUnit.Id);
    }

    system.debug('setBookingUnitIds '+setBookingUnitIds);
    
    for(Payment_Terms__c objPaymentTerm : [ Select Id,Name,Payment_Plan__r.Name,Milestone_Event__c
                                            ,Installment__c,Description__c,Percent_Value__c
                                            ,Payment_Date__c,Milestone_Event_Arabic__c 
                                            FROM Payment_Terms__c WHERE Booking_Unit__c IN:setBookingUnitIds
                                          ])
    {
      system.debug('objPaymentTerm '+objPaymentTerm);

      if(mapPaymentTermToPlan.containsKey(objPaymentTerm.Payment_Plan__r.Name) && mapPaymentTermToPlan.get(objPaymentTerm.Payment_Plan__r.Name) != null)
      {
        
        List<Payment_Terms__c> lstPaymentTerms = mapPaymentTermToPlan.get(objPaymentTerm.Payment_Plan__r.Name);
        lstPaymentTerms.add(objPaymentTerm);
        mapPaymentTermToPlan.put(objPaymentTerm.Payment_Plan__r.Name,lstPaymentTerms);
      }
      else
      {
        mapPaymentTermToPlan.put(objPaymentTerm.Payment_Plan__r.Name,new List<Payment_Terms__c>{objPaymentTerm});
      }
    }
    system.debug('mapPaymentTermToPlan '+mapPaymentTermToPlan);
    return null;
  }

  public PageReference validateBookingUnits()
  {
    // here we will perform callout to IPMS or Rule Engine to validate the booking units selected
    // by CRE for AOPT.
    List<NewPaymentTermsWrapper> lstNewPaymentTerms = new List<NewPaymentTermsWrapper>();

    //new payment term  for Structure Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperFirst = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperFirst.name = 'Structure Based Payment Plan';
    objNewPaymentTermWrapperFirst.installment = 'DP';
    objNewPaymentTermWrapperFirst.description = 'DEPOSIT';
    objNewPaymentTermWrapperFirst.mileStoneEvent = 'Immediate';
    objNewPaymentTermWrapperFirst.percentValue = '14';
    objNewPaymentTermWrapperFirst.paymentDate = '08-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperFirst);

    //new payment term 1 for Structure Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperFirst1 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperFirst1.name = 'Structure Based Payment Plan';
    objNewPaymentTermWrapperFirst1.installment = 'I001';
    objNewPaymentTermWrapperFirst1.description = '1ST INSTALLMENT';
    objNewPaymentTermWrapperFirst1.mileStoneEvent = '--';
    objNewPaymentTermWrapperFirst1.percentValue = '0';
    objNewPaymentTermWrapperFirst1.paymentDate = '08-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperFirst1);

    //new payment term 2 for Structure Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperFirst2 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperFirst2.name = 'Structure Based Payment Plan';
    objNewPaymentTermWrapperFirst2.installment = 'I002';
    objNewPaymentTermWrapperFirst2.description = '2ND INSTALLMENT';
    objNewPaymentTermWrapperFirst2.mileStoneEvent = 'Within 60 days of Sales Date';
    objNewPaymentTermWrapperFirst2.percentValue = '10';
    objNewPaymentTermWrapperFirst2.paymentDate = '08-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperFirst2);

    //new payment term 3 for Structure Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperFirst3 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperFirst3.name = 'Structure Based Payment Plan';
    objNewPaymentTermWrapperFirst3.installment = 'I003';
    objNewPaymentTermWrapperFirst3.description = '3ND INSTALLMENT';
    objNewPaymentTermWrapperFirst3.mileStoneEvent = 'Within 180 days of Sales Date';
    objNewPaymentTermWrapperFirst3.percentValue = '10';
    objNewPaymentTermWrapperFirst3.paymentDate = '08-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperFirst3);

    //new payment term 4 for Structure Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperFirst4 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperFirst4.name = 'Structure Based Payment Plan';
    objNewPaymentTermWrapperFirst4.installment = 'I004';
    objNewPaymentTermWrapperFirst4.description = '4TH INSTALLMENT';
    objNewPaymentTermWrapperFirst4.mileStoneEvent = 'Within 360 days of Sales Date';
    objNewPaymentTermWrapperFirst4.percentValue = '10';
    objNewPaymentTermWrapperFirst4.paymentDate = '08-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperFirst4);

    //new payment term 5 for Structure Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperFirst5 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperFirst5.name = 'Structure Based Payment Plan';
    objNewPaymentTermWrapperFirst5.installment = 'I005';
    objNewPaymentTermWrapperFirst5.description = '5TH INSTALLMENT';
    objNewPaymentTermWrapperFirst5.mileStoneEvent = 'On Completion Of basement structure';
    objNewPaymentTermWrapperFirst5.percentValue = '10';
    objNewPaymentTermWrapperFirst5.paymentDate = '08-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperFirst5);

    //new payment term 6 for Structure Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperFirst6 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperFirst6.name = 'Structure Based Payment Plan';
    objNewPaymentTermWrapperFirst6.installment = 'I006';
    objNewPaymentTermWrapperFirst6.description = '6TH INSTALLMENT';
    objNewPaymentTermWrapperFirst6.mileStoneEvent = 'On Completion Of 40th Floor Structure';
    objNewPaymentTermWrapperFirst6.percentValue = '10';
    objNewPaymentTermWrapperFirst6.paymentDate = '08-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperFirst6);

    //new payment term 7 for Structure Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperFirst7 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperFirst7.name = 'Structure Based Payment Plan';
    objNewPaymentTermWrapperFirst7.installment = 'I007';
    objNewPaymentTermWrapperFirst7.description = '7TH INSTALLMENT';
    objNewPaymentTermWrapperFirst7.mileStoneEvent = 'On Completion Of 50th Floor Structure';
    objNewPaymentTermWrapperFirst7.percentValue = '10';
    objNewPaymentTermWrapperFirst7.paymentDate = '08-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperFirst7);

    //new payment term 8 for Structure Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperFirst8 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperFirst8.name = 'Structure Based Payment Plan';
    objNewPaymentTermWrapperFirst8.installment = 'I008';
    objNewPaymentTermWrapperFirst8.description = '8TH INSTALLMENT';
    objNewPaymentTermWrapperFirst8.mileStoneEvent = 'On Completion of 60th Floor Structure ';
    objNewPaymentTermWrapperFirst8.percentValue = '10';
    objNewPaymentTermWrapperFirst8.paymentDate = '08-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperFirst8);

    //new payment term 9 for Structure Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperFirst9 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperFirst9.name = 'Structure Based Payment Plan';
    objNewPaymentTermWrapperFirst9.installment = 'I009';
    objNewPaymentTermWrapperFirst9.description = '9TH INSTALLMENT';
    objNewPaymentTermWrapperFirst9.mileStoneEvent = 'On Completion';
    objNewPaymentTermWrapperFirst9.percentValue = '20';
    objNewPaymentTermWrapperFirst9.paymentDate = '08-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperFirst9);

    //new payment term 1 for Date Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperSecond = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperSecond.name = 'Date Based Payment Plan';
    objNewPaymentTermWrapperSecond.installment = 'DP';
    objNewPaymentTermWrapperSecond.description = 'DEPOSIT';
    objNewPaymentTermWrapperSecond.mileStoneEvent = 'Immediate';
    objNewPaymentTermWrapperSecond.percentValue = '24';
    objNewPaymentTermWrapperSecond.paymentDate = '09-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperSecond);

    //new payment term 2 for Date Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperSecond1 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperSecond1.name = 'Date Based Payment Plan';
    objNewPaymentTermWrapperSecond1.installment = 'I001';
    objNewPaymentTermWrapperSecond1.description = '1ST INSTALLMENT';
    objNewPaymentTermWrapperSecond1.mileStoneEvent = '--';
    objNewPaymentTermWrapperSecond1.percentValue = '0';
    objNewPaymentTermWrapperSecond1.paymentDate = '09-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperSecond1);

    //new payment term 3 for Date Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperSecond2 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperSecond2.name = 'Date Based Payment Plan';
    objNewPaymentTermWrapperSecond2.installment = 'I002';
    objNewPaymentTermWrapperSecond2.description = '2ND INSTALLMENT';
    objNewPaymentTermWrapperSecond2.mileStoneEvent = 'Within 180 days of Sales Date';
    objNewPaymentTermWrapperSecond2.percentValue = '5';
    objNewPaymentTermWrapperSecond2.paymentDate = '09-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperSecond2);

    //new payment term 4 for Date Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperSecond3 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperSecond3.name = 'Date Based Payment Plan';
    objNewPaymentTermWrapperSecond3.installment = 'I003';
    objNewPaymentTermWrapperSecond3.description = '3RD INSTALLMENT';
    objNewPaymentTermWrapperSecond3.mileStoneEvent = 'Within 300 days of Sales Date';
    objNewPaymentTermWrapperSecond3.percentValue = '5';
    objNewPaymentTermWrapperSecond3.paymentDate = '09-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperSecond3);

    //new payment term 5 for Date Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperSecond5 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperSecond5.name = 'Date Based Payment Plan';
    objNewPaymentTermWrapperSecond5.installment = 'I004';
    objNewPaymentTermWrapperSecond5.description = '3RD INSTALLMENT';
    objNewPaymentTermWrapperSecond5.mileStoneEvent = 'Within 540 days of Sales Date';
    objNewPaymentTermWrapperSecond5.percentValue = '10';
    objNewPaymentTermWrapperSecond5.paymentDate = '09-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperSecond5);

    //new payment term 6 for Date Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperSecond6 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperSecond6.name = 'Date Based Payment Plan';
    objNewPaymentTermWrapperSecond6.installment = 'I005';
    objNewPaymentTermWrapperSecond6.description = '5TH INSTALLMENT';
    objNewPaymentTermWrapperSecond6.mileStoneEvent = 'Within 630 days of Sales Date';
    objNewPaymentTermWrapperSecond6.percentValue = '10';
    objNewPaymentTermWrapperSecond6.paymentDate = '09-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperSecond6);

    //new payment term 7 for Date Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperSecond7 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperSecond7.name = 'Date Based Payment Plan';
    objNewPaymentTermWrapperSecond7.installment = 'I006';
    objNewPaymentTermWrapperSecond7.description = '6TH INSTALLMENT';
    objNewPaymentTermWrapperSecond7.mileStoneEvent = 'Within 720 days of Sales Date';
    objNewPaymentTermWrapperSecond7.percentValue = '10';
    objNewPaymentTermWrapperSecond7.paymentDate = '09-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperSecond7);

    //new payment term 8 for Date Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperSecond8 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperSecond8.name = 'Date Based Payment Plan';
    objNewPaymentTermWrapperSecond8.installment = 'I007';
    objNewPaymentTermWrapperSecond8.description = '7TH INSTALLMENT';
    objNewPaymentTermWrapperSecond8.mileStoneEvent = 'Within 900 days of Sales Date';
    objNewPaymentTermWrapperSecond8.percentValue = '10';
    objNewPaymentTermWrapperSecond8.paymentDate = '09-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperSecond8);

    //new payment term 8 for Date Based Payment Plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperSecond9 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperSecond9.name = 'Date Based Payment Plan';
    objNewPaymentTermWrapperSecond9.installment = 'I008';
    objNewPaymentTermWrapperSecond9.description = '8TH INSTALLMENT';
    objNewPaymentTermWrapperSecond9.mileStoneEvent = 'On Completion';
    objNewPaymentTermWrapperSecond9.percentValue = '30';
    objNewPaymentTermWrapperSecond9.paymentDate = '09-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperSecond9);



    //new payment term 1 for %age Based payment plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperThird1 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperThird1.name = '%age Based payment plan';
    objNewPaymentTermWrapperThird1.installment = 'DP';
    objNewPaymentTermWrapperThird1.description = 'DEPOSIT';
    objNewPaymentTermWrapperThird1.mileStoneEvent = 'Immediate';
    objNewPaymentTermWrapperThird1.percentValue = '24';
    objNewPaymentTermWrapperThird1.paymentDate = '10-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperThird1);

    //new payment term 2 for %age Based payment plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperThird2 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperThird2.name = '%age Based payment plan';
    objNewPaymentTermWrapperThird2.installment = 'I001';
    objNewPaymentTermWrapperThird2.description = '1ST INSTALLMENT';
    objNewPaymentTermWrapperThird2.mileStoneEvent = '--';
    objNewPaymentTermWrapperThird2.percentValue = '0';
    objNewPaymentTermWrapperThird2.paymentDate = '10-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperThird2);

    //new payment term 3 for %age Based payment plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperThird3 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperThird3.name = '%age Based payment plan';
    objNewPaymentTermWrapperThird3.installment = 'I002';
    objNewPaymentTermWrapperThird3.description = '2ND INSTALLMENT';
    objNewPaymentTermWrapperThird3.mileStoneEvent = 'Within 90 days of Sales Date';
    objNewPaymentTermWrapperThird3.percentValue = '10';
    objNewPaymentTermWrapperThird3.paymentDate = '10-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperThird3);

    //new payment term 4 for %age Based payment plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperThird4 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperThird4.name = '%age Based payment plan';
    objNewPaymentTermWrapperThird4.installment = 'I003';
    objNewPaymentTermWrapperThird4.description = '3RD INSTALLMENT';
    objNewPaymentTermWrapperThird4.mileStoneEvent = 'On 20% Of Project Completion';
    objNewPaymentTermWrapperThird4.percentValue = '10';
    objNewPaymentTermWrapperThird4.paymentDate = '10-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperThird4);

    //new payment term 5 for %age Based payment plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperThird5 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperThird5.name = '%age Based payment plan';
    objNewPaymentTermWrapperThird5.installment = 'I004';
    objNewPaymentTermWrapperThird5.description = '4TH INSTALLMENT';
    objNewPaymentTermWrapperThird5.mileStoneEvent = 'On 30% Of Project Completion';
    objNewPaymentTermWrapperThird5.percentValue = '10';
    objNewPaymentTermWrapperThird5.paymentDate = '10-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperThird5);

    //new payment term 6 for %age Based payment plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperThird6 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperThird6.name = '%age Based payment plan';
    objNewPaymentTermWrapperThird6.installment = 'I005';
    objNewPaymentTermWrapperThird6.description = '5TH INSTALLMENT';
    objNewPaymentTermWrapperThird6.mileStoneEvent = 'On 40% Of Project Completion';
    objNewPaymentTermWrapperThird6.percentValue = '10';
    objNewPaymentTermWrapperThird6.paymentDate = '10-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperThird6);

    //new payment term 7 for %age Based payment plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperThird7 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperThird7.name = '%age Based payment plan';
    objNewPaymentTermWrapperThird7.installment = 'I006';
    objNewPaymentTermWrapperThird7.description = '6TH INSTALLMENT';
    objNewPaymentTermWrapperThird7.mileStoneEvent = 'On 50% Of Project Completion';
    objNewPaymentTermWrapperThird7.percentValue = '10';
    objNewPaymentTermWrapperThird7.paymentDate = '10-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperThird7);

    //new payment term 8 for %age Based payment plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperThird8 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperThird8.name = '%age Based payment plan';
    objNewPaymentTermWrapperThird8.installment = 'I007';
    objNewPaymentTermWrapperThird8.description = '7TH INSTALLMENT';
    objNewPaymentTermWrapperThird8.mileStoneEvent = 'On 60% Of Project Completion';
    objNewPaymentTermWrapperThird8.percentValue = '10';
    objNewPaymentTermWrapperThird8.paymentDate = '10-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperThird8);

    //new payment term 9 for %age Based payment plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperThird9 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperThird9.name = '%age Based payment plan';
    objNewPaymentTermWrapperThird9.installment = 'I008';
    objNewPaymentTermWrapperThird9.description = '8TH INSTALLMENT';
    objNewPaymentTermWrapperThird9.mileStoneEvent = 'On 70% Of Project Completion';
    objNewPaymentTermWrapperThird9.percentValue = '10';
    objNewPaymentTermWrapperThird9.paymentDate = '10-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperThird9);

    //new payment term 10 for %age Based payment plan
    NewPaymentTermsWrapper objNewPaymentTermWrapperThird10 = new NewPaymentTermsWrapper();
    objNewPaymentTermWrapperThird10.name = '%age Based payment plan';
    objNewPaymentTermWrapperThird10.installment = 'I009';
    objNewPaymentTermWrapperThird10.description = '9TH INSTALLMENT';
    objNewPaymentTermWrapperThird10.mileStoneEvent = 'On Completion';
    objNewPaymentTermWrapperThird10.percentValue = '10';
    objNewPaymentTermWrapperThird10.paymentDate = '10-11-2017';

    lstNewPaymentTerms.add(objNewPaymentTermWrapperThird10);

    if(lstNewPaymentTerms != null && lstNewPaymentTerms.size() > 0)
    {
      lstNewPaymentTermSelectOption = new List<SelectOption>();
      List<NewPaymentTermsWrapper> lstNewPaymentTermsWrapper;
      lstNewPaymentTermSelectOption.add(new selectOption('None', '-None-'));
      for(NewPaymentTermsWrapper objNewPPWrapper : lstNewPaymentTerms)
      {
        lstNewPaymentTermSelectOption.add(new selectOption(objNewPPWrapper.name, objNewPPWrapper.name));
        if(mapNewPaymentTermsWrapper.containsKey(objNewPPWrapper.name) && mapNewPaymentTermsWrapper.get(objNewPPWrapper.name) != null)
        {
          lstNewPaymentTermsWrapper = new List<NewPaymentTermsWrapper>();
          lstNewPaymentTermsWrapper = mapNewPaymentTermsWrapper.get(objNewPPWrapper.name);
          lstNewPaymentTermsWrapper.add(objNewPPWrapper);
          mapNewPaymentTermsWrapper.put(objNewPPWrapper.name,lstNewPaymentTermsWrapper);
        }
        else
        {
          mapNewPaymentTermsWrapper.put(objNewPPWrapper.name,new List<NewPaymentTermsWrapper>{objNewPPWrapper});
        }
      }
    }

    Set<SelectOption> myset = new Set<SelectOption>();
    myset.addAll(lstNewPaymentTermSelectOption);
    lstNewPaymentTermSelectOption.clear();
    lstNewPaymentTermSelectOption.addAll(myset);
    blnShowNewPP = true;
    return null;
  }

  public PageReference getNewPaymentPlanByName()
  {
    system.debug('strSelectedNewPP '+strSelectedNewPP);
    lstNewPaymentTermsDisplay = new List<NewPaymentTermsWrapper>();
    if(String.isNotBlank(strSelectedNewPP))
    {
      lstNewPaymentTermsDisplay.addAll(mapNewPaymentTermsWrapper.get(strSelectedNewPP));
    }
    return null;
  }

  public PageReference checkAOPTEligibility()
  {
    system.debug('check aopt eligibility method called');

    return null;
  }

  Public Attachment myfile;
  Public Attachment getmyfile()
  {
      myfile = new Attachment();
      return myfile;
  }
   
  Public Pagereference Savedoc()
  {
      String buID = 'a0x7E000005d0ae';

      Attachment a = new Attachment(parentId = buID, name=myfile.name, body = myfile.body);
       
      /* insert the attachment */
      insert a;
      return NULL;
  }

  public class NewPaymentTermsWrapper
  {
    public String installment {get;set;}
    public String description {get;set;}
    public String mileStoneEvent {get;set;}
    public String percentValue {get;set;}
    public String paymentDate {get;set;}
    public String name {get;set;}
  }

  // Wrapper class to display Booking Unit related to Project
  public class BookingUnitWrapper
  {
    public Booking_Unit__c objBookingUnit {get;set;}
    public Boolean blnIsChecked {get;set;}

    public BookingUnitWrapper(Booking_Unit__c objBookingUnit,Boolean blnIsChecked)
    {
      this.objBookingUnit = objBookingUnit;
      this.blnIsChecked = blnIsChecked;
    }
  }
}