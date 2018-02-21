public class CustomLeadConversionHelper{

    @future
    public static void convertUpdatedLead(Id myLeadId){

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(myLeadId);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
    }
}