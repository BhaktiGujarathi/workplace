public class AvailabilityController {
    
    public Map<string, set<String>> mpProperties{get; set;}
    public Map<string, List<Inventory__c>> mpAvailable{get; set;}
    public Map<string, Map<string, List<Inventory__c>>> mpFinal{get; set;}
    public Map<string, Location__c> mpBuildings {get; set;}
    public string widthPx{get; set;}
    public string ptWidthPx{get; set;}
    public Map<String, List<Payment_Plan__c>> mpPaymentPlans{get; set;}
    public Map<Id, List<Payment_Terms__c>> mpPaymentTerms{get; set;}
    public string planKeyStr{get; set;}
    public string pTermKeyStr{get; set;}
    public String propId{set;get;}
    
    public Double offset{
        get{
            TimeZone timeZ = UserInfo.getTimeZone();
            return timeZ.getOffset(Datetime.now())/(1000*3600*24.0);
        }
    }
    
    public AvailabilityController(){
        prepareData();
    }
    
    public void prepareData(){
        
        id agentId = ApexPages.currentPage().getParameters().get('agentId');
        propId = ApexPages.currentPage().getParameters().get('propId');
      
        System.debug('>>>>>>>>>>>>>>>>'+agentId);
        
        string query = DamacUtility.getCreatableFieldsSOQL('Inventory__c');
        query+= ' where Unit_location__c != null and Status__c = \'Released\''; 
        if(propid != null)
            query+= ' and Marketing_Name__c =: propId';
        
        if(agentId != null){
            System.debug('>>>>>>>>>>'+agentId);
            string inventoryIdQuery ='SELECT Inventory__c from Inventory_User__c where Inventory__r.Status__c = \'RELEASED\' AND Inventory__r.Unit_Location__c != null'+ 
                                         ' AND Inventory__r.Address__c != null AND End_Date__c >= TODAY AND User__c=\''+agentId+'\'';

            String generalInventoryQuery = 'SELECT Id from Inventory__c where Status__c=\'RELEASED\' AND Unit_Location__c != null'+                                
            ' AND Address__c != null AND Is_Assigned__c = false';                             
            
            //Location Name Selected is blank or All then dont include it in query
            
            if(ApexPages.currentPage().getParameters().containsKey('Bedrooms') && ApexPages.currentPage().getParameters().get('Bedrooms') != ''
                && ApexPages.currentPage().getParameters().get('Bedrooms') != 'All'){
                String bedroomsSelectedFromURL = ApexPages.currentPage().getParameters().get('Bedrooms');
                
                List<String> bedroomsSelectedLists = bedroomsSelectedFromURL.split(',');
                
                if(null != bedroomsSelectedLists){
                    inventoryIdQuery += ' AND Inventory__r.IPMS_Bedrooms__c IN (\''+String.join(bedroomsSelectedLists,'\',\'')+'\')';
                    generalInventoryQuery += ' AND IPMS_Bedrooms__c IN (\''+String.join(bedroomsSelectedLists,'\',\'')+'\')';
                    system.debug('**location query '+inventoryIdQuery);
                }
                 
               
             }  
             
             if(ApexPages.currentPage().getParameters().containsKey('Type') && ApexPages.currentPage().getParameters().get('Type') != ''
                && ApexPages.currentPage().getParameters().get('Type') != 'All'){
               String typeSelectedFromURL= ApexPages.currentPage().getParameters().get('Type');
                
                List<String> typeSelectedLists= typeSelectedFromURL.split(',');
                
                if(null != typeSelectedLists){
                    inventoryIdQuery += ' AND Inventory__r.Unit_Type__c IN (\''+String.join(typeSelectedLists,'\',\'')+'\')';
                    generalInventoryQuery += ' AND Unit_Type__c IN (\''+String.join(typeSelectedLists,'\',\'')+'\')';
                    system.debug('**location query '+inventoryIdQuery);
                }
                       
             }

            if(ApexPages.currentPage().getParameters().containsKey('Location') && ApexPages.currentPage().getParameters().get('Location') != ''
                && ApexPages.currentPage().getParameters().get('Location') != 'All'){
                String locationSelectedFromURL = ApexPages.currentPage().getParameters().get('Location');
                
                List<String> locationSelectedLists = locationSelectedFromURL.split(',');
                
                if(null != locationSelectedLists){
                    inventoryIdQuery += ' AND Inventory__r.Address__r.City__c IN (\''+String.join(locationSelectedLists,'\',\'')+'\')';
                    generalInventoryQuery += ' AND Address__r.City__c IN (\''+String.join(locationSelectedLists,'\',\'')+'\')';
                    system.debug('**location query '+inventoryIdQuery);
                }
            }

            if(ApexPages.currentPage().getParameters().containsKey('MinPrice') && 
                ApexPages.currentPage().getParameters().get('MinPrice') != ''){
                String priceMin = ApexPages.currentPage().getParameters().get('MinPrice');
                inventoryIdQuery += ' AND ( Inventory__r.Selling_Price__c >=' + priceMin +' OR Inventory__r.Special_Price_calc__c >= ' +priceMin + ') ';
                generalInventoryQuery += ' AND ( Selling_Price__c >=' + priceMin +' OR Special_Price_calc__c >= ' +priceMin + ') ';
            }
            
            if(ApexPages.currentPage().getParameters().containsKey('MaxPrice') && 
                ApexPages.currentPage().getParameters().get('MaxPrice') != ''){
                String priceMax = ApexPages.currentPage().getParameters().get('MaxPrice');
                inventoryIdQuery += ' AND ( Inventory__r.Selling_Price__c <=' + priceMax +' OR Inventory__r.Special_Price_calc__c <= ' +priceMax + ') ';
                generalInventoryQuery += ' AND ( Selling_Price__c <=' + priceMax +' OR Special_Price_calc__c <= ' +priceMax + ') ';
            }

            Set<Id> InventoryIDs = UtilityQueryManager.getInventoryIDs(inventoryIdQuery);
            Set<Id> generalInventoryIds= UtilityQueryManager.getAllGeneralInventories(generalInventoryQuery);        
            
            system.debug('**** generalInventoryId '+generalInventoryIds );        
            
            InventoryIDs.addAll(generalInventoryIds);
            
            query+= ' and Id in : InventoryIDs';
        }

        mpProperties = new Map<String,set<String>>();
        mpAvailable = new Map<String, list<Inventory__c>>();
        mpFinal = new Map<string, Map<string, List<Inventory__c>>>();
        mpBuildings = new Map<String,Location__c>();
        mpPaymentTerms = new Map<Id, List<Payment_Terms__c>>();
        mpPaymentPlans = new Map<String, List<Payment_Plan__c>>();
        planKeyStr = '';
        
        List<Schema.FieldsetMember> lstMembers = SObjectType.Inventory__c.FieldSets.Project_Unit.getFields();
        integer width= Math.round(100/(lstMembers.size()-1));
        widthpx = width+'%';
        
        lstMembers = SObjectType.Payment_Terms__c.FieldSets.PaymentTerm.getFields();
        width= Math.round(100/lstMembers.size());
        ptWidthPx = width+'%';
        
        
        for(Inventory__c inv: database.query(query)){
             if(!mpAvailable.containsKey(inv.Building_ID__c)){
                mpAvailable.put(inv.Building_ID__c, new List<Inventory__c>{inv});
             }
             else{
                List<Inventory__c> existing = mpAvailable.get(inv.Building_ID__c);
                existing.add(inv);
                mpAvailable.put(inv.Building_ID__c,existing);
             }
        }
        
        for(Location__c loc: [Select id, location_Id__c, Construction_status__c, status__c, Building_name__c from Location__c where Location_Id__c in: mpAvailable.keyset()]){
            mpBuildings.put(loc.location_Id__c, loc);
        }
        
        set<string> buildingIds = new set<string>();
        set<Id> PaymentPlanIds = new set<Id>();
        date currDate = system.today();
        for(Payment_Plan__c pp: [Select id,Building_ID__c from Payment_Plan__c where Building_ID__c in: mpBuildings.keyset() and Effective_From__c<=:currDate and Effective_To_calculated__c>=:currDate]){
            PaymentPlanIds.add(pp.Id);
            buildingIds.add(pp.Building_ID__c);
            if(!mpPaymentPlans.containsKey(pp.Building_ID__c))
                mpPaymentPlans.put(pp.Building_ID__c, new List<Payment_Plan__c>{pp});
            else{
                List<Payment_Plan__c> existing = mpPaymentPlans.get(pp.Building_ID__c);
                existing.add(pp);
                mpPaymentPlans.put(pp.Building_ID__c, existing); 
            }
        }
        
        for(string bId : buildingIds){
            planKeyStr+=bId+';';
        }
        
        set<String> paymentIds = new set<String>();
        string ppQuery = DamacUtility.getCreatableFieldsSOQL('Payment_Terms__c');
        ppQuery+=' where Payment_Plan__c in: PaymentPlanIds order by line_ID__c';
        for(Payment_Terms__c pt: database.query(ppQuery)){
            paymentIds.add(pt.Payment_Plan__c);
            if(!mpPaymentTerms.containsKey(pt.Payment_Plan__c)){
                mpPaymentTerms.put(pt.Payment_Plan__c, new list<Payment_Terms__c>{pt});
            }
            else{
                List<Payment_Terms__c> existing = mpPaymentTerms.get(pt.Payment_Plan__c);
                existing.add(pt);
                mpPaymentTerms.put(pt.Payment_Plan__c, existing);
            }
            
        }
        
        for(string pId : paymentIds){
            pTermKeyStr+=pId+';';
        }
    }
    
    
   
    
}