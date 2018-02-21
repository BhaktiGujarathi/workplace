/* Class to calculate the Roll-up of Amount of Payables on Opportunity
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    11/04/2014                              Initial Draft
 */ 

public with sharing class CalculatePayableRollup {
    
    //Variable Declaration                                         
    public Set<Id> opportunityIds = new Set<Id>();
    public Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
    public Map<Id, list<Payable__c>> payableListRecordMap = new  Map<Id, list<Payable__c>> ();
    public list<Payable__c> lstpayablewithCommission = new list<Payable__c> ();
    public list<Payable__c> lstpayableAll = new list<Payable__c> ();
        
    /*Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission*/
    public  void CalculateTotalCommissionsPayable(map<Id,Payable__c> pOldPayableMap, 
                                             list<Payable__c> pPayableList){
       
        
        for(Payable__c Payable: pPayableList){
            opportunityIds.add(Payable.Opportunity__c);
            opportunityIds.remove(null);
        }
        
        // To iterate over Opportunity Ids
        for(Id opportunityId:opportunityIds){
            opportunityMap.put(opportunityId,resetOppRollUp(opportunityId));
        }
        
        if(!opportunityMap.isEmpty() && opportunityMap <> null){
            //Query Payable using Opportunity Id
            lstpayableAll = this.selectPayableQuery(opportunityIds);          
        }
        
        //iterate over Opportunity record to add Campaign Id and Opportunity record          
        for(Payable__c payable : lstpayableAll){
            if(!payableListRecordMap.containskey(payable.Opportunity__c)){
                payableListRecordMap.put(payable.Opportunity__c, new List<Payable__c>{payable});
            }
               
            else{
                payableListRecordMap.get(payable.Opportunity__c).add(payable);
            }
        }
        
        //Declare List to Update Opportunity
        list<Opportunity> lstUpdateOpportunity = new list<Opportunity>();
        Opportunity objOpportunity;
        calculateRollUpForOppertunity(payableListRecordMap,lstUpdateOpportunity);
        
        //Commit Changes To DataBase
        system.savepoint savePointInstance = Database.setSavepoint();
    
        try{           
            Database.update(lstUpdateOpportunity);
        }
        catch(exception e){
            Database.rollback(savePointInstance);
        }
    }//End CalculateTotalCommissionsPayable
    
    /*Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission
    When Payable Amount is updated*/
    public  void CalculateTotalPayableOnUpdate(list<Payable__c> pOldPayableList, 
                                             list<Payable__c> pPayableList){

        for(Payable__c Payable: pOldPayableList){
            opportunityIds.add(Payable.Opportunity__c);
            opportunityIds.remove(null);
        }
        
        // To iterate over Opportunity Ids
        for(Id opportunityId:opportunityIds){
            opportunityMap.put(opportunityId,resetOppRollUp(opportunityId));
        }
        
        if(!opportunityMap.isEmpty() && opportunityMap <> null){
            //Query Payable using Opportunity Id
            lstpayableAll = this.selectPayableQuery(opportunityIds);          
        }
        
        //iterate over Payable records      
        for(Payable__c payable : lstpayableAll){
            if(!payableListRecordMap.containskey(payable.Opportunity__c)){
                payableListRecordMap.put(payable.Opportunity__c, new List<Payable__c>{payable});
            }
               
            else{
                payableListRecordMap.get(payable.Opportunity__c).add(payable);
            }
        }

        //Declare List to Update Opportunity
        list<Opportunity> lstUpdateOpportunity = new list<Opportunity>();
        Opportunity objOpportunity;
        calculateRollUpForOppertunity(payableListRecordMap,lstUpdateOpportunity);


        //Commit Changes To DataBase
        system.savepoint savePointInstance = Database.setSavepoint();
    
        try{                        
            Database.update(lstUpdateOpportunity);
        }
        catch(exception e){
            Database.rollback(savePointInstance);
        }
    }//End CalculateTotalPayableOnUpdate
    /*Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission
    When Payable record is Deleted*/
    public  void CalculateTotalPayableOnDelete(list<Payable__c> pOldPayableList, 
                                             list<Payable__c> pPayableList){

        for(Payable__c Payable: pOldPayableList){
            opportunityIds.add(Payable.Opportunity__c);
            opportunityIds.remove(null);
        }
        
        // To iterate over Opportunity Ids
        for(Id opportunityId:opportunityIds){
            opportunityMap.put(opportunityId,resetOppRollUp(opportunityId));
        }
        
        if(!opportunityMap.isEmpty() && opportunityMap <> null){
            //Query Payable using Opportunity Id 
            lstpayableAll = this.selectPayableQuery(opportunityIds);           
        }
        
        //iterate over Opportunity record to add Campaign Id and Opportunity record          
        for(Payable__c payable : lstpayableAll){
            if(!payableListRecordMap.containskey(payable.Opportunity__c)){
                payableListRecordMap.put(payable.Opportunity__c, new List<Payable__c>{payable});
            }               
            else{
                payableListRecordMap.get(payable.Opportunity__c).add(payable);
            }
        }
        //Declare List to Update Opportunity
        list<Opportunity> lstUpdateOpportunity = new list<Opportunity>();
        Opportunity objOpportunity;      
        //Check if No Opportunity is Asscoiated with Payable Record then assign zero values
        if(lstpayableAll.size() <=0 ){
            for(Id opportunityId : opportunityIds){
                objOpportunity = resetOppRollUp(opportunityId);
                
                //Check if Campaign Id in Null
                if(objOpportunity.Id <> null)
                    lstUpdateOpportunity.add(objOpportunity);
                    //update objCampaign;
            }            
            system.savepoint savePointInstance = Database.setSavepoint();
        
            try{
                Database.update(lstUpdateOpportunity);
            }
            catch(exception e){
                Database.rollback(savePointInstance);
            }
        }       
         calculateRollUpForOppertunity(payableListRecordMap,lstUpdateOpportunity);        
        //Commit Changes To DataBase
        system.savepoint savePointInstance = Database.setSavepoint();
    
        try{
            //Database.update(opportunityMap.values());
            Database.update(lstUpdateOpportunity);
        }
        catch(exception e){
            Database.rollback(savePointInstance);
        }
    }//End CalculateTotalPayableOnDelete*/
    
    
    public void calculateRollUpForOppertunity(Map<Id, list<Payable__c>> payableListRecordMap,List<Opportunity> lstUpdateOpportunity)
    {
        
           for(Id opportunityId : payableListRecordMap.Keyset()){
            
            Opportunity objOpportunity = new Opportunity(Id = opportunityId);
            Decimal TotalCommissionsPayable = 0.0;
            Decimal TotalPayables = 0.0;
            Decimal TotalOriginationFeesPayable = 0.0;
            
            //Changes for External ISO and Internal ISO
            Decimal TotalCommissionsPayableInternal = 0.0;
            Decimal TotalOriginationFeesPayableInternal = 0.0;
            Decimal TotalPayablesInternal = 0.0;
            Decimal TotalCommissionsPayableExternal = 0.0;
            Decimal TotalOriginationFeesPayableExternal = 0.0;
            Decimal TotalPayablesExternal = 0.0;
            
            for(Payable__c payable : payableListRecordMap.get(opportunityId)){
                if(payable.Amount_Due__c != null && payable.Type__c == 'Commission') {
                    TotalCommissionsPayable += payable.Amount_Due__c;
                    
                    //For Internal ISO
                    if(payable.Payee_Type__c == 'Internal')
                       TotalCommissionsPayableInternal += payable.Amount_Due__c;
                   
                    //For External ISO
                    if(payable.Payee_Type__c == 'External')
                       TotalCommissionsPayableExternal += payable.Amount_Due__c;
                   
                    
                }
                
                if(payable.Amount_Due__c != null && payable.Type__c == 'Origination Fee') {
                    TotalOriginationFeesPayable += payable.Amount_Due__c;
                    
                        //For Internal ISO
                        if(payable.Payee_Type__c == 'Internal')
                           TotalOriginationFeesPayableInternal += payable.Amount_Due__c;
                        
                        
                        //For External ISO
                        if(payable.Payee_Type__c == 'External')
                            TotalOriginationFeesPayableExternal += payable.Amount_Due__c;
                        
                }
                
                if(payable.Amount_Due__c != null ) {
                    TotalPayables += payable.Amount_Due__c;
                    
                   //For Internal ISO
                        if(payable.Payee_Type__c == 'Internal')
                           TotalPayablesInternal += payable.Amount_Due__c;                        
                        
                        //For External ISO
                        if(payable.Payee_Type__c == 'External')
                           TotalPayablesExternal += payable.Amount_Due__c;                        
                }
            }
            
            //Assign Values of variables
            objOpportunity.Total_Commissions_Payable__c = TotalCommissionsPayable;
            objOpportunity.Total_Payables__c = TotalPayables;
            objOpportunity.Total_Origination_Fees_Payable__c = TotalOriginationFeesPayable;
           
            objOpportunity.Commissions_Payable_Internal__c = TotalCommissionsPayableInternal;
            objOpportunity.Origination_Fees_Payable_Internal__c = TotalOriginationFeesPayableInternal;
            objOpportunity.Total_Payables_Internal__c = TotalPayablesInternal;
            
            objOpportunity.Commissions_Payable_External__c = TotalCommissionsPayableExternal;
            objOpportunity.Origination_Fees_Payable_External__c = TotalOriginationFeesPayableExternal;
            objOpportunity.Total_Payables_External__c = TotalPayablesExternal;
            
                        
            if(objOpportunity.Id != null)
                lstUpdateOpportunity.add(objOpportunity);           
        }               
       
    }    
    public Opportunity resetOppRollUp(Id opportunityId)
    {
        return new Opportunity(Id=opportunityId,                                         
                                          Total_Payables__c=0,
                                          Total_Commissions_Payable__c = 0,
                                          Total_Origination_Fees_Payable__c = 0,
                                          Commissions_Payable_Internal__c = 0,
                                          Origination_Fees_Payable_Internal__c = 0,
                                          Total_Payables_Internal__c = 0,
                                          Commissions_Payable_External__c = 0,
                                          Origination_Fees_Payable_External__c = 0,
                                          Total_Payables_External__c = 0);
      
    }   
    public list<Payable__c> selectPayableQuery(set<Id> opportunityIds)
    {
            list<Payable__c> payList = [select id,
                                        Amount_Due__c,
                                        Opportunity__c,
                                        Payee_Type__c,
                                        Account__c,
                                        Account__r.type,
                                        Type__c 
                                     From  Payable__c
                                     where Opportunity__c in :opportunityIds];
            return payList;
    }
}