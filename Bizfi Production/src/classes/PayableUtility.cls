public class PayableUtility{
    
     public void ShareRecords(List<McaApp__Payable__c> lstRecords){
        
        set<Id> accIds = new Set<Id>();
        for(McaApp__Payable__c pay:lstRecords){
            if(pay.McaApp__Account__c != null){
                accIds.add(pay.McaApp__Account__c);    
            }
        }
        
        List<String> ExcludeRoles = System.Label.ExcludeRoleIds.split(';');
        
        
        if(accIds.size()>0){
            
            Map<Id,Id> accUsersMap = new Map<Id,Id>();
            Map<Id,Id> UsersMap = new Map<Id,Id>();
            
            for(Account acc : [Select id, McaApp__User__c,McaApp__User__r.UserRoleId from Account where Id in: accIds]){
                accUsersMap.put(acc.id, acc.McaApp__User__c);   
                UsersMap.put(acc.id, acc.McaApp__User__c);   
            }
            
            map<Id,UserRole> mpUserRoles = new Map<Id,UserRole>();
            for(UserRole uRole : [Select id,developerName, parentRoleId from UserRole]){
                mpRoles.put(uRole.Id, uRole.ParentRoleId);
                mpUserRoles.put(urole.Id,uRole);
            }
            
            Group managergrp = [Select id from Group where type='Role' and developerName='Opener_Manager'];
            
            Set<Id> AllRoleIds = new Set<Id>();
            Map<Id,Set<Id>> mpUsers = new Map<Id,Set<Id>>();
            for(id recId : accUsersMap.keyset()){
                if(accUsersMap.get(recId) != null){
                    roleIds.add(UsersMap.get(recId));
                    //getParentRoleIds(accUsersMap.get(recId));
                    mpUsers.put(recId,roleIds);
                    
                    AllRoleIds.addAll(roleIds);
                }
            }
            
            sYSTEM.DEBUG('>>>>>>>>AllRoleIds>>>>>>>>>>>>'+AllRoleIds);
            
            //AllRoleIds.addAll(mpUsers.values());
            Map<Id,Id> mpGroupRoles = new Map<Id,Id>();
            for(Group g: [Select id,RelatedId from Group where RelatedId in:AllRoleIds and type='Role' and developerName not in:ExcludeRoles]){
                //mpGroupRoles.put(g.RelatedId,g.Id);
            }
            
            List<McaApp__Payable__Share> lstExisting = [Select id,UserOrGroupId,AccessLevel from McaApp__Payable__Share where parentId in: lstRecords];
            System.debug('>>>>>>>>>>>>>>>>>>'+lstExisting);
            Map<Id,String> existingShares = new Map<Id,string>();
            for(McaApp__Payable__Share ps : lstExisting){
                existingShares.put(ps.UserOrGroupId, ps.AccessLevel);
            }
            System.debug('>>>>>>>>>>>>>>>>>>>'+existingShares);
            
            List<McaApp__Payable__Share> lstToInsert = new List<McaApp__Payable__Share>();
            for(McaApp__Payable__c pay:lstRecords){
                
                System.debug('\n\n###UsersMap: ' + UsersMap);
                System.debug('\n\n###UsersMap: ' + UsersMap.get(pay.McaApp__Account__c));

                if (UsersMap.containsKey(pay.McaApp__Account__c)) {
                    
                    Id roleId = UsersMap.get(pay.McaApp__Account__c);

                    if (roleId != null) {
                    //for(Id roleId : UsersMap.get(pay.McaApp__Account__c)){
                        
                        McaApp__Payable__Share obj = new McaApp__Payable__Share();
                        obj.AccessLevel = 'Edit';
                        obj.ParentID = pay.id;                        
                        
                    //    obj.put('RowCause', 'User_of_Due_to_Account_on_creation__c');
                        

                        if(!existingShares.containsKey(roleId)) { // && ((pay.Opener_Manager_Payable__c ==false && string.valueOf(roleId).startsWith('005')) || mpGroupRoles.containskey(roleId))){
                            //obj.UserOrGroupId = mpGroupRoles.get(roleId) != null ? mpGroupRoles.get(roleId) : roleId;
                            obj.UserOrGroupId = roleId;
                            //obj.RowCause = Schema.McaApp__Payable__Share.RowCause.Manual;
                            System.debug('>>>>>>>>>>00Go0000001b96wEAA>>>>>>>>>>>>>>'+obj.UserOrGroupId);
                            if(pay.Opener_Manager_Payable__c && obj.UserOrGroupId != managergrp.Id){
                                    lstToInsert.add(obj);
                            }
                            if(pay.Opener_Manager_Payable__c == false)
                                lstToInsert.add(obj);
                        }
                    //}
                    }
                }
            }
            
            System.debug('>>>>>>>>>>>Lst inserting>>>>>>>>>>>>>'+lstToInsert);
            if(!lstToInsert.isEmpty())
            insert lstToInsert;
            
        }
    
    }
    
    public Map<Id,Id> mpRoles = new Map<Id,Id>();
    public set<Id> roleIds = new set<Id>();
    
    public void getParentRoleIds(Id userRoleId){
        if(mpRoles.containsKey(userRoleId) && mpRoles.get(userRoleId) != null){
            roleIds.add(mpRoles.get(userRoleId));
            getParentRoleIds(mpRoles.get(userRoleId));
        }
    }
     
     


}