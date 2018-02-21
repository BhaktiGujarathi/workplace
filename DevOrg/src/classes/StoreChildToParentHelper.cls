public with sharing class StoreChildToParentHelper {

// opp.STips__c = '<HTML> <b> test </b> <table border="1"><tr> <td>test </td>  <td>test 22</td></tr>  </table></HTML>';
	
	private map<String, String> objFieldsMap = new map<String, String>();
	
	public StoreChildToParentHelper(){}
	public void copyField( list<sObject> sObjectList){
		
		this.populateCsData();
		
		for(sObject sObj : sObjectList){
			system.debug('***'+sObj.getSObjectType());
			
		}
		
		//Chek if field to append has HTML and Table tags
		/*if(pFieldToUpdate == '' || (pFieldToUpdate != '' && !pFieldToUpdate.contains('<HTML>') )){
			this.addHtmlTag(pFieldToUpdate);
		}*/
	}
	
	public void addHtmlTag(String pFieldToUpdate){
		pFieldToUpdate += '<Html>';		
		this.addTableTag(pFieldToUpdate);
	}
	
	public void addTableTag(String pFieldToUpdate){
		pFieldToUpdate += '<Table>';
		this.addRow(pFieldToUpdate);
	}
	
	public void addRow(String pFieldToUpdate){
		pFieldToUpdate += '<tr>';
		this.addColumns(pFieldToUpdate);
	}
	
	public void addColumns(String pFieldToUpdate){
		pFieldToUpdate += '<td>';
	}
	
	public void populateCsData(){
		for(FieldsToSendToMerchant__c csObj : FieldsToSendToMerchant__c.getall().values()){
			system.debug('***csObj***'+csObj);
			objFieldsMap.put(csObj.Object__c ,csObj.Fields__c );
		}	
	}
}