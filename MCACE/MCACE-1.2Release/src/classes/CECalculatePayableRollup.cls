public with sharing class CECalculatePayableRollup{
    /*
    //Variable Declaration                                         
    public Set<Id> opportunityIds = new Set<Id>();
    public Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
    public Map<Id, list<McaApp__Payable__c>> payableListRecordMap = new  Map<Id, list<McaApp__Payable__c>> ();
    public list<McaApp__Payable__c> lstpayablewithCommission = new list<McaApp__Payable__c> ();
    public list<McaApp__Payable__c> lstpayableAll = new list<McaApp__Payable__c> ();
        
    //Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission
    public  void CalculateTotalCommissionsPayable(map<Id,McaApp__Payable__c> pOldPayableMap, 
                                             list<McaApp__Payable__c> pPayableList)
    {
       
        
        for(McaApp__Payable__c Payable: pPayableList){
            opportunityIds.add(Payable.McaApp__Opportunity__c);
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
        for(McaApp__Payable__c payable : lstpayableAll){
            if(!payableListRecordMap.containskey(payable.McaApp__Opportunity__c)){
                payableListRecordMap.put(payable.McaApp__Opportunity__c, new List<McaApp__Payable__c>{payable});
            }
               
            else{
                payableListRecordMap.get(payable.McaApp__Opportunity__c).add(payable);
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
    
    //Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission When Payable Amount is updated
    public  void CalculateTotalPayableOnUpdate(list<McaApp__Payable__c> pOldPayableList, 
                                             list<McaApp__Payable__c> pPayableList){

        for(McaApp__Payable__c Payable: pOldPayableList){
            opportunityIds.add(Payable.McaApp__Opportunity__c);
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
        for(McaApp__Payable__c payable : lstpayableAll){
            if(!payableListRecordMap.containskey(payable.McaApp__Opportunity__c)){
                payableListRecordMap.put(payable.McaApp__Opportunity__c, new List<McaApp__Payable__c>{payable});
            }
               
            else{
                payableListRecordMap.get(payable.McaApp__Opportunity__c).add(payable);
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
//Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission When Payable record is Deleted
    public  void CalculateTotalPayableOnDelete(list<McaApp__Payable__c> pOldPayableList, 
                                             list<McaApp__Payable__c> pPayableList){

        for(McaApp__Payable__c Payable: pOldPayableList){
            opportunityIds.add(Payable.McaApp__Opportunity__c);
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
        for(McaApp__Payable__c payable : lstpayableAll){
            if(!payableListRecordMap.containskey(payable.McaApp__Opportunity__c)){
                payableListRecordMap.put(payable.McaApp__Opportunity__c, new List<McaApp__Payable__c>{payable});
            }               
            else{
                payableListRecordMap.get(payable.McaApp__Opportunity__c).add(payable);
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
    }//End CalculateTotalPayableOnDelete    
    
    public void calculateRollUpForOppertunity(Map<Id, list<McaApp__Payable__c>> payableListRecordMap,List<Opportunity> lstUpdateOpportunity)
    {
        
           for(Id opportunityId : payableListRecordMap.Keyset()){
            
            Opportunity objOpportunity = new Opportunity(Id = opportunityId);    
            
            //Changes for External ISO and Internal ISO           
            Decimal TotalCommissionsPayableExternal = 0.0;
            Decimal TotalOriginationFeesPayableExternal = 0.0;
            
            
            for(McaApp__Payable__c payable : payableListRecordMap.get(opportunityId)){
                if(payable.McaApp__Amount_Due__c != null && payable.McaApp__Type__c == 'Commission') 
                {
                    //TotalCommissionsPayable += payable.McaApp__Amount_Due__c;
                   
                    //For External ISO
                    if(payable.McaApp__Payee_Type__c == 'External')
                       TotalCommissionsPayableExternal += payable.McaApp__Amount_Due__c;
                   
                    
                }
                
                if(payable.McaApp__Amount_Due__c != null && payable.McaApp__Type__c == 'Origination Fee') {
                    //TotalOriginationFeesPayable += payable.McaApp__Amount_Due__c;
                    
                        //For External ISO
                        if(payable.McaApp__Payee_Type__c == 'External')
                            TotalOriginationFeesPayableExternal += payable.McaApp__Amount_Due__c;
                        
                }               
               
            }
            
            //Assign Values of variables     
            
            objOpportunity.MCACE__Commissions_Payable_External__c = TotalCommissionsPayableExternal;
            objOpportunity.MCACE__Origination_Fees_Payable_External__c = TotalOriginationFeesPayableExternal;
                        
            if(objOpportunity.Id != null)
                lstUpdateOpportunity.add(objOpportunity);           
        }               
       
    }    
    public Opportunity resetOppRollUp(Id opportunityId)
    {
        return new Opportunity(Id=opportunityId,
                                          MCACE__Commissions_Payable_External__c = 0,
                                          MCACE__Origination_Fees_Payable_External__c = 0);
      
    }   
    public list<McaApp__Payable__c> selectPayableQuery(set<Id> opportunityIds)
    {
            list<McaApp__Payable__c> payList = [select id,
                                        McaApp__Amount_Due__c,
                                        McaApp__Opportunity__c,
                                        McaApp__Payee_Type__c,
                                        McaApp__Account__c,
                                        McaApp__Account__r.type,
                                        McaApp__Type__c 
                                     From  McaApp__Payable__c
                                     where McaApp__Opportunity__c in :opportunityIds];
            return payList;
    }*/
}