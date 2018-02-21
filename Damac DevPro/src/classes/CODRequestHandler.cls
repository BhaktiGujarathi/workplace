public class CODRequestHandler {
    @InvocableMethod
    public static void HandleCOD(List<Service_request__c> lstSR){
        system.debug('lstSR ' +lstSR);
        COCDServiceRequestHandler.NotifyUserForSR(lstSR);
        COCDServiceRequestHandler.ProcessHandler(lstSR);

    }
}