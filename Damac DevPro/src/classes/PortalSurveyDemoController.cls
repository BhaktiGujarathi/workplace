public with sharing class PortalSurveyDemoController {
    public String csKnow {get; set;}
    public String csPolite {get; set;}
    public String moc {get; set;}
    public String mocomplaint {get; set;}
    public String poc {get; set;}
    public String tc {get; set;}
    public String otherPurpose {get; set;}
    
    public PortalSurveyDemoController() {
    
    }
    
    public void insertResposne() {
        try{
            Response__c objResponse = new Response__c();
            objResponse.CS_Knowledge__c = csKnow ;
            objResponse.CS_Politeness__c = csPolite;
            objResponse.Feedback_of__c = userInfo.getUserId();
            objResponse.Mode_of_Communication__c = moc;
            objResponse.Mode_of_Complaint__c = mocomplaint;
            objResponse.Purpose_Of_Contact__c = poc + otherPurpose ;
            objResponse.Times_Contacted__c = tc;
            system.debug(objResponse);
            insert objResponse;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Feedback recorded successfully'));
        }
        catch( Exception e ) {
            system.debug('Exception rauised'+e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error : '+e.getMessage()));
        }
    }
}