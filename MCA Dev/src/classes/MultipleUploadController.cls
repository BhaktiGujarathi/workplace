/**
 * Controller class for OppMultipleAttachment page
 *
 * Revision History:
 *  Version     Author            Date(dd/mm/yyyy)    Description
 *  1.0         Unknown           20/05/2014          Initial draft
 *  2.0         Ajinkya Hingne    12/12/2016          Changes to make page compatible with console
 *  3.0         Ajinkya Hingne    22/06/2017          Changes to remove use of Stip Attachment Object
 */
public class MultipleUploadController  {

    // Constant variable
    private static final String STIP_UPLOAD_TITLE = 'Upload Multiple Stip Documents';
    private static final String OPP_UPLOAD_TITLE = 'Upload Multiple Opportunity Documents';
    private static final String IS_CONSOLE_PARAM = 'isConsole';

    // get set variable
    //Picklist of integer values to hold file count
    public List<SelectOption> filesCountList    {get; set;}
    public boolean ShowPreview                  {get; set;}
    public String FileCount                     {get; set;}
    public Blob attachmentBody                  {get; set;}
    public String attachmentName                {get; set;}
    public Boolean isShowBtn                    {get; set;}
    public Boolean isError                      {get; set;}
    public Boolean isInConsole                  {get; set;}
    public Boolean showHeader                   {get; set;}
    public PageReference currentPageReference   {get; set;}
    public String indexToRemove                 {get; set;}
    //public transient List<attachment> oplist  {get; set;}
    public List<attachment> oplist              {get; set;}
    //Create list of Attachment object
    public List<Attachment> allFileList         {get; set;}
    // URL parameter value
    public String isStips                       {get; set;}
    public Set<String> attachIds;
    // URL paramater Name
    private String STIPS_NAME = 'isStips';
    private String STIPS_ID = 'stipID';
    private String attParentId;
    private String stipID;
    //Private Variables
    private String retURL;
    private String accId;
    OpportunityUtility utility;

    public string getbaseUrlOrg() {
        return MCAStringConstant.baseUrlOrg;
    }

    // Standard controller Constructor
    public MultipleUploadController(ApexPages.StandardController controller) {
        //Initialize
        currentPageReference = System.currentPagereference();
        attParentId = System.currentPagereference().getParameters().get('id');
        retURL = System.currentPagereference().getParameters().get('retURL');
        accId = System.currentPagereference().getParameters().get('accID');
        isStips = System.currentPagereference().getParameters().get(STIPS_NAME);
        stipID = System.currentPagereference().getParameters().get(STIPS_ID);
        attachIds = new Set<String>();
        //setUplaodTitle();
        isError = false;
        isShowBtn = true;
        filesCountList = new List<SelectOption>() ;
        FileCount = '' ;
        allFileList = new List<Attachment>() ;
        isInConsole
            = ApexPages.currentPage().getParameters().get(IS_CONSOLE_PARAM) == '1' ? true : false;
        //Adding values count list - you can change this according to your need, Now it is 10
        for(Integer i = 1 ; i < 11 ; i++) {
            filesCountList.add(new SelectOption(''+i , ''+i));
        }
        String isUpload = ApexPages.currentPage().getParameters().get('isUpload');
        if(isUpload !=null && isUpload !=''){
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.Severity.Confirm,
                ' File(s) are uploaded successfully')
            );
        }
        oplist = new List<attachment>();
        getAllAttachment();
        configureHeaderVisibility();
    }// End MultipleUploadController()

    // Method to set header visibility
    private void configureHeaderVisibility() {
        // Hide header when page is opened from console
        showHeader = !isInConsole;
    }

    // Set upload section title
    /*private void setUplaodTitle() {
        if(!isStips.contains('true'))
            uploadTitle = OPP_UPLOAD_TITLE;
        else
            uploadTitle = STIP_UPLOAD_TITLE;
    }// End setUplaodTitle()*/

    // Get all attchment
    public void getAllAttachment() {
        //string test = createAttQuery();
        //Query only those fields which is required to display in attachments column on page
        oplist = Database.query(createAttQuery());
        /*oplist = [Select Id,
                        Name,
                        IsPrivate,
                        CreatedById,
                        LastModifiedDate,
                        Description
                FROM Attachment where ParentId= :System.currentPageReference().getParameters().get('id')
                Order by LastModifiedDate DESC]; */
    }// End getAllAttchment()

    // create dynamic query
    public String createAttQuery() {
        String attchQuery;
        attchQuery =  'SELECT Id'
                               +',Name'
                               +',IsPrivate'
                               +',CreatedById'
                               +',LastModifiedDate'
                               +',Description'
                        +' FROM Attachment '
                        +'WHERE ParentId =\''+attParentId+'\'';
        if(isStips.contains('true')) {
            attchQuery = addWhereClause(attchQuery);
        }
        attchQuery += ' Order by LastModifiedDate DESC';
        return attchQuery;
    }// end createAttQuery()

    //Add where clause
    public String addWhereClause(String attchQuery) {
        for(Stips__c objStipAttc : [SELECT id
                                         , Attachments_IDs__c
                                      FROM Stips__c
                                     WHERE Id =: stipID]) {
            if(objStipAttc.Attachments_IDs__c <> null && objStipAttc.Attachments_IDs__c <> '')
                attachIds.addAll(objStipAttc.Attachments_IDs__c.split(','));
        }// end for
        attchQuery += ' AND '
                   +'ID IN :attachIds';
        return attchQuery;
    }//end addWhereClause()

    // Used to update the attachment.
    public void saveme() {
        try {
            update oplist;
        }
        catch(Exception e) {
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
        }// end try - catch
    }// end saveme()

    // This action is called from upload button to insert attchment.
    public PageReference SaveAttachments() {
        // to get id of the OppRecord from the URL
        String isSucess = 'Error';
        // Checking Opp Record
        if(attParentId == null || attParentId == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,
                'No record is associated. Please pass record Id in parameter.')
            );
            FileCount = '';
            return null;
        }// end if

        if(FileCount == null || FileCount == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,
                'Please select how many files you want to upload.')
            );
            FileCount = '';
            return null;
        }//end if
        // Create a list of attachemnt(Standard object) type
        Transient List<Attachment> listToInsert = new List<Attachment>();
        //Attachment a = new Attachment(parentId = attParentId , name=myfile.name, body = myfile.body);
        for(Attachment attachmnt: allFileList) {
            // for checking attachment file name and body
            if(attachmnt.name != '' && attachmnt.name != '' && 
                attachmnt.body != null && attParentId <> null && attParentId <> '')
                listToInsert.add(new Attachment(
                    parentId = attParentId,
                    name = attachmnt.Name,
                    body = attachmnt.Body,
                    description = attachmnt.Description)
            ) ;
        }// end for
        allFileList.clear();
        //Inserting attachments
        if(listToInsert.size() > 0) {
            try {
                insert listToInsert;
                if(isStips.contains('true') && stipID <> null && stipID <> ''){
                    createStipAtt(listToInsert);
                }//end if
                isSucess ='success';
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO, 
                    listToInsert.size() + ' file(s) are uploaded successfully')
                );
                FileCount = '' ;
            } catch(exception ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO, 
                    ex.getMessage()));
            }
        } else {
            // show error message if no file is uploaded
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,
                'Please select at-least one file')
            );
            FileCount = '' ;
            return currentPageReference;
        }// end else - if

        //Used for submission wizard to redirect to wizard on Upload
        if(retURL == null){
            //Refresh page after uploading attachment and return to same page
            ID ContID= ApexPages.currentPage().getParameters().get('id');
            PageReference pg=new PageReference('/'+ContID);
            pg.getParameters().put('isUpload',isSucess);
            isShowBtn = true;
        }
        listToInsert.clear();
        getAllAttachment();
        FileCount = '';
        return null;
    }// end SaveAttachments()

    // Create Stip - Attachment record
    public void createStipAtt(List<Attachment> listAttachment) {
        Map<Id, Stips__c> stipsToUpdate = new Map<Id, Stips__c>([SELECT Id
                                                                      , Attachments_IDs__c
                                                                   FROM Stips__c
                                                                  WHERE Id = :stipID]);
        for(Attachment objAttach :listAttachment) {
            if(stipsToUpdate.containskey(stipID)) {
                String attchId = objAttach.Id;
                if(String.isBlank(stipsToUpdate.get(stipID).Attachments_IDs__c)) {
                    stipsToUpdate.get(stipID).Attachments_IDs__c = attchId;
                } else {
                    stipsToUpdate.get(stipID).Attachments_IDs__c += ','+attchId;
                }
            }
        }//end for
        //try {
            // Insert list
            if(stipsToUpdate.values().size() > 0)
                update stipsToUpdate.values();
        /*} catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
        }*///end try - catch
    }// end

    // close button url
    public PageReference closedRedirect() {
        if(isStips == 'true') {
            return new PageReference(retURL+ '?' + IS_CONSOLE_PARAM+'='+(isInConsole ? '1' : '0'));
        }
        else {
            return new PageReference(retURL+'&accId='+accId+'&'+IS_CONSOLE_PARAM+'='+(isInConsole ? '1' : '0'));
        }
    }// end closedRedirect()

    // count number of attachment to be uploaded
    public void ChangeCount() {
        isShowBtn = false;
        allFileList.clear() ;
        //Adding multiple attachments instance
        if(FileCount != Null)
        for(Integer i = 1 ; i <= Integer.valueOf(FileCount) ; i++)
            allFileList.add(new Attachment()) ;
        //return null ;
    }// end ChangeCount

    /**
     * To delete attachment records
     */
    public void deleteAttachment() {
        try{
            if (indexToRemove != null) {
                Attachment record = [SELECT Id
                                    FROM Attachment
                                    WHERE Id = :indexToRemove];
                delete record;
                oplist = new List<attachment>();
                getAllAttachment();
            }//end if
        }catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }

    // Used to insert attachment
    public void CollectData() {
        OpportunityUtility utility = new OpportunityUtility();
        utility.collectData();
        if(isStips.contains('true') && stipID <> null && stipID <> ''){
            createStipAtt(utility.lstAttach);
            //getAllAttachment();
        }
        getAllAttachment();
    }//  end CollectData()
}