@istest
public class InquiryServiceTest{



    static testmethod void InquiryService_methods(){
    
        User pcUser = InitialiseTestData.getPropertyConsultantUsers('pc2@damactest.com');
        pcUser.Extension = '0099';
        pcUser.Languages_Known__c = 'English';        
        insert pcUser ;
        
        User pcUser1 = InitialiseTestData.getPropertyConsultantUsers('pc3@damactest.com');
        pcUser1.Extension = '0098';
        pcUser1.Languages_Known__c = 'English';        
        insert pcUser1 ;
        
        
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
        
        
        Assigned_PC__c assignPC = InitialiseTestData.assignPCToCampaign(pcUser.Id,camp.Id);
        assignPC.Start_Date__c = System.today().addDays(-60);
        assignPC.end_date__c = System.today().addDays(60);
        insert assignPC ;
    
        JO_Campaign_Virtual_Number__c vn = new JO_Campaign_Virtual_Number__c();
        vn.Related_Campaign__c = camp.id;
        vn.Related_Virtual_Number__c = v.id;
        insert vn;
        
        //
        Account a = new Account();
        a.Name = 'Test Account';        
        insert a;
        
        Id PerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a1 = new Account();
        a1.FirstName = 'Test Account';
        a1.LastName = 'Acc';
        a1.Phone_Key__c = 'ABC';
        a1.Email_Key__c = 'TEST@TEST.COM';
        a1.recordtypeid = PerRecordTypeId;
        insert a1;
        
        NSIBPM__SR_Template__c SRTemplate = new NSIBPM__SR_Template__c();
        srtemplate.NSIBPM__SR_RecordType_API_Name__c = 'Deal';
        insert SRTemplate;
        
        Id RecType1 = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
        NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
        sr.NSIBPM__Customer__c = a.id;
        sr.RecordTypeId = RecType1;
        sr.Agency__c = a.id;
        sr.NSIBPM__SR_Template__c = SRTemplate.id;
        sr.Agency_Type__c = 'Corporate';        
        sr.Registration_Date__c = system.today();
        sr.doc_ok__c = true;
        sr.DP_ok__c = true;
        insert sr;
        
        deal_team__c dt = new deal_team__c();
        dt.Associated_PC__c = pcuser.id;
        dt.Associated_Deal__c  = sr.id;
        insert dt;
        
        
        //        
        Inquiry__c newInquiry = new Inquiry__c();
        newInquiry = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,127);
        newInquiry.Campaign__c = camp.Id ;  
        newInquiry.First_name__c = 'Test';        
        newInquiry.Last_name__c = 'Lead';
        newInquiry.inquiry_source__c = 'Call Center';
        newInquiry.email__c = 'TEST@TEST.COM';
        newInquiry.Phone_Unique_key__c = 'ABC';
        newInquiry.Email_Unique_key__c = 'TEST@TEST.COM';
        insert newInquiry ;
        
        Inquiry__c newInquiry1 = new Inquiry__c();
        newInquiry1 = InitialiseTestData.getInquiryDetails(DAMAC_Constants.INQUIRY_RT,127);
        newInquiry1.Campaign__c = camp.Id ;  
        newInquiry1.First_name__c = 'Test';        
        newInquiry1.Last_name__c = 'Lead';
        newInquiry1.inquiry_source__c = 'Call Center';
        newInquiry1.email__c = 'TEST@TEST.COM';
        newInquiry1.Phone_Unique_key__c = 'ABC';
        newInquiry1.Email_Unique_key__c = 'TEST@TEST.COM';
        insert newInquiry1 ;
        
        
        Property__c prop = new Property__c();
        prop.Active_Property__c = true;
        prop.Property_ID__c = 123;
        insert prop;
        
        
        Assigned_Property_User__c aProp = new Assigned_Property_User__c();
        aProp.Assigned_user__c = pcuser.id;
        aProp.Associated_Property__c = prop.id;
        insert aProp;        
        
        //        
        InquiryService.getUserDetailsByProfile(pcUser.profileid);        
        
        //        
        set<id> campids = new set<id>();
        campids.add(camp.Id);
        InquiryService cls = new InquiryService();
        cls.getAllCampaignUser(campids);
        
        map<id,list<id>> parentSortedEligibleUsersMap = new map<id,list<id>>();
        list<id> subList = new list<id>();
        sublist.add(pcUser.id);
        parentSortedEligibleUsersMap.put(pcuser.id,sublist);
        cls.getPcPerformanceMap(parentSortedEligibleUsersMap);
        
        //
        Map<Id, Integer> pcWithMeetingCount = new Map<Id, Integer>();
        pcWithMeetingCount.put(pcuser.id,10);
        cls.getPcMeetingBandMap(10,pcWithMeetingCount);
        
        //
        cls.upgradeScore('Hot');
        cls.upgradeScore('Cold');
        cls.upgradeScore('Warm');
        
        //        
        cls.downgradeScore('Hot');
        cls.downgradeScore('Cold');
        cls.downgradeScore('Warm');
        
        //        
        newInquiry.ownerid = pcUser1.id;
        update newInquiry;
        set<id> inqId = new set<id>();
        inqId.add(newInquiry.ownerid);
        cls.getNurturingInquiryDetails(inqId); // to cov
        
        //
        set<string> phkey = new set<string>();
        set<string> emkey = new set<string>();
        phKey.add(a1.Phone_Key__c );
        emkey.add(a1.Email_Key__c );
        cls.getMatchingAccount(phKey,emKey);
                
        //
        cls.getMatchingInquiry(phKey,emKey,campids);
        //
        list<inquiry__c> elgInq = new list<inquiry__c>();
        elgInq.add(newInquiry);
        elgInq.add(newInquiry1);
        cls.getMatchingInquiryRecord(newInquiry,elgInq);
        
        //
        set<id> aProps = new set<id>();
        aProps.add(prop.id);
        cls.getAllPropertyUser(aProps);
        
        //
        set<string> phkey1 = new set<string>();
        set<string> emkey1 = new set<string>();
        phKey1.add(a1.Phone_Key__c );
        emkey1.add(a1.Email_Key__c );
        cls.possibleMatchesOfInquiry(emkey1,phKey1);
        
        InquiryService.UserLoadWrapper compCls;
        compCls = new InquiryService.UserLoadWrapper(newInquiry.id,1,2,10,2,1); 
        compCls.compareTo(compCls);
    }
}