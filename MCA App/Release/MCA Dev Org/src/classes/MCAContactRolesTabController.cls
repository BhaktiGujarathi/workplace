public with sharing class MCAContactRolesTabController {
    public OpportunityContactRole[] contactRoles;
    public Container[] containers;
    public Integer counter = 0;
    public Contact[] contactList {get;set;}
    public Contact[] newContactList {get;set;}//added to  save contact  in  container
    public OpportunityContactRole[] newContactRoles {get; set;}  
    public Boolean editAll {get;set;}
    public Integer primaryIndex{get;set;}
    public Id recordToDelete {get;set;}
    public Integer indexToRemove {get;set;}
    private Id opportunityId;
    public Integer contactindex {get;set;}
    public Boolean isFirst;
    public Boolean isUpdated;
    public Map<Id, OpportunityContactRole> mapIDANDOppContactRole;
    public Map<Id, Contact> mapIDANDConatct;
    public Set<Integer> setInvalidRow;
    List<Id> listOppRole;
    List<Id> listContact;
    public List<OpportunityContactRole> listToUpdate;
    public List<Contact> listContactToUpdate;
    
    public contact con1 =new Contact();
    
    public void contactFetch(){
        system.debug('$$$$$$$container$$$$$$$$'+containers);
        List<Contact> con1=[Select Id,Phone,MobilePhone,Email from Contact where Id=:containers[contactindex].contactRole.ContactId];
        system.Debug('$$$-----------get contact--'+con1);
        containers[contactindex].contactList=con1[0];
        system.Debug ('$$$-------------new contact'+containers[contactindex].contactList);
        system.debug('after contact container'+containers);
    }
    
    public MCAContactRolesTabController() {
        isFirst=true;
        mapIDANDOppContactRole = new Map<Id, OpportunityContactRole>();
        setInvalidRow = new Set<Integer>();
        mapIDANDConatct = new Map<Id, Contact>();
        counter =+ 1;
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        refresh();
    }
    public Container[] getContainers() {
        counter =+ 1;
        system.debug('record to delete'+recordToDelete);
        system.debug('$$$$$$Counter in getContainers= '+containers);
        contactRoles = new OpportunityContactRole[] {};
        contactList = new Contact[] {};
        contactRoles.addAll(newContactRoles);
        contactList.addAll(newContactList);
        
        if (isFirst && !editAll && setInvalidRow.size() <= 0){
            isFirst=false;
            system.debug('in if');
            listOppRole = new List<Id>();
            listContact = new List<Id>();
            system.debug('in if clause'+containers);
            for(OpportunityContactRole oppConRole:[SELECT 
                      SystemModstamp, 
                      Role, 
                      OpportunityId, 
                      IsPrimary, 
                      Id, 
                      ContactId 
                    From OpportunityContactRole
                    WHERE OpportunityId = :opportunityId]){
             contactRoles.add(oppConRole);
             listOppRole.add(oppConRole.Id);
             if(!contactRoles.isEmpty()){
                for(Contact con:[Select Id,Phone,MobilePhone,Email from Contact where Id=:oppConRole.ContactId]){
                    listContact.add(con.Id);
                    contactList.add(con);
                  
               }
             }  
          }
      }else{
           system.debug('in else clause '+containers);
           system.debug('in remove else'+indexToRemove);
        for (Container containerVal: containers) {
            if (recordToDelete!=null){
                if(containerVal.contactRole.id<> recordToDelete){
                    contactRoles.add(containerVal.contactRole);
                    contactList.add(containerVal.contactList);
                }
            }else if(containerVal.index!=indexToRemove) {
                system.debug('111111in remove else'+containerVal.index);
                   contactRoles.add(containerVal.contactRole);
                   contactList.add(containerVal.contactList);
            }
            
       }
       system.debug('after all the process check list container'+containers);
       system.debug('after all the process check list contactroles'+contactRoles);
       system.debug('after all the process check list contactroles'+contactList);

    }

      containers = new Container[] {};
      system.debug(' container reintit'+containers);
      system.debug('contactrole'+contactRoles.size());
      system.debug('contactlist'+ contactList.size());
      Integer conCounter = 0;
        if(!contactRoles.isEmpty()){
        if(contactRoles.size()!=contactList.size()) {

            for(Integer i = 0; i < contactRoles.size(); i++) {
                if(setInvalidRow.contains(i)){
                    if (contactRoles[i].id==null){
                        if (i==contactindex){
                            contactRoles[i].ContactId=con1.id;
                            assginContinerVal(contactRoles[i], i,con1, true);
                        }
                        else{ 
                            assginContinerVal(contactRoles[i], i,new Contact(), true);
                        }// End Else - If 
                    } 
                    else if(containers[conCounter].contactList == contactList[conCounter]){ 
                        assginContinerVal(contactRoles[i], i,contactList[conCounter], true); 
                        conCounter++;
                    }
                    else {
                        assginContinerVal(contactRoles[i], i,contactList[conCounter], true); 
                        conCounter++;
                    }// End Else - If
                } else {
                    if (contactRoles[i].id==null){
                        if (i==contactindex){
                            contactRoles[i].ContactId=con1.id;
                            assginContinerVal(contactRoles[i], i,con1, false);
                        }
                        else{ 
                            assginContinerVal(contactRoles[i], i,new Contact(), false);
                        }// End Else - If 
                    } 
                    else if(containers[conCounter].contactList == contactList[conCounter]){ 
                        assginContinerVal(contactRoles[i], i,contactList[conCounter], false); 
                        conCounter++;
                    }
                    else {
                        assginContinerVal(contactRoles[i], i,contactList[conCounter], false); 
                        conCounter++;
                    }// End Else - If
                }//  End Else - If
            }//End For
        }// End Else - If
        if(contactRoles.size()==contactList.size()) {
            for (Integer i = 0; i < contactRoles.size(); i++) {
                if(setInvalidRow.contains(i))
                    assginContinerVal(contactRoles[i], i,contactList[i], true);
                else 
                    assginContinerVal(contactRoles[i], i,contactList[i], false);
            }//End For
        }//End If
    }// End IF
     
     newContactRoles=new List<OpportunityContactRole>();
     newContactList=new List<Contact>(); 
     recordToDelete=null;
     indexToRemove=-99;
     contactindex=-99; 
     return containers;
  }
    //Assign/ add value to container
    public void assginContinerVal(OpportunityContactRole contactRoles, Integer i, 
            Contact contactList, Boolean iseditVal) {
        containers.add(new Container(contactRoles, i,contactList, iseditVal));
    }// End assginContinerVal()
    
    
    public void getOppContactRoleList() {
        mapIDANDOppContactRole = new Map<Id, OpportunityContactRole>([SELECT 
                                                                          SystemModstamp, 
                                                                          Role, 
                                                                          OpportunityId, 
                                                                          IsPrimary, 
                                                                          Id, 
                                                                          ContactId 
                                                                        From OpportunityContactRole
                                                                        WHERE OpportunityId =:opportunityId]);
        
    }
    
    public void getContactList() { 
        mapIDANDConatct = new Map<Id, Contact>([Select Id,Phone,MobilePhone,Email from Contact where Id IN:listContact]);
    }
    public void newContactRole() {
        saveMessage();
       /* counter =+ 1;   
        isUpdated = false;
        checkoldAndNewVal();
        if(editAll !=true && isUpdated == true){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
            updateInlineEditedValue();
        }*/
        newContactRoles.add(new OpportunityContactRole(OpportunityId = opportunityId));
        newContactList.add(new Contact());
    }
    
    public void removeRoles(){
        saveMessage();
    }
    
    public void saveMessage(){
        isUpdated = false;
        counter =+ 1;
        checkoldAndNewVal();
        if(editAll !=true && isUpdated == true){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
            updateInlineEditedValue();
        }
    }
    
    public void updateInlineEditedValue() {
        String ContactRoleMsgStr = '';
        String ContactMsgStr = '';
        try{
            //update listToUpdate;
            List<Database.saveResult> contactRoleResult = Database.update(listToUpdate, false);
            for (Integer i =0; i < contactRoleResult.size(); i++) {
              if (!contactRoleResult[i].isSuccess()){
                  for (Database.Error err : contactRoleResult[i].getErrors()){
                      ContactRoleMsgStr = ContactRoleMsgStr + 'Error: '+ err.getMessage()+ ' For record with serial number : ' +(containers[i].index +1) + '<br />';
                  }
              }
           }
           if(!ContactRoleMsgStr.contains('Argument 2 cannot be null') && String.isNotBlank(ContactRoleMsgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ContactRoleMsgStr));
            
            //update listContactToUpdate;
            List<Database.saveResult> contactResult = Database.update(listToUpdate, false);
            for (Integer i =0; i < contactResult.size();i++) {
              if (!contactResult[i].isSuccess()){
                  for (Database.Error err : contactResult[i].getErrors()){
                      ContactMsgStr = ContactMsgStr + 'Error: ' + err.getMessage()+ ' For record with serial number : ' +(containers[i].index +1) + '<br />';
                  }
              }
           }
           if(!ContactMsgStr.contains('Argument 2 cannot be null') && String.isNotBlank(ContactMsgStr )) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,ContactMsgStr ));
            
        }
        catch(Exception e){
            system.debug('***Enter In Exception****');
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }
    
    public void checkoldAndNewVal() {
        OpportunityContactRole opportunityContactRoleValue = new OpportunityContactRole();
        Contact contactValue = new Contact();
        listToUpdate = new List<OpportunityContactRole>();
        listContactToUpdate = new List<Contact>();
        getOppContactRoleList();
        getContactList();
        system.debug('containerContactRole++++++'+containers);
        system.debug('mapIDANDOppContactRole+++++++++'+mapIDANDOppContactRole);
        system.debug('mapIDANDConatct++++++++++++'+mapIDANDConatct );
        for (Container containerVal: containers) {  
            if(containerVal.contactRole.id != null){
                opportunityContactRoleValue = mapIDANDOppContactRole.get(containerVal.contactRole.id);
                if(opportunityContactRoleValue != null && containerVal.contactRole.ContactId != null){
                    contactValue = mapIDANDConatct.get(containerVal.contactList.id);
                    if(contactValue != null) {
                        if(containerVal.contactRole.ContactId != opportunityContactRoleValue.ContactId
                        || containerVal.contactRole.IsPrimary != opportunityContactRoleValue.IsPrimary
                        || containerVal.contactRole.Role != opportunityContactRoleValue.Role
                        || containerVal.contactList.Phone != contactValue.Phone
                        || containerVal.contactList.MobilePhone != contactValue.MobilePhone
                        || containerVal.contactList.Email != contactValue.Email ){
                            listToUpdate.add(containerVal.contactRole);
                            listContactToUpdate.add(containerVal.contactList);
                            isUpdated = true;
                        }
                    }
                }
            }
        }
    }
  public String isNullCheck(String strVal) {
    return strVal == null? ' ' : strVal;
  }
  public Id isIdNullCheck(Id IdVal) {
    return IdVal == null? ' ' : IdVal;
  }
  public void refresh() {
    editAll = false;
    isFirst=true;
    recordToDelete = null;     
    newContactRoles = new OpportunityContactRole[] {};
    newContactList= new Contact[]{}; 
  }
  
  public void save(){}
  
  public void saveAll() {
  
    try{  
      List<Contact> oldcontactlist= new List<Contact>();
      Map<Id, Contact> newMapIdToContact = new Map<Id, Contact>();
      Map<Id, Contact> oldMapIdToContact = new Map<Id, Contact>();
      set<Id> setContact = new set<Id>();  
      for(Contact conObj : contactList) {
          setContact.add(conObj .Id);
      } 
      oldcontactlist = [Select Id,Phone,MobilePhone,Email from Contact where Id=:setContact];
      for(Contact oldConObj : oldcontactlist) {
          oldMapIdToContact.put(oldConObj.Id, oldConObj);
      }
      
      for(Contact conObj : contactList) {
          Contact contactObj = oldMapIdToContact.get(conObj.Id);
          
          if(newMapIdToContact.containsKey(conObj.Id)){
              Contact conTemp = newMapIdToContact.get(conObj.Id);
              system.debug('>>>4conTempbefor Update' +conTemp);
              if(contactObj.Phone <> conObj.Phone ) {
                  conTemp.Phone = conObj.Phone;
              }
              if(contactObj.Email <> conObj.Email ) {
                 conTemp.Email = conObj.Email;
              }
              if(contactObj.MobilePhone <> conObj.MobilePhone) {
                 conTemp.MobilePhone = conObj.MobilePhone;
              }
              system.debug('>>>5conTemp' +conTemp);
              newMapIdToContact.put(conObj.Id, conTemp);
              
          }
          else {
              newMapIdToContact.put(conObj.Id, conObj);
          }

      }

      //setContact.addall(contactList);
     contactlist.clear();
     setInvalidRow.clear();
     contactlist.addall(newMapIdToContact.values());
     //update contactlist; 
     List<Database.saveResult> contactRoleResult = Database.update(listToUpdate, false);
     String contactRoleMsgStr = '';
        for (Integer i =0; i < contactRoleResult.size(); i++) {
          if (!contactRoleResult[i].isSuccess()){
              for (Database.Error err : contactRoleResult[i].getErrors()){
                  contactRoleMsgStr = contactRoleMsgStr + 'Error: '+ err.getMessage()+ ' For record with serial number : ' +(containers[i].index +1) + '<br />';
                  setInvalidRow.add(i);
              }
          }
       }
       if(!ContactRoleMsgStr.contains('Argument 2 cannot be null') && String.isNotBlank(contactRoleMsgStr)) 
           ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,contactRoleMsgStr)); 
     //upsert contactRoles;
      List<Database.upsertResult> contactRolesResults = Database.upsert(contactRoles, false);
       String msgStr = '';
       for(Integer i = 0; i<contactRolesResults.size(); i++) {
          if (!contactRolesResults[i].isSuccess()){
              for (Database.Error err : contactRolesResults[i].getErrors()){
                 msgStr = msgStr + 'Error: ' + err.getMessage() + ' For record with serial number : ' +(containers[i].index +1) + '<br />';
                 setInvalidRow.add(i);
              }
          }
      }
      
     if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
           ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, msgStr)); 
     
    }
    catch(Exception e){
        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
    }
    refresh();
  }
  public void editAll() {
    editAll = true;
    //isFirst=true;
  }
  public void deleteContactRole() {
      saveMessage();
    if (recordToDelete != null) {
        OpportunityContactRole record = [SELECT Id FROM OpportunityContactRole WHERE Id = :recordToDelete];
        try {
            delete record;
        } catch (Exception ex) {
            indexToRemove = -99;
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
        }
    }
  }
  
  
  public class Container {
    public OpportunityContactRole contactRole {get;set;}
    public Integer index {get;set;}
    public Contact contactList {get;set;}
    public Boolean isedited {get;set;}
    public Container(OpportunityContactRole instance, Integer index,Contact ins, Boolean isedited) {
      contactRole = instance;
      contactList = ins;
      this.index = index;
      this.isedited = isedited;
    }
    public Container(OpportunityContactRole instance, Integer index) {
      contactRole = instance;     
      this.index = index;
    }
  }
}