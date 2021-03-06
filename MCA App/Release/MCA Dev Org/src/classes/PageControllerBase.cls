/* 
This is a base class which can be extended by any page controller that will communicate 
with the controllers for compnents. 
  
  * Revision History:
  *   
  * Version         Author                                   Date                                    Description
  * 1.0             Nachiket R. Deshpande                    24/12/2014                              Initial Draft

*/
  
public with sharing virtual class PageControllerBase {

  /*
   these variables will hold references to the 4 component 
   controllers involved with the Custom Lead Convert Process
   
   New components and controllers should need to be added here 
   in order for the Visual Force page to communicate with them.
  */
  //this is the controller for leadConvertCoreComponentController
  public ComponentControllerBase myComponentController;
  
  //this is the controller for leadConvertTaskInfoComponentController
  public ComponentControllerBase myTaskComponentController;
  
  //this is the controller for leadConvertRemindComponentController
  public ComponentControllerBase myReminderComponentController;
  
  //this is the controller for leadConvertTaskDescComponentController
  public ComponentControllerBase myDescriptionComponentController;

  // this method will return the leadConvertCoreComponentController. It is overridden in the LeadConverController class
  public virtual ComponentControllerBase getMyComponentController() {

      return myComponentController;
 
  }

  // this method will return the leadConvertTaskInfoComponentController. It is overridden in the LeadConverController class
  public virtual ComponentControllerBase getmyTaskComponentController() {

      return myTaskComponentController;
 
  }
  
  // this method will return the leadConvertRemindComponentController. It is overridden in the LeadConverController class
  public virtual ComponentControllerBase getmyReminderComponentController() {

      return myReminderComponentController;
 
  }
  
  // this method will return the leadConvertTaskDescComponentController. It is overridden in the LeadConverController class
  public virtual ComponentControllerBase getmyDescriptionComponentController() {

      return myDescriptionComponentController;
 
  }

    // this method will return the leadConvertTaskInfoComponentController. It is overridden in the LeadConverController class
  public virtual void setTaskComponentController(ComponentControllerBase compController) {

      myTaskComponentController = compController;

  }

  // this method will set the leadConvertCoreComponentController. It is overridden in the LeadConverController class
  public virtual void setComponentController(ComponentControllerBase compController) {

      myComponentController = compController;

  }
  
  // this method will set the leadConvertRemindComponentController. It is overridden in the LeadConverController class
  public virtual void setReminderComponentController(ComponentControllerBase compController) {

      myReminderComponentController = compController;

  }
  
  // this method will set the leadConvertTaskDescComponentController. It is overridden in the LeadConverController class
  public virtual void setDescriptionComponentController(ComponentControllerBase compController) {

      myDescriptionComponentController = compController;

  }

  // return the instance of this class
  public PageControllerBase getThis() {

      return this;

  }
}