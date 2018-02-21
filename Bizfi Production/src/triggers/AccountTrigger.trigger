trigger AccountTrigger on Account (after insert, after update) {

    Account[] applicantProcessAccounts = new Account[]{};
    Account[] customerProcessAccounts  = new Account[]{};
    Account[] prospectProcessAccounts  = new Account[]{};

    for (Account account : Trigger.new) {

        if (Trigger.old == null || Trigger.oldMap.get(account.Id).Opportunity_Stage_Category__c != account.Opportunity_Stage_Category__c) {

            if (DedupeApplicantProcessService.APPLICANT_CATEGORIES.contains(account.Opportunity_Stage_Category__c)) {

                applicantProcessAccounts.add(account);
            }
            else if (account.Opportunity_Stage_Category__c == 'Funded Opp') {

                customerProcessAccounts.add(account);
            }
            else if(account.Opportunity_Stage_Category__c == 'Apped Opp'){
                
                prospectProcessAccounts.add(account);
            }
        } 
    }           

    if (!applicantProcessAccounts.isEmpty()) {

        DedupeApplicantProcessService service = new DedupeApplicantProcessService(applicantProcessAccounts);
        service.initDedupe();
    }

    if (!customerProcessAccounts.isEmpty()) {

        DedupeCustomerProcessService service = new DedupeCustomerProcessService(customerProcessAccounts);
        service.initDedupe();
    }

    if (!prospectProcessAccounts.isEmpty()) {
        DedupeProspectProcessServiceForAccounts service = new DedupeProspectProcessServiceForAccounts(prospectProcessAccounts);
        service.initDedupe();
    }
}