/*  Description - Controller for CreateInvoice Page
 * 
 *  Created By - Sneha P.
 * 
 *  Date - 02/01/2014
 */
public with sharing class CreateInvoiceController {
public list<ProjectWrapper> projectListWrapper {get; set;}  //list of the Wrapper class
	public list<HarvestTimeEntry__c> timeEntryList {get; set;} 
	public set<Id> selectedProjects 			   {get; set;}  // Set of the Selected Projects Id
	public boolean createSingleInvoice             {get; set;}  // Variable to determine if single Invoice is to be created 
	public list<String> invoiceIdList 		   	   {get; set;}
	public final HarvestProject__c project;
	//public boolean isCBDisabled					   {get; set;} 						
	//Private Variables
	private final String creditReason = 'Multiple Entries for the Task Type';
	private final String selectProjectError = 'Please select the projects that are to be invoiced';
	private set<String> taskTypeToMerge ;
	private map<String,String> replacementSettingMap;
	
	//Constructor
	public CreateInvoiceController(ApexPages.StandardController stdController){
		 
		 projectListWrapper = new list<ProjectWrapper>();
		 replacementSettingMap = new map<String,String>();
		 invoiceIdList = new list<String>();
		 taskTypeToMerge = new set<String>();
		 selectedProjects = new set<Id>();
		// isCBDisabled = true; 
		 
		 this.project = (HarvestProject__c)stdController.getRecord();
		 Integer numberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
		 this.project.DateCompleted__c = Date.newInstance(system.today().year(), system.today().month(), numberOfDays);
		 this.project.DateStarted__c = null;
		 this.populateProjects();
		 this.populateMergeTaskType();
		 this.populateReplacementSetting();
	}
	
	//Function to populate the projects based on the Client selected 
	public void populateProjects(){
		
		projectListWrapper.clear();
		Id acctId = this.project.Account__c;

		Date DateCompleted;
		if(project.DateCompleted__c != null && project.DateCompleted__c!= null && project.DateCompleted__c.month() != 12)
			DateCompleted = Date.newInstance(project.DateCompleted__c.year(), project.DateCompleted__c.month()+1, 1);
		else if(project.DateCompleted__c != null)
			DateCompleted = Date.newInstance(project.DateCompleted__c.year()+1, 1, 1);

		set<Id> setProject = new set<Id>();
		map<Id,decimal> mapTimeEntryHrs = new map<Id,decimal>();
		
		//if(!this.fromProjectBtn)
			//fetch all the Time Entry records for the selected Date Range
			for (HarvestTimeEntry__c timeEntry :[Select Date__c,Duration__c,Hours__c,EndTime__c,StartTime__c,HarvestProject__c
						 					 From HarvestTimeEntry__c where Invoiced_by_CMB__c = false
						 											  and ((StartTime__c >=: project.DateStarted__c and
																	 EndTime__c <=: DateCompleted) or 
																	( Date__c >=: Date.valueOf(project.DateStarted__c) and	
																	  Date__c <=: Date.valueOf(project.DateCompleted__c))) ]){
				setProject.add(timeEntry.HarvestProject__c);
				
				// Calculate hrs for each project 	
				decimal hrs;
				
				if(timeEntry.Hours__C != null)
					//hrs = timeEntry.Duration__c;
					hrs = timeEntry.Hours__C;
				else if(timeEntry.EndTime__c != null && timeEntry.StartTime__c != null){
					hrs = (timeEntry.EndTime__c.getTime()  - timeEntry.StartTime__c.getTime()) / (1000.0*60.0*60.0);  
				}
				if(hrs == null)
					hrs = 0; 
				//Store the total Hours for each project in a map, to display on the page
				if(mapTimeEntryHrs.isEmpty() || (!mapTimeEntryHrs.isEmpty() && 
												 !mapTimeEntryHrs.containsKey(timeEntry.HarvestProject__c)))
					mapTimeEntryHrs.put(timeEntry.HarvestProject__c,hrs);		
				else if(!mapTimeEntryHrs.isEmpty() && mapTimeEntryHrs.containsKey(timeEntry.HarvestProject__c)){
					mapTimeEntryHrs.put(timeEntry.HarvestProject__c,mapTimeEntryHrs.get(timeEntry.HarvestProject__c)+hrs);
				}						  	
			}
								  
		String query = 'Select Id,Name,Budget__c,Account__c,Account__r.Name,ProjectHourlyRate__c,Opportunity__c,TotalProjectHours__c,Opportunity__r.Billing_Contact__c,Oldest_Uninvoiced_Date__c'+ 
						' from HarvestProject__c'; 
						//where UnInvoicedCMB_TimeEntries__c > 0'; 
			query += ' where Id IN: setProject';
		
		if(acctId != null){
			//isCBDisabled = false;
			query +=' and Account__c =: acctId';	
		}else{
			//disable the Create Single Invoice checkbox
			createSingleInvoice = false;
			//isCBDisabled = true;
		}
		query += ' order by Account__r.Name,Name';
		for(HarvestProject__c prjct : Database.Query(query)){
			// Add the project to wrapper list with isSelected as false
			projectListWrapper.add(new ProjectWrapper(prjct,false,mapTimeEntryHrs.containsKey(prjct.Id) ? 
																		mapTimeEntryHrs.get(prjct.Id) : 
																			0));
		}
	}
	
	public PageReference CreateInvoices(){
		list<Invoice__c> invoiceList = new list<Invoice__c>();
		map<Id, Invoice__c> mapAccInvoice = new map<Id,Invoice__c>();
		
		//Invoice__c invoice;
		boolean isListInserted = false;
		selectedProjects.clear();
		invoiceList.clear();
		try{
			Integer cnt = 0; 
			//Create Invoice and Invoice Line Items for selected projects
			for(ProjectWrapper wrapper : projectListWrapper){
				if(wrapper.isSelected ){
					cnt++;
					selectedProjects.add(wrapper.prjct.id);
					//If its create single, maintain a map of Account and invoice  and its single invoices
					if(createSingleInvoice){
						if(mapAccInvoice.isEmpty() || !mapAccInvoice.containskey(wrapper.prjct.Account__c)){
							mapAccInvoice.put(wrapper.prjct.Account__c,
												new Invoice__c(Account__c = wrapper.prjct.Account__c,
												Opportunity__c = wrapper.prjct.Opportunity__c,
												Project_Harvest__c = wrapper.prjct.id,
												Status__c = 'Open',
												Invoice_Type__c = 'Hours',
												Rate__c	= wrapper.prjct.ProjectHourlyRate__c,
												Description_On_Invoice__c = wrapper.prjct.Name,
												Description__c = wrapper.prjct.Name,
												Billing_Contact__c = wrapper.prjct.Opportunity__r.Billing_Contact__c
												) );
						}
					}//Link invoice to Project,Client  and opp
					else if(!createSingleInvoice ){
						invoiceList.add(new Invoice__c(Account__c = wrapper.prjct.Account__c,
												Opportunity__c = wrapper.prjct.Opportunity__c,
												//Harvest_Project__c = wrapper.prjct.id,
												Project_Harvest__c = wrapper.prjct.id,
												Status__c = 'Open',
												Invoice_Type__c = 'Hours',
												Rate__c	= wrapper.prjct.ProjectHourlyRate__c,
												Description_On_Invoice__c = wrapper.prjct.Name,
												Description__c = wrapper.prjct.Name,
												Billing_Contact__c = wrapper.prjct.Opportunity__r.Billing_Contact__c
												));
					
						//invoiceList.add(invoice);
					}
				}	
			}
			//If No project is selected for invoicing, display information msg asking user to select project 
			if(cnt == 0 ){
				mapAccInvoice.clear();
				invoiceList.clear();
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,selectProjectError));
				return null ;
			}
			
			this.populateTimeEntries();
			
			//Info msg Displayed when there are no Time Entries for selected projects
			if(timeEntryList == null || timeEntryList.size() == 0){
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'No Time entries for this Date Range for selected project/projects'));
				return null ;	
			}
			
			
			if(createSingleInvoice){
				//attach all the Line items to single Invoice 
				if(mapAccInvoice.size() > 0)
					insert mapAccInvoice.values();
				
				// Add the invoices to a list to open them in new Tab thr javascript
				invoiceList.addAll(mapAccInvoice.values());
				isListInserted = true;	
				//Send a map of Account and related Single Invoice Invoice
				createLineItems(mapAccInvoice,null);
			}else{
				map<Id,Invoice__c> mapProjectInvoice = new map<Id,Invoice__c>();
				
				// Open the invoices in new tab
				if(invoiceList.size() > 0){
					insert invoiceList;
					isListInserted = true;	
				}
			
				for(Invoice__c invce : invoiceList){
					//mapProjectInvoice.put(invce.Harvest_Project__c,invce);
					mapProjectInvoice.put(invce.Project_Harvest__c,invce);
				}
				createLineItems(null,mapProjectInvoice);
			}
		}catch(Exception e){
			if(invoiceList.size() > 0 && isListInserted){
				delete invoiceList;
				invoiceList.clear();
			}
			else if(mapAccInvoice.size() > 0 && isListInserted)
				delete mapAccInvoice.values();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
												       e.getMessage()));
			
			
			return null;
		}		
		for( Invoice__c invce : invoiceList){
			invoiceIdList.add(invce.id);
		}
		
		if(createSingleInvoice){
			this.populateProjects();
			//return new PageReference('/'+invoice.id);
		}else{
			this.populateProjects();
		}
		
		//return this.Cancel();
		return null;
	}
//-------------------------	
	
	//Function called when Cancel button is clicked 
	public PageReference Cancel(){
		//if its called from project record return it to its detail Page
		 if(this.project.id != null){
		 	return new PageReference('/'+this.project.id);
		 }
		 // Redirect to Home Page
		 return new PageReference('/home/home.jsp');
	}
	
	// Private methods
	// Function to create Line Item Summary ,Invoice Line items and update the Time Entry record to Invoiced By CMB
	//private void createLineItems(Invoice__c invoice,map<Id,Invoice__c> mapProjectInvoice ){
	private void createLineItems(map<Id,Invoice__c> mapAccInvoice,map<Id,Invoice__c> mapProjectInvoice ){	
		map<String,Line_Item__c> lineItemMap = new map<String,Line_Item__c>();
		//map<String,Invoice_Line_Item_Summary__c> mapSummary = new map<String, Invoice_Line_Item_Summary__c> ();
		list<Line_Item__c> lineItemToBeCreated = new list<Line_Item__c>();
		map<Id,HarvestTimeEntry__c> timeEntryToBeUpdatedMap = new map<Id,HarvestTimeEntry__c>();
		//map to track the Time Entry Id which is credited in case of duplicate,
		// if other time entry with higher hrs found fetch the previous one and update the credite reason 
		map<String, Id> timeEntryCreditedMap = new map<String,Id>();
		map<String, list<Id>> timeEntryNotCreditedMap = new map<String,list<Id>>();
		
		// Create Line Items Linked to Line Item Summary and Invoice object
		for(HarvestTimeEntry__c timeEntry : timeEntryList){
			
			Date objDate;
			// if date is null
			if(timeEntry.Date__c == null)
				objDate = timeEntry.EndTime__c.date();
			else
				objDate = timeEntry.Date__c;
			
			Decimal hrs;
			
			if(timeEntry.EndTime__c != null && timeEntry.StartTime__c != null){
				hrs = (timeEntry.EndTime__c.getTime()  - timeEntry.StartTime__c.getTime()) / (1000.0*60.0*60.0);  
			}
			else if(timeEntry.Duration__c != null)
				hrs = timeEntry.Duration__c;
			
			Invoice__c invoice = new Invoice__c();
			//TODO : If create Single invoice then get from mapAccountInvoice
			if(createSingleInvoice && mapAccInvoice != null && mapAccInvoice.containsKey(timeEntry.HarvestProject__r.Account__c)){
				invoice = mapAccInvoice.get(timeEntry.HarvestProject__r.Account__c);
			}
			else if(!createSingleInvoice && mapProjectInvoice != null && mapProjectInvoice.containsKey(timeEntry.HarvestProject__c))
				invoice  = mapProjectInvoice.get(timeEntry.HarvestProject__c);
			
			system.debug('****invoice*'+invoice);
			//Special Case - If the Task is present in Custom setting then for multiple records create a single Line item
			//if(Merging_Time_Entry_Setting__c.getInstance(timeEntry.Task_Type__c) != null ){
			if(timeEntry.Task_Type__c != null && timeEntry.Task_Type__c != '' && taskTypeToMerge.size() > 0 && 
															 taskTypeToMerge.contains(timeEntry.Task_Type__c.toLowerCase()) ){
				
				if(lineItemMap.isEmpty() || (!lineItemMap.isEmpty() && 
											 !lineItemMap.containsKey(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c))){
					
					lineItemMap.put(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c,new Line_Item__c(Contractor__c = timeEntry.Developer_Company__c,
										//			 Invoice_Line_Item_Summary__c =  mapSummary.containsKey(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c) ? 
										//			 									mapSummary.get(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c).id :
										//			 										null,
													 Task_Type__c = timeEntry.Task_Type__c,
													 Task_Harvest__c = timeEntry.Task_Type__c,
													 Invoice__c =  invoice.Id,
													 Time_Entry__c = timeEntry.Id,
													 Developer_Name__c = timeEntry.Developer_Name__c ,
													 Opportunity__c = invoice.Opportunity__c,
													 Description__c = getTaskDescription(timeEntry.Task_Type__c,timeEntry.Notes__c),
													 Date__c = objDate,
													 Credit_Hrs__c=timeEntry.Credit_Hrs__c,
													 Hours_Num__c = hrs
													  ));
					
					//Track the Time entry which is credited for the task type
					timeEntryCreditedMap.put(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c,timeEntry.Id);
				}
				//For duplicate record of same Date
				else if(!lineItemMap.isEmpty() && 
							lineItemMap.containsKey(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c)){
					
					Line_Item__c lineItem = lineItemMap.get(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c);
					
					// Compare for the highest record if the current time entry has more hrs then add it 
					if( (lineItem.Hours_Num__c != null && lineItem.Hours_Num__c < hrs ) ||
							(lineItem.Finish__c != null && lineItem.Start__c != null && 
							 (lineItem.Finish__c.getTime()  - lineItem.Start__c.getTime()) / (1000.0*60.0*60.0) < hrs ) ){
							
							//Enter the current Time entry to line Item 
							lineItem.Time_Entry__c = timeEntry.Id;
							lineItem.Date__c = objDate;
							lineItem.Hours_Num__c = hrs;
							lineItem.Developer_Name__c = timeEntry.Developer_Name__c ;
							lineItem.Credit_Hrs__c = timeEntry.Credit_Hrs__c;
							lineItem.Description__c =  getTaskDescription(timeEntry.Task_Type__c,timeEntry.Notes__c) ;  
							// Fetch the previous time entry and Update its credit Reson as it is not credited
							if(timeEntryCreditedMap.size() > 0 && 
								 timeEntryCreditedMap.containsKey(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c) &&
								 timeEntryToBeUpdatedMap.containsKey(timeEntryCreditedMap.get(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c))){
								 
								 if( timeEntryNotCreditedMap.size() == 0|| (timeEntryNotCreditedMap.size() > 0 && 
								 	!timeEntryNotCreditedMap.containsKey(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c))){
								 	timeEntryNotCreditedMap.put(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c,
								 							 new list<Id>{timeEntryCreditedMap.get(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c)});
								 }else{
								 	timeEntryNotCreditedMap.get(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c).add(timeEntryCreditedMap.get(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c));
								 }
								 timeEntryCreditedMap.put(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c,timeEntry.Id);
							}
					}//Else if it has lowest hrs do not credit the line item, mention the credit reason and save link to credited time Entry
					else if(timeEntryCreditedMap.size() > 0 &&
							timeEntryCreditedMap.containsKey(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c)){
							
						if( timeEntryNotCreditedMap.size() == 0|| (timeEntryNotCreditedMap.size() > 0 && 
								 	!timeEntryNotCreditedMap.containsKey(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c))){
							timeEntryNotCreditedMap.put(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c,
								 						new list<Id>{timeEntry.Id});
						}else{
							timeEntryNotCreditedMap.get(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c).add(timeEntry.Id);
						}
					}
					
					lineItemMap.put(invoice.id+timeEntry.Task_Type__c +objDate+timeEntry.HarvestProject__c,lineItem);
				}					
				
			}else{
				lineItemToBeCreated.add(new Line_Item__c(Contractor__c = timeEntry.Developer_Company__c,
									//				 Invoice_Line_Item_Summary__c = mapSummary.containsKey(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c) ? 
									//				 									mapSummary.get(invoice.id+timeEntry.Task_Type__c+objDate+timeEntry.HarvestProject__c).id :
									//				 										null,
													 Task_Type__c = timeEntry.Task_Type__c,
													 Task_Harvest__c = timeEntry.Task_Type__c,
													 // getTaskType(timeEntry.Task_Type__c),
													 Invoice__c =  invoice.Id,
													 Time_Entry__c = timeEntry.Id,
													 Developer_Name__c = timeEntry.Developer_Name__c ,
													 Opportunity__c = invoice.Opportunity__c,
													 Description__c = getTaskDescription(timeEntry.Task_Type__c,timeEntry.Notes__c),
													 Credit_Hrs__c = timeEntry.Credit_Hrs__c,
													 Date__c = objDate,
													 Hours_Num__c = hrs
													  ));
			}
			//Update Time Entry
			//All time entry records against which Invoice Line Item records are created will be marked as 'Invoiced by CMB'.
			timeEntry.Invoiced_by_CMB__c = true;
			timeEntryToBeUpdatedMap.put(timeEntry.id,timeEntry);
		}
		
		timeEntryToBeUpdatedMap = updateCreditReason(timeEntryCreditedMap,timeEntryNotCreditedMap,timeEntryToBeUpdatedMap);
		
		if(lineItemMap.size() > 0)
			insert lineItemMap.values();
				
		if(lineItemToBeCreated.size() > 0)
			insert lineItemToBeCreated;
			
		if(timeEntryToBeUpdatedMap.size() > 0)
			update timeEntryToBeUpdatedMap.values();
	}
	
	/* Function to fetch all the Time Entry records for Selected Projects and in given Date Range 
	 * and where Invoiced By CMB is False
	 */
	private void populateTimeEntries(){
		
		Date DateCompleted;
		if(project.DateCompleted__c != null && project.DateCompleted__c.month() != 12)
			DateCompleted = Date.newInstance(project.DateCompleted__c.year(), project.DateCompleted__c.month()+1, 1);
		else if(project.DateCompleted__c != null)
			DateCompleted = Date.newInstance(project.DateCompleted__c.year()+1, 1, 1);
		
		//fetch all the Time Entry records for the selected Projects
		timeEntryList =	[Select Date__c,
								Notes__c,
								Duration__c,
								Hours__c,
								EndTime__c,
								StartTime__c,
								Task_Type__c,
								HarvestProject__c,
								Credit_Hrs__c,								
								HarvestProject__r.Account__c,
								Developer_Name__c,
								Developer_Company__c
						 From 	HarvestTimeEntry__c  
						 where HarvestProject__c IN: selectedProjects and
						 	   Invoiced_by_CMB__c = false
						 		and ((StartTime__c >=: project.DateStarted__c and
								EndTime__c <=: DateCompleted) or 
								( Date__c >=: Date.valueOf(project.DateStarted__c) and	
								  Date__c <=: Date.valueOf(project.DateCompleted__c))) ];
	}
	
	//Function to update the Credit Reason of the Time Entries which are not Credited,also link the record which is credited
	private map<Id,HarvestTimeEntry__c> updateCreditReason(map<String, Id> timeEntryCreditedMap,
												  map<String, list<Id>> timeEntryNotCreditedMap,
												  map<Id,HarvestTimeEntry__c> timeEntryToBeUpdatedMap){
							
		for(String key : timeEntryNotCreditedMap.keySet()){
			for(Id timeEntryId : timeEntryNotCreditedMap.get(key)){
				
				if(timeEntryCreditedMap.size() > 0 && timeEntryCreditedMap.containsKey(key) && 
													timeEntryToBeUpdatedMap.containsKey(timeEntryId)){
					
					HarvestTimeEntry__c timeEntry = timeEntryToBeUpdatedMap.get(timeEntryId);
					timeEntry.Credit_Reason__c = creditReason;
					timeEntry.Invoiced_Time_Entry__c = timeEntryCreditedMap.get(key);
					timeEntryToBeUpdatedMap.put(timeEntry.Id,timeEntry);
				}
			}
			
		}	
		return timeEntryToBeUpdatedMap;
	}
	
	//Function used to replace String in specific task type 
	private String getTaskDescription(String taskType ,String description){
		//if(Replace_words_Setting__c.getInstance(taskType) != null){
		if(taskType != null && taskType != '' && replacementSettingMap.size() > 0 ){
												// replacementSettingMap.containsKey(taskType.toLowerCase())){
			
			if(description != null && description != ''){
				for(String replacementSetting : replacementSettingMap.keySet()){
					while(description.containsIgnoreCase(replacementSetting)){
						Integer index = description.toLowerCase().indexOf(replacementSetting.toLowerCase());
						description = description.replace(description.substring(index, index+replacementSetting.length()), 
														  replacementSettingMap.get(replacementSetting));
					}	
					
				}
				return description;
			}
			else
				return '';
		}
		return description;
	}
	
	//Function used to populate a map of replacement setting values 
	private void populateReplacementSetting(){
		
		for(Replace_words_Setting__c replacementSetting: Replace_words_Setting__c.getall().values()){
			replacementSettingMap.put(replacementSetting.String__c.toLowerCase(),replacementSetting.Replacement__c);
		}
	}
	
	//Function used to populate all the Task type in a set for which only 1 Line item will get created  
	private void populateMergeTaskType(){
		for(Merging_Time_Entry_Setting__c mergeSetting: Merging_Time_Entry_Setting__c.getall().values()){
			taskTypeToMerge.add(mergeSetting.Task_Type__c.toLowerCase());
		}
	}
	
	//Wrapper Class contains Project Object and isSelected to keep track of which project is selected 
	public class ProjectWrapper{
		public HarvestProject__c prjct 	{get; set;}
		public boolean isSelected 		{get; set;}
		public decimal totalHrs 		{get; set;}
		
		public ProjectWrapper(HarvestProject__c project ,Boolean pIsSelected, decimal pTotalHrs){
			prjct = project;
			isSelected = pIsSelected;
			totalHrs = pTotalHrs; 
		}
	}
}