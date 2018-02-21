public class AccountSharingUtility{
    @future
    public static void shareAccount(string JsonAccidsetUserids){
        try{
            List<AccountShare> lstaccSharetoInsert = new List<AccountShare>();
			if(JsonAccidsetUserids != null && !String.isEmpty(JsonAccidsetUserids)){
                List<AccountSharingUtility.JsonWrapper> lstSharingRec = (List<AccountSharingUtility.JsonWrapper>)Json.deserialize(JsonAccidsetUserids, List<AccountSharingUtility.JsonWrapper>.class); 
                
                if(lstSharingRec == null || lstSharingRec.isempty()){
                    return;
                }                
                for(AccountSharingUtility.JsonWrapper sh : lstSharingRec){
                    if(sh.userids == null || sh.userids.isempty()){
                        continue;
                    }
                    for(id uid: sh.userids){
                        AccountShare accshare = new AccountShare();
                        accshare.AccountId = sh.accid;
                        accshare.UserOrGroupId = uid;
                        accshare.AccountAccessLevel = 'Edit';
                        accshare.OpportunityAccessLevel = 'Edit';
                        lstaccSharetoInsert.add(accshare);
                    }
                }
            }
            if(lstaccSharetoInsert != null && !lstaccSharetoInsert.isempty()){
            	system.debug('--->Share Success'+lstaccSharetoInsert.size());
                insert lstaccSharetoInsert;
                system.debug('--->Share Success'+lstaccSharetoInsert.size());
            }
        }
        catch(exception ex){
            system.debug('--->Error in account sharing -->'+ex.getMessage());
        }
    }
    
    
    public class JsonWrapper{
        public  id accid {get;set;}
        public set<id> userids {get;set;}
        public JsonWrapper(id acid, set<id> uIds){
            this.accid = acid;
            this.userids = uIds;
        }
    }   
}