public class SCSalesRepMetricsDisplayController {
    
    
    public List<SCTimeframe_Metric__c> listSCtime = new List<SCTimeframe_Metric__c>();
    public List<String> listOfTimeLines {get;set;}
    public List<String> listOfTimeLinesLabel {get;set;}
    public Map<String,SCTimeframe_Metric__c> mapOfCustSet {get;set;}
    public Sales_Rep_Report_Card__c salesRepScore {get;set;}
    public List<String> orderStr {get;set;}
    public List<Sales_Rep_Report_Card__c> lScoreCard;
    
    public SCSalesRepMetricsDisplayController(ApexPages.StandardController controller)
    {
        
    }
    
    public PageReference onLoad()
    {
        
        String queryStringForSalesRepCard;
        String queryID;
        listOfTimeLines = new List<String> {'Yesterday__c','Last_7_Days__c','Last_Month__c','MTD__c','YTD__c'};
        listOfTimeLinesLabel = new List<String>{'Yesterday','Last 7 Days','Last Month','MTD','YTD'};
        mapOfCustSet = new Map<String,SCTimeframe_Metric__c>();
        orderStr = new List<String>();
        
        
        for(SCTimeframe_Metric__c scCust:[select name,Yesterday__c,Last_7_Days__c,Last_Month__c,MTD__c,YTD__c,order__c from SCTimeframe_Metric__c order by order__c])
        {
            
            mapOfCustSet.put(scCust.name,scCust);
            orderStr.add(scCust.name);
            
        }
        
        
        queryStringForSalesRepCard = joinList(Sales_Rep_Report_Card__c.getSObjectType().getDescribe().fields.getMap().keyset(),',');
        //list and null check
        queryID = ApexPages.currentPage().getParameters().get('Id');
        if(!String.isBlank(queryID))
        {
            lScoreCard = database.query('SELECT '+queryStringForSalesRepCard +' from Sales_Rep_Report_Card__c where Id = \''+queryID+'\'');
            if(lScoreCard != null && lScoreCard.size() > 0)
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