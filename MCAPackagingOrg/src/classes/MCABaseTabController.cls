public with sharing class MCABaseTabController {

}
/*
public with sharing class MCABaseTabController {

  public sObject[] records;
  public sObject newRecord {get; set;}
  
  public Boolean editAll {get;set;}
  
  public Integer recordFirst {get;set;}
  public Boolean recordAdd {get;set;}
  
  public Id recordToDelete {get;set;}
  
  public String objectName {get;set;}
  
  protected Id opportunityId;

  public MCABaseTabController(String objectName) {
  
    this.objectName = objectName;
    opportunityId = Apexpages.currentPage().getParameters().get('id');
    
    refresh();  
  }

  public sObject[] getRecords() {
  
    newRecord = getNewRecord();
    records = new sObject[] {newRecord};
    
    String query = MCABaseTabControllerUtils.getQuery(objectName);
    records.addAll(Database.query(query));
                    
    return records;
  }

  public void refresh() {

    recordFirst = 1;
    recordAdd = false;
    
    recordToDelete = null;
    editAll = false;
    
    newRecords();  
  }

  public void editAll() {
    
    editAll = true;
  }

  public void saveAll() {
  
    if (recordAdd) {
        insert newRecord;
    }

    records.remove(0);  
    update records;
    
    refresh();
  }
   
  public void newRecords() {
  
    newRecord = getNewRecord();
  }
  
  public void newRecord() {
    recordFirst = 0;
    recordAdd = true;
  }
    
  
  public void deleteRecord() {
  
    if (recordToDelete != null) {
       
      String sql = 'SELECT Id FROM ' + objectName + ' WHERE Id = :recordToDelete';
      sObject[] objects = Database.query(sql);
       
      if (!objects.isEmpty()) {
        delete objects; 
      }
    }
  }

  
  private sObject getNewRecord() {
  
    sObject result = MCABaseTabControllerUtils.getNewRecord(objectName);
    result.put(MCABaseTabControllerUtils.getOpportunityReferenceName(objectName),  opportunityId);
    return result;  
  }

}  */