public class Referralcontroller{

    public Referral__c ReferralObj{get;set;}
   
    public String Oppid;
    public String recname{get;set;}
    public String recID;

    public Referralcontroller() { 
           ReferralObj = new Referral__c(); 
        recname ='';
        Oppid = apexpages.currentPage().getParameters().get('id');
        recname = apexpages.currentPage().getParameters().get('rectName');
        recID = apexpages.currentPage().getParameters().get('rectId');
        if(Oppid!= null){
            
            Opportunity opp =  [Select id,Contact__r.FirstName,Contact__r.LastName,Contact__c,AccountID from Opportunity where id=:Oppid];
            //ReferralObj.Consentor__c = opp.Contact__c;
            //ReferralObj.Account__c = opp.AccountId;
            ReferralObj.Opportunity__c = opp.id;
            if(opp.Contact__r.FirstName != null && opp.Contact__r.FirstName !=''){
                ReferralObj.Patient_Name__c = opp.Contact__r.FirstName + ' '+ opp.Contact__r.LastName.SubString(0,1);
            }else{
                ReferralObj.Patient_Name__c = opp.Contact__r.LastName.SubString(0,1);
            } 
        } 
    }
    
    public PageReference save(){ 
        ReferralObj.RecordTypeId = recID;
        insert ReferralObj;
        return new PageReference('/'+Oppid);
    }
    
    public PageReference cancel(){
        
        return new PageReference('/'+Oppid);
    }
    public PageReference saveandnew(){
        ReferralObj.RecordTypeId = recID;  
        insert ReferralObj;
          ReferralObj = new Referral__c(); 
         PageReference page = new PageReference('/apex/Referralvfpage?id='+Oppid+'&rectId='+recID+'&rectName='+recname);
         page.setredirect(true);
        return page; 
    }
}