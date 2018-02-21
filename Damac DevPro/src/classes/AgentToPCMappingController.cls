/****************************************************************************************************************
* Name                  : AgentToPCMappingController                                                            *
* Visualforce Page      : AgentToPCMapping                                                                      *
* Test Class            : AgentToPCMappingController_Test                                                       *
* Description           : This class map the agents to PCs                                                      *
* Created By            : NSI - Sivasankar K                                                                    *               
* Created Date          : 06/Feb/2017                                                                           *   
* Last Modified Date    :                                                                                       *
* Last Modified By      :                                                                                       *
* ------------------------------------------------------------------------------------------------------------  *
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                         *                                        
* CH00              1.0         NSI - Sivasankar K         06/Feb/2017      Initial developmen                  *
* CH01              2.0                                                                                         *
* CH02              3.0                                                                                         *
*****************************************************************************************************************/
public with sharing class AgentToPCMappingController { 
        
    public Integer noOfRecToDisplay { get; set; } // Number of records to be displayed in page.
    public Integer total { get; set; } // total records
    public List<User> allPCUsers {get;set;} //Users to display in table
    public String selUserName {get;set;} // Selected User Name
    public String selSM {get;set;} // Selected Sales Manager
    public String selHOS {get;set;} // Selected Head of Sales
    public String selDOS {get;set;} // Selected Director of Sales
    
    public String agencyID {
        get{
            if(agencyID == null || agencyID == '')
                agencyID = ApexPages.currentPage().getParameters().get('id');
            return agencyID;
        }
        set;
    }
    
    public Set<ID> existingPCs {get;set;}
    public String existingPCIDS {get;set;}
    
    @testVisible private Set<ID> userIDs = new Set<ID>();
    @testVisible private String conditionsString = '';
    @testVisible private integer totalRecs = 0;
    @testVisible private integer offsetVal = 0;
    @testVisible private integer LimitSize = 5;
    
    public AgentToPCMappingController(ApexPages.StandardController controller){
        existingPCIDS = '';
        existingPCUsers();
        total = totalRecs = getTotalRecords();
        allPCUsers = getallPCUsers();
        selUserName = selSM = selHOS = selDOS = null;
    }
    
    public void searchUsers() {
        allPCUsers.clear();
        conditionsString = '';
        userIDs = new Set<ID>();
        
        if(String.isNotBlank(selSM)){
            userIDs.add(selSM);
        }
        if(String.isNotBlank(selHOS)){
            userIDs.add(selHOS);
        }
        if(String.isNotBlank(selDOS)){
            userIDs.add(selDOS);
        }
        /*conditionsString = ((String.isNotBlank(selSM)) ? 'Name LIKE \'%'+selSM+'%\' AND Profile.Name =\''+System.Label.SM_Profile+'\'':'');
        conditionsString = ((String.isNotBlank(selHOS)) ? 'Name LIKE \'%'+selHOS+'%\' AND Profile.Name =\''+System.Label.HOS_Profile+'\'':conditionsString);
        conditionsString = ((String.isNotBlank(selDOS)) ? 'Name LIKE \'%'+selDOS+'%\' AND Profile.Name =\''+System.Label.DOS_Profile+'\'':conditionsString);
        conditionsString = ((String.isNotBlank(selSM) && String.isNotBlank(selHOS) && String.isNotBlank(selDOS)) ? '(Name LIKE \'%'+selSM+'%\' OR Name LIKE \'%'+selHOS+'%\' OR Name LIKE \'%'+selDOS+'%\') AND Profile.Name IN(\''+System.Label.SM_Profile+'\',\''+System.Label.DOS_Profile+'\',\''+System.Label.HOS_Profile+'\')':conditionsString);
        conditionsString = ((String.isNotBlank(selSM) && String.isNotBlank(selHOS)) ? '(Name LIKE \'%'+selSM+'%\' OR Name LIKE \'%'+selHOS+'%\') AND Profile.Name IN(\''+System.Label.SM_Profile+'\',\''+System.Label.HOS_Profile+'\')':conditionsString);
        conditionsString = ((String.isNotBlank(selHOS) && String.isNotBlank(selDOS)) ? '(Name LIKE \'%'+selHOS+'%\' OR Name LIKE \'%'+selDOS+'%\') AND Profile.Name IN(\''+System.Label.DOS_Profile+'\',\''+System.Label.HOS_Profile+'\')':conditionsString);
        conditionsString = ((String.isNotBlank(selSM) && String.isNotBlank(selDOS)) ? '(Name LIKE \'%'+selSM+'%\' OR Name LIKE \'%'+selDOS+'%\') AND Profile.Name IN(\''+System.Label.SM_Profile+'\',\''+System.Label.DOS_Profile+'\')':conditionsString);
        
        System.debug('conditionsString ===>'+conditionsString);
        
        if(String.isNotBlank(conditionsString))
            for(User us: Database.query('SELECT ID FROM USER WHERE IsActive = True AND '+conditionsString)){
                userIDs.add(us.id);
            }
        
        */
        conditionsString = ((String.isNotBlank(selUserName) ? 'ID =\''+selUserName+'\'' : ''));
        System.debug('userIDs == Search ====> '+userIDs);
        if(!userIDs.isEmpty() && userIDs.size() > 0){
            conditionsString += (String.isNotBlank(conditionsString) ? ' AND ' :'')+'(ManagerId IN: userIDs OR Manager.ManagerId IN: userIDs OR Manager.Manager.ManagerId IN: userIDs OR Manager.Manager.Manager.ManagerId IN: userIDs)';
        }
        System.debug('conditionsString == Search ====> '+conditionsString);
        
        limitsize = noOfRecToDisplay;
        total = totalRecs = getTotalRecords();
        allPCUsers = getallPCUsers();
    }
    
    /************************************************************************************************
    * @Description : this method will update the page with new page size                            *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public void updatePage() {
        allPCUsers.clear();
        limitsize = noOfRecToDisplay;
        allPCUsers = getallPCUsers();
    }
    
    /************************************************************************************************
    * @Description : this method will update the page with new page size                            *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public void addPCsToAgency() {
        
        List<Agency_PC__c> agPCs = new List<Agency_PC__c>();
        try{
            for(User pc :  allPCUsers){
                if(pc.IsActive)
                    agPCs.add(new Agency_PC__c(Agency__c = agencyID,User__c = pc.id,Name = pc.Name));
            }
            
            System.debug('agPCs===='+agPCs);
            if(!agPCs.isEmpty() && agPCs.size() > 0)
                insert agPCs;
                
            //reinitialize the values.
            selUserName = selSM = selDOS = selHOS = '';
            existingPCIDS = '';
            existingPCUsers();//call existing users 
            limitsize = noOfRecToDisplay;
            total = totalRecs = getTotalRecords();
            allPCUsers = getallPCUsers();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,agPCs.size()+' PCs are added sucessfully.'));
        }Catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
    }
    
    /************************************************************************************************
    * @Description : Get all existing PC Users of the Agency                                        *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public void existingPCUsers(){
        existingPCs = new Set<ID>();
        existingPCIDS = '';
        for(Agency_PC__c aPC : new List<Agency_PC__c>([SELECT User__c FROM Agency_PC__c WHERE Agency__c =: agencyID])){
            existingPCs.add(aPC.User__c);
            existingPCIDS +='\\\''+aPC.User__c+'\\\',';
        }
        if(String.isNotBlank(existingPCIDS)){
            existingPCIDS = existingPCIDS.subStringBeforeLast(',');
            existingPCIDS = '('+existingPCIDS+')';
        }
    }
    
    /************************************************************************************************
    * @Description : Get the Total records to be displayed for the search conditions                *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    @testVisible private Integer getTotalRecords(){
        System.debug('conditionsString == getRecords ====> '+conditionsString);
        List<User> totalUsers = new List<User>();
        try{
            totalUsers = Database.query('SELECT Id FROM User WHERE ID NOT IN: existingPCs AND IsActive = True AND Profile.Name=\'Property Consultant\''+(String.isNotBlank(conditionsString) ? ' AND '+conditionsString : ''));
        }Catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
        return totalUsers.size();
    }
    
    /************************************************************************************************
    * @Description : this method will get all the PC users based on search condition                *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    @testVisible private List<User> getallPCUsers(){
        List<User> pcUsers = new List<User>();
        try{
            
            System.debug('conditionsString == getAllUsers ====> '+conditionsString);
            for(User us : Database.query('SELECT ID,Name,IsActive,UserRole.Name FROM USER WHERE ID NOT IN: existingPCs AND IsActive = True AND Profile.Name=\'Property Consultant\''+(String.isNotBlank(conditionsString) ? ' AND '+conditionsString:'')+' LIMIT:limitsize OFFSET:offsetVal')){
                us.IsActive = false;
                pcUsers.add(us);
            }
        }Catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
        return pcUsers;
    }
    
    /************************************************************************************************
    * @Description : this method will set hte offsetVal to display first page records               *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public void Firstbtn() {
        offsetVal = 0;
        allPCUsers = getallPCUsers();
    }
    
    /************************************************************************************************
    * @Description : this method will set hte offsetVal to display previous page records            *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/  
    public void prvbtn() {
        offsetVal = offsetVal-limitsize;
        offsetVal = (offsetVal < 0 ? 0:offsetVal);
        allPCUsers = getallPCUsers();
    }
    
    /************************************************************************************************
    * @Description : this method will set hte offsetVal to display next page records                *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public void Nxtbtn() {
        offsetVal = offsetVal+limitsize;
        allPCUsers = getallPCUsers();
    }
    
    /************************************************************************************************
    * @Description : this method will set hte offsetVal to display last page records                *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public void lstbtn() {
        offsetVal= totalrecs - math.mod(totalRecs,LimitSize);
        allPCUsers = getallPCUsers();
    }
    
    /************************************************************************************************
    * @Description : this method will get checks that hasmore records in current search             *
    * @Params      :                                                                              *
    * @Return      : void                                                                           *
    *************************************************************************************************/
    public Boolean gethasNext() {
        if((offsetVal + LimitSize) > totalRecs)
            return true;
        else
            return false;
        
    }
    
    /************************************************************************************************
    * @Description : this method will get checks that previous records in current search            *
    * @Params      :                                                                              *
    * @Return      : Boolean                                                                        *
    *************************************************************************************************/
    public Boolean gethasPrevious() {
        if(offsetVal == 0)
          return true;
        else
          return false;
    }
}