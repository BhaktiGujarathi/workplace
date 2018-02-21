public with sharing class MissionFactory {

     /**
     * Creates basic mission record
     * @param numberOfRecordsas Integer for no. of records
     *
     * @return list of mission records 
     */
     public static List<Mission__c> createMission(Integer numberOfRecords) {
        List<Mission__c> missions = new List<Mission__c>();
        for (Integer i = 1; i <= numberOfRecords; i++) {
            Mission__c mission = new Mission__c(
                Name = 'Mission'+i
            );
            missions.add(mission);
        }
        return missions;
    }
    
    /**
     * Inserts mission records
     */
    public static List<Mission__c> insertData(List<Mission__c> missions) {
        insert missions;
        return missions;
    }

    /**
     * Creates basic mission record
     * @param numberOfRecordsas Integer for no. of records
     *
     * @return list of mission records 
     */
     public static List<Mission__c> createAndInsertMission(Integer numberOfRecords) {
        List<Mission__c> missions = new List<Mission__c>();
        for (Integer i = 1; i <= numberOfRecords; i++) {
            Mission__c mission = new Mission__c(
                Name = 'Mission'+i
            );
            missions.add(mission);
        }
        insert missions;
        return missions;
    }
}