public with sharing class MCAContactRolesTabController {

  public OpportunityContactRole[] contactRoles;
  public Container[] containers;
  
  public OpportunityContactRole[] newContactRoles {get; set;}
  
  public Boolean editAll {get;set;}
  
  public Id recordToDelete {get;set;}
  public Integer indexToRemove {get;set;}
  
  private Id opportunityId;
  
  public MCAContactRolesTabController() {
  
    opportunityId = Apexpages.currentPage().getParameters().get('id');
    
    refresh();
  }
  
  public Container[] getContainers() {
  
    contactRoles = new OpportunityContactRole[] {};
    containers = new Container[] {};
    
    contactRoles.addAll(newContactRoles);
  
    contactRoles.addAll([SELECT 
                      SystemModstamp, 
                      Role, 
                      OpportunityId, 
                      IsPrimary, 
                      Id, 
                      ContactId 
                    From OpportunityContactRole
                    WHERE OpportunityId = :opportunityId]);
      
    
    for (Integer i = 0; i < contactRoles.size(); i++) {
      containers.add(new Container(contactRoles[i], i));
    }
                
    return containers;
                
    //return contactRoles;
  }  
  
  public void newContactRole() {
  
    newContactRoles.add(new OpportunityContactRole(OpportunityId = opportunityId));
  }  

  public void refresh() {

    editAll = false;
    recordToDelete = null;
    
    newContactRoles = new OpportunityContactRole[] {};
  }

  public void saveAll() {
  
    upsert contactRoles;
    refresh();
  }
  
  public void editAll() {
    editAll = true;
  }  
  
  public void deleteContactRole() {
  
    if (recordToDelete != null) {
      OpportunityContactRole record = [SELECT Id FROM OpportunityContactRole WHERE Id = :recordToDelete];
      delete record;
    }
  }    
  
  
  public void removeContactRole() {
  
    if (indexToRemove != null) {
      
      Container c = null;
      
      for (Container element :containers) {
        
        if (element.index == indexToRemove) {
          c = element;
        }
      }
      newContactRoles.remove(c.index);
    }
  
  }     
  
  public class Container {
  
    public OpportunityContactRole contactRole {get;set;}
    public Integer index {get;set;}
  
    public Container(OpportunityContactRole instance, Integer index) {
      contactRole = instance;
      this.index = index;
    }
  
  }      

}