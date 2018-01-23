trigger updateMentalHealthSymptom on Mental_Health_Symptom__c (before insert, after insert, before update, after update ) {
	System.debug('trigger just got CALLED');
		TriggerFactory.createAndExecuteHandler(mentalHealthSymptomHandler.class);
		
	}