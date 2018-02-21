public class Opportunity_CMB_Utility {
    
    public static void createPayables(Map<Id,Opportunity> mpNew, Map<Id,Opportunity> mpOld){
        
        //Collect OwnerIds
        Set<Id> userIds = new Set<Id>();
        for(Opportunity opp: mpNew.values()){
            System.debug('>>>>>>Submission Approved>>>>>>>>>'+opp.Submission_Approved__c);
            if(opp.Submission_Approved__c && mpOld.get(opp.Id).Submission_Approved__c != opp.Submission_Approved__c){
                userIds.add(opp.ownerId);
            }
        }  
        
        System.debug('>>>>>>>>User Ids>>>>>>>>'+userIds);
        
        //Collect manager Ids from Opportunity Team Member
        Map<Id,Id> mpManagerIds = new Map<Id,Id>();
        for(OpportunityTeamMember otm: [Select id,opportunityId,UserId from OpportunityTeamMember where opportunityId in: mpNew.keyset() and TeamMemberRole='Opener Manager']){
            mpManagerIds.put(otm.opportunityId, otm.userId);
        }
        
        System.debug('>>>>>>Manager Ids>>>>>>>>>>'+mpManagerIds);
        
        //Collect Owner Ids and their Roles
        map<Id,String> mpUserRoles = new Map<Id,String>();
        for(User u : [Select id,UserRole.Name from User where id in: userIds]){
            mpUserRoles.put(u.Id,u.UserRole.Name);
        }
        
        System.debug('>>>>>>mpUser Roles>>>>>>>>>>'+mpUserRoles);
        
        //Collect exisitng Sales Rep Report Cards
        Map<Id,Sales_Rep_Report_Card__c> mpSales = new Map<Id,Sales_Rep_Report_Card__c>();
        for(Sales_Rep_Report_Card__c rep: [Select id, Sales_Rep__c, Submissions_Today__c, Submissions_Required_for_Today_Bonus__c,Submissions_Today_Bonus__c from Sales_Rep_Report_Card__c where Sales_Rep__c in: userIds]){
            mpSales.put(rep.Sales_Rep__c,rep);
        }
        
        System.debug('>>>>>>Map Sales Rep Cards>>>>>>>>>>'+mpSales);
        
        //Collect Opener Account Records
        Map<Id,Id> mpUserAccIds = new Map<Id,Id>();
        for(Account acc : [Select id,McaApp__User__c  from Account where Recordtype.Name='ISO' and McaApp__User__c in: mpUserRoles.keyset()]){
            mpUserAccIds.put(acc.McaApp__User__c,acc.id);
        }
        
        System.debug('>>>>>>User Accounts>>>>>>>>>>'+mpUserAccIds);
        
        //Collect Opener Manager Account Records
        Map<Id,Id> mpManagerUserAccIds = new Map<Id,Id>();
        for(Account acc : [Select id,McaApp__User__c  from Account where Recordtype.Name='ISO' and McaApp__User__c in: mpManagerIds.values()]){
            mpManagerUserAccIds.put(acc.McaApp__User__c,acc.id);
        }
        
        System.debug('>>>>>>User Manager Accounts>>>>>>>>>>'+mpManagerUserAccIds);
        
        List<McaApp__Payable__c> Payables2Insert = new List<McaApp__Payable__c>();
        List<Sales_Rep_Report_Card__c> Reps2Update = new List<Sales_Rep_Report_Card__c>();
        
        for(Opportunity opp: mpNew.values()){
            if(opp.Submission_Approved__c && mpOld.get(opp.Id).Submission_Approved__c != opp.Submission_Approved__c){
                if(mpUserRoles.containsKey(opp.ownerId) && mpUserRoles.get(opp.ownerId)=='Opener'){
                    if(mpUserRoles.containsKey(opp.OwnerId) && mpUserAccIds.containsKey(opp.OwnerId)){          
                        McaApp__Payable__c payRecAgent = new McaApp__Payable__c(McaApp__Amount_Due__c= opp.Submission_Approved_Rep_Bonus__c);
                        payRecAgent.McaApp__Account__c = mpUserAccIds.get(opp.OwnerId);
                        payRecAgent.McaApp__Opportunity__c = opp.Id;
                        payRecAgent.McaApp__Payable_Date__c= System.Today();
                        payRecAgent.McaApp__Due_Date__c = System.Today();
                        payRecAgent.McaApp__Type__c='Bonus';
                        payRecAgent.McaApp__Memo__c = 'Submission Bonus for Rep';
                        Payables2Insert.add(payRecAgent);
                    }
                    
                    if(mpManagerIds.containsKey(opp.Id) && mpManagerUserAccIds.containsKey(mpManagerIds.get(opp.Id))){  
                        McaApp__Payable__c payRecManager = new McaApp__Payable__c(McaApp__Amount_Due__c= opp.Submission_Approved_Manager_Bonus__c);
                        payRecManager.McaApp__Account__c = mpManagerUserAccIds.get(mpManagerIds.get(opp.Id));
                        payRecManager.McaApp__Opportunity__c = opp.Id;
                        payRecManager.McaApp__Payable_Date__c= System.Today();
                        payRecManager.McaApp__Due_Date__c = System.Today();
                        payRecManager.McaApp__Type__c='Bonus';
                        payRecManager.Opener_Manager_Payable__c =true;
                        payRecManager.McaApp__Memo__c = 'Submission Bonus for Manager';
                        Payables2Insert.add(payRecManager);
                    } 
                                   
                    if(mpSales.containsKey(opp.OwnerId)){
                        Sales_Rep_Report_Card__c rep = mpSales.get(opp.OwnerId);
                        rep.Submissions_Today__c = rep.Submissions_Today__c+1;
                        Reps2Update.add(rep);
                        
                        if(Math.mod(integer.valueOf(rep.Submissions_Today__c),integer.valueof(rep.Submissions_Required_for_Today_Bonus__c))==0){
                            McaApp__Payable__c payRecAgent = new McaApp__Payable__c(McaApp__Amount_Due__c= rep.Submissions_Today_Bonus__c);
                            payRecAgent.McaApp__Account__c = mpUserAccIds.get(opp.OwnerId);
                            //payRecAgent.McaApp__Opportunity__c = opp.Id;
                            payRecAgent.McaApp__Payable_Date__c= System.Today();
                            payRecAgent.McaApp__Due_Date__c = System.Today();
                            payRecAgent.McaApp__Type__c='Bonus';
                            payRecAgent.McaApp__Memo__c = 'Submissions Today Bonus';
                            Payables2Insert.add(payRecAgent);
                        }
                    }
                }
            }
        }
        
        System.debug('>>>>>>>>>>>>>>>>>'+Payables2Insert);
        
        if(!Payables2Insert.isEmpty())
            insert Payables2Insert;
        
        if(!Reps2Update.isEmpty())
            update Reps2Update;
        
        
    }

}