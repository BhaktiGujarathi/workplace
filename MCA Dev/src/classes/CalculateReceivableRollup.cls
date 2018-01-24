/* Class to calculate the Roll-up of Amount of Recivables on Opportunity
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    11/03/2014                              Initial Draft
 * 2.0             Merul Shah                               08/07/2015                              Added Logic for Origination Fee.   
 */ 

public class CalculateReceivableRollup {
    
    //Variable Declaration                                         
    private Set<Id> opportunityIds = new Set<Id>();
    private Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
    private Map<Id, list<Receivable__c>> receivableListRecordMap = new  Map<Id, list<Receivable__c>> ();
    private list<Receivable__c> lstReceivableAll = new list<Receivable__c> ();
            
    /*Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission*/
    public  void CalculateTotalCommissionsReceivable(map<Id,Receivable__c> pOldReceivableMap, 
                                                     list<Receivable__c> pReceivableList,map<Id,Receivable__c> pNewReceivableMap){
        //Variable Declaration                                      
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        
        for(Receivable__c receivable: pReceivableList){
            opportunityIds.add(receivable.Opportunity__c);
            opportunityIds.remove(null);
        }//End For
        
        // To iterate over Opportunity Ids
        for(Id opportunityId:opportunityIds){
            opportunityMap.put(opportunityId,new Opportunity(Id=opportunityId,Total_Commissions_Receivable__c=0,Total_Receivables__c=0));
        }//End For
        
        
        if(!opportunityMap.isEmpty() && opportunityMap <> null){
            //Query Receivable using Opportunity Id 
            lstReceivableAll = [select id,
                                       Amount__c,
                                       Opportunity__c,
                                       Status__c,
                                       Type__c from 
                                Receivable__c where 
                                Opportunity__c in :opportunityIds ];
        }//End If
        
        //iterate over Opportunity record to add Campaign Id and Opportunity record          
        for(Receivable__c receivable : lstReceivableAll){
            if(!receivableListRecordMap.containskey(receivable.Opportunity__c)){
                receivableListRecordMap.put(receivable.Opportunity__c, new List<Receivable__c>{receivable});
            }//End if
               
            else{
                receivableListRecordMap.get(receivable.Opportunity__c).add(receivable);
            }//End Else
        }//End For

        //Declare List to Update Opportunity
        list<Opportunity> lstUpdateOpportunity = new list<Opportunity>();
        Opportunity objOpportunity;

        for(Id opportunityId : receivableListRecordMap.Keyset()){
            
            objOpportunity = new Opportunity(Id = opportunityId);

            Decimal TotalCommissionsReceivable = 0.0;
            Decimal TotalReceivables = 0.0;
            Decimal TotalOriginationFeesReceivables = 0.0;
            
            for(Receivable__c receivable : receivableListRecordMap.get(opportunityId)){
                if(receivable.Status__c != 'Cancelled') {
                    if(receivable.Amount__c != null && receivable.Type__c == 'Commission') {
                        TotalCommissionsReceivable += receivable.Amount__c;
                    }//End If
                
                    if(receivable.Amount__c != null && receivable.Type__c == 'Origination Fee') {
                        TotalOriginationFeesReceivables += receivable.Amount__c;
                    }//End If
                
                    if(receivable.Amount__c != null ) {
                        TotalReceivables += receivable.Amount__c;
                    }//End If
                }
            }//End For

            objOpportunity.Total_Commissions_Receivable__c = TotalCommissionsReceivable;
            objOpportunity.Total_Origination_Fees_Receivable__c = TotalOriginationFeesReceivables;
            objOpportunity.Total_Receivables__c = TotalReceivables;
            
            if(objOpportunity.Id != null)
                lstUpdateOpportunity.add(objOpportunity);
        }//End For      
   
        //Commit Changes To DataBase
        system.savepoint savePointInstance = Database.setSavepoint();
    
        try{
            Database.update(lstUpdateOpportunity);
        }//End try
        catch(exception e){
            Database.rollback(savePointInstance);
        }//End catch
    }//End CalculateTotalCommissionsReceivable
    
    /*Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission
    When Receivable Amount is updated*/
    public  void CalculateTotalReceivableOnUpdate(list<Receivable__c> pOldReceivableList, list<Receivable__c> pReceivableList, 
                                                  map<Id,Receivable__c> pNewReceivableMap,map<Id,Receivable__c> pOldReceivableMap){
        //Variable Declaration                                      
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        
        for(Receivable__c receivable: pOldReceivableList){
            opportunityIds.add(receivable.Opportunity__c);
            opportunityIds.remove(null);
        }//End For
        
        // To iterate over Opportunity Ids
        for(Id opportunityId:opportunityIds){
            opportunityMap.put(opportunityId,new Opportunity(Id=opportunityId,Total_Commissions_Receivable__c=0,Total_Receivables__c=0));
        }//End For
        
        if(!opportunityMap.isEmpty() && opportunityMap <> null){
            //Query Receivable using Opportunity Id 
            lstReceivableAll = [select id,
                                       Amount__c,
                                       Opportunity__c,
                                       Status__c,
                                       Type__c from 
                                Receivable__c where 
                                Opportunity__c in: opportunityIds ];
        }//End If

        //iterate over Opportunity record to add Campaign Id and Opportunity record          
        for(Receivable__c receivable : lstReceivableAll){
            if(!receivableListRecordMap.containskey(receivable.Opportunity__c)){
                receivableListRecordMap.put(receivable.Opportunity__c, new List<Receivable__c>{receivable});
            }//End if
               
            else{
                receivableListRecordMap.get(receivable.Opportunity__c).add(receivable);
            }//End Else
        }//End For

        //Declare List to Update Opportunity
        list<Opportunity> lstUpdateOpportunity = new list<Opportunity>();
        Opportunity objOpportunity;

        for(Id opportunityId : receivableListRecordMap.Keyset()){
            
            objOpportunity = new Opportunity(Id = opportunityId);

            Decimal TotalCommissionsReceivable = 0.0;
            Decimal TotalReceivables = 0.0;
            Decimal TotalOriginationFeesReceivables = 0.0;
            for(Receivable__c receivable : receivableListRecordMap.get(opportunityId)){
                if(receivable.Status__c != 'Cancelled') {
                    if(receivable.Amount__c != null && receivable.Type__c == 'Commission') {
                        TotalCommissionsReceivable += receivable.Amount__c;
                    }//End If
                    
                    if(receivable.Amount__c != null && receivable.Type__c == 'Origination Fee') {
                        TotalOriginationFeesReceivables += receivable.Amount__c;
                    }//End If
                    
                    if(receivable.Amount__c != null ) {
                        TotalReceivables += receivable.Amount__c;
                    }//End If
                }
            }//End For
            objOpportunity.Total_Commissions_Receivable__c = TotalCommissionsReceivable;
            objOpportunity.Total_Receivables__c = TotalReceivables;
            objOpportunity.Total_Origination_Fees_Receivable__c = TotalOriginationFeesReceivables;
            if(objOpportunity.Id != null)
                lstUpdateOpportunity.add(objOpportunity);
        }//End For      
   
        //Commit Changes To DataBase
        system.savepoint savePointInstance = Database.setSavepoint();
    
        try{
            Database.update(lstUpdateOpportunity);
        }//End try
        catch(exception e){
            Database.rollback(savePointInstance);
        }//End catch
    }//End CalculateTotalReceivableOnUpdate
    
    /*Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission
    When Receivable record is Deleted*/
    public  void CalculateTotalReceivableOnDelete(list<Receivable__c> pOldReceivableList, list<Receivable__c> pReceivableList,
                                                  map<Id,Receivable__c> pNewReceivableMap,map<Id,Receivable__c> pOldReceivableMap){
        //Variable Declaration                                      
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        
        for(Receivable__c receivable: pOldReceivableList){
            opportunityIds.add(receivable.Opportunity__c);
            opportunityIds.remove(null);
        }//End For
        
        //To iterate over Opportunity Ids
        for(Id opportunityId:opportunityIds){
            opportunityMap.put(opportunityId,new Opportunity(Id=opportunityId,Total_Commissions_Receivable__c=0,Total_Receivables__c=0));
        }//End For
        
        //Checking if opportunityMap is null
        if(!opportunityMap.isEmpty() && opportunityMap <> null){
            //Query Receivable using Opportunity Id 
            lstReceivableAll = [select id,
                                       Amount__c,
                                       Opportunity__c,
                                       Status__c,
                                       Type__c from 
                                Receivable__c where 
                                Opportunity__c in :opportunityIds ];
        }//End If
        
        //iterate over Opportunity record to add Campaign Id and Opportunity record          
        for(Receivable__c receivable : lstReceivableAll){
            if(!receivableListRecordMap.containskey(receivable.Opportunity__c)){
                receivableListRecordMap.put(receivable.Opportunity__c, new List<Receivable__c>{receivable});
            }//End if
               
            else{
                receivableListRecordMap.get(receivable.Opportunity__c).add(receivable);
            }//End Else
        }//End For

        //Declare List to Update Opportunity
        list<Opportunity> lstUpdateOpportunity = new list<Opportunity>();
        Opportunity objOpportunity;

        //Check if No Opportunity is Asscoiated with Receivable Record then assign zero values
        if(lstReceivableAll.size() <=0 ){
            for(Id opportunityId : opportunityIds){
                
                objOpportunity = new Opportunity(Id = opportunityId);
                
                objOpportunity.Total_Commissions_Receivable__c = 0.0;
                objOpportunity.Total_Receivables__c = 0.0;
                
                //Check if Campaign Id in Null
                if(objOpportunity.Id <> null)
                    lstUpdateOpportunity.add(objOpportunity);
                    //update objCampaign;
            }//End For
            
            system.savepoint savePointInstance = Database.setSavepoint();
        
            try{
                Database.update(lstUpdateOpportunity);
            }//End try
            catch(exception e){
                Database.rollback(savePointInstance);
            }//End catch
        }//End If       

        for(Id opportunityId : receivableListRecordMap.Keyset()){
            
            objOpportunity = new Opportunity(Id = opportunityId);

            Decimal TotalCommissionsReceivable = 0.0;
            Decimal TotalReceivables = 0.0;
            Decimal TotalOriginationFeesReceivables = 0.0;

            for(Receivable__c receivable : receivableListRecordMap.get(opportunityId)){
                if(receivable.Status__c != 'Cancelled') {
                if(receivable.Amount__c != null && receivable.Type__c == 'Commission') {
                    TotalCommissionsReceivable += receivable.Amount__c;
                }//End If
                
                if(receivable.Amount__c != null && receivable.Type__c == 'Origination Fee') {
                    TotalOriginationFeesReceivables += receivable.Amount__c;
                }//End If
                
                if(receivable.Amount__c != null ) {
                    TotalReceivables += receivable.Amount__c;
                }//End If
                }
            }//End for
            objOpportunity.Total_Commissions_Receivable__c = TotalCommissionsReceivable;
            objOpportunity.Total_Receivables__c = TotalReceivables;
            objOpportunity.Total_Origination_Fees_Receivable__c = TotalOriginationFeesReceivables;
            if(objOpportunity.Id != null)
                lstUpdateOpportunity.add(objOpportunity);
        }//End For      
   
        //Commit Changes To DataBase
        system.savepoint savePointInstance = Database.setSavepoint();
    
        try{
            Database.update(lstUpdateOpportunity);
        }//End try
        catch(exception e){
            Database.rollback(savePointInstance);
        }//End catch
    }//End CalculateTotalReceivableOnDelete
}//End CalculateReceivableRollup