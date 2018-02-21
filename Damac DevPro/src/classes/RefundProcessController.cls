/* 
    Use : For Token and Customer Refund process
    Created By: Swapnil Gholap 
*/

public class RefundProcessController{
    public List<Account> lstAccount ;
    public Account objAcc {get;set;}
    public String strAccountID ;
    public List<Booking_Unit__c> lstBookingUnit {get;set;}
    public List<SelectOption> lstBookingUnitOptions {get;set;} 
    public String strSelectedRefundProcess{get;set;}
    public List<wrapper> lstWrapper {get;set;}
    public List<WrapperBookingUnit> lstWrapperBookingUnit{get;set;}
    public String strSelectedBookingUnit {get;set;}
    public WrapperBookingUnit objWrapperBookingUnit {get;set;}
    public boolean blnShowTypeOfRefund {get;set;}
    public boolean blnShowBookingUnit {get;set;}
    public boolean blnShowRefundDetails {get;set;}
    public Map<String,WrapperBookingUnit> mapWrapperBookingUnit;
    public Case objCase;
    public List<SR_Booking_Unit__c> lstSRbookingUnit;
    public Decimal decTokenRefundAmount {get;set;}
    public Decimal decCustomerRefundAmount {get;set;}
    public Decimal decRefundAmount {get;set;}
    public List<Case> lstOpenSRs {get;set;}
    
    public RefundProcessController(){
        strAccountID = ApexPages.currentPage().getParameters().get('accID');
        blnShowTypeOfRefund = false;
        blnShowBookingUnit = false;
        blnShowRefundDetails = false;
        lstAccount = new List<Account>();
        lstSRbookingUnit = new List<SR_Booking_Unit__c>();
        objAcc = new Account();
        objWrapperBookingUnit = new WrapperBookingUnit();
        objCase = new Case();
        if(String.isNotBlank(strAccountID)){
            lstAccount = [SELECT Id, Name, LastName, FirstName, Salutation, MiddleName,
            IsPersonAccount,phone,PersonEmail,PersonMobilePhone
            FROM Account where id =: strAccountID];
            
            if(lstAccount.Size()>0){
                blnShowTypeOfRefund = true;
                objAcc = lstAccount[0];            
                lstBookingUnit = new List<Booking_Unit__c>();
                lstBookingUnit = [Select id,name,Property_Name__c,Inventory__c,
                Inventory__r.Property__r.Name,Unit_Selling_Price__c,
                Booking_Unit_Type__c, Inventory__r.Property_Status__c,
                Registration_ID__c, Inventory__r.Property_Name_2__c,
                Inventory__r.Unit__c, Inventory__r.ACD_Date__c, Unit_Selling_Price_AED__c 
                from Booking_Unit__c where Booking__r.Account__c =:
                strAccountID Order By Inventory__r.Property__r.Name ASC ];
                
                System.debug('--lstBookingUnit---'+lstBookingUnit.Size()+'---'+lstBookingUnit);
                if(lstBookingUnit.Size()>0){               
                    //lstBookingUnitOprtions = new List<SelectOption>();
                    //lstBookingUnitOprtions.add(new SelectOption('','-None-'));
                    //for(Booking_Unit__c bu :lstBookingUnit){
                    //     lstBookingUnitOprtions.add(new SelectOption(bu.id,bu.Inventory__r.Unit__c));
                    //}
                    lstWrapper = new List<Wrapper>();
                    for(Booking_Unit__c bu : lstBookingUnit){
                        lstWrapper.add(new wrapper(false,bu));
                    }
                }
            }    
        }
    }
    
    public boolean RecordSelection(){
        boolean checkSelected = false;
        for(Wrapper w : lstWrapper){
            if(w.Wselected){
                checkSelected = true;
                break;
            }
        }
        return checkSelected;
    }
    public void bookingUnitDetails(){
        System.debug('---strSelectedRefundProcess--'+strSelectedRefundProcess);
        if(String.isNotBlank(strSelectedRefundProcess)){
            if(RecordSelection() == false){
                ApexPages.addmessage(new ApexPages.message(
                ApexPages.severity.Error,'Please select atleast one booking unit'));
            }
            else{
                lstWrapperBookingUnit = new List<WrapperBookingUnit>();
                lstBookingUnitOptions = new List<SelectOption>();
                integer intCounter = 0;
                blnShowBookingUnit = true;
                mapWrapperBookingUnit = new Map<String,WrapperBookingUnit>();
                for(Wrapper w : lstWrapper){
                    if(w.Wselected){
                        WrapperBookingUnit objWrb = new WrapperBookingUnit();
                        intCounter++;
                        objWrb.intNumber = intCounter;
                        objWrb.strUnit = w.WBU.Inventory__r.Unit__c;
                        objWrb.strProject = w.WBU.Inventory__r.Property__r.Name;
                        objWrb.strProjectCity = w.WBU.Inventory__r.Property__r.Name+' Pune';
                        objWrb.strBedroomType = 'Master Bedroom';
                        objWrb.strUnitType = w.WBU.Booking_Unit_Type__c;
                        objWrb.strPermittedUse = 'Yes';
                        objWrb.strReady_OffPlan = 'Ready';
                        objWrb.strRentalPool = 'Yes';
                        objWrb.blnDispute = true;
                        objWrb.blnEnforcement = false;
                        objWrb.blnLitigation = false;
                        objWrb.blnMortage = true;
                        objWrb.blnCourtCase = false;
                        objWrb.blnFTLsent = true;
                        objWrb.blnEHO = true;
                        objWrb.blnHO = false;
                        objWrb.strPCC = 'Test';
                        objWrb.strPCC = 'Test';
                        objWrb.strOQOODregistered = 'No';
                        objWrb.strAgreementStatus = 'Pending';
                        objWrb.strUnderTermination = 'No';
                        
                        lstBookingUnitOptions.add(new SelectOption
                        (String.ValueOf(objWrb.intNumber),objWrb.strUnit));
                        
                        lstWrapperBookingUnit.add(objWrb);
                        
                        mapWrapperBookingUnit.put(String.ValueOf(objWrb.intNumber),objWrb);
                     }
                 }
                 objWrapperBookingUnit = lstWrapperBookingUnit[0];
                 strSelectedBookingUnit = String.valueOf(lstWrapperBookingUnit[0].intNumber);
                 
                 
                Id devRecordTypeId =
                Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Refund').getRecordTypeId();            
                objCase.AccountID = strAccountID ;
                objCase.RecordTypeID = devRecordTypeId;
                objCase.Subject = '--Test--'+System.Now();
                upsert objCase; 
                
               if(lstSRbookingUnit.Size() == 0){
	               for(Wrapper w : lstWrapper){
	                    if(w.Wselected){
	                        SR_Booking_Unit__c SRB = new SR_Booking_Unit__c();
	                        SRB.Case__c = objCase.id;
	                        SRB.Booking_Unit__c = w.WBU.id;
	                        lstSRbookingUnit.add(SRB);
	                    }
	                }
                upsert lstSRbookingUnit; 
                }                               
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(
            ApexPages.severity.Error,'Please select Type of Refund'));
        }
    }
    
    public void showBookingUnitInfo(){
        System.debug('---strSelectedBookingUnit--'+strSelectedBookingUnit);
        if(String.isNotBlank(strSelectedBookingUnit) 
        && mapWrapperBookingUnit.containsKey(strSelectedBookingUnit)){
            objWrapperBookingUnit = mapWrapperBookingUnit.get(strSelectedBookingUnit);
        }
    }
    public void showRefundDetails(){
        blnShowRefundDetails = true;
        decTokenRefundAmount = 50000;
        decCustomerRefundAmount = 20000;
        decRefundAmount = 10000;
    }
    
    public class Wrapper {
    public boolean Wselected {get;set;}
    public Booking_Unit__c WBU {get;set;}
    
        public wrapper(boolean selected,Booking_Unit__c BU ){
            Wselected = selected ;
            WBU = BU;
        }
    }
    
    
   
}