@isTest
public class CreateOpportunityExtTest{
    
    static testMethod void Test1(){     
        RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Residential Treatment'];
        Opportunity opp1 = new Opportunity(Name = 'Test1',Referral_Source_Unknown_Details__c= 'test', Alumni_Referral_Source__c= 'Online', StageName = 'Qualification',Probability = 10,LeadSource = 'Professional',OwnerId = UserInfo.getUserId(),CloseDate =  Date.today(),RecordTypeId = rc1.id, Have_You_Ever_Purged_or_Forced_Throw_Up__c= 'Yes');
        insert opp1;
        
        contact con = new contact();
        con.LastName = 'Test';
        con.Birthdate = System.Today();
        con.FirstName = 'Test';
        con.Social_Security_Number__c = 'Test';
        insert con;
        
         // Patient_Insurance__c pi = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp1.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today());
        
        
        Abused_Substance__c ascc = new Abused_Substance__c(Opportunity__c = opp1.id, Substance__c = 'test');
        insert ascc;
        update ascc;

        RecordType rc = [select id from  RecordType where SobjectType='Opportunity' AND Name='Residential Treatment'];
        Opportunity opp = new Opportunity(Name = 'Test',StageName = 'Qualification',OwnerId = UserInfo.getUserId(),Referral_Source_Unknown_Details__c= 'test', Alumni_Referral_Source__c= 'Online',LeadSource = 'Professional', Probability = 10,CloseDate =  Date.today(),RecordTypeId = rc.id, Have_You_Ever_Purged_or_Forced_Throw_Up__c= 'Yes');
        //insert opp;
       
        Illness_Injury__c ii = new Illness_Injury__c(Opportunity__c = opp1.id);
        insert ii;
       
        Major_Medical_Issue__c mmi = new Major_Medical_Issue__c(Opportunity__c = opp1.id, Major_Medical_Issue__c= 'Stroke');
        insert mmi;
        update mmi;
        
        Patient_Contact__c pc = new Patient_Contact__c(Opportunity__c = opp1.id, Contact__c = con.id, First_Name__c = 'test', Last_Name__c = 'test');
        insert pc;
        update pc;
        
        Patient_Insurance__c pi = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp1.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today(),Patient__c= Con.id,Subscriber_is_Patient__c=True,Subscriber__c=pc.Id);
        insert pi;
        update pi;
        
        
        Account acc = new Account();
            acc.Name = 'test';
            insert acc;
        
        
        Insurance_Benefit__c ib = new Insurance_Benefit__c(Patient_Insurance__c=pi.id, 
                                                           Disposition__c = 'Benefits Available',
                                                           Applicable_For_Year__c = String.valueOf(System.Today().Year()));
            insert ib;
        
        
        Pay_Agreement_Worksheet__c paw = new Pay_Agreement_Worksheet__c(Opportunity__c = opp1.id, Insurance_Benefit__c=ib.id);
            insert paw;
        
        
        Facility_Program__c fp = new Facility_Program__c(Name = 'test', FRN_Facility__c = acc.id);
            insert fp;        
        
        Quote quo = new Quote();
            quo.Name = 'test';
            quo.OpportunityId = opp1.Id;
            quo.FRN_Facility__c = acc.Id;
            quo.Insurance_Company__c = acc.Id;
            quo.Facility_Program__c = fp.Id;
            quo.Pay_Agreement_Worksheet__c = paw.Id;
            quo.Insurance_Company_Contract_Type__c = 'In Network';
            insert quo;        
        
        Online_Search_Term__c OST = new Online_Search_Term__c(Name = 'Black Bear IOP');
        insert OST;
        
        Referral__c ref = new Referral__c(Patient_Name__c='test', Account__c= acc.Id,Consentor__c= con.Id, Referral_Reason__c='BCBS Fed',Opportunity__c= Opp1.Id);
        insert ref;
    
        ApexPages.StandardController sc = new ApexPages.StandardController (opp1);
        PageReference pr = Page.CreateOpportunity;
               
        Test.setCurrentPage(pr);
        pr.getParameters().put('Id',opp1.Id);
        pr.getParameters().put('about',OST.Id);
        pr.getParameters().put('retURL','test.test.test.test.login.salesforce.com/'+con.Id);
        CreateOpportunityExt coe = new CreateOpportunityExt(sc);
        coe.rowToEdit=0;
        
        coe.addNewCAObj();
        coe.addNewReferralObj();
        coe.addNewPMObj();
        coe.addNewPIObj();
        coe.rowToRemove = 0;
        coe.removeRowToPIList();
        coe.addNewCaseObj();
        coe.addNewCaseObj();
        coe.addNewNoteCommentObj();
        coe.removeRow();
        coe.addNewPayAgreementWorksheetObj();
        coe.newClinicalAssessment();
        coe.clinicalAssessmentEdit();
        coe.updateCAObj();
        coe.patientcontact();
        //coe.patientcontactEdit();
        coe.updatepatientcontactObj();
        coe.newPatientInsurance();
        coe.patientInsuranceEdit();
        coe.updatePatientIontactObj();
        coe.conDetail();
        coe.Selectedsubscriber = ''+con.Id;
        coe.updatedPatient();
        coe.SubscriberEmployer();
//      CreateOpportunityExt.getSearchResult('Test');
        coe.searchPosition=0;
        coe.addNewRow();
         coe.validateOpp();
        coe.ReferWrpList[0].searchKeyWord = ''+con.Id;
//        coe.selectedvalue();
        coe.getInsuranceCompany();
        coe.updateAbsSubsObj();
        coe.abusedsubstance();
        coe.saveNewAbsSubsObj();
        coe.saveNewAbsSubsObjEdit();
        coe.abusedsubstanceEdit();
        coe.calculateYears(System.Today().addYears(25));
        coe.addNewTripObj();
        coe.addNewTripObj();
        coe.rowToRemove = 0;
        coe.addNewIIObj();
        coe.removeRowToIIList();
        //coe.removeRowToReferralList();
        coe.removeRowToCAList();
        coe.removeRowToPMList();
        coe.removeRowToNoteCommentList();
        //coe.removeRowToPayAgreementWorksheetList();
        coe.cancel();
        coe.stageValue = 'Prospecting';
        //coe.saveOppInfo();       
        coe.rendSection();
    } 
        
    static testMethod void Test2(){ 

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='stand12a1rduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,Update_AC_Assigned_on_Opportunity__c = True, Update_RAM_Assigned_on_Opportunity__c = True, TimeZoneSidKey='America/Los_Angeles', UserName='stand12a1rduser@testorg.com');
    
    System.runAs(u) {
        RecordType rc = [select id from  RecordType where SobjectType='Opportunity' AND Name='Outpatient Treatment'];
        
        contact con = new contact();
        con.LastName = 'Test';
        con.Birthdate = System.Today();
        con.FirstName = 'Test';
        con.Social_Security_Number__c = 'Test';
        insert con;
        
        Opportunity opp = new Opportunity(Name = 'Test',LeadSource = 'Professional',StageName = 'Qualification',Referral_Source_Unknown_Details__c= 'test', Alumni_Referral_Source__c= 'Online', Contact__c = con.id,Probability = 10,CloseDate =  Date.today(),RecordTypeId = rc.id);
        insert opp;
        
        Patient_Contact__c pc = new Patient_Contact__c(Opportunity__c = opp.id, Contact__c = con.id, First_Name__c = 'test', Last_Name__c = 'test');
        insert pc;
        update pc;

        
         // Patient_Insurance__c pi = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today());
        Patient_Insurance__c pi = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today(),Patient__c= Con.id, Subscriber__c = pc.id, Subscriber_is_Patient__c=False);
        insert pi;
        update pi;
        
        Pay_Agreement_Worksheet__c PAW = new Pay_Agreement_Worksheet__c(Opportunity__c = opp.id);
        insert PAW;
        
        Note_Comment__c note = new Note_Comment__c(Opportunity__c = opp.id, Email_To__c ='testing', Note_Comment__c = 'test');
        insert note;
        
        Account acc = new Account();
        acc.Name = 'Test1';
        acc.Phone = '(123) 456-7890';
        acc.FRN_Facility_Type__c ='Residential Treatment';
        insert acc;
        
        Referral__c ref = new Referral__c(Patient_Name__c='test', Account__c= acc.Id,Consentor__c= con.Id, Referral_Reason__c='BCBS Fed',Opportunity__c= Opp.Id);
        insert ref;
            
        Abused_Substance__c ascc = new Abused_Substance__c(Opportunity__c = opp.id, Substance__c = 'test');
        insert ascc;
        update ascc;

        Treatment_History__c pth = new Treatment_History__c(Opportunity__c = opp.id,Type__c= 'Substance Abuse');
        insert pth;
        
        Medical_Problem_Symptom__c mps = new Medical_Problem_Symptom__c(Opportunity__c = opp.id);
        insert mps;
        
        Prescription_Medication__c pm = new Prescription_Medication__c(Opportunity__c = opp.id);
        insert pm;
        
        Illness_Injury__c ii = new Illness_Injury__c(Opportunity__c = opp.id);
        insert ii;
        
        Major_Medical_Issue__c mmi = new Major_Medical_Issue__c(Opportunity__c = opp.id, Major_Medical_Issue__c= 'Stroke');
        insert mmi;
        update mmi;
        
        Mental_Health_Symptom__c mhs = new Mental_Health_Symptom__c(Opportunity__c = opp.id);
        insert mhs;
        
        Psychiatric_Diagnosis__c pd = new Psychiatric_Diagnosis__c(Opportunity__c = opp.id);
        insert pd;
        
        Legal_Offense__c lo = new Legal_Offense__c(Opportunity__c = opp.id);
        insert lo;
        
        Clinical_Assessment__c cac = new Clinical_Assessment__c(Opportunity__c = opp.Id);
        insert cac;
        
        Behavioral_Social_History__c bsh = new Behavioral_Social_History__c(Clinical_Assessment__c = cac.id);
        insert bsh;
        
        Risk_Assessment__c ra = new Risk_Assessment__c(Clinical_Assessment__c = cac.id);
        insert ra;
        
        Substance_Abuse_History_and_Frequency__c sahf = new Substance_Abuse_History_and_Frequency__c(Opportunity__c = opp.id);
        insert sahf;
                
        Medical_Equipment__c me = new Medical_Equipment__c(Opportunity__c = opp.id);
        insert me;      
        
        Case cs = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Facility Approval').getRecordTypeId(),Status='New',Opportunity__c = opp.id, Origin = 'Email', Subject = 'Test Subject',Red_Flag_Information__c = 'test',Priority='Medium', AccountId = acc.id);
        insert cs;
        
        
        Document__c  dc = new Document__c(Category__c='Others',Description__c = 'test',Opportunity__c = opp.id ,Patient__c = con.Id);
        insert dc;
        
        Infectious_Disease__c ids = new Infectious_Disease__c(Currently_Symptomatic__c='Yes',Currently_Taking_Medications__c='Yes',Diagnosis_Date__c=System.today(),Have_You_Followed_Up_with_Appointments__c='Yes',Infectious_Disease__c = 'Have you recently been exposed to or currently have TB (tuberculosis)?',Opportunity__c = opp.id,Patient__c = con.Id,Regular_Follow_Up_Recommended__c='Yes');
        insert ids;
        
        Trip__c trp = new Trip__c(Trip_Name__c = 'test',Opportunity__c = opp.id);
        insert trp;
        
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController (opp);
        PageReference pr = Page.CreateOpportunity;
        Test.setCurrentPage(pr);
        pr.getParameters().put('Id',opp.Id);
        pr.getParameters().put('retURL','test.test.test.test.login.salesforce.com/'+con.Id);
        CreateOpportunityExt coe = new CreateOpportunityExt(sc);
        coe.stageValue = 'Prospecting';
        coe.cancel();
        //coe.saveOppInfo();
        coe.rowToRemove = 0;
        coe.addNewAbsSubsObj();
        coe.removeRowToAbsList();
        coe.removeRowToAbsList();
        coe.addNewPTHObj();
        coe.removeRowToPTHList();
        coe.removeRowToPTHList();
        coe.addNewMPSObj();
        coe.removeRowToMpsList();
        coe.removeRowToMpsList();
        coe.addNewPMObj();
        //coe.removeRowToPMList();
        coe.addNewMHSObj();
        coe.removeRowToMHSList();
        coe.removeRow();
        coe.addNewPDObj();
        coe.removeRowToPDList();
        coe.removeRowToPDList();
        coe.addNewLOObj();
        coe.removeRowToLOList();
        coe.removeRowToLOList();
        coe.toldYouAbout();
        //coe.addNewBHObj();
        //coe.removeRowToBHList();
        //coe.removeRowToBHList();
        //coe.addNewRAObj();
       // coe.removeRowToRAList();
        //coe.removeRowToRAList();
        coe.addNewSAHFObj();
        coe.rowToRemove = 0;
        coe.removeRowToSAHFList();
        coe.removeRowToSAHFList();
        coe.addNewPCObj();
        coe.Selectedsubscriber = ''+pc.Id;
        coe.updatedPatient();
        coe.removeRowToPCList();
        coe.removeRowToPCList();
        coe.addNewMEObj();
        coe.rowToRemove = 0;
        coe.removeRowToMEList();
        coe.changeStageName();
        coe.renderedSection();
        coe.rowToRemove = 0;
        //coe.removeRowToPIList();
        coe.changeUsr();
        coe.showPopup();
        coe.closePopup();
        coe.redirectPopup();
        coe.CloneOpportunity();
        coe.UploadDocument();
        coe.rowToRemove = 0;
        //coe.removeRowToPIList();
        coe.rowToRemove = 1;
       // coe.removeRowToPMList();
        coe.rowToRemove = 0;
        coe.removeRowToIDList();
        //coe.removeRowToDOCList();
        coe.removeRowToCaseList();
        coe.newClinicalAssessment();
        coe.patientcontact();
        CreateOpportunityExt.getSearchResult('Test1');
        coe.searchPosition=0;
        coe.addNewRow();
        coe.ReferWrpList[0].searchKeyWord = ''+acc.Id;
        coe.selectedvalue();
        //coe.patientcontactEdit();
        coe.updatepatientcontactObj();
        coe.updateCAObj();
        coe.newPatientInsurance();
       // coe.patientInsuranceEdit();
        coe.updatePatientIontactObj();
        //coe.getSubscriberName();
        coe.conDetail();
        coe.SubscriberEmployer();
        coe.getInsuranceCompany();
        coe.calculateYears(System.Today().addYears(-1));
        // coe.removeRowToPayAgreementWorksheetList();
        //coe.removeRowToQuoteList();
        coe.removeRowToTripList();
        coe.rendSection();

    }
    }

    static testMethod void Test3(){     
        RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Refer Out Only'];
        
        Account acc = new Account();
        acc.Name = 'Test1';
        acc.Phone = '(123) 456-7890';
        acc.FRN_Facility_Type__c ='Residential Treatment';
        insert acc;
        
        contact con = new contact();
        con.LastName = 'Test';
        con.Birthdate = System.Today();
        con.FirstName = 'Test';
        con.Social_Security_Number__c = 'Test';
        insert con;
        
        Opportunity opp1 = new Opportunity(Name = 'Test1',Contact__c = con.Id,Referral_Source_Unknown_Details__c= 'test', Alumni_Referral_Source__c= 'Online', StageName = 'Referral Requested',Probability = 11,CloseDate =  Date.today(),RecordTypeId = rc1.id, Have_You_Ever_Purged_or_Forced_Throw_Up__c= 'Yes',LeadSource = 'Friend or Family Member');
        insert opp1;
        
        Patient_Contact__c pc = new Patient_Contact__c(Last_Name__c = 'Test',First_Name__c = 'Test',Opportunity__c = opp1.id, Contact__c = con.id);
        insert pc;
        update pc;

        //Patient_Insurance__c pi = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp1.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today(),Patient__c= Con.id,Subscriber_is_Patient__c=True);
        //insert pi;
        //update pi;
        
        Patient_Insurance__c pi1 = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp1.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today(),Patient__c= Con.id,Subscriber__c=pc.Id);
        insert pi1;

        Abused_Substance__c ascc = new Abused_Substance__c(Opportunity__c = opp1.id, Substance__c = 'test');
        insert ascc;
        update ascc;
        
        
        Treatment_History__c pth = new Treatment_History__c(Opportunity__c = opp1.id,Type__c= 'Substance Abuse');
        insert pth;
        
        Medical_Problem_Symptom__c mps = new Medical_Problem_Symptom__c(Opportunity__c = opp1.id);
        insert mps;
        
        Prescription_Medication__c pm = new Prescription_Medication__c(Opportunity__c = opp1.id);
        insert pm;
        
        Illness_Injury__c ii = new Illness_Injury__c(Opportunity__c = opp1.id);
        insert ii;
        
        Major_Medical_Issue__c mmi = new Major_Medical_Issue__c(Opportunity__c = opp1.id, Major_Medical_Issue__c= 'Stroke');
        insert mmi;
        update mmi;
        
        Mental_Health_Symptom__c mhs = new Mental_Health_Symptom__c(Opportunity__c = opp1.id);
        insert mhs;
        
        Psychiatric_Diagnosis__c pd = new Psychiatric_Diagnosis__c(Opportunity__c = opp1.id);
        insert pd;
        
        Legal_Offense__c lo = new Legal_Offense__c(Opportunity__c = opp1.id);
        insert lo;
        
        Clinical_Assessment__c cac = new Clinical_Assessment__c(Opportunity__c = opp1.Id);
        insert cac;
        
        Behavioral_Social_History__c bsh = new Behavioral_Social_History__c(Clinical_Assessment__c = cac.id);
        insert bsh;
        
        Risk_Assessment__c ra = new Risk_Assessment__c(Clinical_Assessment__c = cac.id);
        insert ra;
        
        Substance_Abuse_History_and_Frequency__c sahf = new Substance_Abuse_History_and_Frequency__c(Opportunity__c = opp1.id);
        insert sahf;
                
        Medical_Equipment__c me = new Medical_Equipment__c(Opportunity__c = opp1.id);
        insert me;      
        
        Case cs = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Facility Approval').getRecordTypeId(),Status='New',Opportunity__c = opp1.id, Origin = 'Email', Subject = 'Test Subject1', Red_Flag_Information__c = 'test',Priority='Medium',AccountId = acc.id);
        insert cs;
        
        
        Document__c  dc = new Document__c(Category__c='Others',Description__c = 'test',Opportunity__c = opp1.id ,Patient__c = con.Id);
        insert dc;
        
         
        Infectious_Disease__c ids = new Infectious_Disease__c(Currently_Symptomatic__c='Yes',Currently_Taking_Medications__c='Yes',Diagnosis_Date__c=System.today(),Have_You_Followed_Up_with_Appointments__c='Yes',Infectious_Disease__c = 'Have you recently been exposed to or currently have TB (tuberculosis)?',Opportunity__c = opp1.id,Patient__c = con.Id,Regular_Follow_Up_Recommended__c='Yes');
        insert ids;
        
        Trip__c trp = new Trip__c(Trip_Name__c = 'test',Opportunity__c = opp1.id);
        insert trp;

            

        RecordType rc = [select id from  RecordType where SobjectType='Opportunity' AND Name='Refer Out Only'];
        Opportunity opp= new Opportunity(Name = 'Test',Contact__c = con.Id,Referral_Source_Unknown_Details__c= 'test', Alumni_Referral_Source__c= 'Online', StageName = 'Referral Requested',Probability = 10,CloseDate =  Date.today(),RecordTypeId = rc.id,LeadSource = 'Friend or Family Member');
        insert opp;
        
        
        Opportunity opp2 = new Opportunity(Name = 'Test',Contact__c = con.Id,Referral_Source_Unknown_Details__c= 'test', Alumni_Referral_Source__c= 'Online', StageName = 'Referral Requested',Probability = 10,CloseDate =  Date.today(),RecordTypeId = rc.id, Have_You_Ever_Purged_or_Forced_Throw_Up__c= 'Yes',LeadSource = 'Friend or Family Member');
        
        Online_Search_Term__c OST = new Online_Search_Term__c(Name = 'Black Bear IOP');
        insert OST;
        
        String rooID = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Refer Out Only').getRecordTypeId();
        
        ApexPages.StandardController sc = new ApexPages.StandardController (opp2);
        PageReference pr = Page.CreateOpportunity;
        Test.setCurrentPage(pr);
        pr.getParameters().put('Id',opp2.Id);
        pr.getParameters().put('about',OST.Id);
        pr.getParameters().put('oppId',opp2.Id);
        pr.getParameters().put('retURL','test.test.test.test.login.salesforce.com/'+con.Id);
        CreateOpportunityExt coe = new CreateOpportunityExt(sc);
        coe.cancel();
        coe.stageValue = 'Prospecting';     
        coe.selectedRecordType = rc.id;     
        coe.getStages();
        coe.getFRNFacilities(); 
        coe.saveOppInfo();   
        coe.saveAndContinue();   
        coe.newClinicalAssessment();   
        coe.medicationOthers();
        coe.validateOpp();      
        coe.patientcontact();   
        //coe.patientcontactEdit();   
        coe.newPatientInsurance();   
        //coe.patientInsuranceEdit();   
        coe.updatepatientcontactObj();   
        coe.getInsuranceCompany();   
        coe.patConFromPatIns();   
        coe.toldYouAbout();
        coe.addNewPCObjInPI();   
        coe.updatePatientIontactObj();   
        coe.getSubscriberName();  
        CreateOpportunityExt.getSearchResult('Test');
        coe.searchPosition=0;
        coe.selectedvalue();   
        coe.updateCAObj();   
        coe.calculateYears(System.Today());   
        coe.conDetail();   
        coe.removeRow();   
        coe.SubscriberEmployer();  
        coe.rendSection();      
        coe.saveOpportunity();      
    }

    static testMethod void testingExtras(){     
        RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Residential Treatment'];
        Opportunity opp1 = new Opportunity(Name = 'Test1',Referral_Source_Unknown_Details__c= 'test', Alumni_Referral_Source__c= 'Online', StageName = 'Qualification',Probability = 10,LeadSource = 'Professional',OwnerId = UserInfo.getUserId(),CloseDate =  Date.today(),RecordTypeId = rc1.id, Have_You_Ever_Purged_or_Forced_Throw_Up__c= 'Yes');
        insert opp1;
        
        contact con = new contact();
        con.LastName = 'Test';
        con.Birthdate = System.Today();
        con.FirstName = 'Test';
        con.Social_Security_Number__c = 'Test';
        insert con;

        Abused_Substance__c ascc = new Abused_Substance__c(Opportunity__c = opp1.id, Substance__c = 'test');
        insert ascc;
        update ascc;

        RecordType rc = [select id from  RecordType where SobjectType='Opportunity' AND Name='Residential Treatment'];
        Opportunity opp = new Opportunity(Name = 'Test',StageName = 'Qualification',OwnerId = UserInfo.getUserId(),Referral_Source_Unknown_Details__c= 'test', Alumni_Referral_Source__c= 'Online',LeadSource = 'Professional', Probability = 10,CloseDate =  Date.today(),RecordTypeId = rc.id, Have_You_Ever_Purged_or_Forced_Throw_Up__c= 'Yes');
        //insert opp;
       
        Illness_Injury__c ii = new Illness_Injury__c(Opportunity__c = opp1.id);
        insert ii;
       
        Major_Medical_Issue__c mmi = new Major_Medical_Issue__c(Opportunity__c = opp1.id, Major_Medical_Issue__c= 'Stroke');
        insert mmi;
        update mmi;
        
        Patient_Contact__c pc = new Patient_Contact__c(Opportunity__c = opp1.id, Contact__c = con.id, First_Name__c = 'test', Last_Name__c = 'test');
        insert pc;
        update pc;
        
        Patient_Insurance__c pi = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp1.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today(),Patient__c= Con.id,Subscriber_is_Patient__c=True,Subscriber__c=pc.Id);
        insert pi;
        update pi;
        
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        
        Insurance_Benefit__c ib = new Insurance_Benefit__c(Patient_Insurance__c=pi.id,
                                                           Disposition__c = 'Benefits Available',
                                                           Applicable_For_Year__c = String.valueOf(System.Today().Year()));
        insert ib;
        
        
        Pay_Agreement_Worksheet__c paw = new Pay_Agreement_Worksheet__c(Opportunity__c = opp1.id, Insurance_Benefit__c=ib.id);
        insert paw;
        
        
        Facility_Program__c fp = new Facility_Program__c(Name = 'test', FRN_Facility__c = acc.id);
        insert fp;
        
        
        Quote quo = new Quote();
        quo.Name = 'test';
        quo.OpportunityId = opp1.Id;
        quo.FRN_Facility__c = acc.Id;
        quo.Insurance_Company__c = acc.Id;
        quo.Facility_Program__c = fp.Id;
        quo.Pay_Agreement_Worksheet__c = paw.Id;
        quo.Insurance_Company_Contract_Type__c = 'In Network';
        insert quo;        
        
        Online_Search_Term__c OST = new Online_Search_Term__c(Name = 'Black Bear IOP');
        insert OST;
        
        Referral__c ref = new Referral__c(Patient_Name__c='test', Account__c= acc.Id,Consentor__c= con.Id, Referral_Reason__c='BCBS Fed',Opportunity__c= Opp1.Id);
        insert ref;        

        ApexPages.StandardController sc = new ApexPages.StandardController (opp1);
        PageReference pr = Page.CreateOpportunity;
        
        Test.setCurrentPage(pr);
        pr.getParameters().put('Id',opp1.Id);
        pr.getParameters().put('about',OST.Id);
        pr.getParameters().put('retURL','test.test.test.test.login.salesforce.com/'+con.Id);
        CreateOpportunityExt coe = new CreateOpportunityExt(sc);
        coe.rowToEdit=0;
        
        coe.addNewCAObj();
        coe.addNewReferralObj();
        coe.addNewPMObj();
        coe.addNewPIObj();
        coe.rowToRemove = 0;
        coe.removeRowToPIList();
        coe.addNewCaseObj();
        coe.addNewCaseObj();
        coe.addNewNoteCommentObj();
        coe.removeRow();
        coe.addNewPayAgreementWorksheetObj();
        coe.newClinicalAssessment();
        coe.clinicalAssessmentEdit();
        coe.updateCAObj();
        coe.patientcontact();
        coe.updatepatientcontactObj();
        coe.newPatientInsurance();
        coe.patientInsuranceEdit();
        coe.updatePatientIontactObj();
        coe.conDetail();
        coe.Selectedsubscriber = ''+con.Id;
        coe.updatedPatient();
        coe.SubscriberEmployer();
        coe.searchPosition=0;
        coe.addNewRow();
         coe.validateOpp();
        coe.ReferWrpList[0].searchKeyWord = ''+con.Id;
        coe.getInsuranceCompany();
        coe.updateAbsSubsObj();
        coe.abusedsubstance();
        coe.saveNewAbsSubsObj();
        coe.saveNewAbsSubsObjEdit();
        coe.abusedsubstanceEdit();
        coe.calculateYears(System.Today().addYears(25));
        coe.addNewTripObj();
        coe.addNewTripObj();
        coe.rowToRemove = 0;
        coe.addNewIIObj();
        coe.removeRowToIIList();
        coe.removeRowToCAList();
        coe.removeRowToPMList();
        coe.removeRowToNoteCommentList();
        coe.cancel();
        coe.stageValue = 'Prospecting';      
        coe.rendSection();
        coe.redirectIfLocked();
        coe.rowToEdit = 0;
        coe.editReferral();
        coe.rowToRemove = 0;
        coe.deleteReferal();
        coe.patientcontactEdit();
        coe.cancelPatConFrmPatIns();
        coe.editCase();
        //coe.removeRowToPayAgreementWorksheetList();
        coe.editPayAWSheet();
        coe.removeRowToQuoteList();
        coe.editQuote();
        coe.editTrip();
        //coe.removeRowToReferralList();
    }
}