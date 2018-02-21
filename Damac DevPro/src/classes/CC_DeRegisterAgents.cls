/**************************************************************************************************
* Name               : CC_DeRegisterAgents                                                        *
* Description        : Custom code for de-registring agents.                                      *
* Created Date       : 05/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION   AUTHOR      DATE            COMMENTS                                                  *
* 1.0       NSI         05/02/2017      Initial Draft.                                            *
**************************************************************************************************/
global without sharing class CC_DeRegisterAgents implements NSIBPM.CustomCodeExecutable, Queueable {
    
    public List<Id> deactivateContactIdsList = new List<Id>();
    
    public CC_DeRegisterAgents(){
        
    }
    
    public CC_DeRegisterAgents(List<Id> deactivateContactIdsList){
        this.deactivateContactIdsList = deactivateContactIdsList;   
    }
    
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step) {
        String result = 'Success';
        Account newAcc;
        try {
            if(step.NSIBPM__SR__c != null){
                for(Amendment__c thisAmendment : getAllAmendments(step.NSIBPM__SR__c)) {
                    if(thisAmendment.Mark_For_Deletion__c){
                        deactivateContactIdsList.add(thisAmendment.Contact__c);
                    }
                }
                if(!deactivateContactIdsList.isEmpty()){
                    deactivateContacts(deactivateContactIdsList);
                    //deactivateUsers(deactivateContactIdsList);
                    System.enqueueJob(new CC_DeRegisterAgents(deactivateContactIdsList));   
                }
            }else{
                result = 'Step is not associated to a service request.';    
            }
        }catch(Exception e) {
            result = 'Error :' + e.getMessage() + '';
        }
        return result;
    }
    
    public List<Amendment__c> getAllAmendments(Id SrId) {
        String amendmentQuery = UtilityQueryManager.getAllFields(Amendment__c.getsObjectType().getDescribe());
        amendmentQuery += ' WHERE Service_Request__c =: SRId';
        return (Database.query(amendmentQuery));
    }
    
    public void execute(QueueableContext qc) {
        deactivateUsers(deactivateContactIdsList);  
    }
    
    public void deactivateContacts(List<Id> contactIdsList){
        List<Contact> contactList =  new List<Contact>();
        for(Id thisId : contactIdsList){
           Contact newContact = new Contact();
           newContact.Id = thisId;
           newContact.Status__c = 'Cancelled';
           contactList.add(newContact);
        }
        if(!contactList.isEmpty()){
            update contactList;
        }
    }
    
    public static void deactivateUsers(List<Id> contactIdsList){
        List<user> userList = new List<User>();
        for(User thisUser : [SELECT Id, isActive FROM User WHERE contactId IN : contactIdsList]){
            thisUser.isActive = false;
            userList.add(thisUser);
        }
        if(!userList.isEmpty()){
            update userList;
        }
    }
}// End of class.