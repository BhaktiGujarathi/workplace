public class VolumeBonusRollUpHandler {
    
    private static String[] MONTHS = new String[]{'January','February','March','April','May','June','July','August','September','October','November','December'};
    private static Set<String> TYPE_NEW = new Set<String>{'New Deal','Concurrent Deal','Additional Funds', 'Other'};
    private static Set<String> TYPE_RENEWAL = new Set<String>{'Refinance','Concurrent Renewal','Other Renewal'};
    private static Set<String> OFFER_OUT_STATUS = new Set<String>{'Presented','Revision'};
    private static Set<String> OFFER_IN_STATUS = new Set<String>{'Chosen'};


    private Account account;
    private Opportunity[] opportunities;
    private McaApp__Offer__c[] offers;
    private Volume_Bonus_Tier__c[] bonuses;


    public VolumeBonusRollUpHandler(String accountId) {
        
        opportunities = new Opportunity[]{};

        if (accountId != null) {
            
            querySObjects(accountId);   
        }
    }


    public void rollup() {

        initAccountFields();

        if (!opportunities.isEmpty()) {

            rollupAllFields();

            rollupNewFields();

            rollupRenewalsFields();
        }

        updateAccountFields();
    }


    private void querySObjects(String accountId) {

        account = [select Id                        
                     from Account
                    where Id = :accountId];

        //Integer month = getMonthNumber(account.Current_Month__c);                   
        
        opportunities = [select McaApp__Bank_Name__c,
                                McaApp__Date_Funded__c,
                                Type,
                                McaApp__Funding_Amount__c,
                                StageName
                           from Opportunity
                          where McaApp__Bank_Name__c = :accountId
                            and McaApp__Date_Funded__c = THIS_MONTH];

    
        offers = [select McaApp__Amount__c,
                         McaApp__Status__c,
                         McaApp__Opportunity__r.StageName,
                         McaApp__Opportunity__r.Type
                    from McaApp__Offer__c
                   where McaApp__Funder__c = :accountId
                     and CreatedDate = THIS_MONTH];     

        
        bonuses = [select Bonus_Payout__c, 
                          Min_Volume_Amount__c, 
                          Max_Volume_Amount__c,
                          Min_Booking_Rate__c,
                          Max_Booking_Rate__c,
                          Type__c 
                     from Volume_Bonus_Tier__c
                    where Active__c = true
                      and Bank__c = :accountId];                                  
    }


    private Integer getMonthNumber(String currentMonth) {

        if (currentMonth != null) {

            Integer i = 0;

            for (String month : MONTHS) {

                if (currentMonth.toLowerCase() == month.toLowerCase()) {

                    return (i + 1);
                }

                i++;
            }
        }

        return (Date.today().month() + 1);
    }


    private void initAccountFields() {

        account.All_Contracts_In__c = 0;
        account.All_Contracts_Out__c = 0;
        account.All_Current_Bonus__c = 0;
        account.All_Current_Booking_Rate__c = 0;
        account.All_Current_Payout__c = 0;
        account.All_Current_Total_Funding__c = 0;
        account.All_Next_Tier_Difference__c = 0;
        account.All_Next_Tier_Min_Volume__c = 0;
        account.All_Next_Tier_Payout__c = 0;
        account.All_Potential_Bonus__c = 0;
        account.All_Potential_Payout__c = 0;
        account.All_Potential_Total_Funding__c = 0;
        account.New_Contracts_In__c = 0;
        account.New_Contracts_Out__c = 0;
        account.New_Current_Bonus__c = 0;
        account.New_Current_Booking_Rate__c = 0;
        account.New_Current_Payout__c = 0;
        account.New_Current_Total_Funding__c = 0;
        account.New_Next_Tier_Difference__c = 0;
        account.New_Next_Tier_Min_Volume__c = 0;
        account.New_Next_Tier_Payout__c = 0;
        account.New_Potential_Bonus__c = 0;
        account.New_Potential_Payout__c = 0;
        account.New_Potential_Total_Funding__c = 0;
        account.Renewals_Contracts_In__c = 0;
        account.Renewals_Contracts_Out__c = 0;
        account.Renewals_Current_Bonus__c = 0;
        account.Renewals_Current_Booking_Rate__c = 0;
        account.Renewals_Current_Payout__c = 0;
        account.Renewals_Current_Total_Funding__c = 0;
        account.Renewals_Next_Tier_Difference__c = 0;
        account.Renewals_Next_Tier_Min_Volume__c = 0;
        account.Renewals_Next_Tier_Payout__c = 0;
        account.Renewals_Potential_Bonus__c = 0;
        account.Renewals_Potential_Payout__c = 0;
        account.Renewals_Potential_Total_Funding__c = 0;
    }


    private void rollupFields(String fieldGroup) {
        

        for (Opportunity opp : opportunities) {
    
            if (fieldGroup == 'All' || fieldGroup == 'New' && TYPE_NEW.contains(opp.Type)
                                    || fieldGroup == 'Renewals' && TYPE_RENEWAL.contains(opp.Type)) {

                if (opp.StageName == 'Funded') {

                    Decimal currentTotalFunding = (Decimal) account.get(fieldGroup + '_Current_Total_Funding__c');

                    if (currentTotalFunding == null) {
                        currentTotalFunding = 0;
                    }

                    account.put(fieldGroup + '_Current_Total_Funding__c', currentTotalFunding + (opp.McaApp__Funding_Amount__c != null ? opp.McaApp__Funding_Amount__c : 0));
                }
            }
        }


        for (McaApp__Offer__c offer : offers) {

            if (fieldGroup == 'All' || fieldGroup == 'New' && TYPE_NEW.contains(offer.McaApp__Opportunity__r.Type)
                                    || fieldGroup == 'Renewals' && TYPE_RENEWAL.contains(offer.McaApp__Opportunity__r.Type)) {

                if (OFFER_OUT_STATUS.contains(offer.McaApp__Status__c) && offer.McaApp__Opportunity__r.StageName == 'Agreement Sent') {
                    
                    Decimal contractsOut = (Decimal) account.get(fieldGroup + '_Contracts_Out__c');

                    account.put(fieldGroup + '_Contracts_Out__c', contractsOut + offer.McaApp__Amount__c);
                }

                if (OFFER_IN_STATUS.contains(offer.McaApp__Status__c) && offer.McaApp__Opportunity__r.StageName == 'Agreement Signed') {
                
                    Decimal contractsIn = (Decimal) account.get(fieldGroup + '_Contracts_In__c');

                    account.put(fieldGroup + '_Contracts_In__c', contractsIn + offer.McaApp__Amount__c);
                }
            }
        }


        Decimal currentTotalFunding = (Decimal) account.get(fieldGroup + '_Current_Total_Funding__c');
        Decimal contractsOut = (Decimal) account.get(fieldGroup + '_Contracts_Out__c');
        Decimal contractsIn = (Decimal) account.get(fieldGroup + '_Contracts_In__c');
        account.put(fieldGroup + '_Potential_Total_Funding__c', currentTotalFunding + contractsOut + contractsIn);


        Decimal countOfOpportunities = 0;
        Decimal countOfOffers = 0;

        for (Opportunity opp : opportunities) {
            
            if (fieldGroup == 'All' || fieldGroup == 'New' && TYPE_NEW.contains(opp.Type)
                                    || fieldGroup == 'Renewals' && TYPE_RENEWAL.contains(opp.Type)) {           
                
                if (opp.StageName == 'Funded') {

                    countOfOpportunities++;
                }
            }
        }


        for (McaApp__Offer__c offer : offers) {

            if (fieldGroup == 'All' || fieldGroup == 'New' && TYPE_NEW.contains(offer.McaApp__Opportunity__r.Type)
                                    || fieldGroup == 'Renewals' && TYPE_RENEWAL.contains(offer.McaApp__Opportunity__r.Type)) {
            
                countOfOffers++;
            }
        }
    

        if (countOfOffers > 0) {

            account.put(fieldGroup + '_Current_Booking_Rate__c', (countOfOpportunities / countOfOffers) * 100);
        }


        for (Volume_Bonus_Tier__c bonus : bonuses) {

            Decimal currentBookingRate = (Decimal) account.get(fieldGroup + '_Current_Booking_Rate__c');

            if (bonus.Min_Volume_Amount__c <= currentTotalFunding && 
                bonus.Max_Volume_Amount__c >= currentTotalFunding &&
                bonus.Min_Booking_Rate__c <= currentBookingRate &&
                bonus.Max_Booking_Rate__c >= currentBookingRate) {

                if ((fieldGroup == 'All' && bonus.Type__c == 'All Deals') || 
                    (fieldGroup == 'New' && bonus.Type__c == 'New Deals') || 
                    (fieldGroup == 'Renewals' && bonus.Type__c == 'Renewals')) {

                    account.put(fieldGroup + '_Current_Payout__c', bonus.Bonus_Payout__c);
                }
            }           
        }


        Decimal currentPayout = (Decimal) account.get(fieldGroup + '_Current_Payout__c');
        account.put(fieldGroup + '_Current_Bonus__c', currentTotalFunding * currentPayout / 100);


        for (Volume_Bonus_Tier__c bonus : bonuses) {

            Decimal potentialTotalFunding = (Decimal) account.get(fieldGroup + '_Potential_Total_Funding__c');
            Decimal currentBookingRate = (Decimal) account.get(fieldGroup + '_Current_Booking_Rate__c');

            if (bonus.Min_Volume_Amount__c < potentialTotalFunding && 
                bonus.Max_Volume_Amount__c > potentialTotalFunding &&
                bonus.Min_Booking_Rate__c <= currentBookingRate &&
                bonus.Max_Booking_Rate__c >= currentBookingRate) {

                if ((fieldGroup == 'All' && bonus.Type__c == 'All Deals') || 
                    (fieldGroup == 'New' && bonus.Type__c == 'New Deals') || 
                    (fieldGroup == 'Renewals' && bonus.Type__c == 'Renewals')) {
                    
                    account.put(fieldGroup + '_Potential_Payout__c', bonus.Bonus_Payout__c);
                }
            }
        }       


        Decimal potentialTotalFunding = (Decimal) account.get(fieldGroup + '_Potential_Total_Funding__c');
        Decimal potentialPayout = (Decimal) account.get(fieldGroup + '_Potential_Payout__c');
        account.put(fieldGroup + '_Potential_Bonus__c', potentialTotalFunding * potentialPayout / 100);


        Volume_Bonus_Tier__c nextHigherBonus;

        for (Volume_Bonus_Tier__c bonus : bonuses) {

            if ((fieldGroup == 'All' && bonus.Type__c == 'All Deals') || 
                (fieldGroup == 'New' && bonus.Type__c == 'New Deals') || 
                (fieldGroup == 'Renewals' && bonus.Type__c == 'Renewals')) {

                if (currentTotalFunding < bonus.Min_Volume_Amount__c) {

                    if (nextHigherBonus == null || nextHigherBonus.Min_Volume_Amount__c > bonus.Min_Volume_Amount__c) {
                        
                        Decimal currentBookingRate = (Decimal) account.get(fieldGroup + '_Current_Booking_Rate__c');

                        if (bonus.Min_Booking_Rate__c <= currentBookingRate && bonus.Max_Booking_Rate__c >= currentBookingRate) {

                            nextHigherBonus = bonus;
                        }
                    }
                }
            }
        }           

        if (nextHigherBonus != null) {

            account.put(fieldGroup + '_Next_Tier_Min_Volume__c', nextHigherBonus.Min_Volume_Amount__c);

            account.put(fieldGroup + '_Next_Tier_Payout__c', nextHigherBonus.Bonus_Payout__c);

            account.put(fieldGroup + '_Next_Tier_Difference__c', nextHigherBonus.Min_Volume_Amount__c - currentTotalFunding);
        }       
    }   


    private void rollupAllFields() {
        
        rollupFields('All');

    }


    private void rollupNewFields() {

        rollupFields('New');

    }

    
    private void rollupRenewalsFields() {

        rollupFields('Renewals');

    }


    private void updateAccountFields() {

        if (account.All_Current_Payout__c == 0 && account.All_Current_Bonus__c == 0) {

            account.All_Current_Bonus__c = account.New_Current_Bonus__c + account.Renewals_Current_Bonus__c;
        }

        if (account.All_Potential_Payout__c == 0 && account.All_Potential_Bonus__c == 0) {

            account.All_Potential_Bonus__c = account.New_Potential_Bonus__c + account.Renewals_Potential_Bonus__c;
        }

        update account;
    }
}