public class CreateOpportunityExt{

    // Constants
    public static final String IOP_RECORDTYPE = 'IOP';

    public String finalName {get;set;}
    public Opportunity opp {get;set;}
    public String oppId{get;set;}
    public boolean oppInEditMode{get;set;}
    public String getretURL;
    public Integer searchPosition{get;set;}
    public List<ReferralWrapper> ReferWrpList{get;set;}
    public List<Clinical_Assessment__c> caList{get;set;}
    public List<AbusedSubstanceWrp> absSubsWrpList {get;set;}
    public List<PsychiatricTHWrp> pTHWrpList {get;set;}
    public List<MedicalProblemSymWrp> mPSWrpList {get;set;}
    public List<IllnessInjuryWrp> iiWrpList {get;set;}
    public List<PrescriptionMediWrp> pmWrpList {get;set;}
    public List<MentalHealthSWrp> mhsWrpList {get;set;}
    public List<PsychiatricDiagnosesWrp> pdWrpList {get;set;}
    public List<LegalOffensesWrp> loWrpList {get;set;}
    public List<ClinicalAssessmentsWrp> caWrpList {get;set;}
    public List<SubstanceAHFWrp> sahfWrpList {get;set;}
    public List<PatientContactsWrp> pcWrpList {get;set;}
    public List<MedicalEquipmentWrp> meWrpList {get;set;}
    public List<PatientInsuranceWrp> piWrpList {get;set;}
    public List<InfectiousDiseasesWrp> idWrpList {get;set;}
    public List<MajorMedicalIssuesWrp> mmiWrpList {get;set;}
    public String refRecId;
    public List<PayAgreementWorksheetsWrp> PayAgreementWorksheetWrpList {get;set;}
    public list<Treatment_History__c> pthList{get;set;}
    public List<CaseWrp> CaseWrpList {get;set;}
    public List<ReferralWrp> ReferralWrpList {get;set;}
    public List<TripWrp> TripWrpList {get;set;}
    public List<NoteCommentWrp> NoteCommentWrpList {get;set;}
    public List<QuotesWrp> QuotesWrpList {get;set;}
    public Integer rowToRemove {get;set;}
    public Integer rowToEdit {get;set;}
    public transient Map<String, Decimal> probabilityStageNameMap;
    public String recordTypeName{get;set;}
    public String dispRecTypeName{get;set;}
    public String loggedinUserName {get;set;}
    public String displayOpptyName {get;set;}
    public String localtimeinString = '';
    public String OppName;
    public boolean opName ;
    public boolean showForReferal{get;set;}
    public boolean showForOutPatient{get;set;}
    public boolean showForOthers{get;set;}
    public boolean showForReferalFields{get;set;}
    public boolean showForNoteCommentFields{get;set;}
    public boolean showForOutPatientFields{get;set;}
    public String usrName {get;set;}
    public boolean rend1 {get;set;}
    public boolean rend2 {get;set;}
    public Boolean displayPopup {get;set;}
    public boolean showForResidentialTreatment {get;set;}
    public boolean isHeightNull {get;set;}
    public boolean isWeightNull {get;set;}
    public Abused_Substance__c sub{get;set;}
    public Patient_Contact__c patcon{get;set;}
    public Patient_Insurance__c patIns{get;set;}
    public Clinical_Assessment__c cliAss {get;set;}
    public boolean showForAbusedIns{get;set;}
    public boolean isForUpdate{get;set;}
    public Contact con{get;set;}
    public String Selectedsubscriber{get;set;}
    public String patconEmployer{get;set;}
    public boolean isFromPatIns {get;set;}
    public Set<String> resCrtdPatConIds;
    public Integer conAge {get;set;}
    public boolean redBoolead{get;set;}
    public integer patConCounter;
    public boolean isContactNull {get;set;}
    public boolean isOpportunitySaved {get;set;}
    public String baseURL {get;set;}
    public boolean onlyEdit {get;set;}
    public boolean rend3 {get;set;}
    public boolean rend4 {get;set;}
    public boolean rend5 {get;set;}
    public boolean rend6 {get;set;}
    public boolean rend7 {get;set;}
    public String abtValue{get;set;}
    public String searchTerm{get;set;}
    public String selectedRecordType;
    public boolean IOIC{get;set;}
    public String specialInstructionsMsg {get; set;}
    public Boolean highPriorityCheck {get; set;}
    public Integer highPriorityReferralRank;
    public Integer highPriorityReferralIndex {get; set;}
    public Boolean validHighReferralWrp {get; set;}
    public Integer rankPosition{get;set;}
    public List<Document__c> docList;
    public Map<String, Integer> refralRankStrToRank = new Map<String, Integer>{'Primary' => 1,
                                                                               'Secondary' => 2,
                                                                               'Tertiary' => 3,
                                                                               'Other' => 4
                                                                               };
    public static Id opportunityId;
    public Boolean hasErrors {get{
        return ApexPages.hasMessages();
    }}
    public Boolean isFromQualityReport;

    /*
    * opportunity stage
    */

    public String stageValue{get;set;}
    public String fRNFacilityValue {get;set;}

    public CreateOpportunityExt(ApexPages.StandardController controller){
        isFromQualityReport = false;
        specialInstructionsMsg = '';
        highPriorityCheck = false;
        validHighReferralWrp = false;
        highPriorityReferralRank = 99;
        highPriorityReferralIndex = 0;
        finalName='';
        IOIC = false;
        onlyEdit = false;
        baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        ReferWrpList = new List<ReferralWrapper>();
        conAge = 0;
        showForAbusedIns = false;
        isForUpdate = false;
        redBoolead = false;
        oppInEditMode = false;
        showForReferal = false;
        isHeightNull = false;
        isWeightNull = false;
        showForOthers = false;
        showForOutPatient = false;
        showForReferalFields = false;
        showForNoteCommentFields = false;
        showForOutPatientFields = false;
        displayPopup  = false;
        rend1 = false;
        rend2 = false;
        rend3 = false;
        rend4 = false;
        rend5 = false;
        rend6 = false;
        rend7 = false;
        isFromPatIns = false;
        isContactNull = false;
        patconEmployer = '';
        showForResidentialTreatment = false;
        isOpportunitySaved = false;
        localtimeinString = System.now().format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
        opName = false;
        opp = new Opportunity();
        con = new Contact();
        patConCounter = 0;
        resCrtdPatConIds = new Set<String>();
        If(opp.ownerId =='' || opp.ownerId == null){
            opp.ownerId = UserInfo.getUserId();
        }
        oppId = ((Opportunity)controller.getRecord()).id;
        getretURL = ApexPages.currentPage().getParameters().get('retURL');
        if(ApexPages.currentPage().getParameters().containsKey('showQualityReport'))
            isFromQualityReport = boolean.valueOf(ApexPages.currentPage().getParameters().get('showQualityReport'));
        selectedRecordType = ((Opportunity)controller.getRecord()).RecordTypeId;

        absSubsWrpList = new List<AbusedSubstanceWrp>();
        pTHWrpList = new List<PsychiatricTHWrp>();
        mPSWrpList = new List<MedicalProblemSymWrp>();
        iiWrpList = new List<IllnessInjuryWrp>();
        pmWrpList = new List<PrescriptionMediWrp>();
        mhsWrpList = new List<MentalHealthSWrp>();
        pdWrpList = new List<PsychiatricDiagnosesWrp>();
        loWrpList = new List<LegalOffensesWrp>();
        caWrpList = new List<ClinicalAssessmentsWrp>();
        sahfWrpList = new List<SubstanceAHFWrp>();
        pcWrpList = new List<PatientContactsWrp>();
        meWrpList = new List<MedicalEquipmentWrp>();
        piWrpList = new List<PatientInsuranceWrp>();
        mmiWrpList = new List<MajorMedicalIssuesWrp>();
        idWrpList = new List<InfectiousDiseasesWrp>();
        ReferralWrpList = new List<ReferralWrp>();
        QuotesWrpList = new List<QuotesWrp>();
        CaseWrpList = new List<CaseWrp>();
        TripWrpList = new List<TripWrp>();
        NoteCommentWrpList = new List<NoteCommentWrp>();
        PayAgreementWorksheetWrpList = new List<PayAgreementWorksheetsWrp>();
        sub = new Abused_Substance__c();
        patcon = new Patient_Contact__c();
        patIns = new Patient_Insurance__c();
        cliAss = new Clinical_Assessment__c();
        //opportunityId = oppId;

        String[] s;
        if(getretURL != null && getretURL.length()>14){
            if(getretURL.contains('?')){
                String[] extraValue = getretURL.split('\\?');
                getretURL = extraValue[0];
            }
            s = getretURL.split('/');
            getretURL=s[1];
        }

        refRecId = Schema.Sobjecttype.Referral__c.getRecordTypeInfosByName().get('Inbound Referral').getRecordTypeId();

        if(oppId!=null && oppId!='') {
            ReferralWrapper cmpWrp;
            for(Referral__c cmpMW:[Select Id,Opportunity__c,Account__c,Account__r.name,Consentor__c,Consentor__r.Currently_Employed__c,Consentor__r.name, Referral_Rank__c,RAM_Assigned__c,RAM_Lookup__c from Referral__c WHERE Opportunity__c =:oppId AND RecordTypeId =:refRecId]){
                cmpWrp = new ReferralWrapper();
                cmpWrp.index = ReferWrpList.size();
                cmpWrp.cmpM = cmpMW;
                if(cmpMW.Account__c !=null)
                cmpWrp.referralSourceList.add(new SelectOption(cmpMW.Account__c,cmpMW.Account__r.Name));
                if(cmpMW.Consentor__c!=null && cmpMW.Consentor__r.Currently_Employed__c == TRUE)
                cmpWrp.referralSourceConList.add(new SelectOption(cmpMW.Consentor__c, cmpMW.Consentor__r.Name));
                ReferWrpList.add(cmpWrp);
            }
        }

        if(ReferWrpList.size()==0){
            addNewRow();
        }

        if(ReferWrpList.size()>0){
            referlist();
        }

        populateRecordTypeInfo();

        String conPrefix = Contact.sObjectType.getDescribe().getKeyPrefix();
        if(getretURL!= null && getretURL.length()>14 && getretURL.startsWith(conPrefix)){
            opp.Contact__c = getretURL;
        /***AC/RAM assigned functionality
        */
            User u = new User();
            u = [
                select Id
                     , Update_AC_Assigned_on_Opportunity__c
                     , Update_RAM_Assigned_on_Opportunity__c
                     , Username
                  from User
                 where Id =: UserInfo.getUserId()
                   AND IsActive =: true
            ];

            if ( u.Update_AC_Assigned_on_Opportunity__c== true && !IOP_RECORDTYPE.equalsIgnoreCase(recordTypeName) ) {
                opp.AC_Assigned__c=u.Id;
            }

            if(u.Update_RAM_Assigned_on_Opportunity__c== true && !IOP_RECORDTYPE.equalsIgnoreCase(recordTypeName) ){
                opp.RAM_Assigned__c=u.Id;
            }
        }

        opp.StageName = 'Prospecting';
        opp.Probability = 10.00;
        opp.CloseDate = system.today().addDays(10);
        loggedinUserName = Userinfo.getName();
        if(oppId!=null){
            onlyEdit = true;
            caList = [SELECT Id,Name FROM Clinical_Assessment__c WHERE Opportunity__c =: oppId];
            opp = [
                SELECT AccountId
                     , RAM_Status__c
                     , Benefits_Status__c
                     , Close_Reason__c
                     , Account.Name
                     , Ongoing_Medical_Issues_or_Conditions__c
                     , Scratchpad__c
                     , Amount
                     , Opportunity_Age__c
                     , Are_You_Able_to_Travel_Alone__c
                     , Are_You_Able_to_Walk_a_Mile__c
                     , Are_You_Able_to_Walk_Up_Down_Stairs__c
                     , Are_You_Able_to_Walk_on_Rugged_Terrain__c
                     , CampaignId,Clinical_Collected_from__c
                     , CloseDate,ConcurConnect__AccruedUnApprovedExpenses__c
                     , Ready_to_Make_Commitment__c
                     , ConcurConnect__AccruedUnApprovedExpenseTotal__c
                     , ConcurConnect__FinalExpenseTotal__c
                     , ConcurConnect__FinalExpense__c
                     , Contact__c
                     , Contact__r.Name
                     , Contact__r.FirstName
                     , Contact__r.LastName
                     , Contact__r.Social_Security_Number__c
                     , Contact__r.Preferred_Method_of_Contact__c
                     , Contact__r.Birthdate
                     , Contact__r.MailingCity
                     , Contact__r.MailingState
                     , Contributing_Factors__c
                     , CreatedById
                     , CreatedDate
                     , Currently_Enrolled_at_FRN_IOP_Facility__c
                     , Online_Search_Term__c
                     , Current_FRN_IOP_Facility__c
                     , Current_Thoughts_of_Attempting_Suicide__c
                     , Customer_Note__c,Call_in_Code__c
                     , Describe_Domestic_Violence_Situation__c
                     , Describe_Hit_Harm_Situation__c
                     , Describe_Suicide_Thoughts__c
                     , Description,Description_of_Suicide_Attempt__c
                     , Description_of_Suicide_Plan__c
                     , Did_Cut_Burn_Require_Medical_Attention__c
                     , Referral_Source_Unknown_Details__c
                     , Do_You_Have_a_Cutting_Burning_Plan__c
                     , Do_You_Have_a_Suicide_Plan__c
                     , Eating_Disorder_Treatment_Facility__c
                     , Family_Hx_of_Mental_Health__c
                     , Family_Hx_of_Substance_Abuse__c
                     , Fiscal
                     , FiscalQuarter
                     , FiscalYear
                     , ForecastCategory
                     , ForecastCategoryName
                     , Frequency_of_Cutting_Burning__c
                     , geopointe__Geocode__c
                     , HasOpenActivity
                     , HasOpportunityLineItem
                     , HasOverdueTask
                     , Have_You_Attended_Anger_Mgmt_Class__c
                     , Have_you_Been_Clean_Sober__c
                     , Have_You_Ever_Attempted_Suicide__c
                     , Have_You_Ever_Purged_or_Forced_Throw_Up__c
                     , Alumni_Referral_Source__c
                     , Have_You_Had_Thoughts_of_Harming_Others__c
                     , Have_You_Physically_Hit_Harmed_Anyone__c
                     , Have_You_Seen_a__c
                     , Have_You_Suffered_from_Binge_Eating__c
                     , Height_ft_in__c,Id,Impact_on_Relationships__c
                     , Intention_Fear_of_Suicide__c
                     , Involved_in_Domestic_Violence__c
                     , IOP_Staff_Referred_to_Admissions_Center__c
                     , IsClosed
                     , IsDeleted
                     , IsExcludedFromTerritory2Filter
                     , IsWon
                     , LastActivityDate
                     , LastModifiedById
                     , LastModifiedDate
                     , LastReferencedDate
                     , LastViewedDate
                     , Last_Cut_Burn_Date__c
                     , Last_Purged_Date__c
                     , LeadSource,Length_of_Time_Clean_Sober__c
                     , Length_of_Time_Purging__c
                     , Length_of_Time_Starving__c
                     , Chat_Email_Transcript__c
                     , Length_of_Time_Using_Laxatives__c
                     , Level_of_Committment__c
                     , Most_Recent_Attempt_Date__c
                     , Name
                     , Needs_Assessment__c
                     , NextStep
                     , Non_Sober_Scary_Behavior__c
                     , Number_of_Suicide_Attempts__c
                     , Occupation__c
                     , OwnerId
                     , Owner.Name
                     , Patient_Currently_Working__c
                     , Payment__c,Pricebook2Id
                     , Prior_PT_at_FRN_Residential_Treatment__c
                     , Prior_Treatment__c
                     , Probability
                     , Professional_License__c
                     , Purge_Frequency__c
                     , Purposely_Cut_or_Burned_Yourself__c
                     , Purposely_Starved_or_Restricted_Food__c
                     , Readmit__c
                     , Reason_for_No_Withdrawal_Symptom__c
                     , Reason_for_Seeking_Help__c
                     , RecordTypeId
                     , RecordType.Name
                     , RecordType.DeveloperName
                     , Relapse_Date__c
                     , Relationship_to_Patient__c
                     , Sober_Support__c
                     , StageName
                     , Suicide_Attempt_Additional_Notes__c
                     , SyncedQuoteId
                     , SystemModstamp
                     , Territory2Id
                     , Timeframe_of_Impact__c
                     , Travel_Restrictions__c
                     , Trigger__c
                     , Type
                     , Type__c
                     , Under_Influence_at_Time_of_Attempt__c
                     , Under_Influence_while_Cutting_Burning__c
                     , Upcoming_Court_Dates__c,Use_of_Laxatives_for_Weight_Loss__c
                     , Vision_of_Future_without_Treatment__c
                     , Weight_lbs__c
                     , Were_You_Under_the_Influence__c
                     , What_Prompted_Call__c
                     , When_Were_You_Clean_Sober__c
                     , Who_Were_You_Thinking_of_Hurting__c
                     , Withdrawal_Symptoms__c
                     , Work_or_School_Problems__c
                     , AC_Assigned__c
                     , RAM_Assigned__c
                     , VOB_Assigned__c
                     , Lead_Source_is_FRN_Alumni__c
                     , Original_Lead_Owner__c
                     , Referral_Source_is_RAM_Account__c
                     , FRN_Facility_of_Interest__c
                     , Happiness_Scale__c
                     , Patient_Willing_to_Receive_Treatment__c
                     , Important_Admission_Notes__c
                     , Do_You_Have_a_Legal_Guardian__c
                     , Legal_Guardian_First_Name__c
                     , Legal_Guardian_Last_Name__c
                     , Attempted_Suicide_Methods__c
                     , Pending_Admission_Date__c
                     , Admission_Date__c
                     , Final_Quote_Selected__c
                     , FRN_Facility_Selected__c
                     , Refer_Out_Reason__c
                     , Cutting_Burning_Plan_Details__c
                     , Binge_Eating_Comments__c
                     , Caller_Id__c
                     , Alumni_Name__c
                     , Frequency_of_Blackouts__c
                     , Alumni_FRN_Facility__c
                     , Most_Recent_FRN_Facility__c
                     , Description_of_Average_Day__c
                     , Diagnosed_with_Psychiatric_Condition__c
                     , Impact_on_Job__c
                     , Estimated_Date_and_Time_of_Arrival__c
                     , Sober_Living_Selected__c
                     , Sober_Living_Facility__c
                     , Step_Down__c
                     , Last_Starved_Restricted_Date__c
                     , Starved_Restricted_Frequency__c
                     , Laxative_Use_Frequency__c
                     , Last_Binge_Eating_Date__c
                     , Last_Laxative_Use_Date__c
                     , Binge_Eating_Frequency__c
                     , Transferring_Facility__c
                     , Patient_Currently_Incarcerated__c
                     , Needs_Score_Recalculation__c
                     , IOP_Notes__c
                     , Patient_experienced_prior_legal_offense__c
                     , Does_patient_have_prescribed_medications__c
                     , Patient_suffered_from_illness_or_injury__c
                     , Pt_Diagnosed_with_Psychiatric_Condition__c
                     , Budget__c
                     , (select id from Documents__r where category__c = 'Referral Documents')
                  FROM Opportunity
                 WHERE Id=:oppId
                 LIMIT 1
            ];

            localtimeinString = opp.CreatedDate.format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
            opportunityId = opp.Id;
            if(opp.RecordType.Name == 'Residential Treatment'){
                recordTypeName = 'RTC';
            } else if(opp.RecordType.Name == 'Outpatient Treatment'){
                recordTypeName = IOP_RECORDTYPE;
            } else if(opp.RecordType.Name == 'Refer Out Only'){
                recordTypeName = 'ROO';
            }
            if(!opp.Documents__r.isEmpty()) {
                docList = opp.Documents__r;
            }
            finalName = getContactName(opp);

            oppInEditMode = true;
            showOpptyName();
            dispRecTypeName = opp.RecordType.Name;
            loggedinUserName = opp.Owner.Name;
            displayOpptyName = opp.Name;
            fRNFacilityValue = opp.Most_Recent_FRN_Facility__c;
            //Query for child Abused_Substance__c
            List<Abused_Substance__c> absSubsList = [Select Id,Opportunity__c,Substance__c,Date_of_Last_Use__c,Age_of_First_Use__c,Average_Amount_of_Use__c,Additional_Notes__c,Frequency__c,Method_of_Use__c,Duration_of_Current_Episode_of_Use__c,Stop_Long_Enough_to_Withdrawal__c,Overdosed_on_this_Substance__c,Hospitalized_for_Overdose__c,Number_Times_Overdosed_on_this_Substance__c,Were_Any_Overdoses_Intentional__c,Most_Recent_Overdosed_Date__c,Explanation_of_Intentional_Overdose__c,Number_of_Blackouts_from_Substance__c from Abused_Substance__c WHERE Opportunity__c =:oppId];
            AbusedSubstanceWrp absWrp;
            for(Abused_Substance__c abs:absSubsList){
                absWrp = new AbusedSubstanceWrp();
                abs.Patient__c = opp.Contact__c;
                absWrp.record = abs;
                absWrp.index = absSubsWrpList.size();
                absSubsWrpList.add(absWrp);

            }

            //Query for child Treatment_History__c
            pthList = [Select Id,Opportunity__c,Type__c,Level_of_Care__c,Admit_Date__c,Discharge_Date__c,Other_Facility__c,Was_Treatment_Involuntary__c from Treatment_History__c WHERE Opportunity__c =:oppId];
            PsychiatricTHWrp pthWrp;
            for(Treatment_History__c pth:pthList){
                pthWrp = new PsychiatricTHWrp();
                pthWrp.record = pth;
                pthWrp.index = pTHWrpList.size()-1;
                pTHWrpList.add(pthWrp);
            }

            //Query for child Medical_Problem_Symptom__c
            List<Medical_Problem_Symptom__c> mpsList = [Select Id,Opportunity__c,Last_Doctor_Visit_Date__c,Follow_up_Recommended__c,Problem__c,Symptoms__c,Patient__c from Medical_Problem_Symptom__c WHERE Opportunity__c =:oppId];
            MedicalProblemSymWrp mpsWrp;
            for(Medical_Problem_Symptom__c mps:mpsList){
                mpsWrp = new MedicalProblemSymWrp();
                mpsWrp.record = mps;
                mpsWrp.record.Patient__c = opp.Contact__c;
                mpsWrp.index = mPSWrpList.size()-1;
                mPSWrpList.add(mpsWrp);
            }

            //Query for child Illness_Injury__c
            List<Illness_Injury__c> iiList = [SELECT Id, Opportunity__c, Illness_Injury__c, Description__c, Surgeries_or_Hospitalizations__c, Surgery_or_Hospitalization_Description__c, Surgery_or_Hospitalization_Date__c, Were_Follow_up_Appointments_Scheduled__c, Did_You_Go_to_Follow_up_Appointments__c FROM Illness_Injury__c
            WHERE Opportunity__c =:oppId];
            IllnessInjuryWrp iiWrp;
            for(Illness_Injury__c ii:iiList){
                iiWrp = new IllnessInjuryWrp();
                iiWrp.record = ii;
                iiWrp.index = iiWrpList.size()-1;
                iiWrpList.add(iiWrp);
            }

            //Query for child Prescription_Medication__c
            List<Prescription_Medication__c> pmList = [Select Id,Opportunity__c,Amount_Abused__c,Currently_Abusing_Substance__c,Indication__c,Prescribed_Dosage__c,Medication__c,Medication__r.Is_Other_Medication__c,Frequency__c  from Prescription_Medication__c WHERE Opportunity__c =:oppId];
            PrescriptionMediWrp pmWrp;
            for(Prescription_Medication__c mps:pmList){
                pmWrp = new PrescriptionMediWrp();
                pmWrp.record = mps;
                pmWrp.record.Patient__c = opp.Contact__c;
                pmWrp.index = pmWrpList.size()-1;
            if(mps.Medication__r.Is_Other_Medication__c == true){
             pmWrp.isMedicationOther = true;
            }else{
             pmWrp.isMedicationOther = false;
            }
                        pmWrpList.add(pmWrp);
                    }

            //Query for child Mental_Health_Symptom__c
            List<Mental_Health_Symptom__c> mhsList = [Select Id,Opportunity__c,Description__c,Patient__c from Mental_Health_Symptom__c WHERE Opportunity__c =:oppId];
            MentalHealthSWrp mhsWrp;
            for(Mental_Health_Symptom__c mhs:mhsList){
                mhsWrp = new MentalHealthSWrp();
                mhsWrp.record = mhs;
                mhsWrp.index = mhsWrpList.size()-1;
                mhsWrpList.add(mhsWrp);
            }

            //Query for child Psychiatric_Diagnosis__c
            List<Psychiatric_Diagnosis__c> pdList = [Select Id,Opportunity__c,Date_of_Diagnosis__c,Diagnosed_By__c,Diagnosis__c,Patient__c from Psychiatric_Diagnosis__c WHERE Opportunity__c =:oppId];
            PsychiatricDiagnosesWrp pdWrp;
            for(Psychiatric_Diagnosis__c pd:pdList){
                pdWrp = new PsychiatricDiagnosesWrp();
                pdWrp.record = pd;
                pdWrp.record.Patient__c = opp.Contact__c;
                pdWrp.index = pdWrpList.size()-1;
                pdWrpList.add(pdWrp);
            }

            //Query for child Legal_Offense__c
            List<Legal_Offense__c> loList = [Select Id,Opportunity__c,Circumstances__c,Date__c,On_Parole__c,On_Probation__c,Registered_Sex_Offender_List__c,Type__c  from Legal_Offense__c WHERE Opportunity__c =:oppId];
            LegalOffensesWrp loWrp;
            for(Legal_Offense__c lo:loList){
                loWrp = new LegalOffensesWrp();
                loWrp.record = lo;
                loWrp.index = loWrpList.size()-1;
                loWrpList.add(loWrp);
            }

            //Query for child Clinical_Assessment__c
            ClinicalAssessmentsWrp raWrp;
            for(Clinical_Assessment__c ca:[select id,Source_s_of_Information__c,Other_Source_s_of_Information__c,Relationship_to_Patient__c,Caller_Home_Phone__c,   Caller_Mobile__c,Caller_First_Name__c,Caller_Last_Name__c,Call_Date_Time__c,Legal_Status__c,RecordTypeId,Caller_Work_Phone__c,Employer_School__c,Employer_School_Phone__c,Smoker__c,Has_a_Vehicle__c,Marital_Status__c,Number_of_Children__c,Children_s_Ages__c,Opportunity__c from Clinical_Assessment__c where Opportunity__c =: oppId]){
                raWrp = new ClinicalAssessmentsWrp();
                raWrp.record = ca;
                caWrpList.add(raWrp);
            }

            //Query for child Substance_Abuse_History_and_Frequency__c
            List<Substance_Abuse_History_and_Frequency__c> sahfList = [Select Id,Opportunity__c,Cigarettes_Tobacco_Amount__c,Alcohol_Amount__c,Marijuana_Amount__c,Opiates_Amount__c from Substance_Abuse_History_and_Frequency__c WHERE Opportunity__c =:oppId];
            SubstanceAHFWrp sahfWrp;
            for(Substance_Abuse_History_and_Frequency__c ra:sahfList){
                sahfWrp = new SubstanceAHFWrp();
                sahfWrp.record = ra;
                sahfWrp.index = sahfWrpList.size()-1;
                sahfWrpList.add(sahfWrp);
            }

            //Query for child Patient_Contact__c
            List<Patient_Contact__c> pcList = [Select Id,Opportunity__c,First_Name__c,Last_Name__c,Preferred_Contact_Method__c,Relationship__c,Primary_Contact__c,Social_Security_Number__c,Employment_Status__c,Employer__c,Mobile_Phone__c,Phone__c,Email__c,Work_Phone__c,Other_Phone__c,Street__c,City__c,State__c,Zip_Postal_Code_c__c, DOB__c from Patient_Contact__c WHERE Opportunity__c =:oppId];
            PatientContactsWrp pcWrp;
            for(Patient_Contact__c ra:pcList){
                pcWrp = new PatientContactsWrp();
                pcWrp.record = ra;
                pcWrp.index = pcWrpList.size();
                pcWrp.UniqueNmbr = patConCounter++;
                pcWrpList.add(pcWrp);
            }

            //Query for child Medical_Equipment__c
            List<Medical_Equipment__c> meList = [Select Id,Opportunity__c,Currently_Using_Equipment__c,Are_You_Able_to_Walk_Up_Down_Stairs__c,Are_You_Able_to_Walk_a_Mile__c,Are_You_Able_to_Walk_on_Rugged_Terrain__c  ,Details__c,Equipment_Type__c,Contact__c,Patient__c from Medical_Equipment__c WHERE Opportunity__c =:oppId];
            MedicalEquipmentWrp meWrp;
            for(Medical_Equipment__c ra:meList){
                meWrp = new MedicalEquipmentWrp();
                meWrp.record = ra;
                meWrp.index = meWrpList.size()-1;
                meWrpList.add(meWrp);
            }

            //Query for child Patient_Insurance__c
            List<Patient_Insurance__c> piList = [SELECT ACA_Policy__c,Opportunity__c,Patient__c,Patient__r.FirstName,Patient__r.LastName,Patient_Social_Security_Number__c,Name,Member_ID__c,Phone__c,Subscriber__c,Subscriber__r.First_Name__c, Subscriber__r.Last_Name__c, Type_Order__c,Subscriber_is_Patient__c,Benefits_Check__c,Insurance_Plan__c,Insurance_Company__c,Provider_Services_Phone__c,Behavioral_Health_Phone__c,Group_Number__c,Policy_Effective_Date__c,COB_Completed__c,Renewal_Date__c,COB_Needed__c,Term_Date__c,State_of_Origination__c,Claims_Billing_Address__c,PreCert_Required__c,Accreditation__c,Subscriber_Employer__c,Vendor__c,Free_Standing_RTC_Facility__c,PreCert_Phone__c,Free_Standing_Facility__c,PreCert_Penalty_Description__c,Travel_Out_of_State_for_Non_Emergent_Tx__c,Accepts_Assignment_of_Benefits__c,Prior_Auth_Before_Travel__c,Referral_Needed__c,Is_this_Medicare_Medicaid__c,Pharmacy_Coverage__c,Rx_Vendor__c,Rx_Phone__c,ACA_Policy_Paid_Through_Date__c,COBRA_Account__c,COBRA_Effective_Date__c,COBRA_Paid_Through_Date__c,VOB_status__c,VOB_Assigned__c,Other_Insurance_Company__c, Patient_is_High_Acuity__c, Approving_Without_Medical_Records__c FROM Patient_Insurance__c WHERE Opportunity__c =:oppId];
            PatientInsuranceWrp piWrp;
            String name = '';
            for(Patient_Insurance__c pi:piList){
                name = '';
                piWrp = new PatientInsuranceWrp();
                piWrp.record = pi;
                piWrp.index = piWrpList.size()-1;
                if(pi.Subscriber_is_Patient__c && pi.Patient__c!=null){
                    if(pi.Patient__r.FirstName !=null && pi.Patient__r.FirstName !=''){
                        name = pi.Patient__r.FirstName +' ';
                    }
                    name = (name!='') ? name+pi.Patient__r.LastName : pi.Patient__r.LastName;
                    name = name+' (Patient)';
                    piWrp.patConUniqueNo = pi.Patient__c;
                } else if(pi.Subscriber__c!=null){
                    if(pi.Subscriber__r.First_Name__c !=null && pi.Subscriber__r.First_Name__c !=''){
                        name = pi.Subscriber__r.First_Name__c +' ';
                    }
                    if(pi.Subscriber__r.Last_Name__c !=null && pi.Subscriber__r.Last_Name__c !=''){
                        name = name + (pi.Subscriber__r.Last_Name__c );
                    }
                    piWrp.patConUniqueNo = pi.Subscriber__c;
                }
                piWrp.patconEmployer = pi.Subscriber_Employer__c;
                piWrp.patConName = name;
                piWrpList.add(piWrp);
            }

            //Query for Major_Medical_Issue__c
            List<Major_Medical_Issue__c> mmiList = [SELECT Major_Medical_Issue__c,When_Did_it_Happen__c,Ongoing_Symptoms__c,Follow_up_Appointments_Scheduled__c,Occured__c FROM Major_Medical_Issue__c WHERE Opportunity__c =:oppId];
            MajorMedicalIssuesWrp mmiWrp;
            for(Major_Medical_Issue__c mmi : mmiList){
                mmiWrp = new MajorMedicalIssuesWrp();
                mmiWrp.record = mmi;
                mmiWrp.index = mmiWrpList.size()-1;
                mmiWrpList.add(mmiWrp);
            }

            //Query for child Infectious_Disease__c
            List<Infectious_Disease__c> idList = new List<Infectious_Disease__c>();
            idList = [SELECT Name,Currently_Symptomatic__c,Currently_Taking_Medications__c,Diagnosis_Date__c,Have_You_Followed_Up_with_Appointments__c,Infectious_Disease__c,Opportunity__c,Patient__c,Regular_Follow_Up_Recommended__c,Diagnosed__c FROM Infectious_Disease__c WHERE Opportunity__c =:oppId];
            InfectiousDiseasesWrp idWrp;

            for(Infectious_Disease__c id : idList){
                idWrp = new InfectiousDiseasesWrp();
                idWrp.record = id;
                idWrp.index = idWrpList.size()-1;
                idWrpList.add(idWrp);
            }

        /***Query for child Case */
            List<Case> CsList = [SELECT Id , Status, Origin,Red_Flag_Information__c,Opportunity__c, Priority, Account.Name, Description, Subject FROM Case WHERE Opportunity__c =:oppId];
            CaseWrp cWrp;
            for(Case CS : CsList){
                cWrp = new CaseWrp();
                cWrp.record = CS;
                cWrp.index = CaseWrpList.size()-1;
                CaseWrpList.add(cWrp);
            }

            //Query for child Pay_Agreement_Worksheet__c
            List<Pay_Agreement_Worksheet__c> PayAgWSList = [SELECT id,Deductible_Included_in_OOP__c,Revision__c,Num_Days_Detox_DTX__c,Opportunity__c,Ancillary_Fees__c FROM Pay_Agreement_Worksheet__c WHERE Opportunity__c =:oppId];
            PayAgreementWorksheetsWrp pAWSWrp;
            for(Pay_Agreement_Worksheet__c pasl : PayAgWSList){
                pAWSWrp = new PayAgreementWorksheetsWrp();
                pAWSWrp.record = pasl;
                pAWSWrp.index = PayAgreementWorksheetWrpList.size()-1;
                PayAgreementWorksheetWrpList.add(pAWSWrp);
            }

            //Query for child Note_Comment__c
            List<Note_Comment__c> NoteCommentwpList = [SELECT Id, Email_To__c,Note_Comment__c,Opportunity__c,RecordTypeId FROM Note_Comment__c WHERE Opportunity__c =:oppId];
            NoteCommentWrp ncWrp;
            for(Note_Comment__c notecom : NoteCommentwpList){
                ncWrp = new NoteCommentWrp(oppId);
                ncWrp.record = notecom;
                ncWrp.index = NoteCommentWrpList.size()-1;
                ncWrp.noteComment = notecom.Note_Comment__c;
                NoteCommentWrpList.add(ncWrp);
            }

        //Query for child Quote
            List<Quote> QuotewpList = [SELECT Name,Status,Determination_Script_Read_to_Patient__c,TotalPrice,Insurance_Company_Contract_Type__c,OpportunityId FROM Quote WHERE OpportunityId =:oppId];
            QuotesWrp qtWrp;
            for(Quote qut : QuotewpList){
                qtWrp = new QuotesWrp();
                qtWrp.record = qut;
                qtWrp.index = QuotesWrpList.size()-1;
                QuotesWrpList.add(qtWrp);
            }

        /***Query For Child Trip */
            List<Trip__c> tripwpList = [SELECT Modified_Date_Time__c,Description__c,Booking_Source__c,Opportunity__c ,End_Date__c,Start_Date__c,Trip_ID__c,Trip_Name__c FROM Trip__c WHERE Opportunity__c =:oppId];
            TripWrp tpWrp;
            for(Trip__c trp : tripwpList){
                tpWrp = new TripWrp();
                tpWrp.record = trp;
                tpWrp.index = TripWrpList.size()-1;
                TripWrpList.add(tpWrp);
            }

            //Query for child Referral__c
            List<Referral__c> ReferralwpList = [SELECT Patient_Name__c,Account__c,Consentor__c,Referral_Reason__c,Opportunity__c, Referral_Rank__c FROM Referral__c WHERE Opportunity__c =:oppId];
            ReferralWrp rflWrp;
            for(Referral__c rfl : ReferralwpList){
                rflWrp = new ReferralWrp();
                rflWrp.record = rfl;
                rflWrp.index = ReferralWrpList.size()-1;
                ReferralWrpList.add(rflWrp);
            }

             stageValue = opp.StageName;
        }
        if(oppId != null && oppId != ''){
            usrName = opp.owner.Name;
            rend2 = true;
            rend1 = false;
        } else {
            usrName = UserInfo.getName();
            rend2 = false;
            rend1 = true;
            idWrpList = createDiseaseRecordlist();
            meWrpList = createEquipmntRecordlist();
            mmiWrpList = createMedIssueRecordlist();
        }

        if(recordTypeName == 'ROO'){ // record Type=Refer Out Only
            showForReferal = true;
            showForOthers = false;
            showForResidentialTreatment = false;
            showForOutPatientFields = true;
            showForReferalFields = true;
            showForNoteCommentFields = true;
        } else if(recordTypeName == IOP_RECORDTYPE){
            showForReferal = true;
            showForOthers = false;
            showForResidentialTreatment = false;
            showForOutPatient = true;
            showForOutPatientFields = true;
        } else if(recordTypeName == 'RTC'){
            showForReferal = false;
            showForOthers = false;
            showForResidentialTreatment = true;
            showForOutPatient = false;
            //showForOutPatientFields = true;
            //showForReferalFields = true;
        }


        //Add a empty row if no records in Psychiatric_Treatment_History__c
        if(pTHWrpList.size()==0){
            addNewPTHObj();
        }

        //Add a empty row if no records in Medical_Problem_Symptom__c
        if(mPSWrpList.size()==0){
            addNewMPSObj();
        }

        //Add a empty row if no records in Illness_Injury__c
        if(iiWrpList.size()==0){
            addNewIIObj();
        }

        //Add a empty row if no records in Prescription_Medication__c
        if(pmWrpList.size()==0){
            addNewPMObj();
        }

        //Add a empty row if no records in Mental_Health_Symptom__c
        if(mhsWrpList.size()==0){
            addNewMHSObj();
        }

        //Add a empty row if no records in Psychiatric_Diagnosis__c
        if(pdWrpList.size()==0){
            addNewPDObj();
        }

        //Add a empty row if no records in Legal_Offense__c
        if(loWrpList.size()==0){
            addNewLOObj();
        }

        //Add a empty row if no records in Substance_Abuse_History_and_Frequency__c
        if(sahfWrpList.size()==0){
            addNewSAHFObj();
        }

        //Add a empty row if no records in Medical_Equipment__c
        if(meWrpList.size()==0){
            addNewMEObj();
        }

        //Add a empty row if no records in Infectious_Disease__c
        if(idWrpList.size()==0){
            addNewIDObj();
        }

        //Add a empty row if no records in Note/Comment
        if(NoteCommentWrpList.size()==0){
            addNewNoteCommentObj();
        }

        if(ReferWrpList.size()>0){
            rendSection();
        }
    }

    public void rendSection(){
        searchTerm = '';
        if(opp.LeadSource == 'Professional'){
           rend3 = true;
       rend4 = false;
       rend5 = false;
       rend6 = false;
       rend7 = false;
        }else if(opp.LeadSource == 'Friend or Family Member'){
            rend3 = false;
            rend4 = true;
      rend5 = false;
      rend6 = false;
      rend7 = false;
      if(opp.Lead_Source_is_FRN_Alumni__c=='Yes'){
        if(opp.Alumni_Referral_Source__c == 'Professional'){
          rend3 = true;
        } else if (opp.Alumni_Referral_Source__c == 'Online'){
          rend5 = true;
        } else if (opp.Alumni_Referral_Source__c == 'Unknown'){
          rend6 = true;
        }
      }
        }else if(opp.LeadSource == 'Online'){
            rend3 = false;
            rend4 = false;
      rend5 = true;
      rend6 = false;
      rend7 = false;
        }else if(opp.LeadSource == 'Unknown'){
            rend3 = false;
            rend4 = false;
      rend5 = false;
      rend6 = true;
      rend7 = false;
        }else if(opp.LeadSource == 'Alumni'){
            rend3 = false;
            rend4 = false;
        rend5 = false;
        rend6 = false;
            rend7 = true;
           }else{
            rend3 = false;
            rend4 = false;
      rend5 = false;
      rend6 = false;
      rend7 = false;
        }
    }

  /***Who told you about ONLINE search()?????*/

    public void toldYouAbout() {
        searchTerm = '';
        abtValue = System.currentPageReference().getParameters().get('about');

        if(abtValue != null && abtValue != '') {
            //string tempInput = '%' + abtValue + '%';
            List<Online_Search_Term__c> srch = new List<Online_Search_Term__c>();
            srch = [SELECT Id, Name FROM Online_Search_Term__c WHERE Name =: abtValue LIMIT 1];
                if(srch.size() > 0){
                    for(Online_Search_Term__c O: srch){
                        searchTerm = O.Name;
                    }

                }   else { }

        } else if(abtValue == null && abtValue == '') {
      searchTerm = '';
    }
    }

    public void selectedvalue(){
        validHighReferralWrp = false;
        if(ReferWrpList.size()>searchPosition){
            Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
            String acckeyPrefix = r.getKeyPrefix();
            Schema.DescribeSObjectResult r1 = Contact.sObjectType.getDescribe();
            String conkeyPrefix = r1.getKeyPrefix();

            ReferralWrapper wrp = ReferWrpList[searchPosition];
            wrp.referralSourceConList.clear();
            wrp.referralSourceList.clear();
            if(wrp.searchKeyWord != null && wrp.searchKeyWord!=''){
                String accName, accID;
                if(String.valueOf(wrp.searchKeyWord).startsWith(acckeyPrefix)){

                    for(Contact con: [
                        SELECT id
                             , AccountId
                             , Account.name
                             , Name
                             , Currently_Employed__c
                          FROM Contact
                         WHERE AccountId = :wrp.searchKeyWord AND Currently_Employed__c = TRUE
                    ]){
                        wrp.referralSourceConList.add(new SelectOption(con.id, con.name));
                    }

                    for(Account acc: [
                            SELECT id
                                 , name
                                 , RAM_Lookup__c
                                 , RAM_Lookup__r.Name
                                 , High_Priority__c
                                 , Special_Instructions__c
                              FROM Account WHERE Id = :wrp.searchKeyWord
                    ]){
                        wrp.referralSourceList.add(new SelectOption(acc.id, acc.name));
                        if(acc.RAM_Lookup__c!=null)
                            wrp.RAMName = acc.RAM_Lookup__r.Name;
                        if(acc.High_Priority__c) {
                            wrp.isHighPriority = true;
                            validHighReferralWrp = validateHighPriorityReferralForSpecialInstructions(ReferWrpList,searchPosition);
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
                    for(Contact con: [SELECT id,AccountId,Account.name,Account.RAM_Lookup__c,Account.RAM_Lookup__r.name,Account.High_Priority__c,Account.Special_Instructions__c, name, Currently_Employed__c FROM Contact WHERE id = :wrp.searchKeyWord AND Currently_Employed__c = True]){
                        wrp.referralSourceConList.add(new SelectOption(con.id, con.name));
                        accName = con.Account.name;
                        accID = con.AccountId;
                        if(con.Account.RAM_Lookup__c !=null)
                            wrp.RAMName = con.Account.RAM_Lookup__r.Name;
                    }
                    if(accName != '' && accName != null){
                        wrp.referralSourceList.add(new SelectOption(accID,accName));
                        if(con.Account.High_Priority__c  ) {
                            wrp.isHighPriority = true;
                            validHighReferralWrp = validateHighPriorityReferralForSpecialInstructions(ReferWrpList,searchPosition);
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
        }
    }

    public Boolean validateHighPriorityReferralForSpecialInstructions(List<ReferralWrapper> pReferWrpList, Integer referralIndex) {
        Boolean  validatHighReferral = false;
        ReferralWrapper referalWraperInstance = ReferWrpList[referralIndex];
        if(pReferWrpList.size() == 1) {
            return true;
        }else {
            for(ReferralWrapper refwraperItr : pReferWrpList) {
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

    public void populateRecordTypeInfo(){
        if(selectedRecordType != null && selectedRecordType.length() >0){
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE Id =:selectedRecordType];
            if(rt.Name == 'Residential Treatment'){
                recordTypeName = 'RTC';
                stageValue = 'In Process';
            } else if(rt.Name == 'Outpatient Treatment'){
                recordTypeName = IOP_RECORDTYPE;
                stageValue = 'Prospecting';
            } else if(rt.Name == 'Refer Out Only'){
                recordTypeName = 'ROO';
                stageValue = 'Prospecting';
            }
            dispRecTypeName = rt.Name;
            opp.RecordTypeId = rt.Id;
            showOpptyName();
        }
    }

    @RemoteAction
    public static List<SearchWrapperClass> getSearchResult(String keyTerm){
        List<SearchWrapperClass> wrpList = new List<SearchWrapperClass>();

        if(keyTerm!= null && keyTerm.trim()!=''){
            keyTerm = '%'+keyTerm.trim()+'%';
            wrpList.add(new SearchWrapperClass('', 'Referral Source'));
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referral Source').getRecordTypeId();
            Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referral Source Contact').getRecordTypeId();
            List<Account> accList = [Select id,
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
        }
        return wrpList;
    }

    public class SearchWrapperClass{
    String id,label;
        public SearchWrapperClass(String wrid, String name){
            this.label = name;
            this.id = wrid;
        }
    }

    public class ReferralWrapper{
        public Integer index {get;set;}
        public Referral__c cmpM   {get; set;}
        public String referalRank {get;set;}
        public String RAMName {get;set;}
        public String searchKeyWord {get; set;}
        public String selectedKeyWrp {get; set;}
        public List<SelectOption> referralSourceList {get; set;}
        public List<SelectOption> referralSourceConList {get; set;}
        public List<SelectOption> refOrders {get; set;}
        public Boolean isHighPriority {get; set;}
        public ReferralWrapper(){
            cmpM = new Referral__c();
            referalRank = '';
            referralSourceList = new List<SelectOption>();
            referralSourceConList = new List<SelectOption>();
            refOrders =  new List<SelectOption>();
            isHighPriority = false;
        }
    }

    public void addNewRow(){
        ReferralWrapper newRecord = new ReferralWrapper();
        newRecord.index = ReferWrpList.size();
        ReferWrpList.add(newRecord);
        referlist();
    }

    public void removeRow(){

        if(ReferWrpList.size()>rowToRemove){
            if(ReferWrpList[rowToRemove].cmpM.id != null){
                delete ReferWrpList[rowToRemove].cmpM;
            }
            ReferWrpList.remove(rowToRemove);
            for(integer i=rowToRemove;i<ReferWrpList.size();i++){
                ReferWrpList[i].index = i;
            }
            if(highPriorityReferralIndex == rowToRemove && highPriorityCheck == true){
                highPriorityReferralIndex = 0;
                highPriorityCheck=  false;
            }
        }
        referlist();
    }

    public void referlist(){
        string refer = '';
        for(ReferralWrapper c: ReferWrpList){
            refer += ' '+c.cmpM.Referral_Rank__c;
        }
        Schema.DescribeFieldResult fieldResult = Referral__c.Referral_Rank__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(ReferralWrapper c: ReferWrpList){
            c.refOrders =  new List<SelectOption>();
            for( Schema.PicklistEntry f : ple){
                if(!refer.contains(f.getValue()) || f.getValue() == c.cmpM.Referral_Rank__c)
                c.refOrders.add(new SelectOption(f.getLabel(), f.getValue()));
            }

            // check if high priority is changed
            // else
        }
    }

    public PageReference cancel(){
        String keyPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
        PageReference pageRef;
        if(oppId!=null){
            pageRef = new PageReference('/'+oppId);
        } else {
            pageRef = new PageReference('/'+keyPrefix);
        }
        pageRef.setRedirect(true);
        return pageRef;
    }

    /***Clone to Refer Out button on Opportunity */
    public PageReference CloneOpportunity(){
        String opportunityId = '';
        if(oppId!=null){
        opportunityId = cloneOpportunity.cloneOpptyRecordType(oppId);
        PageReference pageRef = new PageReference('/'+opportunityId);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }

    public PageReference UploadDocument(){
        PageReference pageRef = new PageReference('/apex/OppDocumentPage?id='+opp.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void showOpptyName(){
        opName = true;
        displayOpptyName = '';
        String conName='';
        if(opp.Contact__c != null){
            Contact conInfo =[select Id, Name from Contact where id=:opp.Contact__c];
            if(conInfo.Name != null && conInfo.Name != ''){
                conName = conInfo.Name + ' ';
            }
        }
        opp.Name = conName + recordTypeName + ' '+localtimeinString;
        displayOpptyName = opp.Name;
    }

    public void hideMessage(){
        isOpportunitySaved = false;
    }

    public PageReference saveOppInfo(){
        system.debug('>>> ReferWrpList : '+ReferWrpList);
        showOpptyName();
        opp.StageName = stageValue;
        system.debug('>>> fRNFacilityValue : '+fRNFacilityValue);
        if(fRNFacilityValue != null) {
            opp.Most_Recent_FRN_Facility__c = fRNFacilityValue;
        }
        if(opp.Probability>100){
            opp.Probability = 100;
        }

        if(opp.Contact__c==null){
            isContactNull = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Patient Contact is required.');
            ApexPages.addMessage(myMsg);
            return null;
        }

        if(!validateOpp()){
            return null;
        }
        saveOpportunity();
        /*
        if(isOpportunitySaved) {
            return (new PageReference('/'+opp.Id));
        }
        else {
            return null;
        }*/

        return (new PageReference('/'+opp.Id));
        //return null;
    }

    public void saveAndContinue(){
        system.debug('>>> in save and continue : '+opp.Most_Recent_FRN_Facility__c);
        isOpportunitySaved = false;
        showOpptyName();
        opp.StageName = stageValue;
        if(fRNFacilityValue != null) {
            opp.Most_Recent_FRN_Facility__c = fRNFacilityValue;
        }
        if(opp.Probability>100){
            opp.Probability = 100;
        }
        if(opp.Contact__c==null){
            isContactNull = true;
            return;
        }

        Boolean validateResult = validateOpp();
        ApexPages.Message[] messageList = ApexPages.getMessages();
        for(ApexPages.Message messageApexPage : messageList){
            System.debug('Message = '+messageApexPage.getDetail());
        }

        if(!validateResult){
            return;
        }
        saveOpportunity();
        isOpportunitySaved = true;
        /*if(!isOpportunitySaved) {
            errorFlag = true;
        }*/

        return;
    }

    public boolean validateOpp(){
        List<Opportunity> validateOppty = new List<Opportunity>();
        if((opp.Have_You_Ever_Purged_or_Forced_Throw_Up__c=='Yes' || opp.Purposely_Starved_or_Restricted_Food__c == 'Yes' || opp.Use_of_Laxatives_for_Weight_Loss__c == 'Yes' || opp.Have_You_Suffered_from_Binge_Eating__c == 'Yes' || opp.Have_You_Seen_a__c == 'Yes') && opp.Height_ft_in__c==null){
            isHeightNull = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Height : You must enter a value.');
            ApexPages.addMessage(myMsg);
            return false;
        }
        if((opp.Have_You_Ever_Purged_or_Forced_Throw_Up__c=='Yes' || opp.Purposely_Starved_or_Restricted_Food__c == 'Yes' || opp.Use_of_Laxatives_for_Weight_Loss__c == 'Yes' || opp.Have_You_Suffered_from_Binge_Eating__c == 'Yes' || opp.Have_You_Seen_a__c == 'Yes') && opp.Weight_lbs__c==null){
            isWeightNull = true;
            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Weight : You must enter a value.');
            ApexPages.addMessage(myMsg1);
            return false;
        }

        if(opp.LeadSource == null || opp.LeadSource == '--None--'){
            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Pre-Screening Source is required.');
            ApexPages.addMessage(myMsg1);
            return false;
        }

        String rooID = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();
        String rtcId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Residential Treatment').getRecordTypeId();

        if(opp.StageName == 'Referral Requested' && (selectedRecordType == rooId || selectedRecordType == rtcId)){
            validateOppty = [SELECT Id, Contact__c,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.Social_Security_Number__c,Contact__r.Preferred_Method_of_Contact__c,Contact__r.Birthdate,Contact__r.MailingCity,Contact__r.MailingState FROM Opportunity WHERE Id =: oppId];
            for(Opportunity opplst : validateOppty){

                if(opplst.contact__r.FirstName == null || opplst.Contact__r.LastName == null || opplst.Contact__r.Birthdate == null || opplst.Contact__r.MailingCity == null || opplst.Contact__r.MailingState == null || opp.Refer_Out_Reason__c == null ){
                    if(opplst.contact__r.FirstName == null){
                        ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Patient\'s  First Name is required.');
                        ApexPages.addMessage(myMsg1);
                    }
                    if(opplst.contact__r.LastName == null){
                        ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Patient\'s  Last Name is required.');
                        ApexPages.addMessage(myMsg1);
                    }
                    if(opplst.contact__r.Birthdate == null){
                        ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Patient\'s  Birthdate is required.');
                        ApexPages.addMessage(myMsg1);
                    }
                    if(opplst.contact__r.MailingCity == null){
                        ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Patient\'s  City is required.');
                        ApexPages.addMessage(myMsg1);
                    }
                    if(opplst.contact__r.MailingState == null){
                        ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Patient\'s  State is required.');
                        ApexPages.addMessage(myMsg1);
                    }

                    if(opp.Refer_Out_Reason__c == null || opp.Refer_Out_Reason__c == '--None--'){
                        ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Refer Out Reason is required.');
                        ApexPages.addMessage(myMsg1);
                    }
                    return false;
                }
            }
        }

        return true;
    }

    public void saveOpportunity(){
        if(opp.Contact__r.Preferred_Method_of_Contact__c != null && opp.Contact__r.Preferred_Method_of_Contact__c != '' ){
            opp.Preferred_Contact_Method__c = opp.Contact__r.Preferred_Method_of_Contact__c;
        }

        if(opp.LeadSource=='Online'){
            opp.Referral_Source_Unknown_Details__c = null;
            opp.Alumni_Name__c = null;
            opp.Alumni_FRN_Facility__c = null;
            deleteReferal();
        } else if(opp.LeadSource=='Unknown'){
            opp.Online_Search_Term__c = null;
            opp.Alumni_Name__c = null;
            opp.Alumni_FRN_Facility__c = null;
            deleteReferal();
        } else if(opp.LeadSource == 'Alumni'){
            opp.Online_Search_Term__c = null;
            opp.Referral_Source_Unknown_Details__c = null;
            deleteReferal();
        } else if(opp.LeadSource == 'Professional') {
            opp.Referral_Source_Unknown_Details__c = null;
            opp.Alumni_Name__c = null;
            opp.Alumni_FRN_Facility__c = null;
            opp.Online_Search_Term__c = null;
        }

        if(opp.Have_You_Ever_Attempted_Suicide__c != 'Yes'){
            opp.Number_of_Suicide_Attempts__c = null;
            opp.Most_Recent_Attempt_Date__c = null;
            opp.Attempted_Suicide_Methods__c = null;
            opp.Description_of_Suicide_Attempt__c = null;
            opp.Under_Influence_at_Time_of_Attempt__c = null;
            opp.Suicide_Attempt_Additional_Notes__c = null;
        }

        if(opp.Current_Thoughts_of_Attempting_Suicide__c != 'Yes'){
            opp.Describe_Suicide_Thoughts__c = null;
            opp.Do_You_Have_a_Suicide_Plan__c = null;
        } else if(opp.Do_You_Have_a_Suicide_Plan__c != 'Yes'){
            opp.Description_of_Suicide_Plan__c = null;
            opp.Intention_Fear_of_Suicide__c = null;
        }

        if(opp.Purposely_Cut_or_Burned_Yourself__c != 'Yes'){
            opp.Frequency_of_Cutting_Burning__c = null;
            opp.Last_Cut_Burn_Date__c = null;
            opp.Did_Cut_Burn_Require_Medical_Attention__c = null;
            opp.Under_Influence_while_Cutting_Burning__c = null;
        }
        if(opp.Do_You_Have_a_Cutting_Burning_Plan__c !='Yes'){
            opp.Cutting_Burning_Plan_Details__c = null;
        }
        if(opp.Have_You_Ever_Purged_or_Forced_Throw_Up__c != 'Yes'){
            opp.Last_Purged_Date__c = null;
            opp.Purge_Frequency__c = null;
            opp.Length_of_Time_Purging__c = null;
            // uncommenting for quality report
            //opp.Height_ft_in__c = null;
            //opp.Weight_lbs__c = null;
        }
        if(opp.Purposely_Starved_or_Restricted_Food__c != 'Yes'){
            opp.Length_of_Time_Starving__c = null;
        }
        if(opp.Use_of_Laxatives_for_Weight_Loss__c != 'Yes'){
            opp.Length_of_Time_Using_Laxatives__c = null;
        }
        if(opp.Have_You_Seen_a__c != 'Yes'){
            opp.Eating_Disorder_Treatment_Facility__c = null;
        }
        if(opp.Have_You_Suffered_from_Binge_Eating__c != 'Yes'){
            opp.Binge_Eating_Comments__c = null;
        }
        if(opp.Have_You_Physically_Hit_Harmed_Anyone__c != 'Yes'){
            opp.Describe_Hit_Harm_Situation__c = null;
        }
        if(opp.Have_You_Had_Thoughts_of_Harming_Others__c != 'Yes'){
            opp.Who_Were_You_Thinking_of_Hurting__c = null;
        }
        if(opp.Involved_in_Domestic_Violence__c != 'Yes'){
            opp.Describe_Domestic_Violence_Situation__c  = null;
        }if(opp.Do_You_Have_a_Legal_Guardian__c != 'Yes'){
            opp.Legal_Guardian_First_Name__c     = null;
            opp.Legal_Guardian_Last_Name__c  = null;
        }

        if(opp.Readmit__c != 'Yes'){
            opp.Most_Recent_FRN_Facility__c = null;
        }
        if(opp.Have_You_Ever_Purged_or_Forced_Throw_Up__c != 'Yes'
        && opp.Purposely_Starved_or_Restricted_Food__c != 'Yes'
        && opp.Use_of_Laxatives_for_Weight_Loss__c != 'Yes'
        && opp.Have_You_Suffered_from_Binge_Eating__c != 'Yes'
        && opp.Have_You_Seen_a__c != 'Yes') {
            opp.Height_ft_in__c = null;
            opp.Weight_lbs__c = null;
        }
        cleanIOPFields(opp);
        opp.Referral_Instruction__c = specialInstructionsMsg;
        opp = UpdateHighPriorityReferralService.updateOpportunityHighPriorityCheckBox(opp);
            try {
                Upsert opp;
            }
            catch(Exception exObj) {
                system.debug('>>> exObj : '+exObj);
                throw exObj;
            }
        if(!ReferWrpList.isEmpty() && highPriorityCheck == true) {
            UpdateHighPriorityReferralService.getReferralDocsOnOpportunity(ReferWrpList[highPriorityReferralIndex].cmpM.Account__c, opp.Id);
        }else if(highPriorityCheck == false && docList != null && !docList.isEmpty()){
            delete docList;
            docList.clear();
        }

        //Abused Subatance Object upsert.
        List<Abused_Substance__c> AbusedSubstanceList = new list<Abused_Substance__c>();
        if(absSubsWrpList.size()>0){
            for(AbusedSubstanceWrp sd:absSubsWrpList){
                Abused_Substance__c ad =sd.record;
                ad.Patient__c = opp.Contact__c;
                ad.Opportunity__c = opp.Id;
                if(ad.Overdosed_on_this_Substance__c!='Yes'){
                    ad.Hospitalized_for_Overdose__c = null;
                    ad.Number_Times_Overdosed_on_this_Substance__c = null;
                    ad.Were_Any_Overdoses_Intentional__c = null;
                    ad.Most_Recent_Overdosed_Date__c = null;
                    ad.Explanation_of_Intentional_Overdose__c = null;
                }
                AbusedSubstanceList.add(ad);
            }
            upsert AbusedSubstanceList;
        }

        //Treatment_History__c Object upsert.
        List<Treatment_History__c> PsychiatricTreatmentHistoryList = new list<Treatment_History__c>();
        if(pTHWrpList.size()>0){
            for(PsychiatricTHWrp sd:pTHWrpList){
                Treatment_History__c ad =sd.record;
                if(ad.Type__c==null && ad.Level_of_Care__c==null && ad.Admit_Date__c==null && ad.Discharge_Date__c==null)
                    continue;
                ad.Opportunity__c = opp.Id;
                PsychiatricTreatmentHistoryList.add(ad);
            }
            upsert PsychiatricTreatmentHistoryList;
        }

    /***Medical_Problem_Symptom Object INSERT/DELETE block.*/
        List<Medical_Problem_Symptom__c> MedicalProblemSymptomList = new list<Medical_Problem_Symptom__c>();
        if(opp.Ongoing_Medical_Issues_or_Conditions__c=='Yes'){
            if(mPSWrpList.size()>0){
                for(MedicalProblemSymWrp sd:mPSWrpList){
                    Medical_Problem_Symptom__c ad =sd.record;
                    if(ad.Last_Doctor_Visit_Date__c==null && ad.Problem__c==null && ad.Symptoms__c==null)
                        continue;
                    ad.Opportunity__c = opp.Id;
                    ad.Patient__c = opp.Contact__c;
                    MedicalProblemSymptomList.add(ad);
                }
                upsert MedicalProblemSymptomList;
            }
        } else {
                for(MedicalProblemSymWrp sd:mPSWrpList){
                    if(sd.record.id != null){
                        MedicalProblemSymptomList.add(sd.record);
                    }
                }
                delete MedicalProblemSymptomList;
        }

        //Illness_Injury__c Object upsert.
        List<Illness_Injury__c> IllnessInjuryList = new list<Illness_Injury__c>();
        if(iiWrpList.size()>0){
            for(IllnessInjuryWrp sd:iiWrpList){
                Illness_Injury__c ad =sd.record;
                if(ad.Illness_Injury__c==null && ad.Description__c==null && ad.Surgeries_or_Hospitalizations__c==null && ad.Surgery_or_Hospitalization_Description__c==null && ad.Surgery_or_Hospitalization_Date__c==null && ad.Were_Follow_up_Appointments_Scheduled__c==null && ad.Did_You_Go_to_Follow_up_Appointments__c==null)
                    continue;
                if(ad.Id==null)
                    ad.Opportunity__c = opp.Id;

                IllnessInjuryList.add(ad);
            }
            upsert IllnessInjuryList;
        }

        //Prescription_Medication Object upsert.
        List<Prescription_Medication__c> PrescriptionMedicationList = new list<Prescription_Medication__c>();
        if(pmWrpList.size()>0){
            for(PrescriptionMediWrp sd:pmWrpList){
                Prescription_Medication__c ad =sd.record;
               // if(ad.Indication__c==null && ad.Prescribed_Dosage__c==null && ad.Currently_Abusing_Substance__c==null && ad.Amount_Abused__c==null && ad.Frequency__c==null)
                   // continue;
                ad.Opportunity__c = opp.Id;
                ad.Patient__c = opp.Contact__c;
                PrescriptionMedicationList.add(ad);
            }
            upsert PrescriptionMedicationList;
        }

        //Mental_Health_Symptom Object upsert.
        List<Mental_Health_Symptom__c> MentalHealthSymptomList = new list<Mental_Health_Symptom__c>();
        if(mhsWrpList.size()>0){
            for(MentalHealthSWrp sd:mhsWrpList){
                Mental_Health_Symptom__c ad =sd.record;
                if(ad.Description__c==null)
                    continue;
                ad.Opportunity__c = opp.Id;
                MentalHealthSymptomList.add(ad);
            }
            upsert MentalHealthSymptomList;
        }

        //Psychiatric_Diagnosis Object upsert.
        List<Psychiatric_Diagnosis__c> PsychiatricDiagnosisList = new list<Psychiatric_Diagnosis__c>();
        if(pdWrpList.size()>0){
            for(PsychiatricDiagnosesWrp sd:pdWrpList){
                Psychiatric_Diagnosis__c ad =sd.record;
                if(ad.Date_of_Diagnosis__c==null && ad.Diagnosed_By__c==null && ad.Diagnosis__c==null)
                    continue;
                ad.Opportunity__c = opp.Id;
                ad.Patient__c = opp.Contact__c;
                PsychiatricDiagnosisList.add(ad);
            }
            upsert PsychiatricDiagnosisList;
        }

        //Legal_Offense Object upsert.
        List<Legal_Offense__c> LegalOffenseList = new list<Legal_Offense__c>();
        if(loWrpList.size()>0){
            for(LegalOffensesWrp sd:loWrpList){
                Legal_Offense__c ad =sd.record;
                if(ad.Date__c==null && ad.On_Parole__c==null && ad.On_Probation__c==null && ad.Registered_Sex_Offender_List__c==null && ad.Type__c==null)
                    continue;
                ad.Opportunity__c = opp.Id;
                ad.Patient__c = opp.Contact__c;
                LegalOffenseList.add(ad);
            }
            upsert LegalOffenseList;
        }

        //Clinical_Assessment Object upsert.
        List<Clinical_Assessment__c> ClinicalAssessmenttList = new list<Clinical_Assessment__c>();
        if(caWrpList.size()>0){
            for(ClinicalAssessmentsWrp sd:caWrpList){
                Clinical_Assessment__c cd =sd.record;
                cd.Opportunity__c = opp.Id;
                ClinicalAssessmenttList.add(cd);
                upsert ClinicalAssessmenttList;
            }
        }

        //Substance_Abuse_History_and_Frequency Object upsert.
        List<Substance_Abuse_History_and_Frequency__c> SubstanceAbuseHistoryandFrequencyList = new list<Substance_Abuse_History_and_Frequency__c>();
        if(sahfWrpList.size()>0){
            for(SubstanceAHFWrp sd:sahfWrpList){
                Substance_Abuse_History_and_Frequency__c ad =sd.record;
                if(ad.Cigarettes_Tobacco_Amount__c==null && ad.Alcohol_Amount__c==null && ad.Marijuana_Amount__c==null && ad.Opiates_Amount__c==null)
                    continue;
                ad.Opportunity__c = opp.Id;
                SubstanceAbuseHistoryandFrequencyList.add(ad);
            }
            upsert SubstanceAbuseHistoryandFrequencyList;
        }

        //Patient_Contact Object upsert.
        /*Map<String,Patient_Contact__c> PatientContactMap = new Map<String,Patient_Contact__c>();
        if(pcWrpList.size()>0){
            List<Patient_Contact__c> ptntCntctList = new List<Patient_Contact__c>();
            for(PatientContactsWrp sd:pcWrpList){
                ptntCntctList = new List<Patient_Contact__c>();
                if(piWrpList!= null && piWrpList.size() >0 ) {
                    for(PatientInsuranceWrp sd2:piWrpList) {
                        Patient_Contact__c ad =sd.record;
                        ad.Opportunity__c = opp.Id;
                        PatientContactMap.put(sd2.patConUniqueNo,ad); // done by bhakti. added on 13Th dec
                    }
                }
                else {
                    Patient_Contact__c ad =sd.record;
                    ad.Opportunity__c = opp.Id;
                    ptntCntctList.add(ad);
                }
            }
            ptntCntctList.addAll(PatientContactMap.values());
            upsert ptntCntctList;
        }*/

        Map<String, Patient_Contact__c> patientContactMap = new Map<String, Patient_Contact__c>();
        if(pcWrpList.size()>0){
            for(PatientContactsWrp sd:pcWrpList){
                Patient_Contact__c ad = sd.record;
                ad.Opportunity__c = opp.Id;
                //patientContactList.add(ad);
                patientContactMap.put(String.valueOf(sd.UniqueNmbr), ad);
            }
            upsert patientContactMap.values();
        }

        //Medical_Equipment Object upsert.

        //@TODO Should not be created for IOP
        List<Medical_Equipment__c> MedicalEquipmentList = new list<Medical_Equipment__c>();
        if(    IOP_RECORDTYPE.equalsIgnoreCase(recordTypeName) == false
            && meWrpList.isEmpty() == false ) {
            for(MedicalEquipmentWrp sd:meWrpList){
                Medical_Equipment__c ad =sd.record;
                if(ad.Equipment_Type__c==null && ad.Currently_Using_Equipment__c==null && ad.Details__c==null)
                    continue;
                ad.Opportunity__c = opp.Id;
                MedicalEquipmentList.add(ad);
            }
            upsert MedicalEquipmentList;
        }

         //Major_Medical_Issue__c Object upsert.
        List<Major_Medical_Issue__c> MajorMedicalIssueList = new list<Major_Medical_Issue__c>();
        if(mmiWrpList.size()>0){
            for(MajorMedicalIssuesWrp mmi:mmiWrpList){
                Major_Medical_Issue__c ad =mmi.record;
                if(ad.Major_Medical_Issue__c==null && ad.When_Did_it_Happen__c==null && ad.Ongoing_Symptoms__c==null && ad.Follow_up_Appointments_Scheduled__c==null && ad.Occured__c == null)
                    continue;
                if(ad.Id==null)
                    ad.Opportunity__c = opp.Id;
                if(ad.Major_Medical_Issue__c!=null)
                MajorMedicalIssueList.add(ad);
            }
            upsert MajorMedicalIssueList;
        }

        //Patient_Insurance Object upsert.
        List<Patient_Insurance__c> PatientInsuranceList = new list<Patient_Insurance__c>();
        if(piWrpList.size()>0){
            for(PatientInsuranceWrp sd:piWrpList){
                Patient_Insurance__c ad =sd.record;
                ad.Opportunity__c = opp.Id;
                if(sd.patConUniqueNo!=null && sd.patConUniqueNo!='' && !ad.Subscriber_is_Patient__c){
                    if(PatientContactMap.containsKey(sd.patConUniqueNo)){
                        ad.Subscriber__c = PatientContactMap.get(sd.patConUniqueNo).Id;
                        //break;
                    } else if((sd.patConUniqueNo).startsWith(Patient_Contact__c.sObjectType.getDescribe().getKeyPrefix())){
                        ad.Subscriber__c = sd.patConUniqueNo;
                    }
                }
                PatientInsuranceList.add(ad);
            }
            upsert PatientInsuranceList;
        }

        //Infectious_Disease__c Object upsert.
        List<Infectious_Disease__c> InfectiousDiseaseList = new list<Infectious_Disease__c>();
        if(idWrpList.size()>0){
            for(InfectiousDiseasesWrp id:idWrpList){
                Infectious_Disease__c ad =id.record;
                if(ad.Infectious_Disease__c==null && ad.Currently_Symptomatic__c==null && ad.Currently_Taking_Medications__c==null && ad.Regular_Follow_Up_Recommended__c==null && ad.Have_You_Followed_Up_with_Appointments__c==null)
                    continue;
                ad.Opportunity__c = opp.Id;
                ad.Patient__c = opp.Contact__c;
                InfectiousDiseaseList.add(ad);
            }
            upsert InfectiousDiseaseList;
        }

        //Case Object upsert.
        List<Case> caseList = new list<Case>();
        if(CaseWrpList.size()>0){
            for(CaseWrp cs:CaseWrpList){
                Case cas = cs.record;
                if(cas.Status==null && cas.Red_Flag_Information__c==null && cas.Origin==null && cas.Priority==null)
                    continue;
                cas.Opportunity__c = opp.Id;
                caseList.add(cas);
            }
            upsert caseList;
        }

        //Pay_Agreement_Worksheet__c Object upsert.
        List<Pay_Agreement_Worksheet__c> payAgreementWorksheetList = new list<Pay_Agreement_Worksheet__c>();
        if(PayAgreementWorksheetWrpList.size()>0){
            for(PayAgreementWorksheetsWrp paws:PayAgreementWorksheetWrpList){
                Pay_Agreement_Worksheet__c pawss = paws.record;
                if(pawss.Deductible_Included_in_OOP__c==null && pawss.Num_Days_Detox_DTX__c==null && pawss.Ancillary_Fees__c==null)
                    continue;
                pawss.Opportunity__c = opp.Id;
                payAgreementWorksheetList.add(pawss);
            }
            upsert payAgreementWorksheetList;
        }

        //Note_Comment__c Object upsert.
        List<Note_Comment__c> NoteCommentList = new list<Note_Comment__c>();
        if(NoteCommentWrpList.size()>0){
            for(NoteCommentWrp NCo:NoteCommentWrpList){
                Note_Comment__c nc = NCo.record;
                if((NCo.noteComment==null || NCo.noteComment=='') && nc.Email_To__c==null)
                    continue;
                nc.Note_Comment__c = NCo.noteComment;
                //if(NCo.record.Name !=null){
                    if(oppId==null){
                        nc.Opportunity__c = opp.Id;
                    }else if(NCo.record.Opportunity__c ==null){
                        nc.Opportunity__c = opp.Id;
                    }
                    NoteCommentList.add(nc);
                //}
            }
            if(NoteCommentList.size()>0){
                upsert NoteCommentList;
            }
        }

        //Quote Object upsert.
        List<Quote> quoteList = new list<Quote>();
        if(QuotesWrpList.size()>0){
            for(QuotesWrp qtw:QuotesWrpList){
                Quote qt = qtw.record;
                quoteList.add(qt);
            }
            if(quoteList.size()>0){
                upsert quoteList;
            }
        }

        //Trip__c Object upsert.
        List<Trip__c> tripList = new list<Trip__c>();
        if(TripWrpList.size()>0){
            for(TripWrp tpw:TripWrpList){
                Trip__c tp = tpw.record;
                if(tp.Trip_Name__c==null && tp.Modified_Date_Time__c==null && tp.Description__c==null && tp.Booking_Source__c==null)
                    continue;
                tp.Opportunity__c = opp.Id;
                tripList.add(tp);
            }
            upsert tripList;
        }

        List<Referral__c> refList = new List<Referral__c>();
        if(opp.LeadSource == 'Professional'){
            Referral__c rf;
            for(ReferralWrapper refWrp:ReferWrpList){
                rf = new Referral__c();
                String patientName = '';
                rf = refWrp.cmpM;
                rf.Opportunity__c = opp.Id;
                if(refWrp.cmpM.Referral_Rank__c!=null){
                    rf.Referral_Rank__c = refWrp.cmpM.Referral_Rank__c;
                }
                /*
                if(refWrp.cmpM.id != null){
                    rf.id = refWrp.cmpM.id;
                }
                rf.Opportunity__c = opp.Id;
                if(refWrp.cmpM.Account__c!=null){
                    rf.Account__c = refWrp.cmpM.Account__c;
                }
                if(refWrp.cmpM.Consentor__c!=null){
                    rf.Consentor__c = refWrp.cmpM.Consentor__c;
                }
                if(refWrp.cmpM.Referral_Rank__c!=null){
                    rf.Referral_Rank__c = refWrp.cmpM.Referral_Rank__c;
                }
                */
                if(opp.Contact__r.FirstName !=null ){
                    patientName = opp.Contact__r.FirstName +' ';
                }
                 if(opp.Contact__r.LastName !=null ){
                     patientName = patientName + opp.Contact__r.LastName.substring(0,1);
                }
                rf.Patient_Name__c = patientName;
                rf.RecordTypeId = refRecId;
                rf.Referral_Stage__c = 'Open';
                if(refWrp.cmpM.Account__c!=null){
                    refList.add(rf);
                }
            }
            system.debug('>>> refList : '+refList.size());
            if(refList.size()>0){
                try{
                    upsert refList;
                }catch(Exception e){
                    System.debug('Exception....>'+e.getmessage());
                }
            }
        }
        if(isFromQualityReport != null && isFromQualityReport == true) {
            system.debug('>>> recalculating ');
            RecordScoreCalculationService.getOpportunityScore(opp.Id, opp.RecordType.DeveloperName);
        }
    }

    //Delete referal records when Lead Source is not Professional
    public void deleteReferal(){
        try{
            List<Referral__c> refList = new List<Referral__c>();
            for(ReferralWrapper refWrp:ReferWrpList){
                if(refWrp.cmpM.id != null){
                    refList.add(refWrp.cmpM);
                }
            }
            delete refList;
        } catch (Exception e){

        }
    }

    //Wrapper class for Abused Subatance Object
    public class AbusedSubstanceWrp{
        public Integer index {get;set;}
        public Abused_Substance__c record {get;set;}
        public AbusedSubstanceWrp(){
            record = new Abused_Substance__c();
        }
    }

    //SAVEABDNEW Abused Substance
    public pagereference saveNewAbsSubsObj(){
        AbusedSubstanceWrp newRecord = new AbusedSubstanceWrp();
        Abused_Substance__c newAbsSubsRecord = new Abused_Substance__c();
        newRecord.record = sub;
        newRecord.record.Patient__c = opp.Contact__c;
        newRecord.index = absSubsWrpList.size();
        absSubsWrpList.add(newRecord);
        showForAbusedIns = false;
        newRecord = new AbusedSubstanceWrp();
        sub = new Abused_Substance__c();
        return page.NewAbusedSubstanceFrOpp;
    }

    //SAVEABDNEW Abused Substance on EDIT
    public pagereference saveNewAbsSubsObjEdit(){
        showForAbusedIns = false;
        sub = new Abused_Substance__c();
        return page.NewAbusedSubstanceFrOpp;
    }

    //Add New row in the Abused Substance related list
    public pagereference addNewAbsSubsObj(){
        AbusedSubstanceWrp newRecord = new AbusedSubstanceWrp();
        Abused_Substance__c newAbsSubsRecord = new Abused_Substance__c();
        newRecord.record = sub;
        newRecord.record.Patient__c = opp.Contact__c;
        newRecord.index = absSubsWrpList.size();
        absSubsWrpList.add(newRecord);
        system.debug('>>> newRecord : '+newRecord);
        showForAbusedIns = false;
        return page.CreateOpportunity;
    }

    public pagereference updateAbsSubsObj(){
        showForAbusedIns = false;
        return page.CreateOpportunity;
    }

    public pagereference abusedsubstance(){
        showForAbusedIns = false;
        sub = new Abused_Substance__c();
        return page.NewAbusedSubstanceFrOpp;
    }

    public pagereference abusedsubstanceEdit(){
        showForAbusedIns = true;
        sub = new Abused_Substance__c();
        sub = absSubsWrpList[rowToEdit].record;
        return page.NewAbusedSubstanceFrOpp;
    }

    //Delete one row from the Abused Substance Related List
    public void removeRowToAbsList(){
        Abused_Substance__c absObjDel = absSubsWrpList[rowToRemove].record;
        if(absObjDel.id!=null){
            delete absObjDel;
        }
       absSubsWrpList.remove(rowToRemove);
    }

    //Wrapper class for Treatment History Object
    public class PsychiatricTHWrp{
        public Integer index {get;set;}
        public Treatment_History__c record {get;set;}
        public PsychiatricTHWrp(){
            record = new Treatment_History__c();
        }
    }

    //Add New row in the Treatment History related list
    public void addNewPTHObj(){
        PsychiatricTHWrp newRecord = new PsychiatricTHWrp();
        Treatment_History__c newPTHRecord = new Treatment_History__c();
        newRecord.record = newPTHRecord;
        newRecord.index = pTHWrpList.size()-1;
        if(newRecord.index>=0){
            Treatment_History__c oldPTHRecord = pTHWrpList[newRecord.index].record;
            if(oldPTHRecord.Type__c==null && oldPTHRecord.Level_of_Care__c==null && oldPTHRecord.Admit_Date__c==null && oldPTHRecord.Discharge_Date__c==null && oldPTHRecord.Other_Facility__c==null && oldPTHRecord.Was_Treatment_Involuntary__c==null)
                return;
        }
        pTHWrpList.add(newRecord);
    }

    //Delete one row from the Treatment History related List
    public void removeRowToPTHList(){
        Treatment_History__c pthObjDel = pTHWrpList[rowToRemove].record;
        if(pTHWrpList.size() == 1){
            if(pthObjDel.id!=null)
                delete pthObjDel;
            pthObjDel = new Treatment_History__c();
            PsychiatricTHWrp newRecord = new PsychiatricTHWrp();
            newRecord.record = pthObjDel;
            pTHWrpList[rowToRemove] = newRecord;
        }else{
            if(pthObjDel.id!=null){
                delete pthObjDel;
            }
            pTHWrpList.remove(rowToRemove);
        }
    }

    //Wrapper class for Medical Problem / Symptom Object
    public class MedicalProblemSymWrp{
        public Integer index {get;set;}
        public Medical_Problem_Symptom__c record {get;set;}
        public MedicalProblemSymWrp(){
            record = new Medical_Problem_Symptom__c();
        }
    }

    //Add New row to the Medical Problem / Symptom related list
    public void addNewMPSObj(){
        MedicalProblemSymWrp newRecord = new MedicalProblemSymWrp();
        Medical_Problem_Symptom__c newMPSRecord = new Medical_Problem_Symptom__c();
        newRecord.record = newMPSRecord;
        newRecord.index = mPSWrpList.size()-1;
        newRecord.record.Patient__c = opp.Contact__c;
        if(newRecord.index>=0){
            Medical_Problem_Symptom__c oldAbsRecord = mPSWrpList[newRecord.index].record;
            if(oldAbsRecord.Last_Doctor_Visit_Date__c==null && oldAbsRecord.Problem__c==null && oldAbsRecord.Symptoms__c==null)
                return;
        }
        mPSWrpList.add(newRecord);
    }

    //Delete one row from the Medical Problem / Symptom Related List
    public void removeRowToMpsList(){
        Medical_Problem_Symptom__c mpsObjDel = mPSWrpList[rowToRemove].record;
        if(mPSWrpList.size() == 1){
            if(mpsObjDel.id!=null)
                delete mpsObjDel;
            mpsObjDel = new Medical_Problem_Symptom__c();
            MedicalProblemSymWrp newRecord = new MedicalProblemSymWrp();
            newRecord.record = mpsObjDel;
            mPSWrpList[rowToRemove] = newRecord;
        }else{
            if(mpsObjDel.id!=null){
                delete mpsObjDel;
            }
            mPSWrpList.remove(rowToRemove);
        }
    }

    //Wrapper class for Illness / Injury Object
    public class IllnessInjuryWrp{
        public Integer index {get;set;}
        public Illness_Injury__c record {get;set;}
        public IllnessInjuryWrp(){
            record = new Illness_Injury__c();
        }
    }

    //Add New row to the Illness / Injury related list
    public void addNewIIObj(){
        IllnessInjuryWrp newRecord = new IllnessInjuryWrp();
        Illness_Injury__c newMPSRecord = new Illness_Injury__c();
        newRecord.record = newMPSRecord;
        newRecord.index = iiWrpList.size()-1;
        if(newRecord.index>=0){
            Illness_Injury__c oldRecord = iiWrpList[newRecord.index].record;
            if(oldRecord.Illness_Injury__c==null && oldRecord.Description__c==null && oldRecord.Surgeries_or_Hospitalizations__c==null && oldRecord.Surgery_or_Hospitalization_Description__c==null && oldRecord.Surgery_or_Hospitalization_Date__c==null && oldRecord.Were_Follow_up_Appointments_Scheduled__c==null && oldRecord.Did_You_Go_to_Follow_up_Appointments__c==null)
                return;
        }
        iiWrpList.add(newRecord);
    }

    //Delete one row from the Illness / Injury Related List
    public void removeRowToIIList(){
        Illness_Injury__c iiObjDel = iiWrpList[rowToRemove].record;
        if(iiWrpList.size() == 1){
            if(iiObjDel.id!=null)
                delete iiObjDel;
            iiObjDel = new Illness_Injury__c();
            IllnessInjuryWrp newRecord = new IllnessInjuryWrp();
            newRecord.record = iiObjDel;
            iiWrpList[rowToRemove] = newRecord;
        }else{
            if(iiObjDel.id!=null){
                delete iiObjDel;
            }
            iiWrpList.remove(rowToRemove);
        }
    }

    //Wrapper class for Prescription Medications Object
    public class PrescriptionMediWrp{
        Public Boolean isMedicationOther{get;set;}
        public Integer index {get;set;}
        public Prescription_Medication__c record {get;set;}
        public PrescriptionMediWrp(){
            isMedicationOther = false;
            record = new Prescription_Medication__c();
        }
    }

    //Add New row to the Prescription Medications related list
    public void addNewPMObj(){
        PrescriptionMediWrp newRecord = new PrescriptionMediWrp();
        Prescription_Medication__c newPMRecord = new Prescription_Medication__c();
        newRecord.record = newPMRecord;
        newRecord.index = pmWrpList.size()-1;
        newRecord.record.Patient__c = opp.Contact__c;
        if(newRecord.index>=0){
            Prescription_Medication__c oldPMRecord = pmWrpList[newRecord.index].record;
            if(oldPMRecord.Indication__c==null && oldPMRecord.Prescribed_Dosage__c==null && oldPMRecord.Currently_Abusing_Substance__c==null && oldPMRecord.Amount_Abused__c==null && oldPMRecord.Medication__c==null&& oldPMRecord.Frequency__c==null)
                return;
        }
        pmWrpList.add(newRecord);
    }

    //Delete one row from the Prescription Medications Related List
    public void removeRowToPMList(){
        Prescription_Medication__c ObjPMDel = pmWrpList[rowToRemove].record;
        if(pmWrpList.size() == 1){
            if(ObjPMDel.Id!=null)
                delete ObjPMDel;
            ObjPMDel = new Prescription_Medication__c();
            PrescriptionMediWrp newRecord = new PrescriptionMediWrp();
            newRecord.record = ObjPMDel;
            newRecord.record.Patient__c = opp.Contact__c;
            pmWrpList[rowToRemove] = newRecord;
        }else{
            if(ObjPMDel.id!=null){
                delete ObjPMDel;
            }
            pmWrpList.remove(rowToRemove);
        }
    }

    //Wrapper class for Mental Health Symptoms Object
    public class MentalHealthSWrp{
        public Integer index {get;set;}
        public Mental_Health_Symptom__c record {get;set;}
        public MentalHealthSWrp(){
            record = new Mental_Health_Symptom__c();
        }
    }

    //Add New row to the Mental Health Symptoms related list
    public void addNewMHSObj(){
        MentalHealthSWrp newRecord = new MentalHealthSWrp();
        Mental_Health_Symptom__c newMHSRecord = new Mental_Health_Symptom__c();
        newRecord.record = newMHSRecord;
        newRecord.index = mhsWrpList.size()-1;
        if(newRecord.index>=0){
            Mental_Health_Symptom__c oldMHSRecord = mhsWrpList[newRecord.index].record;
            if(oldMHSRecord.Description__c==null)
                return;
        }
        mhsWrpList.add(newRecord);
    }

    //Delete one row from the Mental Health Symptoms Related List
    public void removeRowToMHSList(){
        Mental_Health_Symptom__c ObjMHSDel = mhsWrpList[rowToRemove].record;
        if(mhsWrpList.size() == 1){
            if(ObjMHSDel.Id!=null)
                delete ObjMHSDel;
            ObjMHSDel = new Mental_Health_Symptom__c();
            MentalHealthSWrp newRecord = new MentalHealthSWrp();
            newRecord.record = ObjMHSDel;
            mhsWrpList[rowToRemove] = newRecord;
        }else{
            if(ObjMHSDel.id!=null){
                delete ObjMHSDel;
            }
            mhsWrpList.remove(rowToRemove);
        }
    }

    //Wrapper class for Psychiatric Diagnoses Object
    public class PsychiatricDiagnosesWrp{
        public Integer index {get;set;}
        public Psychiatric_Diagnosis__c record {get;set;}
        public PsychiatricDiagnosesWrp(){
            record = new Psychiatric_Diagnosis__c();
        }
    }

    //Add New row to the Mental Health Symptoms related list
    public void addNewPDObj(){
        PsychiatricDiagnosesWrp newRecord = new PsychiatricDiagnosesWrp();
        Psychiatric_Diagnosis__c newPDRecord = new Psychiatric_Diagnosis__c();
        newRecord.record = newPDRecord;
        newRecord.record.Patient__c = opp.Contact__c;
        newRecord.index = pdWrpList.size()-1;
        if(newRecord.index>=0){
            Psychiatric_Diagnosis__c oldPDRecord = pdWrpList[newRecord.index].record;
            if(oldPDRecord.Date_of_Diagnosis__c==null && oldPDRecord.Diagnosed_By__c==null && oldPDRecord.Diagnosis__c==null)
                return;
        }
        pdWrpList.add(newRecord);
    }

    //Delete one row from the Mental Health Symptoms Related List
    public void removeRowToPDList(){
        Psychiatric_Diagnosis__c objPDDel = pdWrpList[rowToRemove].record;
        if(pdWrpList.size() == 1){
            if(objPDDel.id!=null)
                delete objPDDel;
            objPDDel = new Psychiatric_Diagnosis__c();
            PsychiatricDiagnosesWrp newRecord = new PsychiatricDiagnosesWrp();
            newRecord.record = objPDDel;
            newRecord.record.Patient__c = opp.Contact__c;
            pdWrpList[rowToRemove] = newRecord;
        }else{
            if(objPDDel.id!=null){
                delete objPDDel;
            }
            pdWrpList.remove(rowToRemove);
        }
    }

    //Wrapper class for Legal Offenses Object
    public class LegalOffensesWrp{
        public Integer index {get;set;}
        public Legal_Offense__c record {get;set;}
        public LegalOffensesWrp(){
            record = new Legal_Offense__c();
        }
    }

    //Add New row to the Legal Offenses related list
    public void addNewLOObj(){
        LegalOffensesWrp newRecord = new LegalOffensesWrp();
        Legal_Offense__c newLORecord = new Legal_Offense__c();
        newRecord.record = newLORecord;
        newRecord.index = loWrpList.size()-1;
        newRecord.record.Patient__c = opp.Contact__c;
        if(newRecord.index>=0){
            Legal_Offense__c oldLORecord = loWrpList[newRecord.index].record;
            if(oldLORecord.Date__c==null && oldLORecord.On_Parole__c==null && oldLORecord.On_Probation__c==null && oldLORecord.Registered_Sex_Offender_List__c==null && oldLORecord.Type__c==null && oldLORecord.Circumstances__c==null)
                return;
        }
        loWrpList.add(newRecord);
    }

    //Delete one row from the Legal Offenses Related List
    public void removeRowToLOList(){
        Legal_Offense__c objLODel = loWrpList[rowToRemove].record;
        if(loWrpList.size() == 1){
            if(objLODel.id!=null)
                delete objLODel;
            objLODel = new Legal_Offense__c();
            LegalOffensesWrp newRecord = new LegalOffensesWrp();
            newRecord.record = objLODel;
            newRecord.record.Patient__c = opp.Contact__c;
            loWrpList[rowToRemove] = newRecord;
        }else{
            if(objLODel.id!=null){
                delete objLODel;
            }
            loWrpList.remove(rowToRemove);
        }
    }

    //Wrapper class for Clinical Assessments Object
    public class ClinicalAssessmentsWrp{
        public Integer index {get;set;}
        public Clinical_Assessment__c record {get;set;}
        public ClinicalAssessmentsWrp(){
            record = new Clinical_Assessment__c();
        }
    }

    //Add New row to the Clinical Assessments related list
    public PageReference addNewCAObj(){
        ClinicalAssessmentsWrp newRecord = new ClinicalAssessmentsWrp();
        newRecord.record = cliAss;
        newRecord.index = caWrpList.size();
        caWrpList.add(newRecord);
        showForAbusedIns = false;
        return page.CreateOpportunity;
    }

    //Delete one row from the Risk Assessments Related List
    public void removeRowToCAList(){
        Clinical_Assessment__c objCADel = caWrpList[rowToRemove].record;
        if(objCADel.id!=null){
            delete objCADel;
        }
        caWrpList.remove(rowToRemove);
    }

    //Open New Clicnical Assessment Page
    public Pagereference newClinicalAssessment(){
        cliAss = new Clinical_Assessment__c();
        showForAbusedIns = false;
        return page.NewClinicalAssessmentOpp;
    }

    //Update existing Clinical Assessment
    public Pagereference clinicalAssessmentEdit(){
        cliAss = new Clinical_Assessment__c();
        cliAss =  caWrpList[rowToEdit].record;
        showForAbusedIns = true;
        return Page.NewClinicalAssessmentOpp;
    }
    //Return back to parent Opportunity Page
    public Pagereference updateCAObj(){
        showForAbusedIns = false;
        return Page.CreateOpportunity;
    }

    //Wrapper class for Substance Abuse History and Frequency Object
    public class SubstanceAHFWrp{
        public Integer index {get;set;}
        public Substance_Abuse_History_and_Frequency__c record {get;set;}
        public SubstanceAHFWrp(){
            record = new Substance_Abuse_History_and_Frequency__c();
        }
    }

    //Add New row to the Substance Abuse History and Frequency related list
    public void addNewSAHFObj(){
        SubstanceAHFWrp newRecord = new SubstanceAHFWrp();
        Substance_Abuse_History_and_Frequency__c newSAHFRecord = new Substance_Abuse_History_and_Frequency__c();
        newRecord.record = newSAHFRecord;
        newRecord.index = sahfWrpList.size()-1;
        if(newRecord.index>=0){
            Substance_Abuse_History_and_Frequency__c oldSAHFRecord = sahfWrpList[newRecord.index].record;
            if(oldSAHFRecord.Cigarettes_Tobacco_Amount__c==null && oldSAHFRecord.Alcohol_Amount__c==null && oldSAHFRecord.Marijuana_Amount__c==null && oldSAHFRecord.Opiates_Amount__c==null)
                return;
        }
        sahfWrpList.add(newRecord);
    }

    //Delete one row from the Substance Abuse History and Frequency Related List
    public void removeRowToSAHFList(){
        Substance_Abuse_History_and_Frequency__c objSAHFDel = sahfWrpList[rowToRemove].record;
        if(sahfWrpList.size() == 1){
            if(objSAHFDel.id!=null)
                delete objSAHFDel;
            objSAHFDel = new Substance_Abuse_History_and_Frequency__c();
            SubstanceAHFWrp newRecord = new SubstanceAHFWrp();
            newRecord.record = objSAHFDel;
            sahfWrpList[rowToRemove] = newRecord;
        }else{
            if(objSAHFDel.id!=null){
                delete objSAHFDel;
            }
            sahfWrpList.remove(rowToRemove);
        }
    }

    //Wrapper class for Patient Contacts Object
    public class PatientContactsWrp{
        public Integer index {get;set;}
        public Patient_Contact__c record {get;set;}
        public Integer UniqueNmbr;
        public PatientContactsWrp(){
            UniqueNmbr = 0;
            record = new Patient_Contact__c();
        }
    }

    public pagereference patientcontact(){
        patcon = new Patient_Contact__c();
        isForUpdate = false;
        patcon.Opportunity__c=oppid;
        patcon.Contact__c = opp.Contact__c;
        isFromPatIns = false;
        return page.NewPatContactPageOpp;
    }

    public pagereference patientcontactEdit(){
        patcon = new Patient_Contact__c();
        patcon =  pcWrpList[rowToEdit].record;
        isForUpdate = true;
        isFromPatIns = false;
        return page.NewPatContactPageOpp;
    }

    public pagereference updatepatientcontactObj(){
        isForUpdate = false;
        return page.CreateOpportunity;
    }

    //Add New row to the Patient Contacts related list
    public Pagereference addNewPCObj(){
        PatientContactsWrp newRecord = new PatientContactsWrp();
        newRecord.record = patcon;
        newRecord.index = pcWrpList.size();
        newRecord.UniqueNmbr = patConCounter++;
        isForUpdate = false;
        pcWrpList.add(newRecord);
        return page.CreateOpportunity;
    }

    //Delete one row from the Patient Contacts Related List
    public void removeRowToPCList(){
        Patient_Contact__c objPCDel = pcWrpList[rowToRemove].record;
        if(objPCDel.id!=null){
            delete objPCDel;
        }
        pcWrpList.remove(rowToRemove);

    }

    //Wrapper class for Medical Equipment Object
    public class MedicalEquipmentWrp{
        public Integer index {get;set;}
        public Medical_Equipment__c record {get;set;}
        public MedicalEquipmentWrp(){
            record = new Medical_Equipment__c();
        }
    }

    //Add New row to the Medical Equipment related list
    public void addNewMEObj(){
        MedicalEquipmentWrp newRecord = new MedicalEquipmentWrp();
        Medical_Equipment__c newMERecord = new Medical_Equipment__c();
        newRecord.record = newMERecord;
        newRecord.index = meWrpList.size()-1;
        if(newRecord.index>=0){
            Medical_Equipment__c oldMERecord = meWrpList[newRecord.index].record;
            if(oldMERecord.Equipment_Type__c==null && oldMERecord.Are_You_Able_to_Walk_Up_Down_Stairs__c==null && oldMERecord.Are_You_Able_to_Walk_on_Rugged_Terrain__c==null && oldMERecord.Are_You_Able_to_Walk_a_Mile__c==null)
                return;
        }
        meWrpList.add(newRecord);
    }

    //Delete one row from the Medical Equipment Related List
    public void removeRowToMEList(){
        Medical_Equipment__c objMEDel = meWrpList[rowToRemove].record;
        if(meWrpList.size() == 1){
            if(objMEDel.id!=null)
                delete objMEDel;
            objMEDel = new Medical_Equipment__c();
            MedicalEquipmentWrp newRecord = new MedicalEquipmentWrp();
            newRecord.record = objMEDel;
            meWrpList[rowToRemove] = newRecord;
        }else{
            if(objMEDel.id!=null){
                delete objMEDel;
            }
            meWrpList.remove(rowToRemove);
        }
    }

    /** Patient Insurance New button START ****/
    //Wrapper class for Patient Insurance Object
    public class PatientInsuranceWrp{
        public Integer index {get;set;}
        public Patient_Insurance__c record {get;set;}
        public String patConUniqueNo;
        public String patConName {get;set;}
        public String patConPhone {get;set;}
        public String patConEmployer;
        public PatientInsuranceWrp(){
            patConName = '';
            patConPhone = '';
            patConEmployer = '';
            record = new Patient_Insurance__c();
        }
    }

    public pagereference newPatientInsurance(){
        patIns = new Patient_Insurance__c();
        showForAbusedIns = false;
        if(opp.Contact__c!=null){
            patIns.Patient__c = opp.Contact__c;
            patIns.Opportunity__c = opp.Id;
            patIns.Patient_Social_Security_Number__c = opp.Contact__r.Social_Security_Number__c;
        }
        patIns.Policy_Effective_Date__c = Date.newInstance((System.Today()).year(), 1, 1);
        patIns.Renewal_Date__c = Date.newInstance((System.Today().addYears(1)).year(), 1, 1);
        patIns.Term_Date__c = Date.newInstance((System.Today()).year(), 12, 31);
        return page.NewPatientInsPageOpp;
    }

    public pagereference patientInsuranceEdit(){
        patIns = new Patient_Insurance__c();
        patIns =  piWrpList[rowToEdit].record;
        if(patIns.Subscriber_is_Patient__c){
            Selectedsubscriber = patIns.Patient__c;
        } else {
            Selectedsubscriber = piWrpList[rowToEdit].patConUniqueNo;
        }
        patconEmployer = piWrpList[rowToEdit].patconEmployer;
        showForAbusedIns = true;
        OtherInsCom();
        return page.NewPatientInsPageOpp;
    }

    public pagereference updatePatientIontactObj(){
        if(!showForAbusedIns && resCrtdPatConIds.size()>0){
            for(String uniqueNo:new List<String>(resCrtdPatConIds)){
                for(integer i=0;i<pcWrpList.size();i++){
                    if(uniqueNo==''+(pcWrpList[i].UniqueNmbr)){
                        pcWrpList.remove(i);
                        break;
                    }
                }
            }
            resCrtdPatConIds.clear();
        }
        if(showForAbusedIns){
            piWrpList[rowToEdit] = updatedPatient();
        }
        if(!IOIC){
                patIns.Other_Insurance_Company__c = null;
            }
        showForAbusedIns = false;
        return page.CreateOpportunity;
    }


    public void conDetail(){
        Integer age = 0;
        if(patIns.Patient__c!= null){
            con = [Select Id, Age__c,Birthdate,FirstName,LastName,Social_Security_Number__c, Phone from contact where Id =: patIns.Patient__c];
            patIns.Patient_Social_Security_Number__c  = con.Social_Security_Number__c;
        }
        if(con.Birthdate != null){
            age = calculateYears(con.Birthdate);
            if(age >0){
                conAge = age;
            } else {
                conAge = 0;
            }
        }
    }
    //Calculate Age Method
    public Integer calculateYears(Date dob){
        date patientDOB = dob;
        Integer monthsCal = 0;
        Integer returnYears = 0;
        Integer cYear = System.Today().year();
        Integer cMnth = System.Today().month();
        Integer cDate = System.Today().day();

        Integer pYear = (patientDOB).year();
        Integer pMnth = (patientDOB).month();
        Integer pDate = (patientDOB).day();
        date currentDate = system.today();
        //  birthdate = today
        if(patientDOB == currentDate){
            monthsCal = 0;
            returnYears = 0;
        } else if(patientDOB > currentDate){
            return null;
        //  birthday < today
        } else {
            monthsCal = patientDOB.monthsBetween(currentDate);
            if (currentDate.day() < patientDOB.day()) monthsCal--;
            returnYears = monthsCal/12;
        }
        //  will turn 26 years old in the current year
        if(returnYears == 25){
            if(pMnth > cMnth){
                redBoolead = true;
            } else if(pMnth == cMnth && pDate >= cDate){
                redBoolead = true;
            }
        } else { redBoolead = false; }
        if(returnYears > 0){
            return returnYears;
        }
        return null;
    }

    public List<SelectOption> getSubscriberName(){
        List<SelectOption> subscriberName  = new List<SelectOption>();

        String OptyId = patIns.Opportunity__c;
        subscriberName.add(new SelectOption('','--None--'));
        String name = '';
        if(con==null || con.Id==null)
            conDetail();
        if(con!=null && con.Id!=null){
            if(con.FirstName !=null && con.FirstName !=''){
                name = con.FirstName +' ';
            }
            name = name + (con.LastName+' (Patient)');
            subscriberName.add(new SelectOption(con.Id, name));
        }
        if(pcWrpList!=null && pcWrpList.size()>0){
            for(PatientContactsWrp pcWrp:pcWrpList){
                name='';
                if(pcWrp.record.First_Name__c !=null && pcWrp.record.First_Name__c !=''){
                    name = pcWrp.record.First_Name__c +' ';
                }
                if(pcWrp.record.Last_Name__c !=null && pcWrp.record.Last_Name__c !=''){
                    name = name + (pcWrp.record.Last_Name__c);
                }
                if(name !=''){
                    if(pcWrp.record.Id!=null){
                        subscriberName.add(new SelectOption(pcWrp.record.Id, name));
                    } else {
                        subscriberName.add(new SelectOption(''+pcWrp.UniqueNmbr, name));
                    }
                }
            }
        }
        return subscriberName;
    }

    public void SubscriberEmployer(){
        if(Selectedsubscriber !=null && Selectedsubscriber != ''){

            patconEmployer = '';
            if(Selectedsubscriber.startsWith(Contact.sObjectType.getDescribe().getKeyPrefix())){
                patIns.Subscriber_is_Patient__c = true;
            } else {
                patIns.Subscriber_is_Patient__c = false;
                for(PatientContactsWrp pcw:pcWrpList){
                    if(pcw.UniqueNmbr+''==Selectedsubscriber || pcw.record.Id+''==Selectedsubscriber){
                        patconEmployer = pcw.record.Employer__c;
                        break;
                    }
                }
            }

        } else {
            patconEmployer = '';
            patIns.Subscriber_is_Patient__c = false;
        }
    }

    public List<SelectOption> getInsuranceCompany(){
        List<SelectOption> InsuranceCompany  = new List<SelectOption>();
        String name ;
        //if(oppid!=null || patIns.Opportunity__c != null){
            InsuranceCompany.add(new SelectOption('','--None--'));
            for(Account acc:[SELECT Id,  Name FROM Account where RecordType.Name = 'Insurance Company' ORDER BY Name ASC]){
                if(acc.Name  != null){
                    InsuranceCompany.add(new SelectOption(acc.Id,acc.name));
                }
            }
       // }
        return InsuranceCompany;
    }

    public PatientInsuranceWrp updatedPatient(){
        PatientInsuranceWrp newRecord = new PatientInsuranceWrp();
        if(Selectedsubscriber !=null && Selectedsubscriber != ''){
            String name = '';
            if(Selectedsubscriber.startsWith(Contact.sObjectType.getDescribe().getKeyPrefix())){
                patIns.Subscriber__c = null;
                if(con.FirstName !=null && con.FirstName !=''){
                    name = con.FirstName +' ';
                }
                name = name + (con.LastName+' (Patient)');
                newRecord.patConName = name;
                if(con.Phone != null){
                    newRecord.patConPhone = con.Phone;
                }

            } else {
                for(PatientContactsWrp pcw:pcWrpList){
                    if(pcw.UniqueNmbr+''==Selectedsubscriber || pcw.record.Id+''==Selectedsubscriber){
                        if(pcw.record.First_Name__c !=null && pcw.record.First_Name__c !=''){
                            name = pcw.record.First_Name__c +' ';
                        }
                        if(pcw.record.Last_Name__c !=null && pcw.record.Last_Name__c !=''){
                            name = name + pcw.record.Last_Name__c +' ';
                        }
                        newRecord.patConName = name;
                        newRecord.patConEmployer = pcw.record.Employer__c;
                        newRecord.patConUniqueNo = Selectedsubscriber;
                        break;
                    }
                }
            }
            if(!IOIC){
                patIns.Other_Insurance_Company__c = null;
            }
            //upsert patIns;
        }

        newRecord.record = patIns;
        return newRecord;
    }
    //Add New row to the Patient Insurance related list
    public Pagereference addNewPIObj(){
        PatientInsuranceWrp newRecord = updatedPatient();
        newRecord.index = piWrpList.size();
        showForAbusedIns = false;
        piWrpList.add(newRecord);
        resCrtdPatConIds.clear();
        return page.CreateOpportunity;
    }

    //Delete one row from the Patient Insurance Related List
    public void removeRowToPIList(){
        Patient_Insurance__c objPIDel = piWrpList[rowToRemove].record;
        if(piWrpList.size() == 1){
            if(objPIDel.id!=null)
                delete objPIDel;
            objPIDel = new Patient_Insurance__c();
            PatientInsuranceWrp newRecord = new PatientInsuranceWrp();
            newRecord.record = objPIDel;
            piWrpList[rowToRemove] = newRecord;
        }else{
            if(objPIDel.id!=null){
                delete objPIDel;
            }
            piWrpList.remove(rowToRemove);
        }
    }

    public PageReference patConFromPatIns(){
        patcon = new Patient_Contact__c();
        patcon.Opportunity__c = opp.Id;
        patcon.Contact__c = opp.Contact__c;
        isForUpdate = false;
        isFromPatIns = true;
        return Page.NewPatContactPageOpp;
    }

    //New Patient Contacts from Patient Insurance
    public Pagereference addNewPCObjInPI(){
        PatientContactsWrp newRecord = new PatientContactsWrp();
        newRecord.record = patcon;
        newRecord.index = pcWrpList.size();
        newRecord.UniqueNmbr = patConCounter++;
        isForUpdate = false;
        pcWrpList.add(newRecord);
        Selectedsubscriber = ''+newRecord.UniqueNmbr;
        patconEmployer = patcon.Employer__c;
        resCrtdPatConIds.add(''+newRecord.UniqueNmbr);
        patIns.Subscriber_is_Patient__c = false;
        return Page.NewPatientInsPageOpp;
    }

    public PageReference cancelPatConFrmPatIns(){
        isFromPatIns = false;
        return Page.NewPatientInsPageOpp;
    }

    /** Patient Insurance New button END ****/
    //Wrapper class for Infectious Diseases Object
    public class InfectiousDiseasesWrp{
        public Integer index {get;set;}
        public Infectious_Disease__c record {get;set;}
        public InfectiousDiseasesWrp(){
            record = new Infectious_Disease__c();
        }
    }

    //Add New row to the Infectious Diseases related list
    public void addNewIDObj(){
        InfectiousDiseasesWrp newRecord = new InfectiousDiseasesWrp();
        Infectious_Disease__c newIDRecord = new Infectious_Disease__c();
        newRecord.record = newIDRecord;
        newRecord.index = idWrpList.size()-1;
        if(newRecord.index>=0){
            Infectious_Disease__c oldLORecord = idWrpList[newRecord.index].record;
            if(oldLORecord.Infectious_Disease__c==null && oldLORecord.Currently_Symptomatic__c==null && oldLORecord.Currently_Taking_Medications__c==null && oldLORecord.Regular_Follow_Up_Recommended__c==null && oldLORecord.Have_You_Followed_Up_with_Appointments__c==null && oldLORecord.Diagnosis_Date__c==null)
                return;
        }
        idWrpList.add(newRecord);
    }

    //Delete one row from the Infectious Diseases Related List
    public void removeRowToIDList(){
        Infectious_Disease__c objIDDel = idWrpList[rowToRemove].record;
        if(idWrpList.size() == 1){
            if(objIDDel.id!=null)
                delete objIDDel;
            objIDDel = new Infectious_Disease__c();
            InfectiousDiseasesWrp newRecord = new InfectiousDiseasesWrp();
            newRecord.record = objIDDel;
            idWrpList[rowToRemove] = newRecord;
        }else{
            if(objIDDel.id!=null){
                delete objIDDel;
            }
            idWrpList.remove(rowToRemove);
        }
    }

        //Wrapper class for Major_Medical_Issue__c object
        public class MajorMedicalIssuesWrp{
            public Integer index {get;set;}
            public Major_Medical_Issue__c record {get;set;}
            public MajorMedicalIssuesWrp(){
                record = new Major_Medical_Issue__c();
            }
        }

    //Wrapper class for Case Object
    public class CaseWrp{
        public Integer index {get;set;}
        public Case record {get;set;}
        public CaseWrp(){
            record = new Case();
        }
    }

    //Add New row to the Case related list
    public void addNewCaseObj(){
        CaseWrp newRecord = new CaseWrp();
        Case newDOCRecord = new Case();
        newRecord.record = newDOCRecord;
        newRecord.index = CaseWrpList.size()-1;
        if(newRecord.index>=0){
            Case oldLORecord = CaseWrpList[newRecord.index].record;
            if(oldLORecord.Status==null && oldLORecord.Red_Flag_Information__c==null && oldLORecord.Origin==null && oldLORecord.Priority==null)
                return;
        }
        CaseWrpList.add(newRecord);
    }

    //Delete one row from the Case Related List
    public void removeRowToCaseList(){
        Case objCaseDel = CaseWrpList[rowToRemove].record;
        if(CaseWrpList.size() == 1){
            if(objCaseDel.id!=null)
                delete objCaseDel;
            objCaseDel = new Case();
            CaseWrp newRecord = new CaseWrp();
            newRecord.record = objCaseDel;
            CaseWrpList[rowToRemove] = newRecord;
        }else{
            if(objCaseDel.id!=null){
                delete objCaseDel;
            }
            CaseWrpList.remove(rowToRemove);
        }
    }

    //Edit Case List
    public PageReference editCase(){
        Case objCse = CaseWrpList[rowToEdit].record;
        PageReference page = new PageReference('/'+objCse.Id+'/e?retURL=%2F/apex/CreateOpportunity?id='+opp.id);
        return page;
    }

    //Wrapper class for Pay_Agreement_Worksheet__c Object
    public class PayAgreementWorksheetsWrp{
        public Integer index {get;set;}
        public Pay_Agreement_Worksheet__c record {get;set;}
        public PayAgreementWorksheetsWrp(){
            record = new Pay_Agreement_Worksheet__c();
        }
    }

    //Add New row to the Pay_Agreement_Worksheet__c related list
    public void addNewPayAgreementWorksheetObj(){
        PayAgreementWorksheetsWrp newRecord = new PayAgreementWorksheetsWrp();
        Pay_Agreement_Worksheet__c newPAWSRecord = new Pay_Agreement_Worksheet__c();
        newRecord.record = newPAWSRecord;
        newRecord.index = PayAgreementWorksheetWrpList.size()-1;
        if(newRecord.index>=0){
            Pay_Agreement_Worksheet__c oldLORecord = PayAgreementWorksheetWrpList[newRecord.index].record;
            if(oldLORecord.Deductible_Included_in_OOP__c==null && oldLORecord.Num_Days_Detox_DTX__c==null && oldLORecord.Ancillary_Fees__c==null)
                return;
        }
        PayAgreementWorksheetWrpList.add(newRecord);
    }

    //Delete one row from the Pay_Agreement_Worksheet__c Related List
    public void removeRowToPayAgreementWorksheetList(){
        Pay_Agreement_Worksheet__c objPAWSDel = PayAgreementWorksheetWrpList[rowToRemove].record;
        if(PayAgreementWorksheetWrpList.size() == 1){
            if(objPAWSDel.id!=null)
                delete objPAWSDel;
            objPAWSDel = new Pay_Agreement_Worksheet__c();
            PayAgreementWorksheetsWrp newRecord = new PayAgreementWorksheetsWrp();
            newRecord.record = objPAWSDel;
            PayAgreementWorksheetWrpList[rowToRemove] = newRecord;
        }else{
            if(objPAWSDel.id!=null){
                delete objPAWSDel;
            }
            PayAgreementWorksheetWrpList.remove(rowToRemove);
        }
    }

    //Edit Pay_Agreement_Worksheet__c
    public PageReference editPayAWSheet(){
        Pay_Agreement_Worksheet__c objPAWS = PayAgreementWorksheetWrpList[rowToEdit].record;
        PageReference page = new PageReference('/apex/PayAgreementWorksheetPage?id='+objPAWS.Id+'&retURL=%2F/apex/CreateOpportunity?id=/'+opp.id);
        //PageReference page = new PageReference('/'+objPAWS.Id+'/e?retURL=%2F/apex/CreateOpportunity/'+opp.id);
        return page;
    }

    //Wrapper class for Note_Comment__c Object
    public class NoteCommentWrp{
        public Integer index {get;set;}
        public Note_Comment__c record {get;set;}
        public String noteComment {get;set;}
        public NoteCommentWrp(String oppId){
            record = new Note_Comment__c();
            record.Opportunity__c = oppId;
        }
    }

    //Add New row to the Note_Comment__c related list
    public void addNewNoteCommentObj(){
        NoteCommentWrp newRecord = new NoteCommentWrp(oppId);
        Note_Comment__c newNoteCommentRecord = new Note_Comment__c();
        newRecord.record = newNoteCommentRecord;
        newRecord.index = NoteCommentWrpList.size()-1;
        if(newRecord.index>=0){
            NoteCommentWrp oldRecord = NoteCommentWrpList[newRecord.index];
            Note_Comment__c oldLORecord = oldRecord.record;
            if((oldRecord.noteComment==null || oldRecord.noteComment=='') && oldLORecord.Email_To__c==null)
                return;
        }
        NoteCommentWrpList.add(newRecord);
    }

    //Delete one row from the Note_Comment__c Related List
    public void removeRowToNoteCommentList(){
        Note_Comment__c objNCDel = NoteCommentWrpList[rowToRemove].record;
        if(NoteCommentWrpList.size() == 1){
            if(objNCDel.id!=null)
                delete objNCDel;
            objNCDel = new Note_Comment__c();
            NoteCommentWrp newRecord = new NoteCommentWrp(oppId);
            newRecord.record = objNCDel;
            NoteCommentWrpList[rowToRemove] = newRecord;
        }else{
            if(objNCDel.id!=null){
                delete objNCDel;
            }
            NoteCommentWrpList.remove(rowToRemove);
        }
    }

     //Wrapper class for Quote Object
  public class QuotesWrp{
        public Integer index {get;set;}
        public Quote record {get;set;}
        public QuotesWrp(){
            record = new Quote();
        }
    }

    //Delete one row from the Quote Related List
    public void removeRowToQuoteList(){
        Quote objQtDel = QuotesWrpList[rowToRemove].record;
    if(QuotesWrpList.size() == 1){
      if(objQtDel.id!=null)
        delete objQtDel;
      objQtDel = new Quote();
      QuotesWrp newRecord = new QuotesWrp();
      newRecord.record = objQtDel;
      QuotesWrpList[rowToRemove] = newRecord;
    }else{
      if(objQtDel.id!=null){
        delete objQtDel;
      }
      QuotesWrpList.remove(rowToRemove);
    }
    }

  //Edit Quote
  public PageReference editQuote(){
        Quote objQtDel = QuotesWrpList[rowToEdit].record;
        PageReference page = new PageReference('/'+objQtDel.Id+'/e?retURL=%2F/apex/CreateOpportunity?id='+opp.id);
        return page;
    }

    //Wrapper class for Trip__c Object
    public class TripWrp{
        public Integer index {get;set;}
        public Trip__c record {get;set;}
        public TripWrp(){
            record = new Trip__c();
        }
    }

    //Add New row to the Trip__c related list
    public void addNewTripObj(){
        TripWrp newRecord = new TripWrp();
        Trip__c newTripRecord = new Trip__c();
        newRecord.record = newTripRecord;
        newRecord.index = TripWrpList.size()-1;
        if(newRecord.index>=0){
            Trip__c oldLORecord = TripWrpList[newRecord.index].record;
            if(oldLORecord.Trip_Name__c==null && oldLORecord.Modified_Date_Time__c==null && oldLORecord.Description__c==null && oldLORecord.Booking_Source__c==null)
                return;
        }
        TripWrpList.add(newRecord);
    }

    //Delete one row from the Trip__c Related List
    public void removeRowToTripList(){
        Trip__c objTpDel = TripWrpList[rowToRemove].record;
        if(TripWrpList.size() == 1){
            if(objTpDel.id!=null)
                delete objTpDel;
            objTpDel = new Trip__c();
            TripWrp newRecord = new TripWrp();
            newRecord.record = objTpDel;
            TripWrpList[rowToRemove] = newRecord;
        }else{
            if(objTpDel.id!=null){
                delete objTpDel;
            }
            TripWrpList.remove(rowToRemove);
        }
    }

    public PageReference editTrip(){
        Trip__c objTpDel = TripWrpList[rowToEdit].record;
        PageReference page = new PageReference('/'+objTpDel.Id+'/e?retURL=%2F/apex/CreateOpportunity?id='+opp.id);
        return page;
    }

    //Wrapper class for Referral__c Object
    public class ReferralWrp{
        public Integer index {get;set;}
        public Referral__c record {get;set;}
        public ReferralWrp(){
            record = new Referral__c();
        }
    }



    //Add New row to the Referral__c related list
    public void addNewReferralObj(){
        ReferralWrp newRecord = new ReferralWrp();
        Referral__c newReferralRecord = new Referral__c();
        newRecord.record = newReferralRecord;
        newRecord.index = ReferralWrpList.size()-1;
        if(newRecord.index>=0){
            Referral__c oldLORecord = ReferralWrpList[newRecord.index].record;
            if(oldLORecord.Patient_Name__c==null && oldLORecord.Account__c==null && oldLORecord.Consentor__c==null && oldLORecord.Referral_Reason__c==null)
                return;
        }
        ReferralWrpList.add(newRecord);
    }

    //Delete one row from the Referral__c Related List
    public void removeRowToReferralList(){
        Referral__c objRefDel = ReferralWrpList[rowToRemove].record;
        if(ReferralWrpList.size() == 1){
            if(objRefDel.id!=null)
                delete objRefDel;
            objRefDel = new Referral__c();
            ReferralWrp newRecord = new ReferralWrp();
            newRecord.record = objRefDel;
            ReferralWrpList[rowToRemove] = newRecord;
        }else{
            if(objRefDel.id!=null){
                delete objRefDel;
            }
            ReferralWrpList.remove(rowToRemove);
        }
    }

    //Edit Referal List
    public PageReference editReferral(){
        Referral__c objRfl = ReferralWrpList[rowToEdit].record;
        PageReference page = new PageReference('/'+objRfl.Id+'/e?retURL=%2F/apex/CreateOpportunity?id='+opp.id);
        return page;
    }

    // for getting probability value
    public PageReference changeStageName() {
        if (probabilityStageNameMap == null) {
            probabilityStageNameMap = new Map<String, Decimal>();
            for (OpportunityStage oppStage : [Select MasterLabel, DefaultProbability From OpportunityStage]) {
                probabilityStageNameMap.put(oppStage.MasterLabel, oppStage.DefaultProbability);
            }
        }

        if (probabilityStageNameMap.containsKey(stageValue)) {
            opp.Probability = probabilityStageNameMap.get(stageValue);
        }
        return null;
    }

    // Used as dummy action for rendering sections
    public void renderedSection() {
        System.debug('renderedSection');
    }

    public pagereference changeUsr(){
        PageReference orderPage = new PageReference('/'+opp.id+'/a?retURL=%2F/apex/CreateOpportunity?id='+opp.id);
        orderPage.setRedirect(true);
        return orderPage;
    }

    public void showPopup(){
        displayPopup = true;
        System.debug('displayPopup>>>'+displayPopup);
    }

    public void closePopup() {
        displayPopup = false;
    }

    public PageReference redirectPopup(){
        displayPopup = false;
        return null;
    }


    public List<SelectOption> getStages(){
        List<SelectOption> listStage = new List<SelectOption>();
         Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        Map<String, String> stageMap = new Map<String, String>();
        for(OpportunityStage os : [Select ApiName,Description, ForecastCategory, IsActive, IsClosed, IsWon, MasterLabel, ForecastCategoryName, DefaultProbability From OpportunityStage where (isclosed != true or IsWon = true)  and IsActive = true ORDER BY DefaultProbability ASC]){
             listStage.add(new SelectOption(os.MasterLabel, os.MasterLabel));
        }
        return listStage;

    }

    public List<SelectOption> getFRNFacilities(){
        List<SelectOption> FacilityList = new List<SelectOption>();
        String recId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FRN Facility').getRecordTypeId();
        FacilityList.add(new SelectOption('','--None--'));
        for(Account acc : [Select Id,Name from Account where RecordTypeId =: recId Order by Name]){
            FacilityList.add(new SelectOption(acc.Id,acc.Name));
        }
        return FacilityList;
    }
    Public void medicationOthers(){

        Set<string> medicationSet = new Set<string>();
        for(PrescriptionMediWrp pm : pmWrpList){
            medicationSet.add(pm.record.Medication__c);
        }
        Map<String, Medication__c> medicationMap= new Map<String, Medication__c>([Select id,Is_Other_Medication__c from Medication__c where id IN: medicationSet]);
        for(PrescriptionMediWrp pm : pmWrpList){
            if(medicationMap.containsKey(pm.record.Medication__c))
                pm.isMedicationOther = medicationMap.get(pm.record.Medication__c).Is_Other_Medication__c;
        }
    }

    public void OtherInsCom(){
        IOIC = false;
        if(patIns.Insurance_Company__c != null){
            Account acct = [select id, Is_Other_Insurance_Company__c from Account WHERE Id =: patIns.Insurance_Company__c];
            if(acct.Is_Other_Insurance_Company__c){
                IOIC = true;
            }else{
                IOIC = false;
            }
        }
    }

    // method to redirect to error page if record is locked
    public PageReference redirectIfLocked() {
        if(oppId != null) {
            return RecordLockUtility.redirectIfLocked(oppId);
        }
        else  {
            return null;
        }
    }

    // method to create list of infectious diseases prior to creation of Opportunity
    public List<InfectiousDiseasesWrp> createDiseaseRecordlist() {
        List<Schema.PicklistEntry> diseasestypeList = new List<Schema.PicklistEntry>();
        diseasestypeList = Infectious_Disease__c.Infectious_Disease__c.getDescribe().getPicklistValues();
        InfectiousDiseasesWrp idWrp;
        for( Schema.PicklistEntry f : diseasestypeList){
            Infectious_Disease__c InD = new Infectious_Disease__c();
            idWrp = new InfectiousDiseasesWrp();
            InD.Infectious_Disease__c= string.valueof(f.getLabel());
            InD.Diagnosed__c= '';
            idWrp.record = InD;
            idWrp.index = idWrpList.size()-1;
            idWrpList.add(idWrp);
        }
        return idWrpList;
    }

    // method to create list of Medical equipment prior to creation of Opportunity
    public List<MedicalEquipmentWrp> createEquipmntRecordlist() {
        List<Schema.PicklistEntry> equipmntTypeList = new List<Schema.PicklistEntry>();
        equipmntTypeList = Medical_Equipment__c.Equipment_Type__c.getDescribe().getPicklistValues();
        MedicalEquipmentWrp medEquipemntWrp;
        for( Schema.PicklistEntry f : equipmntTypeList){
            Medical_Equipment__c medEqipmnt = new Medical_Equipment__c();
            medEquipemntWrp = new MedicalEquipmentWrp();
            medEqipmnt.Equipment_Type__c = string.valueof(f.getLabel());
            medEquipemntWrp.record = medEqipmnt;
            medEquipemntWrp.index = meWrpList.size()-1;
            meWrpList.add(medEquipemntWrp);
        }
        return meWrpList;
    }

    // method to create list of major medical issues prior to creation of Opportunity
    public List<MajorMedicalIssuesWrp> createMedIssueRecordlist() {
        List<Schema.PicklistEntry> medIssuestypeList = new List<Schema.PicklistEntry>();
        medIssuestypeList = Major_Medical_Issue__c.Major_Medical_Issue__c.getDescribe().getPicklistValues();
        MajorMedicalIssuesWrp issueWrp;
        for( Schema.PicklistEntry f : medIssuestypeList){
            Major_Medical_Issue__c issue = new Major_Medical_Issue__c();
            issueWrp = new MajorMedicalIssuesWrp();
            issue.Major_Medical_Issue__c = string.valueof(f.getLabel());
            issueWrp.record = issue;
            issueWrp.index = mmiWrpList.size()-1;
            mmiWrpList.add(issueWrp);
        }
        return mmiWrpList;
    }

    //IOP Specific Start

    public static final String SOBER_ANSWER_YES = 'Yes';

    public Opportunity cleanIOPFields(Opportunity patientFile){
        if( patientFile.Step_Down__c != true ){
            patientFile.Transferring_Facility__c = null;
        }

        if(     patientFile.Sober_Living_Selected__c == null
            ||  SOBER_ANSWER_YES.equalsIgnoreCase(patientFile.Sober_Living_Selected__c) == false
        ){
            patientFile.Sober_Living_Facility__c = null;
        }


        return patientFile;
    }

    //IOP Specific Stop

    //util methods
    public static String getContactName(Opportunity opp){
        String finalName;
        if(opp.Contact__r.FirstName!=null && opp.Contact__r.FirstName!=''){
            finalName = opp.Contact__r.FirstName;
        }
        finalName = (finalName!=null) ? finalName+' '+opp.Contact__r.LastName : opp.Contact__r.LastName;
        return finalName;
    }
}