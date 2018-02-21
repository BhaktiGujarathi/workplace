public with sharing class VolumeBonusTierTriggerHandler {
    
    private Map<Id, Volume_Bonus_Tier__c[]> existingBonusesMap;


    public VolumeBonusTierTriggerHandler() {
        
        queryExistingBonuses();
    }


    public void validateRecords(Volume_Bonus_Tier__c[] newBonusTiers) {


        for (Volume_Bonus_Tier__c bonus : newBonusTiers) {

            if (bonus.Active__c) {

                if (isValidRecord(bonus)) {

                    if (!existingBonusesMap.containsKey(bonus.Bank__c)) {
                        
                        existingBonusesMap.put(bonus.Bank__c, new Volume_Bonus_Tier__c[]{});
                    }

                    existingBonusesMap.get(bonus.Bank__c).add(bonus);

                }
                else {

                    bonus.addError('Cannot have active Volume Bonus Tier records of conflicting types or overlapping ranges.');
                }
            }            
        }
    }


    private Boolean isValidRecord(Volume_Bonus_Tier__c bonus) {

        Volume_Bonus_Tier__c[] existingBonuses = existingBonusesMap.get(bonus.Bank__c);

        if (existingBonuses != null) {
            
            for (Volume_Bonus_Tier__c existingBonus : existingBonuses) {

                if (bonus.Id != existingBonus.Id) {

                    if (!validateRange(bonus.Min_Volume_Amount__c, bonus.Max_Volume_Amount__c, existingBonus.Min_Volume_Amount__c, existingBonus.Max_Volume_Amount__c) && 
                        !validateRange(bonus.Min_Booking_Rate__c, bonus.Max_Booking_Rate__c, existingBonus.Min_Booking_Rate__c, existingBonus.Max_Booking_Rate__c)) {

                        if (bonus.Type__c == 'All Deals' || existingBonus.Type__c == 'All Deals'
                                                         || bonus.Type__c == existingBonus.Type__c) {

                            
                            return false;
                        }
                    }
                }

            }
        }

        return true;
    }


    private Boolean validateRange(Decimal lowerLeft, Decimal upperLeft, Decimal lowerRight, Decimal upperRight) {
        
        
        if (lowerLeft == lowerRight || upperLeft == upperRight) {
        
            return false;
        }


        if (lowerLeft > upperRight) {

            return true;
        }
        else {

            if (upperLeft < lowerRight) {

                return true;
            }              
        }

        return false;
    }


    private void queryExistingBonuses() {

        Volume_Bonus_Tier__c[] existingBonuses = [select Bank__c,
                                                         Type__c, 
                                                         Active__c, 
                                                         Start_Date__c, 
                                                         End_Date__c, 
                                                         Bonus_Payout__c, 
                                                         Min_Volume_Amount__c, 
                                                         Max_Volume_Amount__c,
                                                         Min_Booking_Rate__c,
                                                         Max_Booking_Rate__c 
                                                    from Volume_Bonus_Tier__c
                                                   where Active__c = true];

        existingBonusesMap = new Map<Id, Volume_Bonus_Tier__c[]>();


        for (Volume_Bonus_Tier__c bonusTier : existingBonuses) {

            if(!existingBonusesMap.containsKey(bonusTier.Bank__c)) {

                existingBonusesMap.put(bonusTier.Bank__c, new Volume_Bonus_Tier__c[]{});
            }

            existingBonusesMap.get(bonusTier.Bank__c).add(bonusTier);
        }
    }
}