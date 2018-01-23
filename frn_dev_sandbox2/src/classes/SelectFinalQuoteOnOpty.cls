global class SelectFinalQuoteOnOpty{
	
 
		
	 webservice static string QuoteSelection(String quoteID, String oppID){ 
        System.debug(quoteID +','+oppID);
		map<string,List<string>> checkgroupname =  new Map<string,List<string>>(); 
		Map<String,List<string>> fmails  = new Map<String,List<string>>();
		for (GroupMember gm : [select group.Name,userOrGroupId from groupMember]) {  
				if(!checkgroupname.containsKey(gm.userOrGroupId)){
					List<String> nameList = new List<String>();
					nameList.add(gm.group.Name);
					checkgroupname.put(gm.userOrGroupId,nameList);
				}else{
					checkgroupname.get(gm.userOrGroupId).add(gm.group.Name);
				} 
			}
			
			for(User u : [SELECT Id,email FROM user WHERE id IN :checkgroupname.keySet()]) {
				for(String  s:checkgroupname.get(u.Id)){
					if(!fmails.containsKey(s)){
						List<String> emailList = new List<String>();
						emailList.add(u.email);
						fmails.put(s,emailList);
					}else{
						fmails.get(s).add(u.email);
					} 
				} 
			}
        Quote Quot = [select Id,OpportunityID, FRN_Facility__c,Opportunity.Final_Quote_Selected__c, Opportunity.FRN_Facility_Selected__c  from Quote where Id=:quoteID];
        System.debug(+Quot);
        list<Quote> quoteListUpdate =new list<Quote>();
        if(quoteID != null){
            if(Quot.Opportunity.Final_Quote_Selected__c != null && Quot.Opportunity.Final_Quote_Selected__c != Quot.Id){
                // update current quote
                Quote q = new Quote();
                q.id= Quot.Id;
                q.Select_as_Final_Quote__c= true ;
                quoteListUpdate.add(q);
                
                // update old quote selected 
                Quote q1 = new Quote();
                q1.id= Quot.Opportunity.Final_Quote_Selected__c;
                q1.Select_as_Final_Quote__c= false ;
                
                quoteListUpdate.add(q1);
            }else{
                
                Quote q = new Quote();
                q.id= Quot.Id;
                q.Select_as_Final_Quote__c= true ;
                quoteListUpdate.add(q);
            }
            
            if(quoteListUpdate.size()>0){
                update quoteListUpdate;
                System.debug(+quoteListUpdate);
            }
            
            Opportunity opp = new Opportunity();
            opp.Id=oppID;
            opp.Final_Quote_Selected__c = Quot.Id;
            opp.FRN_Facility_Selected__c = Quot.FRN_Facility__c;
            update opp;
            system.debug(+opp);

            Opportunity op = [SELECT Id,FRN_Facility_Selected__c FROM Opportunity WHERE Id =: oppID];
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Case> caseList = new List<Case>();
            List<Task> tskList = new List<Task>();
			 
            for(Case cs:[Select Id,Status,CaseNumber,AccountId,Account.Facility_Approval_Group_Name__c from Case WHERE Opportunity__c =:oppID AND IsClosed = false]){
                if(cs.AccountId != op.FRN_Facility_Selected__c){
                    system.debug('cs.acc>>>>>>'+cs.AccountId); 
                    cs.Status = 'Closed'; 
                    caseList.add(cs);
					System.debug('Facility_Approval_Group_Name__1 '+cs.Account.Facility_Approval_Group_Name__c);   
                    if(cs.Account.Facility_Approval_Group_Name__c != null && cs.Account.Facility_Approval_Group_Name__c != ''){
						System.debug('Facility_Approval_Group_Name__2 '+cs.Account.Facility_Approval_Group_Name__c);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
						if(!Test.isRunningTest()){ 
							if(fmails.containsKey(cs.Account.Facility_Approval_Group_Name__c)){
								mail.settoAddresses(fmails.get(cs.Account.Facility_Approval_Group_Name__c)); 
							mail.setSubject('Case ' + cs.CaseNumber + ' has been closed');
							String body = 'Case ' + cs.CaseNumber + ' has been closed due to another facility being selected as final. ';
							mail.setHtmlBody(body); 
							//mails = new List<Messaging.SingleEmailMessage>{mail};
							mails.add(mail);

							Task task = new Task();
							task.WhatId = cs.id;
							task.Subject = 'Case ' + cs.CaseNumber + ' has been closed';
							task.Type = 'Email Mass';
							task.Status = 'Completed';                    
							task.description = 'Case'+ cs.CaseNumber + ' has been closed due to another facility being selected as final. ';
							tskList.add(task);
							}  
						} else {
							mail.settoAddresses(new String[] {'test@test.com' });
						} 
                    }
                }
            }
             if(mails.size()>0){
                Messaging.sendEmail(mails);
                insert tskList;
            }
            
                                            
            if(caseList.size()>0){
                update caseList;
            }
            
            return 'Opportunity is updated'; 
        }
        
        return null; 
    }
    webservice static List<string> getOpportunity(String quoteID ){
        
        List<string> opp =  new List<string>();
        Quote q = [Select Opportunity.id,Opportunity.Name,Opportunity.Final_Quote_Selected__c, Opportunity.Final_Quote_Selected__r.QuoteNumber,Opportunity.Final_Quote_Selected__r.Name FROM Quote where id =: quoteID limit 1];
        
        if(q != null){
            opp.add(q.Opportunity.id);
            opp.add(String.valueOf(q.Opportunity.Final_Quote_Selected__c) != null ? String.valueOf(string.valueOf(q.Opportunity.Final_Quote_Selected__r.QuoteNumber)) : 'no');
            opp.add(String.valueOf(q.Opportunity.Final_Quote_Selected__c) != null ? String.valueOf(string.valueOf(q.Opportunity.Final_Quote_Selected__r.Name)) : 'no');
       }
       return opp;
    }  
}