/*
Created by:Srikanth Pinnamaneni
*/

public class LeadISOTriggerService{
    
    public Static Map<String,String> salesRepAndIsoMap
    {
        get {
            return new Map<String, String>
            {
                'ISO_1_salesRep__c' => 'ISO_1__c',
                'ISO_2_Sales_Rep__c' => 'ISO_2__c',
                'ISO_3_Sales_Rep__c' => 'ISO_3__c',
                'ISO_4_Sales_Rep__c' => 'ISO_4__c'
            };
        }
        set;
    }
    
    public Static Map<String,String> mapISOApiAndLabel
    {
        get {
            return new Map<String, String>
            {
                'ISO_1__c' => 'ISO #1 / Lead Source',
                'ISO_2__c' => 'ISO #2',
                'ISO_3__c' => 'ISO #3',
                'ISO_4__c' => 'ISO #4'
            };
        }
        set;
    }
    
     //Method to check account type is ISO or Vendor
   public static List <Lead> isAccISOorVendor(List<Lead> lstNewLead)
    {
                list<RecordType> recordTypeList = new list<RecordType>();
                Map<ID,Lead> mapAccIDLead = new Map<ID,Lead>();
                   
                
                for(Lead leadObj : lstNewLead)
                {
                    for(String mapValue : salesRepAndIsoMap.values())
                    { 
                       if(leadObj.get(mapValue) != null )
                       {
                           mapAccIDLead.put((ID)leadObj.get(mapValue),leadObj);
                       }                  
                    }
                  
                }
                
               Map<Id,Account> accListOfISOVendorType=new Map<Id,Account>([select id from account where id IN :mapAccIDLead.keySet() AND (recordtype.name= 'ISO' /*OR recordtype.name= 'Vendor'*/ )]);
                
               for(Lead leadObj : lstNewLead)
               {
                    for(String mapValue : salesRepAndIsoMap.values())
                    { 
                       if(leadObj.get(mapValue) != null  )
                       {
                         if(!accListOfISOVendorType.containsKey((ID)leadObj.get(mapValue)))
                         leadObj.addError(mapISOApiAndLabel.get(mapValue)+' should be of ISO ' + /*or Vendor */ + 'Type');
                         //return false;
                       } 
                      
                    }
                }   
                
             return lstNewLead;   
           
    } 
    
    public static List <Lead> isISOParentPresent(List <Lead> newLeads) 
    {
        //Variable declaration
        Set<String> setOfLeadISO = new Set<String>();
        List <Account> accList = new List <Account>();
        set<Id> isoAccIdSet = new set<Id>();
        Map < string, string > idsMap = new Map < string, string >();
        Map<string,Account> AccountsMap = new Map<string, Account>();
        setOfLeadISO.addAll(salesRepAndIsoMap.values());
        
        for(Lead leadObj: newLeads)
        {
            for(String value: salesRepAndIsoMap.values())
            {
                if((id)(leadObj.get(value)) != null)
                isoAccIdSet.add((id)(leadObj.get(value)));
            }
        }
        
        if(isoAccIdSet.size() > 0)
        {
            accList = [select id, name, ParentId 
                       from Account 
                       where Id IN : isoAccIdSet AND 
                            (RecordType.Name = 'ISO' /* OR RecordType.Name = 'Vendor' */ )];
        }
        
        for (Account act: accList)
        {
            idsMap.put(Act.id, act.parentId);
            AccountsMap.put(act.id,act);
        }
        
        for (Lead newLead: newLeads)
        {
        
            for(String primeISO : setOfLeadISO)
            {
                Set<String> setIdWithoutPrime = new Set<String>();
                setIdWithoutPrime = setOfLeadISO.Clone();
                setIdWithoutPrime.remove(primeISO);
                if(newLead.get(primeISO) != null && idsMap.get((String)newLead.get(primeISO)) != null )
                {
                    Boolean isParentIsoPresent = false;
                    for(String idWithoutPrime : setIdWithoutPrime)
                    {
                        isParentIsoPresent = isParentIsoPresent || (newLead.get(idWithoutPrime) != Null && (newLead.get(idWithoutPrime) == idsMap.get((String)newLead.get(primeISO))));
                    }
                    
                    if(!isParentIsoPresent)
                    {
                        newLead.addError('Please add the Parent Account of ' +AccountsMap.get((String)newLead.get(primeISO)).name);
                        //return false;
                    }
                }
            }
            
        }
        return newLeads;
        
    }
    
    public static List <Lead> isISODuplicate(List < Lead> newLeads)
    {
        Set<String> setOfLeadISO = new Set<String>();
        Set<String> setIdWithoutPrime = new Set<String>();
        setOfLeadISO.addAll(salesRepAndIsoMap.values());
        setIdWithoutPrime = setOfLeadISO.Clone();
        
        for (Lead newLead: newLeads)
        {
            for(String primeISO : setOfLeadISO)
            {
                setIdWithoutPrime = setOfLeadISO.Clone();
                setIdWithoutPrime.remove(primeISO);
                
                if(newLead.get(primeISO) != null )
                {
                    Boolean isDuplicate = false;
                    for(String idWithoutPrime : setIdWithoutPrime)
                    {
                        isDuplicate = isDuplicate || (newLead.get(idWithoutPrime) != Null && newLead.get(primeISO) != Null && ((String)newLead.get(idWithoutPrime) == (String)newLead.get(primeISO)));
                    }
                    
                    if(isDuplicate)
                    {
                        newLead.addError('You cannot add the same ISO multiple times. Please remove duplicate instances.');
                        //return false;
                    }
                }
            }
        }      
        
        return newLeads;  
        
    }
    
    public static list <Lead> populateISOBasedOnSalesRep(list < Lead > newLeads)
    {
        set<Id> isoIdSet = new set<Id>();
        list<contact> contactList = new list<contact>();
        Map<Id,ID> conIdAccIdMap = new map<Id,Id>();
        
        for(Lead leadObj: newLeads)
        {
            for(String key : salesRepAndIsoMap.keySet())
            {
                if((id)(leadObj.get(key)) != null)
                isoIdSet.add((id)(leadObj.get(key)));
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
        
        for (Lead newOpty: newLeads)
        {
            for(String key: salesRepAndIsoMap.keySet())
            {
                if(((id)newOpty.get(key)) != null)
                {
                    newOpty.put(salesRepAndIsoMap.get(key),conIdAccIdMap.get((id)newOpty.get(key)));
                }
            }
        }
        
        return newLeads;
    }
    
}