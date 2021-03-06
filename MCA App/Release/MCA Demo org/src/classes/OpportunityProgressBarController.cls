public with sharing class OpportunityProgressBarController {
	
	public Id oppId									{get; set;}
	public Decimal tillDate;
	public list<OpportunityHistory> lstOppHistory;
	public list<OpportunityHistory> lstOppHistory1 = new list<OpportunityHistory>();
	public list<ProgressBarWrapper> lstWrapper 		{get;set;}
	public map<String,ProgressBarWrapper> mapWrapper{get;set;}
	public list<String> lstcolor					{get;set;}
	public Date modifiedDt;
	public Date createdDt;
	
public OpportunityProgressBarController(ApexPages.StandardController controller){
	// check for only stage is updated not amt or probability
	// if diffrence in days is zero
	// if the 100% exceeds
	oppId = ApexPages.currentPage().getParameters().get('Id');
	Opportunity objOpp = [select Name, CreatedDate, StageName from Opportunity where id=:oppId];
	mapWrapper = new map<string,ProgressBarWrapper>();
	lstOppHistory = new list<OpportunityHistory>();
	lstWrapper = new list<ProgressBarWrapper>();
	lstcolor = new list<String>();
	/*lstcolor = new list<String>();
	lstcolor.add('Progress_BarColor/red.jpg');
	lstcolor.add('Progress_BarColor/green.jpg');
	lstcolor.add('Progress_BarColor/darkblue.jpg');
	lstcolor.add('Progress_BarColor/lightblue.jpg');
	lstcolor.add('Progress_BarColor/brown.jpg');
	lstcolor.add('Progress_BarColor/orange.jpg');
	lstcolor.add('Progress_BarColor/blue.jpg');
	lstcolor.add('Progress_BarColor/purple.jpg');
	lstcolor.add('Progress_BarColor/magenta.jpg');
	lstcolor.add('Progress_BarColor/peach.jpg');
	lstcolor.add('Progress_BarColor/darkyellow.jpg');
	lstcolor.add('Progress_BarColor/skyblue.jpg');
	lstcolor.add('Progress_BarColor/grey.jpg');
	lstcolor.add('Progress_BarColor/lightgreen.jpg');*/
		
	lstOppHistory1 = [Select o.SystemModstamp, o.StageName, o.OpportunityId, o.CreatedDate From OpportunityHistory o where o.OpportunityId =: oppId order by o.CreatedDate];
	system.debug('@@lstOppHistory111'+lstOppHistory1);
	Integer i=0,j=0;
	while(i<=j && i<lstOppHistory1.size() && j<lstOppHistory1.size())
	{
		system.debug('@@@lstOppHistory1[j].StageName'+lstOppHistory1[j].StageName);
		if(lstOppHistory1[j].StageName == 'Funded' ){
			i = j+1;
			lstOppHistory.add(lstOppHistory1[j]);
		}
		else{
			lstOppHistory.add(lstOppHistory1[j]);
			++j;
		}
	}
	system.debug('@@lstOppHistory'+lstOppHistory);
	createdDt =  date.newinstance(objOpp.CreatedDate.year(), objOpp.CreatedDate.month(), objOpp.CreatedDate.day());
	if(lstOppHistory1.size() != lstOppHistory.size() || (lstOppHistory[lstOppHistory.size()-1].StageName == 'Funded'))
	{
		modifiedDt = date.newinstance(lstOppHistory[lstOppHistory.size()-1].SystemModstamp.year(), 
						lstOppHistory[lstOppHistory.size()-1].SystemModstamp.month(), 
						lstOppHistory[lstOppHistory.size()-1].SystemModstamp.day());
		tillDate = (createdDt.daysBetween(modifiedDt));	
		system.debug('****1111'+createdDt);
		system.debug('****1111'+modifiedDt);
		system.debug('****1111tillDate'+tillDate);
	}
	else{
		//system.debug('%%%'+(system.now()-lstOppHistory[0].CreatedDate)*1440);
		tillDate = (createdDt.daysBetween(Date.TODAY()));
		system.debug('****222'+tillDate);
	}
	// if tilldate>0
	init();
	
}// end of constructor

public void init(){
	Date newDt;
	Date lastDt;
	Decimal daysDiff;
	Integer i=0,j=0;
	Integer counter = 1;
	Map<String, OpportunityStageBar__c> mapColorCodes = OpportunityStageBar__c.getAll();
	 //system.debug('@@@mapColorCodes'+mapColorCodes);
	 //stop after closed stage
	if(lstOppHistory.size() == 2)
	{
		system.debug('1111');
		lastDt = date.newinstance(lstOppHistory[0].CreatedDate.year(),lstOppHistory[0].CreatedDate.month(),lstOppHistory[0].CreatedDate.day() );
		newDt = date.newinstance(lstOppHistory[1].CreatedDate.year(),lstOppHistory[1].CreatedDate.month(),lstOppHistory[1].CreatedDate.day() );
		system.debug('@@diff'+newDt.daysBetween(lastDt));
		system.debug('@@diff'+newDt.daysBetween(Date.TODAY()));
		//if only Opportunity Stage is changed
		if(lstOppHistory[0].StageName != lstOppHistory[1].StageName){
			if(lastDt.daysBetween(newDt) > 0)
				lstWrapper.add(new ProgressBarWrapper(lstOppHistory[0].StageName,((lastDt.daysBetween(newDt)/tillDate)*100).round(System.RoundingMode.FLOOR)+'%',
									mapColorCodes.containsKey(lstOppHistory[0].StageName)?mapColorCodes.get(lstOppHistory[0].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,lastDt.daysBetween(newDt)));
			else
				lstWrapper.add(new ProgressBarWrapper(lstOppHistory[0].StageName,5+'px',
									mapColorCodes.containsKey(lstOppHistory[0].StageName)?mapColorCodes.get(lstOppHistory[0].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,1));
									
			if(lstOppHistory.size()>0 && (lstOppHistory[lstOppHistory.size()-1].StageName == 'Funded')){
				if(lastDt.daysBetween(newDt) > 0)
					lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((newDt.daysBetween(modifiedDt)/tillDate)*100).round(System.RoundingMode.FLOOR)+'%',
		 						mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
		 						newDt.daysBetween(modifiedDt)));
		 		else
		 			lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,'5px',
		 						mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
		 						newDt.daysBetween(modifiedDt)));
			}else{
				if(tillDate > 0)
					lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((newDt.daysBetween(Date.TODAY())/tillDate)*100).round(System.RoundingMode.FLOOR)+'%',
			 						mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
			 						newDt.daysBetween(Date.TODAY())));
			 	else
			 		lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,'5px',
			 						mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
			 						newDt.daysBetween(Date.TODAY())));
			}
			++counter;
		}
		else{
			if(lstOppHistory[1].StageName == 'Funded'){
				if(tillDate > 0)
					lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((lastDt.daysBetween(modifiedDt)/tillDate)*100).round(System.RoundingMode.FLOOR)+'%',
			 						mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
			 						lastDt.daysBetween(modifiedDt)));
		 		else
		 			lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,'100%',
			 						mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
			 						lastDt.daysBetween(modifiedDt)));
			}
		 	else
		 		if(tillDate > 0)
		 			lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((lastDt.daysBetween(Date.TODAY())/tillDate)*100).round(System.RoundingMode.FLOOR)+'%',
			 						mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
			 						lastDt.daysBetween(Date.TODAY())));
			 	else
			 		lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,'100%',
			 						mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
			 						lastDt.daysBetween(Date.TODAY())));
		}
		
	} //end of if lstOppHistory.size() == 2
	else if(lstOppHistory.size() > 2){
		for(i=0;i<=lstOppHistory.size()-2;++i){
			for(j=i+1;j<=lstOppHistory.size()-1;++j){
				system.debug('@@@i'+i+'@@@j'+j);
				system.debug('@@Stages'+lstOppHistory[i].StageName+lstOppHistory[j].StageName);
				if(lstOppHistory[i].StageName != lstOppHistory[j].StageName){
					
					lastDt = date.newinstance(lstOppHistory[i].CreatedDate.year(),lstOppHistory[i].CreatedDate.month(),lstOppHistory[i].CreatedDate.day() );
					newDt = date.newinstance(lstOppHistory[j].CreatedDate.year(),lstOppHistory[j].CreatedDate.month(),lstOppHistory[j].CreatedDate.day() );
					system.debug('@@last'+lastDt.daysBetween(newDt));
					//system.debug('@@##last'+((lastDt.daysBetween(newDt)/tillDate)*100).round(System.RoundingMode.FLOOR));
					if(lastDt.daysBetween(newDt) > 0){
						if(tillDate > 0 && ((lastDt.daysBetween(newDt)/tillDate)*100).round(System.RoundingMode.FLOOR) > 5 && ((lastDt.daysBetween(newDt)/tillDate)*100).round(System.RoundingMode.FLOOR) < 95)
							lstWrapper.add(new ProgressBarWrapper(lstOppHistory[i].StageName,(((lastDt.daysBetween(newDt)/tillDate)*100).round(System.RoundingMode.FLOOR))-3+'%',
											mapColorCodes.containsKey(lstOppHistory[i].StageName)?mapColorCodes.get(lstOppHistory[i].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
																	lastDt.daysBetween(newDt)));
						else if(tillDate > 0 && ((lastDt.daysBetween(newDt)/tillDate)*100).round(System.RoundingMode.FLOOR) >= 95)
							lstWrapper.add(new ProgressBarWrapper(lstOppHistory[i].StageName,(((lastDt.daysBetween(newDt)/tillDate)*100).round(System.RoundingMode.FLOOR))-5+'%',
											mapColorCodes.containsKey(lstOppHistory[i].StageName)?mapColorCodes.get(lstOppHistory[i].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
																	lastDt.daysBetween(newDt)));
						else if(tillDate <= 0)
							lstWrapper.add(new ProgressBarWrapper(lstOppHistory[i].StageName,5+'px',
											mapColorCodes.containsKey(lstOppHistory[i].StageName)?mapColorCodes.get(lstOppHistory[i].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
																	lastDt.daysBetween(newDt)));
						else
							lstWrapper.add(new ProgressBarWrapper(lstOppHistory[i].StageName,((lastDt.daysBetween(newDt)/tillDate)*100).round(System.RoundingMode.FLOOR)+'%',
											mapColorCodes.containsKey(lstOppHistory[i].StageName)?mapColorCodes.get(lstOppHistory[i].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
																	lastDt.daysBetween(newDt)));
					}else
						lstWrapper.add(new ProgressBarWrapper(lstOppHistory[i].StageName,5+'px',
								mapColorCodes.containsKey(lstOppHistory[i].StageName)?mapColorCodes.get(lstOppHistory[i].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,1));
					i = j-1;
					++counter;
					break;
				}
				else
					newDt = date.newinstance(lstOppHistory[i].CreatedDate.year(),
										lstOppHistory[i].CreatedDate.month(),
										lstOppHistory[i].CreatedDate.day() );
			}//end of FOR-j
		}//end of FOR-i
		if(lstOppHistory[lstOppHistory.size()-1].StageName != lstOppHistory[lstOppHistory.size()-2].StageName)
			newDt = date.newinstance(lstOppHistory[lstOppHistory.size()-1].CreatedDate.year(),
									lstOppHistory[lstOppHistory.size()-1].CreatedDate.month(),
									lstOppHistory[lstOppHistory.size()-1].CreatedDate.day() );
		if(lstOppHistory.size()>0 && (lstOppHistory[lstOppHistory.size()-1].StageName == 'Funded')){
			if(tillDate > 0)
				lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((newDt.daysBetween(modifiedDt)/tillDate)*100).round(System.RoundingMode.FLOOR)+'%', 
								mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
													newDt.daysBetween(modifiedDt)));
			else
				lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,'5px', 
								mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
													newDt.daysBetween(modifiedDt)));
		}else{
		system.debug('###dayssss-newdt'+(newDt));	
		//system.debug('###dayssss'+(newDt.daysBetween(Date.TODAY())/tillDate));
		if(tillDate > 0)
			lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((newDt.daysBetween(Date.TODAY())/tillDate)*100).round(System.RoundingMode.FLOOR)+'%', 
								mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
													newDt.daysBetween(Date.TODAY())));
		else
			lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,'5px', 
								mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
													newDt.daysBetween(Date.TODAY())));
		}
		system.debug('###lstWrapper'+lstWrapper);
	}//end of else if lstOppHistory.size() > 2
	else{
		system.debug('3333');
		if(lstOppHistory.size()>0 && (lstOppHistory[lstOppHistory.size()-1].StageName == 'Funded')){
			
			if(tillDate>0)
				lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((createdDt.daysBetween(modifiedDt)/tillDate)*100).round(System.RoundingMode.FLOOR)+'%',
			 					mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
			 										createdDt.daysBetween(modifiedDt)));
			else
				lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,'99%',
								mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
								createdDt.daysBetween(modifiedDt)));
			}
		else{
			newDt = date.newinstance(lstOppHistory[0].CreatedDate.year(),lstOppHistory[0].CreatedDate.month(),lstOppHistory[0].CreatedDate.day() );
			if(tillDate>0){
				lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,((newDt.daysBetween(Date.TODAY())/tillDate)*100).round(System.RoundingMode.FLOOR)+'%',
			 					mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
			 										newDt.daysBetween(Date.TODAY())));
			}
			else
				lstWrapper.add(new ProgressBarWrapper(lstOppHistory[lstOppHistory.size()-1].StageName,'99%',
								mapColorCodes.containsKey(lstOppHistory[lstOppHistory.size()-1].StageName)?mapColorCodes.get(lstOppHistory[lstOppHistory.size()-1].StageName).ColorCode__c:mapColorCodes.get('else').ColorCode__c,
								newDt.daysBetween(Date.TODAY())));
		}
	}// end of else lstOppHistory is of size one
	// to get total number of days if stage repetatively occurs
	//for(Integer z=lstWrapper.size()-1; z>=0;z--){
	Decimal sizeper = 100/counter;
	for(ProgressBarWrapper objwrapper:lstWrapper){
		system.debug('&&&&&&'+objwrapper);
		if(mapWrapper!=null && mapWrapper.containsKey(objwrapper.stageColor)){
			ProgressBarWrapper newWrapper = mapWrapper.get(objwrapper.stageColor);
			objwrapper.daysDiff += newWrapper.daysDiff;
			if(objwrapper.stageName == 'Application Sent' || objwrapper.stageName == 'Application In' ||
				objwrapper.stageName == 'Underwriting' || objwrapper.stageName == 'Approved' ||
				objwrapper.stageName == 'Agreement Signed' || objwrapper.stageName == 'Funded')
					newWrapper.stageName = objwrapper.stageName;
			//if(objwrapper.stagePercentage >= '100%')
				//objwrapper.stagePercentage = '99%';
		}
		else{
			string stage = '';
			if(objwrapper.stageColor == mapColorCodes.get('Application Sent').ColorCode__c)
				stage = 'Application Sent';
			else if(objwrapper.stageColor == mapColorCodes.get('Application In').ColorCode__c)
				stage = 'Application In';
			else if(objwrapper.stageColor == mapColorCodes.get('Underwriting').ColorCode__c)
				stage = 'Underwriting';
			else if(objwrapper.stageColor == mapColorCodes.get('Approved').ColorCode__c)
				stage = 'Approved';
			else if(objwrapper.stageColor == mapColorCodes.get('Agreement Signed').ColorCode__c)
				stage = 'Agreement Signed';
			else if(objwrapper.stageColor == mapColorCodes.get('Funded').ColorCode__c)
				stage = 'Funded';
			system.debug('@@@'+stage);
			if(stage != '')
			objwrapper.stageName = stage;
			
			lstcolor.add(objwrapper.stageColor);
		}
		if(tillDate == 0)
			objwrapper.stagePercentage = sizeper + '%';
		mapWrapper.put(objwrapper.stageColor,objwrapper);
		system.debug('&&&mapWrapper'+mapWrapper);
		system.debug('###lstWrapper'+lstWrapper);
	} 
}

public Integer testmethods(Integer i){
		++i;++i;++i;	
		return i;
}
	
	public class ProgressBarWrapper {
		public String stageName {get;set;}
		public String stagePercentage {get;set;}
		public String stageColor {get;set;}
		public Decimal daysDiff {get;set;}
		public ProgressBarWrapper(String pstageName, String pstagePercentage, String pstageColor,Decimal pdaysDiff){
			stageName = pstageName;
			stagePercentage = pstagePercentage;
			stageColor = pstageColor;
			daysDiff = pdaysDiff;
		}
	}

}