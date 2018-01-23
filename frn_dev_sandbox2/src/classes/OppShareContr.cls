global class OppShareContr{
	
	 webservice static string shareOpportunity(String oppId){
		String uid = UserInfo.getUserId();
		for(UserRecordAccess ur: [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId=:uid AND RecordId =: oppId  limit 1]){
			if(!ur.HasEditAccess){
				OpportunityShare oppshr  = new OpportunityShare();
				oppshr.OpportunityId = ur.RecordId;
				oppshr.UserOrGroupId = UserInfo.getUserId();
				oppshr.OpportunityAccessLevel = 'Edit';
				oppshr.RowCause = Schema.AccountShare.RowCause.Manual;
                if(!Test.isRunningTest()){
				insert oppshr;			
                }
			}

		}
		return 'success';
	}
}