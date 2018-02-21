public class OCRRequestHandler {
    @InvocableMethod
    public static void HandleOCR(List<Service_request__c> lstSR){
        system.debug('lstSR in HandleOCR ' +lstSR);
        List<id> srIds = new list<id>();
        for(Service_request__c sr : lstSR){
            srIds.add(sr.Id);
        }
        //OCRCallout.sendDocumentToOCR(srIds);
    }
}