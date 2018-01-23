public class NewLeadController {
    public Lead nLead {get;set;}
    public String recordTypeName{get;set;}
    public String leadId{get;set;}
    public String refRecId;
    public String URLopp{get;set;}
    public String URLld{get;set;}
    public String URLcon{get;set;}
    public  Map<Id,Call_in_Code__c> listCIC;
    public List<CampaignMemberWrapper> campMWrpList{get;set;}
    public List<TreatmentHistoryWrp> TreatmentHistoryWrpList {get;set;}
    public Integer rowToRemove{get;set;}
    public Integer searchPosition{get;set;}
    public boolean isNotSelf{get;set;}
    //public boolean flagRelated{get;set;}
    public boolean isPriorTreatmentYes{get;set;}
    public boolean isLeadSourceisFRNAlumniYes{get;set;}
    public boolean isSelf{get;set;}
    public List<SelectOption> refOrders{get;set;}
    public boolean isLeadSaved {get;set;}
    public List<SelectOption> callInCodePicklist {get;set;}
    public String selectedCallInCode {get;set;}
    public Boolean rend1 {get;set;}
    public Boolean rend2 {get;set;}
    public Boolean rend3 {get;set;}
    public Boolean rend4 {get;set;}
    public Boolean rend5 {get;set;}
    public String specialInstructionsMsg {get; set;}
    public Boolean highPriorityCheck {get; set;}
    public Integer highPriorityReferralRank;
    public Integer highPriorityReferralIndex {get; set;}
    public Boolean validHighReferralWrp {get; set;}
    public Integer rankPosition{get;set;}
    public Map<String, Integer> refralRankStrToRank = new Map<String, Integer>{'Primary' => 1,
                                                                               'Secondary' => 2,
                                                                               'Tertiary' => 3,
                                                                               'Other' => 4
                                                                               };

    public NewLeadController(ApexPages.StandardController controller){
        specialInstructionsMsg = '';
        highPriorityCheck = false;
        validHighReferralWrp = false;
        highPriorityReferralRank = 99;
        highPriorityReferralIndex = 0;
        isPriorTreatmentYes = false;
        isLeadSourceisFRNAlumniYes = false;
        isLeadSaved = false;
        rend1 = false ;
        rend2 = false ;
        rend3 = false ;
        rend4 = false ;
        rend5 = false ;
        //flagRelated= false;
        abtValue = '';
        nLead = new Lead();
        nLead.Origin__c = 'Inbound Call';
        nLead.company = 'New Household';
        campMWrpList = new List<CampaignMemberWrapper>();
        TreatmentHistoryWrpList = new List<TreatmentHistoryWrp>();
        refOrders = new List<SelectOption>();
        //referlist();
        /*Schema.DescribeFieldResult fieldResult = Referral__c.Referral_Rank__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            refOrders.add(new SelectOption(f.getLabel(), f.getValue()));
        } */

        If(nLead.ownerId =='' || nLead.ownerId == null){
            nLead.ownerId = UserInfo.getUserId();
        }
        leadId = ((Lead)controller.getRecord()).id;
        RecordType rcTyp = [SELECT Name FROM RecordType WHERE SobjectType =: 'Lead'];
        refRecId = Schema.Sobjecttype.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId();
        System.debug('refRecId....>'+refRecId);
        recordTypeName = rcTyp.Name;
        system.debug('LeadId_________________________'+leadId);
        system.debug('RecordType_________________________'+recordTypeName);

        if(leadId !=null){
            nLead = [SELECT Salutation,Name, FirstName, Status, MiddleName, Rating, LastName, Type__c, Suffix, Company, Owner.Name ,Online_Search_Term__c, Friend_Family_Details__c,ownerId, LeadSource, Preferred_Contact_Method__c, Phone, DoNotCall, MobilePhone, HasOptedOutOfEmail, Work_Phone__c, Email, Fax, HasOptedOutOfFax, CountryCode, Street, City, StateCode, PostalCode, Calling_for__c, Relationship_to_Patient__c, Patient_Willing_to_Receive_Treatment__c, Description_of_Average_Day__c, Timeframe_of_Impact__c, What_Prompted_Call__c, Alumni_Referral_Source__c, Impact_on_Job__c, Patient_Currently_Working__c, Impact_on_Relationships__c, Trigger__c, Contributing_Factors__c, Payment__c, Diagnosed_with_Psychiatric_Condition__c, Prior_Treatment__c, Vision_of_Future_without_Treatment__c, Ready_to_Make_Commitment__c, Level_of_Committment__c, Chat_Email_Transcript__c, Customer_Note__c,State,Country,ScratchPad__c, Caller_First_Name__c, Caller_Last_Name__c, Caller_Id__c, Caller_Phone__c, Caller_Mobile__c, Caller_Work_Phone__c, Caller_Email__c ,Happiness_Scale__c,Origin__c,Birthdate__c,Lead_Source_is_FRN_Alumni__c,Alumni_Name__c,Alumni_FRN_Facility__c , Referral_Source_Unknown_Details__c,Call_in_Code__c,Identified_Gender__c,Gender__c FROM Lead WHERE id =: leadId];
            System.debug(nLead.Online_Search_Term__c);
            CampaignMemberWrapper cmpWrp;
            for(Referral__c cmpMW:[Select Id,RAM_Lookup__c,Lead__c,Account__c,Account__r.name,Consentor__c,Consentor__r.name, Consentor__r.Currently_Employed__c, Referral_Rank__c FROM Referral__c WHERE Lead__c=:leadId]){
                cmpWrp = new CampaignMemberWrapper();
                cmpWrp.index = campMWrpList.size();
                cmpWrp.cmpM = cmpMW;
                if(cmpMW.RAM_Lookup__c !=null)
                    cmpWrp.RAMName = cmpMW.RAM_Lookup__c;
                if(cmpMW.Account__c !=null)
                    cmpWrp.referralSourceList.add(new SelectOption(cmpMW.Account__c,cmpMW.Account__r.Name));
                if(cmpMW.Consentor__c!=null && cmpMW.Consentor__r.Currently_Employed__c == TRUE)
                    cmpWrp.referralSourceConList.add(new SelectOption(cmpMW.Consentor__c, cmpMW.Consentor__r.Name));
                /*if(cmpMW.Referral_Rank__c !=null ){
                    cmpWrp.refOrders = cmpMW.Referral_Rank__c;
                }*/
                campMWrpList.add(cmpWrp);
            }
            if(campMWrpList.size()>0){
                referlist();
            }

            // For LeadSource Depend Section will open in VF Page
            rendSection();

            List<Treatment_History__c> TreatmentHistorywpList = [SELECT RecordTypeID,Type__c,Other_Facility__c,Level_of_Care__c,Was_Treatment_Involuntary__c,Discharge_Date__c,Admit_Date__c,Lead__c FROM Treatment_History__c WHERE Lead__c =:leadId];
            TreatmentHistoryWrp trthWrp;
            for(Treatment_History__c trth : TreatmentHistorywpList){
                trthWrp = new TreatmentHistoryWrp();
                trthWrp.record = trth;
                trthWrp.index = TreatmentHistoryWrpList.size()-1;
                TreatmentHistoryWrpList.add(trthWrp);
            }
            if(nLead.Prior_Treatment__c=='yes'){
            isPriorTreatmentYes = true;
            }
            leadCallingFor();
            leadDuplicate();
            selectedCallInCode = nLead.Call_in_Code__c;
        }
        if(campMWrpList.size()==0){
            addNewRow();
        }
        if(TreatmentHistoryWrpList.size()==0){
            addNewTreatmentHistoryObj();
        }

        callInCodePicklist = new List<SelectOption>();
        listCIC = new Map<Id,Call_in_Code__c>([SELECT Id,
                                                      Name
                                                 FROM Call_in_Code__c
                                                WHERE Inactive__c = false
                                             ORDER BY Name ASC]);
        system.debug('listCIC:::>>>  '+ listCIC);
        for(Call_in_Code__c eachCIC : listCIC.values()){
           callInCodePicklist.add(new SelectOption(eachCIC.Id, eachCIC.name));
        }

    }

    public void rendTreatmentHistoryInfo(){
        if(nLead.Prior_Treatment__c=='yes'){
            isPriorTreatmentYes = true;
        }else{
            isPriorTreatmentYes = false;
        }
    }

    public void rendLeadSourceisFRNAlumniInfo(){
        if(nLead.Lead_Source_is_FRN_Alumni__c=='yes'){
            isLeadSourceisFRNAlumniYes = true;
        }else{
            isLeadSourceisFRNAlumniYes = false;
        }
    }

    /***Who told you about ONLINE search()?????*/
    public String abtValue{get;set;}
    public String searchTerm{get;set;}
    public void toldYouAbout() {
        searchTerm = '';
        abtValue = System.currentPageReference().getParameters().get('about');
        System.debug('abtValue___________________________________'+abtValue);

        if(abtValue != null && abtValue != '') {
            //string tempInput = '%' + abtValue + '%';
            List<Online_Search_Term__c> srch = new List<Online_Search_Term__c>();
            srch = [SELECT Id, Name FROM Online_Search_Term__c WHERE Name =: abtValue LIMIT 1];
                System.debug('SIZE___ '+srch.size()+'  srch___________ '+srch);
                if(srch.size() > 0){
                    for(Online_Search_Term__c O: srch){
                        searchTerm = O.Name;
                    }
                    System.debug('searchTerm_____________________'+searchTerm);

                }   else { System.debug('showSearch_Value_is_not_Valid');}

        } else if(abtValue == null && abtValue == '') {
            searchTerm = ''; System.debug('Not_Getting_the_showSearch_Value');
        }
    }
    public void rendSection(){
        searchTerm = '';
        //nLead.Online_Search_Term__c = '';
        if(nLead.LeadSource == 'Online'){
            rend1 = true;
            rend2 = false;
            rend3 = false;
            rend4 = false;
            rend5 = false ;
        } else if(nLead.LeadSource == 'Professional'){
            rend1 = false;
            rend2 = true;
            rend3 = false;
            rend4 = false;
            rend5 = false ;
        } else if(nLead.LeadSource == 'Friend or Family Member'){
            rend1 = false;
            rend2 = false;
            rend3 = true;
            rend4 = false;
            rend5 = false ;
            if(nLead.Alumni_Referral_Source__c == 'Unknown' && nLead.Lead_Source_is_FRN_Alumni__c=='Yes'){
                rend4 = true;
            }else if(nLead.Alumni_Referral_Source__c == 'Online' && nLead.Lead_Source_is_FRN_Alumni__c=='Yes'){
                rend1 = true;
            }else if(nLead.Alumni_Referral_Source__c == 'Professional' && nLead.Lead_Source_is_FRN_Alumni__c=='Yes'){
                rend2 = true;
            }
        } else if(nLead.LeadSource == 'Unknown' || nLead.LeadSource == 'Alumni Referral Source'){
            rend1 = false;
            rend2 = false;
            rend3 = false;
            rend4 = true;
            rend5 = false ;
        } else if(nLead.LeadSource == 'Alumni'){
            rend1 = false;
            rend2 = false;
            rend3 = false;
            rend4 = false;
            rend5 = true;
        } else {
            rend1 = false ;
            rend2 = false ;
            rend3 = false ;
            rend4 = false ;
            rend5 = false ;
        }
    }

    public void leadCallingFor(){
        if(nLead.Calling_for__c!=null && nLead.Calling_for__c!='Self' && nLead.Relationship_to_Patient__c != null && nLead.Relationship_to_Patient__c != 'Self'){
            isNotSelf = true;
        } else {
            isNotSelf = false;
        }
    }

    public void leadDuplicate(){
        //flagRelated= true;
        String Name='';
        String FName = '';
        String LName = '';
        if(nLead.FirstName != null) {
            Name+= nLead.FirstName;
            FName = nLead.FirstName;
        }
        if(nLead.MiddleName != null) {
            Name = (Name=='') ? Name+nLead.MiddleName : Name+' '+nLead.MiddleName;
        }

        if(nLead.LastName != null){
            Name = (Name=='') ? Name+nLead.LastName : Name+' '+nLead.LastName;
            LName = nLead.LastName;
        }

        Name = Name.trim();
        system.debug('>>> FName : '+FName);
        system.debug('>>> LName : '+LName);
        System.debug('Name'+Name);
        System.debug('nLead.Phone'+nLead.Phone);
        if(leadId!=null){
            URLld = '/apex/LeadDuplicatePage?Id='+leadId+'&LName='+Name+'&LFName='+FName+'&LLName='+LName+'&LPhone='+nLead.Phone+'&LMPhone='+nLead.MobilePhone+'&LWPhone='+nLead.Work_Phone__c+'&onEditMode=true&findDuplicate=lead';
        } else {
            URLld = '/apex/LeadDuplicatePage?LName='+Name+'&LFName='+FName+'&LLName='+LName+'&LPhone='+nLead.Phone+'&LMPhone='+nLead.MobilePhone+'&LWPhone='+nLead.Work_Phone__c+'&onEditMode=true&findDuplicate=lead';
        }
        URLopp = '/apex/MatchingOpportunitiesOnLead?LName='+Name+'&LFName='+FName+'&LLName='+LName+'&LPhone='+nLead.Phone+'&LMPhone='+nLead.MobilePhone+'&LWPhone='+nLead.Work_Phone__c+'&onEditMode=true&findDuplicate=opportunity';
        URLcon = '/apex/MatchingContactWithLead?LName='+Name+'&LFName='+FName+'&LLName='+LName+'&LPhone='+nLead.Phone+'&LMPhone='+nLead.MobilePhone+'&LWPhone='+nLead.Work_Phone__c+'&onEditMode=true&findDuplicate=contact';
        system.debug('>>> URLld  :'+URLld);
        system.debug('>>> URLopp  :'+URLopp);
        system.debug('>>> URLcon  :'+URLcon);
    }

    public void selectedvalue(){
        System.debug('campMWrpList ::>'+campMWrpList);
        System.debug('searchPosition ::>'+searchPosition);
        if(campMWrpList.size()>searchPosition){
            Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
            String acckeyPrefix = r.getKeyPrefix();
            Schema.DescribeSObjectResult r1 = Contact.sObjectType.getDescribe();
            String conkeyPrefix = r1.getKeyPrefix();

            CampaignMemberWrapper wrp = campMWrpList[searchPosition];
            wrp.referralSourceConList.clear();
            wrp.referralSourceList.clear();
            //wrp.cmpM = new    CampaignMember();
            System.debug('wrp ::>'+wrp);
            if(wrp.searchKeyWord != null && wrp.searchKeyWord!=''){
                String accName, accID;
                if(String.valueOf(wrp.searchKeyWord).startsWith(acckeyPrefix)){
                    for(Contact con: [SELECT id,
                                             AccountId,
                                             Account.name,
                                             Name
                                        FROM Contact
                                       WHERE AccountId = :wrp.searchKeyWord AND Currently_Employed__c = TRUE]){
                        wrp.referralSourceConList.add(new SelectOption(con.id, con.name));
                    }
                    for(Account acc: [SELECT id,
                                             Name,
                                             RAM_Lookup__c,
                                             RAM_Lookup__r.Name,
                                             Special_Instructions__c,
                                             High_Priority__c
                                        FROM Account
                                       WHERE Id = :wrp.searchKeyWord]){
                        wrp.referralSourceList.add(new SelectOption(acc.id, acc.name));
                        if(acc.RAM_Lookup__c!=null)
                            wrp.RAMName = acc.RAM_Lookup__r.Name;
                            //wrp.cmpM.RAM_Assigned_to_Referral_Source__c = acc.RAM_Lookup__c;
                            if(acc.High_Priority__c) {
                            wrp.isHighPriority = true;
                            validHighReferralWrp = validateHighPriorityReferralForSpecialInstructions(campMWrpList,searchPosition);
                            if(validHighReferralWrp) {
                                highPriorityCheck = true;
                                highPriorityReferralIndex = searchPosition;
                                highPriorityReferralRank = refralRankStrToRank.get(wrp.cmpM.Referral_Rank__c);
                                specialInstructionsMsg  = acc.Special_Instructions__c;
                            }
                        }
                    }
                }
                if(String.valueOf(wrp.searchKeyWord).startsWith(conkeyPrefix)){
                    for(Contact con: [SELECT id,
                                             AccountId,
                                             Account.Name,
                                             Account.RAM_Lookup__c,
                                             Account.RAM_Lookup__r.Name,
                                             Account.High_Priority__c,
                                             Account.Special_Instructions__c,
                                             Name
                                        FROM Contact
                                       WHERE id = :wrp.searchKeyWord AND Currently_Employed__c = TRUE]){
                        wrp.referralSourceConList.add(new SelectOption(con.id, con.name));
                        accName = con.Account.name;
                        accID = con.AccountId;
                        if(con.Account.RAM_Lookup__c !=null)
                            wrp.RAMName = con.Account.RAM_Lookup__r.Name;
                           // wrp.cmpM.RAM_Assigned_to_Referral_Source__c = con.Account.RAM_Lookup__c;
                        if(accName != '' && accName != null){
                            wrp.referralSourceList.add(new SelectOption(accID,accName));
                            if(con.Account.High_Priority__c  ) {
                                wrp.isHighPriority = true;
                                validHighReferralWrp = validateHighPriorityReferralForSpecialInstructions(campMWrpList,searchPosition);
                                if(validHighReferralWrp) {
                                    highPriorityCheck = true;
                                    highPriorityReferralIndex = searchPosition;
                                    highPriorityReferralRank = refralRankStrToRank.get(wrp.cmpM.Referral_Rank__c);
                                    specialInstructionsMsg  = con.Account.Special_Instructions__c;
                                }
                            }
                        }
                    }

                }
                System.debug('wrp ::>'+wrp);
            }
        }
    }

    @RemoteAction
    public static List<SearchWrapperClass> getSearchResult(String keyTerm){
        System.debug('keyTerm ::>'+keyTerm);
        List<SearchWrapperClass> wrpList = new List<SearchWrapperClass>();

        if(keyTerm!= null && keyTerm.trim()!=''){
            keyTerm = '%'+keyTerm.trim()+'%';
            wrpList.add(new SearchWrapperClass('', 'Referral Source'));
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId();
            Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referral Source Contact').getRecordTypeId();
            List<Account> accList = new List<Account>();
            accList= [Select id,
                            Enabled__c,
                            Name
                     from Account
                     where RecordTypeId =:devRecordTypeId
                     AND Name
                     like :keyTerm
                     AND Enabled__c = TRUE
                                    ];
            if(accList!=null && accList.size()>0){
                for(Account acc:accList){
                    wrpList.add(new SearchWrapperClass(String.valueof(acc.id), acc.name));
                }
            } else {
                wrpList.add(new SearchWrapperClass('', '--No Matches--'));
            }
            System.debug('wrpList ::>'+wrpList);
            wrpList.add(new SearchWrapperClass('', 'Referral Source Contact'));
            List<Contact> conList = [Select id,
                                            Name
                                       from Contact
                                      where Name
                                      like :keyTerm
                                        AND RecordTypeId =:conRecordTypeId
                                        AND Currently_Employed__c = TRUE];
            if(conList!=null && conList.size()>0){
                for(Contact con: conList){
                    wrpList.add(new SearchWrapperClass(String.valueof(con.id), con.name));
                }
            } else {
                wrpList.add(new SearchWrapperClass('', '--No Matches--'));
            }
            System.debug('wrpList ::>'+wrpList);
        }
        System.debug('wrpList ::>'+wrpList);
        return wrpList;
    }


    public class SearchWrapperClass{
        String id,label;
        public SearchWrapperClass(String wrid, String name){
            this.label = name;
            this.id = wrid;
        }
    }

    public class CampaignMemberWrapper{
        public Integer index {get;set;}
        public Referral__c cmpM {get;set;}
        public String RAMName {get;set;}
        public String searchKeyWord {get; set;}
        public String selectedKeyWrp {get; set;}
        public List<SelectOption> referralSourceList {get; set;}
        public List<SelectOption> referralSourceConList {get; set;}
        public List<SelectOption> refOrders {get; set;}
        public Boolean isHighPriority {get; set;}
        public CampaignMemberWrapper(){
            cmpM = new Referral__c();
            referralSourceList = new List<SelectOption>();
            referralSourceConList = new List<SelectOption>();
            refOrders =  new List<SelectOption>();
            isHighPriority = false;
        }
    }

    public void addNewRow(){
        boolean flag ;
        CampaignMemberWrapper newRecord = new CampaignMemberWrapper();
        newRecord.index = campMWrpList.size();
        newRecord.cmpM.Lead__c = leadId;

        Schema.DescribeFieldResult fieldResult = Referral__c.Referral_Rank__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            flag= true;
            for(CampaignMemberWrapper c: campMWrpList){
                if( f.getValue() == c.cmpM.Referral_Rank__c)
                flag= false;
            }
            if(flag){
                newRecord.cmpM.Referral_Rank__c=f.getValue();
                break;
            }
        }

        campMWrpList.add(newRecord);
        referlist();
    }

    public void removeRow(){
        System.debug('PracticeProviderWrpList......'+campMWrpList);
        System.debug('rowToRemove  in removeRowFromPOSList......'+rowToRemove);
        System.debug('cmpM.Referral_Rank__c in removeRowFromPOSList......'+campMWrpList[rowToRemove].cmpM.Referral_Rank__c);

        if(campMWrpList.size()>rowToRemove){

            if(campMWrpList[rowToRemove].cmpM.id != null){
                delete campMWrpList[rowToRemove].cmpM;
            }
            campMWrpList.remove(rowToRemove);
            for(integer i=rowToRemove;i<campMWrpList.size();i++){
                campMWrpList[i].index = i;
            }

            if(highPriorityReferralIndex == rowToRemove && highPriorityCheck == true){
                highPriorityReferralIndex = 0;
                highPriorityCheck =  false;
            }
        }

        referlist();
    }

    public void referlist(){
        String refer = '';
        for(CampaignMemberWrapper c: campMWrpList){
            refer += ' '+c.cmpM.Referral_Rank__c;
        }

        System.debug('current Referral_Rank...... '+refer);
        Schema.DescribeFieldResult fieldResult = Referral__c.Referral_Rank__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(CampaignMemberWrapper c: campMWrpList){
            c.refOrders =  new List<SelectOption>();
            for(Schema.PicklistEntry f : ple){
                if(!refer.contains(f.getValue()) || f.getValue() == c.cmpM.Referral_Rank__c)
                    c.refOrders.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }
    }

    public void hideMessage(){
        isLeadSaved = false;
    }

    public PageReference saveLead(){
        if(nLead.LastName == null || nLead.LastName ==''){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'LastName: You must enter a value');
            apexpages.addmessage(msg);
            return null;
        }
        if(nLead.company == null || nLead.company == ''){
          apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Company: You must enter a value');
          apexpages.addmessage(msg);
                return null;
        }
        saveLeadData();
        PageReference orderPage = new PageReference('/' + nLead.Id);
        orderPage.setRedirect(true);
        return orderPage;
    }

    public void saveAndContinue(){
        isLeadSaved = false;
        if(nLead.LastName == null || nLead.LastName ==''){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'LastName: You must enter a value');
            apexpages.addmessage(msg);
            return;
        }
        if(nLead.company == null || nLead.company == ''){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Company: You must enter a value');
            apexpages.addmessage(msg);
            return;
        }
        saveLeadData();
        isLeadSaved = true;
    }

    public void saveLeadData(){
        nLead.Call_in_Code__c = selectedCallInCode;
        System.debug('nLead>>>>>'+nLead);
        try{
            if(nLead.LeadSource=='Online'){
                nLead.Referral_Source_Unknown_Details__c = null;
                nLead.Alumni_Name__c = null;
                nLead.Alumni_FRN_Facility__c = null;
                deleteReferals();
            } else if(nLead.LeadSource=='Unknown'){
                nLead.Online_Search_Term__c = null;
                nLead.Alumni_Name__c = null;
                nLead.Alumni_FRN_Facility__c = null;
                deleteReferals();
            } else if(nLead.LeadSource == 'Alumni'){
                nLead.Online_Search_Term__c = null;
                nLead.Referral_Source_Unknown_Details__c = null;
                deleteReferals();
            } else if(nLead.LeadSource == 'Professional') {
                nLead.Referral_Source_Unknown_Details__c = null;
                nLead.Alumni_Name__c = null;
                nLead.Alumni_FRN_Facility__c = null;
                nLead.Online_Search_Term__c = null;
            }

            if(nLead.Calling_for__c==null || nLead.Calling_for__c=='Self'){
                nLead.Relationship_to_Patient__c = null;
                nLead.Caller_First_Name__c = null;
                nLead.Caller_Phone__c = null;
                nLead.Caller_Last_Name__c = null;
                nLead.Caller_Mobile__c = null;
                nLead.Caller_Work_Phone__c = null;
                nLead.Caller_Email__c = null;
            } else if(nLead.Relationship_to_Patient__c==null || nLead.Relationship_to_Patient__c=='Self'){
                nLead.Caller_First_Name__c = null;
                nLead.Caller_Phone__c = null;
                nLead.Caller_Last_Name__c = null;
                nLead.Caller_Mobile__c = null;
                nLead.Caller_Work_Phone__c = null;
                nLead.Caller_Email__c = null;
            }
            nLead.Referral_Instruction__c = specialInstructionsMsg;
            nLead = UpdateHighPriorityReferralService.updateLeadHighPriorityCheckBox(nLead);
            upsert nLead;
            System.debug('nLead.Id ::>'+nLead.Id);
            System.debug('nLead.LeadSource ::>'+nLead.LeadSource);
            if(nLead.LeadSource == 'Professional') {
                upsertReferals();
            }
        }catch(Exception e){
            System.debug('Exception on lead upsert ::>'+e);
        }

/***Treatment_History INSERT/DELETE block */
        List<Treatment_History__c> TreatmentHistoryList = new list<Treatment_History__c>();
        if(nLead.Prior_Treatment__c=='Yes'){
            if(TreatmentHistoryWrpList.size()>0){
                for(TreatmentHistoryWrp th:TreatmentHistoryWrpList){
                    Treatment_History__c trtth = th.record;
                    if(trtth.Type__c==null && trtth.Level_of_Care__c==null && trtth.Admit_Date__c==null && trtth.Discharge_Date__c==null)
                        continue;
                    if(th.record.id != null){
                        trtth.id = th.record.id;
                    }
                    trtth.Lead__c = nLead.Id;
                    TreatmentHistoryList.add(trtth);
                }
                upsert TreatmentHistoryList;
            }
        } else {
            for(TreatmentHistoryWrp th:TreatmentHistoryWrpList){
                if(th.record.id != null){
                    TreatmentHistoryList.add(th.record);
                }
            }
            delete TreatmentHistoryList;
        }
    }

    public PageReference saveAndNewLead(){

        if(nLead.LastName == null || nLead.LastName ==''){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'LastName: You must enter a value');
            apexpages.addmessage(msg);
            return null;
        }
        if(nLead.company == null || nLead.company == ''){
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Company: You must enter a value');
            apexpages.addmessage(msg);
            return null;
        }
        system.debug('selectedCallInCode :>' +selectedCallInCode);
        if(selectedCallInCode != null && selectedCallInCode != ''){
            nLead.Call_in_Code__c = selectedCallInCode;
        }
        if(nLead.LeadSource=='Online'){
            nLead.Referral_Source_Unknown_Details__c = null;
            nLead.Alumni_Name__c = null;
            nLead.Alumni_FRN_Facility__c = null;
            deleteReferals();
        } else if(nLead.LeadSource=='Unknown'){
            nLead.Online_Search_Term__c = null;
            nLead.Alumni_Name__c = null;
            nLead.Alumni_FRN_Facility__c = null;
            deleteReferals();
        } else if(nLead.LeadSource == 'Alumni'){
            nLead.Online_Search_Term__c = null;
            nLead.Referral_Source_Unknown_Details__c = null;
            deleteReferals();
        } else if(nLead.LeadSource == 'Professional') {
            nLead.Referral_Source_Unknown_Details__c = null;
            nLead.Alumni_Name__c = null;
            nLead.Alumni_FRN_Facility__c = null;
            nLead.Online_Search_Term__c = null;
        }

        if(nLead.Calling_for__c==null || nLead.Calling_for__c=='Self'){
            nLead.Relationship_to_Patient__c = null;
            nLead.Caller_First_Name__c = null;
            nLead.Caller_Phone__c = null;
            nLead.Caller_Last_Name__c = null;
            nLead.Caller_Mobile__c = null;
            nLead.Caller_Work_Phone__c = null;
            nLead.Caller_Email__c = null;
        } else if(nLead.Relationship_to_Patient__c==null || nLead.Relationship_to_Patient__c=='Self'){
            nLead.Caller_First_Name__c = null;
            nLead.Caller_Phone__c = null;
            nLead.Caller_Last_Name__c = null;
            nLead.Caller_Mobile__c = null;
            nLead.Caller_Work_Phone__c = null;
            nLead.Caller_Email__c = null;
        }

        Upsert nLead;
        if(nLead.LeadSource == 'Professional') {
            upsertReferals();
        }
        if(nLead.Prior_Treatment__c=='Yes'){
            List<Treatment_History__c> TreatmentHistoryList = new list<Treatment_History__c>();
            if(TreatmentHistoryWrpList.size()>0){
                for(TreatmentHistoryWrp th:TreatmentHistoryWrpList){
                    Treatment_History__c trtth = th.record;
                    if(trtth.Type__c==null && trtth.Level_of_Care__c==null && trtth.Admit_Date__c==null && trtth.Discharge_Date__c==null)
                        continue;
                    if(th.record.id != null){
                        trtth.id = th.record.id;
                    }
                    trtth.Lead__c = nLead.Id;
                    TreatmentHistoryList.add(trtth);
                }
                upsert TreatmentHistoryList;
            }
        }

        PageReference pageRef = Page.NewLeadPage;
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void deleteReferals(){
        List<Referral__c> refList = new List<Referral__c>();
        for(CampaignMemberWrapper cmpWrp:campMWrpList){
            if(cmpWrp.cmpM.id != null){
                refList.add(cmpWrp.cmpM);
            }
        }

        if(refList.size()>0){
            delete refList;
        }
    }

    public void upsertReferals(){
        List<Referral__c> refList = new List<Referral__c>();
        Referral__c rf ;
        for(CampaignMemberWrapper cmpWrp:campMWrpList){
            rf = new Referral__c();
            if(cmpWrp.cmpM.Account__c!=null){
            String patientName = '';

            if(cmpWrp.cmpM.id != null){
                rf.id = cmpWrp.cmpM.id;
            }
            rf.Lead__c = nLead.Id;

            rf.Account__c = cmpWrp.cmpM.Account__c;

            if(cmpWrp.cmpM.Consentor__c!=null){
                rf.Consentor__c = cmpWrp.cmpM.Consentor__c;
            }
            if(cmpWrp.cmpM.Referral_Rank__c!=null){
                rf.Referral_Rank__c = cmpWrp.cmpM.Referral_Rank__c;
            }
            System.debug('nLead.Call_In_Code__c ::>'+nLead.Call_In_Code__c);
            if(nLead.Call_In_Code__c != null ){
                 rf.Call_In_Code__c = listCIC.get(nLead.Call_In_Code__c).Id;
            }
            //rf.Search_Term__c = nLead.Online_Search_Term__c;
            if(nLead.FirstName!=null){
                patientName = nLead.FirstName +' ';
            }
            /* if(nLead.MiddleName!=null){
                patientName += nLead.MiddleName +' ';
            } */
            System.debug('last Name..>'+nLead.LastName.charAt(0));
            patientName += nLead.LastName.substring(0,1);
            rf.Patient_Name__c = patientName;
            rf.City__c = nLead.City;
            rf.State__c = nLead.State;
            rf.RecordTypeId = refRecId;
            rf.Referral_Stage__c = 'Open';
            refList.add(rf);
            }

            System.debug('refList....>'+refList);
        }

        if(refList.size()>0){
            upsert refList;
        }
    }

    public PageReference cancel(){
        String leadKeyPrefix = Lead.sObjectType.getDescribe().getKeyPrefix();
        PageReference page;
        if(nLead.Id!=null){
            page = new PageReference('/' + nLead.Id);
        } else {
            page = new pageReference('/'+leadKeyPrefix+'/o');
        }
        return page;
    }


    //Wrapper class for Treatment History Object
    public class TreatmentHistoryWrp{
        public Integer index {get;set;}
        public Treatment_History__c record {get;set;}
        public TreatmentHistoryWrp(){
            record = new Treatment_History__c();
        }
    }

    //Add New row to the Treatment_History__c related list
    public void addNewTreatmentHistoryObj(){
        TreatmentHistoryWrp newRecord = new TreatmentHistoryWrp();
        Treatment_History__c newTreatmentHistory = new Treatment_History__c();
        newRecord.record = newTreatmentHistory;
        newRecord.index = TreatmentHistoryWrpList.size()-1;
        if(newRecord.index>=0){
            Treatment_History__c oldLORecord = TreatmentHistoryWrpList[newRecord.index].record;
        }
        TreatmentHistoryWrpList.add(newRecord);
    }

    //Delete one row from the Treatment_History__c Related List
    public void removeRowToTreatmentHistoryList(){
        Treatment_History__c objTthDel = TreatmentHistoryWrpList[rowToRemove].record;
        if(TreatmentHistoryWrpList.size() == 1){
            if(objTthDel.id!=null)
                delete objTthDel;

            objTthDel = new Treatment_History__c();
            TreatmentHistoryWrp newRecord = new TreatmentHistoryWrp();
            newRecord.record = objTthDel;
            TreatmentHistoryWrpList[rowToRemove] = newRecord;
        }else{
            if(objTthDel.id!=null){
                delete objTthDel;
            }
            TreatmentHistoryWrpList.remove(rowToRemove);
        }
    }


    public Boolean validateHighPriorityReferralForSpecialInstructions(List<CampaignMemberWrapper> pReferWrpList, Integer referralIndex) {
        Boolean  validatHighReferral = false;
        CampaignMemberWrapper referalWraperInstance = campMWrpList[referralIndex];
        if(pReferWrpList.size() == 1) {
            return true;
        }else {
            for(CampaignMemberWrapper refwraperItr : pReferWrpList) {
                if(refralRankStrToRank.get(referalWraperInstance.cmpM.Referral_Rank__c) >  refralRankStrToRank.get(refwraperItr.cmpM.Referral_Rank__c)
                 && highPriorityCheck == true) {
                    return false;
                }
                else {
                    return true;
                }
            }
        }
        return validatHighReferral;
    }
}