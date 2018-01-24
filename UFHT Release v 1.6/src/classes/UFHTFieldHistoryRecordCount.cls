/**
 * @Class Name: UFHTFieldHistoryRecordCount.
 * @Description: This class accepts record count and selected object as a parameter and update the record count
 *               in the UFHT__Ultra_Track_Container__c Object.
 * ====================================================================================================================
 *       Version   | Date        | Author             | Comments
 *   ------------------------------------------------------------------------------------------------------------------
 *       1.0       | 01/02/2017  | Eternus Solutions   | 1. Created Class for above functionality.
 * ====================================================================================================================
**/
public class UFHTFieldHistoryRecordCount {
	
	
    /**
     * @Author: Eternus Solutions
     * @Description: Method to accept recordCount and Seleted Object to update recordCount.
     * @Param:
     * @Return: None
     * @Date: 01/02/2017
     **/       
    public static void updateRecordCount(String objectName,Integer recordCount) {  
    	integer maxThreeEntry = 1 ;
	    	while(maxThreeEntry <= 3){
	    		 
		        if(String.isNotBlank(objectName) && recordCount!=null) {
		     		
		            try{
		            //UFHTList Fetches the selected Object Name
		            list<UFHT__Ultra_Track_Container__c>  UltraFieldHistoryList = [SELECT Id,
		                                                                                  UFHT__Object_Name__c ,
		                                                                                  UFHT__No_of_Records__c  
		                                                                             FROM UFHT__Ultra_Track_Container__c 
		                                                                            WHERE UFHT__Object_Name__c = : objectName 
		                                                                            LIMIT 1 
		                                                                             FOR UPDATE];	
		                //Updates field UFHT__No_of_Records__c  in UFHT__Ultra_Track_Container__c                                                                               
			            if(!UltraFieldHistoryList.isEmpty()) {
			            	
			                UltraFieldHistoryList[0].UFHT__No_of_Records__c = recordCount;		                
				            update UltraFieldHistoryList ;
			            }
			            break; 
		            }
		            
		            catch(DMLException e){
		            	maxThreeEntry++ ;
	                }         
		        }
	    	}
    	
    }
}