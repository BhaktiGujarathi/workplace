public with sharing class AccountingCalendarMonthHandler {
    
    private static AccountingCalendarMonthHandler instance = null;

    private RecordType recOpportunity;
    private RecordType legacyOpportunity;
    private RecordType recPayable;
    private RecordType defPayable;
    private RecordType recReceivable;
    private RecordType defReceivable;


    public static AccountingCalendarMonthHandler getInstance() {

        if (instance == null) {

            instance = new AccountingCalendarMonthHandler();
        }

        return instance;
    }


    private AccountingCalendarMonthHandler() {

        recOpportunity = [SELECT Id 
                            FROM RecordType 
                           WHERE sObjectType = 'Opportunity' 
                             AND DeveloperName = 'Read_Only'];
        
        legacyOpportunity = [SELECT Id 
                               FROM RecordType 
                              WHERE sObjectType = 'Opportunity' 
                                AND DeveloperName = 'Legacy_Funding_Opportunity'];


        recPayable = [SELECT Id 
                        FROM RecordType 
                       WHERE sObjectType = 'McaApp__Payable__c' 
                         AND DeveloperName = 'Read_Only'];
        
        defPayable = [SELECT Id 
                        FROM RecordType 
                       WHERE sObjectType = 'McaApp__Payable__c' 
                         AND DeveloperName = 'Default'];     


        recReceivable = [SELECT Id 
                           FROM RecordType 
                          WHERE sObjectType = 'McaApp__Receivable__c' 
                            AND DeveloperName = 'Read_Only'];

        defReceivable = [SELECT Id 
                           FROM RecordType 
                          WHERE sObjectType = 'McaApp__Receivable__c' 
                            AND DeveloperName = 'Default'];
    }


    public void lockOpportunities(Opportunity[] opportunities, Boolean isDelete) {
       
        Opportunity[] updateOpportunities = new Opportunity[]{};
        
        for (Opportunity opp : opportunities) {
            
            if (isDelete) {
                
                if (opp.RecordTypeId != legacyOpportunity.Id){
                    
                    opp.RecordtypeId = LegacyOpportunity.Id;
                    
                    updateOpportunities.add(opp);
                }
            }
            else {
                
                if (opp.RecordTypeId != recOpportunity.Id) {
                    
                    opp.RecordtypeId = recOpportunity.Id;
                    
                    updateOpportunities.add(opp);
                }
            }
        }

        if (!updateOpportunities.isEmpty()) {

            Database.update(updateOpportunities, false);
        }
    }


    public void lockPayables(McaApp__Payable__c[] payables, Boolean isDelete) {

        McaApp__Payable__c[] updatePayables = new McaApp__Payable__c[]{};
        
        for (McaApp__Payable__c payable : payables) {
            
            if (isDelete) {
                
                if (payable.RecordTypeId != defPayable.Id) {
                    
                    payable.RecordtypeId = defPayable.Id;
                    
                    updatePayables.add(payable);
                }
            }
            else {
                
                if (payable.RecordTypeId != recPayable.Id) {
                    
                    payable.RecordtypeId = recPayable.Id;
                    
                    updatePayables.add(payable);
                }
            }
        }   

        if (!updatePayables.isEmpty()) {

            Database.update(updatePayables, false);
        }      
    }


    public void lockReceivable(McaApp__Receivable__c[] receivables, Boolean isDelete) {

        McaApp__Receivable__c[] updateReceivables = new McaApp__Receivable__c[]{};

        for (McaApp__Receivable__c receivable : receivables) {
            
            if (isDelete) {
                
                if (receivable.RecordTypeId != defReceivable.Id){
                
                    receivable.RecordtypeId = defReceivable.Id;
                
                    updateReceivables.add(receivable);
                }
            }
            else{
                
                if(receivable.RecordtypeId != recReceivable.Id){
                
                    receivable.RecordTypeId = recReceivable.Id;
                
                    updateReceivables.add(receivable);
                }
            }
        }       

        if (!updateReceivables.isEmpty()) {

            Database.update(updateReceivables, false);
        }
    }
}