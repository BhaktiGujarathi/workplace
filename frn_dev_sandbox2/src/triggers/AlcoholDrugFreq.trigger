trigger AlcoholDrugFreq on  Alcohol_Drug_History_Frequency__c (before insert, before update){
  TriggerFactory.createAndExecuteHandler(AlcoholDrugFreq.class); 

}