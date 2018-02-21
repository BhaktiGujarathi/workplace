/**
 * Version     Date            Author              Comment
 * 1.0        Nov-16-2015     Yogesh Mahajan      Initial Draft[]
 * 1.1        Nov-21-2015     Yogesh Mahajan      

**/

public with sharing class SubmissionSiteController{
    private static final String ERROR_MSG = 'Invalid submission ID provided in URL';
    private static final String SUBMISSION_API_NAME = 'Submission__c';
    private static final String SUBMISSION_FIELDSET = 'Submission_Wizard_Field_Set';
    
    public Submission__c[] submission ;
    public List<Attachment> listAttachment;
    public List<wrapperAttachment> listWrapperAttachment;
    public String submissionID;
    public static String oppId  {get;set;}
    //public String imageURL      {get;set;}
    public Boolean isNext       {get;set;}
    public Boolean isPrev       {get;set;}
    public Boolean isVisible       {get;set;}
        
    private Integer totalRecs = 0;
    private Integer offsetSize = 0;
    private Integer limitSize = 5;
    private Boolean isValidateSub = true;
    public boolean hideSelectedAttachField{get; set;}
    
    public static boolean isAccess{get; set;}
    
    //constructor to instansiate list
    public SubmissionSiteController() {
        isVisible = true;        
        listAttachment= new List<Attachment>();
        listWrapperAttachment = new List<wrapperAttachment>();
        
        //createImageURL();
        
        
        
    }
    
    //get submissions of opportunity to display fields on page
    public Submission__c getSubmission() {
        if(isValidateSub && submission != null && submission.size() > 0) {
        
            return submission[0];
        }
        return null;
    }
    
    // create cloudmybiz logo URL for header
    /*public void createImageURL() {
        imageURL='https://c.ap1.content.force.com/servlet/servlet.FileDownload?file=';
        List< document > documentList = [SELECT name 
                                         FROM document 
                                         WHERE Id = :Label.SubmissionWizard_LogoName];
        system.debug('---->'+documentList);
        if(documentList.size() > 0) {
            imageURL = imageURL+documentList[0].id;
        }//End If
        system.debug('---1->'+imageURL);
    }//End ImageController
    */
    //It is used to get submision and related record value.
    public PageReference querySubmission() {        
        String submissionIDToDecrypt = String.valueOf(apexpages.currentpage().getparameters().get('id'));
        if(submissionIDToDecrypt != null)
        {
            Blob cryptoKey = Blob.valueOf('1234567890123456');
            Blob encodedEncryptedBlob = EncodingUtil.base64Decode(submissionIDToDecrypt);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES128', cryptoKey, encodedEncryptedBlob);
            submissionID = decryptedData.toString();
            
            String query = '';
            String querySubString ='';
            if(submissionID != null) 
            {
                
                query = generateQuery(SUBMISSION_API_NAME, SUBMISSION_FIELDSET);
                
                if(query <>  null && query <> '')
                    querySubString = query.substringBefore('FROM');
                    querySubString += ',Time_Frame__c FROM';
                    querySubString += query.substringAfter('FROM');
                    query = querySubString;
                    submission = Database.query(submissionWhereClause(query, submissionID));
                if(submission.size() <= 0 ) {
                    isValidateSub = false;
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error, ERROR_MSG));
                } else {
                   
                    totalRecs = [SELECT count() 
                                FROM Attachment
                                WHERE ParentID =: submission[0].Opportunity__c];
                    
                } 
               if(submission[0].Time_Frame__c != null && (submission[0].Time_Frame__c < system.Today()))
               {
                    
                    PageReference pageRef = new PageReference('/apex/SiteErrorPage');
                    //pageRef.setRedirect(true); 
                    return pageRef;
                }
               
            } 
            else 
            {
                isValidateSub = false;
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error, ERROR_MSG));
            }
        }
        return null;
    }
    
    // Add oppid for where clause 
    public String submissionWhereClause(String query, String objectID) {
        return query + ' WHERE Id =\'' +objectID+ '\' ' ;
    }//End oppWhereClause()
    
    //get list of attachment into wrapper class and list is display on page
    public list<wrapperAttachment> getlistWrapperAttachment() {
        getnxt();
        getprev();
        listWrapperAttachment.clear();
        if(submission <> null && submission.size() > 0) {
            if(submission[0].Selected_Attachment_Id__c <> null && submission[0].Selected_Attachment_Id__c <> '') {
                List<String> listSubmissionAtt = processString(submission[0].Selected_Attachment_Id__c);
                if(submissionID != null 
                    && submission <> null 
                    && submission.size() > 0
                    && submission[0].Opportunity__c <> null) {
                     /*AggregateResult[] groupedResults = [SELECT SUM(BodyLength)totalSize FROM Attachment];
                     //Attachment test = groupedResults[0].get('totalSize');
                    if(((decimal)(groupedResults[0].get('totalSize'))/(1024*1024)).setScale(2) >= 15)
                        isVisible = false;*/
                     
                     //to fetch attachment and add it into wrapper list to display on vf page
                     listAttachment = [
                                     SELECT id
                                          , Name
                                          , Description
                                          , LastModifiedDate
                                          , BodyLength
                                          , CreatedDate
                                      FROM Attachment
                                      WHERE ParentID =: submission[0].Opportunity__c
                                        AND Id IN :listSubmissionAtt];
                                      //LIMIT :limitSize OFFSET :offsetSize
                    //];
                    
                    oppId = submission[0].Opportunity__c;
                    if(listAttachment  != Null) {
                        for(Attachment attachInstance :listAttachment) {
                            listWrapperAttachment.add(new wrapperAttachment(attachInstance));
                        }
                    }
                    return listWrapperAttachment;
                }
            }else {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error, 'Zero attachments are related to this submission'));
            }//end else - if
        } else {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error, ERROR_MSG));
        }// end else - if    
        return null;
    }
    
    // Pagination next, previous methods start 
    public void FirstPage() {
        offsetSize = 0;
    }
    
    public void previous() {
        offsetSize = offsetSize - limitSize;
    }
    
    public void next() {
        offsetSize = offsetSize + limitSize;
    }
    
    public void LastPage() {
        offsetSize = (totalrecs - math.mod(totalRecs,limitSize)) - 1;
    }
    
    public void getprev() {
        if(offsetSize == 0)
            isPrev = false;
        else
            isPrev =  true;
    }
    
    public void getnxt() {
        if((offsetSize + limitSize) >= totalRecs)
            isNext =  false;
        else
            isNext =  true;
    }
    
    //to get attachments to download from vf page
    @RemoteAction 
    public static List<AttachmentResponse> getAttachments(String oppIdVal, List<String> attID) {
            //system.debug('attID ---->'+attID);
            //system.debug('attID ---->'+isAllDownload);
            List<AttachmentResponse> listAttch = new List<AttachmentResponse>();
            List<Attachment> listAttchment = new List<Attachment>();
            try{
               /* if(isAllDownload) {
                    listAttchment = [SELECT id
                                            , Name
                                            , body
                                    FROM Attachment 
                                    WHERE ParentId  =:oppIdVal];
                } else {*/
                    listAttchment = [SELECT id
                                            , Name
                                            , body
                                    FROM Attachment 
                                    WHERE ParentId  =:oppIdVal
                                        AND id IN: attID];
                //}//End Else - If
                //system.debug('attID ---->'+listAttchment);
                if(listAttchment.size() > 0){
                    for(Attachment objAttachment :listAttchment) {
                        
                        listAttch.add(new AttachmentResponse((objAttachment.Name).substringBeforeLast('.'), 
                            (objAttachment.Name).substringAfterLast('.'), 
                            EncodingUtil.base64Encode(objAttachment.body)));
                    }// End For
                }//end If
            } catch(Exception e) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error, e.getMessage()));
            }
            return listAttch;
    }
    
     // Use to create query using fieldset
     public String generateQuery(String objectAPIName, String fieldSetName) {
        // To store dynamic query
        
        String query = '';
        Boolean isFieldPresent = false;
        try{
            if( objectAPIName != null ){
                query = 'SELECT ';
                
                //Get field set values.
                //List<Schema.FieldSetMember> lstFields = Id.valueOf(objectID).getSObjectType().getDescribe().fieldsets.getMap().get(fieldSetName).getFields();
                List<Schema.FieldSetMember> lstFields = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
                
                for(Schema.FieldSetMember strField : lstFields) {
                    isFieldPresent = true;
                    query += strField.getFieldPath() + ',';
                } //End of for loop for fields
                query = query.substring(0,query.length()-1);
                query += ' FROM ' + objectAPIName;
            }//End IF
        } catch(Exception e) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.error, e.getMessage()));
        }
        if(isFieldPresent)
            return query;
        else 
            return null;
    }// End generateQuery()
    
    // get all comma seprate id into set
    public List<String> processString(String selectedAttId) {
        return selectedAttId.split(',');
    }// End processString()
       
    //wrapper class for attachments and boolean to select multiple attachment
    public class wrapperAttachment {
        public Boolean isChecked{get; set;}
        public Attachment attachmentInstance{get; set;}
        public Decimal sizeKB{get;set;}
        
        //constructor of wrapper class
        public wrapperAttachment(Attachment attachmentInstance) {
            isChecked = false;
            this.attachmentInstance = attachmentInstance;
            this.sizeKB = ((decimal.valueof(attachmentInstance.BodyLength))/1024).setScale(2);
        }
    }
    
    // Wrapper to store attchemnt data
    // Note javascript don't no the object structure like Attchement, account, lead
    public class AttachmentResponse{
        public String attName {get;set;}
        public String nameExt {get;set;}
        public String attchBody {get;set;}
        public AttachmentResponse(String attName, String nameExt, String attchBody){
            this.attName = attName;
            this.nameExt = nameExt;
            this.attchBody = attchBody;
        }
    } 
    
    
}