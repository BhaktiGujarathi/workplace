/**************************************************************************************************
* Name                  : ManageTeamsAgenciesInventoriesController    
* Visualforce Page      : Manage_Teams_Agencies_for_Inventories
* Description           : This class will allow users to select the buildings and assign them to Teams or Agencies
* Created By            : NSI - Sivasankar K                                                                        
* Created Date          : 30/Jan/2017 
* Last Modified Date    :                                                                            
* Last Modified By      :                                                                            
* ----------------------------------------------------------------------------------------------- 
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                                                      
* CH00              1.0         NSI - Sivasankar K         20/Jan/2017      Initial development
* CH01              2.0
* CH02              3.0
**************************************************************************************************/
public class ManageTeamsAgenciesInventoriesCtrl {
    
    //Select Options and Selected Options Variables
    public SelectOption[] allBuildingNames {get;set;}
    public SelectOption[] allPropertyNames {get;set;}
    public List<String> selectedProperty {get;set;}
    public List<String> selectedBuildings {get;set;}
    
    public String windowURL {get;set;}
    public String selTeamAgency {get;set;}
    public List<User> viesTeamAgencyUsers {get;set;}
    public List<SelectWrapper> lstGroupsAgency {get;set;}//lst of Teams or Agencies wrapper to display them in first page.
    
    public Boolean firstPage {get;set;}
    public Boolean secondPage {get;set;}
    public Boolean areRecordsAdded {get;set;}
    public Boolean areUsersPresent {get;set;}
    
    public String propertiespresent {get;set;}
    public Boolean buildingspresent {get;set;}
    
    public Team_Building__c addteambuilding {get;set;}//to add the team Building to the list
    public String removeBuildingfor {get;set;}
    public Integer removeBuildingIndex {get;set;}
    public Map<String,List<Team_Building__c>> teamBuildings {get;set;} // to hold the team buildings for agency/Team and its buildings
    public Map<String,String> teamAgencyIDNameMap {get;set;}// to hold the selected Team or AgencyId and its respective Name

    public Map<Id,String> mapOfProjectNames {get;set;}
    public Map<Id,String> mapOfbuildingNames {get;set;}
    public Map<String,List<SelectOption>> buildingsMap {get;set;}
    
    //Pagination variables
    public Integer noOfRecToDisplay { get; set; } // Number of records to be displayed in page.
    public Integer total { get; set; } // total records
    @testVisible private String conditionsString = '';
    @testVisible private integer totalRecs = 0;
    @testVisible private integer offsetVal = 0;
    @testVisible private integer LimitSize = 5;
    //Pagination variables
    public Integer minNumber {get;set;}
    public Integer maxNumber {get;set;}
    public Integer totalPageNumber {get;set;}
    public Integer currPageNumber {get;set;}
    
    
    @testVisible Map<String,Set<String>> buildingsOfProperty {get;set;}
    @testVisible Map<ID,Integer> buildingsIndexMap {get;set;}
    @testVisible Set<String> addedBuildingsUniqueKeyValues {get;set;}
    
   
    /**
     * ManageTeamsAgenciesInventoriesController():Constructor
     **/
  public ManageTeamsAgenciesInventoriesCtrl(){
        firstPage = true;
        secondPage = false;
        areRecordsAdded = false;
        propertiespresent = '';
        buildingspresent = false;
        areUsersPresent = false;
        selectedProperty = new List<String>();
        selectedBuildings = new List<String>();
        selTeamAgency = 'Teams';
        windowURL = (selTeamAgency.equalsIgnoreCase('Teams') ? '/setup/own/groupdetail.jsp?id=' : '');
        mapOfProjectNames = new Map<Id,String>();
        mapOfbuildingNames = new Map<Id,String>();

        buildingsMap = new Map<String,List<SelectOption>>();
        teamBuildings = new Map<String,List<Team_Building__c>>();
        teamAgencyIDNameMap = new Map<String,String>();

        addteambuilding = new Team_Building__c();
        viesTeamAgencyUsers = new List<User>();
        allBuildingNames = new List<SelectOption>();
        allPropertyNames = new List<SelectOption>();
      
        //total = totalRecs = getTotalRecords();
        currPageNumber = 1;
        displayTeamsAgences();
  }  
  
  /** First Page Methods **/
    public void onRadioChange(){
        offsetVal = 0;
        LimitSize = 5;
        areUsersPresent = false;
        viesTeamAgencyUsers = new List<User>();
        //total = totalRecs = getTotalRecords();
        
        currPageNumber = 1;
        displayTeamsAgences();
    }
  
  /**
     * displayTeamsAgences(): This function will displays the data for the Teams or Agencies
     **/
    public void displayTeamsAgences(){
        lstGroupsAgency = new List<SelectWrapper>();
        //total = totalRecs = getTotalRecords();
        
        System.debug('totalPageNumber = '+totalPageNumber);
        System.debug('total = '+total);
        System.debug('LimitSize ='+LimitSize);
        System.debug('currPageNumber ='+currPageNumber);
        System.debug('maxNumber = '+maxNumber);
        System.debug('minNumber = '+minNumber);
        
        if(String.isNotBlank(selTeamAgency)){
            if(selTeamAgency.equalsIgnoreCase('Teams')){
                windowURL = '/setup/own/groupdetail.jsp?id=';
                List<Group> lstGroup = getGroups();
                total = totalRecs = lstGroup.size();
                countPageNumbers();
                for(Integer i = minNumber; i <= maxNumber; i++){
                    if(lstGroup != null && lstGroup.size() > i && i >= 0){
                        lstGroupsAgency.add(new SelectWrapper(false,lstGroup[i].id,lstGroup[i].DeveloperName.subStringBefore('_DAMAC_TEAM')));
                        if(lstGroupsAgency.size() == LimitSize){
                            break;
                        }
                    }else{  
                        break;
                    }
                }
            }
            else{
                windowURL = '/';
                List<Account> lstAccounts = getAgencies();
                total = totalRecs = lstAccounts.size();
                countPageNumbers();
                for(Integer i = minNumber; i <= maxNumber; i++){
                    if(lstAccounts != null && lstAccounts.size() > i && i >= 0 ){
                        lstGroupsAgency.add(new SelectWrapper(false,lstAccounts[i].id,lstAccounts[i].Name));
                        if(lstGroupsAgency.size() == LimitSize){
                            break;
                        }
                    }else{  
                        break;
                    }
                }
            }
        }
                
    }
    
    @testVisible private void countPageNumbers(){
        totalPageNumber =  ((math.mod(total, LimitSize) == 0) ? (total / LimitSize) : ((total / LimitSize) + 1)); 
        maxNumber = currPageNumber * LimitSize;
        minNumber = maxNumber - LimitSize;
    }
    
    /**
    *getGroups(): get the list of groups that are having developer name list DAMAC_TEAM
    **/
    @testVisible private List<Group> getGroups(){
        return new List<Group>([SELECT ID,Name,DeveloperName FROM Group WHERE DeveloperName LIKE '%_DAMAC_TEAM' Order By DeveloperName LIMIT 50000]);
    }
    
    /**
    *getAgencies(): get the list of Accounts with Agency record Type that are having developer name list DAMAC_TEAM
    **/
    @testVisible private List<Account> getAgencies(){
        return new List<Account>([SELECT ID,Name FROM Account WHERE RecordType.Name LIKE '%Agency%' Order By Name ASC LIMIT 50000]);
    }

    /**
    * getAgencyUsers(): This function will return the set ID of Property Consultants which are assigned to the Agencies
    *
    @testVisible private Set<id> getAgencyUsers(Set<ID> agencyIds){
      Set<Id> userIDs = new Set<Id>();
      for(Agency_PC__c aPC : new List<Agency_PC__c>([SELECT User__c FROM Agency_PC__c WHERE Agency__c IN:agencyIds AND User__c != null])){
        userIDs.add(aPC.User__c);
      }
      return userIDs;
    }
*/
    /** First Page methods End**/

  /**
     * displayTeamsAgences(): This function will displays the data for the Teams or Agencies
     **/
    public void getPropertyNames(){
        List<SelectOption> lstOption;
        SelectOption sOptiong;
        Set<String> bldofProperty;
        allPropertyNames = new List<SelectOption>();
        buildingsMap = new Map<String,List<SelectOption>>();
        buildingsOfProperty = new Map<String,Set<String>>();
        
        mapOfProjectNames = new Map<Id,String>();
        mapOfbuildingNames = new Map<Id,String>();
        propertiespresent = '';
        for(AggregateResult agg : [SELECT Building_Location__c,Building_Location__r.Building_Name__c bName,Building_Location__r.Property_Name__r.Property_Name__c pName,Building_Location__r.Property_Name__c pId 
                                    FROM Inventory__c 
                                    WHERE Status__c ='RELEASED' 
                                    AND Building_Location__c != null 
                                    AND Building_Location__r.Property_Name__c != null 
                                    AND Building_Location__r.Building_Name__c != null 
                                    AND Building_Location__r.Property_Name__r.Property_Name__c != null
                                    Group By Building_Location__r.Property_Name__r.Property_Name__c,Building_Location__r.Property_Name__c,Building_Location__c,Building_Location__r.Building_Name__c]){
            System.debug('agg == '+agg);                            
            //lstOption.add(new SelectOption((String)agg.get('Building_Location__c'),(String)agg.get('bName')));
            if(agg.get('pId') != null){
                if(!buildingsMap.isEmpty() && buildingsMap.containsKey((String)agg.get('pId'))){
                    sOptiong = new SelectOption((String)agg.get('Building_Location__c'),(String)agg.get('bName'));
                    mapOfbuildingNames.put((String)agg.get('Building_Location__c'),(String)agg.get('bName'));
                    System.debug('=sOptiong=> '+ sOptiong);
                    buildingsMap.get((String)agg.get('pId')).add(sOptiong);
                    
                    bldofProperty = buildingsOfProperty.get((String)agg.get('pId'));
                    bldofProperty.add((String)agg.get('Building_Location__c'));
                    buildingsOfProperty.put((String)agg.get('pId'),bldofProperty);
                }  
                else {
                    allPropertyNames.add(new SelectOption((String)agg.get('pId'),(String)agg.get('pName')));
                    mapOfProjectNames.put((String)agg.get('pId'),(String)agg.get('pName'));
                    
                    propertiespresent += ','+(String)agg.get('pId');
                    
                    bldofProperty = new Set<String>{(String)agg.get('Building_Location__c')};
                    buildingsOfProperty.put((String)agg.get('pId'),bldofProperty);
                    sOptiong = new SelectOption((String)agg.get('Building_Location__c'),(String)agg.get('bName'));
                    mapOfbuildingNames.put((String)agg.get('Building_Location__c'),(String)agg.get('bName'));
                    lstOption = new List<SelectOption>();
                    lstOption.add(sOptiong);
                    buildingsMap.put((String)agg.get('pId'),lstOption);
                    System.debug('=buildingsMap=> '+ buildingsMap);
                }
            }
        }
        //if(mapOfProjectNames.size() > 0 ) 
        //    propertiespresent = true;
    }
    
    public void getBuildingNames(){
        buildingspresent = false;
        System.debug('selectedProperty = '+selectedProperty); 
        allBuildingNames = new List<SelectOption>();
        
        for(String projectID : selectedProperty){
            allBuildingNames.addAll(buildingsMap.get(projectID));
        }
        if(allBuildingNames.size() > 0){
            buildingspresent = true;
        }
    }
    
    public void getteamBuildingsRecs(){

      addedBuildingsUniqueKeyValues = new Set<String>();
        List<Inventory_User__c> lstInvUsers = new List<Inventory_User__c>();
        teamAgencyIDNameMap = new Map<String,String>();
 
        for(SelectWrapper SW: lstGroupsAgency){
            if(SW.selected){
                teamAgencyIDNameMap.put(SW.idValue,SW.nameValue);
            }
        }
       
        teamBuildings = new Map<String,List<Team_Building__c>>();
        for(Team_Building__c teamBuilding : new List<Team_Building__c>([SELECT Id,End_Date__c,Start_Date__c,Location__c,Location__r.Building_Name__c,Project__c,Project__r.Property_Name__c,Unique_Key__c,Agency_or_Group_Id__c FROM Team_Building__c WHERE Agency_or_Group_Id__c IN: teamAgencyIDNameMap.keySet() ORDER BY Agency_or_Group_Id__c])){
            if(!teamBuildings.isEmpty() && teamBuildings.containsKey(teamBuilding.Agency_or_Group_Id__c)){
              teamBuildings.get(teamBuilding.Agency_or_Group_Id__c).add(teamBuilding);
              addedBuildingsUniqueKeyValues.add(teamBuilding.Unique_Key__c);
            }
            else{
              teamBuildings.put(teamBuilding.Agency_or_Group_Id__c,new List<Team_Building__c>{teamBuilding});
              addedBuildingsUniqueKeyValues.add(teamBuilding.Unique_Key__c);
            }
        }
        
        //if the teams does not have existing records then add the blank list
        for(String agID : teamAgencyIDNameMap.keySet()){
          if(!teamBuildings.containsKey(agID)){
            teamBuildings.put(agID,new List<Team_Building__c>());
          }
        }
    }

    public void addRow(){
      System.debug('addteambuilding = '+addteambuilding);
      //List<Team_Building__c> addbuilding = new List<Team_Building__c>();
      Map<String,Set<String>> tempMapping = new Map<String,Set<String>>();//buildingsOfProperty
      Set<String> tempSet;
      Boolean isBuildingSelforSelProperty;
      Team_Building__c addTeam;
      String uniqueKey = '';
      
      if(addteambuilding.Start_Date__c == null || addteambuilding.End_Date__c == null || selectedProperty.size() == 0){
          if(selectedProperty.size() == 0 )
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select at least one property.'));
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Start and End Dates are required.'));
      }
      else {
      
          for(String selPropID : selectedProperty){
              isBuildingSelforSelProperty = false;
              for(String selBldId : selectedBuildings){
                  if(buildingsOfProperty.containsKey(selPropID) && buildingsOfProperty.get(selPropID).contains(selBldId)){
                      isBuildingSelforSelProperty = true;
                      if(tempMapping.containsKey(selPropID)){
                          tempSet =  tempMapping.get(selPropID);
                          tempSet.add(selBldId);
                          tempMapping.put(selPropID,tempSet);
                      }
                      else{
                          tempSet = new Set<String>{selBldId};
                          tempMapping.put(selPropID,tempSet);
                      }
                  }
              }
              
              if(!isBuildingSelforSelProperty && buildingsOfProperty.containsKey(selPropID)){
                  tempSet = new Set<String>();
                  tempSet.addAll(buildingsOfProperty.get(selPropID));
                    tempMapping.put(selPropID,tempSet);
              }
          }
          
          
          System.debug('@@@teamBuildings Before = '+teamBuildings);
          for(String team : teamAgencyIDNameMap.keySet()){
              for(String selPropID : selectedProperty){
                  for(String selBldId : tempMapping.get(selPropID)){
                      uniqueKey = team+'###'+selBldId;
                      if(!addedBuildingsUniqueKeyValues.contains(uniqueKey)){
                          addTeam = new Team_Building__c(Id=addteambuilding.id,Agency_or_Group_Id__c = team,
                                                  Unique_Key__c = team+'###'+selBldId,
                                                  Start_Date__c = addteambuilding.Start_Date__c,
                                                  End_Date__c = addteambuilding.End_Date__c,
                                                  Location__c = selBldId,
                                                  Project__c = selPropID);
                          
                          System.debug('addTeam == '+addTeam); 
                          teamBuildings.get(team).add(addTeam);
                          addedBuildingsUniqueKeyValues.add(uniqueKey);
                      }
                  }
              }
          }
          System.debug('@@@teamBuildings After = '+teamBuildings);
          addteambuilding = new Team_Building__c();
          selectedProperty = new List<String>();
          selectedBuildings = new List<String>();
      }
    }

    public void removeRow(){
      System.debug('removeBuildingfor = '+removeBuildingfor+', removeBuildingIndex = '+removeBuildingIndex);
      Team_Building__c deleteBuilding = new Team_Building__c();
      List<Team_Building__c> tempBuildings = new List<Team_Building__c>();
      String uniqueKey = ''; 
      try{
        if(String.isNotBlank(removeBuildingfor) && teamBuildings.containsKey(removeBuildingfor)){
            //tempBuildings.addAll(teamBuildings.get(removeBuildingfor));
            
          deleteBuilding = teamBuildings.get(removeBuildingfor)[removeBuildingIndex];
          System.debug('deleteBuilding == '+deleteBuilding);
          
          uniqueKey = deleteBuilding.Agency_or_Group_Id__c+'###'+deleteBuilding.Location__c;
          if(deleteBuilding != null && deleteBuilding.id != null){
            delete deleteBuilding;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'sucessfully removed the access.'));
          }
          System.debug('tempBuildings Before '+teamBuildings.get(removeBuildingfor).size());
          System.debug('tempBuildings Before '+teamBuildings.get(removeBuildingfor));
          //tempBuildings.remove(removeBuildingIndex);
          //teamBuildings.put(removeBuildingfor,tempBuildings);
          
          if(addedBuildingsUniqueKeyValues.contains(uniqueKey)){
              addedBuildingsUniqueKeyValues.remove(uniqueKey);
          }
          teamBuildings.get(removeBuildingfor).remove(removeBuildingIndex);
          
          System.debug('tempBuildings After '+teamBuildings.get(removeBuildingfor).size());
          System.debug('tempBuildings After '+teamBuildings.get(removeBuildingfor));
        }
      }catch(Exception ex){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()+' : '+ex));
      }
    }

    public void saveBuildingAllocation(){

      List<Team_Building__c> upsertBuildings = new List<Team_Building__c>();
      try{
          
          for(String buldID : teamBuildings.keySet()){
                if(teamBuildings.get(buldID).size() > 0){
                    areRecordsAdded = true;
                    break;
                }
            }
            if(!areRecordsAdded){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please add at least one building for selected '+selTeamAgency));
            }
          
        if(areRecordsAdded && !teamBuildings.values().isEmpty() && teamBuildings.values().size() > 0){
          for(String teamID : teamBuildings.keySet()){
              System.debug('teamID = '+teamID+', team Name = '+teamAgencyIDNameMap.get(teamID));
            for(Team_Building__c team :teamBuildings.get(teamID) ){
                System.debug('adding the TeamBuilding = '+team);
              if(team != null){
                team.Location_ID__c = ((team.Location__c != null ) ? team.Location__c : null);
                upsertBuildings.add(team);
              }
            }
          }
          if(!upsertBuildings.isEmpty() && upsertBuildings.size() > 0 ){
              System.debug('upsertBuildings = '+upsertBuildings);
            //upsert upsertBuildings;
            database.Upsert(upsertBuildings,Team_Building__c.Unique_Key__c.getDescribe().getSObjectField() ,false);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Inventories are shared sucessfully.'));
          }
        }
      }catch(Exception ex){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }
    }

    public void goToHomePage(){
      firstPage = true;
      secondPage = false;
      viesTeamAgencyUsers = new List<User>();
      limitsize = noOfRecToDisplay;
        //total = totalRecs = getTotalRecords();
        displayTeamsAgences();
  } 

  public void goToNextPage(){
      firstPage = false;
      secondPage = true;
      addteambuilding = new Team_Building__c();
      selectedProperty.clear();
      selectedBuildings.clear();
      allBuildingNames.clear();
      viesTeamAgencyUsers.clear();
      viesTeamAgencyUsers = new List<User>();
      allBuildingNames = new List<SelectOption>();
      selectedProperty = new List<String>();
      selectedBuildings = new List<String>();
      getPropertyNames();
      removeBuildingfor = null;
      getteamBuildingsRecs();
  }
  
  /*public void viewUsers(){
    Set<ID> teamUserIDs = new Set<ID>();
    System.debug('removeBuildingfor = '+removeBuildingfor);
    if(selTeamAgency.containsIgnoreCase('Teams')){
        for(GroupMember gm: [SELECT id, UserOrGroupId, groupid FROM GroupMember WHERE groupid =: removeBuildingfor]){
           teamUserIDs.add(gm.UserOrGroupId);
        }
    }
    else{
        for(Agency_PC__c PC: [SELECT User__c FROM Agency_PC__c WHERE Agency__c =: removeBuildingfor]){
           teamUserIDs.add(PC.User__c);
        }
        for(Contact con: [SELECT Salesforce_User__c FROM Contact WHERE AccountID =: removeBuildingfor AND Salesforce_User__c != null]){
           teamUserIDs.add(con.Salesforce_User__c);
        }
    }
    viesTeamAgencyUsers = new List<User>([SELECT ID,Name,UserRole.Name FROM USER WHERE ID IN:teamUserIDs]);

    areUsersPresent = (!viesTeamAgencyUsers.isEmpty() && viesTeamAgencyUsers.size() > 0 ) ? true : false;
    System.debug('areUsersPresent = '+areUsersPresent+', viesTeamAgencyUsers = '+viesTeamAgencyUsers);
  }
*/
    /*********************************************************************************************
    * @Description : class to group and selectedGroup.                                      *
    *********************************************************************************************/
  public class SelectWrapper{
    public Boolean selected {get; set;}
    public ID idValue {get;set;} 
    public String nameValue {get;set;}
    
    public SelectWrapper(Boolean selected, ID idValue,String nameValue){
      this.selected = selected;
      this.idValue = idValue;
      this.nameValue = nameValue;
    }  
  }
  
  /************************************************************************************************
    * @Description : this method will update the page with new page size                            *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public void updatePage() {
        limitsize = noOfRecToDisplay;
        displayTeamsAgences();
    }
    
    /************************************************************************************************
    * @Description : Get the Total records to be displayed for the search conditions                *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    ************************************************************************************************
    @testVisible private Integer getTotalRecords(){
        System.debug('selTeamAgency = '+selTeamAgency);
        Integer totalUsers = null;
        if(selTeamAgency.containsIgnoreCase('Teams'))
            totalUsers = [SELECT Count() FROM Group WHERE DeveloperName LIKE '%_DAMAC_TEAM'];
        else
            totalUsers = [SELECT Count() FROM Account WHERE RecordType.Name LIKE '%Agency%'];
        return totalUsers;
    }*/
    
    /************************************************************************************************
    * @Description : this method will set hte offsetVal to display first page records               *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public void Firstbtn() {
        //offsetVal = 0;
        currPageNumber = 1;
        displayTeamsAgences();
    }
    
    /************************************************************************************************
    * @Description : this method will set hte offsetVal to display previous page records            *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/  
    public void prvbtn() {
        //offsetVal = offsetVal-limitsize;
        currPageNumber = currPageNumber - 1;
        displayTeamsAgences();
    }
    
    /************************************************************************************************
    * @Description : this method will set hte offsetVal to display next page records                *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public void Nxtbtn() {
        //offsetVal = offsetVal+limitsize;
        currPageNumber = currPageNumber + 1;
        displayTeamsAgences();
    }
    
    /************************************************************************************************
    * @Description : this method will set hte offsetVal to display last page records                *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public void lstbtn() {
        currPageNumber = ((math.mod(total, LimitSize) == 0) ? (total / LimitSize) : ((total / LimitSize) + 1)); 
        displayTeamsAgences();
    }
    
    /************************************************************************************************
    * @Description : this method will get checks that hasmore records in current search             *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public Boolean gethasNext() {
        if((currPageNumber * LimitSize) < total)
            return false;
        else 
            return true;
        
    }
    
    /************************************************************************************************
    * @Description : this method will get checks that previous records in current search            *
    * @Params      :                                                                              *
    * @Return      : Boolean                                                                        *
    *************************************************************************************************/
    public Boolean gethasPrevious() {
        if(currPageNumber > 1 && currPageNumber <= totalPageNumber )
            return false;
        else 
            return true;
    }
}