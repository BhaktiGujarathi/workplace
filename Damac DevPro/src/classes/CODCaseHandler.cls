public class CODCaseHandler {
    //ALSO CREATE A CALLOUT TO IPMS TO CREATE TASK
    @InvocableMethod
    public static void HandleCOD(List<Case> lstSR){
        system.debug('lstSR ' +lstSR);
        //Need to change the Data types of the parameters of below methods
        List<Case> lstClosedSR = new List<Case>();
        List<Case> lstOpenSR = new List<Case>();
        for(Case c : lstSR){
            if(c.Status.equalsIgnoreCase('closed')){
                lstClosedSR.add(c);
            } else {
                lstOpenSR.add(c);
            }
        }
        if(!lstOpenSR.isEmpty()){
            //COCDServiceRequestHandler.NotifyUserForSR(lstSR);
            COCDServiceRequestHandler.ProcessHandler(lstSR);
        }

        if(!lstClosedSR.isEmpty()){
            OCRCallout.NotifyUserAfterUpdate(lstClosedSR);
        }
    }
}