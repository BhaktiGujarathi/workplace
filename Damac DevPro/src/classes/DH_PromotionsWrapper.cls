/**************************************************************************************************
* Name               : DH_PromotionsWrapper *
* Description        : This Wrapper Class to hold The Response Parameter From Drool Web Service                     *
* Created Date       :                                                               *
* Created By         : UnKnow                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE          COMMENTS                                              *

  1.1         Naresh(Accely)    20/06/2017    Add  New Parameter i.e.
                                               templateIdSN ,templateIdCN ,templateIdPN , templateIdOP*
**************************************************************************************************/


public with sharing class DH_PromotionsWrapper {
    
        public string  id{get;set;}
        public string  templateIdSN{get;set;}
        public string  templateIdCN{get;set;}
        public string  templateIdPN{get;set;}
        public string  templateIdOP{get;set;}
        public string  templateIdOP1{get;set;}
        public string  templateIdOP2{get;set;}
        public string  templateIdOP3{get;set;}
        public string  templateIdOP4{get;set;}
        public string  templateIdOP5{get;set;}
        public string  unitID{get;set;}
        public string  TokenAmountApprovalStatus{get;set;}
        public Decimal NetPrice{get;set;}
        public string productType{get;set;}
        public List<selectOption> promotionOptions{set;get;}
        public List<selectOption> campaignOptions{set;get;}
        public List<selectOption> schemeOptions{set;get;}
        public List<optionWrapper> optionOptions{set;get;}
        
        public class optionWrapper{
            public string Name{get;set;}
            public string Id{get;set;}
            public string Price{get;set;}
           
            
        }
        
}