public with sharing class PublicGroupInfo {

    public static Set<id> getUserIdsByGroupId(Set<Id> groupIds) 
    {
        // store the results in a set so we don't get duplicates
        Set<Id> result = new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        Set<Id> groupIdProxys = new Set<Id>();
        // Loop through all group members in a group
        for(GroupMember memberObj : [Select Id, UserOrGroupId, Group.Type, Group.RelatedId From GroupMember Where GroupId in :groupIds])
        {
            // If the user or group id is a user
            if(((String)memberObj.UserOrGroupId).startsWith(userType))
            {
                result.add(memberObj.UserOrGroupId);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)memberObj.UserOrGroupId).startsWith(groupType))
            {
                // Call this function again but pass in the group found within this group
               groupIdProxys.add(memberObj.userOrGroupId);
                
            }
                                   
        }
        
      if(groupIdProxys.size()>0)
      result.addAll(GetUserIdsByGroupId(groupIdProxys));                       
     
      return result;  
        
    }
}