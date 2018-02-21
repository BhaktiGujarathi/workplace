public with sharing class DeploymentFactory {

/**
     * Creates  Deployment record
     * @param numberOfRecords as Integer for no. of records
     * @param missionId as Id for master object Mission__c
     * @param positionId as Id for master object Position__c
     * @param expertId as Id for master object Contact
     *
     * @return list of position records 
     */
     public static List<Deployment__c> createBasicPosition(
        Integer numberOfRecords,
        Id missionId,
        Id positionId,
        Id expertId
     ) {
        List<Deployment__c> deployments = new List<Deployment__c>();
        for (Integer i = 1; i <= numberOfRecords; i++) {
            Deployment__c deployment = new Deployment__c(
                Mission__c = missionId,
                Expert__c = expertId,
                Position__c = positionId
            );
            deployments.add(deployment);
        }
        return deployments;
    }
}