public with sharing class TaskClosureService {
    @InvocableMethod 
    public static void verifyCaseAttachment( list<Task> lstTask ) {
        system.debug('Task Closure Service Called .......');
        system.debug('TlstTask d .......'+lstTask );
        set<Id> setCaseId = new set<Id>();
        set<String> setDocURL = new set<String>();
        
        for( Task objTask : lstTask ) {
            if( String.isNotBlank( objTask.Status ) && objTask.Status.equalsIgnoreCase('Completed') && 
                String.isNotBlank( objTask.Assigned_User__c ) && objTask.Assigned_User__c.equalsIgnoreCase('Legal') && 
                String.isNotBlank( objTask.Document_URL__c ) && String.valueOf( objTask.whatId ).startsWith('500') ) {
                setCaseId.add( objTask.whatId );
                setDocURL.add( objTask.Document_URL__c );
            }
        }
        
        if( !setCaseId.isEmpty() && !setDocURL.isEmpty() ) {
            list<SR_Attachments__c> lstCustomAttach = [ SELECT Id
                                                        , isValid__c
                                                        , Attachment_URL__c
                                                        , Case__c
                                                     FROM SR_Attachments__c
                                                    WHERE Case__c IN :setCaseId
                                                      AND Attachment_URL__c IN :setDocURL ] ;
            if( lstCustomAttach != null && !lstCustomAttach.isEmpty() ) {
                for( SR_Attachments__c objAtt : lstCustomAttach ) {
                    objAtt.isValid__c = true ;
                }
                 system.debug('lstCustomAttach  .......'+lstCustomAttach  );
                update lstCustomAttach ;
            }
        }                                         
    }
}