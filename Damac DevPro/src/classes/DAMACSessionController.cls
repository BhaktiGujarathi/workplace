public class DAMACSessionController{
    
    public User uRec{get; set;}
    public Account acc{get; set;}
    public Contact con{get; set;}
    public String inquiryObjectPrefix{set;get;}
    public String caseObjectPrefix{set;get;}
    public String propertyObjectPrefix{set;get;}
    public Boolean hideTabs{set;get;}
    
    public DAMACSessionController(){
        
       
        uRec = [SELECT id, name, accountId, account.Name, Contact.Name,Contact.FirstName,Contact.LastName,
                ContactId FROM User WHERE Id=: userInfo.getuserId()];
        if(uRec.accountId != null){
            acc = [SELECT id, name,Eligible_For_Tier_Program__c,Agency_Tier__c,Trade_License_Expiry_Date__c,
                   RERA_Expiry_Date__c
                   FROM Account WHERE id=:uRec.AccountId];
            con = [SELECT id, name, email, phone FROM Contact WHERE id=:uRec.ContactId];    
        }
        
        inquiryObjectPrefix = DamacUtility.getObjectPrefix('Inquiry__c');
        caseObjectPrefix = DamacUtility.getObjectPrefix('Case__c');
        propertyObjectPrefix = DamacUtility.getObjectPrefix('Inventory__c');

        //IF the Users Trade License or RERA is expired dont allow them to use any portal feature
        //other than Company Profile. Hiding all the tabs except Company Profile.
        if(null !=  acc && (acc.Trade_License_Expiry_Date__c < System.today() || acc.RERA_Expiry_Date__c < System.today())){
            hideTabs = true;
        }else{
            hideTabs = false;
        }

        
    }
    

}