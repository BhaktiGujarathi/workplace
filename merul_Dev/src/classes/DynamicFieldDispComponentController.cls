public class DynamicFieldDispComponentController {

public position__c obj
{ 
  get;
  set;
}


public pagereference save()
 {
 
 //DynamicFieldDispComponentController d= new DynamicFieldDispComponentController();

 update obj;
 system.debug('$$$$$$   '+ obj);
 
 return null;
 }


}