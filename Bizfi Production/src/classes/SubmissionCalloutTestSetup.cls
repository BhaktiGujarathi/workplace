@isTest
public class SubmissionCalloutTestSetup {

    public static String jsonSetup() {
        Account[] acctList = new Account[]{};
        Opportunity[] oppList = new Opportunity[]{};
        Contact[] conList = new Contact[]{};
        List<List<SObject>> jsonData = new List<List<SObject>>();

        Account a = new Account(Name = 'Submission Callout Test Account'); acctList.add(a);
        jsonData.add(acctList);
        Opportunity o = new Opportunity(Name = 'Submission Callout Test Opp'); oppList.add(o);
        jsonData.add(oppList);
        for(Integer i = 0; i < 12; i++){
            Contact c = new Contact(LastName = 'Surname-'+i); conList.add(c);
        }
        jsonData.add(conList);

        String body = JSON.serialize(jsonData);
        return body;
    }
    
    public static Map<Id, Opportunity> mapSetup(Boolean mix){

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();

        for(Integer n = 0; n < 9; n++){
            Opportunity o = new Opportunity();
            o.Id = '006d0000008WaW'+n+'AAK';

            if(n <= 2 && mix) {
                o.Is_Bizfi_Submission__c = true;
            } else if(n > 2 && mix) {
                o.Is_Bizfi_Submission__c = false;
            } else if(n <= 2 && !mix) {
                o.Is_Bizfi_Submission__c = false;
            } else{
                o.Is_Bizfi_Submission__c = true;
            }

            oppMap.put(o.Id, o);
        }

        return oppMap;
    }

}