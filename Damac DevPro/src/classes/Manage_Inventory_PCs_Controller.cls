public with sharing class Manage_Inventory_PCs_Controller {
    public Search_User__c searchUser {get;set;}
    public String tableHeader {get;set;}
    public List<User> lstUsers {get;set;}
    public static Date iStartDate {get;set;}
    public static Date iEndDate {get;set;}
    public String errorMessage {get;set;}
    public String selectedUserIds {get;set;}

    @testVisible private String queryString {get;set;}

    public static String inventoryID {
        get{
            inventoryID = ApexPages.CurrentPage().getParameters().get('id');
            return inventoryID;
        }
        set;
    }

    public Inventory__c inventoryRec {
        get{
            if(inventoryRec == null && String.isNotBlank(inventoryID))
                inventoryRec = [SELECT ID,Name,Start_Date__c,End_Date__c FROM Inventory__c WHERE Id =:inventoryID];
            return inventoryRec;
        }
        set;
    }

    @testVisible private static Set<ID> existingUsers {get;set;}

    public Manage_Inventory_PCs_Controller(ApexPages.StandardController ctrl){
        inventoryRec = (Inventory__c)ctrl.getRecord();
    }

    public ApexPages.StandardSetController controller {
        get{
            if(controller == null) {
                System.debug('queryString==> '+queryString);
                controller = new ApexPages.StandardSetController(Database.query('SELECT Id,Name,UserName FROM USER WHERE ID NOT IN: existingUsers AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:iStartDate AND Leave_Start_Date__c <=:iStartDate) OR (Leave_Start_Date__c >=:iEndDate)) ) LIMIT 50000'));
            }
            // sets the number of records in each page set
            controller.setPageSize(20);
            return controller; 
        }
        set;
    }

    /**
    * Inventory_Manage_PCs_Controller(): Controller
    **/
    public Manage_Inventory_PCs_Controller(){
        searchUser = new Search_User__c();
        selectedUserIds = '';
        tableHeader = 'Select Property Consultants';
        getExistingUserIDs();
        iStartDate = inventoryRec.Start_Date__c;
        iEndDate = inventoryRec.End_Date__c;
        lstUsers = getlstUsers();
        iStartDate = iEndDate = null;
        errorMessage = null;
    }

    @testVisible static private void getExistingUserIDs(){
        existingUsers = new Set<ID>();
        for(Inventory_User__c invUser : new List<Inventory_User__c>([SELECT User__c FROM Inventory_User__c WHERE Inventory__c =: inventoryID AND User__c != null])){
            existingUsers.add(invUser.User__c);
        }
    }

    public List<User> getlstUsers(){
        lstUsers = new List<User>();
        System.debug('=======lstUsers=======>'+lstUsers);
        for (User userRec : (List<USer>)controller.getRecords()) {
            lstUsers.add(userRec);
        }
        if( lstUsers.size() == 0 ){
            errorMessage = 'Property Consultants are already added / not available to add users';
        }
        System.debug('lstUsers = '+lstUsers);
        return lstUsers;
    }

    @RemoteAction
    public static List<String> autoCompleteForUsers(String searchTerm,String inv,String autoFor) {
        System.debug('Search String is: '+searchTerm +'MS = '+iStartDate+',MD'+iEndDate+'=>'+inv);
        set<ID> extUserIDs = new Set<ID>();
        List<String> users = new List<String>();
        String queryStr = 'Select Id, Name from User WHERE Name like \'%' + String.escapeSingleQuotes(searchTerm) + 
                          +'%\' AND Profile.Name='+((autoFor == 'Property') ? '\'Property Consultant\'':((autoFor == 'HOS') ? '\'Head of Sales\'' : ((autoFor == 'DOS') ? '\'Director of Sales\'':'')))+
                          +' AND IsActive = true';

        
        System.debug('existingUsers = '+existingUsers);
        try{
            if(String.isNotBlank(inv)){
                Inventory__c invRec = [SELECT ID,Name,Start_Date__c,End_Date__c,(SELECT User__c FROM Inventory_Users__r WHERE User__c != null) FROM Inventory__c WHERE ID=:inv];
                
                for(Inventory_User__c invU : invRec.Inventory_Users__r)
                        extUserIDs.add(invU.User__c);
                if(extUserIDs.size() > 0)
                    queryStr +=' AND ID NOT IN:extUserIDs';

                if(invRec.Start_Date__c != null && invRec.End_Date__c != null){
                    iStartDate = invRec.Start_Date__c;
                    iEndDate = invRec.End_Date__c;
                    System.debug('MS = '+iStartDate+',MD'+iEndDate+'=>'+inv);
                    
                    if (autoFor != 'DOS' && autoFor != 'HOS' && iStartDate != null && iEndDate != null)
                        queryStr +=' AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:iStartDate AND Leave_Start_Date__c <=:iStartDate) OR (Leave_Start_Date__c >=:iEndDate)) )';
                }
            }
            
            for(User U: Database.query(queryStr)){
                users.add(U.Name);
            }
            //errorMessage = null;
        }catch(Exception ex){
            //errorMessage = ex.getMessage();
        }
        return users;
    }

    public void serachforUsersWithFilters(){
        
        queryString = prepareQueryString();
        try{
            if(String.isNotBlank(queryString) && String.isNotBlank(searchUser.Name) || String.isNotBlank(searchUser.PC_Languages__c) || String.isNotBlank(searchUser.PC_Nationality__c) 
               || String.isNotBlank(searchUser.DOS__c) || String.isNotBlank(searchUser.HOS__c) || String.isNotBlank(searchUser.Team__c)) {
                System.debug('Final queryString= '+queryString);
                controller = new ApexPages.StandardSetController(Database.query(queryString));
            } else {
                controller = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id,Title, Name,Email,UserName,Profile.Name FROM User WHERE Profile.Name ='Property Consultant' AND ID NOT IN:existingusers AND IsActive = true AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:iStartDate AND Leave_Start_Date__c <=:iStartDate) OR (Leave_Start_Date__c >=:iEndDate)) ) Order By Name limit 50000]));
            }
        }catch(Exception ex){
            errorMessage = ex.getMessage();
        }
    }

    @testVisible private String prepareQueryString(){

        //System.debug('searchUSer1 = '+manageHelper.searchText);
        
        String lang = '\''+searchUser.PC_Languages__c+'\'', nantion = searchUser.PC_Nationality__c, team = searchUser.Team__c,queryStr='',nameStr = searchUser.Name,groupID = '';
        List<String> lstLan = new List<String>{lang};
        Set<ID> managerIds = new Set<ID>();
        Set<ID> groupMemberIDs = new Set<ID>();
        try{
            if(String.isNotBlank(team)){
                groupID = [SELECT DeveloperName FROM Group WHERE Name='team'].id;
                groupMemberIDs = UtilityQueryManager.getUserIdsFromGroups(new Set<ID>{groupID});
            }
            String managerQuery = 'SELECT ID FROM USER WHERE ';
            managerQuery += ((String.isNotBlank(searchUser.DOS__c) && String.isNotBlank(searchUser.HOS__c)) ? '(Name LIKE \'%'+searchUser.DOS__c+'%\' OR Name LIKE \'%'+searchUser.DOS__c+'%\')':(String.isNotBlank(searchUser.DOS__c) ? '(Name LIKE \'%'+searchUser.DOS__c+'%\')': String.isNotBlank(searchUser.HOS__c) ? '(Name LIKE \'%'+searchUser.HOS__c+'%\')':''));
            
            if(String.isNotBlank(searchUser.DOS__c) || String.isNotBlank(searchUser.HOS__c)){
                for(USer U : Database.query(managerQuery))
                    managerIds.add(u.id);
            }  
            System.debug('managerIds = '+managerIds); 
            
            queryStr = 'Select Id, Name,Email,UserName,Profile.Name FROM User WHERE ID NOT IN:existingUsers'+
                            +' AND IsActive = true AND ((Leave_Start_Date__c = null AND Leave_End_Date__c = null) OR ((Leave_End_Date__c <=:iStartDate AND Leave_Start_Date__c <=:iStartDate) OR (Leave_Start_Date__c >=:iEndDate)) )'+
                            +' AND Profile.Name =\'Property Consultant\'';
            queryStr += (!groupMemberIDs.isEmpty() ? ' AND ID IN:groupMemberIDs':'');
            queryStr += (!managerIds.isEmpty() ? ' AND (ManagerId IN: managerIds OR Manager.ManagerId IN: managerIds OR Manager.Manager.ManagerId IN: managerIds OR Manager.Manager.Manager.ManagerId IN: managerIds)' : '');
            queryStr +=((String.isNotBlank(nameStr)) ? ' ; (Name LIKE \'%'+nameStr+'%\' OR UserName LIKE \'%'+searchUser.Name+'%\')':'');
            queryStr +=((String.isNotBlank(lang)) ? ' ; Languages_Known__c includes '+lstLan:''); 
            queryStr +=((String.isNotBlank(nantion)) ? ' ; TimeZoneSidKey LIKE \'%'+nantion+'%\'':'');
            
            queryStr += ' Order By Name ';
            queryStr = queryStr.replace(';','AND');

            errorMessage = null;

        }catch(Exception ex){
            errorMessage = ex.getMessage();
        }
        return queryStr;
    }

    public void createInventoryUsers(){

        String[] selectedIDs = new List<String>();
        List<Inventory_User__c> lstInvUsers = new List<Inventory_User__c>();
        try{
            if(String.isBlank(selectedUserIds)){
                errorMessage = 'Please select at least one user';
            } else {
                for(String userID : selectedUserIds.split(',')){
                    lstInvUsers.add(new Inventory_User__c( User__c = userID,Inventory__c=inventoryID));
                }

                if(!lstInvUsers.isEmpty()){
                    insert lstInvUsers;
                    errorMessage = null;
                }
            }
        }catch(Exception ex){
            errorMessage = ex.getMessage();
        }
    }
}