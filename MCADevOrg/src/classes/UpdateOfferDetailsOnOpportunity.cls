/* Class to update funding details of Offer on Opportunity if offer is marked as Chosen
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    17/08/2015                              Initial Draft
 */ 

public class UpdateOfferDetailsOnOpportunity { 
	
	//Variable Declaration                                         
    private Set<Id> opportunityIds = new Set<Id>();
    private Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
    private Map<Id, list<Offer__c>> offerListRecordMap = new  Map<Id, list<Offer__c>> ();
    private list<Offer__c> lstofferDetails = new list<Offer__c> ();
    
    /*Method to update offer details on Insert of Offer with status Chosen*/
    public void updtaeOfferDetailsOnAfterInsert(map<Id,Offer__c> pOldOfferMap, 
                                                 list<Offer__c> pOfferList){
	
		for(Offer__c offer: pOfferList){
	    	opportunityIds.add(offer.Opportunity__c);
	        opportunityIds.remove(null);
	    }//End For	
	    
	    system.debug('****opportunityIds****'+opportunityIds);
	    
	    //To iterate over Opportunity Ids
        for(Id opportunityId:opportunityIds){
            opportunityMap.put(opportunityId,new Opportunity(Id=opportunityId));
        }//End For
        
        system.debug('****opportunityMap****'+opportunityMap);
        
        if(!opportunityMap.isEmpty() && opportunityMap <> null){
            //Query offer using Opportunity Id
            lstofferDetails = [select id,
                                      Deal_Type__c
                              from Offer__c where 
                              Opportunity__c in :opportunityIds  ];
                              
            system.debug('*****lstofferDetails****'+lstofferDetails);
        }//End If
        
        //iterate over Offer records         
        for(Offer__c offer : lstofferDetails){
        	
            if(!offerListRecordMap.containskey(offer.Opportunity__c)){
                offerListRecordMap.put(offer.Opportunity__c, new List<Offer__c>{offer});
            }//End if
               
            else{
                offerListRecordMap.get(offer.Opportunity__c).add(offer);
            }//End Else
            
        }//End For
        
        system.debug('*****offerListRecordMap****'+offerListRecordMap);
        
        //Declare List to Update Opportunity
        list<Opportunity> lstUpdateOpportunity = new list<Opportunity>();
        Opportunity objOpportunity;
        
        for(Id opportunityId : offerListRecordMap.Keyset()){
            
            objOpportunity = new Opportunity(Id = opportunityId);

            for(Offer__c offer : offerListRecordMap.get(opportunityId)){
                objOpportunity.Deal_Type__c = offer.Deal_Type__c;
            }//End for
            
            if(objOpportunity.Id != null){
                lstUpdateOpportunity.add(objOpportunity);    
            }
	     }//End for     
	     
	     system.debug('*****lstUpdateOpportunity****'+lstUpdateOpportunity);
	     
	     //Commit Changes To DataBase
	     system.savepoint savePointInstance = Database.setSavepoint();
	     /*
	        try{
	            //Database.update(opportunityMap.values());
	            Database.update(lstUpdateOpportunity);
	        	}//End try
	        catch(exception e){
	            Database.rollback(savePointInstance);
	        }//End catch  
	      */      
    }//End updtaeOfferDetailsOnAfterInsert
    
    /*Method to update offer details on Update of Offer with status Chosen*/
    public void updtaeOfferDetailsOnAfterUpdate(map<Id,Offer__c> pOldOfferMap, 
                                                 list<Offer__c> pOfferList){
		
     
                                             	
    }//End updtaeOfferDetailsOnAfterUpdate
    
    /*Method to remove offer details on delete of Offer with status Chosen*/
    public void updtaeOfferDetailsOnAfterDelete(map<Id,Offer__c> pOldOfferMap, 
                                                 list<Offer__c> pOfferList){
		
     
                                             	
    }//End updtaeOfferDetailsOnAfterDelete
}