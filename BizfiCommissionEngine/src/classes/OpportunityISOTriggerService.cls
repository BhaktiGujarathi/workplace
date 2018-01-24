/*
Created by:Srikanth Pinnamaneni
*/

public without sharing class OpportunityISOTriggerService {
    
    public Static Map<String,String> salesRepAndIsoMap
    {
        get {
            return new Map<String, String>
            {
                'ISO_1_Lead_Source_Sales_Rep__c' => 'ISO_1_Lead_Source__c',
                'ISO_2_Sales_Rep__c'  => 'ISO_2__c',
                'ISO_3_Sales_Rep__c'  => 'ISO_3__c',
                'ISO_4_Sales_Rep__c'  => 'ISO_4__c'
                /*
                'ISO_5_Sales_Rep__c'  => 'ISO_5__c',
                'ISO_6_Sales_Rep__c'  => 'ISO_6__c',
                'ISO_7_Sales_Rep__c'  => 'ISO_7__c',
                'ISO_8_Sales_Rep__c'  => 'ISO_8__c',
                'ISO_9_Sales_Rep__c'  => 'ISO_9__c',
                'ISO_10_Sales_Rep__c' => 'ISO_10__c'
                */
            };
        }
        set;
    }
    
    
    public Static Map<String,String> mapISOApiAndLabel
    {
        get {
            return new Map<String, String>
            {
                'ISO_1_Lead_Source__c' => 'ISO #1 / Lead Source',
                'ISO_2__c'  => 'ISO #2',
                'ISO_3__c'  => 'ISO #3',
                'ISO_4__c'  => 'ISO #4'
                /*
                'ISO_5__c'  => 'ISO #5',
                'ISO_6__c'  => 'ISO #6',
                'ISO_7__c'  => 'ISO #7',
                'ISO_8__c'  => 'ISO #8',
                'ISO_9__c'  => 'ISO #9',
                'ISO_10__c' => 'ISO #10'                
                */
            };
        }
        set;
    }
    
    //Method to check account type is ISO or Vendor
    public static List < opportunity > isAccISOorVendor(List<Opportunity> lstNewOpp)
    {
                list<RecordType> recordTypeList = new list<RecordType>();
                Map<ID,Opportunity> mapAccIDOpp = new Map<ID,Opportunity>();
                   
                
                for(Opportunity oppObj : lstNewOpp)
                {
                    for(String mapValue : salesRepAndIsoMap.values())
                    { 
                       if(oppObj.get(mapValue) != null)
                       {
                           mapAccIDOpp.put((ID)oppObj.get(mapValue),oppObj);
                       }                  
                    }
                  
                }
                
               Map<Id,Account> accListOfISOVendorType=new Map<Id,Account>([select id from account where id IN :mapAccIDOpp.keySet() AND (recordtype.name= 'ISO')]);
               system.debug('####### '+accListOfISOVendorType); 
               for(Opportunity oppObj : lstNewOpp)
               {
                    for(String mapValue : salesRepAndIsoMap.values())
                    { 
                       if(oppObj.get(mapValue) != null )
                       {
                         system.debug('####### '+ accListOfISOVendorType.containsKey((ID)oppObj.get(mapValue))); 

                         if(! accListOfISOVendorType.containsKey((ID)oppObj.get(mapValue)   ))
                        // oppObj.addError(accListOfISOVendorType+ ' should be of ISO Type');
                         oppObj.addError(mapISOApiAndLabel.get(mapValue)+ ' should be of ISO Type');
                        
                       } 
                      
                    }
                }   
                
             return lstNewOpp;   
           
    }  
    
    /*  19.validations on Opportunity for When an ISO is populated ,
    then there must be another ISO with its Parent Account for the popuplated ISO Account */
    
    public static List < opportunity > isISOParentPresent(List < opportunity > newopportunities) 
    {
        //Variable declaration
        Set<String> setOfOppISO = new Set<String>();
        List <Account> accList = new List <Account>();
        set<Id> isoAccIdSet = new set<Id>();
        Map < string, string > idsMap = new Map < string, string >();
        Map<string,Account> AccountsMap = new Map<string, Account>();
        setOfOppISO.addAll(salesRepAndIsoMap.values());
        
        for(opportunity oppObj : newopportunities)
        {
            for(String value: salesRepAndIsoMap.values())
            {
                if((oppObj.get(value)) != null   )
                isoAccIdSet.add((id)(oppObj.get(value)));
            }
        }
        
        if(isoAccIdSet.size() > 0)
        {
            accList = [select id, name, ParentId 
                       from Account 
                       where Id IN : isoAccIdSet AND 
                            (RecordType.Name = 'ISO' /*OR RecordType.Name = 'Vendor'*/)];
        }
        
        for (Account act: accList)
        {
            idsMap.put(Act.id, act.parentId);
            AccountsMap.put(act.id,act);
        }
        
        for (opportunity newOppty: newopportunities)
        {
        
            for(String primeISO : setOfOppISO)
            {
                Set<String> setIdWithoutPrime = new Set<String>();
                setIdWithoutPrime = setOfOppISO.Clone();
                setIdWithoutPrime.remove(primeISO);
                if(newOppty.get(primeISO) != null && idsMap.get((String)newOppty.get(primeISO)) != null )
                {
                    Boolean isParentIsoPresent = false;
                    for(String idWithoutPrime : setIdWithoutPrime)
                    {
                        isParentIsoPresent = isParentIsoPresent || (newOppty.get(idWithoutPrime) != Null && (newOppty.get(idWithoutPrime) == idsMap.get((String)newOppty.get(primeISO))));
                    }
                    
                    if(!isParentIsoPresent)
                    {
                        newOppty.addError('Please add the Parent Account of ' +AccountsMap.get((String)newOppty.get(primeISO)).name);
                       
                    }
                }
            }
            
        }
        return newopportunities;
        
    }
    
    
    
    public static List < opportunity > isISODuplicate(List < opportunity > newopportunities)
    {
        Set<String> setOfOppISO = new Set<String>();
        Set<String> setIdWithoutPrime = new Set<String>();
        setOfOppISO.addAll(salesRepAndIsoMap.values());
        setIdWithoutPrime = setOfOppISO.Clone();
        
        for (opportunity newOppty: newopportunities)
        {
            for(String primeISO : setOfOppISO)
            {
                setIdWithoutPrime = setOfOppISO.Clone();
                setIdWithoutPrime.remove(primeISO);
                
                if(newOppty.get(primeISO) != null )
                {
                    Boolean isDuplicate = false;
                    for(String idWithoutPrime : setIdWithoutPrime)
                    {
                        isDuplicate = isDuplicate || (newOppty.get(idWithoutPrime) != Null && newOppty.get(primeISO) != Null && ((String)newOppty.get(idWithoutPrime) == (String)newOppty.get(primeISO)));
                    }
                    
                    if(isDuplicate)
                    {
                        newOppty.addError('You cannot add the same ISO multiple times. Please remove duplicate instances.');
                       
                    }
                }
            }
        }
        
        return newopportunities;
        
    }
    
    
    /* 16. Workflows that will populate ISO values on oppty */
    public static list <opportunity> populateISOBasedOnSalesRep(list < opportunity > newOptys)
    {
        set<Id> isoIdSet = new set<Id>();
        list<contact> contactList = new list<contact>();
        Map<Id,ID> conIdAccIdMap = new map<Id,Id>();
        
        for(opportunity oppObj : newOptys)
        {
            for(String key : salesRepAndIsoMap.keySet())
            {
                if((oppObj.get(key)) != null  )
                isoIdSet.add((id)(oppObj.get(key)));
            }
        }
        
        if(isoIdSet.size() > 0)
        {
            contactList = [select ID,name,Account.Id From Contact where Id IN : isoIdSet];
        }
        
        if(contactList.size() >0 )
        {
            for(Contact conObj : contactList)
            {
                conIdAccIdMap.put(conObj.Id,conObj.Account.Id);
            }
        }
        
        for (opportunity newOpty: newOptys)
        {
            for(String key: salesRepAndIsoMap.keySet())
            {
                if(((id)newOpty.get(key)) != null)
                {
                    newOpty.put(salesRepAndIsoMap.get(key),conIdAccIdMap.get((id)newOpty.get(key)));                   
                }
            }
        }
        
        return newOptys;
        
        
    }
    
}