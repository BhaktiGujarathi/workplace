public with sharing class ReportChartController {
    private String AccId;
    public Account objAccount{get;set;}
    
    public ReportChartController(ApexPages.StandardController stdController){
      
        objAccount = new Account();
        //AccId = '0019000001FZSyj';//ApexPages.currentPage().getParameters().get('id');
        AccId = '0019000001DLK9c';//ApexPages.currentPage().getParameters().get('id');
        
        objAccount = [Select a.Name, a.Id, (Select Name, Bank_Name__c From Opportunities) From Account a where a.ID =:AccId];
        
     }
     
     public List<ChartData>  getChartData(){  
     	string closeDateMonth='';
        List<ChartData> data = new List<ChartData>();
        List<Opportunity> oppList = new List<Opportunity>();  
        
        //String sql = 'SELECT SUM(Funding_Amount__c),CloseDate.Month,ID FROM Opportunity Where Bank_Id__c =\''+ AccId + '\'' + 'GROUP BY CloseDate.Month()\'';
         //AggregateResult[] groupedResults = Database.Query(sql);
       
        AggregateResult[] groupedResults = [SELECT CALENDAR_MONTH(CloseDate),SUM(Funding_Amount__c), count(Id) FROM Opportunity Where Bank_Id__c = :AccId GROUP BY CALENDAR_MONTH(CloseDate)];
        
        Integer count = [select count() FROM Opportunity Where Bank_Id__c = :AccId];
        
        //system.debug('***AccId'+AccId);
        //system.debug('***groupedResults'+groupedResults);
        for (AggregateResult ar : groupedResults)  {
		    System.debug('CALENDAR_MONTH(CloseDate)' + ar.get('expr0'));
		    System.debug('Average amount' + ar.get('expr1'));
		    
		    if(ar.get('expr0') !=null && ar.get('expr0') == 1)
		    closeDateMonth = 'Jan';
		    else if(ar.get('expr0') !=null && ar.get('expr0') == 2)
		    closeDateMonth = 'Feb';
		    else if(ar.get('expr0') !=null && ar.get('expr0') == 3)
		    closeDateMonth = 'March';
		    else if(ar.get('expr0') !=null && ar.get('expr0') == 4)
		    closeDateMonth = 'Aril';
		    else if(ar.get('expr0') !=null && ar.get('expr0') == 5)
		    closeDateMonth = 'May';
		    else if(ar.get('expr0') !=null && ar.get('expr0') == 6)
		    closeDateMonth = 'Jun';
		    else if(ar.get('expr0') !=null && ar.get('expr0') == 7)
		    closeDateMonth = 'July';
		    else if(ar.get('expr0') !=null && ar.get('expr0') == 8)
		    closeDateMonth = 'Aug';
		    else if(ar.get('expr0') !=null && ar.get('expr0') == 9)
		    closeDateMonth = 'Sept';
		    else if(ar.get('expr0') !=null && ar.get('expr0') == 10)
		    closeDateMonth = 'Oct';
		    else if(ar.get('expr0') !=null && ar.get('expr0') == 11)
		    closeDateMonth = 'Nov';
		    else //(ar.get('expr0') !=null && ar.get('expr0') == 12)
		    closeDateMonth = 'Dec';
		   
		    
		    data.add(new ChartData(closeDateMonth,(decimal)ar.get('expr1'), ((decimal)ar.get('expr2')).intValue()));
		}
        return data;  
    }  
    
     // Wrapper class  
    public class ChartData {  
        public string month { get; set; }  
        public decimal fundingAmount { get; set; }  
        public Integer countOpp { get; set; }  
        
        public ChartData(string month, decimal fundingAmount, Integer countOpp) {  
            this.month = month;  
            this.fundingAmount = fundingAmount; 
            this.countOpp = countOpp; 
        }  
    }  
}