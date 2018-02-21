public with sharing class TitleDeedProcess {
 
    public list<SelectOption> lstUnits {get;set;}
    public list<SelectOption> resHandedOver {get;set;}
    public list<SelectOption> lstModes {get;set;}
    public string strSelectedUnit {get;set;}
    public string strSelectedMode{get;set;}
    public string strHandedOver {get;set;}
    public string strOverdues {get;set;}
    public string strPenalties {get;set;}
    public string strAdminFee {get;set;}
    public string strOtherDues {get;set;}
    public string strTotalAmt {get;set;}
    public string strCaseNumber {get;set;}
    public boolean blnStep1 {get;set;}
    public boolean blnStep2 {get;set;}
    public boolean blnStep3 {get;set;}
    public boolean blnStep4 {get;set;}
    public string strFirst {get;set;}
    public string strSecond {get;set;}
    public string strThird {get;set;}
    public string strFourth {get;set;}
    public string strCaseID;

    public TitleDeedProcess(){
        blnStep1 = true;
        blnStep2 = false;
        blnStep3 = false;
        blnStep4 = false;
        strFirst = 'current';
        strSecond = '';
        strThird = '';
        strFourth = '';
        init();
    }//End Constructor

    public void init(){
        lstUnits = new list<SelectOption>();
        resHandedOver = new list<SelectOption>();
        lstModes = new list<SelectOption>();
        strOverdues = 'XX';
        strPenalties = 'XX';
        strAdminFee = 'XX';
        strOtherDues = 'XX';
        strTotalAmt = 'XX';

        lstModes.add(new selectOption('Courier', 'Courier'));
        lstModes.add(new selectOption('Collection by hand', 'Collection by hand'));
        lstUnits.add(new selectOption('--None--', '--None--'));
        for(Booking_Unit__c objBU : [Select Id,
                                            Name,
                                            Booking__c 
                                     from Booking_Unit__c
                                    where Booking__r.Account__c = '0017E00000cWKII']){
            lstUnits.add(new selectOption(objBU.Id, objBU.Name));
        }//End for
        resHandedOver.add(new SelectOption('Yes','Yes'));
        resHandedOver.add(new SelectOption('No','No'));
    }//End init

    public Attachment attachment {
        get {
            if (attachment == null)
            attachment = new Attachment();
            return attachment;
            }
        set;
    }//end attachment

    public Attachment attachment1 {
        get {
            if (attachment1 == null)
            attachment1 = new Attachment();
            return attachment1;
            }
        set;
    }//end attachment1

    public void nextInstruction(){
        blnStep1 = true;
        blnStep2 = true;
        blnStep3 = false;
        blnStep4 = false;
        strFirst = 'is-done';
        strSecond = 'current';
        strThird = '';
        strFourth = '';
    }//end nextInstruction

    public Pagereference autoPopulateBUDetails(){
        //resHandedOver = new list<SelectOption>();
        system.debug('=strSelectedUnit=='+strSelectedUnit);
        for(Booking_Unit__c objBU : [select ID,
                                            Handover_Complete__c
                                       from Booking_Unit__c
                                      where ID =: strSelectedUnit]){
              if(objBU.Handover_Complete__c == true)
               strHandedOver = 'Yes';
              else
              strHandedOver = 'No';
              
            strOverdues = '10';
            strPenalties = '20';
            strAdminFee = '200';
            strOtherDues = '30';
            strTotalAmt = '260';
         }//End for
         return null;
    }//end autoPopulateBUDetails

    public void SaveAndContinueDR(){
        list<Booking_Unit__c> lstBU = new list<Booking_Unit__c>();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Deed').getRecordTypeId();
       if(strSelectedUnit!= '--None--'){
        Case objCase = new Case();
        objCase.Booking_Unit__c = strSelectedUnit;
        objCase.RecordTypeId = caseRecordTypeId;
        objCase.Priority = 'Medium';
        objCase.Origin = 'Web';
        objCase.Description = 'Title Deed SR';
        objCase.Status = 'Draft Request';
        objCase.Mode_of_Collection__c = strSelectedMode;
        objCase.Overdues_Dues_Towards_Service_Charges__c = strOverdues;
        objCase.Penalties_LP_Fee_on_Service_Charges__c = strPenalties;
        objCase.Admin_Fee_For_Title_Deed__c = strAdminFee;
        objCase.Other_Dues__c = strOtherDues;
        objCase.Total_Amount_To_Be_Paid__c = strTotalAmt;
        objCase.Handed_Over__c = strHandedOver == 'Yes'? true : false;
        insert objCase;
        strCaseID = objCase.ID;
       }//end if
       if(strSelectedUnit != '--None--'){
        for(Booking_Unit__c objBU : [select ID,
                                            Handover_Complete__c
                                       from Booking_Unit__c
                                      where ID =: strSelectedUnit]){
                     if(strHandedOver == 'Yes')
                      objBU.Handover_Complete__c = true;
                     else
                      objBU.Handover_Complete__c = false;
                 lstBU.add(objBU);
          }//End for 
       }//End if
       if(lstBU!=null && lstBU.size()>0)
        update lstBU;
        blnStep1 = true;
        blnStep2 = true;
        blnStep3 = true;
        blnStep4 = false;
        strFirst = 'is-done';
        strSecond = 'is-done';
        strThird = 'current';
        strFourth = '';
     }//end SaveAndContinueDR

    
    public void uploadDocuments(){
        list<Attachment> lstAttachment = new list<Attachment>();

            SR_Attachments__c objSRAtt = new SR_Attachments__c ();
            objSRAtt.Name = attachment.name; 
            objSRAtt.Case__c = strCaseID; 
            objSRAtt.type__c = 'PDF';
            insert objSRAtt;

            SR_Attachments__c objSRAtt1 = new SR_Attachments__c ();
            objSRAtt1.Name = attachment1.name; 
            objSRAtt1.Case__c = strCaseID; 
            objSRAtt1.type__c = 'PDF';
            insert objSRAtt1;

           Attachment objAttachmnt = new Attachment(parentId = objSRAtt.ID, 
                                                         name= attachment.name, 
                                                         body = attachment.body,
                                                         ContentType='PDF');
           insert objAttachmnt;

           Attachment objAttachmnt1 = new Attachment(parentId = objSRAtt.ID, 
                                                         name= attachment1.name, 
                                                         body = attachment1.body,
                                                         ContentType='PDF');
           insert objAttachmnt1;
        attachment.body = null;
        attachment1.body = null;
        Case objCase = [select ID, CaseNumber from Case where ID =: strCaseID];
        strCaseNumber = objCase.CaseNumber;
        blnStep1 = true;
        blnStep2 = true;
        blnStep3 = true;
        blnStep4 = true;
        strFirst = 'is-done';
        strSecond = 'is-done';
        strThird = 'is-done';
        strFourth = 'current';
     }//end uploadDocuments

}//End TitleDeedProcess