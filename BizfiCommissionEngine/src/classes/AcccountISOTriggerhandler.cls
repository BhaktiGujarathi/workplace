/*
    Created by:Srikanth Pinnamaneni
*/

Public class AcccountISOTriggerhandler{


    Public Static void checkExsistingMethod(List<Account> Newlist){
        
        List < recordType > record = [select id, name, SobjectType from Recordtype where SobjectType = 'Account' AND Name = 'ISO'];
        id recordid = record[0].id;

        List < Account > accList = [select id, name, McaApp__User__c from account where recordtypeid = : recordid];
        for (Account Acc: Newlist) {
            if (Acc.recordtypeid == recordid) {
                if (accList != null && accList.size() > 0 && Acc.McaApp__User__c != null) {
        
                    for (Account Acct: accList) {
                        if (Acct.id != acc.id) {
                            if (Acc.McaApp__User__c == acct.McaApp__User__c) {
                                system.debug('sds' + '  ' + acc.id + '    ' + acct.id);
                                Acc.adderror('User exists on a different ISO Account. Please choose another User ');
                            }
                        }
                    }
                }
            }
        }
    
    }
}