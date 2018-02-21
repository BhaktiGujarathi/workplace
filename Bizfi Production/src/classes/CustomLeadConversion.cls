public class CustomLeadConversion {

    private List<Lead> prospectsList{get;set;}
    private Lead prospect;
    private ApexPages.StandardController leadController;
    public boolean doAction{get;set;}

    public static boolean isConverting = false;

    public static boolean run = true;

    public static boolean runOnce(){
        if(run){
            run = false;
            return true;
        }else{
            return run;
        }
    }

    public CustomLeadConversion(ApexPages.StandardController stdController){
        prospectsList  = new List<Lead>();
        prospect       = (Lead)stdController.getRecord();
        leadController = stdController;
        doAction = true;
    }

    public pageReference convert(){
        if(doAction){
            prospectsList.add(prospect);

        //    try {
                DedupeProspectProcessService deduplicator = new DedupeProspectProcessService(prospectsList);

                deduplicator.deduplicate();

                Lead              duplicatedLead              = new Lead();
                List<Lead>        prospectOriginalLead        = new List<Lead>();
                List<Opportunity> prospectOriginalOpportunity = new List<Opportunity>();

                duplicatedLead              = [SELECT Id, DupRefLeadId__c, DupRefOppID__c FROM Lead where Id =: prospect.id limit 1];

                // If our Lead is not a duplicate
                if(String.isBlank(duplicatedLead.DupRefLeadId__c) && String.isBlank(duplicatedLead.DupRefOppID__c)/* &&  prospectOriginalLead.isEmpty() && prospectOriginalOpportunity.isEmpty() */){
                    isConverting = true;
                
                
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(prospect.id);

                    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
                    lc.setConvertedStatus(convertStatus.MasterLabel);

                    Database.LeadConvertResult lcr = Database.convertLead(lc);


                    //CustomLeadConversionHelper.convertUpdatedLead(prospect.Id);

                    isConverting = false;

                    Id convertedOpportunityId = [SELECT ConvertedOpportunityId FROM Lead WHERE Id = :prospect.Id limit 1][0].ConvertedOpportunityId;
                    Id convertedAccountId = [SELECT ConvertedAccountId FROM Lead WHERE Id = :prospect.Id limit 1][0].ConvertedAccountId;

                    runDedupeAfterConvert(convertedAccountId);

                    PageReference p = new PageReference('/' + convertedOpportunityId);
                    return p; 

                }
                else {

                    PageReference p = new PageReference('/' + prospect.id);
                    return p;
                }
            } 
        //    catch(Exception e) {
        //        doAction = false;
            
        //        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getStackTraceString() ));

        //        return null; 
        //    }       
    //    }
        else{
            return null;
        }
    }


    @future
    public static void runDedupeAfterConvert(Id accountId) {

        System.debug('\n\n###FUTURE METHOD');

        //DedupeProspectProcessServiceForAccounts dedupe = new DedupeProspectProcessServiceForAccounts(new Account[]{ new Account(Id = accountId) });
        //dedupe.initDedupe(true);
    }
}