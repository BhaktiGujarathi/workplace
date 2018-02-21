/* 
 *  Description - Controller for Submission Wizard Page
 *   
 *  Date - 10-02-2014
 *  
 *  Created by - Sneha P.
 */
global with sharing class SubmissionWizardController {
    
    private Boolean prefferedPgm; 
    private list<Attachment> attachmentList;
    private map<Id,Program__c> programMap;
    User userObj = [Select LastName, FirstName, CompanyName From User where id=:userinfo.getuserid()];
    //Properties
    public Opportunity opp                               {get; set;}
    public Id OppId                                      {get; set;}
    public String pAccId                                 {get; set;}
    public list<Program__c> applicationSentToPgm         {get; set;} //list stores the pgms to which the applications are sent
    public list<Program__c> applicationNotSentToPgm      {get; set;} //list stores the pgms to which the applications are not sent
    public boolean showThankYouPage                      {get; set;}
    public Program__c program                            {get; set;}
    public list<ProgramWrapper> programWrapperList       {get; set;} 
    public list<AttachmentWrapper> AttachmentWrapperList {get; set;} 
    public boolean displayPopup                          {get; set;}   
    public map<String,list<String>> prgmDocMap           {get; set;}
    public static String sortDirection = 'ASC';
    private String sortExp = 'name';
    public string MessageBody = '';
    public list<Submission_Mails_Detail__c> mailsDetails ;
    public static final String LOGO_NAME = Label.SubmissionWizard_LogoName;
    public static String EMAIL_LIMIT = 'EMAIL_LIMIT_EXCEEDED';
    public static String channelVal = '';
    //public String check= 'Unckeck';
    
    public String sortExpression
    {
         get { return sortExp; }
         set
         { 
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp)
             sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           else
             sortDirection = 'ASC';
           sortExp = value;
        }
    }
    
     public String getSortDirection()
     {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
     }
    
     public void setSortDirection(String value)
     {  
       sortDirection = value;
     } 
    
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
        applicationNotSentToPgm = new list<Program__c>();
        AttachmentWrapperList = new list<AttachmentWrapper>();
        
        prefferedPgm = true;
        mailsDetails = new List<Submission_Mails_Detail__c>();               
        
        OppId = ApexPages.currentPage().getParameters().get('Id');
        pAccId = ApexPages.currentPage().getParameters().get('accId');
        
        //Get the Opportunity 
        Opp = [Select Total_Loan_Balance__c,
                      No_of_Funders__c,                   
                      Credit_Score__c,
                      Gross_monthly_Sales__c, 
                      AccountId,
                      StageName,
                      Amount_Requested__c,
                      Account.Name,
                      Account.Number_Bank_Statements_Available__c,
                      Account.Number_CC_Statements_Available__c,
                      Account.Monthly_CC_Avg_All__c,
                      Account.Monthly_Bank_Deposit_Avg_All__c,
                      Account.NSFs_Avg__c,
                      Account.NumberofLocations__c,
                      Account.Gross_monthly_Sales__c,
                      Account.Industry,
                      Account.Years_in_Business__c 
                      from Opportunity where Id =: OppId];
        
        mailsDetails = [Select Is_Active__c,
                               Message_Body__c,
                               Subject__c,
                               CC_Address__c,
                               Bcc_Address__c
                        From Submission_Mails_Detail__c 
                        where Is_Active__c= true];
        
        program.Credit_Score__c = Opp.Credit_Score__c;
        program.Years_in_Business__c = Opp.Account.Years_in_Business__c;
        program.Industry__c = Opp.Account.Industry;
        program.Min_Monthly_Deposits__c = Opp.Gross_monthly_Sales__c;
        program.Preffered_Programs__c = true;
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
    
    public void clearFilter(){
        program.Credit_Score__c = null;
        program.Years_in_Business__c = null;
        program.Industry__c = null;
        program.Min_Monthly_Deposits__c = null;
        program.Preffered_Programs__c = false;
        this.getPrograms();
    }
    
    public PageReference openAttachment(){
        
        String pgRef =Page.OppMultipleAttachment.getUrl()+'?id='+OppId+'&retURL='+Page.SubmissionWizard.getUrl()+'?id='+OppId+'&accId='+pAccId;
        return new PageReference(pgRef);
    }
    
    public void getPrograms(){
        
        programMap.clear();
        programWrapperList.clear();
        
        String query = 'Select Bank__r.Name,Bank__r.Main_Contact__c,Bank__r.Main_Contact__r.Name,'+
                         SObjectType.Program__c.fields.Name.Name + ','+
                         SObjectType.Program__c.fields.Bank__c.Name + ','+
                         SObjectType.Program__c.fields.Submission_Email__c.Name + ','+
                  //       SObjectType.Program__c.fields.Commission__c.Name + ','+
                         SObjectType.Program__c.fields.Industry__c.Name + ','+
                         SObjectType.Program__c.fields.Max_No_NSFs__c.Name + ','+
                         SObjectType.Program__c.fields.Credit_Score__c.Name + ','+
                         SObjectType.Program__c.fields.Years_in_Business__c.Name + ','+
                         SObjectType.Program__c.fields.Min_Monthly_Deposits__c.Name + ','+
                         SObjectType.Program__c.fields.Max_Amount__c.Name + ',' +
                         SObjectType.Program__c.fields.Commission_Percentage__c.Name + ',' +
                         SObjectType.Program__c.fields.Preffered_Programs__c.Name + ',' +
                         SObjectType.Program__c.fields.Funding_Amt_of_Monthly_Gross_Sales__c.Name+' from '+
                         SObjectType.Program__c.Name; 
        
        //if(!prefferedPgm){ !prefferedPgm &&
            if( ( program.Credit_Score__c != null || 
                                  program.Years_in_Business__c != null || 
                                  program.Industry__c != null ||
                                  program.Min_Monthly_Deposits__c != null ||
                                  program.Preffered_Programs__c != false))
                query += ' Where '; 
                
            if(program.Credit_Score__c != null){
                 program.Credit_Score__c +=10;
                query += SObjectType.Program__c.fields.Credit_Score__c.Name+' <= '+ program.Credit_Score__c;
            }
            if(program.Years_in_Business__c != null){
                if(program.Credit_Score__c != null)
                    query += ' and ';
                query += SObjectType.Program__c.fields.Years_in_Business__c.Name+' <= '+program.Years_in_Business__c;
            }
            if(program.Industry__c != null){
                if(program.Credit_Score__c != null || program.Years_in_Business__c != null)
                    query += ' and ';   
                query += SObjectType.Program__c.fields.Restricted_Industry_List__c.Name+'  excludes (\''+program.Industry__c+'\') ';
            }
            
            if(program.Min_Monthly_Deposits__c != null){
                if(program.Credit_Score__c != null || program.Years_in_Business__c != null || program.Industry__c != null)
                    query += ' and ';   
                query += SObjectType.Program__c.fields.Min_Monthly_Deposits__c.Name+' <= '+program.Min_Monthly_Deposits__c;
            }
            if(program.Preffered_Programs__c){
                if(program.Credit_Score__c != null || program.Years_in_Business__c != null || program.Industry__c != null ||
                    program.Min_Monthly_Deposits__c != null)
                    query += ' and ';   
                query += SObjectType.Program__c.fields.Preffered_Programs__c.Name+' = '+program.Preffered_Programs__c;  
            }
        //}
        if(sortExpression!='Score'){
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        query += ' order by '+sortFullExp;
        }
        
        //programList = Database.query(query);  
        for(Program__c prgm : Database.query(query)){
            //programMap.put(prgm.Id,prgm);
            Decimal score = 0; 
            Integer totalScore = 0;
            if(program.Credit_Score__c != null ){
                totalScore++;
                if(prgm.Credit_Score__c == program.Credit_Score__c)
                    score++;    
            }
            if(program.Years_in_Business__c != null ){
                totalScore++;
                if( prgm.Years_in_Business__c == program.Years_in_Business__c )
                    score++;    
            }
            if(program.Min_Monthly_Deposits__c != null ){
                totalScore++;
                if( prgm.Min_Monthly_Deposits__c == program.Min_Monthly_Deposits__c )
                    score++;
            }
            if(program.Industry__c != null ){
                totalScore++;
                if( prgm.Industry__c == program.Industry__c)
                    score++;
            }
            if(program.Preffered_Programs__c){
                totalScore++;
                if( prgm.Preffered_Programs__c == program.Preffered_Programs__c )
                    score++;
            }
            
            if(score != 0)
                score = ((score  / totalScore) *100);   
                
            // Calculate Eligible Funding Amount= Gross Monthly Sales * Fun Amt - % of monthly gross sales
            Decimal eligibleFunAmt; 
            if(Opp.Account.Gross_monthly_Sales__c != null && prgm.Funding_Amt_of_Monthly_Gross_Sales__c != null)
                eligibleFunAmt = (Opp.Account.Gross_monthly_Sales__c * prgm.Funding_Amt_of_Monthly_Gross_Sales__c)/100;
            else
                eligibleFunAmt = 0;
                
            programWrapperList.add(new ProgramWrapper(prgm, false, Integer.valueOf(score), 
                                                      eligibleFunAmt, (totalScore < 2 ? true : false )));   
        }
        this.getAvailableAttachments();
        
        prefferedPgm = false;   
        if(sortExpression=='Score')
            programWrapperList.sort();
    }
    
    public void getAvailableAttachments(){
        Integer cnt = 1;
        AttachmentWrapperList.clear();
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
                selectDeselectAtt1();
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
    
    // Function to Create Submission and Update Chatter w/o sending Email
    public void createWithoutSending(){
                channelVal = 'Create without Sending';
                selectDeselectAtt1();
        if(programMap.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Select Program')); 
            return;
        }
        
        list<Submission__c> submissionList = new list<Submission__c>();
        for(Id pgmId : programMap.keySet()){
                submissionList.add(createSubmission(programMap.get(pgmId).Bank__r.Main_Contact__c,
                                                                                programMap.get(pgmId).Bank__c,
                                                                                pgmId,
                                                                                programMap.get(pgmId).Submission_Email__c));
                applicationSentToPgm.add(programMap.get(pgmId));
        }
        try{
                        if(submissionList.size() > 0){
                                insert submissionList;
                                system.debug('***submissionList***'+submissionList);
                                if(opp.StageName == 'Prospecting' || opp.StageName == 'Application Sent' || opp.StageName == 'Application In' ||
                opp.StageName == 'Application Missing Info' || opp.StageName == 'Declined' || opp.StageName == 'Closed Lost' ||
                opp.StageName == 'Renewal Prospecting' || opp.StageName == 'Renewal Requested' )
                {
                        update (new Opportunity (Id = oppId ,StageName = 'Underwriting'));
                }
                                postOnChatter(null);
                                showThankyouPage = true;
                        }
        }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage())); 
        }
    }// End CreateWithoutSending
    
    public void sendSelectedAttachments(){
        channelVal = 'Send with Attachments';
                selectDeselectAtt1();
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
        
        if(AttachmentWrapperList.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'There are no Attachments for Submission'));        
        }
        else if(mapPgmAttachment.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.label.Submission_SelectProgram));    
        }else{
            this.sendMail(mapPgmAttachment);
        }
    }
    
    public void sendWithoutAttachment(){
        channelVal = 'Send without Attachments';
                selectDeselectAtt1();
        if(mailsDetails.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.label.Submission_TemplateMissingError)); 
            return;
        }
        try{
            list<Submission__c> submissionList = new list<Submission__c>();
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
                
            if(programMap.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.label.Submission_SelectProgram)); 
                return;
            }
            
            
            for(Id pgmId: programMap.keySet()){
                if(!programMap.isEmpty() && programMap.get(pgmId).Submission_Email__c <> null){
    
                    Messaging.EmailFileAttachment[] fileAttachments = new Messaging.EmailFileAttachment[]{};
                    //Creating Messaging.Singleemailmessage instance to create a message.
                    Messaging.Singleemailmessage message = new Messaging.Singleemailmessage();
               
                    List<String> senderAddresses = new List<String>();
                    List<String> CCAddress = new List<String>();
                    List<String> BCCAddress = new List<String>();
                    
                    if(mailsDetails != null && mailsDetails[0].CC_Address__c != null && mailsDetails[0].CC_Address__c != '' &&
                                                                   mailsDetails[0].CC_Address__c.contains('@')){
                        CCAddress = mailsDetails[0].CC_Address__c.split(',');
                    }
                    
                    if(mailsDetails != null && mailsDetails[0].Bcc_Address__c != null && mailsDetails[0].Bcc_Address__c != '' && 
                                                                  mailsDetails[0].Bcc_Address__c.contains('@') ){
                        BCCAddress = mailsDetails[0].Bcc_Address__c.split(',');
                    }
                    senderAddresses.add(programMap.get(pgmId).Submission_Email__c); //Adding Email Id.
                    message.setToAddresses(senderAddresses);
                    message.setCcAddresses(CCAddress);
                    message.setBccAddresses(BCCAddress);
                    String Subject = '';
                    if(opp.AccountId != null)
                    Subject = mailsDetails[0].Subject__c + ': ' + opp.Account.Name;
                    else
                    Subject = mailsDetails[0].Subject__c;
                    
                    message.setSubject(Subject);
                    
                    MessageBody = messageBodyContent();
                    
                    message.setHtmlBody(MessageBody); 
                    //Send the Attachment Email to Banks Email address
                    allMails.add(message);
                    
                    submissionList.add(createSubmission(programMap.get(pgmId).Bank__r.Main_Contact__c,
                                                                                        programMap.get(pgmId).Bank__c,
                                                                                        pgmId,
                                                                                        programMap.get(pgmId).Submission_Email__c));
                    
                    applicationSentToPgm.add(programMap.get(pgmId));
                }else if(programMap.get(pgmId).Submission_Email__c == null){
                    applicationNotSentToPgm.add(programMap.get(pgmId));
                }
            }
    
            if(submissionList.size() > 0)
                    insert submissionList;
            if(allMails.size() > 0){
                
                 List<Messaging.SendEmailResult> results =  Messaging.sendEmail(allMails); 
                 postOnChatter(null);
                
                //After the mail has been sent show a thankyou Page
                showThankYouPage = true;
                if(opp.StageName == 'Prospecting' || opp.StageName == 'Application Sent' || opp.StageName == 'Application In' ||
                opp.StageName == 'Application Missing Info' || opp.StageName == 'Declined' || opp.StageName == 'Closed Lost' ||
                opp.StageName == 'Renewal Prospecting' || opp.StageName == 'Renewal Requested' )
                {
                        update (new Opportunity (Id = oppId ,StageName = 'Underwriting'));
                }
            }else{
                //No email sent
                showThankYouPage = true;
            }
        }//try ends
        catch(Exception e){
                if(e.getMessage() != '' && e.getMessage() != null && e.getMessage().contains(EMAIL_LIMIT)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.Submission_EmailLimitExceeded));               
                }else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));   
        }
    }
    
    public void sendMail(map<Id,list<Attachment>> mapPgmAttachment){
        try{
            
            
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
                    List<String> CCAddress = new List<String>();
                    List<String> BCCAddress = new List<String>();
                    if(mailsDetails != null && mailsDetails[0].CC_Address__c != null && mailsDetails[0].CC_Address__c != '' &&
                                                                   mailsDetails[0].CC_Address__c.contains('@')){ 
                        CCAddress = mailsDetails[0].CC_Address__c.split(',');
                    }
                    if(mailsDetails != null && mailsDetails[0].Bcc_Address__c != null && mailsDetails[0].Bcc_Address__c != '' && 
                                                                  mailsDetails[0].Bcc_Address__c.contains('@') ){
                        BCCAddress = mailsDetails[0].Bcc_Address__c.split(',');
                    }
                    senderAddresses.add(programMap.get(pgmId).Submission_Email__c); //Adding Email Id.
                    message.setToAddresses(senderAddresses);
                    message.setCcAddresses(CCAddress);
                    message.setBccAddresses(BCCAddress);
                    String Subject = '';
                    if(opp.AccountId != null)
                    Subject = mailsDetails[0].Subject__c + ': ' + opp.Account.Name;
                    else
                    Subject = mailsDetails[0].Subject__c;
                    message.setSubject(Subject);
                    MessageBody = messageBodyContent();
                    message.setHtmlBody(MessageBody); 
                    //Send the Attachment Email to Banks Email address
                    allMails.add(message);
                    
                    submissionList.add(createSubmission(programMap.get(pgmId).Bank__r.Main_Contact__c,
                                                                                        programMap.get(pgmId).Bank__c,
                                                                                        pgmId,
                                                                                        programMap.get(pgmId).Submission_Email__c));
                    
                    applicationSentToPgm.add(programMap.get(pgmId));
                }else if(programMap.get(pgmId).Submission_Email__c == null){
                    applicationNotSentToPgm.add(programMap.get(pgmId));
                }
            }
            
            if(submissionList.size() > 0)
                    insert submissionList;
            if(allMails.size() > 0){
                
                 List<Messaging.SendEmailResult> results =  Messaging.sendEmail(allMails); 
                 postOnChatter(mapPgmAttachment);
                //After the mail has been sent show a thankyou Page
                showThankYouPage = true;
                if(opp.StageName == 'Prospecting' || opp.StageName == 'Application Sent' || opp.StageName == 'Application In' ||
                opp.StageName == 'Application Missing Info' || opp.StageName == 'Declined' || opp.StageName == 'Closed Lost' ||
                opp.StageName == 'Renewal Prospecting' || opp.StageName == 'Renewal Requested' )
                        update (new Opportunity (Id = oppId ,StageName = 'Underwriting'));
                        
            }else{
                //No email sent
                showThankYouPage = true;
            }
        }
        catch(Exception e){
                
                if(e.getMessage() != '' && e.getMessage() != null && e.getMessage().contains(EMAIL_LIMIT)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,system.label.Submission_EmailLimitExceeded));               
                }else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
            //return null;  
        }
    }
    
    public String messageBodyContent(){
        List<Document> docuLst = new List<Document>();
        String query = 'Select d.SystemModstamp, d.Name, d.Id From Document d where name = \''+LOGO_NAME+'\'';
        docuLst = Database.query(query);
        if(docuLst <> null && docuLst.size()>0){
           string strOrgId = UserInfo.getOrganizationId();
           string orgInst = URL.getSalesforceBaseUrl().getHost();
           string strDocUrl = URL.getSalesforceBaseUrl().getProtocol() + '://c.' + orgInst + '/servlet/servlet.ImageServer?id=' + docuLst[0].Id + '&oid=' + strOrgId;
           String messageBody = '<html><body><div align="center"><img src="'+strDocUrl+'" alt="Company Logo"></img></div>'+mailsDetails[0].Message_Body__c+'</body></html>';
           return messageBody;
        }
        else{
           String messageBody =  mailsDetails[0].Message_Body__c; 
           system.debug('messageBody@@@'+messageBody);
           return messageBody;
        }
        
    }
    
    public PageReference cancel(){
        return new PageReference('/'+OppId);
    }
        
    //For Chatter Post
    private void postOnChatter(map<Id,list<Attachment>> mapPgmAttachment){  
        
        String chatterFeed = '' ;
        String programBankName = '';
        FeedItem oChatterFeedItem = new FeedItem();
        
        if(mapPgmAttachment != null){
            for(Id pgmId : mapPgmAttachment.keySet()){
                
                programBankName += (programBankName == '' ? '' : ', ') +programMap.get(pgmId).Bank__r.Name ; 
                
            }
        }else{
            for(Id pgmId : programMap.keySet()){
                
                programBankName += (programBankName == '' ? '' : ', ') +programMap.get(pgmId).Bank__r.Name ; 
                
            }
        }
        chatterFeed = System.Label.Submission_ChatterFeedBody + ' ' + programBankName + 
                                ' by ' + userObj.FirstName + ' ' + userObj.LastName;
    
        PostToChatterUtility objClass = new PostToChatterUtility();
        try{
                insert objClass.postToChatter(chatterFeed , OppId);
        }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));   
        }
    }
    
    public PageReference ViewSortedData_Program(){
        if(sortExp != 'Score')
            getPrograms();
        else
           programWrapperList.sort(); 
         return null;
    }
    
    public void checkUncheckAttachements(){
        String isSelected = ApexPages.CurrentPage().getParameters().get('isSelected');
        String attId = ApexPages.CurrentPage().getParameters().get('attId');
        
        if(attId != null && attId != '' ){
                for(AttachmentWrapper attWrapper : AttachmentWrapperList){
                        if(attWrapper.attachment.id == attId){
                                if(isSelected == 'true'){
                                        attWrapper.selectedPrograms.clear(); 
                                }else{
                                        //attWrapper.selectedPrograms.addAll(attWrapper.options);
                                        for(Id pgmId : attWrapper.ProgramMap.keySet()){
                                                attWrapper.selectedPrograms.add(pgmId);
                                        }
                                }
                        }
                }       
        }
    }
    
    public void resetAttachments(){
        this.populateProgramMap();
        this.getAvailableAttachments();
    }
    
    public void populateProgramMap(){
        programMap.clear();
        for( ProgramWrapper wrapper: programWrapperList){
            if(wrapper.isSelected){
                programMap.put(wrapper.prgm.Id,wrapper.prgm);
            }
        }
    }
    
     public void selectDeselectAtt1(){
        
        system.debug('***programWrapperList***'+programWrapperList);
        programMap.clear();
        for( ProgramWrapper wrapper: programWrapperList){
                
                if(wrapper.isSelected == true)
                        programMap.put(wrapper.prgm.Id,wrapper.prgm);
                        system.debug('***programMap***'+programMap);
            }
        
        
        //In attachment wrappper for all the att add the selected option
                for(AttachmentWrapper attWrapper : AttachmentWrapperList){
                        attWrapper.selectedPrograms.clear();
                        for(ProgramWrapper wrapper: programWrapperList){
                        if(wrapper.isSelected == true){         
                                //Auto select the recently added program
                                attWrapper.selectedPrograms.add(wrapper.prgm.Id); 
                                system.debug('***selectedPrograms***'+attWrapper.selectedPrograms);
                        }
                        system.debug('***attWrapper.selectedPrograms***'+attWrapper.selectedPrograms);
                        //Also populate the program map with the recently selected value
                        if(programMap.size() > 0 && programMap.containsKey(wrapper.prgm.Id)){
                                attWrapper.programMap.put(wrapper.prgm.Id, programMap.get(wrapper.prgm.Id));
                        }               
                        else if(attWrapper.programMap.size() >  0 && attWrapper.programMap.containsKey(wrapper.prgm.Id) ){
                        attWrapper.programMap.remove(wrapper.prgm.Id);
                        }
                        
                        attWrapper.options.clear();
                        system.debug('****attWrapper.programMap***'+attWrapper.programMap);
                        //for(String pgm : attWrapper.programMap.keySet()){
                        for(String pgm : attWrapper.selectedPrograms){
                         attWrapper.options.add(new selectOption(pgm, attWrapper.programMap.get(pgm).Name)); 
                    }
                }//
        }
     }
    
   /* public void selectDeselectAtt(){
        String isSelected = ApexPages.CurrentPage().getParameters().get('isPgmSelected');
        String pgmId = ApexPages.CurrentPage().getParameters().get('pgmId');
        
        for( ProgramWrapper wrapper: programWrapperList){
            // 
            if(pgmId == wrapper.prgm.Id){
                if(isSelected == 'false')
                        programMap.put(wrapper.prgm.Id,wrapper.prgm);
                else if(programMap.size() > 0 && programMap.containsKey(wrapper.prgm.Id))
                        programMap.remove(wrapper.prgm.Id);
            }
        }
        
        //In attachment wrappper for all the att add the selected option
        for(AttachmentWrapper attWrapper : AttachmentWrapperList){
                
                //Auto select the recently added program
                attWrapper.selectedPrograms.add(pgmId);
                
                //Also populate the program map with the recently selected value
                if(programMap.size() > 0 && programMap.containsKey(pgmId)){
                        attWrapper.programMap.put(pgmId, programMap.get(pgmId));
                }
                else if(attWrapper.programMap.size() >  0 && attWrapper.programMap.containsKey(pgmId) ){
                        attWrapper.programMap.remove(pgmId);
                }
                
                attWrapper.options.clear();
                for(String pgm : attWrapper.programMap.keySet()){
                 attWrapper.options.add(new selectOption(pgm, attWrapper.programMap.get(pgm).Name));
            }
        }
    }*/
    
    
    // Function used to create Submission records
    public Submission__c createSubmission(Id pMainContact, Id pBank,Id pPgmId, String pEmail){
        system.debug('****channelVal***'+channelVal);
        Submission__c submission = new Submission__c(Opportunity__c = OppId,
                                                     Contact__c = pMainContact,
                                                     Status__c = 'UW',
                                                     Funder__c = pBank,
                                                     Program__c = pPgmId,
                                                     Email__c = pEmail,
                                                     Channel__c = channelVal,
                                                     Date_Submitted__c = system.now()); 
        system.debug('****submission***'+submission);
        return submission;      
    }
    
    //Wrapper Class contains Attachment Object and isRequired to keep track of which Attachment is isRequired 
    public class AttachmentWrapper{
        public Integer cnt                {get; set;}
        public Attachment attachment      {get; set;}
        public boolean isRequired         {get; set;}
        public List<selectOption> options {get; set;}
        public String[] selectedPrograms          {get; set;} 
        public map<Id,Program__c> programMap {get; set;}
        public AttachmentWrapper(Integer pCnt, Attachment pAttachment ,Boolean pIsRequired, map<Id,Program__c> pProgramMap){
            cnt = pCnt;
            selectedPrograms = new String[]{};
            for(String pgm : pProgramMap.keySet()){
                selectedPrograms.add(pgm);
            }
            attachment = pAttachment;
            isRequired = pIsRequired;
            programMap = pProgramMap;
            options = new List<selectOption>();
            for(String pgm : pProgramMap.keySet()){
                 options.add(new selectOption(pgm, pProgramMap.get(pgm).Name));
            }
        }
    }
    
    //Wrapper Class contains Program__c Object and isSelected to keep track of which Program__c is selected 
    public class ProgramWrapper implements Comparable{
        public Program__c prgm              {get; set;}
        public boolean isSelected           {get; set;}
        public Integer score                {get; set;}
        public Decimal PotentialFundingAmt  {get; set;}
        public Boolean missingInfo          {get; set;}
      
        public ProgramWrapper(Program__c pProgram ,Boolean pIsSelected,Integer pScore,Decimal pPotentialFundingAmt, boolean pMissingInfo){
            prgm = pProgram;
            isSelected = pIsSelected;
            score = pScore;
            PotentialFundingAmt = pPotentialFundingAmt;
            missingInfo = pMissingInfo;
        }
        
        public Integer compareTo(Object ObjToCompare) {
            ProgramWrapper compareTo =(ProgramWrapper)ObjToCompare;
            if(SubmissionWizardController.sortDirection.equals('ASC')){
                if(score == compareTo.score)return 0;
                if(score > compareTo.score)return 1;
                return -1;
            }
            else{
                if(score == compareTo.score)return 0;
                if(score > compareTo.score)return -1;
                return 1;
            }
        }
    }
}