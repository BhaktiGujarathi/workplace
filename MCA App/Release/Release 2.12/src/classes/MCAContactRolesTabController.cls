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
        
        if (isFirst && !editAll){
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
        if(contactRoles.size()!=contactList.size()){
         system.debug(' container reintit'+containers);
            for(Integer i = 0; i < contactRoles.size(); i++) {
             if (contactRoles[i].id==null){
                 if (i==contactindex){
                  system.debug(contactindex +'hello+++' + i);
                         contactRoles[i].ContactId=con1.id;
                     containers.add(new Container(contactRoles[i], i,con1));
                   }
                   else{ 
                    containers.add(new Container(contactRoles[i], i,new Contact()));
                    } 
                 } 
              else if(containers[conCounter].contactList == contactList[conCounter]){ 
                  containers.add(new Container(contactRoles[i], i,contactList[conCounter])); 
                  conCounter++;
              }
              else {
                  containers.add(new Container(contactRoles[i], i,contactList[conCounter])); 
                  conCounter++;
              }
            }
        }
        if(contactRoles.size()==contactList.size())
        {
            for (Integer i = 0; i < contactRoles.size(); i++) {
                   containers.add(new Container(contactRoles[i], i,contactList[i]));
            }
        }
     }
     system.debug(' container reintit'+containers);
     newContactRoles=new List<OpportunityContactRole>();
     newContactList=new List<Contact>(); 
     recordToDelete=null;
     indexToRemove=-99;
     contactindex=-99; 
     return containers;
  }
    
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
        try{
            update listToUpdate;
            update listContactToUpdate;
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
      System.debug('>>>1oldcontactlist' +oldcontactlist);
      System.debug('>>>2oldMapIdToContact' +oldMapIdToContact);
      for(Contact conObj : contactList) {
          Contact contactObj = oldMapIdToContact.get(conObj.Id);
          System.debug('>>>3contactObj  before update' +contactObj);
          
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
     contactlist.addall(newMapIdToContact.values());
     update contactlist;  
     upsert contactRoles; 
     
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
    delete record;
    }
  }
  
  
  public class Container {
    public OpportunityContactRole contactRole {get;set;}
    public Integer index {get;set;}
    public Contact contactList {get;set;}
    public Container(OpportunityContactRole instance, Integer index,Contact ins) {
      contactRole = instance;
      contactList = ins;
      this.index = index;
    }
    public Container(OpportunityContactRole instance, Integer index) {
      contactRole = instance;     
      this.index = index;
    }
  }
}