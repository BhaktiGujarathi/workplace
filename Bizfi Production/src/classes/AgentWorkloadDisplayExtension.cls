public class AgentWorkloadDisplayExtension {

	public List<AWDynamicCategories__c> 		listSCtime			 {get;set;}
    public List<String> 						listOfWorkLoads 	 {get;set;}
    public List<String> 						listOfWorkLoadsLabel {get;set;}
    public List<String> 						orderStr 			 {get;set;}
    public List<Sales_Rep_Report_Card__c> 		lScoreCard			 {get;set;}
    public Map<String,AWDynamicCategories__c> 	mapOfCustSet 		 {get;set;}
    public Sales_Rep_Report_Card__c 			salesRepScore 		 {get;set;}

    public AgentWorkloadDisplayExtension(ApexPages.StandardController controller){
		listSCtime = new List<AWDynamicCategories__c>();
    }
    
    public PageReference onLoad()
    {
        
        String queryStringForSalesRepScoreCard;
        String scoreCardID;
        listOfWorkLoads      = new List<String> {'Count__c','Average_Min__c','Total_Work_Min__c','Total_Work_Hours__c'};
        listOfWorkLoadsLabel = new List<String> {'Count','Average Min','Total Work - Min','Total Work - Hours'};
        mapOfCustSet         = new Map<String,AWDynamicCategories__c>();
        orderStr             = new List<String>();

        List<AWDynamicCategories__c> agentWorkLoadDynamicCategories = new List<AWDynamicCategories__c>();

		agentWorkLoadDynamicCategories = [select name,Count__c,Average_Min__c,Total_Work_Min__c,Total_Work_Hours__c,order__c from AWDynamicCategories__c order by order__c];
        
        for(AWDynamicCategories__c scCust : agentWorkLoadDynamicCategories)
        {
            
            mapOfCustSet.put(scCust.name,scCust);
            orderStr.add(scCust.name);
            
        }
        
        queryStringForSalesRepScoreCard = joinList(Sales_Rep_Report_Card__c.getSObjectType().getDescribe().fields.getMap().keyset(),',');
        //list and null check
        scoreCardID = ApexPages.currentPage().getParameters().get('Id');
        if(!String.isBlank(scoreCardID))
        {
            lScoreCard = database.query('SELECT ' + queryStringForSalesRepScoreCard + ' from Sales_Rep_Report_Card__c where Id = \'' + scoreCardID + '\'');
            if(lScoreCard != null && !lScoreCard.isEmpty())
            {
              
                salesRepScore = lScoreCard[0];
            }
        }
                
        return null;
    }


    // Join an Apex list of fields into a SELECT fields list string Or making the query string.
    public String joinList(Set<String> theList, String separator) {
        
        if (theList == null) {
            return null;
        }
        if (separator == null) {
            separator = '';
        }
        
        String joined = '';
        Boolean firstItem = true;
        for (String item : theList) {
            if(null != item) {
                if(firstItem){
                    firstItem = false;
                }
                else {
                    joined += separator;
                }
                joined += item;
            }
        }
        return joined;
    }
}