/**
 * @Class Name: PieChartControllerNewClone 
 * @Description: This class is used to query on UFHT__Ultra_Track_Container__c and Attachment to 
 *               fetch its value and display in Google Pie Chart .
 * ===================================================================================================
 *   Version   | Date        | Author             | Comments
 * ---------------------------------------------------------------------------------------------------
 *   1.0       | 23/01/2017  | Eternus Solutions  | 1. Created the class for above functionality.
 * ===================================================================================================
**/
public class PieChartControllerNewClone {
    /**
     * @Author: Eternus Solutions
     * @Description: FetchContainerData method fetches the data from UFHT__Ultra_Track_Container__c and related Attachments
     * @Param: none
     * @Return: ultraTrackContainerAttachmentWrapperList
     * @Date: 23/01/2017
     **/
    @RemoteAction   
    public static List<UltraTrackContainerAttachmentWrapper> FetchContainerData() {
        decimal otherRecordCountSum = 0;
        list<Id> parentList = new list<Id>();
        long otherBodyLengthSum =0;
        list<UFHT__Ultra_Track_Container__c> numOfRecordList = new list<UFHT__Ultra_Track_Container__c>();
        list<UFHT__Ultra_Track_Container__c> dataList = new list<UFHT__Ultra_Track_Container__c>();
        List<UltraTrackContainerAttachmentWrapper> ultraTrackContainerAttachmentWrapperList = new List<UltraTrackContainerAttachmentWrapper>();
        //Query to fetch top five BodyLength of Attachment where pafent is UFHT__Ultra_Track_Container__c
        for(AggregateResult  ar : [SELECT SUM(BodyLength) bodyLength, ParentId
                                   FROM Attachment
                                   WHERE parent.Type = 'UFHT__Ultra_Track_Container__c'
                                   GROUP BY parentID
                                   ORDER BY SUM(BodyLength) DESC
                                   LIMIT 5]){
            parentList.add((Id)ar.get('ParentId'));
        }
        
        for(Attachment attch : [SELECT  bodyLength, ParentId
                                   FROM Attachment
                                   WHERE (parent.Type = 'UFHT__Ultra_Track_Container__c') AND (id in : parentList)
                                   ]){
            otherBodyLengthSum += attch.bodyLength;
            
        }
        system.debug('otherBodyLengthSum'+otherBodyLengthSum);
        //Query to fetch sum of record count whose bodylength is lees than top 5
        for(UFHT__Ultra_Track_Container__c ultraTrackContainerRecordCount : [SELECT UFHT__Number_of_Records__c
                                                                         FROM   UFHT__Ultra_Track_Container__c 
                                                                         WHERE  id not in : parentList]) {
          otherRecordCountSum += ultraTrackContainerRecordCount.UFHT__Number_of_Records__c;
                                                                     
          numOfRecordList.add(ultraTrackContainerRecordCount);
          
        }
        system.debug('otherRecordCountSum =='+otherRecordCountSum );    //system.debug('ultraTrackContainerRecordCount =='+ultraTrackContainerRecordCount );
        
        
        //Query to fetch UFHT__Ultra_Track_Container__c data which contains records with top5 Bodylength
        for(UFHT__Ultra_Track_Container__c ultraTrackContainerObj : [SELECT UFHT__Object_Name__c,
                                                                            UFHT__Object_Label__c,
                                                                            UFHT__Number_of_Records__c,
                                                                            UFHT__Is_Tracking_Enabled__c,
                                                                            (SELECT BodyLength 
                                                                             FROM Attachments) 
                                                                     FROM   UFHT__Ultra_Track_Container__c
                                                                     Where  id in : parentList]) {
                if(!ultraTrackContainerObj.Attachments.isEmpty()) {
                    decimal totalBodylength = 0;
                    for(Attachment attachmentObj : ultraTrackContainerObj.Attachments) {
                        totalBodylength += attachmentObj.BodyLength;
                    }
                    ultraTrackContainerAttachmentWrapperList.add(new UltraTrackContainerAttachmentWrapper(ultraTrackContainerObj, totalBodylength, otherRecordCountSum, otherBodyLengthSum  ));
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
    public decimal otherRecordCountSum;
    public long otherBodyLengthSum; 
    public UltraTrackContainerAttachmentWrapper(UFHT__Ultra_Track_Container__c ultraTrackContainerObj, decimal bodylength, decimal otherRecordCountSum,long otherBodyLengthSum ){
      this.ultraTrackContainerObj = ultraTrackContainerObj;
      this.bodylength = bodylength;
      this.otherRecordCountSum =otherRecordCountSum;
      this.otherBodyLengthSum =otherBodyLengthSum ;
      
    }
  }
}