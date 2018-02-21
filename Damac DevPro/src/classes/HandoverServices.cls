public with sharing class HandoverServices {
	
	public static generateDocument getPCCdocuemnt(String regId){
    HandoverMQService.HandoverHttpSoap11Endpoint calloutObj = new HandoverMQService.HandoverHttpSoap11Endpoint();
    calloutObj.timeout_x = 120000;
    generateDocument resObj = new generateDocument();

    try{
      String response = calloutObj.generatePCC( String.valueOf( Datetime.now().getTime()), 'PCC_DP', 'SFDC', regId, '', regId );
      resObj = (generateDocument)JSON.deserialize(response, HandoverServices.generateDocument.class);
      system.debug('pcc response === '+ resObj);
    } catch (Exception e ){
      resObj.status = 'Exception';
      resObj.url = 'https://www.google.com';
    }
    return resObj;
  }
  
  public static generateDocument getLODdocuemnt(String regId){
    HandoverMQService.HandoverHttpSoap11Endpoint calloutObj = new HandoverMQService.HandoverHttpSoap11Endpoint();
    calloutObj.timeout_x = 120000;
    generateDocument resObj = new generateDocument();

    try{
      String response = calloutObj.LetterofDischarge(String.valueOf( Datetime.now().getTime()), 'LETTER_OF_DISCHARGE', 'SFDC', regId, '', regId );
      resObj = (generateDocument)JSON.deserialize(response, HandoverServices.generateDocument.class);
      system.debug('lod response === '+ resObj);
    } catch (Exception e ){
      resObj.status = 'Exception';
      resObj.url = 'https://www.google.com';
    }
    return resObj;
  }
  
  public static generateDocument getKRFdocuemnt(String regId){
    HandoverMQService.HandoverHttpSoap11Endpoint calloutObj = new HandoverMQService.HandoverHttpSoap11Endpoint();
    calloutObj.timeout_x = 120000;
    generateDocument resObj = new generateDocument();

    try{
      String response = calloutObj.GenerateKeyReleaseForm(String.valueOf( Datetime.now().getTime()), 'KEY_RELEASE_FORM', 'SFDC', regId, '', regId );
      resObj = (generateDocument)JSON.deserialize(response, HandoverServices.generateDocument.class);
      system.debug('krf response === '+ resObj);
    } catch (Exception e ){
      resObj.status = 'Exception';
      resObj.url = 'https://www.google.com';
    }
    return resObj;
  }
  
  public static buildingCompletion getAreaCompletion(String locId){
    HandoverMQService.HandoverHttpSoap11Endpoint calloutObj = new HandoverMQService.HandoverHttpSoap11Endpoint();
    calloutObj.timeout_x = 120000;
    buildingCompletion resObj = new buildingCompletion();

    try{
      String response = calloutObj.getBuildingRERAPercentage(String.valueOf( Datetime.now().getTime()), 'BUILDING_COMP_PERCENTAGE', 'SFDC', locId);
      resObj = (buildingCompletion)JSON.deserialize(response, HandoverServices.buildingCompletion.class);
      system.debug('response === '+ resObj);
    } catch (Exception e ){
      resObj.status = 'Exception';
      //resObj.url = 'https://www.google.com';
    }
    return resObj;
  }
  
  public class generateDocument{
      public String status {get;set;}
      public String url {get;set;}
  }
  
  public class buildingCompletion {
  	public String status {get;set;}
  	public String PROC_MESSAGE {get;set;}
  	public String Message {get;set;}
  	public String REQUEST_ID {get;set;}
  	public String BUILDING_ID {get;set;}
  	public String URL {get;set;}
  }

}