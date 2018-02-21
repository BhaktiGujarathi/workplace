/*
* Name : Pavithra Gajendra
* Date : 02/09/2017
* Purpose : To Invoke Approval process on click of a button
* Company : NSI Gulf
* 
*/
global class AgentBlacklistingApproval{
		//	Individual_Agency
		//	Corporate_Agency
        /*
        * Submit for Blacklisting Agent 
        */
        webservice static string submitAgentBlacklistApprovalRequest(Id accountRecordId) {
            try{
            Account acc = [select id,name,recordtype.name from account where id =: accountRecordId limit 1];    
            NSIBPM__Service_Request__c objSR = UtilityQueryManager.checkPendingSR(accountRecordId);
            if(null != objSR){
                return 'Please close the pending '+objSR.name;
            }
            //----- Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(DAMAC_Constants.COMMENTS_FOR_BLACKLISTING);
            req1.setObjectId(accountRecordId);   
                if(acc.recordtype.name == Label.Individual_Agency){
                    req1.setProcessDefinitionNameOrId('Agent_Blacklisting_Approval_Ind');
                }else if(acc.recordtype.name == Label.Corporate_Agency){
                    req1.setProcessDefinitionNameOrId('Agent_Blacklisting_Approval_Corp');
                }else{
                    return 'No applicable process found';
                }
            //req1.setProcessDefinitionNameOrId('Agent_Blacklisting_Approval');
            req1.setSubmitterId(UserInfo.getUserId());            
            
            //----- Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
            //----- Verify the result
            System.assert(result.isSuccess()); 
            return 'Submitted successfully';
            }
            catch(exception ex){
                return 'No applicable process found';
            }
        }

        /*
        * Submit for Terminating Agent 
        */
        webservice static string submitAgentTerminateApprovalRequest(Id accountRecordId) {
            try{
            Account acc = [select id,name,recordtype.name from account where id =: accountRecordId limit 1];
            NSIBPM__Service_Request__c objSR = UtilityQueryManager.checkPendingSR(accountRecordId);
            if(null != objSR){
                return 'Please close the pending '+objSR.name;
            }
            //----- Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(DAMAC_Constants.COMMENTS_FOR_TERMINATION);
            req1.setObjectId(accountRecordId);  
                if(acc.recordtype.name == Label.Individual_Agency || acc.recordtype.name == Label.Individual_Agency_Blacklisted){
                    req1.setProcessDefinitionNameOrId('Agent_Termination_Approval_Ind');
                }else if(acc.recordtype.name == Label.Corporate_Agency || acc.recordtype.name == Label.Corporate_Agency_Blacklisted){
                    req1.setProcessDefinitionNameOrId('Agent_Termination_Approval_Corp');
                }else{
                    return 'No applicable process found';
                }
            //req1.setProcessDefinitionNameOrId('Agent_Termination_Approval');
            req1.setSubmitterId(UserInfo.getUserId());            
            
            //----- Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
            //----- Verify the result
            System.assert(result.isSuccess());     
            return 'Submitted successfully';
            }
            catch(exception ex){
                return 'No applicable process found';
            }
        }
        
        /*
        * Submit for Un-Terminating Agent 
        */
        webservice static string submitAgentUnBlacklistApprovalRequest(Id accountRecordId) {
            try{
            Account acc = [select id,name,recordtype.name from account where id =: accountRecordId limit 1];
            NSIBPM__Service_Request__c objSR = UtilityQueryManager.checkPendingSR(accountRecordId);
            if(null != objSR){
                return 'Please close the pending '+objSR.name;
            }    
            //----- Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(DAMAC_Constants.COMMENTS_FOR_UNBLACKLISTING);
            req1.setObjectId(accountRecordId);            
                if(acc.recordtype.name == Label.Individual_Agency_Blacklisted){
                    req1.setProcessDefinitionNameOrId('Agent_Un_Blacklisting_Approval_Ind');
                }else if(acc.recordtype.name == Label.Corporate_Agency_Blacklisted){
                    req1.setProcessDefinitionNameOrId('Agent_Un_Blacklisting_Approval_Corp');
                }else{
                    return 'No applicable process found';
                }
            //req1.setProcessDefinitionNameOrId('Agent_UnBlacklisting_Approval_2');
            req1.setSubmitterId(UserInfo.getUserId());            
            
            //----- Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
            //----- Verify the result
            System.assert(result.isSuccess());   
            return 'Submitted successfully';
            }
            catch(exception ex){
                return 'No applicable process found';
            }
        }
    
    	//	Individual_Agency
		//	Corporate_Agency
        
        /*
        * Submit for Un-Blacklisting Agent 
        */
        webservice static string submitAgentUnTerminateApprovalRequest(Id accountRecordId) {
            try{
            Account acc = [select id,name,recordtype.name from account where id =: accountRecordId limit 1];
            NSIBPM__Service_Request__c objSR = UtilityQueryManager.checkPendingSR(accountRecordId);
            if(null != objSR){
                return 'Please close the pending '+objSR.name;
            }    
            //----- Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(DAMAC_Constants.COMMENTS_FOR_UNTERMINATION);
            req1.setObjectId(accountRecordId);
                if(acc.recordtype.name == Label.Individual_Agency_Terminated){
                    req1.setProcessDefinitionNameOrId('Agent_Un_Termination_Approval_Ind');
                }else if(acc.recordtype.name == Label.Corporate_Agency_Terminated){
                    req1.setProcessDefinitionNameOrId('Agent_Un_Termination_Approval_Corp');
                }else{
                    return 'No applicable process found';
                }
                    
            //req1.setProcessDefinitionNameOrId('Agent_UnTermination_Approval_2');
            req1.setSubmitterId(UserInfo.getUserId());            
            
            //----- Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
            //----- Verify the result
            System.assert(result.isSuccess());   
            return 'Submitted successfully';
            }
            catch(exception ex){
                return 'No applicable process found';
            }
        }
}