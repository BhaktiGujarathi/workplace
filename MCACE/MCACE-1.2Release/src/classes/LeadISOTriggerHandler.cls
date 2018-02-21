public class LeadISOTriggerHandler
{
    public static void ISOFieldPopulateAndValidateOnBefore()
    {
        List<Lead> duplicateLeadList = LeadISOTriggerService.isISODuplicate(trigger.new);
        if(duplicateLeadList.size() > 0 && duplicateLeadList != null)
        {
            List<Lead> ISOParentLeadList = LeadISOTriggerService.isISOParentPresent(duplicateLeadList);            
            if(ISOParentLeadList.size() > 0 && ISOParentLeadList != null)
            {
                List<Lead> ISOSalesRepLeadList = LeadISOTriggerService.populateISOBasedOnSalesRep(ISOParentLeadList);
                if(ISOSalesRepLeadList.size() > 0 && ISOSalesRepLeadList != null)
                {
                    LeadISOTriggerService.isAccISOorVendor(ISOSalesRepLeadList);
                }
            }
        }
    }
    
    public static void ISOFieldPopulateAndValidateOnAfter()
    {
        List<Lead> duplicateLeadList = LeadISOTriggerService.isISODuplicate(trigger.new);
        if(duplicateLeadList.size() > 0 && duplicateLeadList != null)
        {
            List<Lead> ISOParentLeadList = LeadISOTriggerService.isISOParentPresent(duplicateLeadList);            
            if(ISOParentLeadList.size() > 0 && ISOParentLeadList != null)
            {
                    LeadISOTriggerService.isAccISOorVendor(ISOParentLeadList);
            }
        }
    }
}