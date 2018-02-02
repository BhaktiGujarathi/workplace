/**
 * Class OpportunityHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class BenefitHandler implements TriggerInterface {
    
    // Constructor
    public BenefitHandler(){

    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){  
      
    }
 
    public void bulkAfter(){
        
    }
 
    public void beforeInsert(SObject so){        
      
      Insurance_Benefit__c ins = (Insurance_Benefit__c)so;
      if(ins.LOC_Benefits_are_the_Same__c==true){
          
           ins.PHP_Covered__c = ins.Detox_Covered__c;
          ins.PHP_Pays_at__c = ins.Detox_Pays_at__c;
          ins.IOP_Covered__c = ins.Detox_Covered__c;
          ins.IOP_Pays_at__c = ins.Detox_Pays_at__c;
          ins.RTC_Covered__c = ins.Detox_Covered__c;
          ins.RTC_Pays_at__c = ins.Detox_Pays_at__c;
          /* 
          ins.PHP_Ratio__c = ins.Detox_Ratio__c;
          ins.PHP_Admit_Co_Payment__c = ins.Detox_Admit_Co_Payment__c;
          ins.PHP_Day_Max_Applies__c = ins.Detox_Day_Max_Applies__c; */
         
          /* ins.IOP_Ratio__c = ins.Detox_Ratio__c;
          ins.IOP_Admit_Co_Payment__c = ins.Detox_Admit_Co_Payment__c;
          ins.IOP_Day_Max_Applies__c = ins.Detox_Day_Max_Applies__c;
          
          ins.RTC_Ratio__c = ins.Detox_Ratio__c;
          ins.RTC_Admit_Co_Payment__c = ins.Detox_Admit_Co_Payment__c;
          ins.RTC_Day_Max_Applies__c = ins.Detox_Day_Max_Applies__c; */
        }
    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
                   
      Insurance_Benefit__c ins = (Insurance_Benefit__c)so;
      if(ins.LOC_Benefits_are_the_Same__c==true){
           ins.PHP_Covered__c = ins.Detox_Covered__c;
          ins.PHP_Pays_at__c = ins.Detox_Pays_at__c;
          ins.IOP_Covered__c = ins.Detox_Covered__c;
          ins.IOP_Pays_at__c = ins.Detox_Pays_at__c;
          ins.RTC_Covered__c = ins.Detox_Covered__c;
          ins.RTC_Pays_at__c = ins.Detox_Pays_at__c;
          /* ins.PHP_Covered__c = ins.Detox_Covered__c;
          ins.PHP_Pays_at__c = ins.Detox_Pays_at__c;
          ins.PHP_Ratio__c = ins.Detox_Ratio__c;
          ins.PHP_Admit_Co_Payment__c = ins.Detox_Admit_Co_Payment__c;
          ins.PHP_Day_Max_Applies__c = ins.Detox_Day_Max_Applies__c; */
         /*  ins.IOP_Ratio__c = ins.Detox_Ratio__c;
          ins.IOP_Admit_Co_Payment__c = ins.Detox_Admit_Co_Payment__c;
          ins.IOP_Day_Max_Applies__c = ins.Detox_Day_Max_Applies__c;
          ins.RTC_Covered__c = ins.Detox_Covered__c;
          ins.RTC_Pays_at__c = ins.Detox_Pays_at__c;
          ins.RTC_Ratio__c = ins.Detox_Ratio__c;
          ins.RTC_Admit_Co_Payment__c = ins.Detox_Admit_Co_Payment__c;
          ins.RTC_Day_Max_Applies__c = ins.Detox_Day_Max_Applies__c; */
        }
    }
    
    public void AfterUpdate(SObject oldSo, SObject so){
        
    }
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){
       
    }
    public void afterInsert(SObject so){ 
        
    }

    public void afterDelete(SObject so){
        
    }
 
    public void afterUndelete(SObject so){
        
    }
 
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally(){
    
    }
}