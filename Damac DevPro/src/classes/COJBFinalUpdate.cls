public class COJBFinalUpdate {
    @InvocableMethod
    public static void finalUpdateAccount(List<Service_request__c> lstSR){
        system.debug('lstSR in HandleOCR ' +lstSR);
        Id cojbRecordTypeId = Schema.SObjectType.Service_Request__c.getRecordTypeInfosByName().get('Change of Joint Buyer').getRecordTypeId();
        Id nncRecordTypeId = Schema.SObjectType.Service_Request__c.getRecordTypeInfosByName().get('Name Nationality Change').getRecordTypeId();
        system.debug('cojbRecordTypeId '+ cojbRecordTypeId);
        system.debug('nncRecordTypeId '+ nncRecordTypeId);
        List<Account> AccountList = new list<Account>();
        for(Service_request__c sr : lstSR){
            if(sr.RecordTypeId == cojbRecordTypeId){
                Account a = new Account();
                a.Id = sr.Account__c;
                if(sr.Contact_Detail_to_update__c == 'email' ){
                    a.PersonEmail = sr.New_Contact_Value__c;    
                } else if (sr.Contact_Detail_to_update_2__c == 'email'){
                    a.PersonEmail = sr.New_Contact_Value_2__c;
                }
                
                if(sr.Contact_Detail_to_update__c == 'city'){
                    a.City__pc = sr.New_Contact_Value__c;  
                } else if (sr.Contact_Detail_to_update_2__c == 'city'){
                    a.City__pc = sr.New_Contact_Value_2__c;
                }
                
                AccountList.add(a);
            }
            else if ( sr.RecordTypeId == nncRecordTypeId ){
                Account a = new Account();
                a.Id = sr.Account__c;
                if(sr.New_Contact_Name__c != null){
                    List<String> parts = sr.New_Contact_Name__c.split(' ');
                    if(parts.size() > 1){
                        a.LastName = parts[parts.size() - 1];
                        String firstName = '';
                        for (Integer i = 0; i < parts.size() - 1; i++ ){
                            firstName += ' '+parts[i];
                        }
                        a.FirstName = firstName;    
                    } else {
                        a.LastName = parts[parts.size() - 1];
                        a.firstName = null;
                    }
                    
                }
                    
                
                if(sr.Changed_Nationality__c != null)
                    a.Nationality__pc = sr.Changed_Nationality__c;
                
                if(sr.Witness_Phone_Number__c != null)
                    a.Name_Nationality_Change_Witness_Number__c = sr.Witness_Phone_Number__c;
                
                if(sr.Witness_Address__c != null)
                    a.Name_Nationality_Change_Witness_Address__c = sr.Witness_Address__c;
                
                AccountList.add(a);
            }
            
        }
        update AccountList;
        NotifyUserAfterUpdate(lstSR);
        
    }
    
    public static void NotifyUserAfterUpdate(List<Service_request__c> lstSR){
        List<String> toAddresses = new List<String>();
        for( Service_request__c sr : lstSR){
            toAddresses.add(sr.Contact_Email_Id__c);
        } 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        
        mail.setSubject('Your Service request is completed' );
        String mailBody = 'Hi,<br/>'; 
        mailBody += '<p>Your request for details change is complete.</p><br/><br/>';
        mailBody += 'Thanks you,<br/>DAMAC Team.';
 
        mail.setHtmlBody( mailBody );
        system.debug('mail' + mail);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}