/**
 * @Class Name: PieChartController 
 * @Description: This class is used to query on UFHT__Ultra_Track_Container__c and Attachment to 
 *               fetch its value and display in Google Pie Chart .
 * ===================================================================================================
 *   Version   | Date        | Author             | Comments
 * ---------------------------------------------------------------------------------------------------
 *   1.0       | 23/01/2017  | Eternus Solutions  | 1. Created the class for above functionality.
 * ===================================================================================================
**/
public class PieChartControllerNew {
    /**
     * @Author: Eternus Solutions
     * @Description: FetchContainerData method fetches the data from UFHT__Ultra_Track_Container__c and related Attachments
     * @Param: none
     * @Return: ultraTrackContainerAttachmentWrapperList
     * @Date: 23/01/2017
     **/
    @RemoteAction   
    public static List<UltraTrackContainerAttachmentWrapper> FetchContainerData() {
        List<UltraTrackContainerAttachmentWrapper> ultraTrackContainerAttachmentWrapperList = new List<UltraTrackContainerAttachmentWrapper>();
        for(UFHT__Ultra_Track_Container__c ultraTrackContainerObj : [SELECT UFHT__Object_Name__c,
                                                                            UFHT__Object_Label__c,
                                                                            UFHT__Number_of_Records__c,
                                                                            UFHT__Is_Tracking_Enabled__c,
                                                                            (SELECT BodyLength 
                                                                             FROM Attachments) 
                                                                     FROM   UFHT__Ultra_Track_Container__c]) {
                if(!ultraTrackContainerObj.Attachments.isEmpty()) {
                    decimal totalBodylength = 0;
                    for(Attachment attachmentObj : ultraTrackContainerObj.Attachments) {
                        totalBodylength += attachmentObj.BodyLength;
                    }
                    ultraTrackContainerAttachmentWrapperList.add(new UltraTrackContainerAttachmentWrapper(ultraTrackContainerObj, totalBodylength));
                }
        }
        return ultraTrackContainerAttachmentWrapperList;     
    }
     /**
     * @Author: Eternus Solutions
     * @Description: Wrapper class that contains wrapper of UFHT__Ultra_Track_Container__c and Attachment Bodylength
     * @Param: none
     * @Return: none
     * @Date: 23/01/2017
     **/
	public class UltraTrackContainerAttachmentWrapper {
		public UFHT__Ultra_Track_Container__c ultraTrackContainerObj;
		public decimal bodylength; 
		public UltraTrackContainerAttachmentWrapper(UFHT__Ultra_Track_Container__c ultraTrackContainerObj, decimal bodylength) {
			this.ultraTrackContainerObj = ultraTrackContainerObj;
			this.bodylength = bodylength;
		}
	}
}