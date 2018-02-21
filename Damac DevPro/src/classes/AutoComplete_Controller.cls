/**************************************************************************************************
* Name                  : AutoComplete_Controller    
* component Page        : AutoComplete
* Description           : This class will invoke from Autocomplete component, it will display all records for autocomplete available.
* Created By            : NSI - Sivasankar K                                                                        
* Created Date          : 11/Feb/2017 
* Last Modified Date    :                                                                            
* Last Modified By      :                                                                            
* -------------------------------------------------------------------------------------------------- 
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                                                      
* CH00              1.0         NSI - Sivasankar K         11/Feb/2017      Initial development
* CH01              2.0
* CH02              3.0
**************************************************************************************************/
public without sharing class AutoComplete_Controller {
    public Object targetField{get;set;}
    public String labelField{ get; set; }
    public String valueField{ get; set; }
    public String sObjVal{get;set;}
    public String conString {get;set;}
    public Integer randomJsIden{get;set;}
   
    public AutoComplete_Controller(){
        randomJsIden = getRandomNumber(1000000);
        sObjVal='Account';
        labelField='Name';
        valueField='Id';
    }
    
    /*
    *Setter method to set the targetField
    ***/
    public void setTargetField(Object targetField){
        if(targetField == null){
            this.targetField = targetField;
        }
    }
    
    /*
    *Random number generator to change the js function name if multiple components us
    ***/
    public  Integer getRandomNumber(Integer size){
        Double d = Math.random() * size;
        return d.intValue();
    }
    
    /*
    *This method queries data according to the passed parameters
    ***/
    @RemoteAction
    public static List<SObject> getData(String sObjVal,String labelField,String valueField,String param,String conString){
        System.debug('sObjVal = '+sObjVal);
        System.debug('labelField = '+labelField);
        System.debug('valueField = '+valueField);
        System.debug('param = '+param);
        System.debug('conString = '+conString);
        param = String.escapeSingleQuotes(param);
        
        List<SObject> autocomResults = new List<SObject>();
        Set<String> removeDuplicates = new Set<String>();
        String lavelValue = '',templabelField = String.isNotBlank(labelField) ? labelField.replace('.','#') : labelField;
        List<String> labelfieldrelation = ((String.isNotBlank(templabelField) && templabelField.containsIgnoreCase('#')) ? templabelField.split('#') : new List<String>());
        String sQuery = 'SELECT '+(valueField.equalsIgnoreCase(labelField) ? '':valueField+',')+labelField+' FROM '+sObjVal+' WHERE '+labelField+' LIKE \'%'+param+'%\''+(String.isNotBlank(conString) ? ' AND '+conString:'');
        System.debug(' sQuery = '+sQuery);
        
        for(SObject thisobj :Database.query('SELECT '+(valueField.equalsIgnoreCase(labelField) ? '':valueField+',')+labelField+' FROM '+sObjVal+' WHERE '+labelField+' LIKE \'%'+param+'%\''+(String.isNotBlank(conString) ? ' AND '+conString:'')) ){
        	lavelValue = labelfieldrelation.isEmpty() ? (String)thisobj.get(labelField) : (String)(thisobj.getSobject(labelfieldrelation[0]).get(labelfieldrelation[1]) );
        	if(removeDuplicates.isEmpty() 
        		|| (!labelfieldrelation.isEmpty() && !removeDuplicates.contains(lavelValue)) 
        		|| !removeDuplicates.contains(lavelValue) ){
        		autocomResults.add(thisobj);
        		if(labelfieldrelation.isEmpty()){
        			removeDuplicates.add(lavelValue);
        		}
        		else if(labelfieldrelation.size() >= 1 ){
        			removeDuplicates.add(lavelValue);
        		}
        	}
        }
        
        return autocomResults;//Database.query('SELECT '+(valueField.equalsIgnoreCase(labelField) ? '':valueField+',')+labelField+' FROM '+sObjVal+' WHERE '+labelField+' LIKE \'%'+param+'%\''+(String.isNotBlank(conString) ? ' AND '+conString:''));
    }
    /*
     @RemoteAction
     public static List<SObject> getDataRate(String sObjVal,String labelField,String valueField,String param){
        param = String.escapeSingleQuotes(param);
        if(param != null){
            return Database.query('SELECT Location__c,Avoid_Validation__c,Surface__c,Description__c, Standard_Depth__c, unit__c, Backfill_Code__C, '+valueField+','+labelField+' FROM '+sObjVal+' WHERE '+labelField+' LIKE \'%'+param+'%\' OR Description__c Like \'%'+param+'%\'');
        }else{
            return null;
        }
    }
    
    @RemoteAction
    public static List<SObject> getTeamData(String sObjVal,String labelField,String valueField,String param){
        param = String.escapeSingleQuotes(param);
        return Database.query('SELECT '+valueField+','+labelField+' FROM '+sObjVal+' WHERE Active_or_Left__c = \'Active\' and Include_in_Reinstatement_Grid__c=true and '+labelField+' LIKE \'%'+param+'%\' order by '+labelField+'');
    }
   
    @RemoteAction
    public static List<SObject> getConsData(String sObjVal,String labelField,String valueField,String param){
        param = String.escapeSingleQuotes(param);
        return Database.query('SELECT Code__c, '+valueField+','+labelField+' FROM '+sObjVal+' WHERE '+labelField+' LIKE \'%'+param+'%\' or Code__c Like \'%'+param+'%\'');
    }
    */
    
}