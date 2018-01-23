public with sharing class OppDefaultChildrenCreationService {
    public static List<InfectiousDiseasesWrp> idWrpList {get;set;}
    public static List<MajorMedicalIssuesWrp> mmiWrpList {get;set;}
    public static List<MedicalEquipmentWrp> meWrpList {get;set;}

    public OppDefaultChildrenCreationService() {
        idWrpList = new List<InfectiousDiseasesWrp>();
        mmiWrpList = new List<MajorMedicalIssuesWrp>();
        meWrpList = new List<MedicalEquipmentWrp>();
    }

    //Wrapper class for Medical Equipment Object
    public class MedicalEquipmentWrp{
        public Integer index {get;set;}
        public Medical_Equipment__c record {get;set;}
        public MedicalEquipmentWrp(){
            record = new Medical_Equipment__c(); 
        }
    }

    //Wrapper class for Infectious Diseases Object
    public class InfectiousDiseasesWrp{
        public Integer index {get;set;}
        public Infectious_Disease__c record {get;set;}
        public InfectiousDiseasesWrp(){
            record = new Infectious_Disease__c(); 
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

    // method to create list of infectious diseases prior to creation of Opportunity
    public static List<InfectiousDiseasesWrp> createDiseaseRecordlist(Id parentOpportunityId) {
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
            //InfecDisease.add(InD);
        }
        system.debug('>>> idWrpList : '+idWrpList);
        return idWrpList;
    }
    
    // method to create list of Medical equipment prior to creation of Opportunity
    public static List<MedicalEquipmentWrp> createEquipmntRecordlist(Id parentOpportunityId) {
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
        system.debug('>>> meWrpList : '+meWrpList);
        return meWrpList;
    }
    
    // method to create list of major medical issues prior to creation of Opportunity
    public static List<MajorMedicalIssuesWrp> createMedIssueRecordlist(Id parentOpportunityId) {
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
        system.debug('>>> mmiWrpList : '+mmiWrpList);
        return mmiWrpList;
    }
}