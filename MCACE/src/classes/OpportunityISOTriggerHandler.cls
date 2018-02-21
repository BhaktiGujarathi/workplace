public class OpportunityISOTriggerHandler
{
    public static void ISOFieldPopulateAndValidateOnBefore()
    {
        List<Opportunity> duplicateOppList = OpportunityISOTriggerService.isISODuplicate(trigger.new);
        if(duplicateOppList.size() > 0 && duplicateOppList != null)
        {
            List<Opportunity> ISOParentOppList = OpportunityISOTriggerService.isISOParentPresent(duplicateOppList);            
            if(ISOParentOppList.size() > 0 && ISOParentOppList != null)
            {
                List<Opportunity> ISOSalesRepOppLIst = OpportunityISOTriggerService.populateISOBasedOnSalesRep(ISOParentOppList);
                if(ISOSalesRepOppLIst.size() > 0 && ISOSalesRepOppLIst != null)
                {
                    OpportunityISOTriggerService.isAccISOorVendor(ISOSalesRepOppLIst);
                }
            }
        }
    }
    
    public static void ISOFieldPopulateAndValidateOnAfter()
    {
        List<Opportunity> duplicateOppList = OpportunityISOTriggerService.isISODuplicate(trigger.new);
        if(duplicateOppList.size() > 0 && duplicateOppList != null)
        {
            List<Opportunity> ISOParentOppList = OpportunityISOTriggerService.isISOParentPresent(duplicateOppList);            
            if(ISOParentOppList.size() > 0 && ISOParentOppList != null)
            {
                    OpportunityISOTriggerService.isAccISOorVendor(ISOParentOppList);
            }
        }
    }
}