public class VerifyDocumentOnSRAttachment{

    @InvocableMethod public static void VerifyDocument(List<SR_Attachments__c> lstSRAttachment){
        map<Id, boolean> mapSRAtt_IsValid = new map<Id, boolean>();
        set<Id> setCaseId = new set<Id>();
        list<SR_Attachments__c> lstSRAtt = new list<SR_Attachments__c>();
        list<Case> lstCase = new list<Case>();

        for (SR_Attachments__c objSRAttachment : lstSRAttachment) {
            setCaseId.add(objSRAttachment.Case__c);
        }//End for

        for (SR_Attachments__c objSRAttachment : [Select Id, 
                                                         isValid__c
                                                    From SR_Attachments__c 
                                                   Where Case__c IN: setCaseId]) {
             lstSRAtt.add(objSRAttachment);
             if(objSRAttachment.isValid__c==True)
              mapSRAtt_IsValid.put(objSRAttachment.id, objSRAttachment.isValid__c);
        }//End for


        if(lstSRAtt!=null & lstSRAtt.size()>0){
          For(Case objCase : [select ID,
                                     Document_Verified__c,
                                     Rental_Pool_Termination_Status__c,
                                     RecordType.DeveloperName,
                                     RecordTypeId
                                from Case where ID IN: setCaseId]){
              if(lstSRAtt.size() == mapSRAtt_IsValid.values().size()){
                    objCase.Document_Verified__c = True;
                    if (objCase.RecordType.DeveloperName == 'Rental_Pool_Termination') {
                        objCase.Rental_Pool_Termination_Status__c = 'Documents Verified';
                    }
              }//end if-else
                    lstCase.add(objCase);
            }//End for
        }//End if

        //Update Verified Document on SR
        try{
            if(lstCase!=null & lstCase.size()>0)
             Update lstCase;
        }catch(DMLException errorMessage){
            system.debug('Error Message'+ errorMessage);
        }//End try-catch

    }//End VerifyDocument
}