@istest
public class CTIRestServiceTest{


    static testmethod void CTIRestService1_Methods(){
    
        Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        
        Virtual_Number__c v = new Virtual_Number__c();
        v.Active__c = true;
        v.name = '123';
        v.End_Date__c = System.today().addDays(60);
        v.Start_Date__c = System.today().addDays(-60);
        insert v;
        
        Campaign__c camp = new Campaign__c();
        camp.RecordTypeId = RSRecordTypeId;
        camp.Campaign_Name__c='Test Campaign';
        camp.start_date__c = System.today();
        camp.end_date__c = System.Today().addDays(30);
        camp.Marketing_start_date__c = System.today();
        camp.Marketing_end_date__c = System.Today().addDays(30);
        camp.Language__c = 'English';
        insert camp;
    
        JO_Campaign_Virtual_Number__c vn = new JO_Campaign_Virtual_Number__c();
        vn.Related_Campaign__c = camp.id;
        vn.Related_Virtual_Number__c = v.id;
        insert vn;
        
        
        User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc2@damactest.com');
        pcUser.Extension = '0099';
        pcUser.Languages_Known__c = 'English';
        insert pcUser ;
        
        Assigned_PC__c assignPC = InitialiseTestData.assignPCToCampaign(pcUser.Id,camp.Id);
        assignPC.Start_Date__c = System.today().addDays(-60);
        assignPC.end_date__c = System.today().addDays(60);
        insert assignPC ;
        
        Inquiry__c newInquiry = new Inquiry__c();
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,127);
        newInquiry.Campaign__c = camp.Id ;  
        insert newInquiry ;
    
        //CTIRestService1 s1 = new CTIRestService1();
        //s1.ResponseHandler resp = new s1.ResponseHandler();
        
        
            CTIRestService1.RequestHandler reqcls = new CTIRestService1.RequestHandler();
            reqcls.callingNumber = '123'; 
            reqcls.calledNumber  = '123';
            reqcls.pcExt.add('0099');
        test.starttest();
            RestRequest req = new RestRequest();
            req.httpMethod = 'POST';
            req.requestUri = '...';
            req.requestBody = Blob.valueOf(JSON.serializePretty(reqcls));
            RestContext.request = req;
            RestContext.response = new RestResponse();
            CTIRestService1.getCallingpcList();    
        test.stoptest();
    }
    
    
    
    static testmethod void CTIRestService2_Methods(){
        
        Id accRecordTypeId   = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id RSRecordTypeId = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get('Roadshows').getRecordTypeId();
        
        User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc2@damactest.com');
        pcUser.Extension = '0099';
        pcUser.Languages_Known__c = 'English';
        insert pcUser ;
        
        Account acc = new Account();
        acc.firstname = 'Person Account';
        acc.LastName = 'Acc';
        acc.RecordTypeId = accRecordTypeId ;
        acc.OwnerId = pcUser.id;
        acc.PersonMobilePhone= '123';
        insert acc ;
        
        Campaign__c camp = new Campaign__c();
        camp.RecordTypeId = RSRecordTypeId;
        camp.Campaign_Name__c='Test Campaign';
        camp.start_date__c = System.today();
        camp.end_date__c = System.Today().addDays(30);
        camp.Marketing_start_date__c = System.today();
        camp.Marketing_end_date__c = System.Today().addDays(30);
        camp.Language__c = 'English';
        insert camp;
        
        Inquiry__c newInquiry = new Inquiry__c();
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,127);
        newInquiry.Campaign__c = camp.Id ;  
        newInquiry.First_name__c = 'Test';
        newInquiry.Last_name__c = 'Lead';
        newInquiry.inquiry_source__c = 'Call Center';
        newInquiry.email__c = 'test@test.com';
        newInquiry.ownerid = pcUser.id;
        newInquiry.Inquiry_Status__c = DAMAC_Constants.INQUIRY_NEW_STATUS;
        newInquiry.Mobile_Phone__c = '123';
        insert newInquiry ;
        
        CTIRestService2.RequestHandler reqcls = new CTIRestService2.RequestHandler();
        CTIRestService2.ResponseDataWrapper respcls = new CTIRestService2.ResponseDataWrapper();       
        
        reqcls.callingNumber = '123'; 
        reqcls.calledNumber  = '123';
        reqcls.pcExt = '0099';
        test.starttest();
            RestRequest req = new RestRequest();
            req.httpMethod = 'POST';
            req.requestUri = '...';
            req.requestBody = Blob.valueOf(JSON.serializePretty(reqcls));
            RestContext.request = req;
            RestContext.response = new RestResponse();
            CTIRestService2.getObjectDetail();
            delete newInquiry;
            CTIRestService2.getObjectDetail();
        test.stoptest();
     }
     
     static testmethod void CTIRestService2_Negative(){
        
        Id accRecordTypeId   = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        
        User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc2@damactest.com');
        pcUser.Extension = '02099';
        pcUser.Languages_Known__c = 'English';
        insert pcUser ;
        
        Account acc = new Account();
        acc.firstname = 'Person Account';
        acc.LastName = 'Acc';
        acc.RecordTypeId = accRecordTypeId ;
        acc.OwnerId = pcUser.id;
        acc.PersonMobilePhone= '123';
        insert acc ;
        
        CTIRestService2.RequestHandler reqcls = new CTIRestService2.RequestHandler();
        CTIRestService2.ResponseDataWrapper respcls = new CTIRestService2.ResponseDataWrapper();

        reqcls.callingNumber = '123'; 
        reqcls.calledNumber  = '123';
        reqcls.pcExt = '0099';
        test.starttest();
            RestRequest req = new RestRequest();
            req.httpMethod = 'POST';
            req.requestUri = '...';
            req.requestBody = Blob.valueOf(JSON.serializePretty(reqcls));
            RestContext.request = req;
            RestContext.response = new RestResponse();
            CTIRestService2.getObjectDetail();
        test.stoptest();
     }

}