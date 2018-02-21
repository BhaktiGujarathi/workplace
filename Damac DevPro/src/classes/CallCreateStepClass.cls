public class CallCreateStepClass {
    @InvocableMethod public static void checkServiceRequestID(List<ID> lstCaseID) {
        System.debug('--CallCreateStepClass lstCaseID---'+lstCaseID);        
        list<User> lstUser = new list<User>();
        lstUser = [Select id,name,isActive  from user where userRole.name = 'Sales Admin'
                  AND isActive =: true];
        if(lstUser.Size()>0){
            Task objTask  = new Task();
            objTask.Subject = 'Deactivate Booking Unit';
            objTask.WhatID = lstCaseID[0] ; 
            objTask.OwnerId = lstUser[0].id;
            objTask.status = 'In Progress';
            objTask.priority= 'High';
            objTask.Assigned_User__c = 'Sales Admin';
            objTask.ActivityDate = System.today().addDays(1);
            objTask.Process_Name__c = 'Token Refund';
            insert objTask;
            System.debug('--objTask ---'+objTask); 
        }          
              
        /*if(lstCase.Size()>0){
            if(lstCase[0].SR_Booking_Units__r.Size()>0){
                System.debug('--SR_Booking_Units__r--'+lstCase[0].SR_Booking_Units__r.Size());                
                if(lstCase[0].SR_Booking_Units__r[0].Booking_unit__r.Booking__r.Deal_SR__c != null){
                    System.debug('--Deal_SR__c---'+lstCase[0].SR_Booking_Units__r[0].Booking_unit__r.Booking__r.Deal_SR__c );
                    String MethodResponse = CreateStepOnDPOverDue.createStepFromButton(lstCase[0].SR_Booking_Units__r[0].Booking_unit__r.Booking__r.Deal_SR__c);
                    System.debug('--MethodResponse--'+MethodResponse);
                    if(MethodResponse == 'Success'){
                        lstCase[0].Task_Created_for_Sales_Admin__c = false;
                        update lstCase[0];
                    }
                }
            }
            
        }*/         
    }
    
}