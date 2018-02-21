public class CaseOCRRequestHandler {
    @InvocableMethod
    public static void HandleOCR(List<Case> lstSR){
        system.debug('lstSR in HandleOCR ' +lstSR);
        List<id> srIds = new list<id>();
        List<Account> accountsToBeUpdated = new List<Account>();
        String rectype = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Change of Details').getRecordTypeId();
        for(Case sr : lstSR){
            srIds.add(sr.Id);
            if(sr.Type == 'Change of Contact Details' && sr.RecordTypeId == rectype && ((sr.IsPOA__c == true && sr.Is_POA_Verified__c == true) || sr.IsPOA__c == false ) && sr.OCR_verified__c == true && ( (sr.OQOOD_Fee_Applicable__c == true && sr.OQOOD_Fee_Verified__c == true) || sr.OQOOD_Fee_Applicable__c == false)){
              Account a = new Account(
              id=sr.AccountId,
              Country__pc=sr.Country__c,
              Country_Arabic__pc=sr.Country_Arabic__c,
              Address_Line_1__pc=sr.Address__c,
              Address_Line_1_Arabic__pc=sr.Address_Arabic_1__c,
              Address_Line_2__pc=sr.Address_2__c,
              Address_Line_2_Arabic__pc=sr.Address_Arabic_2__c,
              Address_Line_3__pc=sr.Address_3__c,
              Address_Line_3_Arabic__pc=sr.Address_Arabic_3__c,
              Address_Line_4__pc=sr.Address_4__c,
              Address_Line_4_Arabic__pc=sr.Address_Arabic_4__c,
              City__pc=sr.City__c,
              City_Arabic__pc=sr.City_Arabic__c,
              State__c=sr.State__c,
              State_Arabic__c=sr.State_Arabic__c,
              Zip_Postal_Code__c=sr.Postal_Code__c,
              Postal_Code_Arabic__pc=sr.Postal_Code_Arabic__c,
              PersonEmail=sr.Contact_Email__c,
              Mobile_Country_Code__pc=sr.Mobile_Country_Code__c,
              PersonMobilePhone=sr.Contact_Mobile__c,
              Home_Phone_Country_Code__c=sr.Home_Phone_Country_Code__c,
              PersonHomePhone=sr.Home_Phone__c,
              Work_Phone_Country_Code__c=sr.Work_Phone_Country_Code__c,
              Work_Phone__c=sr.Work_Phone__c
              );
              accountsToBeUpdated.add(a);
            }
        }
        OCRCallout.sendDocumentToOCR(srIds);

        if(!accountsToBeUpdated.isEmpty()){
          //update accountsToBeUpdated;
        }
        //CreateTaskForManualVerification(lstSR);

    }

    /*public static void CreateTaskForManualVerification(List<Case> lstSR){
List<Task> manualTasks = new List<Task>();
for(Case c: lstSR){
Task t = new  Task();
t.WhatId = c.Id;
t.ActivityDate = system.today();
t.Type = 'General Task';
t.OwnerId = c.OwnerId;
Subject = 'Here\'s my subject';
Description = 'Description';
}
}*/
}