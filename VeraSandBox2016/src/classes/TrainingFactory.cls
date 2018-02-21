/***********************************************************************************
 * Class : TrainingFactory
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Factory class for Training__c object
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    03/05/2016    Initial Development
 **********************************************************************************/
public with sharing class TrainingFactory {

    /**
     * Creates training records
     */
    public static List<Training__c> create(Integer numberOfRecords, Id countryId) {
        List<Training__c> trainings = new List<Training__c>();
        for (Integer i = 1; i <= numberOfRecords; i++) {
            Training__c training = new Training__c(
                Name = 'Test'+i,
                Status__c = 'PLAN',
                Country__c = countryId,
                Start_Date__c = System.today(),
                End_Date__c = System.today() + 5
            );
            trainings.add(training);
        }
        return trainings;
    }

    /**
     * Inserts training records
     */
    public static List<Training__c> insertData(List<Training__c> trainings) {
        insert trainings;
        return trainings;
    }

    /**
     * Creates and inserts training data
     */
    public static List<Training__c> createAndInsert(Integer numberOfRecords, Id countryId) {
        List<Training__c> trainings = create(numberOfRecords, countryId);
        insertData(trainings);
        return trainings;
    }

}