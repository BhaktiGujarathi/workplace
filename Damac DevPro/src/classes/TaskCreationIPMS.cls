/***********************************************************************************************************************************
* Name: TaskCreationIPMS*
* Description        : Controller class for Creating New Task for CRM Process.          *
* Created Date       : 02/07/2017*
* Created By         : Naresh          *
* ---------------------------------------------------------------------------------------------------------------------*
* VERSION     AUTHORDATE COMMENTS          *
* 1.0         Naresh       02/07/2017      Initial Draft.          *
* 
  *
**************************************************************************************************************************************/
public class TaskCreationIPMS{
    
    
    public Static List<Task> TaskList =  new List<Task>();
    public  Static final String Endurl = System.Label.IPMSTaskUpdate;
    public  Static CRM_SR_Matrix__c CrmMatrix =  new CRM_SR_Matrix__c();
    public  Static Task task {get ; set ;} 
    public  Static Integer TaskCount ; 
   
  
    @future(Callout=true)
    public static void TaskCreationIPMSUpdate(Set<Id> NewTask){
      System.debug('CrmMatrix--CrmMatrix--CrmMatrix--CrmMatrix------------ '+task);  
      
      
        try{
        Task TaskList = [select id,WhatId ,OwnerId , Owner.Name ,Subject,Description ,Priority from Task Where Subject = 'Verify Payment Received' Order By CreatedDate DESC limit 1]; 
        
        
        if(TaskList != null){
        Service_Request__c CaseList  = [select id, SR_Type__c ,Address__c ,Address_2__c ,Address_3__c ,Country_Code__c ,City_Arabic__c ,Country_Arabic__c , Address_4__c ,Contact_Email__c, Name ,Account__c , Account__r.Name  from Service_Request__c Where Id =: TaskList.WhatId  limit 1];
        
        System.debug('Inserted Task-----------------------   '+TaskList);
         String Body = '';
        
     Body += '<?xml version="1.0" encoding="UTF-8"?>';
        Body += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xxdc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_rep_gen_ws/" xmlns:gen="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_rep_gen_ws/generate_report/">';
        Body += '<soapenv:Header>';
        Body += '      <xxdc:SOAHeader>';
        Body += '         <xxdc:RespApplication>ONT</xxdc:RespApplication>';
        Body += '         <xxdc:SecurityGroup>standard</xxdc:SecurityGroup>';
        Body += '         <xxdc:NLSLanguage>american</xxdc:NLSLanguage>';
        Body += '      </xxdc:SOAHeader>';
        Body += '      <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
        Body += '     <wsse:UsernameToken>';
        Body += '      <wsse:Username>oracle_user</wsse:Username>';
        Body += '      <wsse:Password>crp1user</wsse:Password>';
        Body += '      </wsse:UsernameToken>';
        Body += '      </wsse:Security>';
        Body += '   </soapenv:Header>';
        Body += '   <soapenv:Body>';
        Body += '      <gen:InputParameters>';
        Body += '  <gen:SR_OPTION>?</gen:SR_OPTION>';
        Body += ' <gen:SIEBEL_SR_NUMBER>'+CaseList.Name +'</gen:SIEBEL_SR_NUMBER>';  
        Body += ' <gen:SIEBEL_SR_TYPE>'+CaseList.SR_Type__c +'</gen:SIEBEL_SR_TYPE> ';  
        Body += ' <gen:SIEBEL_TASK_ID>+'+TaskList.Id+'</gen:SIEBEL_TASK_ID> ';
        Body += ' <gen:SIEBEL_TASK_NAME>'+TaskList.Subject+'</gen:SIEBEL_TASK_NAME> ';
        Body += ' <gen:SIEBEL_TASK_OWNER>'+TaskList.Owner.Name+'</gen:SIEBEL_TASK_OWNER> ';
        Body += ' <gen:CUSTOMER_PARTY_ID>?</gen:CUSTOMER_PARTY_ID>';
        Body += ' <gen:CUSTOMER_NAME>?</gen:CUSTOMER_NAME> ';
        Body += ' <gen:CUST_ACCT_ID>'+CaseList.Account__c+'</gen:CUST_ACCT_ID>';
        Body += ' <gen:TASK_OWNER_ID>'+TaskList.OwnerId+'</gen:TASK_OWNER_ID> ';
        Body += ' <gen:DEPARTMENT>?</gen:DEPARTMENT> ';
        Body += ' <gen:ASSIGN_USER>'+TaskList.Owner.Name+'</gen:ASSIGN_USER> ';
        Body += ' <gen:ASSIGN_USER_ID></gen:ASSIGN_USER_ID> ';
        Body += ' <gen:ATTRIBUTE1>'+TaskList.OwnerId+'</gen:ATTRIBUTE1>';
        Body += ' <gen:ATTRIBUTE2>?</gen:ATTRIBUTE2>';
        Body += ' <gen:ATTRIBUTE3>?</gen:ATTRIBUTE3>';
        Body += ' <gen:ATTRIBUTE4>?</gen:ATTRIBUTE4>';
        Body += ' <gen:ATTRIBUTE5>?</gen:ATTRIBUTE5>';
        Body += ' <gen:ATTRIBUTE6>?</gen:ATTRIBUTE6>';
        Body += ' <gen:ATTRIBUTE7>?</gen:ATTRIBUTE7>';
        Body += ' <gen:ATTRIBUTE8>?</gen:ATTRIBUTE8>';
        Body += ' <gen:ATTRIBUTE9>?</gen:ATTRIBUTE9>';
        Body += ' <gen:ATTRIBUTE10>?</gen:ATTRIBUTE10>';
        Body += ' <gen:ATTRIBUTE11>?</gen:ATTRIBUTE11>';
        Body += ' <gen:ATTRIBUTE12>?</gen:ATTRIBUTE12>';
        Body += ' <gen:ATTRIBUTE13>?</gen:ATTRIBUTE13>';
        Body += ' <gen:ATTRIBUTE14>?</gen:ATTRIBUTE14>';
        Body += ' <gen:ATTRIBUTE15>?</gen:ATTRIBUTE15>';
        Body += ' <gen:ATTRIBUTE16>?</gen:ATTRIBUTE16>';
        Body += ' <gen:ATTRIBUTE17>?</gen:ATTRIBUTE17>';
        Body += ' <gen:ATTRIBUTE18>?</gen:ATTRIBUTE18>';
        Body += ' <gen:ATTRIBUTE19>?</gen:ATTRIBUTE19>';
        Body += ' <gen:ATTRIBUTE20>?</gen:ATTRIBUTE20>';
        Body += ' <gen:CUSTOMER_NUMBER>?</gen:CUSTOMER_NUMBER>';
        Body += ' <gen:INITIAL_AMOUNT>?</gen:INITIAL_AMOUNT>';
        Body += ' <gen:CREDIT_AMOUNT>?</gen:CREDIT_AMOUNT>';
        Body += ' <gen:DISPATCH_TO_CUSTOMER>?</gen:DISPATCH_TO_CUSTOMER>';
        Body += ' <gen:PDC_CHEQUES>?</gen:PDC_CHEQUES>';
        Body += ' <gen:PERCENTAGE_OF_AREA_VERIATION>?</gen:PERCENTAGE_OF_AREA_VERIATION>';
        Body += ' <gen:NEW_BUYER_NUMBER>?</gen:NEW_BUYER_NUMBER>';
        Body += ' <gen:NEW_BUYER_NAME>?</gen:NEW_BUYER_NAME>';
        Body += ' <gen:JOINT_BUYER_NUMBER>?</gen:JOINT_BUYER_NUMBER>';
        Body += ' <gen:JOINT_BUYER_NAME>?</gen:JOINT_BUYER_NAME>';
        Body += ' <gen:AGREEMENT_DATE>?</gen:AGREEMENT_DATE>';
        Body += ' <gen:PASSPORT_NUMBER>?</gen:PASSPORT_NUMBER>';
        Body += ' <gen:MEMO_TYPE>?</gen:MEMO_TYPE>';
        Body += ' <gen:ADDITIONAL_COMMENT>?</gen:ADDITIONAL_COMMENT>';
        Body += ' <gen:NEW_BUYER_PARTY_ID>?</gen:NEW_BUYER_PARTY_ID>';
        Body += ' <gen:ORG_ID>?</gen:ORG_ID>';
        Body += ' <gen:NEW_JOINT_BUYER_PARTY_ID>?</gen:NEW_JOINT_BUYER_PARTY_ID>';
        Body += ' <gen:ADDRESS1></gen:ADDRESS1>';
        Body += ' <gen:ADDRESS2>?</gen:ADDRESS2>';
        Body += ' <gen:ADDRESS3>?</gen:ADDRESS3>';
        Body += ' <gen:ADDRESS4>?</gen:ADDRESS4>';
        Body += ' <gen:CITY>?</gen:CITY>';
        Body += ' <gen:STATE>?</gen:STATE>';
        Body += ' <gen:COUNTRY>?</gen:COUNTRY>';
        Body += ' <gen:POSTAL_CODE>?</gen:POSTAL_CODE>';
        Body += ' <gen:PHONE_COUNTRY_CODE>?</gen:PHONE_COUNTRY_CODE>';
        Body += ' <gen:PHONE_AREA_CODE>?</gen:PHONE_AREA_CODE>';
        Body += ' <gen:PHONE_NUMBER>?</gen:PHONE_NUMBER>';
        Body += ' <gen:MOBILE_COUNTRY_CODE>?</gen:MOBILE_COUNTRY_CODE>';
        Body += ' <gen:MOBILE_AREA_CODE>?</gen:MOBILE_AREA_CODE>';
        Body += ' <gen:MOBILE_NUMBER>?</gen:MOBILE_NUMBER>';
        Body += ' <gen:FAX_COUNTRY_CODE>?</gen:FAX_COUNTRY_CODE>';
        Body += ' <gen:FAX_AREA_CODE>?</gen:FAX_AREA_CODE>';
        Body += ' <gen:FAX_NUMBER>?</gen:FAX_NUMBER>';
        Body += ' <gen:EMAIL_ADDRESS>'+CaseList.Contact_Email__c+'</gen:EMAIL_ADDRESS>';
        Body += ' <gen:TERMINATION_STATUS>?</gen:TERMINATION_STATUS>';
        Body += ' <gen:SPA_STATUS>?</gen:SPA_STATUS>';
        Body += ' <gen:PASSPORT_ISSUE_DT>?</gen:PASSPORT_ISSUE_DT>';
        Body += ' <gen:RENT_AMOUNT_IN_AED>?</gen:RENT_AMOUNT_IN_AED>';
        Body += ' <gen:LEASE_COMMENCEMENT_DATE>?</gen:LEASE_COMMENCEMENT_DATE>';
        Body += ' <gen:LEASE_END_DATE>?</gen:LEASE_END_DATE>';
        Body += ' <gen:HANDOVER_MILESTONE>?</gen:HANDOVER_MILESTONE>';
        Body += ' <gen:PENALTIES_AS_OF_DATE>?</gen:PENALTIES_AS_OF_DATE>';
        Body += ' <gen:REGISTRATION_FEES_PAID>?</gen:REGISTRATION_FEES_PAID>';
        Body += ' <gen:TOTAL_PENALTY_CALCULATED>?</gen:TOTAL_PENALTY_CALCULATED>';
        Body += ' <gen:ENALTY_AS_OF_DATE>?</gen:ENALTY_AS_OF_DATE>';
        Body += ' <gen:AMOUNT_TO_BE_WAIVED>?</gen:AMOUNT_TO_BE_WAIVED>';
        Body += ' <gen:PENALTY_CATEGORY>?</gen:PENALTY_CATEGORY>';
        Body += ' <gen:NO_PARKINGS_REQUIRED>?</gen:NO_PARKINGS_REQUIRED>';
        Body += ' <gen:PARKING_PRICE>?</gen:PARKING_PRICE>';
        Body += ' <gen:PARKING_PRICE_POLICY>?</gen:PARKING_PRICE_POLICY>';
        Body += ' <gen:DEPT_NAME_AFT_CRM_APP>?</gen:DEPT_NAME_AFT_CRM_APP>';
        Body += ' <gen:NEW_PASSPORT_NO>?</gen:NEW_PASSPORT_NO>';
        Body += ' <gen:NEW_PASSPORT_ISSUE_DATE>?</gen:NEW_PASSPORT_ISSUE_DATE>';
        Body += ' <gen:RESPONSIBLE_DEPARTMENT>?</gen:RESPONSIBLE_DEPARTMENT>';
        Body += ' <gen:ROOT_CAUSE_OF_PROBLEM>?</gen:ROOT_CAUSE_OF_PROBLEM>';
        Body += ' <gen:PROVINCE>?</gen:PROVINCE>';
        Body += ' <gen:COUNTY>?</gen:COUNTY>';
        Body += ' <gen:NOTES>?</gen:NOTES>';
        Body += ' <gen:X_XX_SI2R12_SR_INT_ATT_TAB>';
        Body += ' </gen:X_XX_SI2R12_SR_INT_ATT_TAB>';
        Body += ' </gen:InputParameters>';
        Body += '</soapenv:Body>';
        Body += '</soapenv:Envelope>';


    
        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        
        System.debug('IPMS Requested Body--------------- '+Body);
        Body = Body.replaceAll('null', '');
        Body = Body.trim();
      
        req.setbody(Body);
        req.setEndpoint(Endurl);
        req.setHeader('Content-Type','text/xml');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        
        HTTPResponse res = http.send(req);
        
        System.debug('IPMS Response-------------------- '+res);
      
         
     }
    }
    
       catch(Exception Ex){
System.debug('Error @Line Number------------ '+Ex.getLineNumber());
System.debug('ErrorgetMessage Number------------ '+Ex.getMessage());
 Log__c logs=new  Log__c();
 logs.Type__c='IPMS Webservice Fails for Task Update';
 logs.Description__c = 'Class -TaskCreationIPMS @Line'+Ex.getLineNumber() +' '+'Error Message : '+Ex.getMessage();
 Insert logs;
        }
    }
    
      
}