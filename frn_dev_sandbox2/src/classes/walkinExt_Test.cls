@isTest
public class walkinExt_Test{
    static testMethod void Test1(){  
        RecordType rc = [select id from  RecordType where SobjectType='Account' AND Name='Patient Account'];
        Account acc = new Account();
        acc.Name= 'test';
        acc.RecordTypeId=rc.Id;
        insert acc;
        
        // Lead nLead = new Lead();
        // nLead.company =  'New Household';
        // nLead.LastName =  'test';
        // nLead.Status =  'Open';
        // nLead.Online_Search_Term__c =  'TEst TEst';
        // nLead.OwnerID =  userInfo.getUserId();
        // insert nLead;
        
        Account acc1 = new Account();
        acc1.Name = 'Test1';
        acc1.Phone = '(123) 456-7890';
        acc1.FRN_Facility_Type__c ='Residential Treatment';
        insert acc1;
        
        contact con = new contact();
        con.LastName = 'Test';
        con.AccountId = acc1.Id;
        insert con;
        
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.contact__c= con.id;
        opp.CloseDate=system.today();
        opp.StageName='In Process';
        Util.flag = false;
        insert opp;
        
        Lead nLead = new Lead();
        nLead.company =  'New Household';
        nLead.LastName =  'test';
        nLead.Opportunity_RecordType__c = 'Outpatient Treatment';
        nLead.Status =  'Open';
        nLead.Online_Search_Term__c =  'TEst TEst';
        nLead.OwnerID =  userInfo.getUserId();
        insert nLead;
        
        Online_Search_Term__c ost = new Online_Search_Term__c(Name = 'Test');
        insert ost;
        
        Patient_Insurance__c PI = new Patient_Insurance__c(Name = 'Test',Patient__c = con.id, Opportunity__c = opp.id, Patient_Social_Security_Number__c = 'Test', Insurance_Company__c = Acc.id );
        insert PI;
        
        Call_in_Code__c cic = new Call_in_Code__c();
        cic.Name = 'Test';
        insert cic;

        Patient_Contact__c Pcon = new Patient_Contact__c();
        Pcon.Opportunity__c = opp.id;
        Pcon.Contact__c = con.id;
        insert Pcon;
        update Pcon;
        
        Treatment_History__c TrH = new Treatment_History__c(Lead__c = nLead.id, Opportunity__c = opp.id, Patient__c = con.id);
        insert TrH;
        
        Abused_Substance__c abs = new Abused_Substance__c(Opportunity__c = opp.id, Patient__c = con.id,OwnerID =  userInfo.getUserId());
        insert abs;
        
        rc = [select id from  RecordType where SobjectType='Referral__c' AND Name='Inbound Referral'];
        Referral__c re = new Referral__c();
        re.Account__c=acc.Id;
        re.Lead__c=nLead.Id;
        re.RecordTypeId=rc.Id;
        insert re;
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
        
        ApexPages.CurrentPage().getparameters().put('id',opp.id);
        ApexPages.CurrentPage().getparameters().put('patc',Pcon.id);
        ApexPages.CurrentPage().getparameters().put('retpg','QuoteExtPage');
        ApexPages.CurrentPage().getparameters().put('about','Test');
         
        
        ApexPages.currentPage().getParameters().put('about','Test');
        ApexPages.StandardController sc = new ApexPages.StandardController (nLead);
        walkinExt nc = new walkinExt(sc);
        /* walkinExt.ReferralWrapper ncrw = new walkinExt.ReferralWrapper();
        ncrw.searchKeyWord = con.id;
        nc.selectedvalue(); */
        nc.rendSection();
        nc.calculateYears(System.Today());
        nc.calculateYears(System.Today().AddYears(-25));
        nc.addNewPCObjInPI();
        nc.newPatientContact();
        nc.SaveAndClose();
        nc.updatePatientIontactObj();
        nc.SubscriberEmployer();
        
        
        
        nLead.LeadSource = 'Professional';
        Update nLead;

        //sc = new ApexPages.StandardController (nLead);
        //nc = new walkinExt(sc);
        nc.le=nLead;
        nc.rendSection();
        nc.rowToRemove=0;
        
       
        nc.toldYouAbout();
        nc.removeRow();
        nc.addNewTreatmentHistoryObj();
        nc.addNewPatientInsuranceObj();
        nc.openNewPatientInsPage();
        nc.getsubscriberName();
        nc.addNewRow();
        nc.getOriginPicklist();
        //nc.SaveAndClose();
        //nc.AbusedSubstanceWrp();
        //nc.openNewAbusedSubstancePage();
        //nc.abuseSubEdit();
        nc.addNewAbusedSubstanceObj();
        nc.cancel1();
        
        nLead.LeadSource = 'Unknown';
        Update nLead;
        //sc = new ApexPages.StandardController (nLead);
        //nc = new walkinExt(sc);
        nc.le=nLead;
        nc.rendSection();
        nLead.LeadSource = 'Friend or Family Member';
        Update nLead;
        //sc = new ApexPages.StandardController (nLead);
        //nc = new walkinExt(sc);
        nc.le=nLead;
        nc.rendSection();
        nLead.LeadSource = 'Online';
        Update nLead;
        //sc = new ApexPages.StandardController (nLead);
        //nc = new walkinExt(sc);
        nc.le=nLead;
        nc.rendSection();
        
        nc.searchPosition= 0;
        nc.selectedvalue();
        walkinExt.getSearchResult('Test');
        //nc.patientInsEdit();
        
        RecordType rc1 = [select id from  RecordType where SobjectType='Account' AND Name='Insurance Company'];
        acc.RecordTypeId=rc1.Id;
        update acc;
        nc.getInsuranceCompany();
        nc.cancel();
        nc.PatContactCancel();
        /* walkinExt.ReferralWrapper ncrw = new walkinExt.ReferralWrapper();
        ncrw.searchKeyWord = con.id;
        nc.selectedvalue(); */
                
    } 
    
    static testMethod void Test2(){
        
        Lead nLead = new Lead();
        nLead.company =  'New Household';
        nLead.LastName =  'test';
        nLead.Opportunity_RecordType__c = 'Outpatient Treatment';
        nLead.Status =  'Open';
        nLead.Online_Search_Term__c =  'TEst TEst';
        nLead.OwnerID =  userInfo.getUserId();
        insert nLead;
        
        ApexPages.StandardController sc = new ApexPages.StandardController (nLead);
        walkinExt nc = new walkinExt(sc);
        nc.Selectedsubscriber ='conId';
        nc.updatedPatient();
        nc.Selectedsubscriber ='test';
        nc.updatedPatient();
        
        
        Account acc1 = new Account();
        acc1.Name = 'Test1';
        acc1.Phone = '(123) 456-7890';
        acc1.FRN_Facility_Type__c ='Residential Treatment';
        insert acc1;
        
        contact con = new contact();
        con.LastName = 'Test';
        con.AccountId = acc1.Id;
        insert con;
        
        Opportunity opp= new Opportunity();
        opp.Name='test';
        opp.contact__c= con.id;
        opp.CloseDate=system.today();
        opp.StageName='In Process';
        Util.flag = false;
        insert opp;
        
        Treatment_History__c TrH = new Treatment_History__c(Lead__c = nLead.id, Opportunity__c = opp.id, Patient__c = con.id);
        insert TrH; 
        
        Online_Search_Term__c ost = new Online_Search_Term__c(Name = 'Test');
        insert ost;
        
        Abused_Substance__c abs = new Abused_Substance__c(Opportunity__c = opp.id, Patient__c = con.id);
        insert abs;
        
        Patient_Insurance__c PI = new Patient_Insurance__c(Name = 'Test',Patient__c = con.id, Opportunity__c = opp.id, Patient_Social_Security_Number__c = 'Test', Insurance_Company__c = acc1.id );
        insert PI;
        
        
        
        List<walkinExt.PatientInsuranceWrp> PatientInsuranceWrpList1 = new  List<walkinExt.PatientInsuranceWrp>();
        
        walkinExt.PatientInsuranceWrp pw = new walkinExt.PatientInsuranceWrp();
        pw.index = 1;
        pw.record = PI;
        pw.patConUniqueNo = 'test';
        pw.patConName = 'test';
        pw.patientEmployer = 'test';
        PatientInsuranceWrpList1.add(pw);
        nc.PatientInsuranceWrpList = PatientInsuranceWrpList1;
        nc.rowToEdit = 0;
        nc.patientInsEdit();
        nc.rowToRemove =0;
        nc.removeRowToPatientInsuranceList();
                
        List<walkinExt.TreatmentHistoryWrp> TreatmentHistoryWrpList1 = new  List<walkinExt.TreatmentHistoryWrp>();
        
        walkinExt.TreatmentHistoryWrp wt = new walkinExt.TreatmentHistoryWrp();
        wt.index = 1;
        wt.record = TrH;
        TreatmentHistoryWrpList1.add(wt);
        nc.TreatmentHistoryWrpList = TreatmentHistoryWrpList1;
        nc.rowToRemove =0;
        nc.removeRowToTreatmentHistoryList();
        
        List<walkinExt.AbusedSubstanceWrp> AbusedSubstanceWrpList1 = new  List<walkinExt.AbusedSubstanceWrp>();
        
        walkinExt.AbusedSubstanceWrp wa = new walkinExt.AbusedSubstanceWrp();
        wa.index = 1;
        wa.record = abs;
        AbusedSubstanceWrpList1.add(wa);
        nc.AbusedSubstanceWrpList = AbusedSubstanceWrpList1;
        nc.rowToRemove =0;
        nc.rowToEdit=0;
        nc.abuseSubEdit();
        nc.removeRowToAbusedSubstanceList();
        nc.openNewAbusedSubstancePage();
        nc.saveNewAbusedSubstanceObj();
        nc.saveNewAbSubstanceOnEdit();
        
        //----------------------------------------------
        
        Lead nLead1 = new Lead();
        nLead1.company =  'New Household';
        nLead1.LastName =  'test';
        nLead1.Opportunity_RecordType__c = 'Outpatient Treatment';
        nLead1.Status =  'Open';
        nLead1.Online_Search_Term__c =  'TEst TEst';
        nLead1.OwnerID =  userInfo.getUserId();
        
        OpportunityEstimatedCloseDays__c setting = new OpportunityEstimatedCloseDays__c();
        setting.Name  = 'EstimatedCloseDays';
        setting.Number__c = 2;
        insert setting;
        
        
        nc.le = nLead1;
        nc.SaveAndClose();
        nc.removeRowToTreatmentHistoryList();
        
        
        
    }
}