public with sharing class TabsObjectController {

  public TabsOpportunityListWrapper element {get; set;}
  public String objectName {get; set;}
  
  private Map<Integer, Wrapper> wrappers; 

  public TabsObjectController() {
    wrappers = new Map<Integer, Wrapper>();
    objectName = '';
  }
  
  public Map<Integer, Wrapper> getWrappers() {
  
    Integer index = 1;
    
    system.debug(element.records);
    for (sObject record :element.records) {
    
      Wrapper wrapper = new Wrapper(record, index);
      wrappers.put(index, wrapper);  

      index ++;
    }
    
    return wrappers;
  }
  
  public String[] getMappingFields() {
  
    return TabsOpportunityControllerUtils.getFieldsMapping(objectName);
  }
  
  public class Wrapper {
    public sObject record {get; set;}
    public Integer index {get; set;}
    
    public Wrapper(sObject record, Integer index) {
      this.record = record;
      this.index = index;
    }
  }

}