/*
================================================================================
*    Description:  Wrapper Class  
     Version    Date          Author                 Description
*    1.0        26/06/2017    Naresh kaneriya        Initial Draft
*    
================================================================================
*/

global class OptionWrapper{
    global cls_items[] items;
    global  class cls_items {
        public String unitIDRef;    //DRZ/53/5303
        public String promotionName;    // 
        public String promotionValue;   // 
       
        public String campaignName; // 
        public String campaignValue;    // 
        
        public String optionsName;  // 
        public String optionsValue; // 
     
        public String schemeName;   // 
        public String schemeValue;  // 
      
        public String templateIdSN; //
        public String templateIdCN; //4
        public String templateIdPN; //101
        public String templateIdOP; //
        public String TokenAmountApprovalStatus; //
        public string  templateIdOP1;
        public string  templateIdOP2;
        public string  templateIdOP3;
        public string  templateIdOP4;
        public string  templateIdOP5;
        public string  dealSR;
    
        public String netPriceVal;  //3414000
        public String CMPricePerSqftAfter;  //2000
        public String currencyCode ;

    }
    global static OptionWrapper parse(String json){
        return (OptionWrapper) System.JSON.deserialize(json, OptionWrapper.class);
    }

    
}