public with sharing class MCAContactRolesTabController {

  public OpportunityContactRole[] contactRoles;
  public Container[] containers;
  public Integer counter = 0;
  
  public Contact[] contactList {get;set;}
  
  
  public OpportunityContactRole[] newContactRoles {get; set;}
  
  public Boolean editAll {get;set;}
  
  public Id recordToDelete {get;set;}
  public Integer indexToRemove {get;set;}
  
  private Id opportunityId;
  
  public MCAContactRolesTabController() {
      counter =+ 1;
      system.debug('$$$$$$Counter in MCAContactRolesTabController = '+counter);
  
    opportunityId = Apexpages.currentPage().getParameters().get('id');
    
    refresh();
  }
  
  public Container[] getContainers() {
      counter =+ 1;
      system.debug('$$$$$$Counter in getContainers= '+counter);
  
  
    contactRoles = new OpportunityContactRole[] {};
    containers = new Container[] {};
    
    contactList = new Contact[] {};
    
    contactRoles.addAll(newContactRoles);
  
    /*contactRoles.addAll([SELECT 
                      SystemModstamp, 
                      Role, 
                      OpportunityId, 
                      IsPrimary, 
                      Id, 
                      ContactId 
                    From OpportunityContactRole
                    WHERE OpportunityId = :opportunityId]);
      */
     for(OpportunityContactRole oppConRole:[SELECT 
                      SystemModstamp, 
                      Role, 
                      OpportunityId, 
                      IsPrimary, 
                      Id, 
                      ContactId 
                    From OpportunityContactRole
                    WHERE OpportunityId = :opportunityId])
      {
          contactRoles.add(oppConRole);
          System.debug('%%%%%%%contactRoles***Size'+contactRoles.size()+'###'+contactRoles);
          if(!contactRoles.isEmpty())
          {
          for(Contact con:[Select Id,Phone,MobilePhone,Email from Contact where Id=:oppConRole.ContactId])
              {
                  contactList.add(con);
                  System.debug('%%%%%%%contactRoles***Size%%%%%%%'+contactRoles.size()+'contactList***Size'+contactList.size()+'###'+contactList);
              }
          }
      }
     /*if(!contactRoles.isEmpty())
     {              
     contactList.addAll([Select Id,Phone,MobilePhone,Email from Contact where Id=:contactRoles[0].ContactId]);
     }
     */
     /*
    if(!contactRoles.isEmpty() && contactRoles.size()==contactList.size())
    {
        for (Integer i = 0; i < contactRoles.size(); i++) {
          containers.add(new Container(contactRoles[i], i,contactList[i]));
        }
    }
    */
    /*
    if(!contactRoles.isEmpty() && contactRoles.size()==contactList.size()-1)
    {
        for (Integer i = 0; i < contactRoles.size(); i++) {
          containers.add(new Container(contactRoles[i], i));
        }
    }
    
     */
    if(!contactRoles.isEmpty())
    {
        if(contactRoles.size()!=contactList.size())
        {
            for (Integer i = 0; i < contactRoles.size(); i++) {
              containers.add(new Container(contactRoles[i], i));
            }
        }
        if(contactRoles.size()==contactList.size())
        {
            for (Integer i = 0; i < contactRoles.size(); i++) {
          containers.add(new Container(contactRoles[i], i,contactList[i]));
            }
        }
    }
   
    
                
    return containers;
                
    //return contactRoles;
  }  
  
  public void newContactRole() {
      counter =+ 1;
      system.debug('$$$$$$Counter in newContactRole= '+counter);
      
    newContactRoles.add(new OpportunityContactRole(OpportunityId = opportunityId));
  }  

  public void refresh() {
     
    editAll = false;
    recordToDelete = null;     
    newContactRoles = new OpportunityContactRole[] {};
  }
 
  public void save(){}
  
  public void saveAll() {
      
    upsert contactRoles; 
    //upsert contactList;  
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