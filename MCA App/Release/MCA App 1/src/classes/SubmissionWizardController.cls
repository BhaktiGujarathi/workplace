/* 
 *  Description - Controller for Submission Wizard Page
 *	 
 *  Date - 10-02-2014
 *  
 *  Created by - Sneha P.
 */
public with sharing class SubmissionWizardController {
	
	
	private String pAccId;
	private Boolean prefferedPgm; 
	private list<Attachment> attachmentList;
	private map<Id,Program__c> programMap;
	//Properties
	public Opportunity opp  							{get; set;}
	public Id OppId										 {get; set;}
	public list<Program__c> applicationSentToPgm 		 {get; set;} //list stores the pgms to which the applications are sent
	public boolean showThankYouPage  				     {get; set;}
	public Program__c program               	         {get; set;}
	public list<ProgramWrapper> programWrapperList       {get; set;} 
	public list<AttachmentWrapper> AttachmentWrapperList {get; set;} 
	public boolean displayPopup 					     {get; set;}   
	public map<String,list<String>> prgmDocMap 			 {get; set;}
	
	//Constructor
	public SubmissionWizardController(){
		opp = new Opportunity();
		showThankYouPage = false;
		displayPopup = false;
		program = new Program__c();
		prgmDocMap = new map<String,list<String>>();
		programWrapperList = new list<ProgramWrapper>();
		attachmentList = new list<Attachment>();
		programMap = new Map<Id,Program__c>();
		applicationSentToPgm = new list<Program__c>();
		AttachmentWrapperList = new list<AttachmentWrapper>();
		prefferedPgm = true;
		
		OppId = ApexPages.currentPage().getParameters().get('Id');
		pAccId = ApexPages.currentPage().getParameters().get('accId');
		
		//Get the Opportunity 
		Opp = [Select Credit_Score__c,
								  Min_Monthly_Deposits__c,
								  AccountId,
								  Account.Name,
								  Account.Gross_monthly_Sales__c,
								  Account.Industry,
								  Account.Years_in_Business__c 
								  from Opportunity where Id =: OppId];
		
		
		program.Credit_Score__c = Opp.Credit_Score__c;
		program.Years_in_Business__c = Opp.Account.Years_in_Business__c;
		program.Industry__c = Opp.Account.Industry;
		program.Min_Monthly_Deposits__c = Opp.Min_Monthly_Deposits__c;
		this.getPrograms();
	}
	
	public void closePopup() {        
        displayPopup = false;    
    }     
    
    public boolean getMapSize(){
    	if(prgmDocMap.size() == 0)
    		return true;
    	else
    		return false; 
    }
    
	public void getPrograms(){
		
		programMap.clear();
		programWrapperList.clear();
		
		String query = 'Select Name,Bank__c,Bank__r.Name,Submission_Email__c,Bank__r.Main_Contact__c,Bank__r.Main_Contact__r.Name,Commission__c,Industry__c,Max_No_NSFs__c,Credit_Score__c,Years_in_Business__c,'+
				         'Min_Monthly_Deposits__c,Max_Amount__c,Commission_Percentage__c from Program__c'; 
				         //Where Opportunity__c =: OppId';
		if(prefferedPgm){
			query += ' Where Preffered_Programs__c = true';	
		}
		
		if(!prefferedPgm){
			if(!prefferedPgm && ( program.Credit_Score__c != null || 
							      program.Years_in_Business__c != null || 
							      program.Industry__c != null ||
							      program.Min_Monthly_Deposits__c != null ))
				query += ' Where';	
				
			if(program.Credit_Score__c != null){
				query += ' Credit_Score__c >= '+ program.Credit_Score__c;
			}
			if(program.Years_in_Business__c != null){
				if(program.Credit_Score__c != null)
					query += ' and';
				query += ' Years_in_Business__c >= '+program.Years_in_Business__c;
			}
			if(program.Industry__c != null){
				if(program.Credit_Score__c != null || program.Years_in_Business__c != null)
					query += ' and';	
				query += ' Restricted_Industry_List__c excludes (\''+program.Industry__c+'\') ';
			}
			
			if(program.Min_Monthly_Deposits__c != null){
				if(program.Credit_Score__c != null || program.Years_in_Business__c != null || program.Industry__c != null)
					query += ' and';	
				query += ' Min_Monthly_Deposits__c >= '+program.Min_Monthly_Deposits__c;
			}
		}
		query += ' order by Name';
		
		system.debug('***query***'+query);
		//programList = Database.query(query);	
		for(Program__c prgm : Database.query(query)){
			//programMap.put(prgm.Id,prgm);
			programWrapperList.add(new ProgramWrapper(prgm,false));	
		}
		this.getAvailableAttachments();
		
		prefferedPgm = false; 	
	}
	
	public void resetAttachments(){
		programMap.clear();
		for( ProgramWrapper wrapper: programWrapperList){
			if(wrapper.isSelected){
				programMap.put(wrapper.prgm.Id,wrapper.prgm);
			}
		}
		this.getAvailableAttachments();
	}
	
	public void getAvailableAttachments(){
		Integer cnt = 1;
		AttachmentWrapperList.clear();
		//Do not query every time. Maintain a list of attachment
		if(attachmentList == null || attachmentList.isEmpty())
			attachmentList = [Select Name, Id,ContentType,
									 Description,ParentId  From Attachment 
									 where ParentId =: pAccId or ParentId =: OppId];
			
		for(Attachment attachmnt : attachmentList){
			AttachmentWrapperList.add(new AttachmentWrapper(cnt++,attachmnt,
														    true,programMap));
		}
	}
	
	public void checkReqdDocument(){
		displayPopup = true; 
		prgmDocMap.clear();   
		
		// Query all the Document records of selected programs and display them 
		for(Required_Documents__c reqdDoc : [Select Name,Program__c,Program__r.Name from Required_Documents__c 
													where Program__c IN: programMap.keySet()
													order by Program__r.Name,Name]){
			if(prgmDocMap.isEmpty() || (!prgmDocMap.isEmpty() && !prgmDocMap.containsKey(reqdDoc.Program__r.Name)))
				prgmDocMap.put(reqdDoc.Program__r.Name, new list<String>{reqdDoc.Name});
			else if(prgmDocMap.containsKey(reqdDoc.Program__r.Name))
				prgmDocMap.get(reqdDoc.Program__r.Name).add(reqdDoc.Name);
		}
	}
	
	public void sendAllAttachments(){
		//Create a map of programs n list of attachments
		map<Id,list<Attachment>> mapPgmAttachment = new map<Id,list<Attachment>>();
		for(Id pgmId : programMap.keySet()){
			for(Attachment attachment : attachmentList){
				
				if(mapPgmAttachment.isEmpty() || (!mapPgmAttachment.isEmpty() && !mapPgmAttachment.containsKey(pgmId))){
					mapPgmAttachment.put(pgmId, new list<Attachment>{attachment});
				}else
					mapPgmAttachment.get(pgmId).add(attachment);
			}	
		}
		this.sendMail(mapPgmAttachment);
	}
	
	public void sendSelectedAttachments(){
		//Create a map of programs n list of attachments
		map<Id,list<Attachment>> mapPgmAttachment = new map<Id,list<Attachment>>();
		for(AttachmentWrapper wrapper : AttachmentWrapperList){
			//If the Attachment is required then only send the attachment
			if(wrapper.isRequired){
				for(String pgm : wrapper.selectedPrograms){
					
					if(mapPgmAttachment.isEmpty() || (!mapPgmAttachment.isEmpty() && !mapPgmAttachment.containsKey((Id)pgm))){
						
						mapPgmAttachment.put((Id)pgm, new list<Attachment>{wrapper.attachment});
					}else
						mapPgmAttachment.get((Id)pgm).add(wrapper.attachment);
				}	
			}
		}
		this.sendMail(mapPgmAttachment);
	}
	
	public void sendMail(map<Id,list<Attachment>> mapPgmAttachment){
		try{
			
			User userObj = [Select LastName, FirstName, CompanyName From User where id=:userinfo.getuserid()];
			map<Id,Attachment> attachmentMap2 =new map<Id,Attachment>([Select Name, Id,ContentType,
																			 Body,
																			 Description,ParentId  From Attachment 
																			 where ParentId =: pAccId or ParentId =: OppId]);
									 
			list<Submission__c> submissionList = new list<Submission__c>();
			List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
			String accName = [Select Account.Name from Opportunity where Id =: oppId ].Account.Name;
			
			//Send an Email to banks email Id
			for(Id pgmId : mapPgmAttachment.keySet()){
				 
				 if(programMap.get(pgmId).Submission_Email__c <> null){
				 	
					Messaging.EmailFileAttachment[] fileAttachments = new Messaging.EmailFileAttachment[]{};
		            //Creating Messaging.Singleemailmessage instance to create a message.
		    		Messaging.Singleemailmessage message = new Messaging.Singleemailmessage();
		       
					for( Attachment att: mapPgmAttachment.get(pgmId)){
		                //Creating Messaging.EmailFileAttachment instance to create file attachment.
		                Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
		                fileAttachment.setFileName(att.Name);
		                fileAttachment.setContentType(att.ContentType);
		                fileAttachment.setBody(attachmentMap2.get(att.Id).Body);
		                fileAttachment.setInline(false);
		                
		                // Add the created attachment to the Messaging Attachments
		                fileAttachments.add(fileAttachment);
		            }//End if.
	
		            //Adding attachments to message.
	                message.setFileAttachments(fileAttachments); 
	                List<String> senderAddresses = new List<String>();
	                senderAddresses.add(programMap.get(pgmId).Submission_Email__c); //Adding Email Id.
	                message.setToAddresses(senderAddresses);
	                message.setSubject('Submissions Email');
	                String messageBody = '<html><body>Hi '+programMap.get(pgmId).Bank__r.Main_Contact__r.Name+',<br/>'+
	                						'Attached please find a new application for your review. <br/>'+
	                						'Should you have any questions, please let me know. <br/>'+
	         								 userObj.FirstName+' '+userObj.LastName+'<br/>'+userObj.CompanyName+
	                						' </body>  </html>';
	              	 message.setHtmlBody(messageBody); 
		            //Send the Attachment Email to Banks Email address
		            allMails.add(message);
		            //Create a submission record for each Program
		            Submission__c submission = new Submission__c(Opportunity__c = OppId,
				 												 Name = programMap.get(pgmId).Bank__r.Name+
				 													'_'+programMap.get(pgmId).Name+
				 													'_'+accName+
				 													'_'+system.now(),
				 												 Contact__c = programMap.get(pgmId).Bank__r.Main_Contact__c,
				 												 Status__c = 'UW',
				 												 Funder__c = programMap.get(pgmId).Bank__c,
					 											 Program__c = pgmId,
					 											 Email__c = programMap.get(pgmId).Submission_Email__c,
					 											 Date_Submitted__c = System.now());
				 	//insert submission;
				 	submissionList.add(submission);
		            applicationSentToPgm.add(programMap.get(pgmId));
				}
			}
			
			if(submissionList.size() > 0)
					insert submissionList;
			if(allMails.size() > 0){
				
					
				 List<Messaging.SendEmailResult> results =  Messaging.sendEmail(allMails); 
				/*if (!results.get(0).isSuccess()) {
				    System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
				    String errorMessage = results.get(0).getErrors()[0].getMessage();
				    system.debug('******statusCode**'+statusCode);
				    system.debug('******errorMessage**'+errorMessage);
				}*/
				
				//After the mail has been sent show a thankyou Page
				showThankYouPage = true;
				
				update (new Opportunity (Id = oppId ,StageName = 'Underwriting'));
			}else{
				//No email sent
			}
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
            //return null;	
		}
	}
	
	public PageReference cancel(){
		return new PageReference('/'+OppId);
	}
	
	//Wrapper Class contains Attachment Object and isRequired to keep track of which Attachment is isRequired 
	public class AttachmentWrapper{
		public Integer cnt 				  {get; set;}
		public Attachment attachment 	  {get; set;}
		public boolean isRequired 		  {get; set;}
		public List<selectOption> options {get; set;}
		public String[] selectedPrograms 		  {get; set;} 
		public AttachmentWrapper(Integer pCnt, Attachment pAttachment ,Boolean pIsRequired, map<Id,Program__c> pProgramMap){
			cnt = pCnt;
			selectedPrograms = new String[]{};
			for(String pgm : pProgramMap.keySet()){
				selectedPrograms.add(pgm);
			}
			attachment = pAttachment;
			isRequired = pIsRequired;
			options = new List<selectOption>();
			for(String pgm : pProgramMap.keySet()){
				 options.add(new selectOption(pgm, pProgramMap.get(pgm).Name));
			}
		}
	}
	
	//Wrapper Class contains Program__c Object and isSelected to keep track of which Program__c is selected 
	public class ProgramWrapper{
		public Program__c prgm 			  {get; set;}
		public boolean isSelected 		  {get; set;}
	
		public ProgramWrapper(Program__c pProgram ,Boolean pIsSelected){
			prgm = pProgram;
			isSelected = pIsSelected;
		}
	}
}