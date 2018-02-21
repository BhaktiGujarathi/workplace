public class COCDInvokableClass {

    @InvocableMethod
    public static void checkOQOODForCOCD(List<Service_request__c> lstSR){
		system.debug('lstSR ' +lstSR);
        COCDServiceRequestHandler.NotifyUserForSR(lstSR);
        COCDServiceRequestHandler.ProcessHandler(lstSR);
        //COCDServiceRequestHandler.DocumentOCRCallout(lstSR);
        
    }
}