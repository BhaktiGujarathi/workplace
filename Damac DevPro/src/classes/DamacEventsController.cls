/**************************************************************************************************
* Name               : DamacAnnouncementsController                                               
* Description        : An apex page controller for showing all active events                                             
* Created Date       : NSI - Diana                                                                        
* Created By         : 11/Feb/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          11/Feb/2017                                                               
**************************************************************************************************/
public without sharing class DamacEventsController {
    /**************************************************************************************************
            Variables used in the class
    **************************************************************************************************/
    public List<AssignedAgentWrapper> allevents{set;get;}
    private static Map<Integer, String> monthsMap = new Map<Integer, String>{
      1=>'Jan',
      2=>'Feb',
      3=>'Mar',
      4=>'Apr',
      5=>'May',
      6=>'Jun',
      7=>'Jul',
      8=>'Aug',
      9=>'Sep',
      10=>'Oct',
      11=>'Nov',
      12=>'Dec'
    };
    
    /**************************************************************************************************
    Method:         DamacEventsController
    Description:    Constructor executing model of the class 
    **************************************************************************************************/
    public DamacEventsController() {
        allevents = new List<AssignedAgentWrapper>();
        List<Assigned_Agent__c> assignedEvents = UtilityQueryManager.getAllCampaigns();
        for(Assigned_Agent__c thisAssignedAgent:assignedEvents){
            Integer startDay;
            String startMonth = '';
            Integer endDay;
            String endMonth = '';
            
            if(null != thisAssignedAgent.Start_Date__c){
                startDay = thisAssignedAgent.Start_Date__c.day();
                startMonth = monthsMap.get(thisAssignedAgent.Start_Date__c.month());
            } 
            
             if(null != thisAssignedAgent.End_Date__c){
                endDay= thisAssignedAgent.End_Date__c.day();
                endMonth= monthsMap.get(thisAssignedAgent.End_Date__c.month());
            } 
            
            String campaignLocation = '';
            
            if(null!= thisAssignedAgent.Campaign__r.Campaign_Location__c)
                campaignLocation  = thisAssignedAgent.Campaign__r.Campaign_Location__c.replace(';',',');
            
            if(null != thisAssignedAgent.Campaign__r){   
                AssignedAgentWrapper assignedWrapper = new AssignedAgentWrapper(thisAssignedAgent.Campaign_Name__c,
                thisAssignedAgent.Start_Date__c,thisAssignedAgent.End_Date__c,startDay,startMonth,endDay,endMonth,
                thisAssignedAgent.Campaign__r.Campaign_Description__c, campaignLocation 
                );
                allevents.add(assignedWrapper);
            }
        }
    }

    public class AssignedAgentWrapper{
        public String campaignName{set;get;}
        public Date campaignStartDate{set;get;}
        public Date campaignEndDate{set;get;}
        public Integer campaignStartDay{set;get;}
        public String campaignStartMonth{set;get;}
        public Integer campaignEndDay{set;get;}
        public String campaignEndMonth{set;get;}
        public String campaignDescription{set;get;}
        public String campaignLocation{set;get;}

        public AssignedAgentWrapper(String campaignName, Date campaignStartDate, Date campaignEndDate,Integer campaignStartDay,String campaignStartMonth,
            Integer campaignEndDay,String campaignEndMonth, String campaignDescription, String campaignLocation){
            this.campaignName = campaignName;
            this.campaignStartDate = campaignStartDate;
            this.campaignEndDate = campaignEndDate;
            this.campaignStartDay = campaignStartDay;
            this.campaignStartMonth = campaignStartMonth;
            this.campaignEndDay = campaignEndDay;
            this.campaignEndMonth = campaignEndMonth;
            this.campaignDescription = campaignDescription;
            this.campaignLocation = campaignLocation;
        }
    }
}