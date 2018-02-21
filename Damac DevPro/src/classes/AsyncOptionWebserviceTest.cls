/*********************************************************************************
* Name               : AsyncOptionWebserviceTest
* Description        :Test class for wrpper class AsyncOptionWebservice.
*----------------------------------------------------------------------------------
* VERSION     AUTHOR            DATE          COMMENTS 
  1.0         Pratiksha(Accely) 11-07-2017
  **********************************************************************************/


@isTest
private class AsyncOptionWebserviceTest {
    static testMethod void myUnitTest() {
    	test.startTest();
        AsyncOptionWebservice objAsyncOption = new AsyncOptionWebservice();
        string body = '';
	    Date d = Date.newinstance(25,12,2021);
	    
	    Location__c loc=new Location__c();
	    loc.Location_ID__c='123';
	    insert loc;
	    Inventory__c inv = new Inventory__c();
	    inv.Unit_Location__c=loc.id;
	    insert inv;
	    
	    NSIBPM__Service_Request__c SR = new NSIBPM__Service_Request__c();
	    SR.Delivery_mode__c='Email';
	    SR.Deal_ID__c='1001';
	    insert SR;
	    
	    List<id> SRids = new List<id>();
	    SRids.add(SR.id);
	    NSIBPM__SR_Doc__c srdoc= new NSIBPM__SR_Doc__c();
	    srdoc.NSIBPM__Service_Request__c=SR.id;
	    insert srdoc;
	    
	    Booking__c bk= new Booking__c();
	    bk.Deal_SR__c=SR.id;
	    bk.Booking_channel__c='Office';
	    insert bk;
	    
	    Buyer__c PB= new Buyer__c();
	    PB.Primary_Buyer__c=true;
	    PB.Buyer_Type__c='Individual';
	    PB.Booking__c=bk.id;
	    PB.Phone_Country_Code__c='India: 0091';
	    PB.Passport_Expiry_Date__c='25/03/2017';
	    PB.CR_Registration_Expiry_Date__c='25/12/2017';
	    PB.City__c='Dubai';
	    PB.Country__c='United Arab Emirates';
	    PB.Address_Line_1__c='street1';
	    PB.Address_Changed__c=true;
	    PB.Date_of_Birth__c='25/12/1990';
	    PB.Email__c='test@test.com';
	    PB.First_Name__c='Buyer';
	    PB.Last_Name__c='test';
	    PB.Nationality__c='Indian'; 
	    PB.Passport_Number__c='PP123'; 
	    PB.Phone__c='53532255';
	    PB.Place_of_Issue__c='Delhi'; 
	    PB.Title__c='Mr.';
	    insert PB;
	    
	    Buyer__c JB= new Buyer__c();
	    JB.Primary_Buyer__c=false;
	    JB.Buyer_type__c='Individual';
	    JB.Booking__c=bk.id;
	    JB.Passport_Expiry_Date__c='25/11/2017';
	    JB.CR_Registration_Expiry_Date__c='25/06/2017';
	    jb.status__c='New';
	    jb.Date_of_Birth__c='25/12/1990';
	    jb.City__c='Dubai';
	    jb.Country__c='United Arab Emirates';
	    jb.Address_Line_1__c='street1';
	    jb.Email__c='test@test.com';
	    jb.First_Name__c='Buyer';
	    jb.Last_Name__c='test';
	    jb.Nationality__c='Indian'; 
	    jb.Passport_Number__c='PP123'; 
	    jb.Phone__c='53532255';
	    jb.Phone_Country_Code__c='India: 0091';
	    jb.Place_of_Issue__c='Delhi'; 
	    jb.Title__c='Mr.';
	    insert JB;
	
	    
        Booking_Unit__c objBook = new Booking_Unit__c();
        objBook.Inventory__c=inv.id;
        objBook.Booking__c=bk.id;
        objBook.Registration_ID__c = '1234';
        insert objBook;
        List<Booking_Unit__C> listBookingunit = new List<Booking_Unit__C>();
        listBookingunit.add(objBook);
        option__c objopt = new option__c();
        objopt.Booking_Unit__c = objBook.ID;
        objopt.PromotionName__c ='test';
        objopt.CampaignName__c ='test';
        objopt.OptionsName__c ='test';
        objopt.SchemeName__c ='test';
        objopt.Net_Price__c = 123;
        List<option__c> listobjopt = new List<option__c>();
        listobjopt.add(objopt);
        
        Database.upsertResult result = Database.upsert(objopt, false);
        map<ID, option__c> mapOptionNew = new map<ID, option__c>();
        map<ID, option__c> mapOptionOld = new map<ID, option__c>();
        mapOptionOld.put(objopt.ID, objopt);
        objopt.Net_Price__c = 124;        
        update objopt;
        mapOptionNew.put(objopt.ID, objopt);
        System.debug('...objopt...'+objopt);
        System.debug('...objopt...'+objopt);
        set<ID> setID = new set<ID>();
        setID.add(objopt.ID);
        
        //AsyncOptionWebservice.parseSOAResponse('test');
        Body   +='<?xml version="1.0" encoding="UTF-8"?> ';
Body   +='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xxdc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/" xmlns:proc="http://xmlns.oracle.com/apps/ont/soaprovider/plsql/xxdc_process_service_ws/process/"> ';
Body   +='  <soapenv:Header> ';
Body   +='      <xxdc:SOAHeader> ';
Body   +='         <xxdc:Responsibility>ONT_ICP_SUPER_USER</xxdc:Responsibility> ';
Body   +='         <xxdc:RespApplication>ONT</xxdc:RespApplication> ';
Body   +='         <xxdc:SecurityGroup>standard</xxdc:SecurityGroup> ';
Body   +='         <xxdc:NLSLanguage>american</xxdc:NLSLanguage> ';
Body   +='         <xxdc:Org_Id/> ';
Body   +='      </xxdc:SOAHeader> ';
Body   +='      <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"> ';
Body   +='         <wsse:UsernameToken> ';
Body   +='            <wsse:Username>oracle_user</wsse:Username> ';
Body   +='            <wsse:Password>crp1user</wsse:Password> ';
Body   +='         </wsse:UsernameToken> ';
Body   +='      </wsse:Security> ';
Body   +='   </soapenv:Header> ';
Body   +='   <soapenv:Body> ';
Body   +='      <proc:InputParameters> ';
Body   +='         <proc:P_REQUEST_NUMBER>122</proc:P_REQUEST_NUMBER> ';
Body   +='         <proc:P_SOURCE_SYSTEM>SFDC</proc:P_SOURCE_SYSTEM> ';
Body   +='         <proc:P_REQUEST_NAME>UPDATE_REGISTRATION</proc:P_REQUEST_NAME> ';
Body   +='         <proc:P_REQUEST_MESSAGE> ';
Body   +='            <proc:P_REQUEST_MESSAGE_ITEM> ';
Body   +='               <proc:PARAM_ID>1211</proc:PARAM_ID> ';
Body   +=' <proc:ATTRIBUTE1>'+listBookingunit[0].Registration_ID__c+'</proc:ATTRIBUTE1> ';
Body   +=' <proc:ATTRIBUTE2>UPDATE_PR_SC_OP_CM_RP</proc:ATTRIBUTE2> ';
Body   +=' <proc:ATTRIBUTE3>'+listobjopt[0].PromotionName__c+'</proc:ATTRIBUTE3> ';
Body   +=' <proc:ATTRIBUTE4>'+listobjopt[0].CampaignName__c+'</proc:ATTRIBUTE4> ';
Body   +=' <proc:ATTRIBUTE5>'+listobjopt[0].OptionsName__c+'</proc:ATTRIBUTE5> ';
Body   +=' <proc:ATTRIBUTE6>'+listobjopt[0].SchemeName__c+'</proc:ATTRIBUTE6> ';
Body   +=' <proc:ATTRIBUTE7>'+listobjopt[0].Net_Price__c +'</proc:ATTRIBUTE7> ';
Body   +='            </proc:P_REQUEST_MESSAGE_ITEM> ';
Body   +='         </proc:P_REQUEST_MESSAGE> ';
Body   +='      </proc:InputParameters> ';
Body   +='   </soapenv:Body> ';
Body   +='</soapenv:Envelope> ';
        AsyncOptionWebservice.parseSOAResponse(body);
        AsyncOptionWebservice.prepareOptionUpdate(setID);
        test.stopTest();
    }
}