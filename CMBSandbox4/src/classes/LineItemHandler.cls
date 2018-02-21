/* Description - Handler for LineItemTrigger
 * 
 *  Created By - Sneha P.
 * 
 *  Date - 13/01/2014
 *
 */
public with sharing class LineItemHandler {
    
    // Function called on before insert of Line Item 
    public void onBeforeInsert(list<Line_Item__c> lineItemList){
        updateHarvestProject(lineItemList,null);        
    }
    
    public void onBeforeUpdate(list<Line_Item__c> lineItemList, map<Id,Line_Item__c> oldLineItemMap){
        updateHarvestProject(lineItemList, oldLineItemMap);     
    }
    
    public void onAFterInsert(map<Id,Line_Item__c> lineItemMap){
        this.updateCrediteHrs(lineItemMap); 
    }
    /* Function Called on after update of LineItems to update the related TimeEntry with the 
     * CreditHrs from LineItem
     */
    public void onAfterUpdate(map<Id,Line_Item__c> lineItemMap){
        this.updateCrediteHrs(lineItemMap);     
    }
    
    /* Function called on Before Delete of Line Item to update 'Invoiced by CMB' field of  the 
     * related Time Entry record to False
     */
    public void onBeforeDelete(map<Id,Line_Item__c> lineItemMap){
        set<Id> setTimeEntry = new set<Id>(); 
        list<HarvestTimeEntry__c> updateTimeEntryList = new list<HarvestTimeEntry__c>();
        
        for(Line_Item__c lineItem : lineItemMap.values()){
            if(lineItem.Time_Entry__c != null)
                setTimeEntry.add(lineItem.Time_Entry__c);
        }
        
        //Query all the Time Entry records related with Line Item
        for(HarvestTimeEntry__c timeEntry : [Select Invoiced_by_CMB__c,Invoiced_Time_Entry__c,
                                                    Credit_Reason__c
                                             from HarvestTimeEntry__c where Id IN: setTimeEntry or
                                             Invoiced_Time_Entry__c IN: setTimeEntry ]){
            if(timeEntry.Invoiced_by_CMB__c){
                timeEntry.Invoiced_by_CMB__c = false;   
                if(timeEntry.Invoiced_Time_Entry__c != null){
                    timeEntry.Invoiced_Time_Entry__c = null;
                    timeEntry.Credit_Reason__c = null;  
                }
                updateTimeEntryList.add(timeEntry); 
            }                               
        }
        try{
            if(updateTimeEntryList.size() > 0){
                update updateTimeEntryList;
            }
        }catch(Exception e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                system.debug('-------'+e.getDmlMessage(i)); 
                if(lineItemMap.size() > 0 && lineItemMap.containsKey(e.getDmlId(i)))
                    lineItemMap.get(e.getDmlId(i)).addError(e.getDmlMessage(i) );
            }
        }
    }
    
    public void updateHarvestProject(list<Line_Item__c> lineItemList, map<Id,Line_Item__c> oldLineItemMap){
        set<Id> setTimeEntryId = new set<Id>();
        
        for(Line_Item__c lineItem : lineItemList){
            if(oldLineItemMap == null && lineItem.Time_Entry__c != null)
                setTimeEntryId.add(lineItem.Time_Entry__c);
            //if from update and Time Entry is changed
            else if(oldLineItemMap != null && oldLineItemMap.get(lineItem.Id).Time_Entry__c != lineItem.Time_Entry__c &&
                                               lineItem.Time_Entry__c != null)
                setTimeEntryId.add(lineItem.Time_Entry__c);                                
        }
        
        map<Id, HarvestTimeEntry__c> mapTimeEntry ; 
        if(!setTimeEntryId.isEmpty())
            mapTimeEntry = new map<Id, HarvestTimeEntry__c>([Select Id,HarvestProject__c
                                                                                       from HarvestTimeEntry__c 
                                                                                       where Id IN: setTimeEntryId]);
        
        //Populate Project(Harvest) on line item from Time Entry
        for(Line_Item__c lineItem : lineItemList){
            if(lineItem.Time_Entry__c != null && mapTimeEntry != null 
                                              && !mapTimeEntry.isEmpty() &&  mapTimeEntry.containsKey(lineItem.Time_Entry__c)
                                              &&  mapTimeEntry.get(lineItem.Time_Entry__c).HarvestProject__c != null){
                
                lineItem.HarvestProject__c = mapTimeEntry.get(lineItem.Time_Entry__c).HarvestProject__c;
            }   
           // if(lineItem.Time_Entry__c == null)
            //    lineItem.HarvestProject__c = null;
        }                                                                 
    
    }
    
    /* Function to Update the Credit Hrs on Time Entry from Line Items credt Hrs.
     */
    public void updateCrediteHrs(map<Id,Line_Item__c> lineItemMap){
        list<HarvestTimeEntry__c> timeEntryList = new list<HarvestTimeEntry__c>();
        map<Id, decimal> mapTimeEntryHrs = new map<Id, decimal>();
        
        for(Line_Item__c lineItem : lineItemMap.values()){
            if(lineItem.Time_Entry__c != null && lineItem.Credit_Hrs__c != null){
                //Map Stores Time ENtry Id and its Credit hrs from Line Item
                mapTimeEntryHrs.put(lineItem.Time_Entry__c, lineItem.Credit_Hrs__c);
            }
        }   
        
        //Query all the Time Entry records related with Line Item
        for(HarvestTimeEntry__c timeEntry : [Select Id,Credit_Hrs__c
                                             from HarvestTimeEntry__c where Id IN: mapTimeEntryHrs.keySet()]){
            if(!mapTimeEntryHrs.isEmpty() && mapTimeEntryHrs.containsKey(timeEntry.Id)){
                //Assign the Credit hrs from Line Item
                timeEntry.Credit_Hrs__c = mapTimeEntryHrs.get(timeEntry.Id);            
            }
            timeEntryList.add(timeEntry);
        }
        
        try{
            //Update the Time Entry list
            if(timeEntryList.size() > 0){
                update timeEntryList;
            }
        }catch(Exception e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                system.debug('-------'+e.getDmlMessage(i)); 
                if(lineItemMap.size() > 0 && lineItemMap.containsKey(e.getDmlId(i)))
                    lineItemMap.get(e.getDmlId(i)).addError(e.getDmlMessage(i) );
            }
        }   
    }
}