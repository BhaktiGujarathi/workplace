/**************************************************************************************************
* Name               : DamacCompanyProfileController                                               
* Description        : An apex page controller for                                              
* Created Date       : NSI - Diana                                                                        
* Created By         : 30/Jan/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          30/Jan/2017                                                               
**************************************************************************************************/
public with sharing class DamacCompanyProfileController {
    /**************************************************************************************************
    Variables used in the class
    **************************************************************************************************/
    
    public List<Contact> amendments{set;get;}
    public Account accountDetail{set;get;}
    
    public string registrationUpdatePageID{set;get;}
    public boolean isSRPending{set;get;}
    public String serviceRequestID{set;get;}
    private NSIBPM__Service_Request__c serviceRequest;
    public boolean isError {get;set;}
    
    /**************************************************************************************************
    Method:         DamacCompanyProfileController
    Description:    Constructor executing model of the class 
    **************************************************************************************************/
    
    public DamacCompanyProfileController() {
        try{
            isError = false;
            Id accountId = UtilityQueryManager.getAccountId();
            /*if(null == accountId){
                accountId = apexpages.currentpage().getParameters().get('Accid');
            }*/
            amendments = new List<Contact>();
            amendments = UtilityQueryManager.getAllContacts(accountId);
            
            accountDetail = new Account();
            accountDetail = UtilityQueryManager.getCompanyProfileDetail(accountId);

            
            registrationUpdatePageID = UtilityQueryManager.getProcessFlowId(LABEL.Agent_Portal_Registration_Update_Page_Flow_Name);
            
            serviceRequest = UtilityQueryManager.checkPendingSR(accountId);
            
            if(null != serviceRequest){
                isSRPending = true;
                serviceRequestID = serviceRequest.Id;
            }
        }
        catch(exception ex){
            isError = true;
        }
    }
    
    public pagereference init(){
        Pagereference pg = null;
        if(isError){  
            System.debug('**INSIDE INIT**');
            Id accountId = apexpages.currentpage().getParameters().get('Accid');
            serviceRequest = UtilityQueryManager.checkPendingSR(accountId);
            if(null != serviceRequest)
            	pg = new Pagereference('/'+serviceRequest.id);
        }
        return pg;
    }
}