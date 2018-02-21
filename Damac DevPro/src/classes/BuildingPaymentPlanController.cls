/**************************************************************************************************
* Name               : BuildingPaymentPlanController                                              *
* Description        : This is the controller for BuildingPaymentPlan visualforce page            *
* Created Date       : 11/02/2017                                                                 *
* Created By         : NSI - Kaavya Raghuram                                                      * 
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR          DATE                                                              *
* 1.0         NSI - Kaavya    11/02/2017                                                        *
**************************************************************************************************/
public without sharing class BuildingPaymentPlanController {

    public id invid;
    
    public List<planwrapper> pls= new List<planwrapper>();
    public BuildingPaymentPlanController(ApexPages.StandardController controller) {
        invid= ApexPages.currentPage().getParameters().get('id');
        prepareData();
        getAllPlans();
    }

    
    public Map<string, set<String>> mpProperties{get; set;}
    public Map<string, List<Inventory__c>> mpAvailable{get; set;}
    public Map<string, Map<string, List<Inventory__c>>> mpFinal{get; set;}
    public Map<string, Location__c> mpBuildings {get; set;}
    public Map<string, Location__c> mpLocations {get; set;}
    public string widthPx{get; set;}
    public string ptWidthPx{get; set;}
    public Map<String, List<Payment_Plan__c>> mpPaymentPlans{get; set;}
    public Map<Id, List<Payment_Terms__c>> mpPaymentTerms{get; set;}
    public string planKeyStr{get; set;}
    public string pTermKeyStr{get; set;}
    public List<String> Units {get; set;}
    public List<String> Locs{get; set;}
    
   
    public void prepareData(){
        
        id agentId = ApexPages.currentPage().getParameters().get('agentId');
        id propId = ApexPages.currentPage().getParameters().get('propId');
        //id invid= ApexPages.currentPage().getParameters().get('invid');
        
        string query = getCreatableFieldsSOQL('Inventory__c');
        query+= ' where id=:invid and Unit_location__c != null and  Status__c = \'Released\''; 
        mpProperties = new Map<String,set<String>>();
        mpAvailable = new Map<String, list<Inventory__c>>();
        mpFinal = new Map<string, Map<string, List<Inventory__c>>>();
        mpBuildings = new Map<String,Location__c>();
        mpLocations = new Map<String,Location__c>();
        mpPaymentTerms = new Map<Id, List<Payment_Terms__c>>();
        mpPaymentPlans = new Map<String, List<Payment_Plan__c>>();
        Units = new List<String>();
        Locs= new List<String>();
        planKeyStr = '';
        
        List<Schema.FieldsetMember> lstMembers = SObjectType.Inventory__c.FieldSets.Project_Unit.getFields();
        integer width= Math.round(100/lstMembers.size());
        widthpx = width+'%';
        
        lstMembers = SObjectType.Payment_Terms__c.FieldSets.PaymentTerm.getFields();
        width= Math.round(100/lstMembers.size());
        ptWidthPx = width+'%';
        
        System.debug('query = '+query);
        for(Inventory__c inv: database.query(query)){
             if(!mpAvailable.containsKey(inv.Building_ID__c)){
                mpAvailable.put(inv.Building_ID__c, new List<Inventory__c>{inv});
             }
             else{
                List<Inventory__c> existing = mpAvailable.get(inv.Building_ID__c);
                existing.add(inv);
                mpAvailable.put(inv.Building_ID__c,existing);
             }
             if(inv.Unit_Location__c!=null)
                 Locs.add(inv.Unit_Location__c);
             if(inv.Floor_Location__c!=null)
                 Locs.add(inv.Floor_Location__c);    
             /*
             if(inv.Floor_ID__c!=null)
             Floors.add(inv.Floor_ID__c);
             
             if(inv.Unit_ID__c!=null)
                 Units.add(inv.Unit_ID__c);
             */    
             /*
             if(!mpProperties.containsKey(inv.Property_Name_2__c)){
                mpProperties.put(inv.Property_Name_2__c, new set<String>{inv.Building_name__c});
             }
             else{
                set<String> existing = mpProperties.get(inv.Property_Name_2__c);
                existing.add(inv.Building_name__c);
                mpProperties.put(inv.Property_Name_2__c,existing);
             }
             */
             
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
        string ppQuery = getCreatableFieldsSOQL('Payment_Terms__c');
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
    
    public class planwrapper{
        //public Inventory__c inv {get; set;}
        public String FileName {get; set;}
        public String FileURL {get; set;}
        public planWrapper(){
            
        }
    }
    
    
    public void getAllPlans() {
       List<id> cvids = new List<id>();
       Map <id,String> locmap = new Map<id,String>();
       Map <String,String> cdmap = new Map<String,String>();
       String fname ='';
       system.debug('Locs==='+Locs);
      
       for(Location__c loc: [Select id, location_Id__c, Location_Type__c,Construction_status__c, status__c, Building_name__c from Location__c where id in: Locs]){
                locmap.put(loc.id,loc.Location_Type__c);
       }
       //system.debug('CC==='+cvmap.keyset());
        for( ContentDistribution cd : [select id, name,ContentVersionId,RelatedRecordId,DistributionPublicUrl from ContentDistribution  Where RelatedrecordId in :Locs]){ //ContentVersionId in :cvmap.keyset()]){
            
            planwrapper p= new  planwrapper ();
            //p.FileName= cd.name; //cvmap.get(cd.ContentVersionId) ;            
            if(cd.name.contains('_P'))
            fname='Plot File';
            else if(locmap.get(cd.RelatedRecordId)=='FLOOR')
            fname='Floor Plan';
            else 
            fname='Unit Plan';
            p.FileName=fname;
            p.FileURL=cd.DistributionPublicUrl;
            
            pls.add(p); 
            
        }
        //return pls;

    }
    public List<planwrapper> getPlans() {
        List<planwrapper> pws = new List<planwrapper>();
        pws = pls.clone();
        return pws;
    }
    
    public static string getCreatableFieldsSOQL(string objectName){
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
               // if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
              //  }
            }
        }
        // contruction of SOQL
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        // return constrcucted query
        return 'SELECT ' + selects + ' FROM ' + objectName ;
         
    }

    
}