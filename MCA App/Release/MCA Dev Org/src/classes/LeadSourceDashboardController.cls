/* 
 *  Controller class to show he average volume of leads per lead source over the last year.
 *  
 *  Revision History:
 *   
 *  Version        Author                   Date            Description
 *  1.0            Nachiket R. Deshpande    16/02/2015      Initial Draft
 */   

public with sharing class LeadSourceDashboardController { 
	
	private String leadId;
	private Lead objLead {get;set;}
	
	//Constructor
	public LeadSourceDashboardController(ApexPages.StandardController stdController){
		
		/*objLead = new Lead (); 
		leadId = '00Q9000000hVblE';
		objLead = [SELECT Id,
		                  LeadSource
		           FROM Lead WHERE ID =: leadId];
		system.debug('****objLead****'+objLead);*/
		
	}
	
	public List<LeadSourceDashboardData>  getLeadSourceDashboardData(){ 
		string leadCreatedMonth='';
		List<LeadSourceDashboardData> data = new List<LeadSourceDashboardData>();
		Integer countLeadSourceByMonth = 0;
		AggregateResult[] leadAggregateResult = [SELECT count(ID),
		                                                LeadSource
		                                                //CALENDAR_MONTH(CREATEDDATE)
		                                         FROM Lead 
		                                         GROUP BY ROLLUP (LeadSource)];
		                                         //,CALENDAR_MONTH(CREATEDDATE) 
		                                         //ORDER BY CALENDAR_MONTH(CREATEDDATE) DESC ];
		system.debug('****leadAggregateResult****'+leadAggregateResult);
		for(Integer i=0 ; i<leadAggregateResult.size();i++){
			system.debug('*****leadAggregateResult[0].Id****'+leadAggregateResult[i].Id);
		}
		
		for (AggregateResult aggResult : leadAggregateResult)  {
			System.debug('at zeorth element' + aggResult.get('expr0'));
			System.debug('at 1st element' + aggResult.get('LeadSource'));
			//System.debug('at 2nd element' + aggResult.get('expr1'));

		    if(aggResult.get('LeadSource') !=null && aggResult.get('LeadSource') == 1)
		    leadCreatedMonth = 'Jan';
		    else if(aggResult.get('LeadSource') !=null && aggResult.get('LeadSource') == 2)
		    leadCreatedMonth = 'Feb';
		    else if(aggResult.get('LeadSource') !=null && aggResult.get('LeadSource') == 3)
		    leadCreatedMonth = 'March';
		    else if(aggResult.get('LeadSource') !=null && aggResult.get('LeadSource') == 4)
		    leadCreatedMonth = 'April';
		    else if(aggResult.get('LeadSource') !=null && aggResult.get('LeadSource') == 5)
		    leadCreatedMonth = 'May';
		    else if(aggResult.get('LeadSource') !=null && aggResult.get('LeadSource') == 6)
		    leadCreatedMonth = 'Jun';
		    else if(aggResult.get('LeadSource') !=null && aggResult.get('LeadSource') == 7)
		    leadCreatedMonth = 'July';
		    else if(aggResult.get('LeadSource') !=null && aggResult.get('LeadSource') == 8)
		    leadCreatedMonth = 'Aug';
		    else if(aggResult.get('LeadSource') !=null && aggResult.get('LeadSource') == 9)
		    leadCreatedMonth = 'Sept';
		    else if(aggResult.get('LeadSource') !=null && aggResult.get('LeadSource') == 10)
		    leadCreatedMonth = 'Oct';
		    else if(aggResult.get('LeadSource') !=null && aggResult.get('LeadSource') == 11)
		    leadCreatedMonth = 'Nov';
		    else //(aggResult.get('expr0') !=null && aggResult.get('expr0') == 12)
		    leadCreatedMonth = 'Dec';

			if(aggResult.get('LeadSource') <> null){
				data.add(new LeadSourceDashboardData(((string)aggResult.get('LeadSource')),((decimal)aggResult.get('expr0')).intValue(),leadCreatedMonth));
			}//End If
		}//End For
		return data;  
	}//End getLeadSourceDashboardData
	
	//Wrapper class  
    public class LeadSourceDashboardData {  
        public string leadSource { get; set; }  
        public Integer leadCount { get; set; }  
        public string month { get; set; }  
        
        public LeadSourceDashboardData(string leadSource, Integer leadCount, string month) {  
            this.leadSource = leadSource;  
            this.leadCount = leadCount; 
            this.month = month; 
        }//End LeadSourceDashboardData
    }//End LeadSourceDashboardData  Class
}