@isTest
public class InitializeSRDataTest {
    
    Public static NSIBPM__Service_Request__c getSerReq(string rectypeName,boolean withParentSR,string srtemplateid){
        Account a = new Account();
        a.Name = 'Test Account';
        a.Agency_Short_Name__c = 'testShrName';
        insert a;
        Id RecType1 = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get(rectypeName).getRecordTypeId();
        NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
        if(!withParentSR){
            sr.NSIBPM__Customer__c = a.id;
            sr.Agency__c = a.id;
            sr.Eligible_to_Sell_in_Dubai__c = true;
            sr.Agency_Type__c = 'Individual';
            sr.ID_Type__c = 'Passport';
            sr.Agency__c = a.id;
            sr.Agency_Email_2__c = 'test2@gmail.com';
            sr.Alternate_Agency_Email_2__c = 'test1@gmail.com';
            sr.Country_of_Sale__c = 'UAE;KSA;Lebanon';
        }
        else{
            Id RecType = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get('Deal').getRecordTypeId();
            NSIBPM__Service_Request__c sr1 = new NSIBPM__Service_Request__c();
            sr1.NSIBPM__Customer__c = a.id;
            sr1.RecordTypeId = RecType;
            insert sr1;
            
            sr.NSIBPM__Customer__c = a.id;
            sr.Agency__c = a.id;
            sr.Eligible_to_Sell_in_Dubai__c = true;
            sr.Agency_Type__c = 'Individual';
            sr.ID_Type__c = 'Passport';
            sr.Agency__c = a.id;
            sr.NSIBPM__Parent_SR__c = sr1.id;
            sr.Agency_Email_2__c = 'test2@gmail.com';
            sr.Alternate_Agency_Email_2__c = 'test1@gmail.com';
            sr.Country_of_Sale__c = 'UAE;KSA;Lebanon';
        }    
        if(srtemplateid != null || srtemplateid != ''){
            sr.NSIBPM__SR_Template__c = srtemplateid;
        }
        if(RecType1 != null){
            sr.RecordTypeId = RecType1;
        }
        
        return sr;
    }
    
    public static void testdfsdf(){
        
    }
    
    public static Deal_Team__c createDealTeam(string srid,string dosid,string hosid,string pcid){
        Deal_Team__c dt = new Deal_Team__c();
        dt.Associated_Deal__c = srid;
        if(dosid != null && dosid != '')
            dt.Associated_DOS__c = dosid;
        if(hosid != null && hosid != '')
            dt.Associated_HOS__c = hosid;
        if(pcid != null && pcid != '')
            dt.Associated_PC__c = pcid;
        return dt;
    }
    
    
    public static Map<string,UserRole> createRoles(list<string> rolenames){
        system.debug(rolenames);
        List<UserRole> lstr = new List<UserRole>();
        Map<string,UserRole> mproleNameRole = new Map<string,UserRole>();
        for(string strrole : rolenames){
            lstr.add(new UserRole(DeveloperName = strrole+strrole, Name = strrole));
        }
        insert lstr;
        for(userrole ur : lstr){
            mproleNameRole.put(ur.name,ur);
        }
        return mproleNameRole;
    }
    
    public static List<NSIBPM__SR_Doc__c> createSRDocs(List<NSIBPM__SR_Template_Docs__c> lstSRtmpDocs,string srid){
        List<NSIBPM__SR_Doc__c> lstSrDoc = new List<NSIBPM__SR_Doc__c>();
        for(NSIBPM__SR_Template_Docs__c srTempDocu : lstSRtmpDocs){
            NSIBPM__SR_Doc__c srdoc = new NSIBPM__SR_Doc__c();
            srdoc.NSIBPM__Service_Request__c = srid;
            srdoc.NSIBPM__SR_Template_Doc__c = srTempDocu.id;
            lstSrDoc.add(srdoc);
        }
        return lstSrDoc;
    }
    
    
    
    public static List<NSIBPM__SR_Template_Docs__c> createSRTemplateDocs(List<NSIBPM__Document_Master__c> lstMDocs,string srtemplateid){
        List<NSIBPM__SR_Template_Docs__c> lstSRtmpDoc = new List<NSIBPM__SR_Template_Docs__c>();
        for(NSIBPM__Document_Master__c Mdoc : lstMDocs){
            NSIBPM__SR_Template_Docs__c stempDoc = new NSIBPM__SR_Template_Docs__c();
            stempDoc.NSIBPM__Optional__c = false;
            stempDoc.NSIBPM__Document_Master__c = Mdoc.id;
            stempDoc.NSIBPM__SR_Template__c = SRTemplateid;
            stempDoc.NSIBPM__Added_through_Code__c = true;
            stempDoc.NSIBPM__On_Submit__c = true;
            lstSRtmpDoc.add(stempDoc);
        }
        return lstSRtmpDoc;
    }
    
    
    public static List<NSIBPM__Document_Master__c> createMasterDocs(List<string> lstDocNames){
        List<NSIBPM__Document_Master__c> lstMDocs = new List<NSIBPM__Document_Master__c>();
        for(string stdocname : lstDocNames){
            NSIBPM__Document_Master__c docmaster = new NSIBPM__Document_Master__c();
            docmaster.NSIBPM__Code__c = stdocname;
            docmaster.NSIBPM__Dev_Doc_ID__c = stdocname;
            lstMDocs.add(docmaster);
        }
        return lstMDocs;
    }
    
    public static Map<string,profile> getprofiles(set<string> stProfileNames){
        Map<string,profile> mpProfile = new Map<string,profile>();
        for(profile p : [select id,name from profile where name in : stProfileNames]){
            mpProfile.put(p.name,p); 
        }
        return mpProfile;
    }
    
    public static List<user> createInternalUser(Map<id,integer> mpprofileidUsercount){
        List<User> lstUsers = new List<User>();
        integer uniqCont = 0;
        for(id pid : mpprofileidUsercount.keyset()){
            integer cnt = mpprofileidUsercount.get(pid);
            for(integer i = 1; i<= cnt;i++){
                string uniq = string.valueof(uniqCont);
                user u = new user();
                u.ProfileId = pid;
                u.LastName = 'la'+uniq+'st';
                u.Email = 'puser'+uniq+'00@ama.com';
                u.Username = 'puser'+uniq+'00@ama.com' + System.currentTimeMillis();
                u.CompanyName = 'TE'+uniq+'ST';
                u.Title = 'ti'+uniq+'tle';
                u.Alias = 'a4i'+uniq+'as';
                u.TimeZoneSidKey = 'America/Los_Angeles';
                u.EmailEncodingKey = 'UTF-8';
                u.LanguageLocaleKey = 'en_US';
                u.LocaleSidKey = 'en_US';
                lstUsers.add(u);
                uniqCont++;
            }
        }
        return lstUsers;
    }
    
    public static List<User> createportalUser(Map<id,integer> mpprofileidUsercount){
        Account portalAccount1 = new Account(Name = 'TestAccount',Agency_Short_Name__c='testAGN');
        Database.insert(portalAccount1);
        
        integer totalContactstobeCreated = 0;
        for(integer i : mpprofileidUsercount.values()){
            totalContactstobeCreated += i;
        }
        
        Map<integer,contact> mpcontacts = new Map<integer,contact>();
        for(integer i=1; i<=totalContactstobeCreated ; i++){
            mpcontacts.put(i,new Contact(
                                        FirstName = 'Te'+i+'st',
                                        Lastname = 'McTe'+i+'sty',
                                        AccountId = portalAccount1.Id,
                                        Email = System.now().millisecond() + 'test@t'+i+'est.com'
                                       ));
        }
        insert mpcontacts.values();
        
        integer uniqCont = 0;
        List<User> lstUsers = new List<User>();
        for(id pid : mpprofileidUsercount.keyset()){
            integer cnt = mpprofileidUsercount.get(pid);
            for(integer i = 1; i<= cnt;i++){
                string uniq = string.valueof(uniqCont);
                system.debug('----Contact-->'+mpcontacts.get(uniqCont+1).id);
                lstUsers.add(new User(
                    Username = System.now().millisecond() + 'test'+uniq+'345@test.com',
                    ContactId = mpcontacts.get(uniqCont+1).id,
                    ProfileId = pid,
                    Alias = 'tes'+uniq+'t',
                    Email = 'test'+uniq+'@test.com',
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'McTesty'+uniq,
                    CommunityNickname = 'test'+uniq,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US'));
                uniqCont++;
            }
        }
        return lstUsers;
    }
    
    public static list<Constants__c> createConstants(){
        List<Constants__c> lstConsts = new List<Constants__c>();   
        Recordtype r = [select id,name from recordtype where sobjecttype = 'Campaign__c' order by name asc limit 1];
        List<string> lstTypes = new List<String>{'Campaign','Country','Language','Campaign Category','Campaign Sub Category 1','Campaign Sub Category 2','Month'};
            for(string stType : lstTypes){
                Constants__c obj = new Constants__c();
                if(stType == 'Country'){
                    obj.Type__c = stType;
                    obj.Code__c = 'NW';
                    obj.Name__c = 'Norway';
                }
                else if(stType == 'Language'){
                    obj.Type__c = stType;
                    obj.Code__c = 'CZ';
                    obj.Name__c = 'Czech';
                }
                else if(stType == 'Month'){
                    obj.Type__c = stType;
                    obj.Code__c = string.valueof(System.today().month());
                    obj.Name__c = string.valueof(System.today().month());
                }
                else if(stType == 'Campaign'){
                    obj.Type__c = stType;
                    obj.Code__c = 'oA';
                    obj.Name__c = 'Outdoor Ads';
                }
                else if(stType == 'Campaign Category'){
                    obj.Type__c = stType;
                    obj.Code__c = 'BH';
                    obj.Name__c = 'Billboard/Hoarding';
                }
                else if(stType == 'Campaign Sub Category 1'){
                    obj.Type__c = stType;
                    obj.Code__c = 'GHAC';
                    obj.Name__c = 'Garhoud Hoarding / Aviation College';
                }
                else if(stType == 'Campaign Sub Category 2'){
                    obj.Type__c = stType;
                    obj.Code__c = 'GHAC';
                    obj.Name__c = 'Replacement';
                }
                lstConsts.add(obj);
            }
        Constants__c obj = new Constants__c();
        obj.Type__c = 'RecordType';
        obj.Code__c = 'codeTest';
        obj.Name__c = r.name;
        lstConsts.add(obj);
        Constants__c obj1 = new Constants__c();
        obj1.Type__c = 'RecordType';
        obj1.Code__c = 'UAE';
        obj1.Name__c = 'Afghanistan';
        lstConsts.add(obj1);
        return lstConsts;
    }
    
    public static Campaign__c createCampaign(string recType){
        Id RecTypeid = Schema.SObjectType.Campaign__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();
        Campaign__c c = new Campaign__c();
        c.Campaign_Name__c = recType;
        if(RecTypeid != null){
            c.RecordTypeId = RecTypeid;
        }
        C.End_Date__c = system.today();
        C.Marketing_End_Date__c = system.today();
        C.Marketing_Start_Date__c = system.today();
        C.Start_Date__c = system.today();
        return c;
    }
    
    public static NSIBPM__SR_Doc__c createSRDOCBookingUnit(id srid,id bookingunitId){
        NSIBPM__SR_Doc__c srdoc = new NSIBPM__SR_Doc__c();
        srdoc.name= 'ppt';
        srdoc.Booking_Unit__c  = bookingunitId;
        srdoc.NSIBPM__Service_Request__c = srid;
        return srdoc;
    }
    
    
    public static Page_Flow__c createPageFlow(string pagename, string recType){
        Page_Flow__c p =new Page_Flow__c(name=pagename,Record_Type_API_Name__c=recType);
        return p;
    }  
    
    public static PSRLT__c createProfileSRLayoutMapping(id userid,boolean isoverride){
        PSRLT__c p =new PSRLT__c(SetupOwnerId=userid, Override__c=isoverride);
        return p;
    }
    
    public static Map<string,NSIBPM__SR_Status__c> createSRStatus(List<string> statuses){
        Map<string,NSIBPM__SR_Status__c> mpSRStatuses = new Map<string,NSIBPM__SR_Status__c>();
        List<NSIBPM__SR_Status__c> lstSRStatuses = new List<NSIBPM__SR_Status__c>();
        for(string st : statuses){
            NSIBPM__SR_Status__c obj = new NSIBPM__SR_Status__c();
            obj.NSIBPM__Code__c = st;
            obj.NSIBPM__DEV_Id__c = st;
            obj.Name = st;
            lstSRStatuses.add(obj);
        } 
        insert lstSRStatuses;
        for(NSIBPM__SR_Status__c srstatus : lstSRStatuses){
            mpSRStatuses.put(srstatus.NSIBPM__Code__c,srstatus);
        }
        return mpSRStatuses;
    }
    
    public static Map<string,NSIBPM__Status__c> createStepStatus(List<string> statuses){
        Map<string,NSIBPM__Status__c> mpStepStatuses = new Map<string,NSIBPM__Status__c>();
        List<NSIBPM__Status__c> lstStepStatuses = new List<NSIBPM__Status__c>();
        for(string st : statuses){
            NSIBPM__Status__c obj = new NSIBPM__Status__c();
            obj.NSIBPM__Code__c = st;
            lstStepStatuses.add(obj);
        } 
        insert lstStepStatuses;
        for(NSIBPM__Status__c stepstatus : lstStepStatuses){
            mpStepStatuses.put(stepstatus.NSIBPM__Code__c,stepstatus);
        }
        return mpStepStatuses;
    }
    
    
    public static Location__c createLocation(String locId,String locType){
        Location__c locationNew = new Location__c();
        locationNew.Location_ID__c = locId ;
        locationNew.Location_Type__c = locType ; 
        return locationNew ;
    }
    
    Public static Inventory__c createInventory(string locationid){
        Inventory__c inv = new Inventory__c();
        inv.Property_Type__c = 'PropertyType';
        inv.Building_Name__c = 'BuildingName';
        inv.Building_Location__c = locationid;
        inv.Status__c = 'Released';
        inv.Price__c = '234';
        inv.Inventory_ID__c = 'wsfd4ew';
        return inv;
    }
    
    public static Booking__c createBooking(string srid){
        Booking__c  bk = new  Booking__c();
        bk.Deal_SR__c = srid;
        bk.Booking_Channel__c = 'Web';
        return bk;
    }
    
    public static NSIBPM__SR_Template__c createSRTemplate(string recTypeName){
        NSIBPM__SR_Template__c SRTemplate = new NSIBPM__SR_Template__c();
        srtemplate.NSIBPM__SR_RecordType_API_Name__c = recTypeName;
        return SRTemplate;
    }
    
    public static NSIBPM__Step_Template__c createStepTemplate(string recTypeName,string code){
        NSIBPM__Step_Template__c sttempl = new NSIBPM__Step_Template__c();
        sttempl.NSIBPM__Step_RecordType_API_Name__c = recTypeName;
        sttempl.NSIBPM__Code__c = code;
        return sttempl;
    }
    
    public static Booking_Unit__c createBookingUnit(string bkid,string invid){
        Booking_Unit__c bu = new Booking_Unit__c();
        bu.Booking__c = bkid;
        bu.Payment_Method__c = 'Cash';
        bu.Primary_Buyer_s_Email__c = 'raviteja@nsiglobal.com';
        bu.Primary_Buyer_s_Name__c = 'testNSI';
        bu.Primary_Buyer_s_Nationality__c = 'test';
        bu.Inventory__c = invid;
        return bu; 
    }
    
    public static Payment_Plan__c createPaymentPlan(string buid,string locid){
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Booking_Unit__c = buid;
        pp.Building_Location__c = locid;
        pp.TERM_ID__c = 'asadas3eds';
        return pp;
    }
    
    public static Buyer__c createBuyer(string bkid,boolean isprimary){
        Buyer__c b = new Buyer__c();
        b.Booking__c = bkid;
        b.First_Name__c = 'testsdf';
        b.Last_Name__c = 'testlastname';
        b.Nationality__c = 'Afghanistan';
        b.Phone__c = '23456';
        b.Date_of_Birth__c = '22/03/1988';
        b.Primary_Buyer__c = isprimary;
        b.Unique_Key__c = 'B-1';
        //
        b.Buyer_Type__c =  'Individual';
        b.Address_Line_1__c =  'Ad1';
        b.Country__c =  'United Arab Emirates';
        b.City__c = 'Dubai' ;
        //b.Date_of_Birth__c = string.valueof(system.today().addyears(-30)) ;
        b.Email__c = 'test@test.com';
        b.First_Name__c = 'firstname' ;
        b.Last_Name__c =  'lastname';
        b.Nationality__c = 'Indian' ;
        b.Passport_Expiry_Date__c = string.valueof(system.today().addyears(20)) ;
        b.Passport_Number__c = 'J0565556' ;
        b.Phone__c = '569098767' ;
        b.Phone_Country_Code__c = 'United Arab Emirates: 00971' ;
        b.Place_of_Issue__c =  'India';
        b.Title__c = 'Mr';
        return b;
    }
    
    public static list<Agent_Site__c> createAgentSites(List<string> ctryofSale,string accid){
        list<Agent_Site__c> lstAgentSites = new List<Agent_Site__c>();
        for(string st : ctryofSale){
            Agent_Site__c obj = new Agent_Site__c();
            obj.Start_Date__c = system.today();
            obj.Name = st;
            obj.Agency__c = accid;
            lstAgentSites.add(obj);
        } 
        return lstAgentSites;
    }    
    
    public static NSIBPM__Step__c createStep(id srid,string stepstatusid, string steptemplateid){
        NSIBPM__Step__c stp = new NSIBPM__Step__c();
        stp.NSIBPM__SR__c = srid;
        if(stepstatusid != null && stepstatusid != ''){
            stp.NSIBPM__Status__c = stepstatusid;
        }if(steptemplateid != null && steptemplateid != ''){
            stp.NSIBPM__Step_Template__c = steptemplateid;
        }        
        return stp;
    }
    
    public static Amendment__c getAmendment(id srid){
        Amendment__c amd = new Amendment__c();
        amd.First_Name__c = 'testFN';
        amd.Last_Name__c = 'testLN';
        amd.Service_Request__c = srid;
        return amd;
    }
}