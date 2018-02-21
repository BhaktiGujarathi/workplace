/******************************************************************************************
 *  Author   : Ravindra Babu Nagaboina
 *  Company  : NSI DMCC
 *  Date     : 03rd Jan 2017                        
 ------------------------------------------------------------------------------------------
 Modification History 
 ----------------------------------------------------------------------------------------
 V.No   Date            Updated By          Description
 ----------------------------------------------------------------------------------------              
 V1.0  03/Jan/2016      Ravi                Created
 V1.1  08/Jan/2016      Charan              Added sobject at line 85 for Inquiry   
 V1.2  10/Jan/2016      Charan              Added sobject at line 88 for Account   
*******************************************************************************************/
public with sharing class TriggerFactoryCls {
    
    private static Boolean BYPASS_UPDATE_TRIGGER = false; 
    
    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Schema.sObjectType soType - Object type to process (SObject.sObjectType)
     *
     * Throws a TriggerException if no handler has been coded.
     */
    public static void createHandler(Schema.sObjectType soType){
        TriggerFactoryInterface handler = getHandler(soType);
        if (handler == null){
            throw new CustomException('No Trigger Handler registered for Object Type: ' + soType);
        }
        try{
            execute(handler);
        }catch(Exception ex){
            throw new CustomException('Exception in Handler '+ex.getMessage()+ex.getLineNumber()); 
        }
    }
    
    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */ 
    private static void execute(TriggerFactoryInterface handler){
        if(trigger.isBefore){
            if(trigger.isInsert){
                handler.executeBeforeInsertTrigger(trigger.new);
            }else if(trigger.isUpdate){
                if(!BYPASS_UPDATE_TRIGGER){
                    handler.executeBeforeUpdateTrigger(trigger.newMap, trigger.oldMap);
                }
            }else if(trigger.isDelete){
                handler.executeBeforeDeleteTrigger(trigger.oldMap);
            }else if(trigger.isInsert || trigger.isUpdate){
                handler.executeBeforeInsertUpdateTrigger(trigger.new, trigger.oldMap);
            }else{
                
            }
        }else{
            if(trigger.isInsert){
                handler.executeAfterInsertTrigger(trigger.newMap);
            }else if(trigger.isUpdate){
                if(!BYPASS_UPDATE_TRIGGER){
                    handler.executeAfterUpdateTrigger(trigger.newMap, trigger.oldMap);
                }
            }else if(trigger.isDelete){
                handler.executeAfterDeleteTrigger(trigger.oldMap);
            }else if(trigger.isInsert || trigger.isUpdate){
                handler.executeAfterInsertUpdateTrigger(trigger.newMap, trigger.oldMap);
            }else{
                
            }
        }
    }
    
    /**
     * private static method to get the appropriate handler for the object type.
     * Modify this method to add any additional handlers.
     *
     * Arguments:   Schema.sObjectType soType - Object type tolocate (SObject.sObjectType)
     *
     * Returns:     ITrigger - A trigger handler if one exists or null.
     */
    private static TriggerFactoryInterface getHandler(Schema.sObjectType soType){
        if(soType == NSIBPM__Service_Request__c.sObjectType){
            return new ServiceRequestTrgHandler();
        }else if(soType == Location__c.sObjectType){
            return new LocationTrgHandler();
        }else if(soType == Inventory__c.sObjectType){
            return new InventoryTrgHandler();
        }else if(soType == Inquiry__c.sObjectType){
           return new InquiryTriggerHandler();
        }else if(soType == Account.sObjectType){
            return new AccountTrgHandler(); 
        }else if(soType == Event.sObjectType){
            return new EventTriggerHandler(); 
        }else if(soType == Task.sObjectType){
            return new TaskTriggerHandler(); 
        }else if(soType == JO_Campaign_Virtual_Number__c.sObjectType){
            return new CampaignVirtualNumberTriggerHandler(); 
        }else if(soType == User.sObjectType){ 
            return new UserTriggerHandler(); 
        }else if(soType == Assigned_PC__c.sObjectType){
            return new AssignedPcTriggerHandler(); 
        }else if(soType == Agency_PC__c.sObjectType){
            return new AgencyPCTriggerHandler(); 
        }else if(soType == Inventory_Release__c.sObjectType){
            return new InventoryReleaseTriggerHandler(); 
        }else if(soType == Address__c.sObjectType){
            return new AddressTriggerHandler(); 
        }else if(soType == Inventory_User__c.sObjectType){
            return new InventoryUserTriggerHandler(); 
        }else if(soType == Assigned_Agent__c.sObjectType){
            return new AssignedAgentTriggerHandler(); 
        }else if(soType == Attachment.sObjectType){
            return new AttachmentTriggerHandler(); 
        }else if(soType == Contact.sObjectType){
            return new ContactTriggerHandler(); 
        }else if(soType == Team_Building__c.sObjectType){
            return new TeamBuildingTriggerHandler(); 
        }else if(soType == Payment_Terms__c.sObjectType){
            return new PaymentTermsTriggerHandler(); 
        }else if(soType == Campaign_Inventory__c.sObjectType){
            return new CampaignInventoryTriggerHandler();
        }else if(soType == Agent_Commission__c.sObjectType){
            return new CommissionTriggerHandler();
        }else if(soType == deal_team__c.sObjectType){
            return new DealTeamTrgHandler();
        }else if(soType == Buyer__c.sObjectType){
            return new BuyerTrgHandler();
        }else if(soType == NSIBPM__SR_Doc__c.sObjectType){
            return new SRDocTrgHandler();
        }       
        
        return null;
    }
    
    /*Trigger Handler for Inquiry.*/
    public static Boolean getBYPASS_UPDATE_TRIGGER(){
        return BYPASS_UPDATE_TRIGGER;
    }
    
    public static void setBYPASS_UPDATE_TRIGGER(){
        BYPASS_UPDATE_TRIGGER = true;   
    }
    
    public static void resetBYPASS_UPDATE_TRIGGER(){
        BYPASS_UPDATE_TRIGGER = false;  
    }
}// End of class.