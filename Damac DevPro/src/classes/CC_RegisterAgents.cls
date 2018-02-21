global without sharing class CC_RegisterAgents implements NSIBPM.CustomCodeExecutable, Queueable {
    
    public Id currentSrId;
    public static List<Amendment__c> amd_List = new List<Amendment__c>();
    public static Map<String, Amendment__c> amdMap = new Map<String, Amendment__c>();
    public static Map<String, Contact> conMap = new Map<String, Contact>();
    public RecordType RecordTypePA = [Select Id from RecordType Where developerName = 'Individual_Agency' and SObjectType = 'Account'];
     
    public CC_RegisterAgents(){
        
    }
    public CC_RegisterAgents(Id currentSrId){
        this.currentSrId = currentSrId; 
    } 
    
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step) {
        String retStr = 'Success';
        Account newAcc,exacc;
        List<id> accids = new List<id>();
        try {
            Boolean bankchange=false;
            NSIBPM__Service_Request__c currSR = getSRDetails(step.NSIBPM__SR__c);
            if(currSR.NSIBPM__Customer__c !=null){
            
                exacc =[select id,name,Vendor_ID__c,Bank_Name__c,Bank_Country__c,Bank_Branch__c,Bank_City__c,Bank_Account_Currency__c,
                                Bank_Account_Number__c,IBAN_Number__c,Swift_Code__c,Sort_Code__c,IFSC_Code__c from Account where id =:currSR.NSIBPM__Customer__c];
                
                if(exacc.Bank_Name__c!= currSR.Bank_Name__c)
                bankchange=true;
                else if(exacc.Bank_Country__c!= currSR.Account_Details_Country__c)
                bankchange=true;
                else if(exacc.Bank_Branch__c!= currSR.Bank_Branch__c)
                bankchange=true;
                else if(exacc.Bank_City__c!= currSR.Bank_City__c)
                bankchange=true;
                else if(exacc.Bank_Account_Currency__c!= currSR.Bank_Account_Currency__c)
                bankchange=true;
                else if(exacc.Bank_Account_Number__c!= currSR.Account_Number__c)
                bankchange=true;
                else if(exacc.IBAN_Number__c!= currSR.IBAN_Number__c)
                bankchange=true;
                else if(exacc.Swift_Code__c!= currSR.Swift_Code__c)
                bankchange=true;
                else if(exacc.Sort_Code__c!= currSR.Sort_Code__c)
                bankchange=true;
                else if(exacc.IFSC_Code__c!= currSR.IFSC_Code__c)
                bankchange=true;
                
            } 
            amd_List =  getAllAmendments(currSR.Id);
            currentSrId = step.NSIBPM__SR__c;
            //AmendmentID -->Amendment
            for (Amendment__c amd : amd_List) {
                amdMap.put(amd.Id, amd);
            }

            //Cretae portal user/contacts for Corporate Agency SRs
            if (currSR.Agency_type__c == 'Corporate') {
                System.debug('==>Corporate Agency');
                newAcc = createAccount(currSR);

                //Update SR to lookup on account
                currSR.NSIBPM__Customer__c = newAcc.Id;
                update currSR;
                if(currSR.NSIBPM__Record_Type_Name__c == Label.ManageAgencySiteInsert)
                	SRUtility.CreateChatterGroup(new map<id,account>{newAcc.id => newAcc});
                //Create Contacts
                List<Contact> newCon_List = createContacts(currSR, newAcc);
                for (Contact con :  newCon_List) {
                    conMap.put(con.AmendmentID__c, Con);
                }
                //Update amendment Acc/Contact lookups
                amd_List = updateAmendmentLookups(newAcc);
                System.enqueueJob(new CC_RegisterAgents(currSR.Id));
            } else {
                System.debug('==>Individual Agency');
                String keyVal = currSR.First_Name__c + currSR.Last_Name__c + currSR.Agency_Mobile__c;
                System.debug('keyVal ==>'+keyVal);
                if(keyVal != NULL && keyVal != '')
                if (!checkForDuplicatePersonAccounts(keyVal,currSR.NSIBPM__Customer__c)) {
                    System.debug('==>No Duplicate');
                    newAcc =  createPersonAccount(currSR);
                    currSR.NSIBPM__Customer__c = newAcc.Id;
                    update currSR;
                    for(user u: [select id,name,profile.name,Profile.UserLicense.Name,contactid from user where id = : currSR.createdbyid]){
                        if(u.profile.name == 'Property Consultant' && currSR.NSIBPM__Record_Type_Name__c == 'Agent_Registration'){
                            addpctoAccount(currSR.NSIBPM__Customer__c,u.id,u.name);
                        }
                    }
                    System.debug('==>' + newAcc);
                } else {
                    retStr = 'Duplicate Person Account.';
                    return retstr;
                }
            }
            
            if(newAcc.id!=null){
                accids.add(newAcc.id);

            }
            if(accids.size()>0){
                IF(currSR.NSIBPM__Record_Type_Name__c == Label.ManageAgencySiteInsert)
                	system.enqueueJob(new AsyncAgentWebservice (accids,'Agent Creation'));
                if(bankchange)
                    system.enqueueJob(new AsyncAgentWebservice (accids,'Bank Updation'));
           
            }
            
            if(currSR.NSIBPM__Customer__c != null){
                //Create or Update Agency site records based on SR -> Country of Sale Field.
                /* Commented to be called from Agent Creation success
                if(currSR.NSIBPM__Record_Type_Name__c == Label.ManageAgencySiteInsert && currSR.Country_of_Sale__c != null){
                    ManageAgencySites.insertAgencySites(currSR.Country_of_Sale__c,currSR.NSIBPM__Customer__c);
                }
                else*/
                if(currSR.NSIBPM__Record_Type_Name__c == Label.ManageAgencySiteUpdate && currSR.Country_of_Sale__c != null){
                    ManageAgencySites.UpdateAgencySites(currSR.Country_of_Sale__c,currSR.NSIBPM__Customer__c);
                }
            }
            
        } catch (Exception e) {
            retStr = 'Error :' + e.getMessage() + '';
        }
        return retStr;
    }
    
    public void execute(QueueableContext qc) {
        createPortalUser(currentSrId);  
    }
    
    public List<Amendment__c> updateAmendmentLookups(Account acc) {
        List<Amendment__c> amdUpdateList = new List<Amendment__c>();
        for (Amendment__c amd :  amd_List) {
            amd.Account__c = acc.Id;
            amd.Contact__c = conMap.get(amd.Id).Id;
            amdUpdateList.add(amd);
        }
        update amdUpdateList;
        return amdUpdateList;
    }
    
    public Account createAccount(NSIBPM__Service_Request__c SR) {
        Account newAcc = new Account(Id = SR.NSIBPM__Customer__c);
        /*
        newAcc.Name = SR.Agency_Name__c;
        newAcc.Corporate_Agency_Type__c = SR.Agency_Type__c;
        newAcc.State__c = SR.Emirate_State__c;
        newAcc.Fax__c = SR.Fax__c;
        newAcc.AccountNumber  = SR.Account_Number__c;
        for(Schema.FieldSetMember fld : sObjectType.Account.FieldSets.SRToAccountFieldMapping.getFields()){
            newAcc.put(fld.getFieldPath(),SR.get(fld.getFieldPath()));
        }
        */
        List<Account_SR_Field_Mapping__c> CS = Account_SR_Field_Mapping__c.getAll().values();
        for (Account_SR_Field_Mapping__c mapping : CS) {
            if(!mapping.Is_Person_Account__c)
                newAcc.put(mapping.Account_Field__c, SR.get(mapping.SR_Field__c));
        }
        system.debug('--newAcc->'+newAcc);
        newAcc.RecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Agency').getRecordTypeId();

        upsert newAcc;
        return newAcc;
    }

    public Account createPersonAccount(NSIBPM__Service_Request__c currSR) {
        try{
        Account personAcc  = new Account();
        List<Account_SR_Field_Mapping__c> CS = Account_SR_Field_Mapping__c.getAll().values();
        for (Account_SR_Field_Mapping__c mapping : CS) {
            if(mapping.Is_Person_Account__c || mapping.Is_Common_to_All_RT__c)
                if(currSR.get(mapping.SR_Field__c) != null)
                personAcc.put(mapping.Account_Field__c, currSR.get(mapping.SR_Field__c));
        }

        personAcc.PersonAccountKey__c = currSR.First_Name__c  + currSR.Last_Name__c + currSR.Agency_Mobile__c;
        personAcc.RecordTypeId = RecordTypePA.Id;
            system.debug('--->before '+personAcc.firstname+personAcc.lastname+personacc.phone+personacc.email__c);
        upsert personAcc PersonAccountKey__c;
            system.debug('--->after '+personAcc.id);
        return personAcc;
        }
        catch(exception ex){
        	system.debug('Exception at line number = '+ex.getLineNumber()+', Exception message = '+ex.getMessage());
            return null;
        }
    }

    public boolean checkForDuplicatePersonAccounts(String keyVal,id accID) {
        Boolean flag ;
        List<Account> acc_List = new List<Account>();
        if(accID != null){
        for(Account a  :[Select id,RecordType.developerName from Account Where RecordType.developerName = 'Individual_Agency' AND PersonAccountKey__c = :keyVal AND PersonAccountKey__c != NULL and id != : accID LIMIT 1] ){
            acc_List.add(a);
        }
        }else{
            for(Account a  :[Select id,RecordType.developerName from Account Where RecordType.developerName = 'Individual_Agency' AND PersonAccountKey__c = :keyVal AND PersonAccountKey__c != NULL LIMIT 1] ){
            acc_List.add(a);
        }
        }
        flag = (acc_List.Size() > 0) ? true :  false;
        return flag;
    }
    
    public String retPrefix() {
        Integer y = system.now().year();
        Integer m = system.now().month();
        Integer d = system.now().day();
        Integer hr = system.now().hour();
        Integer min = system.now().minute();
        Integer sec = system.now().second();
        String t = string.valueOf(y) + string.valueOf(m) + string.valueOf(d) + string.valueOf(hr) + string.valueOf(min) + string.valueOf(sec);
        return t;
    }
    
    public static String randomWithLimit(Integer upperLimit) {
        Integer rand = Math.round(Math.random() * 1000);
        return String.valueOf(Math.mod(rand, 9999)).leftpad(4, '0');
    }


    public static string getUserName(Contact c) {
        String username = '';
        if (c.FirstName != NULL) {
            username += c.FirstName.replaceAll( '\\s+', '');
        }
        if (c.LastName != NULL) {
            username += c.LastName.replaceAll( '\\s+', '');
        }
        username += randomWithLimit(9999);

        username += '@damacagents.com';
        return username;
    }
    
    public static String getUserProfile(Amendment__c amd) {
        String profileName = 'Customer Community - Agent';
        if (amd.Portal_Administrator__c) {
            profileName = 'Customer Community - Admin';
        }
        if (amd.Agent_Representative__c) {
            profileName = 'Customer Community - Agent';
        }
        if (amd.Authorised_Signatory__c) {
            profileName = 'Customer Community - Admin';
        }
        if (amd.Owner__c) {
            profileName = 'Customer Community - Owner';
        }
        if (amd.Agent_Representative__c && amd.Portal_Administrator__c) {
            profileName = 'Customer Community - Agent + Admin';
        }
        if (amd.Authorised_Signatory__c && amd.Portal_Administrator__c) {
            profileName = 'Customer Community - Auth + Admin';
        }
        if (amd.Authorised_Signatory__c && amd.Agent_Representative__c) {
            profileName = 'Customer Community - Auth + Agent';
        }
        if (amd.Agent_Representative__c && amd.Portal_Administrator__c && amd.Authorised_Signatory__c) {
            profileName = 'Customer Community - Agent + Admin + Auth';
        }
        return profileName;
    }
    
    public static void addpctoAccount(id accid,id userid,string username){
        Agency_PC__c agp = new Agency_PC__c(Agency__c = accid,User__c = userid,Name = username);
        insert agp;
    }
    
    public static void createPortalUser( Id SrId) {
        NSIBPM__Service_Request__c currSR = getSRDetails(SrId);
        //skip the creation of user if a SR is created from users who belongs to profiles mentioned in the label.
         for(user u: [select id,name,profile.name,Profile.UserLicense.Name,contactid from user where id = : currSR.createdbyid]){
            /*for(string pfName : Label.ProfilesIncludedByPassUserCreation.split(',')){
                if(u.profile.name == pfName){
                    system.debug('-->Users will not be created.');
                    return;Guest User License
                }
            }*/
             if(u.profile.name == 'Property Consultant' && currSR.NSIBPM__Record_Type_Name__c == 'Agent_Registration'){
                 addpctoAccount(currSR.NSIBPM__Customer__c,u.id,u.name);
             }
            if((u.contactid == null && u.Profile.UserLicense.Name != 'Guest User License' && !Test.isRunningTest())){
                return;
            }
        }
        List<String> portalProfileName = new List<String> {'Customer Community - Admin', 'Customer Community - Agent', 'Customer Community - Agent + Admin', 'Customer Community - Agent + Admin + Auth', 'Customer Community - Auth + Admin', 'Customer Community - Auth + Agent', 'Customer Community - Owner'};
        Map<String, Id> profileMap = new Map<String, Id>();
        for (Profile p : [select id, Name from profile where Name IN :portalProfileName]) {
            profileMap.put(p.Name, p.Id);
        }
        List<User> portalUserList = new List<User>();
        User u ;
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        dlo.EmailHeader.triggerAutoResponseEmail = true;
        system.debug('#### currentSrId = '+SrId);
        
        System.debug('***'+currSR.NSIBPM__Customer__c);
        Id accId = currSR.NSIBPM__Customer__c;
        
        //AmendmentID -->Amendment
        for (Amendment__c amd : getAllAmendments(SrId)) {
            amdMap.put(amd.Id, amd);
        }

        String conQuery = 'Select FirstName,Passport_Number__c,LastName,Designation__c,Nationality__c,Broker_Card_Expiry_Date__c,AmendmentID__c,Broker_Card_Number__c,MobilePhone,AccountId,ID_Type__c ,Email,Id,Shareholding__c,Is_Eligible_To_Sell__c,Agent_Representative__c,Owner__c,Authorised_Signatory__c,Portal_Administrator__c FROM Contact ';
        conQuery += ' WHERE AccountId =: accId ';   
        for (Contact con :  Database.Query(conQuery)) {
            conMap.put(con.AmendmentID__c, Con);
        }
        Map<Id,user> conIdUserMap = getUserContactMap(currSR.NSIBPM__Customer__c);
       
        System.debug('amdMap.Values()=>' + amdMap.Values());
        if (currSR.Agency_type__c == 'Corporate') {
            for (Amendment__c amd : amdMap.Values()) {
                Contact con = conMap.get(amd.Id);
                //Check if Contact Already has an user associated to update it
                ID userId = (conIdUserMap.get(con.id) != NULL) ? conIdUserMap.get(con.id).Id : NULL;
                System.debug('User Id : '+userId);
                u =  new User( Id= userId);
                
                String UserName = '';
                String aliasVal = String.valueOf(con.Id);
                u.alias = aliasVal.substring(0, 5);
                u.email = con.Email;
                u.Is_Eligible_To_Sell__c = amd.Is_Eligible_To_Sell__c;
                u.emailencodingkey = 'UTF-8';
                u.timezonesidkey = 'Asia/Dubai';
                u.FirstName = con.FirstName;
                u.LastName = con.LastName;
                //Skip assigning of contact for update operation
                if(userId == NULL){
                   u.ContactId = con.Id;
                }
                u.ProfileId = profileMap.get(getUserProfile(amd));
                u.languagelocalekey = 'en_US';
                u.localesidkey = 'en_GB';
                if(userId == null)
                    u.username = getUserName(con);
                u.setOptions(dlo);
                portalUserList.add(u);
            }
        }
        System.debug('portalUserList==>' + portalUserList);
        if (!Test.isRunningTest() && !portalUserList.isEmpty() ) {
            Database.Upsert(portalUserList,User.Fields.Id,true); 
        }
    }
    
    public static List<Amendment__c> getAllAmendments(Id SrId) {
        String amendmentQuery = UtilityQueryManager.getAllFields(Amendment__c.getsObjectType().getDescribe());
        amendmentQuery += ' WHERE Service_Request__c =: SRId ';
        return (Database.query(amendmentQuery));
    }
    
    public List<Contact> createContacts(NSIBPM__Service_Request__c SR, Account newAcc) {
        Id SRId = SR.Id;
        List<Contact> conList = new List<Contact>();
        Contact newCon;
        for (Amendment__c amd : amdMap.values()) {
            System.debug('amd.Contact__c**'+amd.Contact__c);
            newCon = new Contact(id = amd.Contact__c);
            newCon.FirstName =  amd.First_Name__c ;
            newCon.LastName = amd.Last_Name__c;
            newCon.AccountId = newAcc.Id;
            newCon.Email = amd.Email__c;
            newCon.ID_Issue_Date__c = amd.ID_Issue_Date__c;
            newCon.MobilePhone = amd.Mobile__c;
            newCon.Shareholding__c = amd.Shareholding__c;
            newCon.Designation__c = amd.Designation__c;
            newCon.Country_Of_Origin__c = amd.Nationality__c;
            newCon.Title = amd.Title__c;
            newCon.ID_Number__c = amd.ID_Number__c;
            newCon.AmendmentID__c = amd.Id;
            newCon.ID_Type__c = amd.ID_Type__c;
            newCon.Broker_Card_Expiry_Date__c = amd.Broker_Card_Expiry_Date__c;
            newCon.Broker_Card_Number__c = amd.Broker_Card_Number__c;
            newCon.Is_Eligible_To_Sell__c = amd.Is_Eligible_To_Sell__c;
            newCon.Agent_Representative__c = amd.Agent_Representative__c;
            newCon.Owner__c = amd.Owner__c;
            newCon.Mobile_Country_Code__c = amd.Mobile_Country_Code__c;
            newCon.Id_Expiry_date__c = amd.ID_Expiry_Date__c;
            newCon.Authorised_Signatory__c = amd.Authorised_Signatory__c;
            newCon.Portal_Administrator__c = amd.Portal_Administrator__c;
            if(amd.Mark_for_Deletion__c)
                newCon.Status__c = 'Cancelled';
            newCon.RecordTypeId  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agency Contact').getRecordTypeId();
            conList.add(newCon);
        }
        upsert conList;
        return conList;
    }

    public static NSIBPM__Service_Request__c getSRDetails(Id SRId) {
        NSIBPM__Service_Request__c currSR = new NSIBPM__Service_Request__c();
        DescribeSObjectResult describeResult = NSIBPM__Service_Request__c.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String> ( describeResult.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNames, ',' ) + ' FROM ' + describeResult.getName();
        query += ' WHERE Id =: SRId LIMIT 1';
        System.debug('==>' + query);
        currSR = Database.query(query);
        return currSR;
    }
    
    public static Map<Id,user> getUserContactMap(Id AccId){
        Map<Id,user>conIdUsermap = new Map<Id,User>();
        for(User u :  [Select Id,FirstName,LastName,ContactId from user Where ContactId IN (Select Id From Contact where AccountId =:AccId)]){
            conIdUsermap.put(u.ContactId,u);
        }
        return conIdUserMap;
    }
}