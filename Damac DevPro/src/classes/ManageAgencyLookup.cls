global without sharing class ManageAgencyLookup implements NSIBPM.CustomCodeExecutable {
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step){
        String retStr = 'Success';
        try{
            NSIBPM__Service_Request__c objSR = SRUtility.getSRDetails(step.NSIBPM__SR__c);
            boolean isRemoveAgency = false;
            if(objSR.NSIBPM__Record_Type_Name__c == 'Deal'){
                for(NSIBPM__Step__c objstp : [SELECT Id, Name,NSIBPM__Status__c 
                                 FROM NSIBPM__Step__c where 
                                 NSIBPM__SR__c != null and (NSIBPM__SR__c =: objSR.id) and NSIBPM__SR__r.NSIBPM__SR_Template__c!=null 
                                 and IsDeleted=false and NSIBPM__Step_Template__r.NSIBPM__Code__c = 'SALES_AUDIT' 
                                              and NSIBPM__Status__r.NSIBPM__Code__c = 'SALES_AUDIT_REJECTED' and id =: step.id]){
                                                  isRemoveAgency = true;
                                                  break;
                                              }
            }
            if(isRemoveAgency){
                if(objSR.Agency__c != null){
                    objSR.Agency__c = null;
                    update objSR;
                }
                update objSR;
   
                list<Booking__c> lstbookings = (list<Booking__c>)SRUTILITY.getRecords('Booking__c',' where Deal_SR__c =\''+objSR.id+'\'');
                List<id> lstbkids = new List<id>();
                for(Booking__c bk : lstbookings){
                    lstbkids.add(bk.id);
                }
                system.debug('--->lstbkids'+lstbkids);
                system.enqueueJob(new AsyncReceiptWebservice (lstbkids, 'Agent Update'));
                
            }
            return retstr;
        }
        catch(exception ex){
            return ex.getMessage();
        }
        
    }
}