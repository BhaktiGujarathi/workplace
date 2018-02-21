/*
Description : 
Created By   : Pratiksha Narvekar
Created Date :25-07-2017
Test Class : 
Change History : 
*/
public class SRCreateTask {
/*    public static List<OQOOD_FLG__c>  ListOQOOD{get;set;}
    @InvocableMethod public static void UpdateTask(List<Service_request__c> objlistSR){
        System.debug('...objlistSR...'+objlistSR);
        List<Service_request__c> listSR = new List<Service_request__c>();
        ListOQOOD =  new List<OQOOD_FLG__c> ();
        List<Task>  ListTask = new List<Task> ();
        User objUserID  = [Select ID , 
                               Name , 
                               Profile.Name  
                        From user 
                        WHERE IsActive = true 
                        AND Name = 'Finance User' limit 1];
        if(!objlistSR.isEmpty()){
            for(Service_request__c objSR : objlistSR){      
                ListOQOOD =[Select id , 
                                   Assignment_Feed_Paid__c , 
                                   OQOOD_Reg_Flag__c ,
                                   Party_ID__c ,
                                   Registration_ID__c ,
                                   Account__c
                            From OQOOD_FLG__c    
                            Where Account__c =: objSR.Account__c limit 1];
                System.debug('...ListOQOOD...'+ListOQOOD);          
                if(!ListOQOOD.isEmpty()){
                    for(OQOOD_FLG__c objlistOQOODFLG :ListOQOOD){
                        Task objTask = new Task();  
                        if(objlistOQOODFLG.OQOOD_Reg_Flag__c == true){
                        objTask.WhatID = objSR.ID;
                        objTask.Subject = 'Verify Payment Received';
                        objTask.Status ='Not Started';
                        objTask.OwnerId = objSR.Account__r.ownerID;
                        objTask.Priority = 'Normal';
                        ListTask.add(objTask);
                        System.debug('...ListTask...'+ListTask);
                        }
                        else{
                            Service_request__c objSRNew = new Service_request__c();
                            objSRNew.IsTask2_Completed__c = true;   
                            objSRNew.ID = objSR.ID; 
                            objTask.WhatID = objSR.ID;
                            objTask.Subject = 'Inform Customer on Approval';
                            objTask.Status ='Not Started';
                            objTask.OwnerId = UserInfo.getUserId();
                            objTask.Priority = 'Normal';
                            ListTask.add(objTask);                  
                            listSR.add(objSRNew);
                        }
                    }
                }
            }
            if(!ListTask.isEmpty()){
            List<Database.saveResult> results = Database.insert(ListTask,false);
            System.debug('.....results.....'+results);
            }
            if(!listSR.isEmpty()){
                System.debug('...listSR...'+listSR);
                update listSR;
            }
        }
        
    }
*/
}