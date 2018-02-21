public with sharing class Position_Domain {

    public static Position__c getPositionForExpertSearch(Id positionId) {
        List<Position__c> positions = ([
                                        SELECT
                                            Id,
                                            Name,
                                            Mission__c,
                                            Core_Expertise_1__c,
                                            Core_Expertise_1__r.AoE_Category__c,
                                            Core_Expertise_2__c,
                                            Core_Expertise_2__r.AoE_Category__c,
                                            Core_Expertise_3__c,
                                            Core_Expertise_3__r.AoE_Category__c,
                                            Main_Profession__c,
                                            Main_Profession__r.Profession_Category__c,
                                            Secondary_Profession__c,
                                            Secondary_Profession__r.Profession_Category__c,
                                            Gender__c,
                                            Seniority__c,
                                            Global_South__c,
                                            CVIC_S_R__c,
                                            FOR_S_R__c,
                                            FIAR_S_R__c,
                                            SGBV_S_R__c,
                                            (
                                                SELECT
                                                    Id,
                                                    Position__c,
                                                    Expert__c,
                                                    Mission__c
                                                FROM
                                                    Deployments__r
                                            ),
                                            (
                                                SELECT
                                                    Id,
                                                    Name,
                                                    RecordType.DeveloperName,
                                                    Entry_from_Catalog__c,
                                                    Entry_from_Catalog__r.Region_UN__c,
                                                    Entry_from_Catalog__r.AoE_Category__c,
                                                    General_Level__c
                                                FROM
                                                    Expertise__r
                                            )
                                        FROM
                                            Position__c
                                        WHERE
                                            Id =: positionId
                                        LIMIT 1
                                        ]
                                    );
        return positions.size() > 0 ? positions[0] : null;
    }
}