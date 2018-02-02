public class PrescriptionMedicationController{
   public Prescription_Medication__c pmc{get;set;}
    public Pagereference pg;
    public String OppRetUrl;
    public PrescriptionMedicationController(ApexPages.StandardController stdController){
        OppRetUrl = ApexPages.CurrentPage().getparameters().get('retUrl');
        pmc = new Prescription_Medication__c();
        if(OppRetUrl != null && OppRetUrl != ''){
          Opportunity opp =[SELECT Id,Contact__c FROM Opportunity WHERE id =: OppRetUrl];  
          pmc.Patient__c = opp.Contact__c;
          pmc.Opportunity__c = opp.id;
        }
        
        pg = new Pagereference('/'+OppRetUrl);
    }
    
    public PageReference saveNew(){
        insert pmc;
        pmc.id = null;
        pmc.Medication__c = null;
        pmc.Indication__c = null;
        pmc.Prescribed_Dosage__c = null;
        pmc.Amount_Abused__c = null;
        pmc.Currently_Abusing_Substance__c = null;
        pmc.Frequency__c = null;
        Pagereference pgn = new Pagereference('/apex/PrescriptionMedicationsPage?retUrl='+OppRetUrl);
        return pgn;
    }
    
    public PageReference save(){
        insert pmc;
        return pg;
    }
    
    public PageReference cancel(){
        return pg;
    }
}