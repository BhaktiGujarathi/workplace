/**
* @author Bhakti Guajarthi
* @date 11-4-2016
*
* @description This class is a controller for the facility status page
* 
* 
*/

public with sharing class CMAFacilityStatusController {
    
    // std controller case record
    private final Case stdCaseObj;
    // Map to hold facility Status records from DB
    public Map<Id, Facility_Status__c> facilityStatusDBMap;
    // list to hold query result
    public List<Facility_Status__c> facilityStatusDBList;
    // List of wrapper to be used to display on vf page
    public List<FacilityStatusWrapper> facilityStatusWrapperList;
    // list of facility status records to be saved to DB
    public List<Facility_Status__c> facilityStatusToSaveList                            {get; set;}
    // boolean to handle edit all feature
    public Boolean faciltiyStatusEditAllFlag                                            {get; set;}
    // integer to hold the index of the status record to be deleted
    public Integer facilityStatusIndexToRemove                                          {get; set;}
    // map of profile permission custom setting
    public CMAProfilePermissionMatrix__c profilePermissionForButton;
    // current logged in user
    public Id currentUserProfileId;
    // boolean to render Add new button
    public Boolean addNewFlag                                                           {get; set;}
    // boolean to render Delete button
    public Boolean deleteFlag                                                           {get; set;}
    // list of facility status to use
    public List<Facility_Status__c> facilityStatusList;
    
    public CMAFacilityStatusController(ApexPages.StandardController stdController) {
         this.stdCaseObj = (Case)stdController.getRecord();
         
         faciltiyStatusEditAllFlag = false;
         facilityStatusDBMap = new Map<Id, Facility_Status__c>();
         facilityStatusDBList = new List<Facility_Status__c>();
         facilityStatusList = new List<Facility_Status__c>();
         facilityStatusWrapperList = new List<FacilityStatusWrapper>();
         facilityStatusToSaveList = new List<Facility_Status__c>();
         profilePermissionForButton = new CMAProfilePermissionMatrix__c();
         
         currentUserProfileId = userInfo.getProfileId();
         profilePermissionForButton = getProfilePermissionsForButton(currentUserProfileId);
         addNewFlag = profilePermissionForButton.Add_New__c;
         deleteFlag = profilePermissionForButton.Delete__c;
         facilityStatusDBList = getFacilityStatusDBList();
         //facilityStatusList.addAll(facilityStatusDBList);
         facilityStatusDBMap = fetchFacilityStatusDBMap(facilityStatusDBList);
         
    }
    
    // method to get related facility status list from DB for the current case record
    public Map<Id, Facility_Status__c> fetchFacilityStatusDBMap(List<Facility_Status__c> pFacilityStatusList) {
        facilityStatusDBMap.clear();
        for (Facility_Status__c statusInstance : pFacilityStatusList) {
            if(!facilityStatusDBMap.containsKey(statusInstance.Id)) {
                facilityStatusDBMap.put(statusInstance.Id, statusInstance);
            }
        }
        return facilityStatusDBMap;
    }
    
    // method to prepeare a  wrapper list fo facility status
    public List<FacilityStatusWrapper> getFacilityStatusWrapperList() {
        facilityStatusWrapperList.clear();
        getFacilityStatusDBList();
        Boolean editFlag = (faciltiyStatusEditAllFlag==true? true: false);
        for(Integer i = 0; i < facilityStatusDBList.Size(); i++) {
            facilityStatusWrapperList.add(new FacilityStatusWrapper(facilityStatusDBList[i],
                                                                    i,
                                                                    editFlag));
        }
        return facilityStatusWrapperList;
    }
    
    // method to save Facility Status
    public void saveFacilityStatusRecords() {
        facilityStatusToSaveList.clear();
        facilityStatusDBMap = fetchFacilityStatusDBMap(getFacilityStatusDBList());
        for(FacilityStatusWrapper wrapperInstance : facilityStatusWrapperList) {
            if(wrapperInstance.facilityStatus.Id == null) {
                facilityStatusToSaveList.add(wrapperInstance.facilityStatus);
            }else {
	            Facility_Status__c statusObj = facilityStatusDBMap.get(wrapperInstance.facilityStatus.Id);
	            if(statusObj.FRN_Facility__c != wrapperInstance.facilityStatus.FRN_Facility__c || 
	               statusObj.Status__c != wrapperInstance.facilityStatus.Status__c) {
	                 facilityStatusToSaveList.add(wrapperInstance.facilityStatus);
	            }
            }
        }
        if(!facilityStatusToSaveList.isEmpty()) {
            try {
                upsert facilityStatusToSaveList;
                
                faciltiyStatusEditAllFlag = false;
            }
            catch(Exception exObj) {
                if((exObj.getMessage()).contains('DUPLICATE_VALUE')) {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'Duplicate entry of FRN facility.'));
                }
            }
        }
    }
    
    // method to enable the edit all feature
    public void editAllFacilityStatus() {
        faciltiyStatusEditAllFlag = true;
        deleteFlag = true;
        for(FacilityStatusWrapper wrapperInstance : facilityStatusWrapperList) {
            wrapperInstance.facilityStatusEdit = true;
        }
    }
    
    // method to delete a facility status record
    public void deleteFacilityStatus() {
        if(facilityStatusWrapperList[facilityStatusIndexToRemove].facilityStatus.Id != null) {
            try {
                delete facilityStatusWrapperList[facilityStatusIndexToRemove].facilityStatus;
            }
            catch(Exception exObj) {
            }
        }
        facilityStatusDBList.remove(facilityStatusIndexToRemove);
        facilityStatusWrapperList.remove(facilityStatusIndexToRemove);
        //re-indexing
         for(Integer i=0;i<facilityStatusWrapperList.size();i++)
         {
            facilityStatusWrapperList[i].facilityStatusIndex = i;
         }
    }
    
    // method to refresh 
    public void refreshFacilityStatus()
    {
        faciltiyStatusEditAllFlag = false;
        facilityStatusDBList = getFacilityStatusDBList();
        getFacilityStatusWrapperList();
    }
    
    public void newFacilityStatusRecord() {
        deleteFlag = true;
        Facility_Status__c facilityStatusNew = new Facility_Status__c(Status__c = 'Pending',
                                                                      Case__c = stdCaseObj.Id);
        facilityStatusWrapperList.add(new FacilityStatusWrapper(facilityStatusNew, null, true));
        facilityStatusDBList.add(facilityStatusNew);
    }
    
    public CMAProfilePermissionMatrix__c getProfilePermissionsForButton(Id pKeyId) {
        
        return CMAProfilePermissionMatrix__c.getInstance(pKeyId);
    }
    
    // method to query facility status from DB
    public List<Facility_Status__c> getFacilityStatusDBList() {
        
        return [SELECT Id, 
                       FRN_Facility__c,
                       FRN_Facility__r.Name,
                       Status__c
                FROM Facility_Status__c
                WHERE Case__c =:stdCaseObj.Id];
    }
    
    // wrapper 
    public class FacilityStatusWrapper
    {
        public Facility_Status__c facilityStatus                                         {get;set;}
        public Integer facilityStatusIndex                                               {get;set;}
        public Boolean facilityStatusEdit                                                {get;set;}
        public FacilityStatusWrapper(Facility_Status__c facilityStatusInstance, 
                                     Integer pFacilityStatusIndex, 
                                     Boolean pFacilityStatusEdit) {
            facilityStatus = facilityStatusInstance;
            facilityStatusIndex = pFacilityStatusIndex;
            facilityStatusEdit = pFacilityStatusEdit;
        }
    }
}