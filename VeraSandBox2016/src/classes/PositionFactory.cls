/***********************************************************************************
 * Class : PositionFactory
 * Created By : Ashwini kr singh
 -----------------------------------------------------------------------------------
 * Description : Factory class for Position__c object
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name      Date          Detail Features
   1.0        Ashwini kr singh    03/05/2016    Initial Development
 **********************************************************************************/

public with sharing class PositionFactory {

    /**
     * Creates basic position record
     * @param numberOfRecordsas Integer for no. of records
     * @param missionId as Id for master object Mission__c
     *
     * @return list of position records 
     */
     public static List<Position__c> createBasicPosition(Integer numberOfRecords, Id missionId) {
        List<Position__c> positions = new List<Position__c>();
        for (Integer i = 1; i <= numberOfRecords; i++) {
            Position__c position = new Position__c(
                Name = 'Position'+i,
                Mission__c = missionId
            );
            positions.add(position);
        }
        return positions;
    }
    
    /**
     * Creates basic position record
     * @param numberOfRecordsas Integer for no. of records
     * @param missionId as Id for master object Mission__c
     * @param mainProfessionId as Id for master object Mission__c
     * @param secondaryprofessionId as Id for master object Mission__c
     * @param coreExpertise1 as Id for master object Mission__c
     * @param coreExpertise2 as Id for master object Mission__c
     * @param coreExpertise3 as Id for master object Mission__c
     *
     * @return list of position records 
     */
    public static List<Position__c> createPosition(
        Integer numberOfRecords,
        Id missionId,
        Id mainProfessionId,
        Id secondaryprofessionId,
        Id coreExpertise1,
        Id coreExpertise2,
        Id coreExpertise3
    ) {
        List<Position__c> positions = new List<Position__c>();
        for(Integer i = 1; i <= numberOfRecords; i++) {
            Position__c position = new Position__c(
                Name = 'Position'+i,
                Mission__c = missionId,
                SGBV__c =true,
                SGBV_S_R__c = true,
                Seniority__c = 2,
                CVIC__c = true,
                CVIC_S_R__c = true,
                FIAR__c = true,
                FIAR_S_R__c = true,
                FOR__c = true,
                FOR_S_R__c = true,
                Gender__c = 'Male',
                Global_South__c = true,
                Main_Profession__c = mainProfessionId,
                Secondary_Profession__c = secondaryprofessionId,
                Core_Expertise_1__c = coreExpertise1,
                Core_Expertise_2__c = coreExpertise2,
                Core_Expertise_3__c = coreExpertise3
            );
            positions.add(position);
        }
        return positions;
    }
    
     /**
     * Inserts position records
     */
    public static List<Position__c> insertData(List<Position__c> positions) {
        insert positions;
        return positions;
    }
}