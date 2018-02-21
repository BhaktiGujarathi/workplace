/**************************************************************************************************
* Name               : DamacAnnouncementDetailController                                               
* Description        : An apex page controller to show the detail of the announcement and allow download                                           
* Created Date       : NSI - Diana                                                                        
* Created By         : 09/Feb/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          09/Feb/2017                                                              
**************************************************************************************************/

public class DamacAnnouncementDetailController {
    
    /**************************************************************************************************
            Variables used in the class
	**************************************************************************************************/
	public boolean isAuthorisedToUpload{set;get;}
	public Attachment headerAttachment{set;get;}
	public Announcement_Request__c announcementRequest{set;get;}
	public Contact contactInfo{set;get;}
	public Announcement__c announcement{set;get;}
	private String announcementId{set;get;}
	public transient Blob logoBlobfile{set;get;}
	public List<Attachment> downloadAttachments{set;get;}
	public Integer downloadAttachmentSize{set;get;}
	
	/**************************************************************************************************
    Method:         DamacAnnouncementDetailController
    Description:    Constructor executing model of the class 
	**************************************************************************************************/
	public DamacAnnouncementDetailController() {
	    
	    contactInfo = UtilityQueryManager.getContactInformation();
	    
		headerAttachment = new Attachment();
		isAuthorisedToUpload = ((contactInfo.Authorised_Signatory__c || 
								 contactInfo.Portal_Administrator__c || contactInfo.Owner__c ) == true)?true:false;
		downloadAttachments = new List<Attachment>();
		if(ApexPages.currentPage().getParameters().containsKey('Id')){
		    announcementId = ApexPages.currentPage().getParameters().get('Id');
		    announcement = UtilityQueryManager.getAnnouncementDetail(announcementId);
			getAnnouncementRequestDetail();


			for(Attachment attachment:[SELECT Id,Name
								   FROM Attachment WHERE
								   ParentId=:announcementId]){
				downloadAttachments.add(attachment);
			}
		}

		downloadAttachmentSize = downloadAttachments.size();
	}
	
	/*public PageReference saveAnnouncement(){

		try{
        
            announcementRequest.Generate_Announcement__c = true;
			upsert announcementRequest;

			system.debug('****'+logoBlobfile);

			if(null != logoBlobfile){
			    
			    headerAttachment.body =  logoBlobfile;
			    
			    if(String.isBlank(headerAttachment.parentId))
				    headerAttachment.parentId = announcementRequest.Id;
				    
				upsert headerAttachment;
			}

			
            logoBlobfile = null;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ' ' + 'Your details are recieved successfully. You will recieve an email shortly.'));
		}
		catch(Exception ex){
			system.debug('<<DamacAnnouncementsController : saveAnnouncement : >> '+ex.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' ' + ex.getMessage()));
		}
		
		return new PageReference('/Damac_Announcement_Detail?Id='+announcementId);
	}*/

	public void getAnnouncementRequestDetail(){
		announcementRequest = UtilityQueryManager.getAnnouncementRequest(announcementId,
			contactInfo.AccountID);

		system.debug('==> announcementRequest '+announcementRequest);
		if(null != announcementRequest && (null == announcementRequest.Agency__c || null == announcementRequest.Announcement__c)){
			announcementRequest = new Announcement_Request__c();
			announcementRequest.Agency__c = contactInfo.AccountID;
			announcementRequest.Announcement__c =announcementId;
			
		}
		
	}
    	

}