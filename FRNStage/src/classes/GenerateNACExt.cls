public class GenerateNACExt {
    public List<SelectOption> PatConOption{get; set;}
    public List<SelectOption> PatConOption2{get; set;}
    public Opportunity opp {get;set;}
    public String redirectTo {get;set;}
    public String selectedGenerator {get;set;}
    
    public GenerateNACExt(ApexPages.StandardController controller) {
        String opId = ApexPages.CurrentPage().getparameters().get('id');
        redirectTo = '';
        PatConOption = new List<SelectOption>();
        if(opId != null && opId != ''){
            
            opp = [Select Id,Physical_Description_of_Patient__c,Additional_Trip_Details__c,Guarantor__c,Guarantor_is_Self__c ,Secondary_Travel_Contact__c,Estimated_Date_and_Time_of_Arrival__c FROM Opportunity WHERE Id=:opId ];
            selectedGenerator = opp.Guarantor__c;
            
            PatConOption.add(new SelectOption('','--None--'));
            PatConOption.add(new SelectOption('Self','Self'));
            list<Patient_Contact__c> PClist = new list<Patient_Contact__c>([Select Id,Name,First_Name__c,Last_Name__c,Opportunity__c from Patient_Contact__c WHERE Opportunity__c =:opId]);
            
            System.debug('PClist ::>'+PClist.size());
            
            for(Patient_Contact__c pc:PClist){
                string name='';
                if(pc.First_Name__c != null &&  pc.First_Name__c != ''){
                    name=pc.First_Name__c ;
                }
                if(pc.Last_Name__c != null &&  pc.Last_Name__c != ''){
                    if(name!= null && name!= ''){
                        name= name+' '+pc.Last_Name__c;
                    }else{
                        name=pc.Last_Name__c ;
                    }
                }
                
                PatConOption.add(new SelectOption(pc.Id,name));
            }
            if(opp.Guarantor_is_Self__c){
                selectedGenerator = 'Self';
            }
        }
        String oppId = ApexPages.CurrentPage().getparameters().get('id');
        PatConOption2 = new List<SelectOption>();
          if(oppId != null && oppId != ''){
            PatConOption2.add(new SelectOption('','--None--'));
            list<Patient_Contact__c> PClist2 = new list<Patient_Contact__c>([Select Id,Name,First_Name__c,Last_Name__c,Opportunity__c from Patient_Contact__c WHERE Opportunity__c =:oppId]);
    
                System.debug('PClist2 ::>'+PClist2.size());
    
                        for(Patient_Contact__c pc2:PClist2){
                                string name='';
                    if(pc2.First_Name__c != null &&  pc2.First_Name__c != ''){
                            name=pc2.First_Name__c ;
                    }
                    if(pc2.Last_Name__c != null &&  pc2.Last_Name__c != ''){
                    if(name!= null && name!= ''){
                    name= name+' '+pc2.Last_Name__c;
                    }else{
                            name=pc2.Last_Name__c ;
                    }
                }
        
                PatConOption2.add(new SelectOption(pc2.Id,name));
            }
        }
    }    
    
    public pageReference generateNAC(){
        System.debug('generateNAC ::>'+opp);
        if(opp!=null && opp.Id!=null){
            opp.StageName = 'Pending Admission';
            if(selectedGenerator!=null){
                if(selectedGenerator == 'Self'){
                    opp.Guarantor__c = null;
                    opp.Guarantor_is_Self__c = true;            
                } else if (selectedGenerator.startsWith(Patient_Contact__c.sObjectType.getDescribe().getKeyPrefix())){
                    opp.Guarantor__c = selectedGenerator;
                    opp.Guarantor_is_Self__c = false;
                }
            }
            update opp;
            String quoteId = '';
            List<Quote> quoteList = new List<Quote>(); 
            for(Quote qu:[Select Id,Status__c,Select_as_Final_Quote__c, OpportunityId from Quote where OpportunityId=:opp.Id]){
                Quote q = new Quote();
                q.Id = qu.Id;
                if(qu.Select_as_Final_Quote__c) {
                    quoteId = qu.Id;
                }
                q.Status__c = 'Closed';
                quoteList.add(q);
            }
            if(quoteList.size()>0){
                Update quoteList;
            }
            //pageReference page = new pageReference('/apex/PDFPage?id='+opp.id);
            pageReference page = new pageReference('/apex/Generate_NAC_page?id='+opp.id);
            //pageReference page = new pageReference('/apex/NAC_OpportunityPage?id='+opp.id+'&Qid='+quoteId);
             return page; 
        } 
        return null;
    }
}