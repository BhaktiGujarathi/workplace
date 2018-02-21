/**
*/
public with sharing class CountEstimatedHoursforProjectController 
{	
	public Map<Id,HarvestProject__c> oldmapProject = new Map<Id,HarvestProject__c>();
	public Map<Id,List<Estimates__c>> oldmapProjectEstimate = new Map<Id,List<Estimates__c>>();
	public Map<Id,List<Estimates__c>> mapProjectEstimate = new Map<Id,List<Estimates__c>>();
	public List<HarvestProject__c> projectToUpdate = new List<HarvestProject__c>();
	public Map<Id,HarvestProject__c> mapprojectToUpdate = new Map<Id,HarvestProject__c>();
	public set<Id> setProjects = new set<Id>();
	public Map<Id,HarvestProject__c> mapProject = new Map<Id,HarvestProject__c>();
	
	public void getProjects(List<Estimates__c> lstEstimates, List<Estimates__c> oldListEstimates)
	{
		for(Estimates__c estimate:lstEstimates)
		{			
				if(estimate.Harvest_Projects__c!=null )
				{				
					setProjects.add(estimate.Harvest_Projects__c);			
					if(mapProjectEstimate.size()==0||(mapProjectEstimate.size()>0 && !mapProjectEstimate.containsKey(estimate.Harvest_Projects__c)))			
						mapProjectEstimate.put(estimate.Harvest_Projects__c,new List<Estimates__c>{estimate});	
					else
					{
						mapProjectEstimate.get(estimate.Harvest_Projects__c).add(estimate);
					}	
				}				
		}
		mapProject = new Map<Id,HarvestProject__c>([Select h.Id, h.Estimated_Hours__c, h.Total_Estimated_Hrs_Developer__c 
													From HarvestProject__c h where h.Id in: setProjects]);
		if(oldListEstimates != null)
		{			
			for(Estimates__c estimate:oldListEstimates)
			{
					if(estimate.Harvest_Projects__c!=null)
					{
						setProjects.add(estimate.Harvest_Projects__c);			
						if(oldmapProjectEstimate.size()==0||(oldmapProjectEstimate.size()>0 && !oldmapProjectEstimate.containsKey(estimate.Harvest_Projects__c)))			
							oldmapProjectEstimate.put(estimate.Harvest_Projects__c,new List<Estimates__c>{estimate});	
						else
						{
							oldmapProjectEstimate.get(estimate.Harvest_Projects__c).add(estimate);
						}	
					//}
				}
			}
			oldmapProject = new Map<Id,HarvestProject__c>([Select h.Id, h.Estimated_Hours__c, h.Total_Estimated_Hrs_Developer__c 
															From HarvestProject__c h where h.Id in: setProjects]);		
				
		}
	}
	public void onInsert(List<Estimates__c> lstEstimates, string status)
	{		
		
		getProjects(lstEstimates,null);		
		
		for(Id objproject:mapProjectEstimate.keySet())
		{
			HarvestProject__c project = mapProject.get(objproject);
			if(project.Estimated_Hours__c == null)
			{
				project.Estimated_Hours__c = 0;				
			}
			if(project.Total_Estimated_Hrs_Developer__c == null)
			{
				project.Total_Estimated_Hrs_Developer__c = 0;
			}
			for(Estimates__c objEstimate:mapProjectEstimate.get(objproject))
			{	
				if(objEstimate.Include_in_Rollup__c)
				{
					Decimal tempEstimateHr =0.0;
					Decimal newtempEstimateHr = 0.0;
					if(objEstimate.Estimates_Hours__c != null)
					{
						tempEstimateHr = objEstimate.Estimates_Hours__c;
					}
					if(objEstimate.Estimated_Hrs_Developer__c != null)
					{
						newtempEstimateHr = objEstimate.Estimated_Hrs_Developer__c;
					}
					if(status=='insert')
					{
						project.Estimated_Hours__c += tempEstimateHr;//objEstimate.Estimates_Hours__c;
						project.Total_Estimated_Hrs_Developer__c += newtempEstimateHr;
					}
					else
					{
						project.Estimated_Hours__c -= tempEstimateHr;//objEstimate.Estimates_Hours__c;
						project.Total_Estimated_Hrs_Developer__c -= newtempEstimateHr;
						if(project.Estimated_Hours__c <= 0)
							project.Estimated_Hours__c = 0;
						if(project.Total_Estimated_Hrs_Developer__c <= 0)
							project.Total_Estimated_Hrs_Developer__c = 0;
					}
				}
			}
			projectToUpdate.add(project);
		}	
		update projectToUpdate;
	}	
	
	public void onUpdate(List<Estimates__c> newlstEstimates, Map<Id,Estimates__c> oldMapEstimates)
	{
		getProjects(newlstEstimates, oldMapEstimates.values());
		
		HarvestProject__c oldproject ;
		HarvestProject__c project  ;
						
		for(Id objproject:mapProjectEstimate.keySet())
		{
			project = mapProject.get(objproject);
			if(project.Estimated_Hours__c == null)
			{
				project.Estimated_Hours__c = 0;
			}
			if(project.Total_Estimated_Hrs_Developer__c == null)
			{
				project.Total_Estimated_Hrs_Developer__c = 0.0;
			}
			for(Estimates__c objEstimate:mapProjectEstimate.get(objproject))
			{	
				if(objEstimate.Include_in_Rollup__c)
				{
					system.debug('$$$$$$inside if');					
					if(objEstimate.Harvest_Projects__c != oldMapEstimates.get(objEstimate.Id).Harvest_Projects__c)
					{// update Estimated Hours and Total Estimated hrs(Developer) of Corresponding Harvst Project - on change of Harvest Project and Estimate Hours of Estimates
						if(mapprojectToUpdate.isEmpty() || !mapprojectToUpdate.containsKey((oldmapProject.get(oldMapEstimates.get(objEstimate.Id).Harvest_Projects__c).Id)))
						{
					    	oldproject = oldmapProject.get(oldMapEstimates.get(objEstimate.Id).Harvest_Projects__c);
						}							
						else
						    oldproject = mapprojectToUpdate.get((oldmapProject.get(oldMapEstimates.get(objEstimate.Id).Harvest_Projects__c).Id));
						
						Decimal tempEstimateHr =0.0;
						Decimal temp1EstimateHr =0.0;
						if(objEstimate.Estimates_Hours__c != null)
						{
							tempEstimateHr = objEstimate.Estimates_Hours__c;
						}
						if(objEstimate.Estimated_Hrs_Developer__c != null)
						{
							temp1EstimateHr = objEstimate.Estimated_Hrs_Developer__c;
						}
						project.Estimated_Hours__c += tempEstimateHr;
						project.Total_Estimated_Hrs_Developer__c +=temp1EstimateHr;
						system.debug('$$$$$$$$$$$$$project)'+project);
						//add to new project							
						
						system.debug('$$$$$$$$$$$$$oldproject)'+oldproject);
						if(oldproject != null)	
						{
							Decimal oldtempEstimateHr =0.0;
							Decimal oldtemp1EstimateHr =0.0;
							if(oldMapEstimates.get(objEstimate.Id).Estimates_Hours__c != null)
							{
								oldtempEstimateHr = oldMapEstimates.get(objEstimate.Id).Estimates_Hours__c;
							}
							if(oldMapEstimates.get(objEstimate.Id).Estimated_Hrs_Developer__c != null)
							{
								oldtemp1EstimateHr = oldMapEstimates.get(objEstimate.Id).Estimated_Hrs_Developer__c;
							}
							oldproject.Estimated_Hours__c -= oldtempEstimateHr;
							oldproject.Total_Estimated_Hrs_Developer__c -= oldtemp1EstimateHr;
							if(oldproject.Estimated_Hours__c <= 0)
							oldproject.Estimated_Hours__c = 0;
							if(oldproject.Total_Estimated_Hrs_Developer__c <= 0)
							oldproject.Total_Estimated_Hrs_Developer__c = 0;
						}							
						
						mapprojectToUpdate.put(project.Id,project);	
					}
					else if(objEstimate.Estimates_Hours__c != oldMapEstimates.get(objEstimate.Id).Estimates_Hours__c || objEstimate.Estimated_Hrs_Developer__c != oldMapEstimates.get(objEstimate.Id).Estimated_Hrs_Developer__c)// && newEstimate.Harvest_Projects__c == oldMapEstimates.get(newEstimate.Id).Harvest_Projects__c)
					{// update Estimated Hours of Corresponding Harvest Project - on change of Estimates Hours of Estimates
						system.debug('******** On Update- change in Estimate hours');
						if(objEstimate.Estimates_Hours__c != oldMapEstimates.get(objEstimate.Id).Estimates_Hours__c)
						{
							Decimal tempEstimateHr =0.0;
							Decimal temp1EstimateHr =0.0;
							if(objEstimate.Estimates_Hours__c != null)
							{
								tempEstimateHr = objEstimate.Estimates_Hours__c;
							}
							if(oldMapEstimates.get(objEstimate.Id).Estimates_Hours__c != null)
							{
								temp1EstimateHr = oldMapEstimates.get(objEstimate.Id).Estimates_Hours__c;
							}
							project.Estimated_Hours__c += (tempEstimateHr-temp1EstimateHr);				
							if(project.Estimated_Hours__c <= 0)
							project.Estimated_Hours__c = 0;
							mapprojectToUpdate.put(project.Id,project);
						}
						if(objEstimate.Estimated_Hrs_Developer__c != oldMapEstimates.get(objEstimate.Id).Estimated_Hrs_Developer__c)// && newEstimate.Harvest_Projects__c == oldMapEstimates.get(newEstimate.Id).Harvest_Projects__c)
						{// update Estimated Hrs(Developer) of Corresponding Harvest Project - on change of Estimated Hrs(Developer) of Estimates
							system.debug('******** On Update- change in Estimate hours');
							Decimal newtempEstimateHr =0.0;
							Decimal newtemp1EstimateHr =0.0;
							if(objEstimate.Estimated_Hrs_Developer__c != null)
							{
								newtempEstimateHr = objEstimate.Estimated_Hrs_Developer__c;
							}
							if(oldMapEstimates.get(objEstimate.Id).Estimated_Hrs_Developer__c != null)
							{
								newtemp1EstimateHr = oldMapEstimates.get(objEstimate.Id).Estimated_Hrs_Developer__c;
							}
							project.Total_Estimated_Hrs_Developer__c += (newtempEstimateHr-newtemp1EstimateHr);				
							if(project.Estimated_Hours__c <= 0)
							project.Estimated_Hours__c = 0;
							mapprojectToUpdate.put(project.Id,project);
						}
					}
					
					else if(objEstimate.Harvest_Projects__c == oldMapEstimates.get(objEstimate.Id).Harvest_Projects__c )
					{
						if(objEstimate.Include_in_Rollup__c != oldMapEstimates.get(objEstimate.Id).Include_in_Rollup__c && objEstimate.Include_in_Rollup__c)
						{	//on update- if checkbox is checked and project is same
							Decimal tempEstimateHr =0.0;
							Decimal newtempEstimateHr =0.0;
							if(objEstimate.Estimates_Hours__c != null)
							{
								tempEstimateHr = objEstimate.Estimates_Hours__c;
							}
							if(objEstimate.Estimated_Hrs_Developer__c != null)
							{
								newtempEstimateHr = objEstimate.Estimated_Hrs_Developer__c;
							}						
							project.Estimated_Hours__c += tempEstimateHr;	
							project.Total_Estimated_Hrs_Developer__c += newtempEstimateHr;
						}
						if(project.Estimated_Hours__c <= 0)
							project.Estimated_Hours__c = 0;
						mapprojectToUpdate.put(project.Id,project);
					}
				}// end of if - objEstimate.Include_in_Rollup__c
				else 
				{
					if(objEstimate.Harvest_Projects__c == oldMapEstimates.get(objEstimate.Id).Harvest_Projects__c)
					{						
						Decimal tempEstimateHr =0.0;
						Decimal newtempEstimateHr =0.0;
						if(objEstimate.Estimates_Hours__c != null)
						{
							tempEstimateHr = objEstimate.Estimates_Hours__c;
						}
						if(objEstimate.Estimated_Hrs_Developer__c != null)
						{
							newtempEstimateHr = objEstimate.Estimated_Hrs_Developer__c;
						}
						Decimal oldtempEstimateHr =0.0;
						Decimal oldtemp1EstimateHr =0.0;
						if(oldMapEstimates.get(objEstimate.Id).Estimates_Hours__c != null)
						{
							oldtempEstimateHr = oldMapEstimates.get(objEstimate.Id).Estimates_Hours__c;
						}
						if(oldMapEstimates.get(objEstimate.Id).Estimated_Hrs_Developer__c != null)
						{
							oldtemp1EstimateHr = oldMapEstimates.get(objEstimate.Id).Estimated_Hrs_Developer__c;
						}
						if(objEstimate.Include_in_Rollup__c != oldMapEstimates.get(objEstimate.Id).Include_in_Rollup__c)
						{
							project.Estimated_Hours__c -= oldtempEstimateHr;
							project.Total_Estimated_Hrs_Developer__c -= oldtemp1EstimateHr;
						}
						else
						{	
							if(objEstimate.Estimates_Hours__c!=oldMapEstimates.get(objEstimate.Id).Estimates_Hours__c)
							project.Estimated_Hours__c -= tempEstimateHr;
							if(objEstimate.Estimated_Hrs_Developer__c!=oldMapEstimates.get(objEstimate.Id).Estimated_Hrs_Developer__c)
							project.Total_Estimated_Hrs_Developer__c -= newtempEstimateHr;
						}
						if(project.Estimated_Hours__c <= 0)
							project.Estimated_Hours__c = 0;
						if(project.Total_Estimated_Hrs_Developer__c <= 0)
							project.Total_Estimated_Hrs_Developer__c = 0;
						mapprojectToUpdate.put(project.Id,project);
					}
					if(objEstimate.Harvest_Projects__c != oldMapEstimates.get(objEstimate.Id).Harvest_Projects__c)
					{
						Decimal oldtempEstimateHr =0.0;
						Decimal oldtemp1EstimateHr =0.0;
						if(oldMapEstimates.get(objEstimate.Id).Estimates_Hours__c != null)
						{
							oldtempEstimateHr = oldMapEstimates.get(objEstimate.Id).Estimates_Hours__c;
						}
						if(oldMapEstimates.get(objEstimate.Id).Estimated_Hrs_Developer__c != null)
						{
							oldtemp1EstimateHr = oldMapEstimates.get(objEstimate.Id).Estimated_Hrs_Developer__c;
						}
						oldproject = oldmapProject.get(oldMapEstimates.get(objEstimate.Id).Harvest_Projects__c);
						if(oldproject!=null)
						{
							oldproject.Estimated_Hours__c -= oldtempEstimateHr;
							oldproject.Total_Estimated_Hrs_Developer__c -= oldtemp1EstimateHr;
							if(oldproject.Estimated_Hours__c <= 0)
								oldproject.Estimated_Hours__c = 0;
							if(oldproject.Total_Estimated_Hrs_Developer__c <= 0)
								oldproject.Total_Estimated_Hrs_Developer__c = 0;
							mapprojectToUpdate.put(oldproject.Id,oldproject);
						}
					}
				}
				
			}// End of for - Estmiates
			
			if(oldproject!= null && (mapprojectToUpdate.isEmpty() || (!mapprojectToUpdate.isEmpty() && !mapprojectToUpdate.containsKey(oldproject.Id))))
			{ // if map is empty or not already contains oldproject object				
				mapprojectToUpdate.put(oldproject.Id,oldproject);
				mapprojectToUpdate.put(project.Id,project);				
			}			
			system.debug('$$$$$$$$$$$$$mapprojectToUpdate'+mapprojectToUpdate);
		}// End of for - project		
		update mapprojectToUpdate.values();
	}//End of function
}// End of Class