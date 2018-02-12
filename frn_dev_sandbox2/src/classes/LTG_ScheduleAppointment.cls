/**
* Class LTG_ScheduleAppointment
*
* Class LTG_ScheduleAppointment for the LTG_Schedule_Appointment VF page. This class implements the functionality
* to Schedule Appointment of Opportunity.
*/
public class LTG_ScheduleAppointment
{
    public Opportunity newOpportunity;
    public LTG_ScheduleAppointment(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();        
    }
    
    public LTG_ScheduleAppointment() {   
    }
    
    public PageReference LTG_ScheduleAppointment() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {  
            string str = OpportunityIOPFinalizeService.triggerOpportunityFinalization(newOpportunity.Id);
            string statusFlag = str.substring(str.indexOf('#'),str.length());            
            if(statusFlag.indexOf('Successful') == 1) 
            {                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Opportunity successfully updated'));               
                str = str.substring(0, str.indexOf('#'));
            }else { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Failes to update the opportunity record. Please verify Opportunity and related Quotes records'));    
                str = string.valueof(newOpportunity.Id); 
            } 
            PageReference pageRef;           
            pageRef= new PageReference('/'+str);
            pageRef.setRedirect(true);
            return pageRef;
          
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            System.debug('<<<<<<<<<<<<<< Record is locked <<<<<<<<<<<<<<<<'+isLockedFlag);
            return null;
        }
    }
}