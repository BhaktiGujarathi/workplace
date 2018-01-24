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
public class PieChartController {
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
        List<UFHT__Ultra_Track_Container__c> ultraTrackContainerOtherList = new List<UFHT__Ultra_Track_Container__c>();
        Map<Id, Decimal> parentIdVsBodyLength = new Map<Id, Decimal>();
        Decimal othersBodyLength = 0;
        
        for(AggregateResult  ar : [SELECT SUM(BodyLength) bodyLength, ParentId
                                     FROM Attachment
                                    WHERE parent.Type = 'UFHT__Ultra_Track_Container__c'
                                 GROUP BY parentID
                                 ORDER BY SUM(BodyLength) DESC
                                    LIMIT 5]) {
            parentIdVsBodyLength.put((Id)ar.get('ParentId'), (Decimal)(ar.get('bodyLength')));         
        }
        
        for(UFHT__Ultra_Track_Container__c ultraTrackContainerObj : [SELECT Id,
                                                                            UFHT__Object_Name__c,
                                                                            UFHT__Object_Label__c,
                                                                            UFHT__Must_Have__c,
                                                                            UFHT__Good_To_Have__c,
                                                                            UFHT__Number_of_Records__c,
                                                                            UFHT__Is_Tracking_Enabled__c
                                                                       FROM UFHT__Ultra_Track_Container__c
                                                                      WHERE Id IN :parentIdVsBodyLength.keySet()]) {
            system.debug('--obj--'+ultraTrackContainerObj);
            system.debug('--label--'+ultraTrackContainerObj.UFHT__Object_Label__c);
            ultraTrackContainerAttachmentWrapperList.add(new UltraTrackContainerAttachmentWrapper(ultraTrackContainerObj.Id,
                                                                                                  ultraTrackContainerObj.UFHT__Object_Name__c,
                                                                                                  ultraTrackContainerObj.UFHT__Object_Label__c,
                                                                                                  ultraTrackContainerObj.UFHT__Must_Have__c,
                                                                                                  ultraTrackContainerObj.UFHT__Good_To_Have__c,
                                                                                                  ultraTrackContainerObj.UFHT__Number_of_Records__c,
                                                                                                  ultraTrackContainerObj.UFHT__Is_Tracking_Enabled__c,
                                                                                                  parentIdVsBodyLength.get(ultraTrackContainerObj.Id)));
        }
        
        for(AggregateResult  ar : [SELECT SUM(BodyLength) bodyLength, ParentId
                                     FROM Attachment
                                    WHERE parent.Type = 'UFHT__Ultra_Track_Container__c'
                                      AND Id NOT IN :parentIdVsBodyLength.keySet()
                                 GROUP BY parentID]) {
            othersBodyLength += (Decimal)(ar.get('bodyLength'));
        }
        
        List<AggregateResult> arList = [SELECT sum(UFHT__Number_of_Records__c) numberOfRecords,
                                                    sum(UFHT__Must_Have__c) Must_Have,
                                                    sum(UFHT__Good_To_Have__c) Good_To_Have 
                                               FROM UFHT__Ultra_Track_Container__c 
                                              WHERE Id IN :parentIdVsBodyLength.keySet()];
        if(arList != null) {
            ultraTrackContainerAttachmentWrapperList.add(new UltraTrackContainerAttachmentWrapper('Others',
                                                                                                  'Others',
                                                                                                  'Others',
                                                                                                  (Decimal)(arList.get(0).get('Must_Have')),
                                                                                                  (Decimal)(arList.get(0).get('Good_To_Have')),
                                                                                                  (Decimal)(arList.get(0).get('numberOfRecords')),
                                                                                                  false,
                                                                                                  othersBodyLength));
        }
        system.debug('--List--' + ultraTrackContainerAttachmentWrapperList);
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
    public String ObjectId;
    public String Object_Name; 
    public String Object_Label;
    public Decimal Must_Have;
    public Decimal Good_To_Have;
    public Decimal Number_of_Records;
    public Boolean Is_Tracking_Enabled; 
    public Decimal bodylength;
    
    public UltraTrackContainerAttachmentWrapper(String ObjectId, String Object_Name, String Object_Label, Decimal Must_Have, Decimal Good_To_Have, Decimal Number_of_Records,
                                                Boolean Is_Tracking_Enabled, Decimal bodylength) {
      this.Object_Name = Object_Name;
      this.Object_Label = Object_Label;
      this.Must_Have= Must_Have;
      this.Good_To_Have= Good_To_Have;
      this.Number_of_Records = Number_of_Records;
      this.Is_Tracking_Enabled = Is_Tracking_Enabled;
      this.bodylength = bodylength;
    }
  }
}