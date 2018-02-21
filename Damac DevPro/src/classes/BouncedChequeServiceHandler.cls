public class BouncedChequeServiceHandler {

    @InvocableMethod
    public static void processSR(List<Service_request__c> lstSR) {
        system.debug('lstSR '+lstSR);
        if(lstSR != null && lstSR.size() > 0){
        	Service_request__c objSRPB = lstSR.get(0);
            Service_request__c objSR = [SELECT Id,Bounced_Cheque_Status__c,OwnerId from Service_request__c where Id=:objSRPB.Id];
            
            if(objSR.Bounced_Cheque_Status__c.equalsIgnoreCase('Customer Not Reachable')
               || objSR.Bounced_Cheque_Status__c.equalsIgnoreCase('Customer Declined To Pay')){
                //create task for GM and assign to them.
                List<User> lstUser = [select id,name from user where user.UserRole.Name = 'General Manager'];
                if(lstUser != null && lstUser.size() > 0 ){
                	Task objTask = new Task();
                    objTask.OwnerId = lstUser[0].Id;
                    objTask.Priority = 'High';
                    objTask.Status = 'Not Started';
                    objTask.Subject = 'Bounced Cheque - Review for GM';
                    objTask.WhatId = objSR.Id;
                    String strDescription = 
                        'Please check if legal action and also committee intervention is required. '
                        +'If legal action and committee intervention is required, '
                        +'update the value of Bounced Cheque Status to \'Reviewed by GM - Legal Action Required - Committee Intervention Required\''
                        +' else update status to \'Reviewed by GM - Legal Action Required - Committee Intervention Not Required\'. '
                        +'If legal action is not required then update the value of Bounced Cheque Status to \'Reviewed by GM - Legal Action Not Required\'.';
                    objTask.Description = strDescription;
                    insert objTask;      
                }   
            }
            
            if(objSR.Bounced_Cheque_Status__c.equalsIgnoreCase('Reviewed by GM - Legal Action Required - Committee Intervention Required')){
                List<User> lstUser = [select id,name from user where user.UserRole.Name = 'Committee'];
                if(lstUser != null && lstUser.size()>0){
                	//create task for Committe and assign to them.
                    Task objTask = new Task();
                    objTask.OwnerId = lstUser[0].Id;
                    objTask.Priority = 'High';
                    objTask.Status = 'Not Started';
                    objTask.Subject = 'Bounced Cheque - Review for Committe';
                    objTask.WhatId = objSR.Id;
                    String strDescription = 
                        'Please check if legal action is required. '
                        +'If legal action required, '
                        +'update the value of Bounced Cheque Status to \'Reviewed by Committee - Legal Action Required\''
                        +' else update status to \'Reviewed by Committee - Legal Action Not Required\'. '
                        +' Also update Committee Comments accordingly.';
                    objTask.Description = strDescription;
                    insert objTask;	    
                }
            }
            
            if(objSR.Bounced_Cheque_Status__c.equalsIgnoreCase('Payment Received')){
                // call the IMPS system through webservice to apply the payments and update status in SFDC CRM
                // if result is success then update status of SR to Bounced Cheque SR Closed
                // else nothing mentioned in Process diagram need to ask
                boolean isPaymentApplied = true;
                if(isPaymentApplied){
                    objSR.Bounced_Cheque_Status__c = 'Bounced Cheque SR Closed';
                	update objSR;
                }else{ // payment is not applied bcz of some error
                	Task objTask = new Task();
                    objTask.OwnerId = objSR.OwnerId;
                    objTask.Priority = 'High';
                    objTask.Status = 'Not Started';
                    objTask.Subject = 'Bounced Cheque - Payment Not Applied';
                    objTask.WhatId = objSR.Id;
                    String strDescription = 
                        'Please check why payment is not applied '
                        +'Error : Error occured while applying payment';
                    objTask.Description = strDescription;
                    insert objTask; 
                    
                    objSR.Bounced_Cheque_Status__c = 'Payment Not Applied Successfully.';
                	update objSR;
                }
            }
        }    
    }
}