/* Class to calculate the Roll-up of Amount of Payables on Opportunity
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    11/04/2014                              Initial Draft
 */ 

public with sharing class CalculatePayableRollup {
    
     //Variable Declaration                                         
    private Set<Id> opportunityIds = new Set<Id>();
    private Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
    private Map<Id, list<Payable__c>> payableListRecordMap = new  Map<Id, list<Payable__c>> ();
    private list<Payable__c> lstpayablewithCommission = new list<Payable__c> ();
    private list<Payable__c> lstpayableAll = new list<Payable__c> ();
        
    /*Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission*/
    public  void CalculateTotalCommissionsPayable(map<Id,Payable__c> pOldPayableMap, 
                                             list<Payable__c> pPayableList){
       
        
        for(Payable__c Payable: pPayableList){
            opportunityIds.add(Payable.Opportunity__c);
            opportunityIds.remove(null);
        }//End For
        
        // To iterate over Opportunity Ids
        for(Id opportunityId:opportunityIds){
            opportunityMap.put(opportunityId,new Opportunity(Id=opportunityId,Total_Commissions_Payable__c=0,Total_Payables__c=0));
        }//End For
        
        if(!opportunityMap.isEmpty() && opportunityMap <> null){
            //Query Payable using Opportunity Id
            lstpayableAll = [select id,
                                    Amount_Due__c,
                                    Opportunity__c,
                                    Type__c from 
                             Payable__c where 
                             Opportunity__c in :opportunityIds  ];
        }//End If
        
        //iterate over Opportunity record to add Campaign Id and Opportunity record          
		for(Payable__c payable : lstpayableAll){
        	if(!payableListRecordMap.containskey(payable.Opportunity__c)){
        		payableListRecordMap.put(payable.Opportunity__c, new List<Payable__c>{payable});
        	}//End if
               
            else{
            	payableListRecordMap.get(payable.Opportunity__c).add(payable);
            }//End Else
        }//End For
        
        //Declare List to Update Opportunity
		list<Opportunity> lstUpdateOpportunity = new list<Opportunity>();
		Opportunity objOpportunity;

        for(Id opportunityId : payableListRecordMap.Keyset()){
        	
        	objOpportunity = new Opportunity(Id = opportunityId);

        	Decimal TotalCommissionsPayable = 0.0;
        	Decimal TotalPayables = 0.0;
        	
        	for(Payable__c payable : payableListRecordMap.get(opportunityId)){
        		if(payable.Amount_Due__c != null && payable.Type__c == 'Commission') {
        			TotalCommissionsPayable += payable.Amount_Due__c;
        		}//End If
        		if(payable.Amount_Due__c != null ) {
        			TotalPayables += payable.Amount_Due__c;
        		}//End If
        	}//End for
        	
        	//Assign Values of variables
        	objOpportunity.Total_Commissions_Payable__c = TotalCommissionsPayable;
        	objOpportunity.Total_Payables__c = TotalPayables;
        	
        	if(objOpportunity.Id != null)
        		lstUpdateOpportunity.add(objOpportunity);        	
        }//End for		
   
        //Commit Changes To DataBase
        system.savepoint savePointInstance = Database.setSavepoint();
    
        try{
            //Database.update(opportunityMap.values());
            Database.update(lstUpdateOpportunity);
        }//End try
        catch(exception e){
            Database.rollback(savePointInstance);
        }//End catch
    }//End CalculateTotalCommissionsPayable
    
    /*Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission
    When Payable Amount is updated*/
    public  void CalculateTotalPayableOnUpdate(list<Payable__c> pOldPayableList, 
                                             list<Payable__c> pPayableList){

        for(Payable__c Payable: pOldPayableList){
            opportunityIds.add(Payable.Opportunity__c);
            opportunityIds.remove(null);
        }//End For
        
        // To iterate over Opportunity Ids
        for(Id opportunityId:opportunityIds){
            opportunityMap.put(opportunityId,new Opportunity(Id=opportunityId,Total_Commissions_Payable__c=0,Total_Payables__c=0));
        }//End For
        
        if(!opportunityMap.isEmpty() && opportunityMap <> null){
            //Query Payable using Opportunity Id
            lstpayableAll = [select id,
                                    Amount_Due__c,
                                    Opportunity__c,
                                    Type__c from 
                             Payable__c where 
                             Opportunity__c in :opportunityIds  ];
        }//End If
        
        //iterate over Payable records      
		for(Payable__c payable : lstpayableAll){
        	if(!payableListRecordMap.containskey(payable.Opportunity__c)){
        		payableListRecordMap.put(payable.Opportunity__c, new List<Payable__c>{payable});
        	}//End if
               
            else{
            	payableListRecordMap.get(payable.Opportunity__c).add(payable);
            }//End Else
        }//End For

        //Declare List to Update Opportunity
		list<Opportunity> lstUpdateOpportunity = new list<Opportunity>();
		Opportunity objOpportunity;

        for(Id opportunityId : payableListRecordMap.Keyset()){
        	
        	objOpportunity = new Opportunity(Id = opportunityId);

        	Decimal TotalCommissionsPayable = 0.0;
        	Decimal TotalPayables = 0.0;
        	
        	for(Payable__c payable : payableListRecordMap.get(opportunityId)){
        		if(payable.Amount_Due__c != null && payable.Type__c == 'Commission') {
        			TotalCommissionsPayable += payable.Amount_Due__c;
        		}//End if
        		if (payable.Amount_Due__c != null ) {
        			TotalPayables += payable.Amount_Due__c;
        		}//End If
        	}//End for
        	
        	//Assign Values of variables
        	objOpportunity.Total_Commissions_Payable__c = TotalCommissionsPayable;
        	objOpportunity.Total_Payables__c = TotalPayables;
        	
        	if(objOpportunity.Id != null)
        		lstUpdateOpportunity.add(objOpportunity);        	
        }		

        //Commit Changes To DataBase
        system.savepoint savePointInstance = Database.setSavepoint();
    
        try{
            //Database.update(opportunityMap.values());
            Database.update(lstUpdateOpportunity);
        }//End try
        catch(exception e){
            Database.rollback(savePointInstance);
        }//End catch
    }//End CalculateTotalPayableOnUpdate
    
    /*Method to calculate Roll-up of Amount of Recivables when Type is Commission and other Than Commission
    When Payable record is Deleted*/
    public  void CalculateTotalPayableOnDelete(list<Payable__c> pOldPayableList, 
                                             list<Payable__c> pPayableList){

        for(Payable__c Payable: pOldPayableList){
            opportunityIds.add(Payable.Opportunity__c);
            opportunityIds.remove(null);
        }//End For
        
        // To iterate over Opportunity Ids
        for(Id opportunityId:opportunityIds){
            opportunityMap.put(opportunityId,new Opportunity(Id=opportunityId,Total_Commissions_Payable__c=0,Total_Payables__c=0));
        }//End For
        
        if(!opportunityMap.isEmpty() && opportunityMap <> null){
            //Query Payable using Opportunity Id 
            lstpayableAll = [select id,
                                    Amount_Due__c,
                                    Opportunity__c,
                                    Type__c from 
                             Payable__c where 
                             Opportunity__c in :opportunityIds  ];
        }//End If
        
        //iterate over Opportunity record to add Campaign Id and Opportunity record          
		for(Payable__c payable : lstpayableAll){
        	if(!payableListRecordMap.containskey(payable.Opportunity__c)){
        		payableListRecordMap.put(payable.Opportunity__c, new List<Payable__c>{payable});
        	}//End if
               
            else{
            	payableListRecordMap.get(payable.Opportunity__c).add(payable);
            }//End Else
        }//End For

        //Declare List to Update Opportunity
		list<Opportunity> lstUpdateOpportunity = new list<Opportunity>();
		Opportunity objOpportunity;

        //Check if No Opportunity is Asscoiated with Payable Record then assign zero values
        if(lstpayableAll.size() <=0 ){
			for(Id opportunityId : opportunityIds){
				
				objOpportunity = new Opportunity(Id = opportunityId);
				
				objOpportunity.Total_Commissions_Payable__c = 0.0;
				objOpportunity.Total_Payables__c = 0.0;
	        	
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
		
        for(Id opportunityId : payableListRecordMap.Keyset()){
        	
        	objOpportunity = new Opportunity(Id = opportunityId);

        	Decimal TotalCommissionsPayable = 0.0;
        	Decimal TotalPayables = 0.0;
        	for(Payable__c payable : payableListRecordMap.get(opportunityId)){
        		if(payable.Amount_Due__c != null && payable.Type__c == 'Commission') {
        			TotalCommissionsPayable += payable.Amount_Due__c;
        		}//End if
        		if(payable.Amount_Due__c != null ) {
        			TotalPayables += payable.Amount_Due__c;
        		}//End if
        	}//End for
        	
        	//Assign Values of variables
        	objOpportunity.Total_Commissions_Payable__c = TotalCommissionsPayable;
        	objOpportunity.Total_Payables__c = TotalPayables;
        	
        	if(objOpportunity.Id != null)
        		lstUpdateOpportunity.add(objOpportunity);        	
        }//End for	
        	
        //Commit Changes To DataBase
        system.savepoint savePointInstance = Database.setSavepoint();
    
        try{
            //Database.update(opportunityMap.values());
            Database.update(lstUpdateOpportunity);
        }//End try
        catch(exception e){
            Database.rollback(savePointInstance);
        }//End catch
    }//End CalculateTotalPayableOnDelete*/
}//End CalculatePayableRollup