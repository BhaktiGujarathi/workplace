/**************************************************************************************************
* Name               : AsyncOptionWebservice
* Description        :


* Created Date       : 05/07/2017
* Created By         : Naresh Kaneriya (Accely)
**************************************************************************************************/
public class AsyncOptionWebserviceHandler{
    
    public static void AfterUpdate(Map<Id,Option__c> newOption,Map<Id,Option__c> OldOption){
        
        Set<Id> OpnId=new  Set<Id>();
        for(Option__c Op:newOption.values()){
            
            
            if(Op.PromotionName__c!=OldOption.get(op.Id).PromotionName__c  
                 ||Op.CampaignName__c!=OldOption.get(op.Id).CampaignName__c 
                 ||Op.OptionsName__c!=OldOption.get(op.Id).OptionsName__c
                 ||Op.SchemeName__c!=OldOption.get(op.Id).SchemeName__c
                 ||Op.TemplateIdPN__c!=OldOption.get(op.Id).TemplateIdPN__c
                 ||Op.TemplateIdCN__c!=OldOption.get(op.Id).TemplateIdCN__c
                 ||Op.TemplateIdOP__c!=OldOption.get(op.Id).TemplateIdOP__c
                 ||Op.TemplateIdSN__c!=OldOption.get(op.Id).TemplateIdSN__c){
                System.debug('Option web Service Will Called');
                OpnId.add(Op.id);
            }
        }
        if(!OpnId.isEmpty())
            if(AsyncOptionWebservice.isOnce==true)
                AsyncOptionWebservice.prepareOptionUpdate(OpnId);
    }
}