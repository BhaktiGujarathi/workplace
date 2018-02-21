global without sharing class ManageDealTeam implements NSIBPM.CustomCodeExecutable {
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step){
        String retStr = 'Success';
        try{
            NSIBPM__Service_Request__c objSR = SRUtility.getSRDetails(step.NSIBPM__SR__c);
            if(objSR.NSIBPM__Record_Type_Name__c == 'Change_Agent'){
                 ChangeAgent(objSR);
            }else if(objSR.NSIBPM__Record_Type_Name__c == 'Change_Manager'){
                ChangeMgr(objSR);                
            }else if(objSR.NSIBPM__Record_Type_Name__c == 'Change_PC'){
                ChangePC(objSR);
            }
            return retStr;
        }
        catch(exception ex){
            return ex.getMessage();
        }
    }
    
    public static void ChangePC(NSIBPM__Service_Request__c objSR){
        //check for parent sr field not null
        if(objSR.NSIBPM__Parent_SR__c != null){
            NSIBPM__Service_Request__c objParentSR = SRUtility.getSRDetails(objSR.NSIBPM__Parent_SR__c);
            //check for parent sr record type
            if(objParentSR.NSIBPM__Record_Type_Name__c == 'Deal' && objSR.Change_Type__c != null){
                boolean isadd = (objSR.Change_Type__c == 'Add') ? true : false;
                boolean isRemove = (objSR.Change_Type__c == 'Remove') ? true : false;
                boolean isChange = (objSR.Change_Type__c == 'Change') ? true : false;
                Deal_Team__c dlTeamRectoupdate = new Deal_Team__c();
                //check if PC needs to be changed or removed.
                if(isChange || isRemove){
                    if((objSR.Select_User_1__c != null && objSR.Select_User_2__c != null && ischange) || (isRemove && objSR.Select_User_1__c != null)){
                        //get all deal team records
                        for(Deal_Team__c dt : [select id,name,Associated_Deal__c,Associated_DOS__c,
                                               Associated_HOS__c,Associated_PC__c,Unique_Key__c
                                               from Deal_Team__c where Associated_Deal__c != null and 
                                               Associated_Deal__c =: objParentSR.id and 
                                               Associated_PC__c != null and Associated_PC__c =: objSR.Select_User_1__c]){
                            //assuming there will be only one record matching the criteria.
                            if(isChange){
                                 //change the existing PC to the new PC
                                 dlTeamRectoupdate = dt;
                                 dlTeamRectoupdate.Associated_PC__c = objSR.Select_User_2__c;
                                 dlTeamRectoupdate.Unique_Key__c = dt.Associated_Deal__c+' - '+objSR.Select_User_2__c;
                                 update dlTeamRectoupdate;
                                 break;
                            }//remove an existing PC
                            else if(isremove){
                                dlTeamRectoupdate = dt;
                                dlTeamRectoupdate.Status__c = 'Inactive';
                                update dt;
                                break;
                            }
                            
                        }
                    }
                }
                //Check if PC needs to be added.
                else if(isadd && objSR.Select_User_2__c != null){
                    //get the PC details
                    User u = [select id,userrole.name,managerid,manager.userrole.name,manager.managerid,manager.manager.userrole.name from user where id = : objSR.Select_User_2__c];
                    dlTeamRectoupdate.Associated_PC__c = objSR.Select_User_2__c;
                    dlTeamRectoupdate.Associated_Deal__c = objParentSR.id;
                    dlTeamRectoupdate.Status__c = 'Active';
                    dlTeamRectoupdate.Unique_Key__c = objParentSR.id+' - '+dlTeamRectoupdate.Associated_PC__c;
                    if(u.managerid != null){ 
                        //if the immediate manager role is dos
                        if(u.manager.userrole.name.tolowercase().contains('dos')){
                           dlTeamRectoupdate.Associated_DOS__c = u.managerid;
                            //if level 2 manager role is HOS
                            if(u.manager.managerid != null && u.manager.manager.userrole.name.tolowercase().contains('hos')){
                               dlTeamRectoupdate.Associated_HOS__c = u.manager.managerid;
                           }
                       }
                       //if the immediate manager role is hos
                        else if(u.manager.userrole.name.tolowercase().contains('hos')){
                           dlTeamRectoupdate.Associated_HOS__c = u.managerid;
                       }
                    }
                    //insert the Deal Team record.
                    insert dlTeamRectoupdate;
                }
                
            }
        }
    }
    
    
    public static void ChangeMgr(NSIBPM__Service_Request__c objSR){
        //check for parent sr field not null
        if(objSR.NSIBPM__Parent_SR__c != null){
            NSIBPM__Service_Request__c objParentSR = SRUtility.getSRDetails(objSR.NSIBPM__Parent_SR__c);
            //check for parent sr record type
            if(objParentSR.NSIBPM__Record_Type_Name__c == 'Deal' && objSR.Change_Type__c != null){
                boolean isHOSUpdate = (objSR.Change_Type__c == 'HOS') ? true : false;
                boolean isDOSUpdate = (objSR.Change_Type__c == 'DOS') ? true : false;
                if(objSR.Select_User_1__c != null && objSR.Select_User_2__c != null){
                    for(Deal_Team__c dt : [select id,name,Associated_Deal__c,Associated_DOS__c,
                                               Associated_HOS__c,Associated_PC__c,Unique_Key__c
                                               from Deal_Team__c where Associated_Deal__c != null and 
                                               Associated_Deal__c =: objParentSR.id and
                                               (Associated_PC__c =: objSR.Select_User_1__c or Associated_PC__c =: objSR.Select_User_1__c)]){
                                                   if(isHOSUpdate){
                                                       dt.Associated_HOS__c = objSR.Select_User_2__c;
                                                       update dt;
                                                       break;
                                                   }
                                                   else if(isDOSUpdate){
                                                       dt.Associated_DOS__c = objSR.Select_User_2__c;
                                                       update dt;
                                                       break;
                                                   }
                    }
                }
            }
        }
    }
    public static void ChangeAgent(NSIBPM__Service_Request__c objSR){
        if(objSR.NSIBPM__Parent_SR__c != null){
            NSIBPM__Service_Request__c objParentSR = SRUtility.getSRDetails(objSR.NSIBPM__Parent_SR__c);
            if(String.isNotBlank(objSR.Change_Type__c) && objSR.Change_Type__c.equalsIgnoreCase('Remove')){
                objParentSR.Agency__c = null;
                objParentSR.Agent_Name__c = null;
                update objParentSR;
            }
            else if(objSR.Agency_Type__c != null && objSR.Agency__c != null){
                if(objSR.Agency_Type__c == 'Corporate'){
                    objParentSR.Agency__c = objSR.Agency__c;
                    objParentSR.Agent_Name__c = (objSR.Agent_Name__c != null) ? objSR.Agent_Name__c : null;
                    update objParentSR;
                }
                else if(objSR.Agency_Type__c == 'Individual'){
                    objParentSR.Agency__c = objSR.Agency__c;
                    objParentSR.Agent_Name__c = null;
                    update objParentSR;
                }
            }
            
            list<Booking__c> lstbookings = (list<Booking__c>)SRUTILITY.getRecords('Booking__c',' where Deal_SR__c =\''+objSR.NSIBPM__Parent_SR__c+'\'');
            List<id> lstbkids = new List<id>();
            for(Booking__c bk : lstbookings){
                lstbkids.add(bk.id);
            }
            system.debug('--->lstbkids'+lstbkids);
            system.enqueueJob(new AsyncReceiptWebservice (lstbkids, 'Agent Update'));
       }
    }
}