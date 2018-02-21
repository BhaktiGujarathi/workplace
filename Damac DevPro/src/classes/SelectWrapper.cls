/**************************************************************************************************
* Name                  : SelectWrapper                                                 
* Description           : This class will be used as wrapper class which will help us in selection scenarios
* Created By            : NSI - Sivasankar K                                                                        
* Created Date          : 12/Jan/2017                                                                  
* Last Modified Date    :                                                                            
* Last Modified By      :                                                                            
* ----------------------------------------------------------------------------------------------- 
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                                                      
* CH00              1.0         NSI - Sivasankar K         12/Jan/2017      
* CH01              2.0
* CH02              3.0
**************************************************************************************************/
public class SelectWrapper {
    public Boolean checked {get;set;}
    public sObject objectType {get;set;}
    
    public SelectWrapper(sObject objectRec){
        checked = false;
        objectType = objectRec ;
    }
}