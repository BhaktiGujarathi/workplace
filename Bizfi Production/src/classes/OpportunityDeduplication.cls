public class OpportunityDeduplication{

    public void onOpportunityStageUpdate(Map<Id,Opportunity> oldmap, List<Opportunity> newList) {
        
        List<Id>      accountIds       = new List<Id>();
        List<Account> accountsList     = new List<Account>();
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id>       opportunitiesSet = new Set<Id>();


        for (Opportunity opportunity : newList) {  
            
            if (oldmap == null || (oldmap.containsKey(opportunity.Id) && opportunity.StageName != oldmap.get(opportunity.Id).StageName)) {
                
                accountIds.add(opportunity.AccountId);
                opportunitiesSet.add(opportunity.id);
            }
            else if (opportunity.DupRefOppId__c != null || opportunity.DupRefLeadId2__c != null) {

                accountIds.add(opportunity.AccountId);
                opportunitiesSet.add(opportunity.id);
            }
        }

        if (!accountIds.isEmpty()){
            
            system.debug('@@@@@@ in deduplication trigger');
            
            accountsList = [SELECT Id, Opportunity_Stage_Category__c, (SELECT Id, McaApp__Funded__c from Opportunities ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id IN: accountIds];

            Map<Id, Id> newestAccountOpportunity = new Map<Id, Id>();

            for (Account account : accountsList) {

                if (account.Opportunities != null) {

                    newestAccountOpportunity.put(account.Id, account.Opportunities.get(0).Id);
                }
            }


            for (Opportunity opportunity : newList) {

                if (newestAccountOpportunity.containsKey(opportunity.AccountId)) {

                    if (newestAccountOpportunity.get(opportunity.AccountId) == opportunity.Id) {

                        if (opportunity.DupRefOppId__c != null || opportunity.DupRefLeadId2__c != null) {

                            Account account = new Account(Id = opportunity.AccountId);

                            account.Opportunity_Stage_Category__c = 'Duplicate Opp';

                            accountsToUpdate.add(account);

                        }
                        else {

                            Account account = new Account(Id = opportunity.AccountId);

                            mapOpportunityAccountStageValues(opportunity, account);

                            accountsToUpdate.add(account);
                        }
                    }
                }
            }

            //Map<Id,Account> OpportunitiesAndAccountsMap = new Map<Id, Account>();

            //for (Account myAccount : accountsList) {              
                
            //    boolean hasFundedOpportunity = false;
            //    Integer index = 0;

            //    List<Opportunity> opportunitiesForThisAccount = myAccount.getSObjects('Opportunities');

            //    // If an Account has an Opportunity that funds, the Account becomes a renewal account, and the Opportunity Stage Category will forever remain Funded Opp.
            //    while (!hasFundedOpportunity && index <  opportunitiesForThisAccount.size()) {
                    
            //        Opportunity oppty = opportunitiesForThisAccount[index];

            //        // Let's exclude the Opportunity we are working with.
            //        if(oppty.McaApp__Funded__c && !opportunitiesSet.contains(oppty.Id)){
            //            hasFundedOpportunity = true;
            //        }

            //        index ++;
            //    }
                
            //    if (!hasFundedOpportunity) {
            //        OpportunitiesAndAccountsMap.put(myAccount.getSObjects('Opportunities')[0].Id, myAccount);
            //    }
            //}

            //for (Opportunity opportunity : newList) {
                
            //    if (OpportunitiesAndaccountsMap.containsKey(opportunity.Id)) {
                   
            //        Account myAccount = OpportunitiesAndAccountsMap.get(opportunity.Id);

            //        mapOpportunityAccountStageValues(opportunity,myAccount);

            //        accountsToUpdate.add(myAccount);
            //    }
            //}
        }


        update accountsToUpdate;
    }

    private void mapOpportunityAccountStageValues(Opportunity oppty, Account myAccount){
        
        if (oppty.StageName == 'Application Sent' || oppty.StageName == 'Application Missing Info') {
            
            myAccount.Opportunity_Stage_Category__c = 'Apped Opp';
        }
        else if (oppty.StageName == 'Application In' || oppty.StageName == 'Underwriting' || oppty.StageName == 'Approved' || oppty.StageName == 'Agreement Requested') {
            
            myAccount.Opportunity_Stage_Category__c = 'Submitted Opp';
        }
        else if(oppty.StageName == 'Agreement Sent' || oppty.StageName == 'Agreement Signed') {
            
            myAccount.Opportunity_Stage_Category__c = 'Contracted Opp';
        }
        else if(oppty.StageName == 'Funded' || oppty.StageName == 'Renewal Prospecting' || oppty.StageName == 'Renewal Requested') {
            
            myAccount.Opportunity_Stage_Category__c = 'Funded Opp';
        }
        else if(oppty.StageName == 'Declined' || oppty.StageName == 'Closed Lost' || oppty.StageName == 'Closed Lost - Merchant' || oppty.StageName == 'Closed Lost - Funding Source') {
            
            myAccount.Opportunity_Stage_Category__c = 'Dead Opp'; //Dead Opp – Declined, Closed Lost- Merchant, Closed Lost-Funding Source
        }
        else if (oppty.StageName == 'Closed Lost - Duplicate') {

            myAccount.Opportunity_Stage_Category__c = 'Duplicate Opp';
        }
    }
}